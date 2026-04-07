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
