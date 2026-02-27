# Upgrade Dependency Audit Report

## Scope
- Reviewed all fishing upgrade keys in `FeedingABlackHoldGame/Data/FishingUpgradeData.json`.
- Confirmed prerequisite gating rules for upgrades that target a specific hero/system.
- Updated the dependency builder in `FeedingABlackHoldGame/Fishing/FishingUpgradeTreeAdapter.gd` to enforce prerequisite ancestry (direct or indirect).

## Findings
- Total unique upgrade keys reviewed: `180`
- Keys that require explicit prerequisite gating under current rules: `31`
- Missing prerequisite nodes in dataset: `0`

### Gated key counts by prerequisite
- `archer_pierce_unlock`: `4`
- `recruit_archer`: `3`
- `mage_storm_unlock`: `3`
- `recruit_mage`: `5`
- `guardian_fortify_unlock`: `3`
- `recruit_guardian`: `2`
- `knight_vamp_unlock`: `2`
- `cursor_pickup_unlock`: `2`
- `power_harvest_unlock`: `7`

## What Was Fixed
- Added explicit prerequisite enforcement pass:
  - `_enforce_required_prerequisites(grouped_upgrades)`
  - Uses `_required_unlock_key_for_upgrade(key)` to determine required unlock/recruit node.
  - Verifies ancestry with `_dependency_reaches_target(...)`.
  - Rewrites dependency when required ancestry is missing.
- Enforcement runs multiple times in the pipeline so fan-out/chain reshaping cannot remove required ancestry:
  - after hub retargeting
  - after max-children redistribution
  - after chain flattening
- Removed cross-branch fallback in max-children redistribution to avoid accidental prerequisite bypass.

## Dependency Structure (Current)
- Primary flow: `center -> hubs (recruit/core/unlock) -> themed upgrade families`.
- Fan-out cap: max `4` direct children per node (`MAX_CHILDREN_PER_NODE`).
- Prerequisite ancestry is guaranteed for targeted upgrades:
  - Archer upgrades require archer recruitment chain.
  - Mage upgrades require mage recruitment chain.
  - Guardian upgrades require guardian recruitment chain.
  - Specialized unlock-dependent upgrades require their specific unlock node ancestry.
- Graph remains sanitized for invalid/self/cyclic dependencies.

## Rule Summary Used For Targeted Gating
- Any key containing `archer` (except `recruit_archer`) requires:
  - `archer_pierce_unlock` for `pierce/drill/piercing` variants
  - otherwise `recruit_archer`
- Any key containing `mage` (except `recruit_mage`) requires:
  - `mage_storm_unlock` for `storm/sigil` variants
  - otherwise `recruit_mage`
- Any key containing `guardian` (except `recruit_guardian`) requires:
  - `guardian_fortify_unlock` for `fortify/bulwark` variants
  - otherwise `recruit_guardian`
- `vamp/bloodline` variants require `knight_vamp_unlock`
- `cursor/pickup/magnet/lens` variants require `cursor_pickup_unlock`
- `reservoir/invocation/channel` variants require `power_harvest_unlock`
