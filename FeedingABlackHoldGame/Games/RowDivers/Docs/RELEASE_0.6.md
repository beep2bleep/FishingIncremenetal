# Railway Fury 0.6

Rebuilt November 17, 2026 for Steam Full/Demo Windows and itch Windows/Web Demo.

Changes since 0.5:

- Achievement rewards display whole numbers.
- Controller-played deaths show a one-second draining/fading circular countdown.
  Choices are disabled until it finishes; the cursor targets Upgrades. Death
  choices use cursor clicks instead of D-pad selection or Start/Back shortcuts.
- The launcher image covers its entire preview area without distortion.
- Player-facing row wording is replaced throughout the game. The death heading
  is `THE RAILWAY CLAIMS YOU`; upgrades, damage labels, achievements and endings
  use railway/track wording.
- All 557 source messages were refreshed across 17 languages, with reviewed
  terminology overrides for controller commands and figurative death wording.
  Translations are machine-assisted, rather than certified native-speaker copy.

SteamPipe receipts:

| Edition | App ID | Build ID |
| --- | --- | --- |
| Full | 5520300 | 26745603 |
| Demo | 5520330 | 26745607 |

Both Steam builds are uploaded and unassigned. No branch was set live and no
review was submitted. Receipts: `tools/railway_steam/upload-0.6.log`.

Itch Windows and browser demos are uploaded and published, both labeled 0.6.
The browser ZIP is selected for browser play; Windows retains its platform flag.
Published-page evidence: `Docs/Previews/itch-0.6-published.png`. The hosted Web
build was also opened directly from its published iframe URL and reached the
menu showing v0.6 (`Docs/Previews/itch-0.6-browser-menu.png`). Public page:
https://beep2bleep.itch.io/railway-fury-demo .

Each Steam package passed 15 independent runtime checks; the itch Windows package
passed 25. ZIP integrity and SHA-256 checks passed. The Web PCK is under the
200 MiB hosting limit. Source validation includes 166 controller-flow checks,
37 focused controller checks after retranslation, 20,305 localization checks,
19 menu checks and 34 music checks. Physical controllers and Steam Input have
not been verified by these synthetic tests.

Artifacts and hashes: `Build - RailwayFury/build_manifest_0.6.json` and
`StoreAssets_RailwayFury/steam/build-manifest.json`.
