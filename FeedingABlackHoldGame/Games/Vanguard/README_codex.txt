Codex guidance for Vanguard

Scope
- This folder is the Vanguard game module.
- Prefer working here for Vanguard-specific menu, scene, flow, and future gameplay work.

Current entry points
- `Menus/VanguardMainMenu.tscn`
- `Scenes/VanguardMain.tscn`
- `Scenes/VanguardBattleScene.tscn`

Shared systems
- Shared systems live outside this folder.
- If a requested change should affect both Vanguard and Mining, prefer updating shared code such as:
  - `res://Core/`
  - `res://UpgradeScreen.gd`
  - `res://UpgradeScreen.tscn`
  - shared settings, input, audio, transitions, and utility files

Do not change Mining by accident
- Do not modify anything under `res://Games/Mining/` unless the request explicitly says to update both games.

Prompting guidance
- Good:
  - "Work only in `res://Games/Vanguard/` unless shared code must change."
  - "Update Vanguard main menu only."
  - "Keep Mining untouched."
- Bad:
  - "Update the menu."
  - "Change the battle scene."

Current architectural note
- Vanguard currently still wraps older root-level scenes.
- When refactoring, prefer moving Vanguard-specific behavior into this folder rather than adding more game-specific logic to generic root files.

Near-term recommended direction
- Keep shared improvements shared.
- Move Vanguard-only content and behavior into explicit Vanguard files over time.
