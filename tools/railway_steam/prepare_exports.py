"""Prepare curated, separate Steam demo and full Windows depots."""
import json
import pathlib
import re
import runpy

ROOT = pathlib.Path(__file__).resolve().parents[2]
PROJECT = ROOT / 'FeedingABlackHoldGame'
runpy.run_path(str(ROOT / 'tools/railway_demo/prepare_exports.py'))
PRESETS = PROJECT / 'export_presets.cfg'
source = PRESETS.read_text(encoding='utf8')
blocks = [b for b in re.split(r'(?=\[preset\.\d+\]\n)', source)
          if b.strip() and 'name="Railway Fury Steam ' not in b]
template = next(b for b in blocks if 'name="Railway Fury Demo Windows"' in b)
for edition, features, exe in [('Full', 'railway_steam', 'RailwayFury'),
                               ('Demo', 'railway_steam,railway_demo', 'RailwayFuryDemo')]:
    index = max(int(re.match(r'\[preset\.(\d+)\]', b)[1]) for b in blocks) + 1
    block = re.sub(r'\[preset\.\d+(\.options)?\]',
                   lambda m: f'[preset.{index}{m[1] or ""}]', template)
    values = {'name': f'"Railway Fury Steam {edition}"',
              'custom_features': json.dumps(features),
              'application/icon': '"res://Games/RowDivers/Art/UI/railway-icon.png"',
              'export_path': json.dumps(f'../Build - RailwayFury/Steam/{edition}/{exe}.exe'),
              'application/product_name': json.dumps('Railway Fury' + (' Demo' if edition == 'Demo' else ''))}
    files = set(re.findall(r'"(res://[^"]+)"', re.search(r'^export_files=.*$', block, re.M)[0]))
    files.add('res://addons/godotsteam/godotsteam.gdextension')
    if edition == 'Full':
        for folder in ['Levels', 'Endings']:
            files.update('res://' + p.relative_to(PROJECT).as_posix()
                         for p in (PROJECT / 'Games/RowDivers/Art' / folder).rglob('*')
                         if p.is_file() and p.suffix not in ['.import', '.uid'])
    values['export_files'] = 'PackedStringArray(' + ', '.join(json.dumps(f) for f in sorted(files)) + ')'
    for key, value in values.items():
        block = re.sub(r'^' + re.escape(key) + r'=.*$', lambda _: key + '=' + value, block, flags=re.M)
    (ROOT / 'Build - RailwayFury/Steam' / edition).mkdir(parents=True, exist_ok=True)
    blocks.append(block)
# Godot stops reading presets at the first missing numeric index.
blocks = [re.sub(r'\[preset\.\d+(\.options)?\]',
                 lambda m: f'[preset.{i}{m[1] or ""}]', b)
          for i, b in enumerate(blocks)]
PRESETS.write_text('\n'.join(b.rstrip() + '\n' for b in blocks), encoding='utf8')
print('Prepared Steam Full (5520300) and Demo (5520330) Windows presets.')
