"""Record edition binaries and the exact current runtime source fingerprints."""
import hashlib
import json
import pathlib
import subprocess
import re
import argparse
from datetime import datetime, timezone

ROOT = pathlib.Path(__file__).resolve().parents[2]
PROJECT = ROOT/'FeedingABlackHoldGame'
def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()

version = re.search(r'^config/version="([^"]+)"', (PROJECT/'project.godot').read_text(encoding='utf-8-sig'), re.M)[1]
parser = argparse.ArgumentParser()
parser.add_argument('--upload-log', type=pathlib.Path)
args = parser.parse_args()
result = {'version':version, 'full_app':5520300, 'demo_app':5520330,
          'generated_utc':datetime.now(timezone.utc).isoformat(),
          'base_commit':subprocess.check_output(['git','rev-parse','HEAD'],cwd=ROOT,text=True).strip(),
          'qa':{'full_pack_checks':15,'demo_pack_checks':15,'controller_checks':88,'analytics_checks':12,'menu_checks':19},
          'binaries':{}, 'runtime_sources':{}}
for edition in ['Full','Demo']:
    folder = ROOT/'Build - RailwayFury/Steam'/edition
    result['binaries'][edition] = {p.relative_to(folder).as_posix():{'bytes':p.stat().st_size,'sha256':digest(p)}
                                  for p in sorted(folder.rglob('*')) if p.is_file()}
sources = [PROJECT/'project.godot', PROJECT/'SteamHandler.gd', PROJECT/'VirtualCursor.gd', PROJECT/'GameAnalyticsManager.gd',
           PROJECT/'UpgradeScreen.gd', PROJECT/'Core/Boot/GameLauncher.gd']
sources += sorted((PROJECT/'Games/RowDivers').rglob('*.gd'))
result['runtime_sources'] = {p.relative_to(PROJECT).as_posix():digest(p) for p in sources
                             if not any(part in p.parts for part in ['Simulation','Tools','Docs'])}
target = PROJECT/'StoreAssets_RailwayFury/steam/build-manifest.json'
if args.upload_log:
    uploaded = dict(re.findall(r'Successfully finished AppID (\d+) build \(BuildID (\d+)\)',args.upload_log.read_text(encoding='utf-8-sig')))
    assert set(uploaded)=={'5520300','5520330'}, 'Both Steam upload success receipts are required'
    result['steam_upload'] = {'uploaded':True,'set_live':False,'full_build_id':int(uploaded['5520300']),'demo_build_id':int(uploaded['5520330'])}
target.write_text(json.dumps(result,indent=2)+'\n',encoding='utf8')
print('Wrote build fingerprints without credentials or save data.')
