# Railway Fury 0.12 — November 20, 2026

Weapons automatically fire at aimed enemies within range from the first run,
including unlocked auxiliary weapons. Clicking, holding a trigger, or buying a
firing mode is no longer required. Mouse/keyboard and controller cannot switch
back to manual fire. Existing fire-rate cooldowns, targeting, projectiles,
movement, powers, pause and result-screen restrictions remain.

Shoot On Hold (5853) and Auto Shoot (6469) are removed from all three catalogs and
their graph connections. Old purchased ranks refund their original 3 and 5 gems
once, remove the retired ranks, and grant innate Auto. Other currencies, ranks
and progression remain. The final-chamber maxed-node threshold drops by two to
match the removed nodes. Refund and idempotence tests include saved-file reloads.

Tutorial pictures and captions now teach aiming. Combat footers no longer show
shooting buttons or bow-mode controls. Main-menu copy, Steam full/demo short and
long descriptions, and itch instructions describe automatic firing. Game text
was regenerated and audited across 17 languages (549 messages each), retaining
reviewed terminology overrides. Steam copy was regenerated in 16 store languages,
with Catalan supplied locally because Steam does not offer that store locale.
The save-sharing and double-speed instructions in the old store-copy files were
also corrected. Prepared store packages are under StoreLocalization/2026-11-20.

The pending 0.11 enemy-animation fix is included: visual enemy playback stays at
1x during faster runs, with pause still freezing it; combat speed is unaffected.

Validation: shipping Steam packs 15 checks each, itch Windows 25; packaged
auto-fire 51 per edition, animation speed 64 per edition, shared progression
39 Full / 57 Demo, and localization 20,034 per edition, all passing. Tests use
RailwayFuryControllerQA and no player-save reset. The older localization fixture
was updated to assert runtime demo restrictions while preserving shared full-game
progress, matching the established 0.8 save behavior. Tutorial capture:
Previews/release-0.12-auto-fire-tutorial.png.

Steam uploads: Full 26820067 and Demo 26820070. Publication is not yet verified.
Itch Windows/Web ZIPs are ready; upload and public verification remain pending.
Store text packages are ready; applying and publishing them remain pending.
See StoreAssets_RailwayFury/steam/build-manifest.json for verified status flags.
