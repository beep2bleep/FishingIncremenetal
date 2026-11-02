"""Build labeled SFX-only clips and a 36-second review cut from Godot frame markers."""
import json
import pathlib
import subprocess
import imageio_ffmpeg
import cv2
import argparse
from PIL import Image, ImageDraw

ROOT = pathlib.Path(__file__).resolve().parents[2]
BUILD = ROOT / 'Build - RailwayFury/TrailerReview'
parser = argparse.ArgumentParser()
parser.add_argument('--output', default='output/railway-fury-trailer')
args = parser.parse_args()
OUT = ROOT / args.output
OUT.mkdir(parents=True, exist_ok=True)
(OUT / 'clips').mkdir(exist_ok=True)
FFMPEG = imageio_ffmpeg.get_ffmpeg_exe()
markers = json.loads((BUILD / 'markers.json').read_text())
def run(args):
    subprocess.run([FFMPEG, '-hide_banner', '-loglevel', 'error', '-y', *args], check=True)
timeline = []
cursor = 0
for m in markers:
    duration = m['frames'] / 30
    clip = OUT / 'clips' / (m['label'] + '.mp4')
    lossless_audio_clip = BUILD / (m['label'] + '.mov')
    filters = []
    afilters = ['afade=t=in:st=0:d=0.015', f'afade=t=out:st={duration-.025}:d=0.025']
    if m['label'] == '05-distant-boss':
        filters += [f'fade=t=out:st={duration-0.85}:d=0.85']
        afilters += [f'afade=t=out:st={duration-0.85}:d=0.85']
    if m['label'] == '09-level-4-finale':
        filters += [f'fade=t=out:st={duration-0.45}:d=0.45']
        afilters += [f'afade=t=out:st={duration-0.45}:d=0.45']
    cmd = ['-ss', str(m['start_frame']/30), '-i', str(BUILD/'source.avi'), '-t', str(duration)]
    if filters: cmd += ['-vf', ','.join(filters)]
    cmd += ['-af', ','.join(afilters), '-c:v', 'libx264', '-preset', 'fast', '-crf', '18', '-pix_fmt', 'yuv420p', '-c:a', 'pcm_s24le', '-ar', '48000', '-ac', '2', str(lossless_audio_clip)]
    run(cmd)
    run(['-i',str(lossless_audio_clip),'-c:v','copy','-c:a','aac','-b:a','192k','-movflags','+faststart',str(clip)])
    timeline.append({**m, 'trailer_start':cursor, 'trailer_end':cursor+duration, 'file':str(clip.relative_to(OUT))})
    cursor += duration
concat = OUT/'concat.txt'
concat.write_text('\n'.join("file '"+str((BUILD/(t['label']+'.mov')).resolve()).replace('\\','/')+"'" for t in timeline))
run(['-f','concat','-safe','0','-i',str(concat),'-c:v','copy','-c:a','aac','-b:a','192k','-t','36','-movflags','+faststart',str(OUT/'Railway-Fury-Trailer-Review-SFX.mp4')])
run(['-f','concat','-safe','0','-i',str(concat),'-vn','-t','36','-c:a','pcm_s24le',str(OUT/'Railway-Fury-Trailer-SFX.wav')])
(OUT/'timeline.json').write_text(json.dumps(timeline,indent=2))
lines = ['# Railway Fury trailer review', '', '36 seconds · 1920×1080 · 30 fps · game sound effects only.', '', '| Time | Clip |', '|---|---|']
for t in timeline: lines.append(f"| {t['trailer_start']:05.2f}–{t['trailer_end']:05.2f} | {t['label']} |")
lines += ['', 'Music has been muted at the Godot Music bus. Add the chosen game track after review; the WAV is the separate effects stem. Boss and final fades are baked into the labeled clips.', '', 'Capture uses the real simulation with a trailer-only pilot, paid upgrade fixtures, isolated user data, and no campaign result persistence. Raw footage and frame markers are in Build - RailwayFury/TrailerReview. Reproduce with tools/railway_trailer/prepare.ps1, then python tools/railway_trailer/assemble.py.']
if any(t.get('hud_hidden') for t in timeline):
    lines += ['', 'Revision 2: gameplay HUD removed, including vitality, instructions, ability cards, boss bar and currency panels. Enemy health and damage numbers remain in the world. Upgrade purchase shots retain their interface. Steering prioritizes reachable fire gaps and nearby gold/gems; imperfect aim is unchanged. The original review export remains in output/railway-fury-trailer. Rebuild this version with --output output/railway-fury-trailer-v2.']
(OUT/'REVIEW.md').write_text('\n'.join(lines), encoding='utf-8')
sheet = Image.new('RGB',(960, 3*210),(16,22,27))
draw = ImageDraw.Draw(sheet)
for i,t in enumerate(timeline):
    cap = cv2.VideoCapture(str(OUT/t['file']))
    cap.set(cv2.CAP_PROP_POS_MSEC, 1000)
    ok,frame = cap.read()
    cap.release()
    if ok:
        thumb = Image.fromarray(cv2.cvtColor(frame,cv2.COLOR_BGR2RGB)).resize((320,180))
        x,y = i%3*320,i//3*210
        sheet.paste(thumb,(x,y))
        draw.text((x+6,y+184),t['label'], fill='white')
sheet.save(OUT/'contact-sheet.jpg',quality=92)
print(OUT)
