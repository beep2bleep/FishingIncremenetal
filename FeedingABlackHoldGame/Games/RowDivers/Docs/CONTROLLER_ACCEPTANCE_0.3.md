# Railway Fury 0.3 — controller acceptance

The automated checks exercise synthetic input and the exported Windows packs.
They do not certify a physical controller, Steam Input configuration, controller
reconnection, browser gamepad delivery, or Steam's review outcome.

Run this checklist against the **final Steam build IDs in RELEASE_0.3.md**, for
both full and demo. Keep a keyboard/mouse nearby only to record failures; needing
either to continue, dismiss a screen, or quit is a failure. Record controller
model, connection type, Steam Input setting, edition, build ID and screen.

Use your existing save for advanced features. For a first-run test, back it up
and select a separate test profile/account; do not erase your only save. Full
and demo use separate RailwayFury and RailwayFuryDemo application-data folders.

## Controls

| Screen | Controller action |
| --- | --- |
| Menus | Left stick moves cursor; A/Cross or RT/R2 or RB/R1 confirms |
| Focus navigation | D-pad selects; A/Cross or RT/R2 or RB/R1 confirms |
| Back | B/Circle; closes dropdown before closing its settings panel |
| Upgrades | Hold X/Square and move left stick to pan; right stick up/down zooms under cursor |
| Scrollable menus/credits | Point into scroll area, right stick up/down scrolls |
| Start dive | Menu/Options or point at Play and confirm |
| Combat | Left stick steers; right stick aims; RT/R2 or RB/R1 shoots |
| Powers | LT/L2 or LB/L1 uses next ready unlocked power |
| Speed | Click left stick to toggle running |
| Bow modes | Y/Triangle alternates Hold/Auto after Auto unlock |
| Pause | Menu/Options; B/Circle also backs out of paused screens |
| Quit | Open Settings from launcher/upgrades, select Quit |

## Required hands-on pass

1. **Cold start:** connect controller before launch. In Steam Big Picture, install
   and launch each edition. Confirm the first screen is usable without touching
   the mouse, and controller prompts appear on first input. Repeat launching
   with the controller connected afterward.
2. **Launcher:** use the cursor and D-pad; open language selection, choose another
   language, return, restore the language. Open Settings with B/Circle. Verify
   each visible option can be reached. Change and restore every volume slider,
   checkbox, text size, FPS and window mode. Open each dropdown; select an item
   with A and again with a trigger/bumper. B must close only the dropdown first.
   Read and scroll credits, then close them. Quit from this screen, and relaunch.
3. **Upgrades:** select every visible button, inspect upgrade descriptions, pan
   across the entire tree, zoom both directions, and buy an affordable node.
   Try purchase confirmation on and off. Check locked/expensive nodes do not
   buy. Use D-pad selection followed by trigger confirmation, then switch back
   to cursor selection. Open collections/achievements and claim an available
   reward; open/close leaderboard and other dialogs. Change the starting level
   on a progressed full-game save. Open Settings here, change/restore an option,
   close with B, and verify Quit exits the game.
4. **First dive/tutorial:** on an unseen-tutorial profile, read the tutorial and
   start with controller only. Steer both directions, aim at all screen edges,
   shoot with trigger and bumper, use each unlocked power, toggle running and,
   on a progressed full save, switch between Hold and Auto bow modes with Y.
   Verify releasing/repressing the trigger fires correctly in Click mode.
5. **Pause/results:** pause, change/restore settings, close a dropdown with B,
   return to pause, resume, reopen HOW TO PLAY, and return to upgrades. Trigger
   a defeat and a victory; replay and return to upgrades from both. Check the
   demo-complete screen after its first boss. Each visible button must work.
6. **Full-game endings:** on an eligible progressed save, open the final chamber,
   choose each ending on separate backed-up saves, read the reveal and return
   to the main menu with controller only.
7. **Device recovery:** unplug during combat, pause, a held click and an X-drag;
   reconnect and verify no stuck shooting/dragging and all screens remain usable.
   Try a second controller/device index. Change between mouse and controller
   once, then finish and quit using only the controller.
8. **Hardware/configurations:** complete the path on an Xbox/XInput controller
   and a PlayStation controller through Steam Input. Check the current default
   and developer-recommended Steam Input layout sends the intended gamepad
   controls. Record any unsupported combination explicitly. Repeat at 1280×720
   and your normal display resolution, including fullscreen/windowed.

For itch.io, repeat steps 1–5 and 7 with the Windows ZIP. Separately check browser
play in Chrome: press a pad button after opening the game, test fullscreen,
reconnection, scrolling and all menu actions. The host page's initial Run Game
button and browser focus are distinct from the game's input handling.

## Pass criteria and evidence

Every applicable item passes without keyboard/mouse. Controller prompts match
the device, input does not activate both the highlighted and hovered buttons,
menus do not trap the player, settings persist, and Quit closes the executable.
Record a continuous video from Steam launch through settings, a dive, results,
return to menu and Quit for each edition. Attach failure recordings with exact
reproduction steps. Submit the final tested build for Steam review only after
the physical-device pass; automated checks alone do not confirm the store claim.
