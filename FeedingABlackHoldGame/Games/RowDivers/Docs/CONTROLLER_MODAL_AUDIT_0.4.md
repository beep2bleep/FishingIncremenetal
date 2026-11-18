# Controller modality audit — Railway Fury 0.4

The 0.3 menu-only tests missed failures across real scene transitions. Version
0.4 tests the route from the launcher through upgrades, gameplay, results, replay
and back, using gamepad events through Godot's input pipeline.

## Fixes

- `RailwayController` tracks the active menu surface, a safe initial selection,
  Back/Start callbacks and the current glyph context. Focus is kept inside that
  surface; D-pad selection scrolls focused controls into view.
- Results establish Play Again focus. Start replays; B/Circle returns to
  upgrades. Pause and results both provide an explicit Quit Game button.
- Settings and Credits unwind one level at a time. Settings opened after a run
  return to results; reopening the tutorial cannot resume an already ended run.
- Confirmation windows receive controller Cancel explicitly. Trigger state is
  cleared when native popups take or relinquish input, avoiding stuck confirms.
- Controller pointer events are injected in viewport-local coordinates. They
  are no longer scaled a second time at non-design resolutions, or converted
  back into physical mouse input that changes the glyphs.
- Controller focus no longer gets removed when an upgrade tooltip decides the
  mouse is elsewhere. Purchase confirmation supports a first confirm, B to
  cancel, and a second confirm to buy. Y selects the upgrade screen's menu
  actions. The shared legacy pause handler does not intercept Railway input.
- Controller disconnect pauses active combat and clears held axis/trigger/mouse
  state. Menus receive input while the scene tree is paused.
- Settings, languages and endings can scroll rather than placing controls off
  screen. Hover rotation is disabled for Railway menu buttons, and focus does
  not animate their hit targets away from the cursor.

## Controls and visible prompts

| Mode | Actions |
| --- | --- |
| Launcher | Left stick: cursor; D-pad: select; A/Cross or RT/R2: confirm; Start/Options: play; B/Circle: settings |
| Language | Select/confirm a language; B: return |
| Settings | D-pad up/down: controls; left/right: slider adjustment; A/RT: checkbox/dropdown/button; right stick: scroll; B: return |
| Credits | Move cursor over the text; right stick: scroll; B: settings |
| Upgrade tree | D-pad: nodes; cursor + A/RT: buy; hold X/Square and move left stick on the background: pan; right stick: pan; LT/L2 + right stick vertically: zoom; Y/Triangle: menu actions; Start: dive; B: settings |
| Purchase confirmation | A/RT again: buy; B: cancel |
| Collections | Select/claim rewards; right stick: scroll; B: tree |
| Leaderboard | Right stick: scroll; B: tree |
| Native popup/dialog | D-pad: select; A/RT/RB: confirm; B: cancel |
| Tutorial | A on Play, Start or B: enter gameplay; if opened after results, return to results |
| Gameplay | Left stick: steer; right stick: aim; RT/RB: fire; LT/LB: ready power; L3: run; Y: unlocked Hold/Auto bow mode; Start: pause |
| Pause | Resume, End Run/Upgrades, Settings, How to Play, Main Menu, Quit Game; B/Start: resume |
| Results / demo completion | Play Again, Upgrades, Settings, How to Play, Main Menu, Quit Game; Start: replay; B: upgrades |
| Ending choice/reveal | Select either ending; confirm; select the return action or B to reach the launcher |

The footer switches to the active controller's artwork and describes the active
mode, rather than continuing to display gameplay instructions over results.
Keyboard/mouse input restores keyboard/mouse hints. In menus, D-pad switches to
focus selection; moving the left stick switches back to the cursor.

## Verification and reproduction

The new main suite passes **142 checks**, including both full/demo states, all
visible setting types, credits scrolling, real upgrade purchases and cancellation,
tree pan/zoom, achievement claims, collections, leaderboard, reset confirmation,
tutorial, pause, end run, defeat/victory, replay, results settings/tutorial,
disconnect recovery and ending return. Each displayed menu context is checked
for valid glyph textures. The rendered run starts at 1280×720, exercises window
mode changes, then returns to 1280×720 for the remaining layout/input checks.

A separate **6-check ending suite** exercises both choices and returns using
both Back and Confirm. Separate processes activate actual Quit handlers from
launcher settings, pause, results, upgrades settings, credits, and after an ending.

```powershell
& tools/railway_steam/verify_controller_flow.ps1 -Capture -Small -QuitChecks
& tools/railway_steam/build.ps1
& tools/railway_steam/build_controller_qa.ps1
& tools/railway_steam/verify_controller_flow.ps1 -Pack '.validation/controller/Full/RailwayControllerQA.pck' -QuitChecks
& tools/railway_steam/verify_controller_flow.ps1 -Pack '.validation/controller/Demo/RailwayControllerQA.pck' -QuitChecks
```

Source fixtures use a temporary `override.cfg`; export fixtures use a QA copy
of the release presets and an isolated `RailwayFuryControllerQA` data folder.
The QA exporter temporarily patches only user-folder settings and restores the
original project bytes in `finally`. Shipping exporters reject an active local
override. No reset/purchase fixture is permitted to run in the normal save folder.
QA builds are not uploaded. Runtime scripts match the release builds; the QA
feature/user-folder configuration is different. Shipping packages separately
check version, full/demo gating, save folders, SDK/art dependencies and analytics.

These are synthetic-input and exported-runtime checks. Defeat/victory and ending
eligibility are supplied by fixtures. They do not claim a physical Xbox/PlayStation
or Steam Input pass. Before Steam review, play each final build using a physical
pad, test its selected Steam Input layout, hotplug it, repeat the complete
launcher → upgrades → dive → pause → results → settings → credits → results →
upgrades → launcher → Quit route, and verify Xbox/PlayStation glyph switching.
Browser-host activation and Steam/store links also need a platform-level pad
check; automated tests do not control those external interfaces.

November 17 source follow-up: the upgrade hint strip reserves the actual Play
button/Start glyph bounds and uses shorter prompts. D-pad selection uses the
displayed graph positions, preferring available/completed nodes over shadow
previews; the controller fixture checks Pickup Range I → II explicitly.
Illustrated and Gothic upgrade music now uses sustained sections with a
two-second equal-power loop join, skipping the recordings' authored fade-outs.
`tools/loop_row_divers_upgrade_music.py` prepares those loops idempotently and
both audio generators invoke it. These follow-up changes require fresh exports.

Subsequent source change: when controller input was last active at death, a
one-second circular countdown blocks all result choices. After it finishes,
the cursor targets Upgrades. Death choices use left-stick cursor selection and
A/RT/RB clicks; D-pad selection and direct Start/B actions are disabled there.
Settings and tutorial submenus retain their own Back behavior. Victory/demo
completion results retain their previous shortcuts. The controller fixture checks
the lock, unlock, cursor target, ignored shortcuts, replay and submenu returns.
