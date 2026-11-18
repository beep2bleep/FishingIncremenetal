"""Audit and summarize the current, frozen Free Aim campaign reruns."""
from collections import Counter
from hashlib import sha256
from pathlib import Path
from statistics import mean, median
import argparse
import json

from report_flight import audit
from report_tuning import export_csv

ROOT = Path(__file__).resolve().parents[2]
MODULE = ROOT / 'FeedingABlackHoldGame/Games/RowDivers'


def read(path):
    return json.loads(path.read_text(encoding='utf8'))


def summarize(trace, catalog):
    runs = trace['runs']
    kills = [kill for run in runs for kill in run['kill_records']]
    levels = []
    for prestige in range(4):
        group = [r for r in runs if int(r['prestige']) == prestige]
        first = next((i+1 for i, r in enumerate(group) if r['won']), None)
        cleared = next((r['run'] for r in group if r['won']), None)
        records = [k for r in group for k in r['kill_records']]
        levels.append(dict(level=prestige+1, attempts_to_first_clear=first,
            first_clear_run=cleared, total_runs=len(group), wins=sum(r['won'] for r in group),
            kills=sum(r['kills'] for r in group), mean_kills=mean(r['kills'] for r in group),
            min_kills=min(r['kills'] for r in group), max_kills=max(r['kills'] for r in group),
            mean_kill_range=mean(k['range'] for k in records),
            near_max_fraction=mean(k['range_fraction'] >= .8 for k in records),
            seconds=sum(r['seconds'] for r in group),
            deaths=dict(Counter(r['death_source'] for r in group if not r['won']))))
    nodes = {n['id']: n for n in catalog['upgrades']}
    powers = []
    for choice in trace['choices']:
        key = nodes[choice['id']].get('unlocks', {}).get('abilityType')
        if key:
            powers.append(dict(power=choice['name'], key=key, after_run=choice['after_run'],
                level=int(choice['prestige'])+1, price=choice['price'], currency=choice['currency']))
    waves = [w for r in runs for w in r['fire_waves']['records']]
    return dict(seed=int(trace['config']['seed']), completed=trace['completed'], runs=len(runs),
        levels=levels, seconds=sum(r['seconds'] for r in runs), kills=len(kills),
        mean_kills_per_run=mean(r['kills'] for r in runs),
        mean_kill_range=mean(k['range'] for k in kills), median_kill_range=median(k['range'] for k in kills),
        near_max_fraction=mean(k['range_fraction'] >= .8 for k in kills),
        close_fraction=mean(k['range'] <= 2 for k in kills),
        deaths=dict(Counter(r['death_source'] for r in runs if not r['won'])),
        row_deaths_with_majority_far_kills=[r['run'] for r in runs if r['death_source']=='the row' and r['far_kill_fraction']>=.5],
        purchases=len(trace['choices']), claims=len(trace['claims']),
        achievement_rewards=[sum(c['reward'] for c in trace['claims'] if c['currency']==i) for i in range(3)],
        loot=[sum(r['loot'][i] for r in runs) for i in range(3)],
        total_healing=sum(r['healing'] for r in runs), powers=powers,
        wave_crossings=len(waves), wave_hits=sum(w['hit'] for w in waves),
        waves_by_stage={str(stage):dict(crossings=sum(w['stage']==stage for w in waves),
            hits=sum(w['stage']==stage and w['hit'] for w in waves)) for stage in range(3)},
        maxed_nodes=sum(trace['final_state']['levels'].get(n['id'],0)>=n['maxLevel'] for n in nodes.values()))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--folder', type=Path, default=MODULE/'Simulation/CurrentPlaythrough20261027')
    args = parser.parse_args()
    folder = args.folder
    catalog = read(folder/'SourceSnapshot/row_divers_free_aim.json')
    summaries, audits = [], {}
    files = sorted(folder.glob('campaign*.json'))
    assert len(files)==3, 'Three complete seeds are required.'
    parity = read(folder/'runtime/runtime_validation.json')
    shop = read(folder/'runtime/tree_validation.json')
    ending = read(folder/'ending_validation.json')
    assert parity['passed'] and shop['passed'] and ending['passed']
    power_log = (ROOT/'tools/rowdivers_balance/current_powerups.log').read_text(encoding='utf8')
    assert 'POWERUPS PASSED: 161 checks, 0 failures' in power_log and 'SCRIPT ERROR' not in power_log
    installed = read(folder/'installed_sources.json')
    assert all(sha256((MODULE/rel).read_bytes()).hexdigest()==digest for rel,digest in installed.items()), 'Gameplay changed during simulation.'
    for path in files:
        trace = read(path)
        assert trace.get('completed'), f'{path.name} is still a checkpoint.'
        seed = int(trace['config']['seed'])
        summary = summarize(trace, catalog)
        result = audit(trace, catalog)
        replay = read(folder/f'replay_{seed}.json')
        result['checks']['deterministic_replay'] = replay['replay_passed']
        result['checks']['snapshot_catalog_matches'] = sha256((folder/'SourceSnapshot/row_divers_free_aim.json').read_bytes()).hexdigest()==trace['config']['catalog_sha256']
        result['checks']['runtime_parity'] = parity['passed']
        result['checks']['runtime_shop_gates'] = shop['passed']
        result['checks']['both_endings'] = ending['passed']
        result['checks']['current_power_runtime_checks'] = True
        result['checks']['sources_unchanged_during_study'] = True
        result['passed'] = all(result['checks'].values())
        assert result['passed'], result['checks']
        audits[str(seed)] = result
        summaries.append(summary)
        rows = []
        for run in trace['runs']:
            row = {k:v for k,v in run.items() if k not in ['kill_records','fire_waves','upgrade_levels']}
            loadout = replay['loadouts'][str(int(run['run']))]
            row.update(level=int(run['prestige'])+1, max_hp=loadout['stats']['MaxHP'],
                starting_armor=loadout['stats'].get('Armor',0),
                powers='; '.join(k for k in ['ArrowShield','Harvester','Shuriken','SlowDown','GhostPower'] if loadout['unlocks'].get(k)),
                fire_hits=run['fire_waves']['hits'], fire_dodged=run['fire_waves']['dodged'])
            rows.append(row)
        exports = dict(runs=rows, choices=trace['choices'], claims=trace['claims'],
            kills=[dict(run=r['run'],level=int(r['prestige'])+1,**k) for r in trace['runs'] for k in r['kill_records']],
            waves=[dict(run=r['run'],level=int(r['prestige'])+1,**w) for r in trace['runs'] for w in r['fire_waves']['records']])
        for kind, rows in exports.items():
            export_csv(folder/f'{seed}_{kind}.csv', rows)
            if seed==2401026: export_csv(folder/f'{kind}.csv', rows)
    (folder/'summary.json').write_text(json.dumps(summaries,indent=2)+'\n',encoding='utf8')
    (folder/'audit.json').write_text(json.dumps(dict(passed=True,seeds=audits),indent=2)+'\n',encoding='utf8')
    main_seed = next(s for s in summaries if s['seed']==2401026)
    old = read(MODULE/'Simulation/CrownValidation/campaign.json')
    lines = ['# Current Free Aim playthrough — 27 October 2026','',
        'Three fresh campaigns use the current 125-node tree and regenerated combat. All completed all four levels and paid the final chamber fee. No gameplay balance or player saves were changed.','',
        '| Seed | Runs | Level 1 attempts | Level 2 attempts | Level 3 attempts | Level 4 attempts | Diving time at 1x |',
        '|---:|---:|---:|---:|---:|---:|---:|']
    for s in summaries:
        attempts=' | '.join(str(v['attempts_to_first_clear']) for v in s['levels'])
        lines.append(f"| {s['seed']} | {s['runs']} | {attempts} | {s['seconds']/60:.1f} min |")
    lines += ['', 'Attempts count through the first clear of each level. Total runs also include any final-fee farming. Diving time excludes menus and buying, and is simulation time, not CPU time.','',
        '## Primary trace: seed 2401026','',
        '| Level | Total runs | Enemies defeated | Kills/run (min–max) | Mean kill distance | Kills at >=80% range |',
        '|---:|---:|---:|---:|---:|---:|']
    for level in main_seed['levels']:
        lines.append(f"| {level['level']} | {level['total_runs']} | {level['kills']} | {level['mean_kills']:.1f} ({level['min_kills']}–{level['max_kills']}) | {level['mean_kill_range']:.2f} m | {level['near_max_fraction']:.1%} |")
    lines += ['',f"Deaths: {', '.join(f'{cause}: {count}' for cause,count in main_seed['deaths'].items())}.",
        f"Across {main_seed['kills']:,} kills, mean separation was {main_seed['mean_kill_range']:.2f} m, median {main_seed['median_kill_range']:.2f} m. {main_seed['near_max_fraction']:.1%} died at >=80% current attack range; {main_seed['close_fraction']:.1%} died within 2 m.",
        f"Hallway deaths with a majority of kills at >=80% range occurred on runs {main_seed['row_deaths_with_majority_far_kills'] or 'none'}. Per-run details are in runs.csv; every kill is in kills.csv.",'',
        f"{main_seed['purchases']} purchases and {main_seed['claims']} achievement claims were recorded. Achievement rewards totaled {main_seed['achievement_rewards']} (gold/gems/crowns). {main_seed['maxed_nodes']} nodes were maxed; the final chamber requires {catalog['settings']['ending_maxed_nodes']}.",
        f"Fire waves hit {main_seed['wave_hits']} times in {main_seed['wave_crossings']} crossings. The trace records hits/dodges separately by boss stage.",'',
        'Run distance is forward hallway reach; path_distance includes strafing. Kill range is horizontal separation from the player at death, normalized against the current attack range for the near-maximum measure.','',
        '## Current powers and policy','',
        'The model includes Shield halving incoming damage, Magpie doubling non-crown pickups, Arrow Storm projectiles, Regen tied to walking drain, and Ghost suppressing ordinary enemy aggression while bosses remain aware. Each power lasts 10 seconds and recharges for 30 seconds after expiry. The pilot activates unlocked powers whenever ready. Powers are not assumed unlocked at the start.','',
        '| Power | Bought after run | Level |','|---|---:|---:|']
    for p in main_seed['powers']: lines.append(f"| {p['power']} | {p['after_run']} | {p['level']} |")
    diagnostic = read(folder/'power_shortlist_diagnostic.json')
    best = diagnostic['recommendation']
    actual = next(c for c in read(folder/'campaign.json')['choices'] if c['after_run']==30)
    assert actual['baseline']==best['baseline'], 'Diagnostic must use the identical shop state and decision seed.'
    lines += ['', '### Exhaustive power diagnostic', '',
        f"At the primary seed's actual wallet/build after run 30, all {len(best['alternatives'])} affordable upgrades were forecast with the same decision seed. The best single purchase was {best['name']} for {best['price']} gold. It improved forecast reach from {best['baseline']['distance']:.1f} m to {best['predicted']['distance']:.1f} m and gold from {best['baseline']['gold']:.0f} to {best['predicted']['gold']:.0f}. The normal shortlist instead chose {actual['name']}; Shield was not among its tested alternatives.",
        'This is a one-decision diagnostic, not a fourth full campaign. The primary three traces deliberately retain the current editor buying policy. See power_shortlist_diagnostic.json for all affordable alternatives.','']
    lines += ['',
        'The same editor buyer policy is retained: 60% reach, 28% gold rate, 12% gem rate, two forecast candidates per purchase. Achievements are claimed before shopping and after every purchase, including rewards that fund more buying. The pilot has a 0.18-second reaction interval, aiming error, six clicks/second before Auto, dodges observed threats and moves to collect payouts. All contact, hallway, fire-wave and enemy-projectile damage remains active. It is a reproducible heuristic, not a measured human or a globally optimal purchase search.','',
        'Buyer limitation: its inexpensive shortlist proxy explicitly values Magpie but has no direct value term for Shield, Regen, Arrow Storm or Ghost. Their actual combat effects are included once forecasted, but they can be omitted from the two-candidate shortlist. Late power purchases therefore expose a limitation of the current buyer as well as game progression; they are not proof that those powers are weak.','',
        f"The prior same-seed crown study took {len(old['runs'])} runs; the current version takes {main_seed['runs']}. This compares all intervening changes together, not the isolated effect of one power.",'',
        '## Verification and files','',
        'Six full-run native/model comparisons pass for fresh, maxed and no-fire-control loadouts. The current native shop gates and 161 power checks pass. All three traces replay their purchases, claims and combat results deterministically, and independent audits reconcile rewards, prices, prerequisites and all three currencies including the ending fee. Both actual ending choices accept each completed build in six additional cases with persistence disabled.','',
        '- `campaign*.json`: complete trials and scored alternatives.',
        '- `runs.csv`, `choices.csv`, `claims.csv`, `kills.csv`, `waves.csv`: primary trace; seed-prefixed copies hold the other two.',
        '- `replay_<seed>.json`: exact starting loadout for every run and replay checks.',
        '- `summary.json`, `audit.json`, `runtime/`: machine-readable findings and checks.',
        '- `SourceSnapshot/`, `installed_sources.json`: frozen runtime inputs and hashes.','']
    (folder/'REPORT.md').write_text('\n'.join(lines),encoding='utf8')
    print(json.dumps(summaries,indent=2))


if __name__=='__main__': main()
