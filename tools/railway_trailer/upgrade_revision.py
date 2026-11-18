"""Assemble the 27-second revision with half damage closer combat starts and a held title card from isolated Godot capture markers."""
import json, pathlib, subprocess, re, argparse
import cv2, imageio_ffmpeg
from PIL import Image, ImageDraw
parser=argparse.ArgumentParser()
parser.add_argument('--reuse-clips',action='store_true')
args=parser.parse_args()
ROOT = pathlib.Path(__file__).resolve().parents[2]
BUILD = ROOT / 'Build - RailwayFury/TrailerUpgradeV6'
OUT = ROOT / 'output/railway-fury-trailer-v6'
MUSIC = ROOT / 'FeedingABlackHoldGame/Games/RowDivers/Audio/Illustrated/battle_quest.ogg'
OUT.mkdir(parents=True, exist_ok=True)
FF = imageio_ffmpeg.get_ffmpeg_exe()
def run(args):
    return subprocess.run([FF, '-hide_banner', '-loglevel', 'error', '-y', *args], check=True)
markers = json.loads((BUILD/'markers.json').read_text())
timeline = []
cursor = 0
for m in markers:
    duration = m['frames']/30
    dest = OUT/(m['label']+'.mov')
    cmd = ['-ss', str(m['start_frame']/30), '-i', str(BUILD/'source.avi'), '-t', str(duration)]
    cmd += ['-af',f'afade=t=in:d=0.015,afade=t=out:st={duration-.025}:d=0.025','-c:v','libx264','-preset','fast','-crf','18','-pix_fmt','yuv420p','-c:a','pcm_s24le',str(dest)]
    if not args.reuse_clips: run(cmd)
    timeline.append(dict(m, trailer_start=cursor, trailer_end=cursor+duration, file=dest.name))
    cursor += duration
gameplay_seconds = round(cursor, 3)
total_seconds = round(gameplay_seconds + 2, 3)
transition_start = round(gameplay_seconds - .8, 3)
expected_frames = round(total_seconds * 30)
concat = OUT/'concat.txt'
concat.write_text('\n'.join("file '"+(OUT/t['file']).as_posix()+"'" for t in timeline))
# Crossfade the last 0.8 seconds of combat into existing branded key art.
# A 2.8-second card overlaps by 0.8 seconds, leaving a full 2-second hold.
TITLE = ROOT/'FeedingABlackHoldGame/StoreAssets_RailwayFury/steam/capsules/main.png'
card=OUT/'08-title-card.mov'
run(['-loop','1','-framerate','30','-i',str(TITLE),'-t','2.8','-vf','scale=1920:1080:force_original_aspect_ratio=decrease,pad=1920:1080:(ow-iw)/2:(oh-ih)/2,setsar=1','-c:v','libx264','-preset','fast','-crf','18','-pix_fmt','yuv420p',str(card)])
mix = f'[0:v]settb=AVTB,setpts=PTS-STARTPTS,fps=30[v0];[1:v]settb=AVTB,setpts=PTS-STARTPTS,fps=30[v1];[v0][v1]xfade=transition=fade:duration=0.8:offset={transition_start}[video];[0:a]afade=t=out:st={transition_start}:d=0.8,apad=whole_dur={total_seconds}[sfx];[2:a]atrim=duration={total_seconds},asetpts=PTS-STARTPTS,loudnorm=I=-20:TP=-3:LRA=9,volume=0.6,afade=t=in:st=0:d=0.35[music];[sfx][music]amix=inputs=2:duration=first:normalize=0,afade=t=out:st={total_seconds-.8}:d=0.8,loudnorm=I=-16:TP=-1.5:LRA=11[audio]'
movie=OUT/'Railway-Fury-Gameplay-Trailer.mp4'
run(['-f','concat','-safe','0','-i',str(concat),'-i',str(card),'-i',str(MUSIC),'-filter_complex',mix,'-map','[video]','-map','[audio]','-t',str(total_seconds),'-r','30','-c:v','libx264','-preset','medium','-b:v','12000k','-maxrate','16000k','-bufsize','24000k','-pix_fmt','yuv420p','-c:a','aac','-b:a','192k','-ar','48000','-ac','2','-movflags','+faststart',str(movie)])
timeline.append(dict(label='08-title-card',trailer_start=transition_start,trailer_end=total_seconds,full_card_start=gameplay_seconds,hold_seconds=2,crossfade_seconds=.8,file=card.name))
(OUT/'timeline.json').write_text(json.dumps(timeline,indent=2))
cap=cv2.VideoCapture(str(movie))
assert cap.get(cv2.CAP_PROP_FRAME_COUNT)==expected_frames and cap.get(cv2.CAP_PROP_FPS)==30
assert (cap.get(3),cap.get(4)) == (1920,1080)
sheet=Image.new('RGB',(960,630),(16,22,27))
draw=ImageDraw.Draw(sheet)
for i,t in enumerate(timeline):
    cap.set(cv2.CAP_PROP_POS_MSEC,(t['trailer_start']+min(1.3,(t['trailer_end']-t['trailer_start'])/2))*1000)
    ok,frame=cap.read(); assert ok
    thumb=Image.fromarray(cv2.cvtColor(frame,cv2.COLOR_BGR2RGB)).resize((320,180))
    x,y=i%3*320,i//3*210
    sheet.paste(thumb,(x,y)); draw.text((x+4,y+183),t['label'],fill='white')
for time in [t["trailer_start"] + .5 for t in timeline] + [transition_start+.4,gameplay_seconds+.1,total_seconds-.1]:
    cap.set(cv2.CAP_PROP_POS_MSEC,time*1000); ok,frame=cap.read(); assert ok
    cv2.imwrite(str(OUT/f'review-{time:.1f}.jpg'),frame)
cap.set(cv2.CAP_PROP_POS_FRAMES,expected_frames-1); ok,last=cap.read(); assert ok
cap.set(cv2.CAP_PROP_POS_FRAMES,round(gameplay_seconds*30)); ok,hold_start=cap.read(); assert ok
assert cv2.absdiff(last,hold_start).mean()<1, 'Title must hold unchanged for the final two seconds'
cap.release(); sheet.save(OUT/'contact-sheet.jpg')
assert timeline[3]['arrows_after'] == timeline[3]['arrows_before']+1 == 3
assert timeline[4]['arrows_per_shot']==3
assert [t['level'] for t in timeline if 'level' in t]==[1,2,3,4]
assert all(t.get('battle_numbers_hidden',True) for t in timeline)
assert timeline[6]['arrows_per_shot']==3
assert all(not t.get('ended',False) for t in timeline)
assert all(t.get('visible_start',1)>0 for t in timeline)
assert all(t['longest_out_of_range_seconds'] <= .5 for t in timeline if t.get('level',0) in [2,3])
assert [t['outgoing_damage_scale'] for t in timeline if 'level' in t]==[0.5,0.25,0.25,0.5]
result=subprocess.run([FF,'-hide_banner','-i',str(movie),'-af','volumedetect','-vn','-f','null','-'],capture_output=True,text=True,check=True)
peak=float(re.search(r'max_volume: ([\-0-9.]+) dB',result.stderr)[1]); assert peak < -.5
report=dict(seconds=total_seconds,frames=expected_frames,fps=30,resolution=[1920,1080],peak_dbfs=peak,arrows_before=2,arrows_after=3,same_purchased_loadout_in_following_biome=True,shots=8,outgoing_damage_scale_by_level=[.5,.25,.25,.5],aim_target="visual_midsection",title_card_hold_seconds=2,crossfade_seconds=.8,title_card_hold_frame_difference=float(cv2.absdiff(last,hold_start).mean()))
report['combat']=[{k:t[k] for k in ['level','player_hits','empty_combat_frames','longest_empty_seconds','nearby_start','out_of_range_frames','longest_out_of_range_seconds']} for t in timeline if 'level' in t]
(OUT/'verification.json').write_text(json.dumps(report,indent=2))
lines=['# Railway Fury trailer upgrade revision','',f'{total_seconds:g} seconds, 1920 x 1080, 30 fps. Fresh isolated capture; campaign saves untouched.','', '| Time | Shot |','|---|---|']
for t in timeline: lines.append(f"| {t['trailer_start']:g}-{t['trailer_end']:g}s | {t['label']} |")
lines += ['', 'Each biome appears once, in order: levels 1, 2, 3, 4. Two-second upgrade clicks between them: Arrow Damage I, Arrow Count II, Arrow Storm. Level 3 uses the purchased three-arrow loadout. Combat HUD, damage, health and loot numbers are hidden. Outgoing player hits deal half damage in levels 1/4, quarter damage in levels 2/3, in the capture subclass only. Aim targets the rendered enemy midsection. Levels 2/3 begin seven metres behind an existing live enemy group, with the player centered on that group. Ends with a 0.8-second crossfade into the existing Railway Fury key art and a full 2-second title hold. Existing Enchanted Quest game music and captured effects.', '', 'Reproduce: powershell -File tools/railway_trailer/prepare.ps1 -UpgradeRevision -OutputDirectory "Build - RailwayFury/TrailerUpgradeV6", then python tools/railway_trailer/upgrade_revision.py.']
(OUT/'REVIEW.md').write_text('\n'.join(lines),encoding='utf-8')
print(json.dumps(report,indent=2))
