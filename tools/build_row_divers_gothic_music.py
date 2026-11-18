"""Prepare Gothic Gore music from the user's local music library."""
from pathlib import Path
import hashlib
import json
import subprocess
import imageio_ffmpeg
import soundfile as sf

ROOT = Path(__file__).resolve().parents[1]
DEST = ROOT / 'FeedingABlackHoldGame/Games/RowDivers/Audio/Gothic'
LIBRARY = Path(r'C:\Game Assets\Music')
SPECS = {
    'upgrade_sanctum': ('darkarts_rpgmusiccollection', 'Sanctum Obscura', 'upgrade'),
    'upgrade_grimoire': ('darkarts_rpgmusiccollection', 'Forbidden Grimoire', 'upgrade'),
    'upgrade_covenant': ('darkarts_rpgmusiccollection', 'Dusk Covenant', 'upgrade'),
    'combat_slayer': ('hellfirereigns_actionmusiccollection', 'Abyssal Slayer', 'combat'),
    'combat_carnage': ('hellfirereigns_actionmusiccollection', 'Carnage Requiem', 'combat'),
    'combat_crucible': ('hellfirereigns_actionmusiccollection', 'Blood Crucible', 'combat'),
}

def run():
    DEST.mkdir(parents=True, exist_ok=True)
    manifest = {'artist': 'Phat Phrog Studio', 'music': {}, 'upgrade': [], 'combat': []}
    for key, (collection, title, context) in SPECS.items():
        matches = list((LIBRARY / collection).glob('* - ' + title + '.wav'))
        assert len(matches) == 1, (key, matches)
        source = matches[0]
        output = DEST / (key + '.ogg')
        subprocess.run([imageio_ffmpeg.get_ffmpeg_exe(), '-hide_banner', '-loglevel', 'error', '-y',
                        '-i', str(source), '-af', 'loudnorm=I=-20:TP=-2:LRA=9',
                        '-ar', '44100', '-ac', '2', '-c:a', 'libvorbis', '-q:a', '5', str(output)], check=True)
        manifest['music'][key] = {
            'title': title, 'collection': collection, 'file': output.name,
            'source': str(source), 'source_sha256': hashlib.sha256(source.read_bytes()).hexdigest(),
            'output_sha256': hashlib.sha256(output.read_bytes()).hexdigest(),
            'duration': sf.info(output).duration, 'volume': 0.65,
            'processing': 'Full track; -20 LUFS normalization, -2 dBTP limit, stereo Vorbis q5',
        }
        manifest[context].append(key)
        print(f'{context}: {title} ({manifest["music"][key]["duration"]:.1f}s)', flush=True)
    (DEST / 'sources.json').write_text(json.dumps(manifest, indent=2) + '\n', encoding='utf-8')
    from loop_row_divers_upgrade_music import prepare
    prepare('Gothic')

if __name__ == '__main__':
    run()
