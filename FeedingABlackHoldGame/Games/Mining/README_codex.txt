Codex guidance for Mining

Scope
- This folder is the Mining game module.
- Prefer working here for Mining-specific menu, scene, flow, and future gameplay work.

Current entry points
- `Menus/MiningMainMenu.tscn`
- `Scenes/MiningBattleScene.tscn`

Current status
- Mining currently reuses the shared upgrade scene and a wrapped copy of the current battle scene.
- Right now Mining is separated at the launch-path level, save-file level, and visible mode-label level.
- Mining gameplay content is not fully unique yet.

Shared systems
- Shared systems live outside this folder.
- If a requested change should affect both Vanguard and Mining, prefer updating shared code such as:
  - `res://Core/`
  - `res://UpgradeScreen.gd`
  - `res://UpgradeScreen.tscn`
  - shared settings, input, audio, transitions, and utility files

Do not change Vanguard by accident
- Do not modify anything under `res://Games/Vanguard/` unless the request explicitly says to update both games.

Prompting guidance
- Good:
  - "Work only in `res://Games/Mining/` unless shared code must change."
  - "Update Mining battle flow only."
  - "Keep Vanguard untouched."
- Bad:
  - "Update the game."
  - "Change the upgrade scene."

Important future direction
- Mining-specific gameplay should increasingly move into this folder.
- Keep shared improvements shared, but keep Mining content, balance, and progression logic clearly separated from Vanguard.

Recommended next kinds of work
- Mining upgrade data separation
- Mining-specific battle/gameplay replacement
- Mining-specific UI and menu styling
- Mining-only progression systems
