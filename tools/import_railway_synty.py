"""Copy selected owned Synty Godot assets and their dependencies, not whole packs."""
from pathlib import Path
import json
import re
import zipfile

ROOT = Path(__file__).resolve().parents[1] / 'FeedingABlackHoldGame'
DEST = 'Games/RowDivers/Art/Synty'
ARCHIVE = next(Path(r'C:\Game Assets\Synty Pass\Godot\POLYGON - Dark Fantasy').glob('*.zip'))
CHARACTERS = ['Skeleton_01', 'Skeleton_HeavyArmor_01', 'Skeleton_Flesh_01',
              'Skeleton_Ranger_01', 'PlagueDoctor_01', 'Priest_Female_01', 'DarkLord_Male_01']
WEAPONS = ['Crossbow_01', 'Crossbow_01_Arrow_01', 'Sword_01', 'Sword_02']


def prune_character(text):
    blocks = re.split(r'(?=^\[)', text, flags=re.M)
    # Each supplied character scene includes every character in the source FBX.
    # Retain only its selected visible skin, skeleton and referenced resources.
    nodes = [b for b in blocks if b.startswith('[node') and
             ('parent=' not in b.splitlines()[0] or 'type="Skeleton3D"' in b or
              ('type="MeshInstance3D"' in b and 'visible = false' not in b))]
    needed = set(re.findall(r'SubResource\("([^"]+)"\)', ''.join(nodes)))
    resources = {re.search(r'\bid="([^"]+)"', b)[1]: b for b in blocks if b.startswith('[sub_resource')}
    while True:
        more = {r for k in needed for r in re.findall(r'SubResource\("([^"]+)"\)', resources[k])}
        if more <= needed:
            break
        needed |= more
    body = ''.join(resources[k] for k in resources if k in needed) + ''.join(nodes)
    ext = set(re.findall(r'ExtResource\("([^"]+)"\)', body))
    header = '[gd_scene format=3]\n\n'
    return header + ''.join(b for b in blocks if b.startswith('[ext_resource') and re.search(r'\bid="([^"]+)"', b)[1] in ext) + body.replace('type="CharacterBody3D"', 'type="Node3D"')


def run():
    archive = zipfile.ZipFile(ARCHIVE)
    index = {n.split('/Assets/Synty/PolygonDarkFantasy/', 1)[1].lower(): n for n in archive.namelist()
             if '/Assets/Synty/PolygonDarkFantasy/' in n and not n.endswith('/')}
    copied = set()
    records = []

    def copy(relative):
        key = relative.lower()
        if key in copied:
            return
        copied.add(key)
        source = index[key]
        relative = source.split('/Assets/Synty/PolygonDarkFantasy/', 1)[1]
        data = archive.read(source)
        target = ROOT / DEST / relative
        if relative.endswith(('.tscn', '.tres')):
            text = data.decode('utf-8-sig')
            if '/Characters/SM_Chr_' in relative and relative.endswith('.tscn'):
                text = prune_character(text)
            dependencies = re.findall(r'res://[Aa]ssets/Synty/PolygonDarkFantasy/([^"\n]+)', text)
            for dependency in dependencies:
                copy(dependency)
                canonical = index[dependency.lower()].split('/Assets/Synty/PolygonDarkFantasy/', 1)[1]
                text = text.replace('res://Assets/Synty/PolygonDarkFantasy/' + dependency, 'res://' + DEST + '/' + canonical)
                text = text.replace('res://assets/Synty/PolygonDarkFantasy/' + dependency, 'res://' + DEST + '/' + canonical)
            text = re.sub(r' uid="[^"]+"', '', text)
            data = text.encode('utf-8')
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_bytes(data)
        records.append({'path': 'res://' + DEST + '/' + relative, 'source_entry': source, 'bytes': len(data)})

    for name in CHARACTERS:
        copy('Prefabs/Characters/SM_Chr_' + name + '.tscn')
    for name in WEAPONS:
        copy('Prefabs/Weapons/SM_Wep_' + name + '.tscn')
    (ROOT / DEST / 'sources.json').write_text(json.dumps({'archive': str(ARCHIVE), 'assets': records}, indent=2))
    print(f'Imported {len(records)} selected assets, {sum(r["bytes"] for r in records)/1048576:.1f} MiB')


if __name__ == '__main__':
    run()
