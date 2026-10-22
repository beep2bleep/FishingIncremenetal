"""Optional native Unity inspection in an isolated, save-redirected project copy."""
from pathlib import Path
import shutil, json, re, argparse, os
from prepare_reference import ROOT

SOURCE=Path(r'C:\Decompiled\Row Divers\ExportedProject')
WORK=ROOT/'.validation/rowdivers-parity/native-unity'

def replace_method(text, name, replacement):
    from prepare_reference import method
    return text.replace(method(text,name), replacement+'\n')

def prepare(play=False,fixture=None):
    # No symlinks: Unity may freely rewrite imports/metadata in this copy only.
    shutil.copytree(SOURCE,WORK,dirs_exist_ok=True)
    scripts=WORK/'Assets/Scripts/Assembly-CSharp'
    save=scripts/'SaveSystem.cs';text=save.read_text(encoding='utf-8-sig')
    isolated=WORK/'ParitySave';isolated.mkdir(exist_ok=True)
    # Reset only instrumentation saves so reruns start with the same progress.
    assert isolated.resolve().parent == WORK.resolve()
    for saved in isolated.iterdir():
        if saved.is_file(): saved.unlink()
    text=text.replace('Application.persistentDataPath',json.dumps(str(isolated).replace('\\','/')))
    save.write_text(text,encoding='utf-8')
    steam=scripts/'SteamManager.cs';text=steam.read_text(encoding='utf-8-sig')
    text=replace_method(text,'TryConnectToSteam','public void TryConnectToSteam() { Debug.Log("PARITY: Steam initialization disabled"); }')
    text=replace_method(text,'OnApplicationQuit','private void OnApplicationQuit() {}')
    steam.write_text(text,encoding='utf-8')
    (WORK/'Assets/Editor').mkdir(exist_ok=True)
    shutil.copyfile(Path(__file__).with_name('NativeParityEditor.cs'),WORK/'Assets/Editor/NativeParityEditor.cs')
    if play:
        # Exported player-only Input System DLLs reject Editor update events.
        # Gameplay uses legacy Input, which is instrumented below; retain the
        # removed copies outside Assets rather than altering the source export.
        excluded=WORK/'ExcludedPlayerOnlyPlugins';excluded.mkdir(exist_ok=True)
        for name in ['Unity.InputSystem.dll','Unity.InputSystem.ForUI.dll']:
            for suffix in ['', '.meta']:
                plugin=WORK/'Assets/Plugins'/(name+suffix)
                if plugin.exists():
                    shutil.copyfile(plugin,excluded/plugin.name);plugin.unlink()
        settings=WORK/'ProjectSettings/ProjectSettings.asset'
        settings.write_text(re.sub(r'activeInputHandler: \d+', 'activeInputHandler: 0', settings.read_text(encoding='utf-8')),encoding='utf-8')
        shutil.copyfile(Path(__file__).with_name('NativeParityRuntime.cs'),WORK/'Assets/NativeParityRuntime.cs')
        for name in ['PlayerController','ArrowShield','Harvester','Shuriken','SlowDown','ShootingWeapon','ThirdEye']:
            path=scripts/(name+'.cs');text=path.read_text(encoding='utf-8-sig')
            text=re.sub(r'\bInput\.(GetKeyDown|GetMouseButtonDown|GetMouseButton|mousePosition)',r'NativeParityInput.\1',text)
            text=text.replace('Input.GetAxis("Horizontal")','NativeParityInput.Horizontal')
            path.write_text(text,encoding='utf-8')
        sections=scripts/'SectionsManager.cs';text=sections.read_text(encoding='utf-8-sig').replace('new System.Random()', 'new System.Random(5400)');sections.write_text(text,encoding='utf-8')
        shutil.copyfile(fixture,WORK/'fixture.json')
        shutil.copyfile(ROOT/'FeedingABlackHoldGame/Games/RowDivers/Data/row_divers.json',WORK/'catalog.json')
    print(WORK)

if __name__=='__main__':
    parser=argparse.ArgumentParser();parser.add_argument('--play',action='store_true');parser.add_argument('--fixture',type=Path,default=Path(os.environ['TEMP'])/'RailwayFury-maxed-reference-fixture.json')
    args=parser.parse_args();prepare(args.play,args.fixture)
