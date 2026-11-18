"""Record the verified 0.7 Steam default-branch release."""
import hashlib
import json
from pathlib import Path

root = Path(__file__).resolve().parents[2]
project = root / 'FeedingABlackHoldGame'
manifest_path = project / 'StoreAssets_RailwayFury/steam/build-manifest.json'
manifest = json.loads(manifest_path.read_text(encoding='utf8'))
assert manifest['version'] == '0.7'
manifest['qa'] = {
    'full_pack_checks': 15, 'demo_pack_checks': 15,
    'source_release_ux_checks': 54, 'full_qa_release_ux_checks': 54,
    'demo_qa_release_ux_checks': 31, 'packed_localization_checks': 20341,
    'source_focused_controller_checks': 37,
    'physical_controller_verified': False,
}
manifest['steam_upload'].update({
    'set_live': True, 'full_branch': 'default', 'demo_branch': 'default',
    'previous_full_build_id': 26332676, 'previous_demo_build_id': 26332680,
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
release = {'version': '0.7', 'uploaded': {'steam': True, 'itch': False},
           'steam_upload': manifest['steam_upload'], 'files': files,
           'itch_note': 'Public itch packages remain at version 0.6; this request updates Steam.'}
(root / 'Build - RailwayFury/build_manifest_0.7.json').write_text(json.dumps(release, indent=2) + '\n', encoding='utf8')
