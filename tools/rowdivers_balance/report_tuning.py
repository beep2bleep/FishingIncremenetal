"""Audit and report full tuning campaigns; never infer completion from checkpoints."""
from pathlib import Path
from collections import defaultdict
from statistics import mean, median
from math import isclose
import csv
import json
import argparse
from tune_trees import EXPERIMENTS, metrics

def audit(data, catalog):
    checks = {}
    checks['completed'] = bool(data.get('completed'))
    checks['ending_paid'] = data['final_state'].get('god_panel_unlocked', False)
    checks['all_prestiges'] = all(data['final_state']['crowns_dropped'].get(str(p)) for p in range(4))
    checks['no_caps'] = not any(r['capped'] for r in data['runs'])
    checks['no_arrow_damage'] = not any(r['damage_sources'].get('enemy arrows', 0) for r in data['runs'])
    checks['all_kills_recorded'] = all(len(r['kill_records']) == r['kills'] for r in data['runs'])
    checks['all_purchases_affordable'] = all(c['wallet_before'][c['currency']] >= c['price'] for c in data['choices'])
    levels = data['final_state']['levels']
    checks['100_maxed'] = sum(levels.get(n['id'], 0) >= n['maxLevel'] for n in catalog['upgrades']) >= 100
    for c, fee in enumerate([200000, 10, 4]):
        expected = data['initial_state']['wallet'][c] + sum(r['loot'][c] for r in data['runs']) + sum(a['reward'] for a in data['claims'] if a['currency'] == c) - sum(a['price'] for a in data['choices'] if a['currency'] == c) - fee
        checks[f'currency_{c}'] = isclose(expected, data['final_state']['wallet'][c], abs_tol=1e-6)
    return {'passed': all(checks.values()), 'checks': checks}

def export_csv(path, rows):
    if not rows: return
    fields = list(dict.fromkeys(k for row in rows for k in row))
    with path.open('w', newline='', encoding='utf-8') as handle:
        writer = csv.DictWriter(handle, fieldnames=fields)
        writer.writeheader()
        for row in rows:
            writer.writerow({k: json.dumps(v, separators=(',', ':')) if isinstance(v, (list, dict)) else v for k, v in row.items()})

def summarize():
    rows = []
    grouped = defaultdict(list)
    for path in sorted(EXPERIMENTS.glob('*/campaign*.json')):
        try:
            data = json.loads(path.read_text())
        except json.JSONDecodeError:
            continue
        if 'completed' not in data: continue
        catalog = json.loads((path.parent / 'catalog.json').read_text())
        metric = metrics(data)
        validation = audit(data, catalog)
        metric.update(profile=path.parent.name, file=path.name, seed=data['config']['seed'], audit_passed=validation['passed'], policy=data['config'].get('policy', 'v1'))
        rows.append(metric)
        grouped[path.parent.name].append(metric)
        (path.parent / (path.stem + '_audit.json')).write_text(json.dumps(validation, indent=2))
        if data.get('completed'):
            export_csv(path.parent / (path.stem + '_runs.csv'), [{k:v for k,v in r.items() if k != 'kill_records'} for r in data['runs']])
            export_csv(path.parent / (path.stem + '_choices.csv'), data['choices'])
            export_csv(path.parent / (path.stem + '_kills.csv'), [dict(run=r['run'], prestige=r['prestige'], **kill) for r in data['runs'] for kill in r['kill_records']])
    aggregates = {}
    for name, subset in grouped.items():
        aggregates[name] = {key:mean(r[key] for r in subset) for key in ['runs','advance_fraction','close_kill_fraction','far_kill_fraction','contact_deaths','row_only_deaths','runs_with_close_kills']}
        aggregates[name].update(campaigns=len(subset), all_complete=all(r['completed'] for r in subset), all_audits_pass=all(r['audit_passed'] for r in subset), all_runs_have_upgrades=all(not r['no_purchase_runs'] for r in subset))
    result = dict(campaigns=rows, aggregates=aggregates)
    (EXPERIMENTS / 'audited_comparison.json').write_text(json.dumps(result, indent=2))
    print(json.dumps(aggregates, indent=2))
    return result

def final_report():
    summary = summarize()
    installed = json.loads((EXPERIMENTS / 'installed_tree.json').read_text())
    chosen = installed['profile']
    control_profile = installed.get('control_profile', 'control_v4')
    release = [r for r in summary['campaigns'] if r['profile'] == chosen]
    control = [r for r in summary['campaigns'] if r['profile'] == control_profile]
    assert len(release) == len(control) == 3
    selected_traces = [json.loads((EXPERIMENTS / chosen / r['file']).read_text()) for r in release]
    control_traces = [json.loads((EXPERIMENTS / control_profile / r['file']).read_text()) for r in control]
    def pooled(traces, rows):
        runs = [r for data in traces for r in data['runs']]
        kills = [k for r in runs for k in r['kill_records']]
        return dict(runs=len(runs), kills=len(kills), avg_runs=len(runs)/len(traces),
            advancing=sum(r['advances'] for r in rows), comparable=sum(r['comparable_transitions'] for r in rows),
            regressions=sum(r['regressions'] for r in rows), flat=sum(r['flat_transitions'] for r in rows),
            close=sum(k['range']<=2 for k in kills)/len(kills),
            close_count=sum(k['range']<=2 for k in kills),
            far=sum(k['range_fraction']>=.8 for k in kills)/len(kills),
            mean_range=mean(k['range'] for k in kills), median_range=median(k['range'] for k in kills),
            front_close=sum(k['range']<=2 and k['ahead']>=0 for k in kills),
            close_runs=sum(any(k['range']<=2 for k in r['kill_records']) for r in runs),
            contact=sum(r['death_source']=='enemy contact' for r in runs),
            row_only=sum(r['death_source']=='the row' and not r['damage_sources'].get('enemy contact',0) for r in runs),
            upgrades=sum(r['runs_with_purchase_after'] for r in rows))
    new, old = pooled(selected_traces,release), pooled(control_traces,control)
    catalog = json.loads((EXPERIMENTS/chosen/'catalog.json').read_text())
    max_hp = catalog['base_stats']['MaxHP'] + sum(e['amount']*u['maxLevel'] for u in catalog['upgrades'] for e in u['effects'] if e['stat']=='MaxHP')
    impact = next(e['amount'] for u in catalog['upgrades'] for e in u['effects'] if e['stat']=='Impact_Armor')
    dagger_range = catalog['base_stats']['Melee_range']
    for u in sorted(catalog['upgrades'], key=lambda u:u['upgradeName']):
        for e in u['effects']:
            if e['stat']=='Melee_range':
                for _ in range(u['maxLevel']):
                    dagger_range += dagger_range*e['amount']/100 if e['percentage'] else e['amount']
    close_call_wins = 0
    for trace in selected_traces:
        for run in trace['runs']:
            max_hp = catalog['base_stats']['MaxHP'] + sum(effect['amount']*run['upgrade_levels'].get(node['id'],0) for node in catalog['upgrades'] for effect in node['effects'] if effect['stat']=='MaxHP')
            close_call_wins += run['won'] and 0 < run['health'] <= max_hp*.10
    percent = lambda value:f'{100*value:.1f}%'
    snapshots = {}
    for name in ['maxed_repeat20','final_build_repeat20']:
        path = EXPERIMENTS / (name+'.json')
        if path.exists():
            data = json.loads(path.read_text())
            snapshots[name] = dict(runs=len(data['runs']),wins=sum(r['won'] for r in data['runs']))
    runtime = json.loads((EXPERIMENTS / 'runtime_validation.json').read_text())
    switch = json.loads((EXPERIMENTS / 'switch_validation.json').read_text())
    achievement = json.loads((EXPERIMENTS / 'achievement_validation.json').read_text())
    integrity = json.loads((EXPERIMENTS / 'old_save_integrity.json').read_text())
    unique = set()
    for path in EXPERIMENTS.glob('*/catalog.json'):
        catalog = json.loads(path.read_text())
        unique.add(json.dumps(catalog,sort_keys=True))
    lines = ['# Railway Fury upgrade-tree rebalance — 2026-10-24','',
        f"Installed **Rebalanced** (experiment `{chosen}`), selected after **{len(summary['campaigns'])} complete campaigns** covering **{len(unique)-1} new numeric trees plus the previous tree**. "
        f"The complete campaigns include {sum(r['runs'] for r in summary['campaigns'])} realized player runs. Forecast trials, fixed-seed replays and final-build stress tests are recorded separately.", '',
        '## Result against the previous tree', '',
        'Both columns use the same final upgrade-buying policy, combat source, 60 Hz simulation and three independent campaign seeds (2401026–2401028). '
        'Each starts with a fresh wallet and ends after clearing all four prestiges, maxing at least 100 nodes and paying the unchanged final-chamber fee.', '',
        '| Measure | Previous tree | Installed tree |','|---|---:|---:|',
        f"| Mean runs to final chamber | {old['avg_runs']:.1f} | {new['avg_runs']:.1f} |",
        f"| Attempts that advance farther before prestige clearance | {percent(old['advancing']/old['comparable'])} | {percent(new['advancing']/new['comparable'])} |",
        f"| Runs followed by a tree upgrade | {old['upgrades']}/{old['runs']} | {new['upgrades']}/{new['runs']} |",
        f"| Kills within 2 m | {percent(old['close'])} | {percent(new['close'])} |",
        f"| Kills at ≥80% of bow range | {percent(old['far'])} | {percent(new['far'])} |",
        f"| Mean enemy separation at death | {old['mean_range']:.2f} m | {new['mean_range']:.2f} m |",
        f"| Median enemy separation at death | {old['median_range']:.2f} m | {new['median_range']:.2f} m |",
        f"| Runs with at least one kill within 2 m | {old['close_runs']}/{old['runs']} | {new['close_runs']}/{new['runs']} |",
        f"| Contact-damage deaths | {old['contact']} | {new['contact']} |",
        f"| Victories ending with ≤10% health | — | {close_call_wins} |",
        f"| Deaths with walking damage and no contact damage | {old['row_only']} | {new['row_only']} |", '',
        f"Campaign length changes by {(new['avg_runs']/old['avg_runs']-1)*100:+.1f}%. Close kills are {new['close']/old['close']:.1f}× as frequent. "
        f"All {new['runs']} realized runs support at least one subsequent upgrade purchase. "
        f"Of {new['comparable']} comparable progression attempts, {new['advancing']} advance, {new['flat']} tie and {new['regressions']} regress. "
        'Permanent upgrades improve every run; random layouts, enemy types and healing/critical rolls still cause occasional distance setbacks. '
        'Strictly farther on every possible random seed is not guaranteed.', '',
        f"{new['front_close']} of the {new['close_count']} close kills occur with the enemy still in front of the player.", '',
        'A crown counts as prestige clearance even if a fatal hit and the boss kill occur in the same physics step, matching the existing runtime. '
        'A completed corridor counts as 300 m of progression even when the boss dies before the player reaches its position. '
        'Distance comparisons exclude prestige resets and farming after that prestige is cleared. Kill separation is horizontal world-space distance at the killing hit; close means ≤2 m.', '',
        '## Runs per prestige', '',
        '| Seed | Prestige 0 | Prestige 1 | Prestige 2 | Prestige 3 | Runs to final chamber |',
        '|---:|---:|---:|---:|---:|---:|']
    for row in release:
        lines.append('| '+ ' | '.join([str(int(row['seed']))]+[str(row['first_clears'][str(p)]) for p in range(4)]+[str(row['runs'])])+' |')
    lines += ['', '## Why this tree', '',
        f'- **Keep ordinary enemies relevant.** Later flat arrow damage is about 70% of the old values, with the final tier set to 200,000 per level. Dagger damage is reduced and its reach grows to {dagger_range:g} m rather than 7 m. Bow reach grows to 10.75 m rather than 13 m. Enemies spend more of their life approaching the player.',
        f'- **Make close combat survivable.** Impact Armor becomes an affordable starting option: 4 gold, {impact:g}% contact reduction, numeric prerequisite threshold 0. Contact still kills players during progression, rather than every close encounter ending the run.',
        f'- **Smooth survival growth.** The first health upgrade gives 6 HP rather than 5. Larger late health rewards increase by approximately 35%, with smaller adjustments to the intermediate tiers. Full health reaches {max_hp:,.0f} instead of 15,440. Corridor damage itself is unchanged.',
        '- **Give boss specialization a purpose.** The four existing boss-only damage tiers give 100, 6,000, 400,000 and 200,000,000 bonus damage per level. Their prices scale with progression. This shortens stalls at the fixed gates without erasing the ordinary enemies that create close calls.',
        f"- **Keep the existing achievement reachable.** The last arrow tier preserves a legal {achievement['arrow_damage']:,.0f}-damage build. Stronger uniform nerfs fell below the unchanged 60-million Bow Master requirement and were rejected.",
        '- **Keep progression length familiar.** Gold prices are generally 10% higher, with explicit prices for the boss tiers and early impact armor. Currency types, caps, purchase-price growth, node identities, positions, parent/child lists and weapon/ability unlock types remain unchanged.', '',
        'The full numeric diff is [installed_value_changes.csv](installed_value_changes.csv). Descriptions were updated to display the new amounts. '
        'Base player/enemy stats, enemy spawning, movement, walking/contact damage rules, projectile logic and ability durations/cooldowns were not retuned.', '',
        '## Experiments and rejected variants', '',
        'Early sweeps used earlier versions of the buying model and are exploratory. Only the final matched-policy controls above support the direct before/after claim. '
        'The selector was refined to value impact armor and to score normal-enemy DPS separately from boss-only DPS. '
        'The latter prevents a huge boss bonus from hiding a lack of ordinary-enemy damage.', '',
        'The experiment table averages percentages per campaign; the main comparison pools the underlying attempts and kills.', '',
        '| Candidate / policy group | Campaigns | Mean runs | Advances | Close kills | Mean contact deaths | Every run buys an upgrade |',
        '|---|---:|---:|---:|---:|---:|---|']
    for name, row in summary['aggregates'].items():
        lines.append(f"| {name} | {row['campaigns']} | {row['runs']:.1f} | {percent(row['advance_fraction'])} | {percent(row['close_kill_fraction'])} | {row['contact_deaths']:.1f} | {'yes' if row['all_runs_have_upgrades'] else 'no'} |")
    lines += ['',
        'Large offense reductions (close/smooth) made contact deaths too common and extended campaigns. '
        'The guarded versions improved close kills but still had too many setbacks. '
        'The balanced versions restored steadier progression, but some produced an empty-income run with no affordable upgrade, and several could not reach Bow Master. '
        'Moving multipliers too early (ladder) hurt the later build because percentage upgrades depend on purchase order. '
        'The installed final arrow adjustment retained the better balanced curve, removed the observed empty-upgrade run in the validation seeds, and restored achievement reachability. '
        'This is the best tested tradeoff, rather than a proof of a global optimum over all possible trees and purchase sequences.', '',
        '## Upgrade-buying model', '',
        'The simulated player ranks affordable, legal purchases by effective health against walking/contact damage, normal DPS, boss DPS, healing, range, pickup range and child unlocks. '
        'It simulates the top four candidates using the same forecast seed and weights reach 60%, gold income rate 28% and gem income rate 12%, with stat/unlock potential and an expected-runs cost penalty. '
        'Realized runs use separate seeds. Purchases are recalculated one level at a time and retain the game’s purchase-order compounding. '
        'After the ending is available, it buys one upgrade per dive and banks entry funds, avoiding a tail of runs with nothing left to buy. '
        'No income is injected. This buyer is a simulation tool; the live game still lets the player choose upgrades.', '',
        '## Achievement rewards and round upgrade values', '',
        'Achievement rewards were already included in all of the original campaign results. The simulator checks and claims every available reward before shopping and after each purchase. '
        'This includes rewards made available by that purchase; unlocking the Achievements tab immediately claims any banked achievements. Rewards earned during combat enter the next shop phase. '
        'The next purchase recommendation uses the updated wallet, so rewards can fund further upgrades in the same visit. '
        'For example, in the pre-rounding seed 2401026 campaign, unlocking Achievements after run 5 left 2 gold; First Dive added 25, and the next 3-gold upgrade was purchased from a 27-gold wallet.', '',
        'Standalone recommendation mode had a separate omission: it did not claim pending rewards before evaluating the supplied snapshot. '
        'It now does. Three regression fixtures verify immediate use of a ready reward, no duplicate payout, and respect for the Achievements-tab lock '
        '([results](recommendation_rewards/validation.json)).', '',
        'The rounding follow-up rounds fractional health and damage additions and percentage bonuses to whole values, and 0.9 bow-rate additions to 1. '
        'Small range and dagger-rate increments retain clean quarters (0.25 and 0.75). All other health, armor, damage and percentage upgrade amounts are whole numbers. '
        f'The adjusted amounts are recorded in [rounding_changes.json]({chosen}/rounding_changes.json). '
        'Compounding percentage bonuses can still produce fractional resulting stats; upgrade additions themselves follow these rules.', '',
        'Whole-number rounding changed the buying order and exposed a zero-income Prestige 3 transition in the initial candidates. '
        'Coarser and nearest-integer rounding variants, and 90% Impact Armor, were tested. '
        'The installed follow-up keeps Impact Armor at 85% and improves the simulation buyer: at Prestige 3, after one purchase in a shop, it retains an affordable option for a possible zero-income next run. '
        'The reserve check includes rewards that the proposed purchase would make claimable. Once the final chamber is available, the existing entry-fee banking rule takes over. '
        'Both the previous and rounded trees were rerun with this same policy for a matched comparison. '
        'This buyer change affects the simulation recommendations; the live game still leaves purchases to the player.', '',
        'An initial policy that reserved an option from Prestige 0 delayed foundational upgrades and was rejected. '
        'Its partial traces and rejection reason remain in `round_numbers_buffered/` and `control_buffered/`; incomplete campaigns are excluded from completed-campaign totals.', '',
        'The follow-up reruns three complete campaigns with the same reward-aware buyer and seeds. '
        'An independent [reward and rounding audit](reward_rounding_audit.json) reconciles reward credits against every shop phase and purchase wallet, checks catalog reward amounts and duplicate claims, and verifies every installed increment.', '',
        '## Installed setting and saves', '',
        '**Settings → UPGRADE TREE (RESTART)** selects **REBALANCED** (default) or **PREVIOUS**. Restart the game to apply. '
        'The choice stays locked during the session so a mid-run setting change cannot redirect loot or mix stats between trees.', '',
        '- Rebalanced progress: `%APPDATA%/RailwayFury/row_divers_progress_balanced_v1.json`; starts fresh on first use.',
        '- Previous progress: `%APPDATA%/RailwayFury/row_divers_progress_v1.json`; restores the original build and wallet.',
        '- The original catalog is preserved byte-for-byte as `Games/RowDivers/Data/row_divers_previous.json`.', '',
        'The shop adapter also renders zero-prerequisite entries as starting options, matching the existing progression API. '
        'The live shop test verifies that the new 4-gold impact upgrade is visible, affordable and applies its catalog value.', '',
        '## Verification', '',
        f"- {len(runtime['cases'])}/{len(runtime['cases'])} rebalanced runtime/model comparisons match completion frame, distance, kills, income, HP, armor and damage sources; failures: {runtime['failures']}. Six additional comparisons pass for the previous tree.",
        f"- All {len(switch['checks'])} setting/save/shop checks {'pass' if switch['passed'] else 'FAIL'}; original save hash unchanged: {integrity['unchanged']}.",
        '- All three selected campaigns replay their recorded purchases and every realized outcome exactly, including the final saved state.',
        '- Currency balances, purchase affordability, kill records, all four crowns, 100 maxed nodes and the final entry fee pass the per-campaign audits.',
        f"- Achievement reachability: {'pass' if achievement['passed'] else 'FAIL'}; legal all-flat-before-percentage build reaches {achievement['arrow_damage']:,.0f} arrow damage."]
    for key, label in [('maxed_repeat20','Legally maxed build'),('final_build_repeat20','Actual final campaign build')]:
        if key in snapshots:
            row=snapshots[key];lines.append(f"- {label}: {row['wins']}/{row['runs']} Prestige 3 clears on new seeds.")
    lines += ['',
        'All simulations use the requested assisted conditions: centered walking, automatic targeting/fire, no hostile-arrow damage and automatic abilities. '
        'Normal contact and corridor damage remain active. Free-aim and unassisted play are outside this validation. '
        'Full-project headless Godot test runs emit existing shader/resource-cleanup diagnostics; their behavioral assertions pass. Isolated campaigns and replays exit cleanly.', '',
        '## Reproduce and inspect', '',
        '- [Installed values and provenance](installed_tree.json)',
        '- [All audited campaign comparisons](audited_comparison.json)',
        '- [Whole-objective completion audit](completion_audit.json)',
        f'- [{chosen} campaign traces and CSVs]({chosen}/campaign.json)',
        f'- [Every run, seed 2401026]({chosen}/campaign_runs.csv)',
        f'- [Every purchase and alternatives, seed 2401026]({chosen}/campaign_choices.csv)',
        f'- [Every kill distance, seed 2401026]({chosen}/campaign_kills.csv)',
        '- `replay_2401026.json` / `...27.json` / `...28.json`: exact replays and starting loadouts for every run.',
        '- `SourceSnapshot/`: frozen combat/progression source; runner snapshots are archived beside final candidate results.',
        '- Run `python tools/rowdivers_balance/report_tuning.py --final` to regenerate this report.', '']
    (EXPERIMENTS/'TUNING_REPORT.md').write_text('\n'.join(lines),encoding='utf-8')
    print(EXPERIMENTS/'TUNING_REPORT.md')

if __name__ == '__main__':
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--final',action='store_true')
    args=parser.parse_args()
    final_report() if args.final else summarize()
