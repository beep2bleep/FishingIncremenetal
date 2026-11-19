# Railway Fury 0.10 — November 19, 2026

Play my other games is absent from every start menu and every full-game screen.
In the demo, the upgrade card first appears on the third upgrade visit after
1,200 seconds of active gameplay, then every third qualifying visit. Earlier
visits do not count. Its existing three-second display and three-second fade
remain, and the faded card cannot intercept input. Reopening an already-open
screen does not advance the cadence. Time and cadence persist with the campaign.
Pauses, menus and accelerated simulation steps do not advance this real-play
clock. Older saves start this new clock at zero instead of treating doubled
simulation time as real play time.

The demo completion screen shows a small other-games card at bottom right,
separate from the large central Wishlist Now button. It respects the five-second
completion input lock and hides in settings, tutorial and pause. Full-game
completion never constructs the card. No new strings require translation.

Validation: Steam Full/Demo shipping packs each passed 15 checks; itch Windows
passed 25. Packaged QA promotion tests passed 50 Full and 29 Demo checks, covering
threshold boundaries, repeated visit cadence, persistence, actual menus, fading,
double speed, pause, completion input lock and no overlap with Wishlist Now.
QA uses RailwayFuryControllerQA with production telemetry inactive.
Screenshot: Previews/release-0.10-demo-complete.png. Editor-only authoring widgets
are hidden for the capture; game UI is otherwise the actual packaged runtime.

Steam Full uploaded: 26798324 (unassigned; previous default retained).
Steam Demo uploaded: 26798327, verified on default after mobile approval.
Itch demo Windows and Web published as 0.10:
https://beep2bleep.itch.io/railway-fury-demo
Hosted browser entry: https://html-classic.itch.zone/html/20674135/index.html
Receipts: tools/railway_steam/upload-0.10.log and build-manifest.json.
