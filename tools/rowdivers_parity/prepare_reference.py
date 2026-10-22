"""Compile the user's unmodified decompiled C# against explicit headless adapters.

Generated copies and binaries stay in ignored .validation; no Unity game is launched.
"""
from pathlib import Path
import hashlib, json, shutil, subprocess, argparse, re

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).resolve().parent
SOURCES = '''Stat StatType WeaponType FireType TabType AbilityType CurrencyType
ZombieType ProjectileType Rarity Pair CurrencyCost IDamageable Entity Player
PlayerController Enemy Zombie MiniBoss Boss EnemyEffectManager Projectile Arrow
FireArrow CursedArrow ShurikenProjectile EnemyArrow Ability ArrowShield Harvester
Shuriken SlowDown UpgradeData AchievementChecker AchievementType Achievement CurrencyItem Item PrestigeSystem Weapon MeleeWeapon ThirdEye EndGamePanel Stats UDictionary'''.split()

def method(text, name):
    start = re.search(r'^\s*(?:public|private|protected) [^\n;=]*\b' + name + r'(?:<[^>]*>)?\(', text, re.M).start()
    brace = text.index('{', start)
    depth = 1
    end = brace + 1
    while depth:
        depth += (text[end] == '{') - (text[end] == '}')
        end += 1
    return text[start:end] + '\n'

def prepare(source, work):
    scripts = source / 'Assets/Scripts/Assembly-CSharp'
    work.mkdir(parents=True, exist_ok=True)
    manifest = {}
    for name in SOURCES:
        path = scripts / (name + '.cs')
        shutil.copyfile(path, work / path.name)
        manifest[path.name] = hashlib.sha256(path.read_bytes()).hexdigest()
    for name in ['UnityAdapters.cs', 'Program.cs']:
        shutil.copyfile(HERE / name, work / name)
    wrappers = (HERE / 'SourceMethods.cs.txt').read_text()
    groups = {
        'UpgradeController': ['UpgradeFlow', 'ActivateChildUpgrades', 'ApplyUpgradeStats', 'Unlock', 'IsUnlockable'],
        'UpgradesTreeManager': ['EverythingUnlocked', 'IncreaseMaxedUpgrades', 'CheckMaxed', 'Unlock'],
        'AchievementManager': ['CheckUpgradeAchievements', 'TryUnlockStatAchievement', 'TryUnlockCurrencyAchievement'],
        'PanelManager': ['UnlockGodButton'],
        'GameManager': ['StartGame', 'BossDefeated', 'DropCrown', 'HandlePrestigeAchievements', 'HandleBossSlayerAchievement', 'UnlockNewPrestige', 'SuccessPanelSetup'],
    }
    for cls, methods in groups.items():
        path = scripts / (cls + '.cs')
        content = path.read_text(encoding='utf-8-sig')
        wrappers = wrappers.replace('/* ' + cls + ' */', '\n'.join(method(content, name) for name in methods))
        manifest[cls + '.cs'] = hashlib.sha256(path.read_bytes()).hexdigest()
    (work / 'SourceMethods.cs').write_text(wrappers)
    (work / 'Reference.csproj').write_text('''<Project Sdk="Microsoft.NET.Sdk">
<PropertyGroup><OutputType>Exe</OutputType><TargetFramework>net8.0</TargetFramework>
<ImplicitUsings>disable</ImplicitUsings><Nullable>disable</Nullable>
<NoWarn>0169;0649;0414;0108</NoWarn></PropertyGroup></Project>''')
    (work / 'source_manifest.json').write_text(json.dumps(manifest, indent=2))
    subprocess.run(['dotnet', 'build', str(work / 'Reference.csproj'), '-v:q', '--nologo'], check=True)
    return work / 'bin/Debug/net8.0/Reference.dll'

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--source', type=Path, default=Path(r'C:\Decompiled\Row Divers\ExportedProject'))
    parser.add_argument('--work', type=Path, default=ROOT / '.validation/rowdivers-parity/reference')
    args = parser.parse_args()
    print(prepare(args.source, args.work))
