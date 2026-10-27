# Railway Fury demo release — 27 October 2026

The demo includes Level 1, both minibosses and the first railway's final boss,
in Classic and Free Aim. The final boss displays **DEMO COMPLETE**. Players can
replay Level 1; crown purchases, later-level branches, Level 2–4 selection and
the final chamber are blocked by the progress/combat rules as well as the UI.
The first crown remains a trophy. No new balance values were introduced.

## Configuration and saves

Set `railway_fury/demo/enabled` in Project Settings to test demo mode in the
editor. The existing `global/Demo` switch is also recognized. Normal source
configuration remains full mode. The dedicated demo export presets force the
`railway_demo` feature, so a saved preference cannot unlock the full game.

Demo export data lives in `%APPDATA%/RailwayFuryDemo`; filenames additionally
end in `_demo.json`. Free Aim, Classic rebalanced and Classic previous retain
separate profiles. The progress cache is invalidated when switching demo/full
profiles, and dives keep their original save destination. Editor purchase
forecasts abort if the campaign profile changes. This prevents a live demo
toggle from constraining or purchasing into the full campaign's cached data.

Demo timing exposes only the first-boss milestone and uses separate board IDs.
The itch.io builds skip Steam initialization. Analytics includes a `demo` field.

## Localization

`Translations/catalog.json` contains 509 source messages in 17 languages:
English, Spanish, German, Portuguese, French, Italian, Chinese, Japanese,
Korean, Russian, Polish, Turkish, Thai, Indonesian, Czech, Catalan, Vietnamese.
This covers upgrade/achievement data, HUD, tutorial, results, collections,
requirements, mode descriptions, level names, ending text and credits.
Shared UI continues using the existing translation resources. Shared message
identifiers are deliberately excluded from the additional catalogue.

These are machine-translated first drafts, generated with the resumable
`tools/railway_demo/localize.py` script. Per-language JSON files are the editable
translation cache. Numbers, format placeholders and BBCode are protected and
checked. No translation network service is used by the running game.

Web keeps the existing 13-language list: Chinese, Japanese, Korean and Thai
remain hidden, as requested. Noto Sans is explicitly supplied for Cyrillic and
Vietnamese on web; PC also bundles CJK and Thai fallbacks. Tutorial arrow
symbols are drawn as geometry so they do not depend on font glyphs.

## Builds and store assets

Run `tools/railway_demo/build.ps1` from PowerShell. It prepares the two dedicated
export presets, exports release builds and packages:

- `Build - RailwayFury/Demo/RailwayFuryDemo-Windows.zip`
- `Build - RailwayFury/Demo/RailwayFuryDemo-Web.zip`
- `Build - RailwayFury/Demo/build_manifest.json` (sizes and SHA-256)

The web export uses Compatibility rendering and a single thread. Its ZIP has
`index.html` at the root. Runtime scenes, an explicit script/class/preload dependency closure, shared
translations, controller settings, audio buses, and assets loaded by name are
exported, excluding unrelated game artwork and later-level/ending pictures,
test/simulation tools and store assets. Railway Fury's own music service is
retained; the unused shared playlist is loaded only by modes that use it.

The initial all-resource web export exceeded itch.io's **200 MiB per-file**
HTML hosting limit. The final main data file is approximately **184 MiB**.
`package.py` enforces the limit on every web export file before producing a ZIP.

Screenshots and page copy are in `StoreAssets_RailwayFury/`. The capture tool
renders controlled, non-persisting gameplay states; QA images include Spanish,
German, Japanese and French screens. The itch.io cover, four screenshots,
controls, demo boundary, language availability and AI disclosure are supplied.

Store page: https://beep2bleep.itch.io/railway-fury-demo

## Validation

- Demo/localization suite: **17,911 checks**, including format integrity,
  all locales, crown/level gates, demo completion, save/profile separation and
  a live demo-toggle regression check.
- Presentation/audio suite: **242 checks**.
- Editor upgrade buyer: **22 checks**.
- Crown playthrough/assist rules: **38 checks**.
- Timed runs, cursor and track rules: **108 checks**.
- Exported Windows PCK: **20 checks** covering both modes and all art styles.
  `verify_pack.ps1` runs `ProbeDemoPack.gd` against the exported PCK from a
  directory containing only the native SDK DLLs, without source files available
  as fallbacks. Shared SDK access is optional so web parses without Steam. The
  release build contains its release DLL and requires no Steam client.
- Native release startup and real browser menu, upgrades, tutorial and active
  combat were checked. Godot still prints existing shader/resource cleanup
  warnings; no script errors were present in the passing test runs.

Primary export/hosting references:

- https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_web.html
- https://itch.io/docs/creators/html5

Latest polish: results use plain vertical-bar separators; artwork disclosure copy
was removed from credits, endings and store prose. Both language selectors
use the same platform-filtered language list. The rebuilt exports pass the
strict 20-check packaged test; localization passes 17,911 checks.

## Published page

Published at https://beep2bleep.itch.io/railway-fury-demo on 27 October 2026.
The page includes four screenshots, browser play and the Windows download.
Hosted menu, Free Aim upgrades, tutorial and first-run results were checked
in Chrome without script errors. Final exports include the revised credits,
plain result separators and filtered language selectors.

Published-page screenshot: `StoreAssets_RailwayFury/itchio/page-published.jpg`.


## Demo 0.1 — 27 October 2026

The main menu displays v0.1, and the Windows executable and build manifest
carry the same release version. Both the Web and Windows demo ZIPs are rebuilt.
Melee actor visuals (kinds 0–2) sit 0.15 world units lower in every art style;
combat positions, targeting and collision bounds are unchanged.

This update includes the single Free Aim menu, simplified settings, local
other-game capsules, enemy status visuals, hallway width changes, revised
powers and the earlier Magpie unlock. Ghost uses its own icon in upgrades and
combat and adds a subtle light-blue glow with rising particles. It suppresses
melee pursuit and flier shots while bosses remain aware. Boss attack range
tracks the player range. Track runtime counts simulation time, including
Shift and editor speed multipliers, and stops on pause or run completion.

The dedicated exports exclude unused shared music and unrelated simulation
reports. The Web PCK is 184,787,548 bytes, below itch.io's 200 MiB file limit.
Validation: menu/layout 17 checks; powerups 161 checks; demo/localization
18,549 checks; isolated Windows package 22 checks. The preceding timing suite
passed 134 checks, including every editor multiplier with and without Shift.
Rendered menu and melee-grounding previews were inspected.
