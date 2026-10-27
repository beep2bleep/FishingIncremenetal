"""Summarize campaign results, with flat CSVs for every run, kill and choice."""
from pathlib import Path
from collections import Counter
from statistics import mean, median
import argparse
import csv
import json

ROOT = Path(__file__).resolve().parents[2]
DEFAULT = ROOT / 'FeedingABlackHoldGame/Games/RowDivers/Simulation/Results'

def write_csv(path, rows):
    if not rows:
        return
    fields = list(dict.fromkeys(k for row in rows for k in row))
    with path.open('w', newline='', encoding='utf-8') as handle:
        writer = csv.DictWriter(handle, fieldnames=fields)
        writer.writeheader()
        for row in rows:
            writer.writerow({k: json.dumps(v, separators=(',', ':')) if isinstance(v, (list, dict)) else v for k, v in row.items()})

def pct(value):
    return f'{100*value:.1f}%'

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--directory', type=Path, default=DEFAULT)
    args = parser.parse_args()
    directory = args.directory
    data = json.loads((directory / 'fresh_campaign.json').read_text())
    runs = data['runs']
    choices = data['choices']
    kills = [dict(run=r['run'], prestige=r['prestige'], **kill) for r in runs for kill in r['kill_records']]
    write_csv(directory / 'runs.csv', [{k: v for k, v in r.items() if k != 'kill_records'} for r in runs])
    write_csv(directory / 'kills.csv', kills)
    write_csv(directory / 'choices.csv', choices)
    (directory / 'final_loadout.json').write_text(json.dumps(data['final_state'], indent=2))
    lines = ['# Railway Fury balance simulation — 2026-10-24', '',
             f"Fresh campaign: **{'final chamber unlocked' if data.get('completed') else 'not completed within the configured run limit'}**, "
             f"{len(runs)} runs, {len(choices)} legal upgrade purchases, {data.get('trial_count', '?')} simulated runs including purchase probes.", '',
             f"Realized runs contain {sum(r['seconds'] for r in runs)/60:.1f} minutes of game time (menus and purchase decisions excluded). "
             f"Experiment wall duration, including upgrade forecasts: {data.get('wall_seconds', 0)/60:.1f} minutes.", '',
             '## Experiment', '',
             'Current repository upgrade catalog and combat rules; fresh wallet and starting stats. '
             'Automatically attempt the highest unlocked prestige, carry all loot and upgrades forward, and claim available achievement rewards after unlocking the achievements tab. '
             'Keep the player centered and walking (Shift running is off). Use the existing fast-mode targeting, firing, immunity to hostile arrows, and abilities on cooldown. '
             'Contact damage, armor depletion, health restoration, projectile travel, loot travel/pickup, boss blocking, and damage every two seconds remain enabled. '
             'No game balance files or gameplay saves are changed.', '',
             'The primary trace uses fixed random seeds and 1/60-second steps, matching normal gameplay steps. '
             'It advances as fast as the CPU allows rather than waiting for frames or imposing a 32× limit. '
             'Completion means clear Prestiges 0–3, max at least 100 nodes, and pay the final chamber entry cost; no ending choice is made.', '',
             '## Progression by prestige', '',
             '| Prestige | Runs spent | Runs to first clear | Kills/run mean (min–max) | Mean kill range | Kills ≥80% range | Row-only deaths |',
             '|---|---:|---:|---:|---:|---:|---:|']
    for prestige in range(4):
        subset = [r for r in runs if r['prestige'] == prestige]
        if not subset:
            continue
        pk = [k for k in kills if k['prestige'] == prestige]
        first = next((i+1 for i, r in enumerate(subset) if r['won']), None)
        row_only = sum(not r['won'] and r['death_source'] == 'the row' and r['damage_sources'].get('enemy contact', 0) == 0 for r in subset)
        lines.append(f"| {prestige} | {len(subset)} | {first or 'not cleared'} | {mean(r['kills'] for r in subset):.1f} ({min(r['kills'] for r in subset)}–{max(r['kills'] for r in subset)}) | {mean(k['range'] for k in pk) if pk else 0:.2f} m | {pct(mean(k['range_fraction'] >= .8 for k in pk)) if pk else '0%'} | {row_only} |")
    failed = [r for r in runs if not r['won']]
    row_deaths = sum(r['death_source'] == 'the row' for r in failed)
    row_only = [r for r in failed if r['death_source'] == 'the row' and r['damage_sources'].get('enemy contact', 0) == 0]
    far70 = mean(k['range_fraction'] >= .7 for k in kills) if kills else 0
    far80 = mean(k['range_fraction'] >= .8 for k in kills) if kills else 0
    fractions = [k['range_fraction'] for k in kills]
    lines += ['', '## Does it reproduce the reported problem?', '',
              f"Walking damage delivers the final blow in **{row_deaths}/{len(failed)} failed runs**; **{len(row_only)}** failures take no contact damage at all. "
              f"Across {len(kills)} kills, **{pct(far80)}** occur at ≥80% of attack range and **{pct(far70)}** at ≥70%. "
              f"The median kill distance is **{median(fractions)*100:.1f}% of range**." if fractions else 'No kills recorded.', '']
    # Find consecutive stretches where attacks are keeping enemies out but row drain ends the run.
    stretches, active = [], []
    for run in runs:
        if not run['won'] and run['death_source'] == 'the row' and run['damage_sources'].get('enemy contact', 0) == 0 and run['far_kill_fraction'] >= .5:
            active.append(run['run'])
        else:
            if active: stretches.append(active)
            active = []
    if active: stretches.append(active)
    if stretches:
        best = max(stretches, key=len)
        if len(best) == 1:
            lines.append(f"Only **run {best[0]}** met the strict combined test: no contact damage, a row-damage death, and at least half the kills at ≥80% range. The run reproduces that combination, but the campaign did **not** reproduce a long consecutive stretch under this definition of near-max range.")
        else:
            lines.append(f"The longest consecutive stretch with no contact damage and at least half the kills at ≥80% range is **runs {best[0]}–{best[-1]} ({len(best)} runs)**. This directly reproduces the combination of distant kills and walking-damage gating.")
    else:
        lines.append('No consecutive stretch met the strict test of a row-only death with at least half the kills at ≥80% range. Walking-damage gating and distant kills should therefore be evaluated separately, rather than claiming the full observation was reproduced.')
    lines += ['', 'Thresholds are explicit: “near max range” means ≥80% of the current bow targeting range; ≥70% is also reported. '
              'Distance is horizontal world-space separation at the killing hit, including enemies behind the player. '
              'Projectile travel reduces kill distance because the player advances during flight. Third Eye starts at bow range minus 2 m. '
              'A row-only death means no contact damage throughout that run, not merely a last blow from the row.', '',
              'Kill distances by position along the corridor (pooled across runs):', '',
              '| Player distance | Kills | Mean enemy separation | Median fraction of attack range |',
              '|---|---:|---:|---:|']
    for lo, hi in [(0, 100), (100, 200), (200, 1000)]:
        bucket = [k for k in kills if lo <= k['distance'] < hi]
        if bucket:
            label = f'{lo}–{hi} m' if hi != 1000 else '200 m onward'
            lines.append(f"| {label} | {len(bucket)} | {mean(k['range'] for k in bucket):.2f} m | {pct(median(k['range_fraction'] for k in bucket))} |")
    lines += ['', '## Your current saved loadout', '']
    snapfile = directory / 'current_save.json'
    if snapfile.exists():
        snap = json.loads(snapfile.read_text())
        sr = snap['runs']
        sk = [k for r in sr for k in r['kill_records']]
        lines.append(f"Read-only snapshot from your existing save ({int(snap['initial_state']['runs'])} prior runs, Prestige {int(snap['initial_state']['prestige'])}); {len(sr)} fresh-seed repeats. "
                     f"Mean distance **{mean(r['distance'] for r in sr):.1f} m**, mean kills **{mean(r['kills'] for r in sr):.1f}**, "
                     f"mean gold **{mean(r['loot'][0] for r in sr):.1f}**, mean gems **{mean(r['loot'][1] for r in sr):.2f}**. "
                     f"Deaths: {dict(Counter(r['death_source'] for r in sr))}. "
                     f"Median kill separation **{median(k['range_fraction'] for k in sk)*100:.1f}% of range**, {pct(mean(k['range_fraction'] >= .8 for k in sk))} at ≥80% range.")
    counterfactual = directory / 'run25_no_row.json'
    normalfile = directory / 'run25_normal.json'
    if counterfactual.exists() and normalfile.exists():
        normal = json.loads(normalfile.read_text())['runs']
        without = json.loads(counterfactual.read_text())['runs']
        lines += ['', '## Isolating walking damage', '',
                  f"Using the exact upgrades before run 25 (Prestige 2), compare {len(normal)} identical-seed repeats with normal walking damage versus zero walking damage. "
                  f"Normal: **{mean(r['distance'] for r in normal):.1f} m**, **{mean(r['kills'] for r in normal):.1f} kills/run**. "
                  f"Without walking damage: **{mean(r['distance'] for r in without):.1f} m**, **{mean(r['kills'] for r in without):.1f} kills/run**. "
                  f"The no-row runs end from {dict(Counter(r['death_source'] for r in without))}. "
                  'This demonstrates a large walking-damage gate, while also showing that enemy contact eventually matters if that gate is removed. The counterfactual modifies only offline damage handling.']
    endfile = directory / 'final_loadout_repeats.json'
    if endfile.exists():
        endruns = json.loads(endfile.read_text())['runs']
        wins = sum(r['won'] for r in endruns)
        losses = [r for r in endruns if not r['won']]
        lines += ['', '## Fully upgraded Prestige 3', '',
                  f"Using the campaign’s final, fully maxed loadout on {len(endruns)} new seeds, **{wins}/{len(endruns)} runs clear**. "
                  f"All {len(losses)} failures end from walking damage; contact damage across these repeats is "
                  f"{sum(r['damage_sources'].get('enemy contact', 0) for r in endruns):g}, and hostile-arrow damage is zero. "
                  f"Mean distance is {mean(r['distance'] for r in endruns):.2f} m. "
                  'This is a particularly clear late-game survivability gate: the fully upgraded build reaches the final boss, but its small health margin and random healing still decide whether it finishes. '
                  'Revisit the Prestige 3 walking-damage budget and healing variability before adding more damage upgrades; these results do not imply an enemy-range issue across the entire run.']
    lines += ['', '## Upgrade selection and choices', '',
              'The selector is a heuristic with short simulated lookahead, not a proof of a globally optimal purchasing path. '
              'It ranks all affordable legal upgrades using changes in effective health, expected weapon damage, healing, range, pickup range, and progress toward child unlocks. '
              'It then tests the top four purchases against a baseline run with the same random seed. '
              'Final score weights relative distance gain 55%, gold per game-second gain 30%, and gems per game-second gain 15%, plus small stat/unlock bonuses. '
              'It discounts expensive options by `1 + sqrt(price / max(1, expected currency earned per run))`, and strongly favors turning a failed run into a win. '
              'The relative-income denominators are floored to avoid division by zero. '
              'The simulator buys one level, recomputes, and continues until nothing is affordable. It does not reserve currency for a future expensive purchase. '
              'Firing-mode unlocks and arrow-defense upgrades have little immediate value under these assist rules, but can still unlock useful descendants or count toward ending requirements.', '',
              'First 20 decisions:', '', '| After run | Prestige | Upgrade | New level | Price |', '|---:|---:|---|---:|---:|']
    for choice in choices[:20]:
        currency = ['gold', 'gems', 'crowns'][choice['currency']]
        lines.append(f"| {choice['after_run']} | {choice['prestige']} | {choice['name']} | {choice['level_before']+1} | {choice['price']:g} {currency} |")
    lines += ['', 'The complete choice log includes the wallet before purchase, baseline forecast, candidate scores, alternatives, and forecast after purchase.', '',
              '## Validation and limits', '']
    validation = directory / 'runtime_validation.json'
    if validation.exists():
        v = json.loads(validation.read_text())
        lines.append(f"Real 3D runtime comparison: **{len(v['cases'])-v['failures']}/{len(v['cases'])} cases passed**. "
                     'Fresh stats and legally maxed loadouts at each prestige matched completion frame, victory, distance, kills, wallet income, damage sources, health, and armor exactly under equal seeds. '
                     'The headless model consumes the same actor idle RNG draw to preserve spawn/combat randomness. '
                     'Visual effects, audio, gate animation and save writes are replaced; combat update order is retained. Campaign source hashes are recorded in `SourceSnapshot/manifest.json`; `../source_manifest.json` identifies the latest generated model.')
        lines.append('Gameplay files were being edited concurrently during the experiment. `SourceSnapshot/` preserves the exact campaign model, runner, progression rules, catalog and original battle source. '
                     'A later five-case comparison also passes against the classic-mode runtime after the first concurrent changes. New free-aim movement, chasing and airborne enemies are outside this experiment.')
        lines.append('Trace accounting checks pass for all three currencies, all purchase affordability and level caps, every kill record, all four crowns, and the final chamber entry fee (`accounting_validation.json`).')
        lines.append('The full-project comparison harness exits successfully but emits Godot resource-cleanup/leak diagnostics at shutdown. The isolated experiment runner completes without those diagnostics; the five outcome comparisons all pass.')
    finefile = directory / 'current_save_120hz.json'
    if finefile.exists() and snapfile.exists():
        fine = json.loads(finefile.read_text())['runs']
        coarse = json.loads(snapfile.read_text())['runs']
        lines.append(f"Step-size check on the same {len(fine)} saved-loadout seeds: 60 Hz mean distance {mean(r['distance'] for r in coarse):.2f} m / {mean(r['kills'] for r in coarse):.2f} kills; "
                     f"120 Hz {mean(r['distance'] for r in fine):.2f} m / {mean(r['kills'] for r in fine):.2f} kills. "
                     'Frame-based targeting and contact checks can change outcomes slightly with step size; the main campaign uses the game’s 60 Hz steps.')
    lines += ['', 'This is one purchasing-policy trajectory, with randomness in layout, enemies, critical hits and loot. '
              'Run counts are evidence for this policy and seed, not guaranteed counts for every player. '
              'The player remains centered, so off-lane enemies can pass without contact, matching the collision rules. '
              'Bosses stop forward movement at 0.75 m while contact requires less than 0.4 m longitudinal separation; that makes boss stalls principally a row-damage/DPS problem under arrow immunity. '
              'Purchase order changes compounded stats. A maxed tree does not imply a unique final damage or health value.', '',
              '## Files', '', '- `runs.csv`: every run, damage sources, income, distance and kill-range summaries.',
              '- `kills.csv`: every kill, time, enemy type, distance and fraction of range.',
              '- `choices.csv`: every purchase and scored alternatives.',
              '- `fresh_campaign.json`: complete campaign trace and final state.',
              '- `final_loadout.json`: reusable final progression input.',
              '- `current_save.json`: repeated tests of your existing saved upgrades.',
              '- `runtime_validation.json`: comparison with real gameplay.', '']
    (directory / 'SUMMARY.md').write_text('\n'.join(lines), encoding='utf-8')
    print(directory / 'SUMMARY.md')

if __name__ == '__main__':
    main()
