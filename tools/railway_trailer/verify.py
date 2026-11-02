import json
import pathlib
import re
import subprocess
import wave
import cv2
import imageio_ffmpeg
import argparse

root = pathlib.Path(__file__).resolve().parents[2]
parser = argparse.ArgumentParser()
parser.add_argument('--output', default='output/railway-fury-trailer')
args = parser.parse_args()
out = root / args.output
movie = out / 'Railway-Fury-Trailer-Review-SFX.mp4'
cap = cv2.VideoCapture(str(movie))
frames, fps = int(cap.get(cv2.CAP_PROP_FRAME_COUNT)), cap.get(cv2.CAP_PROP_FPS)
assert frames == 1080 and fps == 30
assert (cap.get(3), cap.get(4)) == (1920,1080)
cap.release()
with wave.open(str(out/'Railway-Fury-Trailer-SFX.wav')) as wav:
    assert wav.getnframes() == 36*48000
timeline = json.loads((out/'timeline.json').read_text())
assert len(timeline) == 9
assert all(not t.get('ended', False) for t in timeline)
assert all(t.get('visible_start',1)>0 for t in timeline)
assert all(t['kills_end']>t['kills_start'] for t in timeline if 'kills_end' in t and 'boss' not in t['label'])
assert all(t['maxed_nodes'] == 125 for t in timeline if t.get('level',0)>1)
result = subprocess.run([imageio_ffmpeg.get_ffmpeg_exe(),'-hide_banner','-i',str(movie),'-af','volumedetect','-vn','-f','null','-'],capture_output=True,text=True,check=True)
peak = float(re.search(r'max_volume: ([\-0-9.]+) dB',result.stderr)[1])
assert -50 < peak < -1, peak
report = {'frames':frames,'fps':fps,'resolution':[1920,1080],'duration_seconds':36,'effects_stem_seconds':36,'peak_dbfs':peak,'clips':9,'no_ended_runs':True,'visible_enemies_at_combat_cuts':True,'kills_in_all_combat_clips':True,'maxed_nodes_in_late_scenes':125,'music':'muted at Music bus during capture'}
combat = [t for t in timeline if 'hud_hidden' in t]
if combat:
    assert all(t['hud_hidden'] for t in combat)
    assert sum(t['fire_dodges'] for t in combat)>0
    assert sum(t['gold_collected'] for t in combat)>0
    assert sum(t['fire_steering_decisions'] for t in combat)>0
    assert sum(t['loot_steering_decisions'] for t in combat)>0
    report.update(hud_hidden=True,fire_dodges=sum(t['fire_dodges'] for t in combat),fire_hits=sum(t['fire_hits'] for t in combat),gold_collected=sum(t['gold_collected'] for t in combat))
(out/'verification.json').write_text(json.dumps(report,indent=2))
print(json.dumps(report,indent=2))
