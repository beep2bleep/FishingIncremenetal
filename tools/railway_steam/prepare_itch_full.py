"""Prepare the matching full Windows itch package without Steam-only features."""
from pathlib import Path
import re

root = Path(__file__).resolve().parents[2]
presets = root / 'FeedingABlackHoldGame/export_presets.cfg'
blocks = [b for b in re.split(r'(?=\[preset\.\d+\]\n)', presets.read_text(encoding='utf8'))
          if b.strip() and 'name="Railway Fury Full Itch Windows"' not in b]
template = next(b for b in blocks if 'name="Railway Fury Steam Full"' in b)
template = template.replace('name="Railway Fury Steam Full"', 'name="Railway Fury Full Itch Windows"')
template = re.sub(r'^custom_features=.*$', 'custom_features="railway_itch"', template, flags=re.M)
template = re.sub(r'^export_path=.*$', 'export_path="../Build - RailwayFury/Full/Windows/RailwayFury.exe"', template, flags=re.M)
blocks.append(template)
blocks = [re.sub(r'\[preset\.\d+(\.options)?\]', lambda m: f'[preset.{i}{m[1] or ""}]', b) for i,b in enumerate(blocks)]
presets.write_text('\n'.join(b.rstrip()+'\n' for b in blocks),encoding='utf8')
(root/'Build - RailwayFury/Full/Windows').mkdir(parents=True,exist_ok=True)
