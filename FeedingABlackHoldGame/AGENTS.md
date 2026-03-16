# Multi-Game Codex Instructions

This project contains multiple game modules in one Godot project.

Game modules
- `res://Games/Vanguard/`
- `res://Games/Mining/`

Shared code
- `res://Core/`
- selected shared root files such as:
  - `res://UpgradeScreen.gd`
  - `res://UpgradeScreen.tscn`
  - shared settings, audio, transitions, utility, and bootstrap files

## Prompt prefixes

When the user starts a request with one of these prefixes, treat it as a scope instruction:

- `Vanguard:`
  - Work is for the Vanguard game.
  - Prefer changes under `res://Games/Vanguard/`.
  - Do not modify `res://Games/Mining/` unless the user explicitly asks for both games.
  - Shared changes are allowed only if they are necessary and remain game-agnostic.

- `Mining:`
  - Work is for the Mining game.
  - Prefer changes under `res://Games/Mining/`.
  - Do not modify `res://Games/Vanguard/` unless the user explicitly asks for both games.
  - Shared changes are allowed only if they are necessary and remain game-agnostic.

- `Core:`
  - Work is for shared infrastructure used by both games.
  - Prefer changes under `res://Core/` and other shared files.
  - Avoid changing game-specific balance, content, or gameplay unless explicitly requested.

## Ambiguity rule

If a request is ambiguous and it is not clear whether the work is for:
- `Vanguard:`
- `Mining:`
- `Core:`

then stop and ask a short clarification question before editing files.

Examples of ambiguous requests
- "Update the menu"
- "Change the upgrade scene"
- "Fix the battle flow"
- "Add a new upgrade"

## Default behavior

- Prefer the game-specific folder first.
- Keep shared improvements shared.
- Do not add Mining-specific logic to Vanguard files.
- Do not add Vanguard-specific logic to Mining files.
- If shared code must change, keep the change generic and usable by both games.

## Current architecture notes

- Startup is config-driven from `res://Core/Boot/AppBootstrap.tscn`.
- Active game is selected through project settings.
- The upgrade scene is currently shared.
- Mining currently uses a wrapped copy of the current battle scene with mode labeling.

## Good prompt examples

- `Mining: Add a drill heat meter to the mining battle scene.`
- `Vanguard: Change the Vanguard main menu layout.`
- `Core: Improve controller navigation in the shared upgrade scene.`

## Bad prompt examples

- `Update the game`
- `Fix the menu`
- `Change upgrades`

If the user gives a bad or ambiguous prompt, ask whether it is for `Vanguard:`, `Mining:`, or `Core:`.
