"""Clone the release presets with an isolated user-data feature for flow QA."""
import pathlib
import re

root = pathlib.Path(__file__).resolve().parents[2]
presets = root / 'FeedingABlackHoldGame/export_presets.cfg'
blocks = [b for b in re.split(r'(?=\[preset\.\d+\]\n)', presets.read_text(encoding='utf8'))
          if b.strip() and 'name="Railway Fury Controller QA ' not in b]
for edition in ['Full', 'Demo']:
    template = next(b for b in blocks if f'name="Railway Fury Steam {edition}"' in b)
    template = template.replace(f'name="Railway Fury Steam {edition}"', f'name="Railway Fury Controller QA {edition}"')
    template = re.sub(r'^custom_features="([^"]*)"', r'custom_features="\1,controller_qa"', template, flags=re.M)
    folder = root / '.validation/controller' / edition
    folder.mkdir(parents=True, exist_ok=True)
    template = re.sub(r'^export_path=.*$', f'export_path="../.validation/controller/{edition}/RailwayControllerQA.exe"', template, flags=re.M)
    blocks.append(template)
blocks = [re.sub(r'\[preset\.\d+(\.options)?\]', lambda m: f'[preset.{i}{m[1] or ""}]', b)
          for i, b in enumerate(blocks)]
presets.write_text('\n'.join(b.rstrip() + '\n' for b in blocks), encoding='utf8')
print('Prepared controller QA presets; runtime sources match release presets, saves are isolated.')
