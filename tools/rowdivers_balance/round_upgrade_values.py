"""Prepare clean upgrade increments without changing costs or tree structure."""
from copy import deepcopy
import argparse
import json
from tune_trees import EXPERIMENTS


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    modes = parser.add_mutually_exclusive_group()
    modes.add_argument('--nearest-integer', action='store_true')
    modes.add_argument('--contact-buffer', action='store_true')
    modes.add_argument('--buffered-buyer', action='store_true')
    args = parser.parse_args()
    profile = 'round_numbers_p3_buffer' if args.buffered_buyer else ('round_numbers_final' if args.contact_buffer else ('round_numbers_whole' if args.nearest_integer else 'round_numbers_refined'))
    folder = EXPERIMENTS / profile
    folder.mkdir(exist_ok=True)
    source = json.loads((EXPERIMENTS / 'release/catalog.json').read_text())
    catalog = deepcopy(source)
    # Keep quarter-unit range/rate increments: these are meaningful small units.
    # Compare nearest whole units with coarser five/ten-unit rounding.
    # Whole-valued existing increments stay intact.
    changes = []
    for upgrade in catalog['upgrades']:
        for effect in upgrade['effects']:
            old = effect['amount']
            if args.contact_buffer and effect['stat'] == 'Impact_Armor':
                effect['amount'] = 90
                changes.append(dict(upgrade=upgrade['upgradeName'], stat=effect['stat'], previous=old, rounded=90,
                    reason='Protect the prestige transition exposed by whole-number rounding.'))
                continue
            if old == int(old):
                continue
            if effect['percentage'] or effect['stat'] in ['MaxHP', 'Armor', 'Arrow_Damage', 'Dagger_Damage', 'Beam_Damage']:
                step = 1 if args.nearest_integer else (10 if effect['stat'] == 'Arrow_Damage' and not (args.contact_buffer or args.buffered_buyer) else 5)
                tie_adjust = -0.000001 if (args.contact_buffer or args.buffered_buyer) and effect['stat'] == 'MaxHP' else 0
                effect['amount'] = int((old + step / 2 + tie_adjust) // step * step)
            elif effect['stat'] == 'Bow_Fire_Rate':
                effect['amount'] = 1
            if effect['amount'] != old:
                changes.append(dict(upgrade=upgrade['upgradeName'], stat=effect['stat'], previous=old, rounded=effect['amount']))
    (folder / 'catalog.json').write_text(json.dumps(catalog, indent=2) + '\n')
    (folder / 'rounding_changes.json').write_text(json.dumps(changes, indent=2) + '\n')
    for seed in [2401026, 2401027, 2401028]:
        config = json.loads((EXPERIMENTS / 'release/config.json').read_text())
        config['seed'] = seed
        if args.buffered_buyer:
            config.update(purchase_buffer=True, purchase_buffer_min_prestige=3, policy='separate-normal-and-boss-v4-p3-buffer')
        suffix = '' if seed == 2401026 else f'_seed{seed}'
        (folder / f'config{suffix}.json').write_text(json.dumps(config, indent=2) + '\n')
    print(json.dumps(changes, indent=2))


if __name__ == '__main__':
    main()
