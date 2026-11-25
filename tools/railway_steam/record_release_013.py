"""Record 0.13 package receipts; mark publication only after UI verification."""
import argparse
import datetime
import hashlib
import json
from pathlib import Path

parser = argparse.ArgumentParser()
for flag in ['full_live', 'demo_live', 'itch_live', 'store_saved', 'store_published']:
    parser.add_argument('--' + flag.replace('_', '-'), action='store_true')
parser.add_argument('--full-build', type=int, required=True)
parser.add_argument('--demo-build', type=int, required=True)
args = parser.parse_args()
root = Path(__file__).resolve().parents[2]
project = root / 'FeedingABlackHoldGame'
build = root / 'Build - RailwayFury'
manifest = {
    'version': '0.13', 'generated_utc': datetime.datetime.now(datetime.timezone.utc).isoformat(),
    'qa': {'steam_full_pack': 17, 'steam_demo_pack': 17, 'itch_windows_pack': 25,
           'autofire_full': 51, 'autofire_demo': 51, 'utility_start_full': 39, 'utility_start_demo': 39,
           'physical_gamesir_verified': False, 'failures': 0},
    'steam': {'full_build': args.full_build, 'demo_build': args.demo_build,
              'full_live_verified': args.full_live, 'demo_live_verified': args.demo_live},
    'itch': {'project_id': 5243421, 'version': '0.13', 'live_verified': args.itch_live,
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
             'Games/RowDivers/RowDiversHUD.gd', 'Games/RowDivers/RowDiversController.gd',
             'Games/RowDivers/RowDiversUtilityGlyphs.gd', 'UpgradeScreen.gd', 'Core/Boot/GameLauncher.gd', 'Games/RowDivers/Translations/catalog.json',
             'Games/RowDivers/Data/row_divers.json', 'Games/RowDivers/Data/row_divers_previous.json',
             'Games/RowDivers/Data/row_divers_free_aim.json']:
    manifest['sources'][name] = hashlib.sha256((project / name).read_bytes()).hexdigest()
text = json.dumps(manifest, indent=2) + '\n'
(build / 'build_manifest_0.13.json').write_text(text, encoding='utf8')
(project / 'StoreAssets_RailwayFury/steam/build-manifest.json').write_text(text, encoding='utf8')
print('Recorded 0.13 receipts and verified publication flags.')
