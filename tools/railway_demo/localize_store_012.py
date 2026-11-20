"""Regenerate current auto-fire store copy without changing hardware fields."""
import concurrent.futures
import json
from pathlib import Path
import re
import localize

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / 'StoreLocalization/2026-11-20'
OUT.mkdir(exist_ok=True)
ABOUT = 'app[content][about]'
SHORT = 'app[content][short_description]'
LANGUAGES = dict(english='en', french='fr', italian='it', german='de', spanish='es',
                czech='cs', indonesian='id', japanese='ja', koreana='ko', polish='pl',
                portuguese='pt', russian='ru', schinese='zh', thai='th', turkish='tr',
                vietnamese='vi', catalan='ca')
sources = {}
for kind, filename, marker in [('main', 'full-description.md', 'About this game:'),
                               ('demo', 'demo-description.md', 'About this demo:')]:
    text = (ROOT / 'FeedingABlackHoldGame/StoreAssets_RailwayFury/steam' / filename).read_text(encoding='utf8')
    short, about = text.split('Short description:', 1)[1].split(marker)
    sources[kind] = {SHORT: short.strip(), ABOUT: ''.join('[p]' + p + '[/p]' for p in about.strip().split('\n\n'))}
(OUT / 'english.json').write_text(json.dumps(sources, ensure_ascii=False, indent=2), encoding='utf8')
localize.TOKEN = re.compile(r'Railway Fury|Windows|Vulkan|VRAM|GHz|GB|Shift|Menu / Options|\bSpace\b|\d+(?:[.,]\d+)*')

def translate(language, locale):
    path = OUT / (language + '.json')
    if locale == 'en': return language, sources
    if path.exists(): return language, json.loads(path.read_text(encoding='utf8'))
    paragraphs = list(dict.fromkeys(p for fields in sources.values() for key, value in fields.items()
                                   for p in (re.findall(r'\[p\](.*?)\[/p\]', value) if key == ABOUT else [value])))
    translated = {}
    batch = []
    for paragraph in paragraphs:
        if batch and sum(map(len, batch)) + len(paragraph) > 2600:
            translated.update(localize.request_batch(locale, batch))
            batch = []
        batch.append(paragraph)
    if batch: translated.update(localize.request_batch(locale, batch))
    result = {}
    for kind, fields in sources.items():
        result[kind] = {SHORT: translated[fields[SHORT]],
                        ABOUT: ''.join('[p]' + translated[p] + '[/p]' for p in re.findall(r'\[p\](.*?)\[/p\]', fields[ABOUT]))}
        assert len(result[kind][SHORT]) <= 300, (language, kind, 'short description too long')
    path.write_text(json.dumps(result, ensure_ascii=False, indent=2), encoding='utf8')
    print(language, 'translated', flush=True)
    return language, result

with concurrent.futures.ThreadPoolExecutor(max_workers=3) as pool:
    results = dict(pool.map(lambda pair: translate(*pair), LANGUAGES.items()))
for kind, itemid in [('main', '1410386'), ('demo', '1410394')]:
    old = json.loads((ROOT / 'StoreLocalization/2026-10-28' / (kind + '_verified.json')).read_text(encoding='utf-8-sig'))
    payload = {'itemid': itemid, 'languages': {}}
    for language in LANGUAGES:
        if language == 'catalan': continue
        fields = old.get('languages', {}).get(language, {}).copy()
        fields.update(results[language][kind])
        payload['languages'][language] = fields
        for key, value in results[language][kind].items():
            assert not re.search(r'RFP\d|RFW|WFR', value), (language, kind, key)
            assert value.strip()
    (OUT / (kind + '_steam_upload.json')).write_text(json.dumps(payload, ensure_ascii=False, indent=2), encoding='utf8')
    print(kind, len(payload['languages']), 'Steam languages packaged', flush=True)
