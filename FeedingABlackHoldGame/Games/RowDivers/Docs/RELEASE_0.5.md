# Railway Fury 0.5 — local builds

Prepared November 17, 2026. The Windows and browser itch demos were uploaded and published on November 17, 2026 at https://beep2bleep.itch.io/railway-fury-demo . Both uploads are labeled 0.5; the browser ZIP is selected for browser play. Steam 0.5 uploads completed November 17, 2026: full app 5520300 build **26739109**, demo app 5520330 build **26739113**. Both are unassigned; neither was set live and no review was submitted. Receipts: `tools/railway_steam/upload-0.5.log`. Published-page proof: `Docs/Previews/itch-0.5-published.png`.

- Right stick pans the upgrade graph; LT/L2 plus right stick zooms. X/Square plus left stick drag remains available.
- Virtual cursor hover switches upgrade details after purchasing.
- D-pad navigation follows displayed positions and prefers available upgrades over shadow previews, including Pickup Range I → II.
- The bottom hints reserve space for the Play button and Start glyph.
- DEMO MODE is on the wallet's second line, clear of purchase feedback.
- Illustrated and Gothic upgrade music loops through sustained sections without the authored fade-out.

Outputs:

- Full Steam Windows: `Build - RailwayFury/Steam/Full/RailwayFury.exe`
- Demo Steam Windows: `Build - RailwayFury/Steam/Demo/RailwayFuryDemo.exe`
- Itch Windows ZIP: `Build - RailwayFury/Demo/RailwayFuryDemo-Windows.zip`
- Itch browser ZIP: `Build - RailwayFury/Demo/RailwayFuryDemo-Web.zip`

Validation: 158 rendered source controller checks across full/demo modes, 34 music checks, 15 packaged-runtime checks per Steam edition, and 25 checks on the packaged itch Windows demo. The ZIP packager enforces the itch HTML file-size limit. Artifact hashes are recorded in `Build - RailwayFury/build_manifest_0.5.json`.

Physical Xbox/PlayStation and Steam Input testing remains necessary before resubmitting the controller support claim. The older `Windows-QA` directory is not updated by this release; use the executables above.
