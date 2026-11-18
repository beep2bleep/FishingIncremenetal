# Railway Fury 0.8

November 18, 2026: Steam Full build **26758129** and Demo build **26758130**
uploaded and verified on their **default** branches. Prior defaults were
26757742 and 26757748. Steamworks Cloud sharing changes were published
successfully for the demo, targeting full app 5520300. Neither app was released
and no review was submitted. Public itch packages remain 0.6.

Both Steam editions now use shared profile files. Legacy demo profiles migrate
with backups and without adding currencies twice. Demo restrictions apply at
runtime: only Level 1, no later upgrade tiers or endings, regardless of saved
full-game unlocks. Saved campaign progress and achievement claims remain intact.
Demo-earned flags backfill Steam achievements when the full Steam build runs;
full-app Steam achievement flags also restore into the saved profile.

See SHARED_PROGRESS_0.8.md for implementation details, validation and the
cross-device test sequence. All local/package checks passed. Steam shared Cloud
cannot be certified while the base app is unreleased. The local Steam client
also showed No Connection; its connection log recorded Session Replaced on
November 18 at 07:41:04. This needs a client reconnect/restart before syncing.
Steamworks publication proof: Docs/Previews/steam-0.8-cloud-published.png.

Receipts: tools/railway_steam/upload-0.8.log. Fingerprints:
StoreAssets_RailwayFury/steam/build-manifest.json and
Build - RailwayFury/build_manifest_0.8.json. Previous wishlist links, the demo
five-second completion countdown, Railway wording and integer rewards remain
included; packaged release UX checks passed (Full 54, Demo 31).
