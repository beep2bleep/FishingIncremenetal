"""Verify the completed trace's currency, level, kill and ending accounting."""
from pathlib import Path
from math import isclose
import json

ROOT = Path(__file__).resolve().parents[2]
directory = ROOT / 'FeedingABlackHoldGame/Games/RowDivers/Simulation/Results'
data = json.loads((directory / 'fresh_campaign.json').read_text())
catalog = json.loads((directory / 'SourceSnapshot/row_divers.json').read_text())
nodes = {n['id']: n for n in catalog['upgrades']}
checks = {}
checks['completed'] = data['completed'] and data['final_state']['god_panel_unlocked']
checks['all_four_crowns'] = all(data['final_state']['crowns_dropped'].get(str(p)) for p in range(4))
checks['no_time_caps'] = not any(r['capped'] for r in data['runs'])
checks['no_arrow_damage'] = not any(r['damage_sources'].get('enemy arrows', 0) for r in data['runs'])
checks['all_kills_recorded'] = all(r['kills'] == len(r['kill_records']) for r in data['runs'])
checks['all_purchases_affordable'] = all(c['wallet_before'][c['currency']] >= c['price'] for c in data['choices'])
checks['levels_within_caps'] = all(0 <= level <= nodes[node]['maxLevel'] for node, level in data['final_state']['levels'].items())
checks['at_least_100_maxed_nodes'] = sum(data['final_state']['levels'].get(n['id'], 0) == n['maxLevel'] for n in nodes.values()) >= 100
for currency, entry_fee in enumerate([200000, 10, 4]):
    income = sum(r['loot'][currency] for r in data['runs'])
    rewards = sum(c['reward'] for c in data['claims'] if c['currency'] == currency)
    purchases = sum(c['price'] for c in data['choices'] if c['currency'] == currency)
    expected = data['initial_state']['wallet'][currency] + income + rewards - purchases - entry_fee
    checks[f'currency_{currency}_balances'] = isclose(expected, data['final_state']['wallet'][currency], abs_tol=1e-6)
    checks[f'currency_{currency}_spend_matches'] = isclose(purchases + data['initial_state']['spent'][currency], data['final_state']['spent'][currency], abs_tol=1e-6)
result = {'passed': all(checks.values()), 'checks': checks}
(directory / 'accounting_validation.json').write_text(json.dumps(result, indent=2))
print(json.dumps(result, indent=2))
raise SystemExit(0 if result['passed'] else 1)
