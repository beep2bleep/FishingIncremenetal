$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$pythonScript = Join-Path $scriptDir "redraw_combat_weapons.py"

python $pythonScript
