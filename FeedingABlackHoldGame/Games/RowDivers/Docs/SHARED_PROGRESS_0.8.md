# Shared demo/full progression — 0.8

Update in 0.9: the demo is released and now owns Cloud storage (redirect 0).
Full app 5520300 shares Demo app 5520330. Both published settings were verified;
the canonical RailwayFury rule is present. This removes the unreleased-base-app
configuration limitation described below. Cross-device verification is still
outstanding. See RELEASE_0.9.md for current status.

Steam Full and Demo use the same RailwayFury user folder and the same JSON
profile names. Classic previous, classic rebalanced, and flying mode remain
separate profiles. The original RailwayFuryDemo/*_demo.json profiles migrate
once into their corresponding shared profiles; originals remain untouched.
An existing shared profile gets an exact .pre_shared.bak before migration.
Missing purchased ranks and their stat effects carry over; earned flags,
unlocks and reward claims are unioned. Currency balances and counters use maxima,
not sums. A migration marker prevents repeated imports, including after reset.

The demo always resolves the playable campaign level to zero (Level 1), even
when a save has all four levels and the final chamber unlocked. Battle visuals,
enemies, loot, damage, boss achievements and fire waves use this resolved level.
Level selection, later upgrade tiers and the final chamber are unavailable in
demo mode. These access checks never erase the full campaign's saved progress.
Defeating the demo boss records completion and carries Level 2 access into the
full game, where the usual level selector becomes available.

In-game achievements and their claimed reward state are shared. Steam's full
app achievement mirror backfills earned save flags when the full Steam build
runs; the demo does not award achievements against the wrong Steam app ID.
Already-earned full-app Steam flags are also restored into the shared save
without granting currencies or claiming rewards.

Steamworks configuration: Demo 5520330 shares Cloud storage with Full 5520300.
It inherits the full app's Auto-Cloud rule: WinAppDataRoaming/RailwayFury,
pattern row_divers_progress*.json, Cross-Platform. Temporary files, local backups,
settings and QA profiles do not match this rule. Dynamic sync remains disabled.

Valve documents that shared Cloud does not sync against an unreleased base app:
https://partner.steamgames.com/doc/features/cloud#initial_setup . Both apps were
still prerelease during this work. Publishing Cloud configuration does not
release either app. Thus end-to-end cross-device Cloud cannot be certified yet.
The local log also recorded login=false sync failures, which can independently
cause an out-of-date badge; playing both editions does not by itself prove a
Cloud conflict. Do not resolve a conflict by deleting a save or picking an
unknown older copy.

Validation: source shared-progress fixture 39 checks; Full QA package 39 checks;
Demo QA package 57 checks; Steam achievement mirror 11 checks; release UX Full
54 and Demo 31 checks; shipping package checks 15 per edition, all passing.
Fixtures use RailwayFuryControllerQA, never player saves. This verifies local
migration, advanced-save demo restrictions, replay, preserved full progress,
idempotence, claims, balances and Steam achievement API behavior via a fake API.

After the base app is released, test on two PCs using one ordinary Steam account:

1. In Demo, buy an upgrade, earn and claim an achievement, defeat the first boss,
   then quit normally. Wait for Steam Cloud Up to date.
2. On the second PC, launch Full and verify that upgrade, wallet, reward claim,
   earned achievement and Level 2 access. Confirm Steam achievements backfill.
3. Unlock a later full level, quit and wait for sync. Launch Demo on the first PC.
   Verify shared purchases/claims, but only Level 1 can launch and no ending opens.
4. Quit Demo, sync, then return to Full. Later levels and ending access must remain.
5. Repeat an offline run followed by reconnect/sync. Resolve any genuine conflict
   using timestamps and known progress after backing up both copies.
