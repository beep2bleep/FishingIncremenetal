# Red Sky Defense Instructions

This folder owns the Red Sky Defense game module.

Default scope
- Work only in `res://Games/RedSkyDefense/`.

Allowed shared changes when necessary
- `res://Core/`
- other clearly shared routing, bootstrap, or utility files

Do not modify
- `res://Games/Mining/`
- `res://Games/Vanguard/`
unless the user explicitly asks for a cross-game change.

Development intent
- Keep Red Sky gameplay, content, menu behavior, progression logic, and balance in Red Sky files.
- Keep shared improvements shared.
- Do not place Red Sky-specific logic in Mining or Vanguard files.

If a request is ambiguous
- Ask whether the task is meant for `RedSky:`, `Mining:`, `Vanguard:`, or `Core:` before making edits.
