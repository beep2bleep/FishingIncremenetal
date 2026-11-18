"""Record 0.9 receipts. Mark demo live only after Steam Mobile confirmation."""
import argparse
import hashlib
import json
from pathlib import Path

parser = argparse.ArgumentParser()
parser.add_argument('--demo-live', action='store_true')
args = parser.parse_args()
root = Path(__file__).resolve().parents[2]
project = root / 'FeedingABlackHoldGame'
target = project / 'StoreAssets_RailwayFury/steam/build-manifest.json'
manifest = json.loads(target.read_text(encoding='utf8'))
assert manifest['version'] == '0.9'
manifest['qa'] = {'full_pack_checks': 15, 'demo_pack_checks': 15,
                  'itch_windows_pack_checks': 25, 'source_release09_checks': 52,
                  'full_qa_release09_checks': 52, 'demo_qa_release09_checks': 51,
                  'full_qa_release_ux_checks': 54, 'demo_qa_release_ux_checks': 31,
                  'full_qa_shared_progress_checks': 39, 'demo_qa_shared_progress_checks': 57,
                  'timed_source_checks': 134, 'physical_controller_verified': False,
                  'cross_device_cloud_verified': False, 'live_leaderboard_score_uploaded': False}
manifest['steam_upload'].update({
    'set_live': args.demo_live, 'full_set_live': True, 'demo_set_live': args.demo_live,
    'full_branch': 'default', 'demo_branch': 'default' if args.demo_live else None,
    'demo_current_default': 26767544 if args.demo_live else 26758130,
    'demo_pending_mobile_confirmation': not args.demo_live, 'demo_released': True,
    'previous_full_build_id': 26758129, 'previous_demo_build_id': 26758130,
})
manifest['cloud'] = {'storage_owner': 5520330, 'full_shared_app_id': 5520330,
                     'demo_shared_app_id': 0, 'published': True,
                     'reason': 'The demo is released; the full game remains unreleased.'}
manifest['itch_uploads'] = {
    'demo': {'version':'0.9','public':True,'platforms':['Web','Windows'],
             'url':'https://beep2bleep.itch.io/railway-fury-demo'},
    'full': {'version':'0.9','public':False,'draft':True,'platforms':['Windows'],
             'project_id':5397032,'url':'https://beep2bleep.itch.io/railway-fury',
             'editor_url':'https://itch.io/game/edit/5397032','package_checks':15},
}
for name in ['Settings.gd','Tech Tree Stuff/TechTree.gd','Games/RowDivers/Translations/catalog.json']:
    manifest['runtime_sources'][name] = hashlib.sha256((project / name).read_bytes()).hexdigest()
target.write_text(json.dumps(manifest, indent=2)+'\n', encoding='utf8')
files = {}
build = root / 'Build - RailwayFury'
for relative in ['Steam/Full/RailwayFury.exe','Steam/Full/RailwayFury.pck',
                 'Steam/Demo/RailwayFuryDemo.exe','Steam/Demo/RailwayFuryDemo.pck',
                 'Demo/RailwayFuryDemo-Windows.zip','Demo/RailwayFuryDemo-Web.zip',
                 'Full/RailwayFury-Full-Windows.zip']:
    path = build / relative
    files[relative] = {'bytes':path.stat().st_size,'sha256':hashlib.sha256(path.read_bytes()).hexdigest()}
release = {'version':'0.9','uploaded':{'steam':True,'itch':True},
           'steam_upload':manifest['steam_upload'], 'cloud':manifest['cloud'], 'files':files,
           'itch_uploads':manifest['itch_uploads'],
           'itch_page':'https://beep2bleep.itch.io/railway-fury-demo'}
(build / 'build_manifest_0.9.json').write_text(json.dumps(release,indent=2)+'\n',encoding='utf8')
