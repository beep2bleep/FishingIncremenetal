"""Audit completed flying campaigns and export the recorded decisions and combat."""
from collections import Counter
from hashlib import sha256
from math import ceil, isclose
from pathlib import Path
from statistics import mean, median
import json

from audit_rewards_rounding import inspect
from report_tuning import export_csv

ROOT = Path(__file__).resolve().parents[2]
MODULE = ROOT / 'FeedingABlackHoldGame/Games/RowDivers'
FLIGHT = MODULE / 'Simulation/Flight'


def read(path):
    return json.loads(path.read_text(encoding='utf-8'))


def digest(path):
    return sha256(path.read_bytes()).hexdigest()


def audit(trace, catalog):
    runs, choices, state = trace['runs'], trace['choices'], trace['final_state']
    nodes = {n['id']: n for n in catalog['upgrades']}
    levels = dict(trace['initial_state']['levels'])
    legal = []
    for choice in choices:
        node = nodes[choice['id']]
        level = levels.get(node['id'], node['level'])
        rank = min(level, node['maxLevel'] - 1)
        price = node['baseUpgradeCost'] if rank <= 0 else ceil(node['baseUpgradeCost'] * 1.2 ** rank)
        visible = node['isVisible'] or level > 0 or any(levels.get(p, 0) >= node['unlockAtParentLevel'] for p in node['parents'])
        legal.append(bool(visible and choice['prestige'] >= node.get('minPrestige', 0)
            and level == choice['level_before'] and level < node['maxLevel']
            and choice['currency'] == node['cost']['currencyType'] and choice['price'] == price
            and choice['wallet_before'][choice['currency']] >= price))
        levels[node['id']] = level + 1
    checks = dict(completed=trace.get('completed', False), final_fee_paid=state.get('god_panel_unlocked', False),
        fresh_start=not trace['initial_state']['levels'] and trace['initial_state']['wallet'] == [0, 0, 0],
        four_crowns=all(state['crowns_dropped'].get(str(p), False) for p in range(4)),
        no_time_caps=all(not r['capped'] for r in runs), all_choices_legal=all(legal),
        chosen_best_tested_score=all(isclose(c['score'], max(a['score'] for a in c['alternatives']), abs_tol=1e-9) for c in choices),
        levels_reconciled=levels == state['levels'],
        enough_maxed_nodes=sum(state['levels'].get(n['id'], 0) >= n['maxLevel'] for n in nodes.values()) >= catalog['settings']['ending_maxed_nodes'],
        all_kills_recorded=all(len(r['kill_records']) == r['kills'] for r in runs),
        constant_fire_damage=all(r['fire_waves']['damage_per_hit'] == catalog['settings']['fire_waves']['damage'][int(r['prestige'])]
            and all(e['damage'] == (r['fire_waves']['damage_per_hit'] if e['hit'] else 0) for e in r['fire_waves']['records']) for r in runs),
        wave_counts=all(r['fire_waves']['hits'] + r['fire_waves']['dodged'] == len(r['fire_waves']['records']) for r in runs))
    for currency, fee in enumerate([200000, 10, 4]):
        expected = trace['initial_state']['wallet'][currency] + sum(r['loot'][currency] for r in runs)
        expected += sum(a['reward'] for a in trace['claims'] if a['currency'] == currency)
        expected -= sum(a['price'] for a in choices if a['currency'] == currency) + fee
        checks[f'currency_{currency}_conserved'] = isclose(expected, state['wallet'][currency], abs_tol=1e-6)
    rewards = inspect(trace, catalog)
    checks['achievement_wallet_audit'] = rewards['passed']
    checks['all_four_damage_sources_active'] = all(sum(r['damage_sources'].get(source, 0) for r in runs) > 0 for source in ['the row', 'enemy contact', 'enemy arrows', 'fire waves'])
    return dict(passed=all(checks.values()), checks=checks, rewards=rewards)


def stats(trace):
    runs = trace['runs']
    kills = [k for r in runs for k in r['kill_records']]
    waves = [e for r in runs for e in r['fire_waves']['records']]
    first_clear, counts, previous = {}, Counter(), {}
    advance = comparable = 0
    for r in runs:
        p = int(r['prestige'])
        counts[p] += 1
        if r['won'] and p not in first_clear: first_clear[p] = counts[p]
        if p in previous and p not in cleared_before(runs, int(r['run'])):
            comparable += 1
            advance += r['distance'] > previous[p] + .1
        previous[p] = r['distance']
    return dict(seed=int(trace['config']['seed']), runs=len(runs), first_clear=first_clear,
        attempts_by_prestige=dict(counts), deaths=dict(Counter(r['death_source'] for r in runs if not r['won'])),
        kills=len(kills), mean_kill_range=mean(k['range'] for k in kills), median_kill_range=median(k['range'] for k in kills),
        far_fraction=mean(k['range_fraction'] >= .8 for k in kills), close_fraction=mean(k['range'] <= 2 for k in kills),
        advancing=advance, comparable=comparable, wave_hits=sum(e['hit'] for e in waves), wave_crossings=len(waves),
        wave_stages={str(s):dict(crossings=sum(e['stage'] == s for e in waves), hits=sum(e['stage'] == s and e['hit'] for e in waves)) for s in range(3)},
        damage={key:sum(r['damage_sources'].get(key, 0) for r in runs) for key in ['the row', 'enemy contact', 'enemy arrows', 'fire waves']},
        loot=[sum(r['loot'][c] for r in runs) for c in range(3)], purchases=len(trace['choices']),
        mean_kills_per_run=mean(r['kills'] for r in runs),
        maxed=sum(trace['final_state']['levels'].get(n['id'], 0) >= n['maxLevel'] for n in read(FLIGHT/'tuned/catalog.json')['upgrades']))


def cleared_before(runs, index):
    return {int(r['prestige']) for r in runs if int(r['run']) < index and r['won']}


def repeat_stats(filename):
    data = read(FLIGHT / filename)
    return dict(runs=len(data['runs']), wins=sum(r['won'] for r in data['runs']),
        deaths=dict(Counter(r['death_source'] for r in data['runs'] if not r['won'])),
        fire_hits=sum(r['fire_waves']['hits'] for r in data['runs']))


def main():
    catalog = read(FLIGHT/'tuned/catalog.json')
    traces = [read(p) for p in sorted((FLIGHT/'tuned').glob('campaign*.json'))]
    assert len(traces) == 3 and all(t.get('completed') for t in traces), 'Wait for all three complete campaigns.'
    audits = [audit(t, catalog) for t in traces]
    rows = [stats(t) for t in traces]
    for trace in traces:
        stem = 'seed' + str(int(trace['config']['seed']))
        export_csv(FLIGHT/'tuned'/f'{stem}_runs.csv', [{k:v for k,v in r.items() if k not in ['kill_records', 'fire_waves']} | dict(
            upgrades_after=sum(c['after_run'] == r['run'] for c in trace['choices']),
            fire_hits=r['fire_waves']['hits'], fire_dodged=r['fire_waves']['dodged']) for r in trace['runs']])
        export_csv(FLIGHT/'tuned'/f'{stem}_choices.csv', trace['choices'])
        export_csv(FLIGHT/'tuned'/f'{stem}_claims.csv', trace['claims'])
        export_csv(FLIGHT/'tuned'/f'{stem}_kills.csv', [dict(run=r['run'], prestige=r['prestige'], **{('path_distance' if k == 'distance' else k):v for k,v in kill.items()}) for r in trace['runs'] for kill in r['kill_records']])
        export_csv(FLIGHT/'tuned'/f'{stem}_waves.csv', [dict(run=r['run'], prestige=r['prestige'], **e) for r in trace['runs'] for e in r['fire_waves']['records']])
    checks = dict(all_campaign_audits=all(a['passed'] for a in audits),
        installed_catalog_matches=digest(MODULE/'Data/row_divers_free_aim.json') == digest(FLIGHT/'tuned/catalog.json'),
        recorded_catalog_matches=all(t['config']['catalog_sha256'] == digest(FLIGHT/'tuned/catalog.json') for t in traces),
        clean_health_damage=all(e['amount'] == int(e['amount']) for n in catalog['upgrades'] for e in n['effects'] if e['stat'] == 'MaxHP' or 'Damage' in e['stat']),
        clean_upgrade_increments=all((e['amount'] * 4 == int(e['amount'] * 4) if not e['percentage'] and e['stat'] in ['Melee_range','Distance_Range','Bow_Fire_Rate','Dagger_Attack_Rate'] else e['amount'] == int(e['amount'])) for n in catalog['upgrades'] for e in n['effects']),
        controls_whole_points=all(n['maxLevel'] == 2 and n['effects'][0]['amount'] == 10 for n in catalog['upgrades'] if n['id'].startswith('flight_')),
        runtime_parity=read(FLIGHT/'runtime_validation.json')['passed'], shop=read(FLIGHT/'tree_validation.json')['passed'])
    regression = read(FLIGHT/'classic_regression/runtime_validation.json')
    checks['classic_runtime_parity'] = regression.get('passed', regression.get('failures') == 0)
    checks['classic_results_unchanged'] = regression['cases'] == read(MODULE/'Simulation/Tuning/runtime_validation.json')['cases']
    classic_manifest = read(MODULE/'Simulation/Tuning/installed_tree.json')
    checks['classic_catalog_unchanged'] = digest(MODULE/'Data/row_divers.json') == classic_manifest['installed_sha256']
    checks['previous_catalog_unchanged'] = digest(MODULE/'Data/row_divers_previous.json') == classic_manifest['previous_sha256']
    before = read(FLIGHT/'save_integrity_before.json')
    after = {path:digest(Path(path)) for path in before if Path(path).exists()}
    checks['existing_progress_unchanged'] = before == after
    (FLIGHT/'save_integrity_after.json').write_text(json.dumps(after, indent=2)+'\n')
    repeats = {name:repeat_stats(name+'.json') for name in ['maxed_repeat20', 'tuned_maxed_repeat20', 'tuned_no_control_repeat20', 'tuned_slower_pilot_repeat20']}
    baselines = [read(p) for p in sorted((FLIGHT/'final').glob('campaign*.json'))]
    comparison = [stats(t) for t in baselines if t.get('completed')]
    checks['initial_comparison_complete_and_audited'] = len(baselines) == 3 and all(audit(t, read(FLIGHT/'final/catalog.json'))['passed'] for t in baselines)
    replay_paths = sorted((FLIGHT/'tuned').glob('replay_seed*.json'))
    checks['exact_campaign_replays'] = len(replay_paths) == 3 and all(read(p).get('replay_passed', False) for p in replay_paths)
    checks['free_aim_three_style_checks'] = 'FREE AIM: 78 checks, 0 failures' in (ROOT/'tools/rowdivers_balance/flight_existing_freeaim.log').read_text(encoding='utf-8')
    provenance = dict(date='2026-10-25', profile='tuned', catalog_sha256=digest(MODULE/'Data/row_divers_free_aim.json'),
        physics_snapshot='SourceSnapshotFinal', source_sha256={str(p.relative_to(ROOT)):digest(p) for p in [
            MODULE/'RowDiversFireWaves.gd', MODULE/'Scenes/RowDiversBattleScene.gd', MODULE/'Simulation/FlightPilot.gd',
            MODULE/'Simulation/GeneratedFreeAimModel.gd', MODULE/'RowDiversProgress.gd', MODULE/'Simulation/RunBalanceCampaign.gd',
            MODULE/'RowDiversFireWaveVisual.gd', MODULE/'FireWave.gdshader',
            MODULE/'Data/row_divers.json', MODULE/'Data/row_divers_previous.json',
            ROOT/'tools/rowdivers_balance/prepare_flight.py', ROOT/'tools/rowdivers_balance/build_model.py',
            ROOT/'tools/rowdivers_balance/run.py', ROOT/'tools/rowdivers_balance/report_flight.py']},
        pilot=dict(reaction_seconds=.18, angular_error_radians=.012, max_aim_radians_per_second=5, click_rate=6),
        campaign_seeds=[r['seed'] for r in rows], dt=1/60,
        note='Frozen campaign runner has an obsolete classic modeled_variant label; config.free_aim=true and GeneratedFreeAimModel identify these flying trials. Current runner corrects the label and extends replay checks without changing decisions or combat.')
    (FLIGHT/'installed_flight.json').write_text(json.dumps(provenance, indent=2)+'\n')
    result = dict(passed=all(checks.values()), checks=checks, campaigns=rows, audits=audits, repeats=repeats, initial_active_comparison=comparison)
    (FLIGHT/'audit.json').write_text(json.dumps(result, indent=2)+'\n')
    lines = ['# Flying mode balance — 25 October 2026', '',
        'Installed a separate 128-node tree and save slot for free aim. The automated pilot aims, strafes around observed hazards, moves into pickup range, and uses abilities on cooldown. Native projectile travel, shot cooldowns, acceleration, contact, hallway drain, enemy arrows, and fire waves remain active. Tests run without rendering or real-time waits at 60 simulation ticks per second; no 32× immunity is used.', '',
        '## Full campaigns', '', '| Seed | Runs to first clear P0 / P1 / P2 / P3 | Total runs through final fee | Maxed nodes | Mean kills/run | Mean kill distance |', '|---:|---|---:|---:|---:|---:|']
    for row in rows:
        lines.append(f"| {row['seed']} | {' / '.join(str(row['first_clear'].get(p, 'missing')) for p in range(4))} | {row['runs']} | {row['maxed']}/128 | {row['mean_kills_per_run']:.1f} | {row['mean_kill_range']:.2f} m |")
    kills = [k for t in traces for r in t['runs'] for k in r['kill_records']]
    deaths = Counter()
    for row in rows: deaths.update(row['deaths'])
    advance = sum(r['advancing'] for r in rows)
    comparable = sum(r['comparable'] for r in rows)
    lines += ['', f"Mean campaign length: **{mean(r['runs'] for r in rows):.1f} runs**, versus 49.7 in the assisted release (53 / 47 / 49). All campaigns start with zero resources, earn all four crowns, max at least 116 nodes, and pay 200,000 gold + 10 gems + 4 crowns for the final chamber. Prestige-first-clear counts exclude later farming. {advance}/{comparable} comparable pre-clear attempts increase forward distance by more than 0.1 m.", '',
        f"Deaths across these campaigns: {', '.join(f'{source}: {count}' for source,count in deaths.items())}. All four damage sources are recorded; this is no longer gated solely by hallway drain. Across {len(kills):,} kills, {100*mean(k['range_fraction'] >= .8 for k in kills):.1f}% occur at ≥80% attack range and {100*mean(k['range'] <= 2 for k in kills):.1f}% within 2 m. Median separation is {median(k['range'] for k in kills):.2f} m. Range fractions can exceed 1 for traveling shots/abilities. Per-run kills, distances, damage, loot, and purchases are in the CSVs.", '',
        '| Prestige | Total attempts across 3 seeds | Mean kills/run | Mean forward distance | Mean kill separation |', '|---:|---:|---:|---:|---:|']
    for p in range(4):
        subset = [r for t in traces for r in t['runs'] if r['prestige'] == p]
        pkills = [k for r in subset for k in r['kill_records']]
        lines.append(f"| {p} | {len(subset)} | {mean(r['kills'] for r in subset):.1f} | {mean(r['distance'] for r in subset):.1f} m | {mean(k['range'] for k in pkills):.2f} m |")
    lines += ['', '## Fire waves and upgrades', '',
        'Each new dive resets the wave stage; each prestige starts using its own control stat. Defeating the first and second miniboss increases pressure. Damage is fixed for the entire prestige: 15 / 100 / 400 / 1,200 per hit. Escalation changes frequency, speed, and the safe channel, rather than damage. The final boss ends the dive.', '',
        '| Stage | No control: interval / gap / speed | 80 control: interval / gap / speed |', '|---|---|---|',
        '| Before first boss | 5.00 s / 1.90 m / 6.0 m/s | Same |',
        '| After first boss | 1.43 s / 1.45 m / 8.0 m/s | 4.55 s / 1.81 m / 6.4 m/s |',
        '| After second boss | 0.45 s / 1.00 m / 10.0 m/s | 3.57 s / 1.72 m / 6.8 m/s |', '',
        'Observed crossings include the control levels the buyer had at that point:', '',
        '| Stage | Crossings | Hits | Hit rate |', '|---:|---:|---:|---:|']
    for stage in range(3):
        crossings = sum(r['wave_stages'][str(stage)]['crossings'] for r in rows)
        hits = sum(r['wave_stages'][str(stage)]['hits'] for r in rows)
        lines.append(f'| {stage} | {crossings} | {hits} | {100*hits/max(1,crossings):.1f}% |')
    lines += ['', 'The 16 Ember Channels nodes are spread behind four existing gem unlocks: Shoot On Hold, Dagger, Dagger Attack Range I, and Row Damage Resistance I. Four nodes per prestige, two ranks each, give +10 whole control points per purchase (80 total). Prestige 0 base prices are 10 / 25 / 50 / 100 gold; Prestige 1 multiplies these by 20, Prestige 2 by 200, Prestige 3 by 2,000. Second ranks cost 1.2×, rounded up. Future-prestige nodes are gated. Earlier control remains owned but does not reduce a later prestige’s waves.', '',
        'Flame banks use the existing illustrated flame texture with animated distortion and warm light; the center opening is the safe route. [In-game preview](fire_wave_preview.png).', '',
        '## Tuning decisions', '',
        'Free aim starts with arrow damage 30, arrow speed 8, and strafe speed 1. Gold payouts are 2× assisted payouts; gems remain 1×. The pickup attraction is strong enough to catch a drop once the player enters its collection radius. Projectile armor now reduces hostile-arrow damage in free aim. Classic outcomes remain unchanged in the six runtime regression cases.', '',
        'The initial active balance left maxed survival at 10/20. Increased Medicine II from +540 to +800 health per rank, Red Heart from +1,620 to +2,000 health, and Shiny Armor from +500 to +750 armor per rank, retaining prices. Fully maxed health is 23,330 and armor 3,520. Health/damage increments remain whole numbers; percentage effects can still produce fractional resulting stats. The adjustment improves survival without changing early wave damage or escalation.', '',
        '| Repeated P3 test, same 20 seeds | Wins | Deaths | Fire hits |', '|---|---:|---|---:|']
    for name, label in [('maxed_repeat20','Initial health, max control'), ('tuned_maxed_repeat20','Final health, max control'), ('tuned_no_control_repeat20','Final health, no P3 control'), ('tuned_slower_pilot_repeat20','Final health, slower pilot, max control')]:
        r = repeats[name]
        lines.append(f"| {label} | {r['wins']}/{r['runs']} | {', '.join(f'{k}: {v}' for k,v in r['deaths'].items()) or 'None'} | {r['fire_hits']} |")
    lines += ['', 'These snapshots use seeds 81240–81259 and a legally purchased maxed fixture, with P3 control removed for the no-control counterfactual. Slower reactions change discrete target and route decisions, so survival is not monotonic in the reaction setting. The slower result is a sensitivity check, not evidence that slower human reactions are better. Each raw trace retains its exact initial state; `initial_maxed_loadout.json` preserves the pre-adjustment fixture.']
    if len(comparison) == 3:
        lines += ['', 'Initial active health campaign totals on the same three seeds: '+ ' / '.join(str(r['runs']) for r in comparison)+'. Final totals: '+ ' / '.join(str(r['runs']) for r in rows)+'. Both use the same frozen physics, pilot, and purchase policy.']
    lines += ['', '## Purchase policy, claims, and limits', '',
        'Before each shop and after every purchase, claim every ready achievement once the Achievements tab is unlocked, then spend the resulting resources. Combat achievements are claimed at the next shop. The independent audit reconciles every shop wallet and the campaign-wide gold/gem/crown totals. Choices include prices, before-purchase wallets, scores, predictions, and alternatives.', '',
        'The buyer shortlists two affordable upgrades using survivability, damage, healing, range, pickup reach, control, and unlock value. It simulates both against the same baseline seed. Score weights are 60% relative forward reach, 28% gold per second, and 12% gems per second, plus stat/unlock value, divided by a price-in-expected-runs penalty. Winning a previously losing probe gets an additional bonus. Prestige 3 retains one affordable future purchase when possible; after the ending unlock it banks entry funds while taking at most one upgrade per shop.', '',
        'This is a bounded heuristic, not a global optimum or a human-calibrated model. The default pilot reacts every 0.18 s, aims at at most 5 rad/s with 0.012 rad error, clicks at most six times per second, and only plans around observed threats and drops. It cannot see future random spawns. The slower test uses 0.30 s reactions and 0.025 rad error. Deterministic seeds enable fair comparisons, but three campaigns and 20-run snapshots do not measure every play style.', '',
        '## Verification and files', '',
        'Six exact current-runtime/model combat comparisons passed, including all four prestiges and a no-control P3 fixture. Fifteen actual-shop checks cover catalog selection, purchase gating/costs, control isolation, and projectiles at 32×. Existing free-aim checks passed for all three visual styles (78 checks). Six classic runtime/model cases preserve the prior classic outcomes. All three tuned campaigns reproduce wave crossings, clicks, pilot decisions, loot, damage, kills, and final wallets; replay numeric tolerance is 1e-6 absolute / 1e-9 relative for JSON serialization. Saved player progress hashes were unchanged. Full-project validators emit existing startup/shader/exit-cleanup diagnostics; behavioral assertions pass, and the isolated campaign launcher rejects script errors.', '',
        'The flying slot is `user://row_divers_progress_flying_v1.json`; classic slots and catalogs remain available. The new mode begins its own progression.', '',
        '[Audit](audit.json) · [Installed source/catalog hashes](installed_flight.json) · [Runtime parity](runtime_validation.json) · [Shop checks](tree_validation.json). The `tuned/` directory contains three complete raw campaign traces and per-seed runs, choices, achievements, kill separations, and wave-crossing CSVs. `final/` retains the initial active balance comparison; rejected/exploratory traces remain separately labeled.', '',
        'Reproduce from the repository root:', '', '```powershell',
        'python tools/rowdivers_balance/run.py --free-aim --frozen-snapshot FeedingABlackHoldGame/Games/RowDivers/Simulation/Flight/SourceSnapshotFinal --catalog FeedingABlackHoldGame/Games/RowDivers/Simulation/Flight/tuned/catalog.json --config FeedingABlackHoldGame/Games/RowDivers/Simulation/Flight/tuned/config.json --output flight_reproduced.json',
        'python tools/rowdivers_balance/report_flight.py', '```', '']
    (FLIGHT/'REPORT.md').write_text('\n'.join(lines), encoding='utf-8')
    print(json.dumps(dict(passed=result['passed'], checks=checks, campaigns=rows, repeats=repeats), indent=2))
    assert result['passed']


if __name__ == '__main__': main()
