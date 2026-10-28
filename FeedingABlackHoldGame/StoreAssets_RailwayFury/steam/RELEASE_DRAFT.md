# Railway Fury — Steam preparation, 2026-10-28

This is an unpublished preparation set. Do not publish store pages, ratings,
tags, app configuration, or release/default branches as part of an upload.

| Edition | App | Windows depot | Store item | Store package |
| --- | --- | --- | --- | --- |
| Full | 5520300 | 5520301 | 1410386 | 1904024 |
| Demo | 5520330 | 5520331 | 1410394 | 1904035 |

Approved base price: **USD 2.99**. The current Steamworks account is denied
pricing access, so this price has NOT been saved to the package.

Approved timing: 2–4 weeks after the next Next Fest. Target saved in Steamworks:
**March 22, 2027, 10:00 AM Pacific / 1:00 PM Eastern**. Public date display remains
"To Be Announced". Valve lists the next Next Fest as February 22–March 1, 2027:
https://partner.steamgames.com/doc/marketing/upcoming_events/nextfest/feb_2027

## Local deliverables

- `masters/`: original landscape and portrait illustrations, transparent logo,
  and title-free library hero. Generation prompts are in `PROMPTS.md`.
- `capsules/`: exact-size Steam store and library exports. English branding is
  used for all interface languages.
- `screenshots/full/` and `screenshots/demo/`: six untouched 1920×1080 frames
  extracted from each actual gameplay recording. Demo shots only show level one.
- `trailer/gameplay-trailer.mp4`: 36-second 1920×1080, 30fps H.264/AAC gameplay
  capture. Four nine-second level excerpts use actual campaign upgrade snapshots
  and the bounded playthrough pilot at normal simulation speed. No save writes
  or leaderboard submissions. This trailer is for the full game; a demo trailer
  uses only the first level: `trailer/demo-gameplay-trailer.mp4` is a separate
  36-second gameplay capture for the demo page.
- Windows build content is under the ignored repository build directory:
  `Build - RailwayFury/Steam/Full` and `Build - RailwayFury/Steam/Demo`.

## Draft portal work

Full and demo application names, Windows 64-bit support, install folders,
launch options, depot languages, English store copy, minimum requirements,
Action/Indie genre, single-player classification, supported PC interface
languages, support forum, and controller descriptions have been prepared.

PC interface languages: English, Spanish (Spain), German, Portuguese (Portugal),
French, Italian, Simplified Chinese, Japanese, Korean, Russian, Polish, Turkish,
Thai, Indonesian, Czech, Catalan, Vietnamese. No full-audio/subtitle translation
claims. Minimum hardware figures are proposed requirements, not measurements
from a low-end hardware test lab.

The full content survey is saved as a reviewed, unpublished draft: stylized dark
settings, fantasy violence, weapons/skeletons, killing, no sexual/drug content,
pre-rendered generated content and no runtime generation. Do not publish ratings.
Steam blocks demo survey inheritance until the full survey is published; leave
that step pending under the no-publishing instruction.

The tag wizard has a prepared selection but requires **Publish** to retain it;
it has intentionally NOT been published. Suggested priority for later review:
Incremental, On-Rails Shooter, FPS, Shooter, Action, First-Person, Singleplayer,
Stylized, Dark Fantasy, Resource Management, Loot, Arcade, Controller, Combat,
3D, Medieval, Multiple Endings. Demo tags should omit Multiple Endings.

Media upload remains pending: the current Steam graphics/trailer pages expose
drag-only drop areas. The browser automation file chooser did not open from
them. Do not mark these assets as uploaded until portal counts/thumbnails or
trailer processing confirm success.

Follow-up verification on October 28: both launch configurations persist with
the correct executable, Windows, and 64-bit architecture. Both controller
summaries show full Xbox support and USB-only DualShock/DualSense support.
Both accessibility questionnaires are saved as drafts with Adjustable Text
Size, Custom Volume Controls, and Playable without Quick Time Events. No
screen-reader, directional audio, or untimed-play claims were added. The full
requirements note was corrected and re-read after saving: "Keyboard and mouse
or compatible gamepad." The same correction was saved for the demo.

The user enabled Chrome extension local-file access. Both full and demo
shortcut icons were then uploaded, with conversion to app icons enabled.
Both pages reported successful upload; reloading the full page shows the
saved icon thumbnails. The browser's read-only DOM representation does not
expose FileList reliably: use the actual filename shown in a screenshot and
the server upload result rather than inferring failure from `input.files`.

Store capsules, screenshots, library artwork, and trailers still require
native file drag-and-drop, which the current browser connection cannot
perform. Prepared drag-ready copies are in the ignored build folder
`Build - RailwayFury/Steam/UploadReady/{Full,Demo}/{Store,Library,Screenshots,Trailer}`.
Each edition has four store capsules, four library images, six screenshots,
and its own trailer. Both store pages have a draft Gameplay trailer slot.
SteamCMD output folders still contain no upload results; authentication is
pending in the local upload window. Do not claim any build IDs or successful
depot uploads yet.

Local portal proof screenshots are under the ignored
`Build - RailwayFury/Steam/Proof` folder. They are account-specific evidence,
not public store collateral.

## Reproduce and verify

Run `tools/railway_steam/build.ps1` from PowerShell. Dedicated Steam features
select the correct app IDs; only the demo has the forced `railway_demo` feature.
Both save directories are separate. The full pack includes every level and both
ending illustrations. Steam DLLs are included through the GDExtension export.

`verify.ps1` runs the PCK from an isolated directory containing no source scripts.
Both editions passed eleven checks each: native SDK loading, edition app ID,
wishlist URL, save isolation, power/dagger assets, hidden editor cheats, first
boss gate, leaderboard count, and the Railway Fury app icon. The packaged full game additionally passed
88 controller regression checks. A release executable startup smoke check exited
successfully. Steam API login/ownership and online leaderboard round trips still
require a Steam-installed build; loading the SDK is not proof of authentication.
Headless logs contain existing dummy-renderer and shutdown-resource warnings.

`CaptureSteamTrailer.gd`, `export_art.gd`, `render_trailer.py`, and
`extract_screens.py` reproduce the media. `CaptureSteamScreens.gd` additionally
offers arranged scene previews, which are not the final store screenshots.
`capture-loadouts.json` retains the four winning-run loadouts selected from the
current-playthrough simulation, so recording does not depend on local reports.
The binaries were built from the current working tree, including existing
controller work. This release preparation commit preserves that separate
uncommitted work; `build-manifest.json` records the exact runtime source hashes.

`tools/railway_steam/upload.ps1` creates SteamPipe scripts and prompts locally for
SteamCMD authentication. No passwords are put in scripts or command arguments.
The AppBuild files deliberately omit SetLive. Verify build IDs on each app's
Builds page after upload. Uploading does not publish app settings or store pages.

Before launch, finish media upload, authorized pricing, hardware review, demo
survey inheritance, tag publication, Steam-installed playtesting and Valve
reviews in a separate authorized publishing pass.

## Steam leaderboards

Configured the actual Steam backend for both apps on October 28, under the
user's explicit leaderboard request. Unlike store/app drafts, Steam commits
leaderboard edits immediately. No store publication or build promotion was done.
`leaderboards.json` records the six exact API names and Steam board IDs.

The full app has level 1, 2, 3, and 4 clear times plus the ending time. The
demo app has only its separate level 1 clear-time board. All six use ascending
milliseconds, unrestricted reads, client writes (not trusted-server-only),
no lobby restriction, and no top/range limits. The existing runtime uses
keep-best submissions and already targets these exact names and edition IDs;
no runtime changes or rebuild were needed for this configuration.

The clock measures cumulative active simulation time from campaign start,
excluding menus/pauses. Editor assists and legacy campaigns missing the start
of their timer are excluded. VerifyTimedRuns passed 134 checks; the demo and
localization suite passed 18,549 checks with zero failures, including separate
demo board naming and the first-boss cap. Existing headless renderer/resource
shutdown warnings remain. No synthetic scores were submitted. Steam-installed,
authenticated score upload/download verification remains pending.
