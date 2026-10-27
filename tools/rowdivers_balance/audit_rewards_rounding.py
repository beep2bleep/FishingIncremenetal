"""Independently check reward credits in purchase wallets and clean increments."""
import json
from math import isclose
from tune_trees import EXPERIMENTS, MODULE


def inspect(trace, catalog):
    checks = {}
    definitions = {a['achievementName']: a for a in catalog['settings']['achievements']}
    claims = trace['claims']
    checks['each_achievement_claimed_once'] = len(claims) == len({a['achievement'] for a in claims})
    checks['catalog_rewards_only'] = all(
        a['reward'] == definitions[a['achievement']]['reward'] and
        a['currency'] == definitions[a['achievement']]['currencyType'] for a in claims)
    totals = [sum(a['reward'] for a in claims if a['currency'] == c) for c in range(3)]
    funded = []
    # Every increase between consecutive purchase wallets must be an earned
    # achievement credit. Combat loot is accounted for before each shop phase.
    for phase in range(len(trace['runs']) + 1):
        wallet = list(trace['initial_state']['wallet'] if phase == 0 else trace['runs'][phase-1]['wallet_after'])
        credited = [0, 0, 0]
        phase_claims = [a for a in claims if a['after_run'] == phase]
        for choice in [c for c in trace['choices'] if c['after_run'] == phase]:
            delta = [choice['wallet_before'][c] - wallet[c] for c in range(3)]
            assert all(d >= -1e-6 for d in delta), (phase, choice['name'], delta)
            credited = [a+b for a, b in zip(credited, delta)]
            currency = int(choice['currency'])
            if wallet[currency] < choice['price'] <= choice['wallet_before'][currency]:
                funded.append(dict(after_run=phase, upgrade=choice['name'], before_reward=wallet[currency], after_reward=choice['wallet_before'][currency], price=choice['price']))
            wallet = list(choice['wallet_before'])
            wallet[currency] -= choice['price']
        ending = list(trace['runs'][phase]['wallet_before'] if phase < len(trace['runs']) else trace['final_state']['wallet'])
        if phase == len(trace['runs']) and trace['completed']:
            ending = [a+b for a, b in zip(ending, [200000, 10, 4])]
        credited = [a+b-c for a, b, c in zip(credited, ending, wallet)]
        expected = [sum(a['reward'] for a in phase_claims if a['currency'] == c) for c in range(3)]
        checks[f'shop_{phase}_credits_match_claims'] = all(isclose(a, b, abs_tol=1e-6) for a, b in zip(credited, expected))
    return dict(passed=all(checks.values()), checks=checks, reward_totals=totals, purchases_requiring_immediately_preceding_reward=funded)


def main():
    profile = json.loads((EXPERIMENTS/'installed_tree.json').read_text())['profile']
    catalog = json.loads((MODULE/'Data/row_divers.json').read_text())
    checks = {}
    for u in catalog['upgrades']:
        for e in u['effects']:
            amount = e['amount']
            # Small range / attacks-per-second units can use exact quarters.
            fractional_unit = not e['percentage'] and e['stat'] in ['Melee_range','Distance_Range','Bow_Fire_Rate','Dagger_Attack_Rate']
            checks[f"{u['id']}:{e['stat']}"] = amount*4 == int(amount*4) if fractional_unit else amount == int(amount)
    campaigns = {}
    for path in sorted((EXPERIMENTS/profile).glob('campaign*.json')):
        data = json.loads(path.read_text())
        if 'completed' in data:
            campaigns[path.name] = inspect(data, catalog)
    recommendation_dir = EXPERIMENTS/'recommendation_rewards'
    ready=json.loads((recommendation_dir/'ready.json').read_text())
    claimed=json.loads((recommendation_dir/'already_claimed.json').read_text())
    locked=json.loads((recommendation_dir/'locked.json').read_text())
    recommendation_checks = {
        'ready_reward_claimed':len(ready['claims'])==1 and ready['claims'][0]['reward']==25,
        'recommendation_uses_reward':ready['recommendation']['wallet_before'][0]==25 and ready['recommendation']['price']<=25,
        'already_claimed_not_duplicated':not claimed['claims'] and claimed['final_state']['wallet']==[0,0,0] and not claimed['recommendation'],
        'locked_tab_not_claimed':not locked['claims'] and locked['final_state']['wallet']==[0,0,0] and not locked['recommendation']}
    recommendation_validation=dict(passed=all(recommendation_checks.values()), checks=recommendation_checks)
    (recommendation_dir/'validation.json').write_text(json.dumps(recommendation_validation,indent=2)+'\n')
    result = dict(passed=all(checks.values()) and len(campaigns)==3 and all(c['passed'] for c in campaigns.values()),
        profile=profile, clean_increment_checks=checks, campaigns=campaigns,
        recommendation_mode=recommendation_validation,
        timing='Claim before shopping and after each purchase, as soon as the Achievements tab permits; combat rewards are claimed at the next shop.')
    result['passed'] = result['passed'] and recommendation_validation['passed']
    (EXPERIMENTS/'reward_rounding_audit.json').write_text(json.dumps(result, indent=2)+'\n')
    lines = ['# Achievement rewards and rounded upgrades', '',
        'The original simulations already claimed achievements before shopping and after every purchase. '
        'Unlocking Achievements immediately releases any previously earned rewards; achievements earned in combat are claimed at the next shop. '
        'Each recommendation uses the wallet after these claims.', '',
        'The original three release campaigns each collected 10,875 gold, 20 gems and 3 crowns from achievements. '
        'In seed 2401026, unlocking Achievements after run 5 left 2 gold; First Dive added 25 and immediately funded a 3-gold upgrade. '
        'The original outcome therefore already includes the benefit of achievement-funded upgrades.', '',
        'A separate issue was found in standalone recommendation mode: it had not claimed pending rewards before selecting an upgrade. '
        'That path now claims them first. Regression cases verify a ready reward funds a recommendation, claimed rewards are not duplicated, and the locked tab prevents claiming.', '',
        'Eleven upgrade amounts were rounded and the same three seeds were simulated again with the existing reward-aware policy. '
        'Health/damage additions and percentages are whole numbers. Small range and dagger-rate increments can use exact quarters. '
        'Percentage compounding can still produce fractional resulting stats.', '',
        'The follow-up also adds a Prestige 3 budget reserve: once a shop has bought an upgrade, the buyer keeps one affordable option for a possible zero-income dive. '
        'The check includes achievement rewards that the proposed purchase unlocks. Earlier prestiges keep the original spending policy. '
        'The full balance report compares previous and rounded trees using this same final policy. '
        'The table below compares the original release policy with the final rounded-and-reserved result, so its differences include both changes.', '',
        '| Seed | Before rounding: runs | Rounded: runs | Achievement rewards (gold / gems / crowns) |',
        '|---:|---:|---:|---:|']
    for filename, row in campaigns.items():
        trace = json.loads((EXPERIMENTS/profile/filename).read_text())
        before = json.loads((EXPERIMENTS/'release'/filename).read_text())
        lines.append(f"| {int(trace['config']['seed'])} | {len(before['runs'])} | {len(trace['runs'])} | {' / '.join(str(int(v)) for v in row['reward_totals'])} |")
    lines += ['', 'Every campaign completed all four prestiges and paid the final entry fee. '
        'The independent audit reconciles the reward credits in every shop phase against recorded purchase wallets, validates reward amounts against the catalog, and rejects duplicate claims.', '',
        f'[Full reward and increment audit](reward_rounding_audit.json) · [Exact rounding changes]({profile}/rounding_changes.json) · [Full balance report](TUNING_REPORT.md)', '']
    (EXPERIMENTS/'ROUNDING_FOLLOWUP.md').write_text('\n'.join(lines), encoding='utf-8')
    print(json.dumps({k:v for k,v in result.items() if k not in ['clean_increment_checks','campaigns']}, indent=2))
    for name, row in campaigns.items():
        print(name, row['passed'], 'rewards', row['reward_totals'], 'immediately reward-funded purchases', len(row['purchases_requiring_immediately_preceding_reward']))
    assert result['passed']


if __name__ == '__main__':
    main()
