"""Copy generated art byte-for-byte, preserve alpha, and build runtime mappings."""
from pathlib import Path
import hashlib, json, shutil
from PIL import Image

ROOT=Path(__file__).resolve().parents[1]
DEST=ROOT/'FeedingABlackHoldGame/Games/RowDivers/Art/Illustrated'
MAPPING={
    'Enemy1.png':'enemy_0','Enemy2.png':'enemy_1','Enemy3.png':'enemy_2','Enemy4.png':'enemy_3',
    'MiniBoss.png':'enemy_4','MiniBoss2.png':'enemy_5','Boss.png':'enemy_6',
    'Wall Texture.png':'wall','Wall Texture 2.png':'wall','Wall_Boss_Texture.png':'boss_wall',
    'Floor Texture.png':'floor','Floor Texture 2.png':'floor','boss_room_floor_texture1.png':'boss_floor',
    'lava.png':'lava','acid.png':'acid','purple acid.png':'acid',
    '1.png':'bow','2.png':'bow','3.png':'bow','4.png':'bow','5.png':'bow','dagger.png':'dagger',
    'Arrow.png':'arrow','Arrow_0.png':'arrow','FireArrow.png':'fire_arrow','CursedArrow.png':'curse_arrow',
    'shuriken.png':'shuriken','enemy bullet template.png':'enemy_bolt','dm.png':'curse_gem','dmf.png':'ember_gem',
    'plant.png':'plant','plant2.png':'plant','plant3.png':'plant','spider web.png':'web','Spikes.png':'spikes',
    'cell.png':'bars','half cell.png':'bars','Decor.png':'decor','Decor2.png':'decor','Throne.png':'throne',
    'Coin.png':'coin','Gem.png':'gem','Crown.png':'crown','Bleed.png':'status_bleed','Curse.png':'status_curse',
    'fire particle.png':'status_fire','Arrow Shield.png':'ability_shield','Harvester.png':'ability_harvester',
    'Remedy.png':'ability_slow','third eye.png':'third_eye',
}

def run():
    source=json.loads((DEST/'generated_sources.json').read_text(encoding='utf-8'))
    files=[]
    opaque={'wall','floor','boss_wall','boss_floor','lava','acid'}
    for name in sorted(set(MAPPING.values())):
        entry=source[name]; path=Path(entry['source']); target=DEST/(name+'.png')
        assert path.is_file(),path
        shutil.copyfile(path,target)
        im=Image.open(target)
        if name not in opaque:
            assert im.mode=='RGBA' and im.getextrema()[3][0]==0,(name,'missing transparent background')
        files.append({'name':name,'file':target.name,'width':im.width,'height':im.height,'sha256':hashlib.sha256(target.read_bytes()).hexdigest(),'source':str(path),'prompt':entry['prompt'],'generator':'Built-in image_gen'})
    # A shadow is a renderer primitive rather than a character/illustration asset.
    (DEST/'shadow.svg').write_text('<svg xmlns="http://www.w3.org/2000/svg" width="128" height="128"><ellipse cx="64" cy="64" rx="56" ry="30" fill="#17151a" fill-opacity=".5"/></svg>')
    textures={k:v+'.png' for k,v in MAPPING.items()}
    textures['Shadow.png']='shadow.svg'
    manifest={'name':'Illustrated','generator':'Built-in image_gen','textures':textures,'files':files,'notes':'New hand-inked combat sprites, seamless stone textures and props. Original geometry/animation and gameplay are retained. All generated PNG files are copied without editing.'}
    (DEST/'manifest.json').write_text(json.dumps(manifest,indent=2),encoding='utf-8')
    print(f'Installed {len(files)} generated assets; {len(textures)} texture mappings')

if __name__=='__main__':run()
