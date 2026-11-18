"""Build and audit Steam store localization files from downloaded source text.

The original downloads remain untouched. Generated copy is reviewed separately
before uploading through Steamworks. Catalan is a local deliverable because
Steam does not offer Catalan store text.
"""
import concurrent.futures
import json
import pathlib
import re
import sys

import localize

ROOT = pathlib.Path(__file__).resolve().parents[2]
OUT = ROOT / 'StoreLocalization' / '2026-10-28'
DOWNLOADS = pathlib.Path.home() / 'Downloads'
LANGUAGES = dict(french='fr', italian='it', german='de', spanish='es',
                czech='cs', indonesian='id', japanese='ja', koreana='ko',
                polish='pl', portuguese='pt-PT', russian='ru', schinese='zh',
                thai='th', turkish='tr', vietnamese='vi', catalan='ca')
ABOUT = 'app[content][about]'
SHORT = 'app[content][short_description]'
DEMO_SHORT = ('Try the first railway and boss in this first-person incremental action demo. '
              'Aim your crossbow, dodge enemies and fire waves, collect loot, and buy permanent upgrades. '
              'The demo ends after the first boss and uses a separate save from the full game.')


def normalized(text):
    # A dive is a combat run here, not swimming. Give the draft translator that
    # context without changing the English page itself.
    replacements = {
        'Every dive': 'Every run', 'each dive': 'each run',
        'EACH DIVE': 'EACH RUN', 'between dives': 'between runs',
        'active dive time': 'active play time during runs',
        'Take your first dives into': 'Start your first runs in',
        'MAKE EACH RUN COUNT': 'MAKE EVERY RUN COUNT',
        'BUILD YOUR WAY FORWARD': 'ADVANCE WITH UPGRADES',
        'bank your loot': 'keep your loot',
        'aiming, strafing,': 'aiming, moving sideways,',
        'strafe around enemies': 'move sideways to dodge enemies',
        'Aim, strafe, and shoot': 'Aim, move sideways, and shoot',
        'returning daggers': 'daggers that return to you',
        'fire-control upgrades': 'upgrades that help you deal with fire hazards',
        'Your active play time during runs tracks progress toward boss clears and the ending.':
        'Your time spent actively playing runs is recorded as you progress toward defeating bosses and reaching the ending.',
    }
    for source, target in replacements.items():
        text = text.replace(source, target)
    return text


def prepare():
    OUT.mkdir(parents=True, exist_ok=True)
    sources = {}
    for kind, itemid in [('main', '1410386'), ('demo', '1410394')]:
        original = json.loads((DOWNLOADS / f'storepage_{itemid}_all.json').read_text(encoding='utf-8-sig'))
        (OUT / f'{kind}_before.json').write_text(json.dumps(original, ensure_ascii=False, indent=2), encoding='utf-8')
        sources[kind] = original['languages']['english']
    sources['demo'][SHORT] = DEMO_SHORT
    (OUT / 'english.json').write_text(json.dumps(sources, ensure_ascii=False, indent=2), encoding='utf-8')
    return sources


def translate_language(language, locale, sources):
    path = OUT / f'{language}.json'
    if path.exists():
        return language, json.loads(path.read_text(encoding='utf-8'))
    paragraphs = list(dict.fromkeys(p for fields in sources.values() for key, value in fields.items()
                                   for p in (re.findall(r'\[p\](.*?)\[/p\]', value) if key == ABOUT else [value])))
    # Keep markup out of the translator; preserve technical names and controls.
    localize.TOKEN = re.compile(r'Railway Fury|Windows|Vulkan|VRAM|GHz|GB|Shift|\bSpace\b|\d+(?:[.,]\d+)*')
    translated = {}
    batch = []
    for paragraph in paragraphs:
        if batch and sum(len(p) for p in batch) + len(paragraph) > 2800:
            translated.update(localize.request_batch(locale, [normalized(p) for p in batch]))
            batch = []
        batch.append(paragraph)
    if batch:
        translated.update(localize.request_batch(locale, [normalized(p) for p in batch]))
    result = {}
    for kind, fields in sources.items():
        result[kind] = {}
        for key, value in fields.items():
            if key == ABOUT:
                result[kind][key] = ''.join('[p]' + translated[normalized(p)] + '[/p]'
                                           for p in re.findall(r'\[p\](.*?)\[/p\]', value))
            else:
                result[kind][key] = translated[normalized(value)]
    path.write_text(json.dumps(result, ensure_ascii=False, indent=2), encoding='utf-8')
    print(language, 'drafted', flush=True)
    return language, result


def package():
    sources = json.loads((OUT / 'english.json').read_text(encoding='utf-8'))
    for kind, itemid in [('main', '1410386'), ('demo', '1410394')]:
        payload = {'itemid': itemid, 'languages': {}}
        # English source already exists in Steam. Only add the missing demo
        # short description; avoid rewriting unrelated English fields.
        if kind == 'demo':
            payload['languages']['english'] = {SHORT: sources[kind][SHORT]}
        for language in LANGUAGES:
            fields = json.loads((OUT / f'{language}.json').read_text(encoding='utf-8'))[kind]
            assert fields.keys() == sources[kind].keys(), (kind, language, 'fields')
            for key, value in fields.items():
                assert value.strip(), (kind, language, key, 'empty')
                assert len(re.findall(r'\[p\]', value)) == len(re.findall(r'\[p\]', sources[kind][key]))
                assert len(re.findall(r'\[/p\]', value)) == len(re.findall(r'\[/p\]', sources[kind][key]))
                assert not re.search(r'RFW|WFR|RFP\d', value), (kind, language, key, 'placeholder')
                if key == SHORT:
                    assert len(value) <= 300, (kind, language, 'short description too long', len(value))
            if language != 'catalan':
                payload['languages'][language] = fields
        (OUT / f'{kind}_steam_upload.json').write_text(json.dumps(payload, ensure_ascii=False, indent=2), encoding='utf-8')
        print(kind, len(payload['languages']), 'Steam languages packaged', flush=True)


if __name__ == '__main__':
    if '--package' in sys.argv:
        package()
    else:
        sources = prepare()
        with concurrent.futures.ThreadPoolExecutor(max_workers=3) as pool:
            jobs = [pool.submit(translate_language, lang, locale, sources) for lang, locale in LANGUAGES.items()]
            for job in concurrent.futures.as_completed(jobs):
                job.result()
