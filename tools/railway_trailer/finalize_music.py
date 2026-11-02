"""30-second release cut: approved footage, one late-level pair, game combat music."""
import json
import pathlib
import re
import subprocess
import wave
import cv2
import imageio_ffmpeg

ROOT = pathlib.Path(__file__).resolve().parents[2]
BUILD = ROOT / 'Build - RailwayFury/TrailerReview'
OUT = ROOT / 'output/railway-fury-trailer-v3'
OUT.mkdir(parents=True, exist_ok=True)
FFMPEG = imageio_ffmpeg.get_ffmpeg_exe()
MUSIC = ROOT / 'FeedingABlackHoldGame/Games/RowDivers/Audio/Illustrated/battle_quest.ogg'
def run(args):
    subprocess.run([FFMPEG,'-hide_banner','-loglevel','error','-y',*args],check=True)

timeline = json.loads((ROOT/'output/railway-fury-trailer-v2/timeline.json').read_text())[:7]
finale = OUT/'07-level-4-finale.mov'
run(['-i',str(BUILD/'07-level-4-maxed.mov'),'-vf','fade=t=out:st=2.2:d=0.8',
     '-c:v','libx264','-preset','fast','-crf','18','-pix_fmt','yuv420p','-c:a','copy',str(finale)])
sources = [BUILD/(t['label']+'.mov') for t in timeline[:6]]+[finale]
concat = OUT/'concat.txt'
concat.write_text('\n'.join("file '"+str(p).replace('\\','/')+"'" for p in sources))
mix = '[1:a]atrim=duration=30,asetpts=PTS-STARTPTS,loudnorm=I=-20:TP=-3:LRA=9,volume=0.6,afade=t=in:st=0:d=0.35[music];[0:a][music]amix=inputs=2:duration=first:normalize=0,afade=t=out:st=29.2:d=0.8,loudnorm=I=-16:TP=-1.5:LRA=11[audio]'
movie = OUT/'Railway-Fury-Gameplay-Trailer.mp4'
run(['-f','concat','-safe','0','-i',str(concat),'-i',str(MUSIC),'-filter_complex',mix,
     '-map','0:v','-map','[audio]','-t','30','-c:v','libx264','-preset','medium',
     '-b:v','12000k','-maxrate','16000k','-bufsize','24000k','-pix_fmt','yuv420p',
     '-c:a','aac','-b:a','192k','-ar','48000','-ac','2','-movflags','+faststart',str(movie)])
run(['-i',str(movie),'-vn','-c:a','pcm_s24le',str(OUT/'Railway-Fury-Trailer-Mix.wav')])
timeline[-1]['final_fade_seconds']=0.8
(OUT/'timeline.json').write_text(json.dumps(timeline,indent=2))
cap=cv2.VideoCapture(str(movie))
assert cap.get(cv2.CAP_PROP_FRAME_COUNT)==900
assert cap.get(cv2.CAP_PROP_FPS)==30
assert (cap.get(3),cap.get(4))==(1920,1080)
cap.set(cv2.CAP_PROP_POS_FRAMES,899)
ok,last=cap.read()
assert ok and last.mean()<4, 'Final frame should fade to black'
cap.release()
result=subprocess.run([FFMPEG,'-hide_banner','-i',str(movie),'-af','volumedetect','-vn','-f','null','-'],capture_output=True,text=True,check=True)
peak=float(re.search(r'max_volume: ([\-0-9.]+) dB',result.stderr)[1])
assert peak < -0.5
report={'seconds':30,'frames':900,'fps':30,'resolution':[1920,1080],
        'music':str(MUSIC.relative_to(ROOT)),'music_title':'Enchanted Quest — Phat Phrog Studio',
        'music_source':'Existing in-game combat pool','peak_dbfs':peak,'shots':7,
        'late_levels':[3,4],'final_fade_seconds':0.8,'last_frame_mean':float(last.mean())}
(OUT/'verification.json').write_text(json.dumps(report,indent=2))
(OUT/'REVIEW.md').write_text('# Railway Fury trailer — music revision\n\n30 seconds, 1080p, 30 fps.\n\n0–8: opening combat\n8–11: upgrades\n11–17: later level 1\n17–19: upgrades\n19–24: distant boss and existing fade\n24–27: level 3\n27–30: level 4 and final fade\n\nMusic: Enchanted Quest from the existing game combat pool, mixed with the captured sound effects. The repeated final pair of level 3/4 shots has been removed.\n',encoding='utf-8')
print(json.dumps(report,indent=2))
