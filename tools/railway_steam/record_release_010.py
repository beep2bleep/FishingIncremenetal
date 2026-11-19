"""Record verified 0.10 uploads and package fingerprints."""
from pathlib import Path
import datetime
import hashlib
import json
import subprocess

root = Path(__file__).resolve().parents[2]
project = root / 'FeedingABlackHoldGame'
build = root / 'Build - RailwayFury'
manifest = {
    'version': '0.10',
    'generated_utc': datetime.datetime.now(datetime.timezone.utc).isoformat(),
    'base_commit': subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=root).decode().strip(),
    'qa': {'steam_full_pack': 15, 'steam_demo_pack': 15, 'itch_windows_pack': 25,
           'promotion_full': 50, 'promotion_demo': 29, 'failures': 0},
    'steam': {'full_build': 26798324, 'full_default_changed': False,
              'demo_build': 26798327, 'demo_default': 26798327, 'demo_live_verified': True},
    'itch': {'project_id': 5243421, 'version': '0.10', 'public': True,
             'platforms': ['Web', 'Windows'],
             'url': 'https://beep2bleep.itch.io/railway-fury-demo',
             'hosted_url': 'https://html-classic.itch.zone/html/20674135/index.html'},
    'binaries': {}, 'sources': {},
}
for name in ['Steam/Full/RailwayFury.exe', 'Steam/Full/RailwayFury.pck',
             'Steam/Demo/RailwayFuryDemo.exe', 'Steam/Demo/RailwayFuryDemo.pck',
             'Demo/RailwayFuryDemo-Windows.zip', 'Demo/RailwayFuryDemo-Web.zip']:
    path = build / name
    manifest['binaries'][name] = {'bytes': path.stat().st_size,
                                 'sha256': hashlib.sha256(path.read_bytes()).hexdigest()}
for name in ['project.godot', 'Core/Boot/GameLauncher.gd', 'UpgradeScreen.gd',
             'Games/RowDivers/RowDiversPromotion.gd', 'Games/RowDivers/RowDiversHUD.gd',
             'Games/RowDivers/Scenes/RowDiversBattleScene.gd']:
    manifest['sources'][name] = hashlib.sha256((project / name).read_bytes()).hexdigest()
text = json.dumps(manifest, indent=2) + '\n'
(build / 'build_manifest_0.10.json').write_text(text, encoding='utf8')
(project / 'StoreAssets_RailwayFury/steam/build-manifest.json').write_text(text, encoding='utf8')
print('Recorded 0.10 release receipts and fingerprints.')
