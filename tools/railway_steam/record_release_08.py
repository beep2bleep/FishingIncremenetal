"""Record the verified 0.8 Steam default-branch release."""
import hashlib
import json
from pathlib import Path

root = Path(__file__).resolve().parents[2]
project = root / 'FeedingABlackHoldGame'
manifest_path = project / 'StoreAssets_RailwayFury/steam/build-manifest.json'
manifest = json.loads(manifest_path.read_text(encoding='utf8'))
assert manifest['version'] == '0.8'
manifest['qa'] = {
    'full_pack_checks': 15, 'demo_pack_checks': 15,
    'source_shared_progress_checks': 39, 'full_qa_shared_progress_checks': 39,
    'demo_qa_shared_progress_checks': 57, 'packed_achievement_checks': 11,
    'full_qa_release_ux_checks': 54, 'demo_qa_release_ux_checks': 31,
    'physical_controller_verified': False, 'cross_device_cloud_verified': False,
}
manifest['cloud'] = {'demo_shared_app_id': 5520300, 'published': True,
                     'limitation': 'Steam does not sync shared Cloud against an unreleased base app.'}
manifest['steam_upload'].update({
    'set_live': True, 'full_branch': 'default', 'demo_branch': 'default',
    'previous_full_build_id': 26757742, 'previous_demo_build_id': 26757748,
    'verification': 'Steamworks default branch tables and Set live history verified November 18, 2026.',
})
for relative in ['Tech Tree Stuff/TechTree.gd', 'Games/RowDivers/Translations/catalog.json']:
    manifest['runtime_sources'][relative] = hashlib.sha256((project / relative).read_bytes()).hexdigest()
manifest_path.write_text(json.dumps(manifest, indent=2) + '\n', encoding='utf8')
files = {}
for edition, binary_names in [('Full', ['RailwayFury.exe', 'RailwayFury.pck']),
                              ('Demo', ['RailwayFuryDemo.exe', 'RailwayFuryDemo.pck'])]:
    for name in binary_names:
        relative = f'Steam/{edition}/{name}'
        path = root / 'Build - RailwayFury' / relative
        files[relative] = {'bytes': path.stat().st_size, 'sha256': hashlib.sha256(path.read_bytes()).hexdigest()}
release = {'version': '0.8', 'uploaded': {'steam': True, 'itch': False},
           'steam_upload': manifest['steam_upload'], 'files': files,
           'itch_note': 'Public itch packages remain at version 0.6; this request updates Steam.'}
(root / 'Build - RailwayFury/build_manifest_0.8.json').write_text(json.dumps(release, indent=2) + '\n', encoding='utf8')
