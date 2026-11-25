# Railway Fury 0.13 — November 25, 2026

The upgrade menu's cursor-only guard consumed Start before its Play callback.
Start and Select equivalents now run the explicit callback before that guard:
Xbox Menu/View, Switch and GameSir +/- in standard gamepad mode, PlayStation
Options/Share and touchpad, and older Start/Select controllers. These buttons also
pause and resume combat and dismiss the tutorial. Result choices remain cursor-only
and utility buttons cannot skip their countdown. Platform-reserved system buttons
are unchanged.

Four compact, brighter +, -, Menu and View glyphs appear beside Play in the upgrade
screen and beside the launcher play title. They hide with keyboard/mouse input.
The launcher fits the title and glyphs on one row, preserving the automatic-fire
description below it. Existing virtual-cursor navigation and purchases remain.

Auto-fire from the first run and the aim-only tutorials introduced in 0.12 are
included and verified in the new full and demo packages. No game text was changed
in this release, so the existing 17 translations remain applicable.

The local Steam full install was build 26767539 (0.9). Steamworks still had the
correct newer default 26820067 (0.12), but the desktop client showed NO CONNECTION
and Cloud Out of Date. After a normal client restart it requested sign-in. The
local install has not yet been verified updated; sign-in and download are needed.

Validation passed: 17 shipping pack checks per Steam edition, 25 itch Windows
pack checks, 39 packaged controller transition/layout checks per edition, and
51 packaged auto-fire checks per edition. Utility tests exercise both menus,
tutorial, pause/resume, result countdowns, glyph bounds and cursor mode at 720p.
Auto-fire tests cover all three profiles, old saves and refunds, cooldowns,
auxiliary weapons and aim-only tutorial captions. Player saves were not reset.
Physical GameSir hardware operation remains for hands-on confirmation.

All four exports were built. Steam uploads succeeded: full 26929190 (depot
5520301 manifest 8249102668373885464), demo 26929193 (depot 5520331; see upload log).
Neither new default activation is verified. Steam activation and itch Windows/Web
demo uploads remain pending after Windows Computer Use stopped because it could
not confidently determine the active browser URL. No full-game public release was
performed. Itch remains on 0.12; its 0.13 archives and revised page copy are ready.

Screenshots: Previews/release-0.13-menu.png, release-0.13-upgrades.png and
release-0.13-tutorial.png. Build hashes and publication flags are recorded in
StoreAssets_RailwayFury/steam/build-manifest.json. UI screenshots use the isolated
QA profile; editor-only QA controls do not appear in shipping executables.
