# Upgrade and Battle Scene Sound Replacement List

Scope checked:

- `FeedingABlackHoldGame/UpgradeScreen.tscn`
- `FeedingABlackHoldGame/UpgradeScreen.gd`
- `FeedingABlackHoldGame/Fishing/BattleScene.tscn`
- `FeedingABlackHoldGame/Fishing/BattleScene.gd`
- `FeedingABlackHoldGame/CustomButton.gd`
- linked sound setting resources in `FeedingABlackHoldGame/Sound Effect Settings/`

## Replace

These are the only replacement-list items I found that are still referenced by the upgrade scene or battle scene.

| Current file(s) | Used from | Current role | Why it stays on replacement list | Suggested replacement profile |
| --- | --- | --- | --- | --- |
| `FeedingABlackHoldGame/Art/Level_Up_Sound_1.mp3` | `UpgradeScreen.tscn` + `UpgradeScreen.gd` | first upgrade unlock stinger | unresolved source | short reward chime / level-up blip |
| `FeedingABlackHoldGame/Art/Level_Up_Sound_2.mp3` | `UpgradeScreen.tscn` + `UpgradeScreen.gd` | second upgrade unlock stinger | unresolved source | short reward chime / level-up blip |
| `FeedingABlackHoldGame/Art/Level_Up_Sound_3.mp3` | `UpgradeScreen.tscn` + `UpgradeScreen.gd` | third upgrade unlock stinger | unresolved source | short reward chime / level-up blip |
| `FeedingABlackHoldGame/Art/Level_Up_Sound_4.mp3` | `Sound Effect Settings/TECH_TREE_NODE_CLICK.tres` used by `UpgradeScreen.gd` | repeated tech tree purchase/click confirm | unresolved source | short confirm click / reward blip |
| `FeedingABlackHoldGame/Audio/bong_001.mp3` | `Sound Effect Settings/TECH_TREE_NODE_HOVER.tres` used by `CustomButton.gd` in both scenes | hover sound on `CustomButton` instances | unresolved source | soft UI hover tick / muted blip |

## Referenced But Not Replacement Targets

These are still used by the two scenes, but they are already tied to known ZapSplat assets from the existing audit and do not need to be in the replacement list unless you want to replace them for design reasons.

| Current file | Used from | Current role |
| --- | --- | --- |
| `FeedingABlackHoldGame/Audio/zapsplat_multimedia_button_click_001_68773.mp3` | `BUTTON_CLICK.tres`, used heavily by `BattleScene.gd` and `CustomButton.gd` | generic click, defeat, coin pickup, continue, button press |
| `FeedingABlackHoldGame/Audio/zapsplat_cartoon_bubble_pop_003_40275.mp3` | `TECH_TREE_NODE_POP_IN.tres`, used by `BattleScene.gd` | hero active/power-up start chime |

## No Longer Needed For These Two Scenes

I did not find current references from `UpgradeScreen` or `BattleScene` to these existing replacement-matrix items:

- `Audio/golden.mp3`
- `Audio/Laser.mp3`
- `Audio/Marble_OnCollide.mp3`
- `Audio/Supernova.mp3`
- `Black Hole Collapse.mp3`
- `Audio/Voicy_Hitmarker Sound.mp3`
- `Audio/cartoon_success_fanfair.mp3`
- `Audio/esm_victory_horns_alert_sound_fx_arcade_synth_musical_chord_bling_electronic_casino_kids_mobile_positive_achievement_score.mp3`

## Reference Notes

- `UpgradeScreen.gd` plays `Level_Up_Sound_1/2/3` for the first three session unlocks, then falls back to `TECH_TREE_NODE_CLICK`.
- `TECH_TREE_NODE_CLICK.tres` points to `Art/Level_Up_Sound_4.mp3`.
- `CustomButton.gd` plays `TECH_TREE_NODE_HOVER` on hover and `BUTTON_CLICK` on press.
- `UpgradeScreen.tscn` contains `CustomButton` instances for `Wishlist` and `Go Again`.
- `BattleScene.tscn` contains a `CustomButton` instance for `ExitBattleButton`.
- `BattleScene.gd` directly uses only `BUTTON_CLICK` and `TECH_TREE_NODE_POP_IN`.
