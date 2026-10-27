# Dive timing, speed controls, rankings and railway scenery

The aiming cursor is hidden while the reticle is active, including after leaving
the editor speed panel. Pauses, tutorials, settings and completed-run menus show
the pointer again. A generic suppression flag in VirtualCursor prevents mouse or
controller input from restoring a second pointer during a dive.

Shift toggles **DOUBLE SPEED** / **NORMAL SPEED**. Double speed repeats two normal
simulation steps: movement, enemy updates, arrows, hazards, ability cooldowns and
walking-damage ticks all advance together. The former 1.5× movement and per-tick
walking-damage modifiers are removed. It combines with editor speeds, but ordinary
Shift double speed is allowed for timed scores. Enemy animation playback follows
the combined speed as well.

## Campaign clock

`gameplay_seconds` counts active diving seconds across wins, deaths and retries.
It advances once per physics frame, distributed across that frame's simulation
steps. It does not run in upgrades, pauses, tutorials, settings, completed-run
screens or endings. Shift speeds up the simulation while the active-time clock
continues at its normal rate. The clock is visible in the dive HUD and under the
wallet in Upgrades, and is saved with the campaign. Each milestone snapshots its
first completion, so farming the same boss cannot overwrite its original time.

Existing saves start counting from this update. Their missing historical time is
not reconstructed, and campaigns that already have progress are ineligible for
competitive uploads. Start a fresh campaign for a complete timed attempt. Editor
speed cheats and Auto Buy also permanently mark that campaign as assisted; its
clock and milestones remain visible locally. Cancellation before an Auto Buy
batch is applied leaves the campaign untouched.

## Steam leaderboards

The Upgrade screen now offers five scrollable time boards:

| Milestone | Snapshot |
|---|---|
| First Row Cleared | Final sovereign defeated at prestige 0 |
| Prestige 1 Cleared | Final sovereign defeated at prestige 1 |
| Prestige 2 Cleared | Final sovereign defeated at prestige 2 |
| Prestige 3 Cleared | Final sovereign defeated at prestige 3 |
| Ending Reached | The player selects either final ending |

Every time is cumulative active dive time from the beginning of that save. Board
IDs are `railway_fury_<profile>_<milestone>_time`, with profiles `free_aim`,
`classic_rebalanced`, and `classic_previous`, and milestones `boss_0` through
`boss_3` plus `ending`. Only the active profile's five boards are shown.

Steam finds or creates these boards on first use with ascending millisecond scores
and keeps the player's faster score. Saved milestone snapshots are retried when a
live dive or ending opens after offline play. Queued submissions are rechecked
for profile and eligibility before upload. The implementation uses the existing
SteamHandler queue and ranking UI. API behavior follows
[Steam's FindOrCreateLeaderboard and UploadLeaderboardScore documentation](https://partner.steamgames.com/doc/api/ISteamUserStats?l=english).

No fixture scores were uploaded and no remote board creation was exercised during
verification. Provisioning and live uploads still require a working Steam session
for the application's configured App ID.

## Track variations

Procedural sleepers, dark iron rails and worn top edges now appear in every
graphics style. Some sections stay straight, some drift left or right, some lose
rails and sleepers, and others have no railway. Bent loose rails lie in broken
stretches. Section joins return to the same centerline. The source Section 5's
central columns (including matching bases and capitals) move to wall-side mounts
when used in the live hallway. Tests compare the track geometry against column
bounds across all source layouts and both hallway widths.

Tracks are decorative MultiMesh batches with no colliders. Their deterministic
layout consumes no combat randomness. They follow the illustrated/classic floor
height when changing graphics style.

## Verification

`Tools/VerifyTimedRuns.gd` passed 108 checks with the compatibility renderer,
covering cursor suppression, pause/finish timing, double-speed simulation versus
clock time, damage ticks, milestone snapshots, persistence, migration, separate
boards, millisecond submission payloads, track patterns/RNG/column clearance and
the upgrade UI. Auto Buy's 22 checks and the auto-loop's 17 checks also passed.
The gameplay/shared-upgrade smoke test passed 98 assertions after updating its
stale speed/edge expectations and correcting its save-backup path. That legacy
test initially wrote a fixture to the Classic rebalanced save without restoring
that file; the earlier file contents could not be recovered. The Free Aim save
was not modified. A rerun confirmed all three current profile files remained
byte-for-byte unchanged after the corrected test.
Existing startup/shutdown warnings remain; these checks had no script errors.

[Leaderboards and timer](Previews/timed_leaderboards.png) ·
[Shifting rails](Previews/tracks_1.png) · [Broken rails](Previews/tracks_2.png) ·
[Clear former pillar section](Previews/tracks_5.png)
