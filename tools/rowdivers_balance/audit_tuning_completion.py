"""Inspect installed files and behavioral evidence for the whole tuning objective."""
from pathlib import Path
from copy import deepcopy
import hashlib
import json
from report_tuning import summarize, audit
from tune_trees import EXPERIMENTS, MODULE, metrics

def sha(path): return hashlib.sha256(path.read_bytes()).hexdigest()

def main():
    summary = summarize()
    manifest = json.loads((EXPERIMENTS/'installed_tree.json').read_text())
    selected = manifest['profile']
    control_profile = manifest.get('control_profile', 'control_v4')
    source = EXPERIMENTS/'SourceSnapshot/row_divers.json'
    original = json.loads(source.read_text())
    current_path = MODULE/'Data/row_divers.json'
    current = json.loads(current_path.read_text())
    previous = MODULE/'Data/row_divers_previous.json'
    normalized = deepcopy(current)
    for old, node in zip(original['upgrades'], normalized['upgrades']):
        for field in ['baseUpgradeCost','unlockAtParentLevel','upgradeDescription']:
            node[field] = old[field]
        for old_effect,effect in zip(old['effects'],node['effects']): effect['amount'] = old_effect['amount']
    rows = [r for r in summary['campaigns'] if r['profile']==selected]
    controls = [r for r in summary['campaigns'] if r['profile']==control_profile]
    traces = [json.loads((EXPERIMENTS/selected/r['file']).read_text()) for r in rows]
    control_traces = [json.loads((EXPERIMENTS/control_profile/r['file']).read_text()) for r in controls]
    checks = {}
    checks['installed_catalog_matches_manifest'] = sha(current_path)==manifest['installed_sha256']
    checks['only_upgrade_numeric_values_and_derived_descriptions_changed'] = normalized==original
    checks['previous_catalog_byte_identical'] = sha(previous)==sha(source)
    checks['combat_code_unchanged'] = sha(MODULE/'Scenes/RowDiversBattleScene.gd')==sha(EXPERIMENTS/'SourceSnapshot/RowDiversBattleScene.gd.txt')
    checks['multiple_complete_tree_variants'] = len(summary['campaigns'])>=3 and len({r['profile'] for r in summary['campaigns']})>=3
    checks['three_selected_campaigns_complete'] = len(rows)==3 and all(r['completed'] and r['audit_passed'] for r in rows)
    checks['matched_policy_three_seed_control'] = len(controls)==3 and all(a['config']['weights']==b['config']['weights'] and a['config']['shortlist']==b['config']['shortlist'] and a['config'].get('purchase_buffer',False)==b['config'].get('purchase_buffer',False) and a['config'].get('purchase_buffer_min_prestige',0)==b['config'].get('purchase_buffer_min_prestige',0) and a['config']['runner_sha256']==b['config']['runner_sha256'] for a,b in zip(traces,control_traces))
    if selected == 'round_numbers_p3_buffer':
        prefixes = {}
        for name, source_name, group in [(selected,'round_numbers',rows),(control_profile,'control_v4',controls)]:
            for row in group:
                trace=json.loads((EXPERIMENTS/name/row['file']).read_text())
                prior=json.loads((EXPERIMENTS/source_name/row['file']).read_text())
                prefix=[r for r in trace['runs'] if r['prestige']<3]
                prefixes[name+'/'+row['file']]={'runs_checked':len(prefix),'identical_to_original_spending_policy':all(r==prior['runs'][i] for i,r in enumerate(prefix))}
        (EXPERIMENTS/'policy_prefix_validation.json').write_text(json.dumps(prefixes,indent=2)+'\n')
        checks['early_prestige_outcomes_preserved'] = len(prefixes)==6 and all(p['identical_to_original_spending_policy'] for p in prefixes.values())
    checks['similar_campaign_length'] = abs(sum(r['runs'] for r in rows)/sum(r['runs'] for r in controls)-1)<=.10
    checks['more_consistent_forward_progress'] = sum(r['advances'] for r in rows)/sum(r['comparable_transitions'] for r in rows) > sum(r['advances'] for r in controls)/sum(r['comparable_transitions'] for r in controls)
    checks['upgrade_purchase_after_every_run'] = all(not r['no_purchase_runs'] for r in rows)
    checks['close_enemies_in_every_campaign'] = all(r['runs_with_close_kills']>0 and r['close_kill_fraction']>.05 for r in rows)
    checks['occasional_contact_deaths'] = all(0<r['contact_deaths']<r['runs']*.5 for r in rows)
    checks['legitimate_resource_accounting'] = all(audit(t,current)['passed'] and t['initial_state']['wallet']==[0,0,0] for t in traces)
    checks['all_three_replays_match'] = all(json.loads((EXPERIMENTS/f"replay_{int(t['config']['seed'])}.json").read_text())['replay_passed'] for t in traces)
    for name in ['runtime_validation','runtime_validation_previous']:
        result=json.loads((EXPERIMENTS/(name+'.json')).read_text())
        checks[name] = result['failures']==0 and len(result['cases'])>=6 and all(c['runtime']==c['model'] for c in result['cases'])
        if name=='runtime_validation':
            checks['runtime_validated_same_candidate_values'] = result.get('catalog_sha256')==sha(EXPERIMENTS/selected/'catalog.json')
    switch = json.loads((EXPERIMENTS/'switch_validation.json').read_text())
    checks['live_setting_save_restore_and_shop'] = switch['passed'] and all(switch['checks'].values())
    integrity=json.loads((EXPERIMENTS/'old_save_integrity.json').read_text())
    path=Path(integrity['path'])
    now=sha(path) if path.exists() else None
    checks['original_save_untouched'] = integrity['unchanged'] and integrity['before_sha256']==now
    achievement=json.loads((EXPERIMENTS/'achievement_validation.json').read_text())
    checks['bow_master_still_achievable'] = achievement['passed'] and achievement['arrow_damage']>=60000000 and achievement['all_nodes_maxed']
    for name in ['maxed_repeat20','final_build_repeat20']:
        result=json.loads((EXPERIMENTS/(name+'.json')).read_text())
        checks[name] = len(result['runs'])==20 and result['initial_state']['prestige']==3 and all(r['won'] and not r['capped'] and any(k['kind']==6 for k in r['kill_records']) for r in result['runs'])
    checks['report_and_exact_values_present'] = (EXPERIMENTS/'TUNING_REPORT.md').exists() and (EXPERIMENTS/'installed_value_changes.csv').exists()
    checks['per_run_kill_and_purchase_logs_present'] = all((EXPERIMENTS/selected/(Path(r['file']).stem+suffix+'.csv')).exists() for r in rows for suffix in ['_runs','_choices','_kills'])
    rewards=json.loads((EXPERIMENTS/'reward_rounding_audit.json').read_text())
    checks['rewards_reinvested_and_upgrade_increments_clean'] = rewards['passed'] and rewards['profile']==selected
    result = {'passed':all(checks.values()), 'checks':checks,
        'soft_target':{'name':'farther on every individual attempt','advancing_attempts':sum(r['advances'] for r in rows),'comparable_attempts':sum(r['comparable_transitions'] for r in rows),'distance_regressions':sum(r['regressions'] for r in rows),'note':'Improved steady progression; random-contact setbacks remain, as reported. Every run makes a permanent upgrade purchase.'}}
    (EXPERIMENTS/'completion_audit.json').write_text(json.dumps(result,indent=2))
    print(json.dumps(result,indent=2))
    raise SystemExit(0 if result['passed'] else 1)

if __name__=='__main__': main()
