"""Append dedicated demo presets without changing existing release/QA presets."""
import pathlib
import re
import json
ROOT=pathlib.Path(__file__).resolve().parents[2]
PROJECT=ROOT/'FeedingABlackHoldGame'
path=PROJECT/'export_presets.cfg'
text=path.read_text(encoding='utf8')
blocks=re.split(r'(?=\[preset\.\d+\]\n)',text)
blocks=[b for b in blocks if b.strip() and 'name="Railway Fury Demo ' not in b]
exclude='Audio/Main Music Playlist.tres,Audio/Music/*,Games/*/Reports/*,Games/*/Docs/*,Games/*/Tools/*,Games/*/Simulation/*,Games/RowDivers/Translations/sources.json,Games/RowDivers/Translations/en.json,Games/RowDivers/Translations/es.json,Games/RowDivers/Translations/de.json,Games/RowDivers/Translations/pt.json,Games/RowDivers/Translations/fr.json,Games/RowDivers/Translations/it.json,Games/RowDivers/Translations/zh.json,Games/RowDivers/Translations/ja.json,Games/RowDivers/Translations/ko.json,Games/RowDivers/Translations/ru.json,Games/RowDivers/Translations/pl.json,Games/RowDivers/Translations/tr.json,Games/RowDivers/Translations/th.json,Games/RowDivers/Translations/id.json,Games/RowDivers/Translations/cs.json,Games/RowDivers/Translations/ca.json,Games/RowDivers/Translations/vi.json,StoreAssets*/*,tools/*,simulation/*'
class_cache=(PROJECT/'.godot/global_script_class_cache.cfg').read_text(encoding='utf8')
classes=dict(re.findall(r'"class":\s*&?"([^"]+)".*?"path":\s*"res://([^"]+)"',class_cache,re.S))
project_text=(PROJECT/'project.godot').read_text(encoding='utf8')
version=re.search(r'^config/version="([^"]+)"',project_text,re.M).group(1)
autoload_section=project_text.split('[autoload]',1)[1].split('\n[',1)[0]
autoloads=set(re.findall(r'="\*res://([^"]+)"',autoload_section))

def dependencies(selected):
    selected.update(autoloads)
    pending=list(selected)
    while pending:
        rel=pending.pop()
        path=PROJECT/rel
        if path.suffix not in ['.gd','.tscn','.tres','.gdshader']:continue
        if not path.exists():raise RuntimeError('Missing dependency: '+rel)
        source=path.read_text(encoding='utf8')
        refs=set(re.findall(r'preload\(\s*"res://([^"]+)"',source))
        refs.update(re.findall(r'path\s*=\s*"res://([^"]+)"',source))
        refs.update(re.findall(r'extends\s+"res://([^"]+)"',source))
        if path.suffix=='.gd':
            refs.update(classes[word] for word in set(re.findall(r'\b[A-Za-z_]\w*\b',source)) if word in classes)
        for ref in refs-selected:
            selected.add(ref);pending.append(ref)
    return selected
for platform,base,folder,filename in [('Windows',0,'Windows','RailwayFuryDemo.exe'),('Web',1,'Web','index.html')]:
    block=next(b for b in blocks if b.startswith('[preset.%d]'%base))
    index=max(int(re.match(r'\[preset\.(\d+)\]',b).group(1)) for b in blocks)+1
    block=re.sub(r'\[preset\.\d+(\.options)?\]',lambda m:f'[preset.{index}{m[1] or ""}]',block)
    values={'name':f'"Railway Fury Demo {platform}"','custom_features':'"railway_demo"','export_filter':'"resources"','include_filter':'"*.json,*.csv"','exclude_filter':f'"{exclude}"','export_path':f'"../Build - RailwayFury/Demo/{folder}/{filename}"','encrypt_pck':'false','script_export_mode':'1'}
    for key,value in values.items():block=re.sub(r'^'+re.escape(key)+r'=.*$',key+'='+value,block,flags=re.M)
    # Select runtime scenes plus assets loaded by name. Godot includes their
    # recursive dependencies and autoloads; unrelated game artwork is omitted.
    selected={'Core/Boot/AppBootstrap.tscn','Core/Boot/GameLauncher.tscn','UpgradeScreen.tscn','Settings.tscn','Game Modes/Main Mode.tres','default_bus_layout.tres','addons/controller_icons/settings.tres'}
    selected.update(p.relative_to(PROJECT).as_posix() for p in (PROJECT/'Data').glob('*.translation'))
    for folder_name in ['Games/RowDivers','Art','Theme','Core','Pallets','addons/controller_icons/assets']:
        for file in (PROJECT/folder_name).rglob('*'):
            rel=file.relative_to(PROJECT).as_posix()
            if not file.is_file() or file.suffix in ['.import','.uid','.json','.md','.txt','.py','.cs','.log','.csv']:continue
            if any('/'+part+'/' in '/'+rel for part in ['Docs','Tools','Simulation']):continue
            if rel.startswith(('Games/RowDivers/Art/Levels/','Games/RowDivers/Art/Endings/')):continue
            if platform=='Web' and '/Fallbacks/' in rel and file.name!='NotoSans-Regular.ttf':continue
            selected.add(rel)
    selected=dependencies(selected)
    export_files='export_files=PackedStringArray('+', '.join(json.dumps('res://'+f) for f in sorted(selected))+')'
    block=block.replace('export_filter="resources"','export_filter="resources"\n'+export_files)
    block=block.replace('application/product_name="Bleepware Incrementals"','application/product_name="Railway Fury Demo"')
    if platform=='Windows':
        for key in ['application/file_version','application/product_version']:
            block=re.sub(r'^'+re.escape(key)+r'=.*$',key+'="'+version+'.0.0"',block,flags=re.M)
    block=block.replace('debug/export_console_wrapper=1','debug/export_console_wrapper=0')
    (ROOT/'Build - RailwayFury/Demo'/folder).mkdir(parents=True,exist_ok=True)
    blocks.append(block)
path.write_text('\n'.join(b.rstrip()+'\n' for b in blocks),encoding='utf8')
print('Prepared dedicated Windows and single-threaded Web demo exports.')
