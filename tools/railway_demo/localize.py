"""Build Railway Fury's source-message catalogue; resumable translation cache.

Translations are machine drafts. Numeric values, format tokens and BBCode are
protected and audited; the output is checked into the game (no runtime network).
"""
import ast
import concurrent.futures
import csv
import json
import pathlib
import re
import time
import urllib.parse
import urllib.request

ROOT = pathlib.Path(__file__).resolve().parents[2]
GAME = ROOT / 'FeedingABlackHoldGame'
ROW = GAME / 'Games/RowDivers'
OUT = ROW / 'Translations'
LOCALES = 'en es de pt fr it zh ja ko ru pl tr th id cs ca vi'.split()
STRING = re.compile(r'"(?:[^"\\]|\\.)*"')
TOKEN = re.compile(r'Railway Fury|RAILWAY FURY|%(?:[-+0#]*\d*(?:\.\d+)?[sdfxX]|%)|\d+(?:[.,]\d+)*|\[/?(?:b|i|u|color[^\]]*)\]|\b(?:VIII|VII|VI|IV|III|II|I)\b')


def human(s):
    if not re.search('[A-Za-z]', s) or len(s) > 2000: return False
    # These are identifiers in the shared translation table, not English copy.
    # Adding identity translations for them could shadow their real messages.
    if re.fullmatch('[A-Z0-9_]+',s) and '_' in s: return False
    if any(v in s for v in ['res://', 'user://', '.png', '.wav', '.ogg', '.tscn', '.json', '.gd', '.ttf', '.tres', 'EDITOR', 'F8', 'F7', 'TEMP_', 'railway_', 'row_', 'RAILWAY AUTO', 'RAILWAY FURY BACKGROUND']): return False
    return ' ' in s.strip() or s.isupper() or bool(re.fullmatch('[A-Z][a-z]+', s))


def sources():
    result = set()
    for path in (ROW / 'Data').glob('*.json'):
        data = json.loads(path.read_text())
        for entry in data['upgrades']:
            result.update([entry['upgradeName'], entry['upgradeDescription']])
        for entry in data['settings']['achievements']:
            result.update([entry['achievementName'], entry['description']])
        result.update(v.replace('_', ' ') for v in data['enums']['ZombieType'].values())
    files = [ROW / p for p in ['RowDiversHUD.gd', 'Scenes/RowDiversBattleScene.gd', 'Scenes/RowDiversEnding.gd', 'RowDiversEndings.gd', 'RowDiversTiming.gd', 'RowDiversLevelThemes.gd', 'RowDiversProgress.gd']]
    for file in files:
        function = ''
        for line in file.read_text(encoding='utf-8-sig').splitlines():
            if line.startswith('func ') or line.startswith('static func '): function = line
            if any(v in function for v in ['debug_speed', '_auto_return', '_return_to_editor', '_build_debug']): continue
            if line.lstrip().startswith('#') or 'print(' in line or 'push_error(' in line: continue
            for match in STRING.finditer(line):
                value = ast.literal_eval(match.group())
                if human(value): result.add(value)
    shared = {
        'UpgradeScreen.gd': lambda name: ('row_divers' in name and not any(x in name for x in ['auto_buy','auto_run','editor_loop','randomize'])) or name in ['_refresh_bottom_wallet_display','_get_leaderboard_panel_title','_refresh_leaderboard_panel'],
        'Settings.gd': lambda name: name.startswith('_setup_row_divers') or name=='_set_credits_visible',
        'Core/Boot/GameLauncher.gd': lambda name: name in ['_refresh_text','_refresh_game_card_text','_setup_row_divers_button'],
        'Tech Tree Stuff/TechTreeNode.gd': lambda name: name=='update',
    }
    for file,include in shared.items():
        name=''
        for line in (GAME/file).read_text(encoding='utf-8-sig').splitlines():
            match=re.match(r'func (\w+)\(',line)
            if match:name=match[1]
            if not include(name) or line.lstrip().startswith('#') or 'print(' in line:continue
            for match in STRING.finditer(line):
                value=ast.literal_eval(match.group())
                if human(value): result.add(value)
    result.update(['DEMO MODE','DEMO COMPLETE','DEMO MODE — DEFEAT THE FIRST BOSS','Full game upgrade — locked in demo mode',' OR ','Unlock: ','Gold','Gems','Crowns','CLAIM','Claimed','Locked','CLICK','HOLD','AUTO','the row','fire waves','poison','contact','enemy projectile','FULL GAME ONLY','Railway Fury Upgrade'])
    return sorted(v for v in result if v)


def protected(source):
    tokens = []
    def sub(match):
        tokens.append(match.group())
        return f'{{RFP{len(tokens)-1:03}}}'
    return TOKEN.sub(sub, source), tokens


def request_batch(locale, batch):
    encoded = []
    original = []
    for i,source in enumerate(batch):
        value,tokens=protected(source)
        encoded.append(f'RFW{i:03}WFR\n{value}')
        original.append(tokens)
    query = urllib.parse.urlencode({'client':'gtx','sl':'en','tl':'zh-CN' if locale=='zh' else locale,'dt':'t','q':'\n'.join(encoded)})
    req=urllib.request.Request('https://translate.googleapis.com/translate_a/single?'+query,headers={'User-Agent':'Mozilla/5.0'})
    with urllib.request.urlopen(req,timeout=45) as response: data=json.load(response)
    translated=''.join(x[0] or '' for x in data[0])
    parts=re.split(r'RFW\s*(\d{3})\s*WFR\s*\n?',translated)
    if len(parts)!=1+len(batch)*2: raise ValueError('Translation boundary marker lost')
    result={}
    for index in range(len(batch)):
        if int(parts[1+index*2])!=index: raise ValueError('Translation boundary reordered')
        text=parts[2+index*2].strip()
        for n,token in enumerate(original[index]):
            pattern=rf'\{{\s*RFP\s*{n:03}\s*\}}'
            if len(re.findall(pattern,text,re.I))!=1: raise ValueError('Placeholder lost: '+batch[index])
            text=re.sub(pattern,lambda _:token,text,flags=re.I)
        # Preserve layout whitespace outside the actual message.
        source=batch[index]
        text=source[:len(source)-len(source.lstrip())]+text+source[len(source.rstrip()):]
        formats = lambda value: re.findall(r'%(?:[-+0#]*\d*(?:\.\d+)?[sdfxX]|%)', value)
        if formats(source)!=formats(text): raise ValueError('Format token sequence changed: '+source)
        result[source]=text
    return result


def translate(locale, source, reuse):
    path=OUT/(locale+'.json')
    cache=json.loads(path.read_text(encoding='utf8')) if path.exists() else {}
    for text in source:
        if text in reuse and reuse[text].get(locale): cache.setdefault(text,reuse[text][locale])
    missing=[s for s in source if s not in cache]
    batches=[];batch=[];size=0
    for text in missing:
        if size+len(text)>3000 and batch: batches.append(batch);batch=[];size=0
        batch.append(text);size+=len(text)+25
    if batch:batches.append(batch)
    for i,batch in enumerate(batches):
        for attempt in range(4):
            try:
                cache.update(request_batch(locale,batch));break
            except Exception as error:
                print(locale,'retry',attempt,str(error),flush=True)
                if attempt==3: raise RuntimeError(locale+': '+str(error)) from error
                time.sleep(2+attempt*2)
        path.write_text(json.dumps(cache,ensure_ascii=False,indent=2),encoding='utf8')
        print(locale,i+1,'/',len(batches),flush=True)
    return locale,{s:cache[s] for s in source}


def main():
    OUT.mkdir(exist_ok=True)
    source=sources()
    (OUT/'sources.json').write_text(json.dumps(source,ensure_ascii=False,indent=2),encoding='utf8')
    reuse={}
    with (GAME/'Data/Blackhole Translations - Sheet1.csv').open(encoding='utf-8-sig',newline='') as stream:
        for row in csv.DictReader(stream):
            if row.get('en'):reuse[row['en']]=row
    print('Source messages:',len(source),flush=True)
    output={'en':{s:s for s in source}}
    with concurrent.futures.ThreadPoolExecutor(max_workers=3) as pool:
        futures=[pool.submit(translate,locale,source,reuse) for locale in LOCALES if locale!='en']
        for future in concurrent.futures.as_completed(futures):
            locale,translated=future.result();output[locale]=translated
    (OUT/'catalog.json').write_text(json.dumps(output,ensure_ascii=False,indent=2),encoding='utf8')
    print('COMPLETE',len(output),'languages;',len(source),'messages per language',flush=True)

if __name__=='__main__': main()
