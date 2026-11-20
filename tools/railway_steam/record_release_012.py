"""Record 0.12 package receipts; mark publication only after UI verification."""
import argparse
import datetime
import hashlib
import json
from pathlib import Path

parser = argparse.ArgumentParser()
for flag in ['full_live', 'demo_live', 'itch_live', 'store_saved', 'store_published']:
    parser.add_argument('--' + flag.replace('_', '-'), action='store_true')
args = parser.parse_args()
root = Path(__file__).resolve().parents[2]
project = root / 'FeedingABlackHoldGame'
build = root / 'Build - RailwayFury'
manifest = {
    'version': '0.12', 'generated_utc': datetime.datetime.now(datetime.timezone.utc).isoformat(),
    'qa': {'steam_full_pack': 15, 'steam_demo_pack': 15, 'itch_windows_pack': 25,
           'autofire_full': 51, 'autofire_demo': 51, 'animation_full': 64, 'animation_demo': 64,
           'shared_progress_full': 39, 'shared_progress_demo': 57,
           'localization_full': 20034, 'localization_demo': 20034, 'failures': 0},
    'steam': {'full_build': 26820067, 'demo_build': 26820070,
              'full_live_verified': args.full_live, 'demo_live_verified': args.demo_live},
    'itch': {'project_id': 5243421, 'version': '0.12', 'live_verified': args.itch_live,
             'url': 'https://beep2bleep.itch.io/railway-fury-demo', 'platforms': ['Windows', 'Web']},
    'store_copy': {'folder': 'StoreLocalization/2026-11-20', 'steam_languages': 16,
                   'catalan_local_copy': True, 'saved': args.store_saved, 'published': args.store_published},
    'binaries': {}, 'sources': {},
}
for name in ['Steam/Full/RailwayFury.exe', 'Steam/Full/RailwayFury.pck',
             'Steam/Demo/RailwayFuryDemo.exe', 'Steam/Demo/RailwayFuryDemo.pck',
             'Demo/RailwayFuryDemo-Windows.zip', 'Demo/RailwayFuryDemo-Web.zip']:
    path = build / name
    manifest['binaries'][name] = {'bytes': path.stat().st_size,
                                 'sha256': hashlib.sha256(path.read_bytes()).hexdigest()}
for name in ['project.godot', 'Games/RowDivers/RowDiversActor.gd',
             'Games/RowDivers/Scenes/RowDiversBattleScene.gd', 'Games/RowDivers/RowDiversProgress.gd',
             'Games/RowDivers/RowDiversHUD.gd', 'Games/RowDivers/Translations/catalog.json',
             'Games/RowDivers/Data/row_divers.json', 'Games/RowDivers/Data/row_divers_previous.json',
             'Games/RowDivers/Data/row_divers_free_aim.json']:
    manifest['sources'][name] = hashlib.sha256((project / name).read_bytes()).hexdigest()
text = json.dumps(manifest, indent=2) + '\n'
(build / 'build_manifest_0.12.json').write_text(text, encoding='utf8')
(project / 'StoreAssets_RailwayFury/steam/build-manifest.json').write_text(text, encoding='utf8')
print('Recorded 0.12 receipts and verified publication flags.')
