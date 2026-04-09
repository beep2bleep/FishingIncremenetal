# Red Sky Defense Balance Notes

## Current Content Size

- Meta tree: `36` nodes, `5` tiers each, `180` total tiers.
- Wave upgrade pool: `30` repeatable offers.

## Targets

- Demo target:
  - about `40` minutes to unlock a meaningful early spread of the tree.
  - measured here as `12` unlocked meta nodes.
- Full-version target:
  - about `2` hours for broad progression.
  - measured here as `72` total tiers across the tree.
- Long-tail mastery target:
  - unlocking all `36` nodes and pushing deep tiers is allowed to run longer.

## Reference

- Older 30-node version:
  - `41.1` minutes to `10` nodes
  - `131.5` minutes to `60` tiers
- Read:
  - The old tree was close on pacing, but it did not include the larger economy branch or the extra scrap-focused wave upgrades.

## Expansion Pass 01

- Meta multiplier:
  - `META_COST_MULTIPLIER = 0.68`
- Economy changes:
  - added direct payout multipliers
  - added per-wave scrap bonuses
  - added better salvage banking and lifetime upgrades
- Result:
  - `avg_minutes_to_demo_nodes`: `57.4`
  - `avg_minutes_to_full_tiers`: `125.1`
  - `avg_run_minutes`: `12.0`
- Read:
  - Overall progression was healthy, but the simulator still over-valued deeper tiers and reached breadth too slowly.

## Expansion Pass 02

- Simulation change:
  - boosted first-tier purchase value in the auto-buyer to better match real player breadth.
- Result:
  - `avg_minutes_to_demo_nodes`: `48.4`
  - `avg_minutes_to_full_tiers`: `91.8`
  - `avg_run_minutes`: `10.6`
- Read:
  - Breadth improved, but the larger economy branch caused the full-tier target to become too fast.

## Final Choice

- Meta pricing:
  - keep `META_COST_MULTIPLIER = 0.68`
  - apply `META_FIRST_TIER_DISCOUNT = 0.82`
- Simulation choice:
  - keep the stronger first-tier breadth bias in the auto-buyer
- Final result:
  - `avg_minutes_to_demo_nodes`: `37.1`
  - `avg_minutes_to_full_tiers`: `101.7`
  - `avg_minutes_to_full_nodes`: `168.1`
  - `avg_run_minutes`: `12.0`
- Read:
  - Demo pacing now feels much closer to the requested target.
  - Broad progression reaches the 72-tier goal a bit faster than 2 hours, which is acceptable given the new scrap-focused economy layer.
  - Full 36-node completion remains a longer mastery chase.

## Expansion Pass 03

- Content shift:
  - expanded tree to `42` nodes with the new enemy-control branch.
  - expanded wave upgrade pool to `53` offers.
  - practical progression target updated to `42 * 3 = 126` total tiers.
- Baseline result before retune:
  - `avg_minutes_to_demo_nodes`: `27.4`
  - `avg_minutes_to_full_tiers`: `97.3`
  - `avg_minutes_to_full_nodes`: `120.2`
- Read:
  - The extra economy and survival options made first-tier breadth too cheap again.
  - Players were effectively on pace to hit the practical 3-tier target too early.

## Expansion Pass 04

- Meta pricing:
  - set `META_COST_MULTIPLIER = 0.78`
  - set `META_FIRST_TIER_DISCOUNT = 0.92`
- Practical pacing target:
  - demo threshold stays `12` unlocked nodes.
  - practical player max stays `tier 3` per node.
  - tiers `4-5` remain mastery padding for overachievers.
- Tuned result:
  - `avg_minutes_to_demo_nodes`: `39.1`
  - `avg_minutes_to_full_tiers`: `122.0`
  - `avg_minutes_to_full_nodes`: `133.4`
  - `avg_run_minutes`: `9.5`
- Read:
  - Demo pacing is now close enough to the requested `40` minutes.
  - A strong human-ish route reaches broad practical completion at about `2` hours.
  - Full node completion still extends past the 2-hour mark, which gives the expanded tree a healthy long tail.
