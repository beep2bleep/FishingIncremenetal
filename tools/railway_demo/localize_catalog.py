"""Prepare Steam catalog localization, preserving source markup and assets.

Inputs are exports downloaded through Steamworks. Uploads use Steamworks UI.
Draft translation operates on plain text; markup and asset URLs never leave
the document model. Edited short descriptions and overrides live separately.
"""
import concurrent.futures
import json
import pathlib
import re
import time

import localize

ROOT = pathlib.Path(__file__).resolve().parents[2]
OUT = ROOT / 'StoreLocalization' / 'catalog-2026-10-28'
LANGS = dict(french='fr', italian='it', german='de', spanish='es', czech='cs',
             indonesian='id', japanese='ja', koreana='ko', polish='pl',
             portuguese='pt-PT', brazilian='pt-BR', russian='ru', schinese='zh',
             thai='th', turkish='tr', vietnamese='vi')
ABOUT = 'app[content][about]'
SHORT = 'app[content][short_description]'
TAGS = re.compile(r'\[[^\]]*\]')
BRANDS = ['Bleepware Incrementals', 'BleepWare Incrementals', 'Vanguard - Idle Auto Battle',
          'Vanguard', 'Deepcore', 'Red Sky Defense', 'Turkey', 'Reel Into the Darkness',
          'Data Breach Inc.', 'Defeat Demo', 'XP', 'PvE']
localize.TOKEN = re.compile('|'.join(re.escape(x) for x in sorted(BRANDS,key=len,reverse=True)) + r'|\d+(?:[.,]\d+)*')

# Straightforward source phrasing disambiguates game terminology and idioms.
# The English store fields themselves are never changed.
EDITORIAL = {
    'Drive the rig. Bank the ore. Build the next better dive.':
        'Drive the drilling vehicle. Return your ore to base. Upgrade your equipment for the next expedition.',
    'Deepcore is a run-based mining incremental built around short, high-pressure dives. Steer a drill rig through destructible underground terrain, break open ore, and get the haul back to the base ring before the timer expires, the drill burns out, or cargo pressure ends the push.':
        'Deepcore is a mining game with incremental progression and short, intense underground expeditions. Drive a drilling vehicle through destructible underground terrain, extract ore, and bring your haul back to the base ring before time runs out, the drill wears out, or your cargo reaches its limit.',
    'Why It Feels Good': 'Satisfying Progression',
    'Every upgrade shows up quickly. The rig moves cleaner, the drill lasts longer, cargo runs get smoother, and deeper layers stop feeling impossible. Deepcore keeps the runs short enough to stay readable while the campaign keeps widening underneath them.':
        'You quickly feel the effect of each upgrade. Your drilling vehicle handles better, your drill lasts longer, transporting cargo becomes easier, and deeper layers become accessible. Deepcore offers short, manageable expeditions within an expanding campaign.',
    'A run-based mining incremental where you steer a drill rig, bank ore, unlock deeper tiers, and turn fast dives into permanent upgrades.':
        'A mining game with incremental progression: drive a drilling vehicle, return ore to base, unlock deeper layers, and invest the rewards from short expeditions in permanent upgrades.',
    'Your team fights automatically. Your decisions determine how far it goes.':
        'Your team fights automatically. Your decisions determine how far your team advances.',
    'Vanguard - Idle Auto Battle combines real-time auto combat with persistent incremental progression. Build your lineup, trigger hero actives at key moments, and convert every run into lasting power.':
        'Vanguard - Idle Auto Battle combines automatic real-time combat with permanent incremental progression. Build your team, use your heroes’ active abilities at key moments, and invest the rewards from every battle attempt in lasting improvements.',
    'Manage power economy for high-impact active abilities':
        'Manage your power resource to use powerful active abilities',
    'Push through escalating waves into boss phases':
        'Defeat increasingly difficult enemy waves and advance to boss phases',
    'Invest run rewards into permanent upgrades':
        'Invest battle rewards in permanent upgrades',
    'Refine your build for faster and safer clears':
        'Optimize your team and upgrades to win faster and more safely',
    'Auto battle combat loop with meaningful tactical decisions':
        'Automatic battles with meaningful tactical decisions',
    'Four heroes with distinct play patterns and active powers':
        'Four heroes with distinct play styles and active abilities',
    'Boss fights with segment-style progression pressure':
        'Boss battles with progression divided into challenging segments',
    'Session-friendly progression pacing with speed control support':
        'Progression suited to short play sessions, with adjustable game speed',
    'Single-player progression built for repeat runs and optimization':
        'Single-player progression designed for repeated battle attempts and optimization',
    'Why It Is Addictive': 'Always Another Improvement',
    'Every run gives clear growth. Every upgrade changes performance. Every active timing choice can rescue a push or accelerate a snowball. You are always one optimization away from a bigger clear.':
        'Every battle attempt brings visible progress, and every upgrade improves your performance. Using an active ability at the right moment can save a difficult battle or help your team grow stronger faster. Another improvement can always help you advance further.',
    'Build optimization and scaling loops': 'Optimizing teams and steadily increasing their strength',
    'PvE strategy with low mechanical overhead': 'PvE strategy without demanding complex controls',
    'An idle auto battler where your squad fights continuously while you optimize upgrades, trigger hero actives, and break through boss phases.':
        'An idle auto battler: your team fights continuously while you optimize upgrades, use heroes’ active abilities, and advance through boss phases.',
    'Data Breach Inc. is an arcade incremental about breaking into hostile corporate infrastructure one risky sortie at a time. Pilot a breach rig, mine the firewall for resources, crack daemon cores, extract before the run turns ugly, and use the payout to make the next breach go deeper.':
        'Data Breach Inc. is an arcade action game with incremental progression. Break into hostile corporate infrastructure through dangerous missions. Pilot a hacking vehicle, mine the firewall for resources, destroy daemon cores, escape before the mission becomes too dangerous, and use your earnings to penetrate deeper next time.',
    'Every flight is part action run, part upgrade puzzle. You choose how hard to push: carve a safe route, chase valuable blocks, pressure a daemon core, or turn back early and bank the haul. Money, XP, and root kernels feed permanent upgrades for damage, attack speed, cargo, fuel, drones, range, payout scaling, and core-cracking power.':
        'Each flight combines action with upgrade strategy. Choose how much to risk: create a safe route, pursue valuable blocks, attack a daemon core, or return early to secure your haul. Spend money, XP, and root kernels on permanent upgrades to damage, attack speed, cargo, fuel, drones, range, earnings, and damage against cores.',
    'The firewall does not sit still. Deeper layers hit harder, daemon cores fight back, and defensive pressure forces cleaner routes instead of mindless grinding. Learn the layout, tune your rig, and turn messy extraction runs into faster clears.':
        'The firewall actively resists you. Deeper layers are more dangerous, daemon cores fight back, and enemy defenses demand efficient routes rather than repetitive resource gathering. Learn the layout, upgrade your hacking vehicle, and complete extraction missions more efficiently.',
    'The demo is built around defeating the demo breach and chasing a cleaner time on the Defeat Demo leaderboard. The full Data Breach Inc. structure also connects side operations into the campaign, including Red Sky Defense and Deepcore, with resources and unlocks feeding back into the central breach.':
        'In the demo, complete the hacking challenge and try to improve your time on the Defeat Demo leaderboard. The full Data Breach Inc. campaign also includes side operations such as Red Sky Defense and Deepcore. Resources and unlocks from those operations contribute to the main hacking campaign.',
    'Arcade breach sorties built around mining, movement, survival, and extraction':
        'Arcade hacking missions combining mining, movement, survival, and extraction',
    'Demo clear target with leaderboard-ready timing': 'A demo completion challenge with timed leaderboard results',
    'Short runs with long-term incremental progression': 'Short missions with long-term incremental progression',
    'Pilot a breach rig into hostile corporate infrastructure. Mine the firewall, crack daemon cores, extract your haul, and buy permanent upgrades between sorties.':
        'Pilot a hacking vehicle into hostile corporate infrastructure. Mine the firewall, destroy daemon cores, escape with your haul, and buy permanent upgrades between missions.',
}


def normalized(text):
    text = text.strip()
    if text.startswith('- '):
        bullet=text[2:]
        bullet_overrides={
            'Persistent firewall progress across runs': 'Your progress through the firewall is preserved between missions',
            'Arcade breach sorties built around mining, movement, survival, and extraction': 'Arcade hacking missions: mine resources, move, survive, and escape with your haul',
            'Daemon core encounters with escalating defensive pressure': 'Battles against daemon cores with increasingly powerful defenses',
            'Permanent upgrades for damage, speed, cargo, fuel, drones, range, payouts, and core damage': 'Permanent upgrades to damage, speed, cargo capacity, fuel, drones, range, earnings, and damage against cores',
            'Connected side operations in the full Data Breach Inc. structure': 'Side operations connected to the main campaign in the full Data Breach Inc. game',
        }
        return '- '+bullet_overrides.get(bullet, EDITORIAL.get(bullet,bullet))
    if text in EDITORIAL:
        return EDITORIAL[text]
    replacements = {
        'underground industry': 'industry beneath the ground',
        '• Pilot a drill rig through destructible underground routes': '• Drive a drilling vehicle through destructible underground terrain',
        '• Manage timer pressure, drill depletion, and cargo limits during each dive': '• Manage limited time, drill durability, and cargo capacity during each expedition',
        '• Collect ore and bank it for money and XP': '• Return collected ore to base to earn money and XP',
        '• Unlock deeper depth tiers with tougher layers and better payouts': '• Unlock deeper layers with harder terrain and better rewards',
        '• Invest returns into permanent upgrades and drone support': '• Invest earnings in permanent upgrades and support drones',
        '• Fast run-based mining loop with strong repeat-dive momentum': '• Short mining expeditions that let you steadily progress with each attempt',
        '• Permanent upgrades for engine tuning, drill torque, plating, cooling, cargo, ore value, XP, and route efficiency': '• Permanent upgrades to the engine, drill torque, armor plating, cooling, cargo capacity, ore value, XP, and route efficiency',
        '• Readable end-of-run summaries with payout, XP, and performance feedback': '• Clear expedition summaries showing earnings, XP, and performance',
        '• Short runs with persistent upgrades': '• Short expeditions with permanent upgrades',
        '• Optimization-focused single-player loops': '• Single-player gameplay focused on optimization',
        'money and XP': 'money and XP',
        'defensive pressure': 'enemy defenses',
        'core-cracking power': 'damage against cores',
        'payout scaling': 'increasing earnings',
    }
    for a,b in replacements.items():
        text = text.replace(a,b)
    return text


def segments(value):
    return [s for s in TAGS.split(value) if s.strip() and re.search('[A-Za-z]',s)]


def transform(value, translations):
    parts = re.split(r'(\[[^\]]*\])',value)
    for n,text in enumerate(parts):
        if text.startswith('[') or not text.strip() or not re.search('[A-Za-z]',text):
            continue
        lead=text[:len(text)-len(text.lstrip())]
        tail=text[len(text.rstrip()):]
        parts[n]=lead+translations[normalized(text)]+tail
    return ''.join(parts)


def translate_language(language, strings):
    path=OUT/(language+'_draft.json')
    cache=json.loads(path.read_text(encoding='utf8')) if path.exists() else {}
    batch=[]
    batches=[]
    for value in strings:
        if value in cache: continue
        if batch and sum(len(s)+25 for s in batch)+len(value)>2600:
            batches.append(batch); batch=[]
        batch.append(value)
    if batch: batches.append(batch)
    for batch in batches:
        for attempt in range(4):
            try:
                cache.update(localize.request_batch(LANGS[language], batch))
                break
            except Exception:
                if attempt==3: raise
                time.sleep(1+attempt)
        path.write_text(json.dumps(cache,ensure_ascii=False,indent=2),encoding='utf8')
    print(language,'drafted',len(cache),'segments',flush=True)
    return cache


def build():
    catalog=json.loads((OUT/'catalog.json').read_text())
    for row in catalog:
        if not row.get('download'): continue
        original=json.loads((OUT/(row['itemid']+'_before.json')).read_text(encoding='utf8'))
        english=original['languages']['english']
        output={'itemid':row['itemid'],'languages':{}}
        for language in row['supported']:
            if language=='english': continue
            cache=json.loads((OUT/(language+'_draft.json')).read_text(encoding='utf8'))
            fields={}
            for key,value in english.items():
                if key in [ABOUT,SHORT]:
                    fields[key]=transform(value,cache)
                else:
                    # These exported requirements contain only product names,
                    # versions and hardware units, with no prose to translate.
                    fields[key]=value
            output['languages'][language]=fields
        (OUT/(row['itemid']+'_upload.json')).write_text(json.dumps(output,ensure_ascii=False,indent=2),encoding='utf8')


if __name__=='__main__':
    strings=set()
    for path in OUT.glob('*_before.json'):
        data=json.loads(path.read_text(encoding='utf8'))['languages']['english']
        strings.update(normalized(s) for k,v in data.items() if k in [ABOUT,SHORT] for s in segments(v))
    # Proper titles need no translation. Keep their original spelling exactly.
    print(len(strings),'unique source segments',flush=True)
    with concurrent.futures.ThreadPoolExecutor(max_workers=3) as pool:
        jobs=[pool.submit(translate_language,l,sorted(strings)) for l in LANGS]
        for job in concurrent.futures.as_completed(jobs): job.result()
    build()
