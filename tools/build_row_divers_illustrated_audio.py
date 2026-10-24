"""Build the third presentation's audio from the user's local licensed library."""
from pathlib import Path
import hashlib, json, subprocess
import imageio_ffmpeg
import numpy as np
import soundfile as sf

ROOT = Path(__file__).resolve().parents[1]
DEST = ROOT/'FeedingABlackHoldGame/Games/RowDivers/Audio/Illustrated'
MUSIC = Path(r'C:\Game Assets\Music')
SFX = Path(r'C:\Game Assets\Sound Effects')
FFMPEG = imageio_ffmpeg.get_ffmpeg_exe()

def run():
    DEST.mkdir(parents=True,exist_ok=True)
    music_files=list(MUSIC.rglob('*.wav')); effect_files=list(SFX.rglob('*.wav'))
    def find(files, fragment):
        matches=[p for p in files if fragment.lower() in str(p).lower()]
        assert len(matches)==1,(fragment,len(matches))
        return matches[0]
    music_specs={
        'battle_quest': ('Serpents Requiem - Enchanted Quest.wav','Melodic fantasy adventure; first combat selection'),
        'battle_wyverns': ('Serpents Requiem - Wizards and Wyverns.wav','Fantasy adventure variation for combat'),
        'battle_heraldry': ('Heraldry - Medieval Combat Music Collection/3 -','Rhythmic medieval combat selection'),
        'menu': ('Taverns - Medieval Inn Music Collection/2 -','Acoustic medieval menu contrast'),
        'god': ('Twilight Pilgrims - Silent Horizon.wav','Quieter final-chamber selection'),
        'credits': ('Serpents Requiem - Lost Chronicle.wav','Melodic fantasy closing track'),
    }
    # Each source is independent of the previous replacement and original sets.
    effect_specs={
        'shot': ('Cartoon Arrow 09.wav',0.45,0.0),
        'hit': ('WOODEN SWORD HIT-11.M.wav',0.38,0.0),
        'dagger': ('Sword Ring Scrape Gleam 02.wav',0.45,0.0),
        'step': ('FS Concrete Soldier Crouch N02.wav',0.18,0.0),
        'coin': ('Money,Coins,Drop In Cash Register.wav',0.38,0.0),
        'ability': ('MAGIC AIR Large Whoosh, Swirl, Wind Gust, Foliage 01.wav',0.4,0.0),
        'purchase': ('StartSelect,UI,set1,strings,ethnic,tonal,plucked,aura,hold_release.wav',0.35,0.0),
        'click': ('StartSelect,UI,set34,mechanical,subtle,percussive,thick,bright,holdrelease.wav',0.28,0.0),
        'hover': ('StartSelect,UI,set3,pure,warm,simple,quick,tonal,deaction.wav',0.18,0.0),
        'damage': ('Melee_Sword_Attack_04.wav',0.32,0.0),
        'death': ('stone29.wav',0.38,0.0),
        'boss_death': ('Monster 31.wav',0.48,0.0),
        'mini_death': ('Monster 20.wav',0.42,0.0),
        'gate': ('Dungeon Door Open, Close, Locked.wav',0.4,0.0),
        'boss_hello': ('TheLibrarybyMTC_GrowlMonster_Effort_92_96k.wav',0.35,0.0),
        'horn': ('TheLibrarybyMTC_GrowlMonster_Roar_26_96k.wav',0.38,0.0),
        'win': ('Success 2a.wav',0.55,0.0),
        'lose': ('StartSelect,UI,set100,lady,vocalizations,crunchy,multipitched,multitimbral,back.wav',0.4,0.0),
        'lose_voice': ('EFX SD Monster Voices 11 A.wav',0.25,0.0),
        'beam': ('MAGIC GENERIC Texture, Shimmer, Processed Glass, Reversed Layer, Disturbing, High.wav',0.25,0.0),
    }
    manifest={'music':{},'effects':{},'music_pools':{'battle':['battle_quest','battle_wyverns','battle_heraldry'],'menu':['menu'],'god':['god'],'credits':['credits']}}
    old=json.loads((DEST.parent/'sources.json').read_text())
    prior_sources={str(v.get('source','')).replace('\\\\','\\').lower() for v in old.values()}
    def execute(args): subprocess.run([FFMPEG,'-hide_banner','-loglevel','error','-y']+args,check=True)
    for cue,(fragment,reason) in music_specs.items():
        source=find(music_files,fragment.replace('/',str(Path('/'))))
        output=DEST/(cue+'.ogg')
        execute(['-i',str(source),'-af','loudnorm=I=-20:TP=-2:LRA=9','-ar','44100','-ac','2','-c:a','libvorbis','-q:a','5',str(output)])
        info=sf.info(output)
        manifest['music'][cue]={'file':output.name,'source':str(source),'sha256':hashlib.sha256(source.read_bytes()).hexdigest(),'duration':info.duration,'volume':0.65,'reason':reason,'processing':'Full track; -20 LUFS normalization, -2 dBTP limit, stereo Vorbis q5'}
    for cue,(fragment,volume,offset) in effect_specs.items():
        source=find(effect_files,fragment)
        assert str(source).lower() not in prior_sources,('Source already used by the prior replacement set',source)
        samples,rate=sf.read(source,dtype='float32',always_2d=True)
        energy=np.max(np.abs(samples),axis=1)
        peak=float(energy.max())
        onset=int(np.argmax(energy>max(peak*0.08,0.0002)))
        start=max(0,onset/rate-0.012)+offset
        duration=min(0.65 if cue in ['step','hit','hover','click','shot'] else 1.8 if cue not in ['win','lose','boss_death','gate'] else 3.0,len(samples)/rate-start)
        output=DEST/(cue+'.wav')
        gain=0.8/max(peak,0.001)
        fade=max(0,duration-0.065)
        execute(['-ss',str(start),'-i',str(source),'-t',str(duration),'-af',f'volume={gain},afade=t=in:d=0.004,afade=t=out:st={fade}:d=0.065','-ar','44100','-ac','1','-c:a','pcm_s16le',str(output)])
        manifest['effects'][cue]={'file':output.name,'source':str(source),'sha256':hashlib.sha256(source.read_bytes()).hexdigest(),'volume':volume,'pitch':1.0,'duration':sf.info(output).duration,'trim_start':start,'processing':'First audible gesture, peak-normalized to 0.8, short fade in/out, mono PCM16 44.1kHz'}
    (DEST/'sources.json').write_text(json.dumps(manifest,indent=2),encoding='utf-8')
    print(f'Built {len(manifest["music"])} music tracks and {len(manifest["effects"])} effect cues in {DEST}')

if __name__=='__main__': run()
