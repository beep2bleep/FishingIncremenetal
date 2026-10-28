"""Record edition binaries and the exact current runtime source fingerprints."""
import hashlib
import json
import pathlib
import subprocess

ROOT = pathlib.Path(__file__).resolve().parents[2]
PROJECT = ROOT/'FeedingABlackHoldGame'
def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()

result = {'version':'0.1', 'full_app':5520300, 'demo_app':5520330,
          'planned_release':'2027-03-22T10:00:00-07:00', 'requested_usd_price':2.99,
          'price_saved':False, 'published':False,
          'base_commit':subprocess.check_output(['git','rev-parse','HEAD'],cwd=ROOT,text=True).strip(),
          'qa':{'full_pack_checks':11,'demo_pack_checks':11,'controller_checks':88},
          'binaries':{}, 'runtime_sources':{}}
for edition in ['Full','Demo']:
    folder = ROOT/'Build - RailwayFury/Steam'/edition
    result['binaries'][edition] = {p.relative_to(folder).as_posix():{'bytes':p.stat().st_size,'sha256':digest(p)}
                                  for p in sorted(folder.rglob('*')) if p.is_file()}
sources = [PROJECT/'project.godot', PROJECT/'SteamHandler.gd', PROJECT/'VirtualCursor.gd',
           PROJECT/'UpgradeScreen.gd', PROJECT/'Core/Boot/GameLauncher.gd']
sources += sorted((PROJECT/'Games/RowDivers').rglob('*.gd'))
result['runtime_sources'] = {p.relative_to(PROJECT).as_posix():digest(p) for p in sources
                             if not any(part in p.parts for part in ['Simulation','Tools','Docs'])}
target = PROJECT/'StoreAssets_RailwayFury/steam/build-manifest.json'
target.write_text(json.dumps(result,indent=2)+'\n',encoding='utf8')
print('Wrote build fingerprints without credentials or save data.')
