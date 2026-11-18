"""Package verified full Windows itch exports and record exact fingerprints."""
from pathlib import Path
import hashlib
import json
import zipfile

root = Path(__file__).resolve().parents[2]
folder = root / 'Build - RailwayFury/Full'
archive = folder / 'RailwayFury-Full-Windows.zip'
with zipfile.ZipFile(archive, 'w', zipfile.ZIP_DEFLATED, compresslevel=6) as bundle:
    for file in sorted((folder/'Windows').rglob('*')):
        if file.is_file() and file.suffix not in ['.log']:
            bundle.write(file, file.relative_to(folder/'Windows'))
result = {'version':'0.9','edition':'full','platform':'Windows',
          'bytes':archive.stat().st_size,'sha256':hashlib.sha256(archive.read_bytes()).hexdigest(),
          'steam_required':False,'public':False}
(folder/'build_manifest.json').write_text(json.dumps(result,indent=2)+'\n',encoding='utf8')
print(json.dumps(result,indent=2))
