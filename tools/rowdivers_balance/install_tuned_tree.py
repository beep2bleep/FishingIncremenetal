"""Install an audited, multi-seed, value-only catalog and preserve the previous one."""
from pathlib import Path
from copy import deepcopy
import argparse
import json
import hashlib
import csv
from tune_trees import EXPERIMENTS, MODULE, metrics
from report_tuning import audit

LABELS = {'MaxHP':'maximum health','Armor':'armor','Arrow_Damage':'arrow damage',
    'Dagger_Damage':'dagger damage','Beam_Damage':'Third Eye damage','Bow_Fire_Rate':'bow fire rate',
    'Dagger_Attack_Rate':'dagger attack rate','Distance_Range':'bow range','Melee_range':'dagger range',
    'Damage_Against_Bosses':'bonus damage against bosses','Impact_Armor':'contact damage reduction'}

def sha(path): return hashlib.sha256(path.read_bytes()).hexdigest()

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('profile')
    parser.add_argument('--control-profile', default='control_v4')
    args = parser.parse_args()
    folder = EXPERIMENTS / args.profile
    original_path = EXPERIMENTS / 'SourceSnapshot/row_divers.json'
    original = json.loads(original_path.read_text())
    catalog = json.loads((folder / 'catalog.json').read_text())
    previous_path = MODULE / 'Data/row_divers_previous.json'
    assert sha(previous_path) == sha(original_path), 'Previous tree must remain byte-identical to the captured original'
    traces = []
    for path in sorted(folder.glob('campaign*.json')):
        data = json.loads(path.read_text())
        if 'runs' not in data: continue
        assert data.get('completed'), f'Campaign not complete: {path}'
        assert audit(data, catalog)['passed'], f'Campaign accounting failed: {path}'
        assert not metrics(data)['no_purchase_runs'], f'Empty-upgrade runs: {path}'
        traces.append({'file': str(path.relative_to(EXPERIMENTS)), 'sha256': sha(path), 'seed': data['config']['seed']})
    assert len({t['seed'] for t in traces}) >= 3, 'At least three completed independent campaign seeds required'
    changes = []
    comparison = deepcopy(catalog)
    for old, new, normalized in zip(original['upgrades'], catalog['upgrades'], comparison['upgrades']):
        assert old['id'] == new['id']
        for key in ['baseUpgradeCost','unlockAtParentLevel']:
            if old[key] != new[key]:
                changes.append(dict(upgrade=new['upgradeName'], field=key, previous=old[key], rebalanced=new[key]))
            normalized[key] = old[key]
        effect_changed = False
        for index, (old_effect,new_effect) in enumerate(zip(old['effects'],new['effects'])):
            if old_effect['amount'] != new_effect['amount']:
                effect_changed = True
                changes.append(dict(upgrade=new['upgradeName'], field='effects.'+new_effect['stat'], previous=old_effect['amount'], rebalanced=new_effect['amount']))
            normalized['effects'][index]['amount'] = old_effect['amount']
        if effect_changed:
            descriptions = []
            for effect in new['effects']:
                value = f"{effect['amount']:,.4f}".rstrip('0').rstrip('.')
                unit = '%' if effect['percentage'] else ''
                descriptions.append(f"{LABELS.get(effect['stat'],effect['stat'])} +{value}{unit}")
            new['upgradeDescription'] = 'Per level: ' + '; '.join(descriptions) + '.'
    assert comparison == original, 'Candidate changes something besides upgrade numeric amounts, prices or thresholds'
    target = MODULE / 'Data/row_divers.json'
    prior_install = EXPERIMENTS / 'installed_tree.json'
    allowed = {sha(original_path)}
    if prior_install.exists(): allowed.add(json.loads(prior_install.read_text())['installed_sha256'])
    assert sha(target) in allowed, 'Canonical catalog changed outside the tuning experiment; inspect before replacing'
    temporary = target.with_suffix('.json.tmp')
    temporary.write_text(json.dumps(catalog, indent=2, ensure_ascii=False)+'\n', encoding='utf-8')
    temporary.replace(target)
    with (EXPERIMENTS / 'installed_value_changes.csv').open('w',newline='',encoding='utf-8') as handle:
        writer = csv.DictWriter(handle,fieldnames=['upgrade','field','previous','rebalanced'])
        writer.writeheader(); writer.writerows(changes)
    manifest = dict(profile=args.profile, control_profile=args.control_profile, original_sha256=sha(original_path), previous_sha256=sha(previous_path),
        installed_sha256=sha(target), changes=changes, campaigns=traces,
        allowed_balance_changes='Upgrade effect amounts, base prices, numeric parent thresholds; descriptions updated to match.',
        previous_progress='user://row_divers_progress_v1.json', rebalanced_progress='user://row_divers_progress_balanced_v1.json',
        setting='Settings > UPGRADE TREE (RESTART) > PREVIOUS')
    prior_install.write_text(json.dumps(manifest,indent=2))
    print(f'Installed {args.profile}: {len(changes)} numeric value changes; {len(traces)} audited campaigns.')

if __name__ == '__main__': main()
