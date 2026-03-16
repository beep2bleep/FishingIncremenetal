# Core Instructions

This folder owns shared infrastructure used by both games.

Default scope
- Work in `res://Core/` and other shared files only.

Shared work includes
- bootstrap and startup flow
- scene routing
- controller and input improvements
- settings systems
- audio systems
- scene transitions
- game-agnostic utility and UI infrastructure

Avoid
- game-specific balance changes
- game-specific content changes
- game-specific gameplay logic
unless the user explicitly asks for them.

If a request is ambiguous
- Ask whether the task is meant for `Core:`, `Vanguard:`, or `Mining:` before making edits.
