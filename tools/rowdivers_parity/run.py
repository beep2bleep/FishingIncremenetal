"""Replay identical action tapes against original C# and actual Godot runtime methods.

This is a differential test, not an assertion that substitute physics equals Unity.
Exit 1 means observed behavior differs. All outputs and copied reference code are local.
"""
from pathlib import Path
import argparse, json, random, subprocess, math, sys, importlib.util, contextlib, re
from prepare_reference import ROOT, prepare

PROJECT = ROOT / 'FeedingABlackHoldGame'
CATALOG = PROJECT / 'Games/RowDivers/Data/row_divers.json'

def cases(design):
    result = []
    nodes = design['upgrades']; by_id = {n['id']: n for n in nodes}
    for order in range(3):
        levels = {}; actions = [{'op':'grant','wallet':[1e15]*3}]
        rng = random.Random(5400 + order)
        while True:
            legal = [n for n in nodes if levels.get(n['id'], n['level']) < n['maxLevel'] and
                     (n['isVisible'] or levels.get(n['id'],0)>0 or any(levels.get(p,0)>=n['unlockAtParentLevel'] for p in n['parents']))]
            if not legal: break
            n = legal[0] if order == 0 else legal[-1] if order == 1 else rng.choice(legal)
            actions.append({'op':'buy','id':n['id']}); levels[n['id']] = levels.get(n['id'], n['level']) + 1
        actions += [{'op':'prestige3'}]
        result.append({'id':f'all-upgrades-order-{order}', 'type':'progress','actions':actions})
    sequential = json.loads(json.dumps(result[0]['actions'][:-1]))
    sequential += [{'op':'win','prestige':p} for p in [0,0,1,1,2,3,3]]
    result.append({'id':'consecutive-victory-progression','type':'progress','actions':sequential})
    ending = json.loads(json.dumps(sequential))
    ending += [{'op':'set_wallet','wallet':[199999,10,4]},{'op':'open_final'},{'op':'set_wallet','wallet':[200000,10,4]},{'op':'open_final'},{'op':'open_final'},{'op':'ending','name':'BenevolentGod'},{'op':'ending','name':'EvilGod'}]
    for repeat in range(2):
        ending += [{'op':'claim','name':design['enums']['AchievementType'][str(a['achievementType'])]} for a in design['settings']['achievements']]
    result.append({'id':'complete-unlock-ending-and-reward-sequence','type':'progress','actions':ending})
    for prestige in range(4):
        result.append({'id':f'row-movement-{prestige}','type':'combat','prestige':prestige,
                       'stats':{'MaxHP':10000,'Armor':50,'Armor_Against_Row':25},'actions':[
                           {'op':'tick','frames':120,'horizontal':0.4},{'op':'running'},{'op':'tick','frames':120,'horizontal':-0.4},
                           {'op':'pause','value':True},{'op':'tick','frames':47},
                           {'op':'pause','value':False},{'op':'tick','frames':73}]})
        actions=[]
        for kind in range(7):
            for index in [0,1,15,50]: actions.append({'op':'spawn','id':f'{kind}_{index}','kind':kind,'index':index,'base_hp':80 if kind>=4 else 40})
        result.append({'id':f'enemy-health-{prestige}','type':'combat','prestige':prestige,'actions':actions})
    for name in ['ArrowShield','Harvester','Shuriken','SlowDown']:
        spec=next(a for a in design['settings']['abilities'] if design['enums']['AbilityType'][str(a['abilityType'])]==name)
        result.append({'id':'ability-'+name,'type':'combat','stats':{'MaxHP':100000},'actions':[
            {'op':'ability','name':name},{'op':'tick','frames':60},
            {'op':'pause','value':True},{'op':'tick','frames':23},{'op':'pause','value':False},
            {'op':'tick','frames':round((spec['abilityDuration']-1)*60)+2},
            {'op':'tick','frames':round(spec['cooldownDuration']*60)+2},{'op':'ability','name':name}]})
        result.append({'id':'ability-repeated-'+name,'type':'combat','stats':{'MaxHP':100000},'actions':[
            {'op':'ability','name':name},{'op':'tick','frames':60},{'op':'ability','name':name},
            {'op':'tick','frames':round((spec['abilityDuration']-1)*60)+3}]})
    for kind in ['Arrow','FireArrow','CursedArrow','ShurikenProjectile']:
        for mode in ['uncursed-then-cursed','repeat-burning','repeat-bleeding']:
            stats={'MaxHP':1000,'Arrow_Damage':16,'FireArrow_Damage':10,'CursedArrow_Damage':10,
                   'Curse_Effect':3,'Curse_Chance':100,'Burn_Chance':100,'Burn_Duration':5,
                   'Critic_Chance':0,'HP_Steal_Chance':0,'HealOnHit_Chance':0}
            actions=[{'op':'spawn','id':'target','kind':0,'hp':1e9,'base_hp':40}]
            for i in range(4):
                effect='Cursed' if mode=='uncursed-then-cursed' and i>0 else 'Bleeding' if mode=='repeat-bleeding' else ''
                if effect: actions.append({'op':'effect','enemy':'target','effect':effect,'duration':10})
                elif i>0: actions.append({'op':'expire','enemy':'target'})
                actions.append({'op':'hit','enemy':'target','kind':kind,'pool':'same-projectile','random':[0.5]*8})
            result.append({'id':kind+'-'+mode,'type':'combat','stats':stats,'actions':actions})
    result.append({'id':'life-steal-critical-order','type':'combat','hp':50,'stats':{
        'MaxHP':100,'Arrow_Damage':16,'Critic_Chance':100,'Critic_Damage':3,'HP_Steal_Chance':100,
        'HP_Steal':7,'HealOnHit_Chance':100,'HealOnHit_Amount':4},'actions':[
            {'op':'spawn','id':'target','kind':6,'base_hp':80,'hp':1e9},
            {'op':'hit','kind':'Arrow','pool':'a','enemy':'target','random':[0.5]*8}]})
    result.append({'id':'boss-finishing-life-steal-reentry','type':'combat','hp':50,'stats':{
        'MaxHP':100,'Arrow_Damage':16,'Critic_Chance':100,'Critic_Damage':3,'HP_Steal_Chance':100,
        'HP_Steal':7,'HealOnHit_Chance':100,'HealOnHit_Amount':4},'actions':[
            {'op':'spawn','id':'target','kind':6,'base_hp':80,'hp':5},
            {'op':'hit','kind':'Arrow','pool':'a','enemy':'target','random':[0.5]*8}]})
    for prestige in range(4):
        for kind in range(4):
            result.append({'id':f'enemy-arrow-{prestige}-{kind}','type':'combat','prestige':prestige,
                           'hp':90000,'armor':70,'stats':{'MaxHP':100000,'HP_Steal':7},'actions':[
                               {'op':'enemy_arrow','kind':kind},{'op':'tick','frames':1},
                               {'op':'tick','frames':60},{'op':'tick','frames':60}]})
    for kind in range(4):
        result.append({'id':f'arrow-shield-block-{kind}','type':'combat','actions':[
            {'op':'ability','name':'ArrowShield'},{'op':'enemy_arrow','kind':kind}]})
    result.append({'id':'harvester-wallet','type':'combat','actions':[
        {'op':'loot','currency':0,'amount':10},{'op':'loot','currency':1,'amount':2},
        {'op':'ability','name':'Harvester'},{'op':'loot','currency':0,'amount':10},
        {'op':'loot','currency':1,'amount':2},{'op':'loot','currency':2,'amount':1}]})
    for weapon in ['dagger','beam']:
        for effect in ['', 'Cursed', 'Burning', 'Bleeding']:
            for boss in [False,True]:
                actions=[{'op':'spawn','id':'target','kind':6 if boss else 0,'hp':1e9,'base_hp':80 if boss else 40}]
                if effect: actions.append({'op':'effect','enemy':'target','effect':effect,'duration':5})
                actions.append({'op':weapon,'enemy':'target'})
                result.append({'id':f'{weapon}-{effect or "plain"}-{boss}','type':'combat','stats':{
                    'Dagger_Damage':20,'Bleed_Chance':100,'Burn_Duration':5,'Curse_Effect':3,
                    'Beam_Damage':30,'Beam_Critic_Chance':100,'Beam_Critic_Multiplier':17,'Damage_Against_Bosses':7},'actions':actions})
    return result

def differences(a,b,path=''):
    if isinstance(a,dict) and isinstance(b,dict):
        for key in sorted(set(a)|set(b)):
            if key not in a or key not in b: yield path+'.'+key,a.get(key,'<missing>'),b.get(key,'<missing>')
            else: yield from differences(a[key],b[key],path+'.'+key)
    elif isinstance(a,list) and isinstance(b,list):
        if len(a)!=len(b): yield path+'.length',len(a),len(b)
        for i,(x,y) in enumerate(zip(a,b)): yield from differences(x,y,path+f'[{i}]')
    elif isinstance(a,(float,int)) and not isinstance(a,bool) and isinstance(b,(float,int)) and not isinstance(b,bool):
        if not math.isclose(a,b,rel_tol=1e-12 if path.endswith('.hp') else 2e-6,abs_tol=2e-5): yield path,a,b
    elif a!=b: yield path,a,b

def run(args):
    work=args.work.resolve();work.mkdir(parents=True,exist_ok=True)
    design=json.loads(CATALOG.read_text(encoding='utf-8'))
    spec=importlib.util.spec_from_file_location('row_divers_importer',ROOT/'tools/import_row_divers.py')
    importer=importlib.util.module_from_spec(spec);spec.loader.exec_module(importer)
    importer.DEST=work/'source-design'
    with (work/'import.log').open('w') as log, contextlib.redirect_stdout(log): importer.run(args.source)
    reference_catalog=importer.DEST/'row_divers.json'
    source_design=json.loads(reference_catalog.read_text(encoding='utf-8'))
    design_mismatches=list(differences({k:v for k,v in source_design.items() if k!='source'},{k:v for k,v in design.items() if k!='source'}))
    tape=cases(source_design)
    tape_path=work/'inputs.json';tape_path.write_text(json.dumps(tape))
    dll=prepare(args.source,work/'reference')
    subprocess.run(['dotnet',str(dll),str(reference_catalog),str(tape_path),str(work/'reference.json')],check=True)
    with (work/'godot.log').open('w') as log:
        subprocess.run([str(ROOT/'Godot/Godot_v4.6-stable_win64_console.exe'),'--headless','--path',str(PROJECT),'--rendering-method','gl_compatibility','--script','res://Games/RowDivers/Tools/ReplayRowDiversParity.gd','--',str(tape_path),str(work/'railway.json')],stdout=log,stderr=subprocess.STDOUT,check=True,timeout=240)
    if 'SCRIPT ERROR:' in (work/'godot.log').read_text(errors='replace'): raise RuntimeError('Godot replay script failed; inspect '+str(work/'godot.log'))
    ref=json.loads((work/'reference.json').read_text());actual=json.loads((work/'railway.json').read_text())
    assert len(ref)==len(actual)==len(tape), 'A replay omitted cases'
    reports=[]
    for case,a,b in zip(tape,ref,actual):
        ds=list(differences(a,b));first_index=int(ds[0][0].split('[',1)[1].split(']',1)[0]) if ds and '.snapshots[' in ds[0][0] else None
        reports.append({'first_divergent_action':case['actions'][first_index] if first_index is not None else None,'id':case['id'],'actions':len(case['actions']),'difference_count':len(ds),'first_differences':[{'path':p,'row_divers':x,'railway_fury':y} for p,x,y in ds[:12]]})
    report={'exact_end_to_end_certified':False,'unverified':['Unity native collision and rigidbody solver; adapters do not reproduce geometry','Raw key-to-Input.GetAxis smoothing, actual render/fixed/coroutine scheduling','Full original projectile flight, raycasts, shuffle and section selection RNG','Original full-campaign gameplay and a natural fresh-save grind; component and victory-event replays are not a substitute'],'source_design_mismatches':len(design_mismatches),'cases':len(reports),'passing':sum(r['difference_count']==0 for r in reports),'failing':sum(r['difference_count']>0 for r in reports),'numeric_tolerance':{'relative':2e-6,'absolute':2e-5,'health_relative':1e-12},'results':reports}
    report['action_checkpoints']=sum(r['actions'] for r in reports)
    report['original_source_sha256']=json.loads((work/'reference/source_manifest.json').read_text())
    if args.self_test:
        # Change only the ignored build copy, then restore it even if validation fails.
        arrow=work/'reference/Arrow.cs';original=arrow.read_bytes()
        try:
            text=original.decode('utf-8-sig')
            needle='_baseDamage = Stats.GetCurrentStat(Stat.Arrow_Damage);'
            assert text.count(needle)==1
            arrow.write_text(text.replace(needle,needle[:-1]+' + 1.0;'))
            subprocess.run(['dotnet','build',str(work/'reference/Reference.csproj'),'-v:q','--nologo'],check=True)
            mutated=work/'reference-mutated.json'
            subprocess.run(['dotnet',str(dll),str(reference_catalog),str(tape_path),str(mutated)],check=True)
            mutant=json.loads(mutated.read_text())
            detected=sum(bool(list(differences(x,y))) for x,y in zip(mutant,actual))
            assert detected>0,'Harness failed to detect injected arrow damage error'
            report['harness_self_test']={'injected_error':'original Arrow base damage +1 in ignored copy','detected_by_cases':detected,'passed':True}
        finally:
            arrow.write_bytes(original)
            subprocess.run(['dotnet','build',str(work/'reference/Reference.csproj'),'-v:q','--nologo'],check=True)
    if args.campaign:
        with (work/'campaign.log').open('w') as log:
            subprocess.run([str(ROOT/'Godot/Godot_v4.6-stable_win64_console.exe'),'--headless','--path',str(PROJECT),'--rendering-method','gl_compatibility','--script','res://Games/RowDivers/Tools/VerifyRowDiversCampaign.gd'],stdout=log,stderr=subprocess.STDOUT,check=True,timeout=240)
        campaign=(work/'campaign.log').read_text(errors='replace')
        if 'SCRIPT ERROR:' in campaign or 'CAMPAIGN PASSED:' not in campaign: raise RuntimeError('Campaign did not pass; inspect campaign.log')
        report['railway_consecutive_campaign']={'passed':True,'rows':re.findall(r'Prestige [0-3]:[^\r\n]*',campaign),'reference_full_campaign_compared':False}
    (work/'report.json').write_text(json.dumps(report,indent=2))
    for r in reports:print(('FAIL' if r['difference_count'] else 'PASS'),r['id'],r['difference_count'])
    print(json.dumps({k:report[k] for k in ['cases','passing','failing','action_checkpoints','source_design_mismatches','exact_end_to_end_certified']}));return 1 if report['failing'] or design_mismatches else 2 if args.require_end_to_end else 0

if __name__=='__main__':
    parser=argparse.ArgumentParser();parser.add_argument('--source',type=Path,default=Path(r'C:\Decompiled\Row Divers\ExportedProject'))
    parser.add_argument('--work',type=Path,default=ROOT/'.validation/rowdivers-parity')
    parser.add_argument('--campaign',action='store_true',help='Also run Railway Fury\'s consecutive four-row gameplay fixture')
    parser.add_argument('--self-test',action='store_true',help='Verify detection of a deliberate error in a temporary original-code copy')
    parser.add_argument('--require-end-to-end',action='store_true',help='Exit 2 while full original campaign/native physics coverage is unverified')
    sys.exit(run(parser.parse_args()))
