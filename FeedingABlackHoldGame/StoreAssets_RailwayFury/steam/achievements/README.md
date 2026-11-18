# Railway Fury Steam achievements

App ID: **5520300** (full game). The demo does not unlock full-game achievements.

These 18 achievements are generated from `Games/RowDivers/Data/row_divers.json`.
API names are the existing `AchievementType` keys. Names and descriptions are
copied verbatim. PNGs are exported through the in-game achievement icon renderer
in the shipping illustrated presentation, scaled to Steam's recommended 256x256.

Regenerate from the repository root:

```powershell
& ./Godot/Godot_v4.6-stable_win64_console.exe --headless --path FeedingABlackHoldGame --script res://Games/RowDivers/Tools/ExportSteamAchievements.gd
```

In [Steamworks achievements](https://partner.steamgames.com/apps/achievements/5520300),
open **Bulk Import/Export** and upload both CSV files and all 18 `*_ACHIEVED.png`
files together. Keep **Automatically generate unachieved icons** enabled. Review
18 additions, save the imported data, then publish the achievement configuration.
Enable Steam Achievements in the store page's Supported Features after the updated
game build is available.

The runtime mirrors earned local flags every five seconds and backfills existing
progress. It never changes reward claims, wallet balances, or local progress.
Failed Steam calls are retried. Editor sessions, web builds, and demos do not
submit achievements.

Verify without changing real Steam achievements:

```powershell
& ./Godot/Godot_v4.6-stable_win64_console.exe --headless --path FeedingABlackHoldGame --script res://Games/RowDivers/Tools/VerifySteamAchievements.gd
```

Reference: [Steamworks achievement setup and bulk import](https://partner.steamgames.com/doc/features/achievements/ach_guide).
