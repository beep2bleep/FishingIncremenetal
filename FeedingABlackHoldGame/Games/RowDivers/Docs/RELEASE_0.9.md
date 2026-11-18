# Railway Fury 0.9 — November 18, 2026

Steam uploads: Full **26767539**, Demo **26767544**. Full is verified on default.
Demo is publicly released, but the 0.9 default-branch change requires the user's
Steam Mobile confirmation. Until approved and rechecked, its default remains
26758130 (0.8). Check build_manifest_0.9.json for the latest recorded status.
No wishlist email or other marketing notification was sent.

Itch browser and Windows files are published as 0.9:
https://beep2bleep.itch.io/railway-fury-demo . The page includes full-game Steam
wishlist links, matching the main menu, upgrades and demo completion screen.
The hosted game at html-classic.itch.zone/html/20645905/index.html was opened
directly and reached the menu showing v0.9 and WISHLIST NOW. Proof:
Docs/Previews/itch-0.9-browser-menu.png. The page editor needed actual keyboard
input to synchronize rich-text backing fields before Save; final public copy
was verified after saving.

The full Windows game was additionally exported without Steam-only features,
passed 15 independent packaged-runtime checks, and uploaded to a new private
itch draft (project 5397032): https://itch.io/game/edit/5397032 . Preview for the
owner: https://beep2bleep.itch.io/railway-fury . The full game remains a draft;
pricing and public full-game release were not configured. ZIP and fingerprints:
Build - RailwayFury/Full/RailwayFury-Full-Windows.zip and Full/build_manifest.json.
Proof: Docs/Previews/itch-0.9-full-draft.png. Its railway_itch feature supplies
the correct Railway application icon without enabling Steam-only achievements.

## Cursor controls

Railway menus consistently use pointer selection on controller: left stick moves
the virtual cursor; A or RT clicks; right stick scrolls, or pans the upgrade tree.
D-pad, B, Start and Y cannot switch menu selection to button focus or bypass the
cursor choices. Start still opens pause while actively playing. Combat controls
are unchanged. Settings, credits, tutorial, pause, death, victory and demo victory
share this model. The demo victory countdown remains five seconds for every input.

The earlier implementation applied cursor-only selection only to controller
deaths. Victory/demo victory and other menus retained focus navigation. Also,
releasing mouse-acquired focus each frame could cancel held cursor clicks before
release. Cursor-mode buttons now avoid taking focus, with original focus behavior
restored when using mouse/keyboard. Footer glyphs match pointer controls.

## Analytics and timing

GameAnalytics now receives every run start, completion, death and voluntary exit;
each section reached (1–15); and a heartbeat every 30 active seconds. Payloads
contain level, section, distance, run/campaign simulation time, attempt, kills,
outcome, death cause, edition and play mode. Progression Start/Complete/Fail events
allow completion funnels. Analytics schema is 2. Once-only milestones are now
deduplicated separately per edition, so sharing a save cannot suppress the other
edition's funnel. A crash or tab kill can prevent the final event; last section
and heartbeat provide the last reported progress instead.

Existing Steam boards remain: Demo Level 1; Full Levels 1–4 and Ending Reached,
separate for flying and the two classic upgrade trees. Times are cumulative
active simulation seconds across attempts, not wall-clock time spent in menus.
Double speed advances this simulation clock at double speed. Best millisecond
scores rank ascending; incomplete historical clocks and editor assists cannot
upload. No fixture scores were sent to production leaderboards.

## Cloud

Both editions retain shared profiles and the demo's hard Level 1 restriction.
Cloud ownership is now Demo 5520330 (redirect 0), with Full redirected to 5520330.
This avoids targeting the unreleased full app when the demo is public. Both apps
therefore use the demo's canonical RailwayFury/row_divers_progress*.json rule;
the legacy demo rule remains for migration. Both Cloud changes were published and
verified. Actual cross-device Cloud still needs a two-device test.

## Validation

- Shipping Steam Full/Demo: 15 checks each; itch Windows: 25.
- Packaged cursor/analytics fixture: Full 52, Demo 51, zero failures.
- Packaged release UX: Full 54, Demo 31; shared progression: Full 39, Demo 57.
- Source timer/leaderboard suite: 134 checks passed.
- Cursor tests send real synthetic A press/release events through GUI routing to
  open/close settings and resume gameplay, and reject focus navigation shortcuts.
- All fixtures use RailwayFuryControllerQA. Physical controller hardware remains
  for user acceptance testing. No real player saves were reset by these tests.

Receipts: tools/railway_steam/upload-0.9.log. Package hashes and status:
StoreAssets_RailwayFury/steam/build-manifest.json and
Build - RailwayFury/build_manifest_0.9.json. Steam release proof and mobile gate
screenshots are under Docs/Previews/steam-0.9-*.
