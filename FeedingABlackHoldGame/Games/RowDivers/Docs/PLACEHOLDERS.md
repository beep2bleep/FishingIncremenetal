# Art inventory and remaining placeholders

Enemy and weapon art defaults to the owned Synty Dark Fantasy Godot pack from `C:\Game Assets\Synty Pass\Godot`. `Art/Synty/sources.json` lists all 28 selected files and the exact archive entries. The importer prunes unused skins from each character scene and copies its dependencies. `RowDiversActor.gd` adds an authored looping skeletal idle, visible breathing/arm sway, hit flashes and skeletal attack/lunge clips; death uses a short collapse tween.

Settings → **Art & Audio Style → Original / Row Divers** switches to the supplied reference scenery, artwork and sound. Corridor imports preserve the initial scene, all six regular sections, miniboss/final rooms, columns, plants, webs, decorations, transforms and materials. Original enemy/weapon/projectile geometry, idle and gate curves, music and sound mappings are included. `Art/Original/presentation.json` records the imported data and source SHA-256 hashes. Regenerate with `python tools/import_row_divers_art.py` followed by `python tools/import_row_divers_original.py`.

**Illustrated / New** adds 38 newly generated combat images and a new six-track/20-effect audio set while retaining both previous styles. See `ILLUSTRATED_PRESENTATION.md` for assets, source records and validation.

This remains a Godot port. Shared menus/HUD, fonts, ending narrative, some effects/animations, native collision/scheduling and cross-engine randomness are not established as exact matches. See `ORIGINAL_PRESENTATION.md` for restoration details and verification limits.

| Element | Current representation | Replacement needed |
| --- | --- | --- |
| Player bow / arrow | Synty Crossbow 01 and Arrow 01 meshes, recoil and movement bob | Hands and a full reload animation |
| Dagger | Synty Sword 01 scaled as a dagger, automatic attack and swing | Hands and a dedicated dagger animation |
| Zombie | Synty Skeleton 01 with skeletal idle | Optional dedicated walk/attack clips |
| Zombie variant I | Synty Skeleton Heavy Armor with skeletal idle | Optional dedicated walk/attack clips |
| Zombie variant II | Synty Skeleton Flesh with skeletal idle | Optional dedicated walk/attack clips |
| Mummy | Synty Skeleton Ranger with skeletal idle, moving toward player | Dedicated walk clip |
| Two minibosses | Synty Plague Doctor / Priest, crossbows, idle and firing windup | Dedicated entrance and attack clips |
| Final boss | Synty Dark Lord, crossbow, idle and firing windup | Dedicated entrance and attack clips |
| Six corridor variants | Box floor, ceiling, walls and repeating dark seams | Dungeon geometry, materials and decorative variation |
| Bow projectiles | Synty Arrow 01 mesh | Optional trails |
| Fire / curse / shuriken | Arrow meshes with colored rings; spinning shuriken shots | Dedicated special projectile meshes and particles |
| Enemy projectiles | Pink narrow boxes | Enemy projectile artwork |
| Third Eye | Mouse-targeted damage and a cyan beam flash | Eye icon and final beam particles |
| Gold/chest drops | Small gold cubes | Coin and copper/silver/gold chest models |
| Gem drops | Small purple cubes | Gem model and attraction effect |
| Crown | Text currency reward | Crown icon / boss reward effect |
| Upgrade icons | Arrow, cross, diamond, dagger, triangle, star and circle glyphs | 112 upgrade icons; original graph coordinates and rarity borders are retained |
| Ability states | Four clickable hotkey cards with active/recharge fills and timers; shield ring | Dedicated ability icons |
| Health, armor, distance | Vitality bar, armor/run-mode text and boss bars; Exo 2 / Poppins fonts | Optional final HUD illustration |
| Bestiary / achievements | Original vector portrait badges, achievement icons and scrolling claim list | Optional rendered mesh portraits and bespoke achievement illustrations |
| Upgrade background | Main project's shared upgrade-screen background and effects | Optional final background art |
| Damage, critical, heal, status | Floating damage/loot numbers, hit flashes, health-loss tint, toasts and status colors | Dedicated status icons and particles |
| Startup card | In-engine render of the Synty enemy lineup | Optional illustrated capsule art |
| Ending | Two original narrative choices, typewriter reveal, achievement state and credits | Optional ending illustrations |

Music and effects are from `C:\Game Assets`, with exact file paths and processing listed in `../Audio/sources.json`. Music is full-length PCM16 and loops. Effects are normalized and limited to two seconds. The two tracks are Phat Phrog Studio's *Dark Abyss — Shaded Fragments* (upgrades) and *Void Warden* (gameplay).

The added concrete footstep is Levan Nadashvili's `FS Concrete Soldier Crouch N05.wav` from the local Sonniss GDC 2016 bundle, retained as original PCM24 and played quietly with pitch variation. Music and effects route through the main project's Music and Effects buses. Fonts are reused from the main project's `Theme` directory.
