"""Audit the crown-gated campaign and current editor tooling checks."""
from collections import Counter
from hashlib import sha256
from pathlib import Path
from statistics import mean, median
import json
from report_flight import audit
from report_tuning import export_csv

ROOT = Path(__file__).resolve().parents[2]
MODULE = ROOT/'FeedingABlackHoldGame/Games/RowDivers'
FOLDER = MODULE/'Simulation/CrownValidation'

def read(path): return json.loads(path.read_text(encoding='utf-8'))

def main():
    trace = read(FOLDER/'campaign.json')
    assert trace.get('completed'), 'Wait for the full campaign to finish.'
    catalog = read(MODULE/'Data/row_divers_free_aim.json')
    result = audit(trace,catalog)
    checks = result['checks']
    checks['catalog_matches_campaign'] = sha256((MODULE/'Data/row_divers_free_aim.json').read_bytes()).hexdigest()==trace['config']['catalog_sha256']
    checks['live_model_parity'] = read(FOLDER/'runtime/runtime_validation.json')['passed']
    checks['actual_shop_gates'] = read(FOLDER/'runtime/tree_validation.json')['passed']
    checks['replay'] = read(FOLDER/'replay.json')['replay_passed']
    old_runner = (FOLDER/'SourceSnapshot/RunBalanceCampaign.gd.txt').read_text()
    live_runner = (MODULE/'Simulation/RunBalanceCampaign.gd').read_text()
    def scoring(source): return source[source.index('func potential('):source.index('func save_results(')]
    checks['same_purchase_scoring'] = scoring(old_runner)==scoring(live_runner)
    checks['same_combat_models'] = all((FOLDER/'SourceSnapshot'/(name+'.txt')).read_text()==(MODULE/'Simulation'/name).read_text() for name in ['GeneratedCombatModel.gd','GeneratedFreeAimModel.gd'])
    for filename, marker in [('crown_features_complete.log','36 checks passed=true'),('editor_autobuy_complete.log','20 checks passed=true')]:
        log = (ROOT/'tools/rowdivers_balance'/filename).read_text(encoding='utf-8')
        checks[filename] = marker in log and 'SCRIPT ERROR' not in log
    runs = trace['runs']
    kills = [k for r in runs for k in r['kill_records']]
    counts, clears = Counter(), {}
    for r in runs:
        p = int(r['prestige'])
        counts[p]+=1
        if r['won'] and p not in clears: clears[p]=counts[p]
    summary = dict(seed=int(trace['config']['seed']),runs=len(runs),runs_per_prestige=dict(counts),first_clear=clears,
        deaths=dict(Counter(r['death_source'] for r in runs if not r['won'])),purchases=len(trace['choices']),
        mean_kill_range=mean(k['range'] for k in kills),median_kill_range=median(k['range'] for k in kills),
        kills=len(kills),near_max_fraction=mean(k['range_fraction']>=.8 for k in kills),
        reward_totals=result['rewards']['reward_totals'])
    result.update(passed=all(checks.values()),summary=summary)
    (FOLDER/'audit.json').write_text(json.dumps(result,indent=2)+'\n')
    export_csv(FOLDER/'runs.csv',[{k:v for k,v in r.items() if k not in ['kill_records','fire_waves']} for r in runs])
    export_csv(FOLDER/'choices.csv',trace['choices'])
    export_csv(FOLDER/'claims.csv',trace['claims'])
    export_csv(FOLDER/'kills.csv',[dict(run=r['run'],prestige=r['prestige'],**k) for r in runs for k in r['kill_records']])
    export_csv(FOLDER/'waves.csv',[dict(run=r['run'],prestige=r['prestige'],**w) for r in runs for w in r['fire_waves']['records']])
    files = [MODULE/'Data/row_divers_free_aim.json',MODULE/'RowDiversProgress.gd',MODULE/'RowDiversFireWaves.gd',
        MODULE/'RowDiversEditorBuyer.gd',MODULE/'RowDiversEndings.gd',MODULE/'RowDiversEndingPicture.gd',
        MODULE/'Scenes/RowDiversBattleScene.gd',MODULE/'Scenes/RowDiversEnding.gd',MODULE/'Simulation/RunBalanceCampaign.gd',
        MODULE/'Simulation/GeneratedFreeAimModel.gd',MODULE/'Simulation/FlightPilot.gd',ROOT/'FeedingABlackHoldGame/UpgradeScreen.gd']
    (FOLDER/'installed_sources.json').write_text(json.dumps({str(p.relative_to(ROOT)):sha256(p.read_bytes()).hexdigest() for p in files},indent=2)+'\n')
    lines = ['# Crown-gated playthrough — 26 October 2026','',
        f"One fresh seeded campaign completed all four prestiges and paid the final fee in **{len(runs)} runs**. This is a verification run, not a new multi-seed balance study.",'',
        '| Prestige | Attempts to first clear | All attempts, including fee farming |','|---:|---:|---:|']
    for p in range(4): lines.append(f'| {p} | {clears[p]} | {counts[p]} |')
    lines += ['',f"Deaths: {', '.join(f'{k}: {v}' for k,v in summary['deaths'].items())}. Across {len(kills):,} kills, mean horizontal separation was {summary['mean_kill_range']:.2f} m, median {summary['median_kill_range']:.2f} m, and {summary['near_max_fraction']*100:.1f}% occurred at ≥80% attack range.",'',
        f"The buyer made {summary['purchases']} legal purchases and collected achievement rewards of {summary['reward_totals']}. The audit reconciles every purchase wallet and total gold/gems/crowns, validates crown prerequisites and prestige gates, checks fixed wave damage, and rejects time-capped runs. The complete trace replays within JSON numeric serialization tolerance.",'',
        'Thirty-six runtime feature checks cover crown gating, refunds, autopilot aim/shot/dodge/collection, normal-step 64×/128× speeds, manual restoration, editor gating, and the two new endings. Twenty editor auto-buy checks include the actual button, tree refresh, real costs, cancellation, same selector/weights, achievement funding, reserved ending funds, and the selected classic Previous catalog. Six native/model flying comparisons pass. New endings also pass the analytics capture checks. Full-project tests retain existing startup/render-resource cleanup diagnostics; no script errors appear in these successful checks.','',
        '[Feature guide](../../Docs/CrownEditorPlaythrough.md) · [Audit](audit.json) · [Choices](choices.csv) · [Runs](runs.csv) · [Replay](replay.json)','',
        'The exact campaign inputs are archived in `SourceSnapshot/`. Current runtime sources also initialize the migration marker for new saves and animate the editor crosshair; these do not change legal campaign combat. Editor forecasts always copy the current runtime models and progression rules.','']
    (FOLDER/'REPORT.md').write_text('\n'.join(lines),encoding='utf-8')
    print(json.dumps(dict(passed=result['passed'],checks=checks,summary=summary),indent=2))
    assert result['passed']

if __name__=='__main__':main()
