# Steam catalog localization — October 28, 2026

The Steamworks All Applications list was inspected. Apart from the already
completed Railway Fury and Railway Fury Demo, eight multilingual records
required work. All changes below were uploaded through Steamworks, downloaded
again, and verified against the prepared packages.

| Store record | Added/updated non-English languages | Verified fields |
| --- | ---: | ---: |
| BleepWare Incrementals | 14 | 70 |
| BleepWare Incrementals Demo | 15 | 45 |
| Data Breach Inc. | 15 | 75 |
| Data Breach Inc. Demo | 15 | 45 |
| Deepcore | 15 | 75 |
| Deepcore Demo | 16 | 80 |
| Vanguard - Idle Auto Battler | 15 | 75 |
| Vanguard - Idle Auto Battler Demo | 16 | 48 |

Total: **513 verified fields across eight records**. Technical requirements
consisting only of product names, numbers, and hardware units were copied
unchanged into the relevant languages. Descriptions and short descriptions
were translated where English source fields existed.

All four demos currently have separate store pages disabled. Their settings
were retained. Deepcore Demo already had an English description and short
description, which were translated; the other three demos only exported their
minimum-system-requirement strings, which were populated for their supported
languages. No new English demo descriptions were invented and no separate demo
store pages were enabled.

Vanguard's supported-language descriptions contained broken phrasing and
omitted the English description's embedded image. Those translations were
replaced with updated copy retaining the original markup and media reference.
Existing locales outside the advertised support list were left untouched.

## Language coverage

The common languages are French, Italian, German, Spanish (Spain), Czech,
Indonesian, Japanese, Korean, Russian, Simplified Chinese, Thai, Turkish, and
Vietnamese. Portuguese (Portugal), Portuguese (Brazil), and Polish were added
according to each record's own supported-language settings; those lists differ
between some main games and demos. English fields were preserved exactly.

`catalog.json` records the exact supported-language list per record. No
additional languages were advertised or enabled.

## English-only records inspected and skipped

- Bleeping Spaceships
- Bleeping Spaceships Demo
- Bounty For Sharks
- Home Plate Baseball
- Laser Swords
- Only Jump!
- Umpire Simulator

## Files and verification

- `*_before.json`: original Steamworks exports.
- `*_upload.json`: packages uploaded to the matching store item IDs.
- `*_verified.json`: fresh Steamworks exports after saving.
- `verification.json`: exact field comparisons and preservation checks.
- `catalog.json`: inventory, language support, and original download paths.
- `demo_presence.json`: separate-demo-store-page settings.
- `prepared.json`: upload coverage counts.
- `saved_exports.json`: paths returned by Steamworks download actions.
- `*_draft.json`: translation work files with editorial terminology fixes.
- `*_preview.png`: visual checks of BleepWare in Japanese, Data Breach in
  Simplified Chinese, Deepcore in German, and Vanguard in French.

Validation found no mismatched uploaded fields, no changed English source,
and no changes to untouched locales. Short descriptions are within 300
characters. Source BBCode tag sequences, embedded asset references, bullet
counts, and protected game names were checked before upload.

Changes remain **saved, unpublished Steamworks store changes**. No publishing
or review submission was performed. This matches the Railway Fury workflow.

The preparation and verification scripts are under `tools/railway_demo/`:
`localize_catalog.py`, `review_catalog.py`, and `verify_catalog.py`.
