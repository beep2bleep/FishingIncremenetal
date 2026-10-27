"""Create value-only tree variants and compare full campaign traces."""
from pathlib import Path
from copy import deepcopy
from collections import Counter
from statistics import mean
import json
import argparse
import hashlib
import shutil

ROOT = Path(__file__).resolve().parents[2]
MODULE = ROOT / 'FeedingABlackHoldGame/Games/RowDivers'
EXPERIMENTS = MODULE / 'Simulation/Tuning'

PROFILES = {
    'control': {},
    'gentle': dict(arrow=.70, beam=.90, dagger=.80, health=1.45, bow_rate=.85, dagger_rate=.70, range=.25, price=.95),
    'close': dict(arrow=.45, beam=.78, dagger=.55, health=1.80, bow_rate=.65, dagger_rate=.45, range=.10, price=.90),
    'smooth': dict(arrow=.58, beam=.85, dagger=.65, health=1.65, bow_rate=.75, dagger_rate=.55, range=.15, price=1.00),
    'steady': dict(arrow=.70, beam=.90, dagger=.70, health=1.45, bow_rate=.85, dagger_rate=.70, range=.25, price=.95, impact=55, early_hp=8),
    'steady_close': dict(arrow=.58, beam=.85, dagger=.65, health=1.55, bow_rate=.75, dagger_rate=.55, range=.15, price=.95, impact=60, early_hp=8),
    'guarded': dict(arrow=.60, beam=.90, dagger=.47, health=1.45, bow_rate=.85, dagger_rate=.70, range=.25, price=.95, impact=55, early_hp=8, triples=True),
    'guarded_plus': dict(arrow=.60, beam=.90, dagger=.47, health=1.45, bow_rate=.85, dagger_rate=.70, range=.25, price=.95, impact=65, early_hp=8, triples=True),
    'gates': dict(arrow=.60, beam=.90, dagger=.47, health=1.35, bow_rate=.85, dagger_rate=.70, range=.25, price=.95, impact=55, early_hp=8, triples=True, gates=True),
    'gates_light': dict(arrow=.66, beam=.95, dagger=.50, health=1.35, bow_rate=.90, dagger_rate=.75, range=.25, price=1.00, impact=45, early_hp=8, triples=True, gates=True),
    'balanced': dict(arrow=.70, beam=.95, dagger=.55, health=1.35, bow_rate=.90, dagger_rate=.75, range=.25, price=1.10, impact=85, early_hp=6, triples=True, gates=True),
    'balanced_edge': dict(arrow=.65, beam=.90, dagger=.50, health=1.40, bow_rate=.85, dagger_rate=.70, range=.20, price=1.05, impact=80, early_hp=6, triples=True, gates=True),
    'balanced_safe': dict(arrow=.75, beam=.95, dagger=.60, health=1.30, bow_rate=.95, dagger_rate=.80, range=.25, price=1.15, impact=90, early_hp=6, triples=True, gates=True),
    'ladder': dict(arrow=.70, beam=.95, dagger=.55, health=1.35, bow_rate=.90, dagger_rate=.75, range=.25, price=1.20, impact=85, early_hp=6, triples=True, gates=True, ladder=True),
    'release': dict(arrow=.70, beam=.95, dagger=.55, health=1.35, bow_rate=.90, dagger_rate=.75, range=.25, price=1.10, impact=85, early_hp=6, triples=True, gates=True, final_arrow=200000),
}

def variant(original, profile):
    data = deepcopy(original)
    if not profile:
        return data
    for node in data['upgrades']:
        for effect in node['effects']:
            stat, amount = effect['stat'], effect['amount']
            if stat == 'Arrow_Damage':
                # Keep the starter upgrade attractive; taper the later large jumps.
                factor = 1 if node['upgradeName'] == 'Arrow Damage I' else profile['arrow']
                if effect['percentage']:
                    factor = 1 if profile.get('triples') else .8 + .2 * factor
                effect['amount'] = round(amount * factor, 4)
            elif stat == 'Beam_Damage':
                effect['amount'] = round(amount * profile['beam'], 4)
            elif stat == 'Dagger_Damage':
                factor = profile['dagger'] if not effect['percentage'] else (1 if profile.get('triples') else .9)
                effect['amount'] = round(amount * factor, 4)
            elif stat == 'MaxHP':
                # Small early steps; progressively larger late survival budget.
                factor = 1 if amount <= 15 else (1.05 if amount <= 60 else profile['health'])
                effect['amount'] = round(amount * factor, 4)
                if node['upgradeName'] == 'Max HP I' and 'early_hp' in profile:
                    effect['amount'] = profile['early_hp']
            elif stat == 'Bow_Fire_Rate':
                effect['amount'] = round(amount * profile['bow_rate'], 4)
            elif stat == 'Dagger_Attack_Rate':
                effect['amount'] = round(amount * profile['dagger_rate'], 4)
            elif stat in ('Distance_Range', 'Melee_range'):
                effect['amount'] = round(amount * profile['range'], 4)
            elif stat == 'Impact_Armor' and 'impact' in profile:
                effect['amount'] = profile['impact']
        if 'impact' in profile and node['upgradeName'] == 'Armor I':
            node['unlockAtParentLevel'] = 4
        if profile.get('triples') and node['upgradeName'] == 'Impact Armor I':
            node['baseUpgradeCost'] = 12
            node['unlockAtParentLevel'] = 1
        if profile.get('gates'):
            if node['upgradeName'] == 'Impact Armor I':
                node['baseUpgradeCost'] = 4
                node['unlockAtParentLevel'] = 0
            boss_tiers = {'Damage Against Bosses I': (100, 2), 'Damage Against Bosses II': (6000, 15),
                          'Damage Against Bosses III': (400000, 600), 'Damage Against Bosses IV': (200000000, 6000)}
            if node['upgradeName'] in boss_tiers:
                amount, price = boss_tiers[node['upgradeName']]
                node['effects'][0]['amount'] = amount
                node['baseUpgradeCost'] = price
        if profile.get('ladder'):
            if node['upgradeName'] == 'Triples Dagger Damage I': node['baseUpgradeCost'] = 600
            if node['upgradeName'] == 'Triples Dagger Damage II': node['baseUpgradeCost'] = 2500
        if profile.get('final_arrow') and node['upgradeName'] == 'Arrow Damage VIII':
            node['effects'][0]['amount'] = profile['final_arrow']
        if node['cost']['currencyType'] == 0:
            node['baseUpgradeCost'] = max(1, round(node['baseUpgradeCost'] * profile['price']))
    return data

def metrics(data):
    runs = data['runs']
    kills = [k for r in runs for k in r['kill_records']]
    advances, reversals, comparable = 0, 0, 0
    deltas = []
    cleared = set()
    for prior, current in zip(runs, runs[1:]):
        if prior['won'] or prior['loot'][2] > 0: cleared.add(prior['prestige'])
        if prior['prestige'] != current['prestige'] or prior['prestige'] in cleared:
            continue
        comparable += 1
        delta = (300 if current['won'] or current['loot'][2] > 0 else current['distance']) - prior['distance']
        deltas.append(delta)
        advances += delta > .25
        reversals += delta < -.25
    buys = Counter(c['after_run'] for c in data['choices'])
    clears = {}
    for p in range(4):
        subset = [r for r in runs if r['prestige'] == p]
        clears[str(p)] = next((i+1 for i, r in enumerate(subset) if r['won'] or r['loot'][2] > 0), None)
    failed = [r for r in runs if not r['won']]
    return {
        'completed': data.get('completed', False), 'runs': len(runs), 'first_clears': clears,
        'purchases': len(data['choices']),
        'runs_with_purchase_after': sum(buys[r['run']] > 0 for r in runs),
        'no_purchase_runs': [r['run'] for r in runs if not buys[r['run']]],
        'comparable_transitions': comparable, 'advances': advances, 'regressions': reversals,
        'flat_transitions': comparable - advances - reversals,
        'advance_fraction': advances / max(1, comparable),
        'mean_distance_delta': mean(deltas) if deltas else 0,
        'close_kill_fraction': mean(k['range'] <= 2 for k in kills) if kills else 0,
        'runs_with_close_kills': sum(any(k['range'] <= 2 for k in r['kill_records']) for r in runs),
        'far_kill_fraction': mean(k['range_fraction'] >= .8 for k in kills) if kills else 0,
        'contact_deaths': sum(r['death_source'] == 'enemy contact' for r in failed),
        'row_only_deaths': sum(r['death_source'] == 'the row' and not r['damage_sources'].get('enemy contact', 0) for r in failed),
        'capped': sum(r['capped'] for r in runs), 'seconds': data.get('wall_seconds', 0),
    }

def generate():
    EXPERIMENTS.mkdir(exist_ok=True)
    source = EXPERIMENTS / 'SourceSnapshot'
    if (source/'manifest.json').exists():
        raise SystemExit('The captured baseline is immutable. Reuse its existing catalogs/snapshot, or choose a new experiment directory for a new baseline.')
    source.mkdir(exist_ok=True)
    for filename, rel in [('RowDiversTiming.gd.txt', 'RowDiversTiming.gd'), ('GeneratedCombatModel.gd.txt', 'Simulation/GeneratedCombatModel.gd'), ('RunBalanceCampaign.gd.txt', 'Simulation/RunBalanceCampaign.gd'), ('RowDiversProgress.gd.txt', 'RowDiversProgress.gd'), ('row_divers.json', 'Data/row_divers.json'), ('RowDiversBattleScene.gd.txt', 'Scenes/RowDiversBattleScene.gd')]:
        shutil.copyfile(MODULE / rel, source / filename)
    manifest = {p.name: hashlib.sha256(p.read_bytes()).hexdigest() for p in source.iterdir() if p.is_file()}
    (source / 'manifest.json').write_text(json.dumps(manifest, indent=2))
    original = json.loads((source / 'row_divers.json').read_text())
    for name, profile in PROFILES.items():
        folder = EXPERIMENTS / name
        folder.mkdir(exist_ok=True)
        catalog = variant(original, profile)
        (folder / 'catalog.json').write_text(json.dumps(catalog, indent=2))
        (folder / 'config.json').write_text(json.dumps(dict(seed=2401026, max_runs=90, shortlist=3,
            ending_reserve=True, weights=dict(distance=.75, gold_rate=.18, gem_rate=.07)), indent=2))
    print(EXPERIMENTS)

def summarize():
    results = {}
    for path in EXPERIMENTS.glob('*/campaign*.json'):
        data = json.loads(path.read_text())
        if data.get('runs'):
            results[str(path.relative_to(EXPERIMENTS))] = metrics(data)
    (EXPERIMENTS / 'comparison.json').write_text(json.dumps(results, indent=2))
    print(json.dumps(results, indent=2))

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('action', choices=['generate', 'summarize'])
    args = parser.parse_args()
    generate() if args.action == 'generate' else summarize()
