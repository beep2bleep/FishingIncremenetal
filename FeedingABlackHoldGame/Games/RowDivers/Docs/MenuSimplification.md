# Railway Fury menu simplification

Railway Fury now has one play entry. It opens the existing Free Aim campaign
and save profile; Classic profiles remain on disk. The launcher and normal
bootstrap both choose this campaign. Settings no longer expose art/audio style
selection, and the upgrade-tree selector is omitted for this campaign.

The bottom menu button says **Play my other games** and opens
https://store.steampowered.com/franchise/Beep2Bleep directly from the click.
The main menu shows two different capsules at a time, rotating through three
pairs every six seconds. The upgrade screen has a single-capsule version in
the bottom-right, above the Play footer. Its 300 x 140 capsule is larger than
the main menu's 246 x 115 capsules, with the action title above the artwork.
It rotates individually every six seconds. Official Steam artwork is bundled
locally:
Vanguard, Deepcore, BleepWare Incrementals, Bleeping Spaceships, Bounty For Sharks
and Home Plate Baseball. No network request is needed to display the menu.
Umpire Simulator and Only Jump are excluded. Artwork URLs and store IDs are
recorded in `Art/OtherGames/sources.json`. New action/description copy is included
in all 17 translation catalogs.

Validation: `VerifyRailwayMenu.gd -- --capture` renders the menu, settings and
combat, checks the single campaign entry and capsule rotation, and verifies
the simplified settings. The Free Aim, illustrated presentation and
demo/localization suites also pass. Screenshots are in `Docs/Previews/`:
`railway_single_menu.png`, `railway_simple_settings.png`, and
`railway_combat.png`. The upgrade placement is shown in
`railway_upgrade_other_games.png`. The menu/rotation/layout suite passes
16 checks, including distinct pairs, all six games, and no overlap with Play.
