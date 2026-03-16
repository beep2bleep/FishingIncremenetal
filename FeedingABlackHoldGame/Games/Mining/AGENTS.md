# Mining Instructions

This folder owns the Mining game module.

Default scope
- Work only in `res://Games/Mining/`.

Allowed shared changes when necessary
- `res://Core/`
- `res://UpgradeScreen.gd`
- `res://UpgradeScreen.tscn`
- other clearly shared infrastructure files

Do not modify
- `res://Games/Vanguard/`
unless the user explicitly asks for a cross-game change.

Development intent
- Keep Mining gameplay, content, menu behavior, progression logic, and balance in Mining files.
- Keep shared improvements shared.
- Do not place Mining-specific logic in Vanguard files.

If a request is ambiguous
- Ask whether the task is meant for `Mining:`, `Vanguard:`, or `Core:` before making edits.
