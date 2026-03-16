# Vanguard Instructions

This folder owns the Vanguard game module.

Default scope
- Work only in `res://Games/Vanguard/`.

Allowed shared changes when necessary
- `res://Core/`
- `res://UpgradeScreen.gd`
- `res://UpgradeScreen.tscn`
- other clearly shared infrastructure files

Do not modify
- `res://Games/Mining/`
unless the user explicitly asks for a cross-game change.

Development intent
- Keep Vanguard gameplay, content, menu behavior, progression logic, and balance in Vanguard files.
- Keep shared improvements shared.
- Do not place Vanguard-specific logic in Mining files.

If a request is ambiguous
- Ask whether the task is meant for `Vanguard:`, `Mining:`, or `Core:` before making edits.
