"""Reproducible, original vector artwork for Railway Fury's optional Gothic Gore style."""
from pathlib import Path
import json, random

ROOT = Path(__file__).resolve().parents[1] / 'FeedingABlackHoldGame/Games/RowDivers/Art/Gothic'
ROOT.mkdir(parents=True, exist_ok=True)
random.seed(666)
def svg(name, body, size=256):
    (ROOT / (name+'.svg')).write_text(f'<svg xmlns="http://www.w3.org/2000/svg" width="{size}" height="{size}" viewBox="0 0 256 256">{body}</svg>', encoding='utf-8')

SKULL = '<path fill="#c6bda5" stroke="#100d10" stroke-width="6" d="M82 146V111C67 49 185 49 174 111v35l-18 9v28H99v-28z"/><path fill="#100d10" d="m91 106 31 8-8 23-24-8zm43 8 31-8 1 23-24 8zm-6 19-10 16h20z"/><path stroke="#100d10" stroke-width="5" d="M112 160v22m15-22v22m15-22v22"/>'
BONES = '<g fill="none" stroke="#b4ad99" stroke-width="13"><path d="m57 61 142 139M57 200 199 59"/></g><g fill="#b4ad99">'+''.join(f'<circle cx="{x}" cy="{y}" r="13"/>' for x,y in [(52,52),(66,52),(195,202),(209,202),(50,203),(66,203),(195,52),(209,52)])+'</g>'
RADIATION = '<g fill="#b1a572"><circle cx="128" cy="128" r="16"/>'+''.join(f'<path transform="rotate({r} 128 128)" d="M103 103 73 51a89 89 0 0 1 110 0l-30 52a36 36 0 0 0-50 0z"/>' for r in [0,120,240])+'</g>'
BONES += '<path fill="none" stroke="#171519" stroke-width="9" d="m91 107 15-8-4 19 16-9m27 27 13 5-20 10 14 8"/>'
POISON = '<path fill="#697e55" stroke="#10120e" stroke-width="6" d="M105 32h46v29l30 45v99H75v-99l30-45z"/><path fill="#151d14" d="M84 117h88v78H84z"/><g transform="translate(47 69) scale(.63)">'+SKULL+'</g>'
HEART = '<path fill="#8e152c" stroke="#160b10" stroke-width="8" d="M128 218C17 148 28 63 89 71l29 20 18-34 43-13 19 31-24 25c71 41-5 88-46 118z"/><path fill="none" stroke="#d45b64" stroke-width="5" d="m125 100-18 40 32 21-14 36M97 78l-8-38m52 27 10-39"/>'
symbols={'skull':SKULL,'bones':BONES,'radiation':RADIATION,'poison':POISON,'heart':HEART,'occult':'<g stroke="#a84256" stroke-width="7" fill="none"><circle cx="128" cy="128" r="91"/><path d="m128 33 55 172L38 98h180L73 205z"/></g>'}
for name, body in symbols.items():
    svg('icon_'+name, '<path fill="#171519" stroke="#63404a" stroke-width="5" d="m17 6 222 0 11 11v222l-11 11H17L6 239V17z"/>'+body+'<path stroke="#601627" stroke-width="4" d="M16 224h61m103-208h48"/>')
svg('symbols', ''.join(f'<g transform="translate({i%2*128} {i//2*128}) scale(.5)" opacity=".7">{symbols[n]}</g>' for i,n in enumerate(['skull','radiation','bones','poison'])))
def blood(seed, count=38):
    r=random.Random(seed)
    return ''.join(f'<rect x="{r.randrange(45,206)}" y="{r.randrange(95,238)}" width="{r.randrange(2,10)}" height="{r.randrange(3,20)}" fill="{r.choice(["#741326","#a21f37","#430e1b"])}"/>' for _ in range(count))
for i in range(7):
    # Distinct silhouettes: flayed revenant, executioner, ruptured corpse,
    # thorn witch, plague bishop, mourning nun, antlered ossuary king.
    silhouettes=[
      '<path fill="#493137" d="m94 105-34 22-29 71 22 10 34-49-10 68h38l14-51 12 51h39l-12-68 35 47 21-18-38-68-28-15z"/>',
      '<path fill="#27262b" stroke="#70656a" stroke-width="5" d="m83 99-43 26-17 80 42 9 20-51-9 65h108l-12-65 18 51 43-12-20-78-41-25z"/><path fill="#5b111f" d="m197 88 36-30 13 64-45-8z"/>',
      '<path fill="#65434a" d="m88 102-39 28-20 77 39 9 16-37-3 57h102l-8-61 24 39 30-13-25-75-37-23z"/><path fill="#1c1016" d="m98 145 47-21 29 51-45 39-35-25z"/><path fill="none" stroke="#9b283d" stroke-width="10" d="M119 150q62 24 13 40t24 32"/>',
      '<path fill="#22242b" stroke="#57535e" stroke-width="4" d="m127 24-48 78-46 134 91-16 94 16-45-133z"/><path stroke="#7f213b" stroke-width="7" d="m52 202 33-96m-18 43-18-20m27-7 19-15"/>',
      '<path fill="#29272a" stroke="#777060" stroke-width="5" d="m128 13-37 63-26 61-23 100 86-21 88 21-26-103-27-60z"/><path fill="#a2a18e" d="m101 83 31-19 37 21-38 61-30-18z"/><path fill="#16191a" d="m127 94 62 23-64 13z"/>',
      '<path fill="#1c1b23" stroke="#57505c" stroke-width="6" d="M128 28 77 69 69 116 32 236l95-18 97 18-38-121-8-47z"/><path fill="#75172c" d="m128 147-20 50h38z"/>',
      '<path fill="#252129" stroke="#786272" stroke-width="5" d="m86 96-43 27-26 47 47 18-13 50h158l-16-54 48-17-27-43-42-28z"/><path fill="none" stroke="#c2b49c" stroke-width="10" d="m99 76-30-29-8-36m9 40-33-19m119 44 31-29 9-36m-10 39 33-20"/>',
    ][i]
    head=('<g transform="translate(0 -21) scale(1 1)">'+SKULL+'</g>') if i not in [4] else ''
    trim='<path fill="none" stroke="#95897d" stroke-width="5" d="m94 151 33 10 34-10m-64 15 30 10 31-10m-53 17 22 7 23-7"/>' if i in [0,1,6] else ''
    svg('enemy_'+str(i), silhouettes+head+trim+blood(i,24)+('<path fill="#a31e38" d="m94 87 24 3-8 10-15-2m41-8 23-4-1 12-15 3z"/>' if i!=4 else ''))
svg('bat','<path fill="#2f202c" stroke="#8c344a" stroke-width="5" d="m128 104-19-32-7 42L10 42l24 133 36-29 28 44 30-35 31 35 27-44 36 29 24-133-91 72-8-42z"/><g transform="translate(63 54) scale(.5)">'+SKULL+'</g>')
bow='<path fill="none" stroke="#110e13" stroke-width="23" d="M40 30q173 98 0 196"/><path fill="none" stroke="#ada28c" stroke-width="13" d="M40 30q173 98 0 196"/><path fill="none" stroke="#9c263c" stroke-width="9" d="m63 46 23 29m19 21 17 28m-7 37-23 22m-12 9-20 13"/><path fill="none" stroke="#a89694" stroke-width="2" d="m40 30 30 98-30 98"/><g transform="translate(99 94) scale(.26)">'+SKULL+'</g><path fill="#32262d" d="m117 10 9 87h-20zM117 246l9-87h-20z"/>'
svg('bow',bow)
svg('dagger','<path fill="#c9c1ac" stroke="#171218" stroke-width="6" d="m128 12-30 117 30 31 30-31z"/><path fill="#84172b" d="m128 12-9 115 12 17 17-29z"/><path stroke="#65535c" stroke-width="14" d="M75 157h106m-53 0v72"/><g transform="translate(94 177) scale(.26)">'+SKULL+'</g>')
for name,color in [('arrow','#c3b59d'),('fire_arrow','#d24a37'),('curse_arrow','#9d557e'),('enemy_bolt','#a41e3e')]:
    svg(name,f'<path stroke="#695557" stroke-width="9" d="M128 49v183"/><path fill="{color}" stroke="#170e16" stroke-width="5" d="m128 8-29 66 29-13 29 13zM128 180l-24 24v32l24-15 24 15v-32z"/><path fill="#8e1c32" d="m121 69 9 52 8-55z"/>')
for name in ['wall','floor']:
    body='<rect width="256" height="256" fill="#29262b"/>'
    for row in range(8):
        for col in range(4):
            x=col*80-(40 if row%2 else 0)
            body+=f'<path fill="{random.choice(["#302d32","#353137","#242227"])}" stroke="#151418" stroke-width="4" d="M{x} {row*32}h78v30h-78z"/>'
    body+='<path fill="#4b1020" opacity=".85" d="M0 38h256v5l-37 7-7 37-12-34-48-5-9 74-12-74-44 4-13 108-10-111-33-3-8 36L8 47H0z"/>' if name=='wall' else '<path fill="#64142b" d="m54 108 36-34 48 12 54 55-22 29-49 8-59-30z"/>'
    svg(name,body+blood(91,50))
for name,sym in [('decor','skull'),('coin','skull'),('gem','occult'),('crown','bones'),('status','heart')]: svg(name,symbols[sym])
manifest={}
source=json.loads((ROOT.parent/'Illustrated/manifest.json').read_text())['textures']
for original,file in source.items():
    stem=Path(file).stem
    if stem.startswith('enemy_'): dest=stem
    elif 'wall' in stem: dest='wall'
    elif 'floor' in stem or stem in ['lava','acid']: dest='floor'
    elif stem in ['bow','dagger','arrow','fire_arrow','curse_arrow','enemy_bolt','coin','gem','crown']: dest=stem
    elif 'status' in stem: dest='status'
    elif 'ability' in stem or stem=='third_eye': dest='icon_occult'
    elif stem=='shadow': continue
    else: dest='decor'
    manifest[original]=dest+'.svg'
# Retain the approved painted enemy replacements when rebuilding vector UI/scenery.
painted = ROOT / 'painted-enemies.json'
if painted.exists(): manifest.update(json.loads(painted.read_text())['textures'])
(ROOT/'manifest.json').write_text(json.dumps({'name':'Gothic Gore','textures':manifest},indent=2)+'\n')
print(f'Created {len(list(ROOT.glob("*.svg")))} Gothic vector assets; {len(manifest)} mapped textures.')
