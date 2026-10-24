"""Import original corridor geometry/materials and audio, retaining source fingerprints."""
from pathlib import Path
import hashlib, json, re, shutil, struct
from import_row_divers import documents, ROOT

SOURCE = Path(r'C:\Decompiled\Row Divers\ExportedProject\Assets')
DEST = ROOT / 'FeedingABlackHoldGame/Games/RowDivers/Art/Original'
AUDIO = DEST / 'Audio'

def run():
    lookup = {}
    for meta in SOURCE.rglob('*.meta'):
        match = re.search(r'^guid: (\w+)', meta.read_text(encoding='utf-8-sig'), re.M)
        if match: lookup[match[1]] = meta.with_suffix('')
    fingerprints = {}
    def read(path):
        fingerprints[str(path.relative_to(SOURCE))] = hashlib.sha256(path.read_bytes()).hexdigest()
        return documents(path)
    materials, meshes = {}, {}
    def material(ref):
        guid = ref.get('guid', '')
        if guid in materials: return guid
        path = lookup.get(guid)
        if not path: return ''
        m = next(iter(read(path).values()))[1]
        props = m['m_SavedProperties']
        tex = props['m_TexEnvs'].get('_BaseMap', props['m_TexEnvs'].get('_MainTex', {}))
        texture = lookup.get(tex.get('m_Texture', {}).get('guid'))
        if texture:
            shutil.copyfile(texture, DEST / texture.name)
            fingerprints[str(texture.relative_to(SOURCE))] = hashlib.sha256(texture.read_bytes()).hexdigest()
        color = props.get('m_Colors', {}).get('_BaseColor', props.get('m_Colors', {}).get('_Color', dict(r=1,g=1,b=1,a=1)))
        materials[guid] = dict(name=m['m_Name'], texture=texture.name if texture else '', color=list(color.values()),
                               uv_scale=list(tex.get('m_Scale', dict(x=1,y=1)).values()),
                               uv_offset=list(tex.get('m_Offset', dict(x=0,y=0)).values()),
                               transparent=props.get('m_Floats', {}).get('_Surface', 0) == 1,
                               unshaded='Unlit' in lookup.get(m['m_Shader'].get('guid'), Path('')).stem)
        return guid
    def mesh(ref, renderer):
        guid = ref.get('guid','')
        if guid.startswith('0000'): return dict(primitive=ref['fileID'])
        sub = renderer.get('m_StaticBatchInfo', {}).get('firstSubMesh', 0)
        key = f'{guid}:{sub}'
        if key not in meshes:
            m = next(iter(read(lookup[guid]).values()))[1]
            vd = m['m_VertexData']; channels = vd['m_Channels']
            assert all(c['format'] == 0 and c['stream'] == 0 for c in channels if c['dimension'])
            stride = max(c['offset'] + c['dimension'] * 4 for c in channels if c['dimension'])
            raw = bytes.fromhex(vd['_typelessdata'])
            sm = m['m_SubMeshes'][sub]
            size = 4 if m['m_IndexFormat'] else 2
            indices = struct.unpack_from('<' + ('I' if size == 4 else 'H') * sm['indexCount'], bytes.fromhex(m['m_IndexBuffer']), sm['firstByte'])
            unique = sorted(set(i + sm['baseVertex'] for i in indices)); mapping = {v:i for i,v in enumerate(unique)}
            def channel(index):
                c = channels[index]
                return [list(struct.unpack_from('<'+'f'*c['dimension'], raw, i*stride+c['offset'])) for i in unique]
            meshes[key] = dict(vertices=channel(0), normals=channel(1), uv=channel(4), indices=[mapping[i+sm['baseVertex']] for i in indices])
        return dict(mesh=key, baked=True)
    game = read(SOURCE/'Scenes/GameScene.unity')
    layouts = {}
    paths = [('Initial', None, 'Initial Section')] + [(p.stem,p,None) for p in (SOURCE/'GameObject').glob('*.prefab') if re.fullmatch(r'Section [1-6]|MiniBoss[12] Section|Boss Section|Crownless Boss Section',p.stem)]
    paths += [(f'Actor_{i}', SOURCE/'GameObject'/f'{n}.prefab', 'actor') for i,n in enumerate(['Zombie','Zombie 2','Zombie 3','Mummy','MiniBoss1 Section','MiniBoss2 Section','Boss Section'])]
    paths += [('Weapons', None, 'Weapons')]
    paths += [(p.stem,p,None) for p in (SOURCE/'GameObject').glob('*Projectile.prefab') if p.stem in ['Arrow Projectile','Fire Arrow Projectile','Cursed Arrow Projectile','Shuriken Projectile','MiniBoss Projectile','MiniBoss 2 Projectile','Boss Projectile']]
    for name,path,selection in paths:
        doc = read(path) if path else game
        gos = {i:v for i,(k,v) in doc.items() if k==1}
        transforms = {i:v for i,(k,v) in doc.items() if k==4}
        by_go = {v['m_GameObject']['fileID']:i for i,v in transforms.items()}
        actors = {v['m_GameObject']['fileID'] for k,v in doc.values() if 'baseHealth' in v}
        roots = [i for i,v in transforms.items() if (v['m_GameObject']['fileID'] in actors if selection=='actor' else (gos[v['m_GameObject']['fileID']]['m_Name']==selection if selection else not v['m_Father']['fileID']))]
        assert len(roots)==1, name
        renderers = {v['m_GameObject']['fileID']:v for k,v in doc.values() if k==23}
        filters = {v['m_GameObject']['fileID']:v for k,v in doc.values() if k==33}
        excluded = {v['m_GameObject']['fileID'] for k,v in doc.values() if 'baseHealth' in v}
        nodes=[]
        def visit(tid, parent=-1):
            t=transforms[tid]; go=t['m_GameObject']['fileID']; g=gos[go]
            if go in excluded and selection != 'actor': return
            index=len(nodes)
            n=dict(name=g['m_Name'],parent=parent,position=list(t['m_LocalPosition'].values()), rotation=list(t['m_LocalRotation'].values()),scale=list(t['m_LocalScale'].values()),active=bool(g['m_IsActive']))
            if go in filters and go in renderers and renderers[go]['m_Enabled']:
                n.update(mesh(filters[go]['m_Mesh'],renderers[go]))
                n['material']=material(renderers[go]['m_Materials'][0])
            if parent == -1 and (selection == 'actor' or name == 'Weapons' or name.endswith('Projectile')): n['position']=[0,0,0]
            nodes.append(n)
            for child in t['m_Children']:
                if child['fileID'] in transforms: visit(child['fileID'],index)
        visit(roots[0]); layouts[name]=nodes
    animations={}
    for name in ['EnemyIdle','BossIdle','BossEntranceOpen']:
        clip=next(iter(read(SOURCE/'AnimationClip'/f'{name}.anim').values()))[1]
        animations[name]={prop:clip.get(prop,[]) for prop in ['m_PositionCurves','m_ScaleCurves']}
    sounds = dict((int(n),s) for s,n in re.findall(r'^\s*(\w+) = (\d+)', (SOURCE/'Scripts/Assembly-CSharp/AudioManager.cs').read_text(),re.M))
    audio={}; AUDIO.mkdir(exist_ok=True)
    menu = read(SOURCE/'Scenes/MainMenuScene.unity')
    values=next(v['soundAudioClipArray']['values'] for k,v in menu.values() if 'soundAudioClipArray' in v)
    for v in values:
        path=lookup.get(v['audioClip'].get('guid'))
        if not path: continue
        shutil.copyfile(path,AUDIO/path.name)
        fingerprints[str(path.relative_to(SOURCE))]=hashlib.sha256(path.read_bytes()).hexdigest()
        audio[sounds[v['sound']]]=dict(file=path.name,volume=v['clipVolume'],pitch=v['pitch'])
    render=next(v for k,v in game.values() if k==104)
    catalog=dict(layouts=layouts,materials=materials,meshes=meshes,audio=audio,animations=animations,render=render,source_sha256=fingerprints)
    (DEST/'presentation.json').write_text(json.dumps(catalog,separators=(',',':')))
    print(f'Imported {len(layouts)} layouts, {len(materials)} materials, {len(meshes)} baked mesh surfaces, {len(audio)} sound cues')

if __name__=='__main__': run()
