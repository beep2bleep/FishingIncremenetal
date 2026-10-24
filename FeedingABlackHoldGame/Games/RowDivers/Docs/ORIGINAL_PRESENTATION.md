# Original presentation restoration

The existing local preference now selects original scenery and audio together. Switching during a dive retains enemies, projectiles, currency, timers and progression. Modern visuals remain available. Audio variation uses its own random generator, so UI sounds and pitch variation do not change combat draws.

## Imported from the supplied source

- Initial scene, six regular corridors, both miniboss sections and both final boss variants. Columns, plants, webs, room entrances and other mesh decorations retain the serialized hierarchy, transforms and materials. Initial static batches are decoded using each renderer's submesh range; their baked vertices are not transformed a second time.
- Original enemy and weapon meshes/materials, including shadows and status icons. EnemyIdle/BossIdle and gate opening use the original position/scale curves with Hermite tangents. Modern boss crossbows/rings are hidden. Original deaths hide the actor immediately.
- All seven player/enemy projectile prefabs. These restore their source appearance; they do not by themselves establish identical collision/flight behavior.
- Camera eye position and pitch from the original Player/Head/Camera hierarchy. Original surfaces implement black exponential-squared fog at source density 0.14; Godot's built-in exponential equation differs.
- 33 original sound/music mappings. Original menu/battle pools, final chamber and credits tracks are available; music loops. Effects use source pitch and the squared clip gain produced by setting AudioSource.volume and passing that gain to PlayOneShot. Hover retains its original random pitch range. Shared Music/Effects buses still honor user volume settings.
- Shot, impact, damage, pickup, ability, dagger, beam, gate, boss entrance/death, win/loss and UI sound events. Enemy firing does not add the replacement bow sound in original mode.

`Art/Original/presentation.json` stores source paths/hashes, geometry, materials, animations and audio references. Import with `python tools/import_row_divers_original.py`; the importer only reads the supplied Unity export.

## Behavioral corrections

Input smoothing now uses the original keyboard sensitivity/gravity (3), reversal snap and dead zone. Wall limits account for the source's three-unit corridor and 0.28-unit player sphere. Footstep spacing uses actual planar velocity and InverseLerp(1, 3). Projectile lists use the original forward Fisher-Yates ordering. These corrections apply to both styles.

## Verification and limits

The original-presentation fixture checks all imported scenery/audio, live switching, camera/weapon selection, original shot gain/pitch, gate animation endpoints, keyboard-axis smoothing and matching normalized gameplay state between styles. A rendered preview is also inspected; headless checks alone cannot validate a shader.

The differential source-code suite passes 73 cases at 2,155 checkpoints, with zero source-design mismatches. The four-row campaign passes 66 checks with both presentation modes; shared UI/gameplay smoke passes 50 assertions. These checks use memory-only progression fixtures. Existing shutdown resource-leak diagnostics remain.

Full equivalence is **not certified**. The existing native recorded-control comparison already found different outcomes. Section/spawn RNG, raw input/render/fixed/coroutine scheduling, projectile flight/raycasts, native collision resolution, beam acquisition, dagger travel and a fresh-save campaign remain unresolved verification work. Shared HUD/menu layout, fonts, narrative and some effects/animations also differ. The original-presentation toggle restores substantially more of the source, but does not make these known boundaries disappear.
