"""Package current demo exports; enforce itch.io's HTML file-size limit."""
import hashlib
import json
import pathlib
import zipfile

ROOT=pathlib.Path(__file__).resolve().parents[2]
BUILD=ROOT/'Build - RailwayFury/Demo'
manifest={}
for folder,name in [('Windows','RailwayFuryDemo-Windows.zip'),('Web','RailwayFuryDemo-Web.zip')]:
    files=sorted(p for p in (BUILD/folder).rglob('*') if p.is_file())
    if not files: raise RuntimeError('Missing export: '+folder)
    if folder=='Web':
        for path in files:
            if path.stat().st_size>200*1024*1024:
                raise RuntimeError('itch.io HTML file limit exceeded: '+str(path))
        if not any(p.name=='index.html' for p in files): raise RuntimeError('Missing index.html')
    with zipfile.ZipFile(BUILD/name,'w',zipfile.ZIP_DEFLATED,compresslevel=6) as archive:
        for path in files: archive.write(path,path.relative_to(BUILD/folder))
    path=BUILD/name
    with path.open('rb') as stream: sha=hashlib.file_digest(stream,'sha256').hexdigest()
    manifest[name]={'bytes':path.stat().st_size,'sha256':sha}
(BUILD/'build_manifest.json').write_text(json.dumps(manifest,indent=2),encoding='utf8')
print(json.dumps(manifest,indent=2))
