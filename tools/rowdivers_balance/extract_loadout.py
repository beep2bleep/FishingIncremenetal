"""Extract the combat loadout before a recorded run, preserving purchase order."""
from pathlib import Path
from copy import deepcopy
import argparse
import json

ROOT = Path(__file__).resolve().parents[2]

def extract(trace, number):
    state = deepcopy(trace['initial_state'])
    catalog = json.loads((ROOT / 'FeedingABlackHoldGame/Games/RowDivers/Data/row_divers.json').read_text())
    nodes = {n['id']: n for n in catalog['upgrades']}
    for choice in trace['choices']:
        if choice['after_run'] >= number:
            break
        node = nodes[choice['id']]
        assert state['levels'].get(node['id'], node['level']) == choice['level_before']
        state['levels'][node['id']] = choice['level_before'] + 1
        state['spent'][choice['currency']] += choice['price']
        if node['unlocks']:
            for kind in ['weaponType', 'fireType', 'tabType', 'abilityType']:
                if kind in node['unlocks']:
                    state['unlocks'][node['unlocks'][kind]] = True
                    break
        else:
            for effect in node['effects']:
                old = state['stats'].get(effect['stat'], 0.0)
                amount = old * effect['amount'] / 100 if effect['percentage'] and old > 0 else effect['amount']
                state['stats'][effect['stat']] = old + amount
    run = trace['runs'][number-1]
    assert state['levels'] == run['upgrade_levels'], 'Loadout levels do not reproduce the trace'
    state['wallet'] = run['wallet_before']
    state['prestige'] = run['prestige']
    state['max_prestige'] = run['prestige']
    state['controls_seen'] = True
    state['crowns_dropped'].update({str(r['prestige']): True for r in trace['runs'][:number-1] if r['won']})
    state['runs'] += number-1
    return state

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('trace', type=Path)
    parser.add_argument('--run', type=int, required=True)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    args.output.write_text(json.dumps(extract(json.loads(args.trace.read_text()), args.run), indent=2))
