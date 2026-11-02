# Railway Fury 0.2 — Steam uploads

Both Windows release builds were uploaded to Steam on November 2, 2026.

| Edition | Steam app | Steam build ID |
|---|---|---|
| Full game | 5520300 | 26391624 |
| Demo | 5520330 | 26391630 |

The uploaded builds are unassigned. This upload did not change either public default branch or publish a store page.

The project and both Windows executables report version 0.2 (Windows file/product version 0.2.0.0). This source snapshot includes controller support, separate full/demo analytics, and demo-only cross-promotion on the main menu and upgrade screen. Trailer capture tools keep the gameplay HUD hidden while preserving enemy health and damage numbers; the final trailer edit adds combat music and ends after the first level 3/4 pair.

Validation: 15 independent packaged-runtime checks per edition, 88 controller checks, 12 analytics integration checks, and 19 menu checks passed. Packaged checks verify the actual exported version and edition-specific analytics configuration, Steam app ID, save location, art, progression gates and leaderboard count.

`StoreAssets_RailwayFury/steam/build-manifest.json` records binary SHA-256 hashes, runtime source fingerprints and the successful Steam build IDs. Client analytics configuration is supplied by the ignored `railway_analytics.local.cfg` file and included in exported builds; it is not committed to GitHub.

Rebuild with `tools/railway_steam/build.ps1`, upload with `tools/railway_steam/upload.ps1`, and record the upload log with `python tools/railway_steam/manifest.py --upload-log <log-path>`. SteamCMD's cached login was used for this upload. The upload script does not set builds live.
