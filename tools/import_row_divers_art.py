"""Copy the user-requested original artwork and resolve its UI references."""
from pathlib import Path
import hashlib, json, re, shutil
from import_row_divers import documents, ROOT

SOURCE = Path(r'C:\Decompiled\Row Divers\ExportedProject\Assets')
DEST = ROOT / 'FeedingABlackHoldGame/Games/RowDivers/Art/Original'

def run():
    lookup = {}
    for meta in SOURCE.rglob('*.meta'):
        match = re.search(r'^guid: (\w+)', meta.read_text(encoding='utf-8-sig'), re.M)
        if match: lookup[match[1]] = meta.with_suffix('')
    def texture(ref):
        path = lookup.get(ref.get('guid'))
        if not path: return None
        if path.suffix == '.png': return path.name
        if path.parent.name == 'Sprite':
            sprite = next(iter(documents(path).values()))[1]
            return texture(sprite.get('m_RD', {}).get('texture', {}))
        return None
    home = documents(SOURCE / 'Scenes/HomeScene.unity')
    icons = {}
    for uid, (_, v) in home.items():
        if 'upgradeName' not in v: continue
        name = texture(v.get('upgradeIcon', {}))
        assert name, v['upgradeName']
        icons[str(uid)] = name
    names = set(icons.values()) | set('''Enemy1.png|Enemy2.png|Enemy3.png|Enemy4.png|MiniBoss.png|MiniBoss2.png|Boss.png|1.png|dagger.png|dm.png|dmf.png|Arrow.png|Arrow_0.png|shuriken.png|enemy bullet template.png|Coin.png|Gem.png|Crown.png|Floor Texture.png|Floor Texture 2.png|Wall Texture.png|Wall Texture 2.png|Wall_Boss_Texture.png|boss_room_floor_texture1.png|Throne.png|BenevolentGod.png|DevilGod.png|third eye.png|Arrow Shield.png|Harvester.png|Remedy.png'''.split('|'))
    achievement_names = {'FirstDive':'First Dive', 'FirstMiniBoss':'First Mini Boss', 'FirstBoss':'First Boss', 'RowDiver':'Prestige0', 'Prestige1':'Prestige1', 'Prestige2':'Prestige2', 'Prestige3':'Prestige3', 'PrestigeMaster':'PrestigeMaster', 'BossSlayer':'BossSlayer', 'BeatTheGame':'CompleteTheGame', 'BenevolentGod':'BenevolentGod', 'EvilGod':'DevilGod', 'ArmoredTank':'Armored Tank', 'BowMaster':'Bow Master', 'Vampire':'Vampire', 'Healer':'Healer', 'CoinMaster':'Coins Collector', 'GemMaster':'GemCollector'}
    achievements = {k:v+'.png' for k,v in achievement_names.items()}
    names.update(achievements.values())
    DEST.mkdir(parents=True, exist_ok=True)
    manifest = []
    for name in sorted(names):
        source = SOURCE / 'Texture2D' / name
        assert source.is_file(), source
        shutil.copyfile(source, DEST / name)
        manifest.append({'file':name, 'source':str(source), 'sha256':hashlib.sha256(source.read_bytes()).hexdigest()})
    (DEST / 'manifest.json').write_text(json.dumps({'source':'User-supplied Row Divers decompilation', 'upgrades':icons, 'achievements':achievements, 'files':manifest}, indent=2))
    print(f'Copied {len(manifest)} original textures; resolved {len(icons)} upgrade icons')

if __name__ == '__main__': run()
