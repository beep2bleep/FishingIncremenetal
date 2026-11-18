"""Remove baked-in intro/outro fades and join upgrade music at sustained gain.

Run after either audio generator. The manifest hash makes this idempotent.
The licensed source files remain untouched.
"""
from pathlib import Path
import hashlib
import json
import subprocess
import tempfile

import imageio_ffmpeg
import numpy as np
import soundfile as sf

ROOT = Path(__file__).resolve().parents[1] / 'FeedingABlackHoldGame/Games/RowDivers/Audio'
# Sustained musical sections, before each source's authored fade-out.
REGIONS = {'Illustrated': {'menu': (8, 112)},
           'Gothic': {'upgrade_sanctum': (8, 116),
                      'upgrade_grimoire': (8, 120),
                      'upgrade_covenant': (8, 108)}}


def prepare(folder):
    manifest_path = ROOT / folder / 'sources.json'
    manifest = json.loads(manifest_path.read_text(encoding='utf-8'))
    for cue, (start, end) in REGIONS[folder].items():
        entry = manifest['music'][cue]
        target = manifest_path.parent / entry['file']
        digest = hashlib.sha256(target.read_bytes()).hexdigest()
        if entry.get('sustained_loop', {}).get('sha256') == digest:
            continue
        samples, rate = sf.read(target, dtype='float32', always_2d=True)
        section = samples[start * rate:end * rate].copy()
        overlap = 2 * rate
        phase = np.linspace(0, np.pi / 2, overlap, endpoint=True)[:, None]
        # Equal-power overlap retains energy while hiding the loop seam.
        section[-overlap:] = section[-overlap:] * np.cos(phase) + section[:overlap] * np.sin(phase)
        loop = section[overlap:]
        peak = float(np.max(np.abs(loop)))
        if peak > 0.89:
            loop *= 0.89 / peak
        with tempfile.TemporaryDirectory(prefix='railway-music-') as temporary:
            wav = Path(temporary) / 'loop.wav'
            sf.write(wav, loop, rate, subtype='PCM_24')
            subprocess.run([imageio_ffmpeg.get_ffmpeg_exe(), '-hide_banner', '-loglevel', 'error',
                            '-y', '-i', str(wav), '-c:a', 'libvorbis', '-q:a', '5', str(target)], check=True)
        entry['duration'] = sf.info(target).duration
        entry['output_sha256'] = hashlib.sha256(target.read_bytes()).hexdigest()
        entry['sustained_loop'] = {'source_region_seconds': [start, end], 'crossfade_seconds': 2,
                                   'sha256': entry['output_sha256']}
        entry['processing'] = 'Sustained section, no authored fade-out; 2-second equal-power loop join; stereo Vorbis q5'
        print(f'{folder}/{cue}: {entry["duration"]:.1f}s continuous loop')
    manifest_path.write_text(json.dumps(manifest, indent=2) + '\n', encoding='utf-8')


if __name__ == '__main__':
    for name in REGIONS:
        prepare(name)
