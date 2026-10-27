# Level themes and compact fire controls

The four existing campaign stages now display as **Levels 1–4**. Internal `prestige` fields, node IDs, achievement keys, analytics IDs and leaderboard board IDs remain compatible with existing saves. Only visible wording changes.

| Level | Setting | Enemy variation |
|---|---|---|
| 1 | The Forgotten Line: original railway ruins | Original palette |
| 2 | The Iron Citadel: warm castle stone, timber beams and burgundy/gold banners | Subtle warm ivory tint |
| 3 | The Wildwood Line: open forest, mossy ground, layered inked oak trees and green mist | Subtle moss/sage tint |
| 4 | The Infernal Descent: fractured volcanic stone and lava channels beside the railway | Subtle ember/russet tint |

Themes apply in all three graphics styles. Tree trunks, banners, beams and lava channels stay beside or above the playable lane. All added scenery is visual only. Theme construction consumes no combat randomness, and graphic-style changes preserve combat state. The woodland theme replaces the enclosed scenery with an open grove. Enemy tint materials remain independent of scenery materials and survive graphics refreshes.

Fire waves retain their orange/red hazard identity. Each level gets a restrained tint, with three slight shade variations as bosses escalate the waves. Wave gaps, damage, speed and cooldowns are unchanged.

## Fire-control tree placement

All twelve Ember Channels nodes now form compact groups around their crown-priced unlocks. First tiers are 5.5–7.4 source units from their crown parent (roughly one normal node spacing); higher tiers are within 15.9 units. Consecutive tiers are at most 10 units apart. They no longer extend to the remote 83 / 101 / 119 rows. Placement keeps every node footprint clear of the existing tree.

Prices, crown parents, level requirements, effects and rank counts are unchanged. The before/after coordinates are recorded in `../../../../tools/rowdivers_balance/fire_branch_positions.json`. An audit against the frozen CrownValidation catalog found no changed upgrade balance fields.

[Compact branches](Previews/fire_control_clusters.png)

## Artwork

Generated with the built-in imagegen tool and copied without pixel editing into:

- `res://Games/RowDivers/Art/Levels/forest_ground.png`
- `res://Games/RowDivers/Art/Levels/forest_tree.png`
- `res://Games/RowDivers/Art/Levels/hell_basalt.png`

[Level 1](Previews/level_1.png) · [Level 2](Previews/level_2.png) · [Level 3](Previews/level_3.png) · [Level 4](Previews/level_4.png) · [Final-level fire](Previews/level_4_fire.png)

## Verification

`Tools/VerifyLevelThemes.gd` passed 96 checks with rendered previews of all four
levels and the upgrade tree: branch spacing and gates, level labels, enemy/bat
tints, fire shader colors for every tier, unchanged combat state and RNG, and
switching all graphics styles. The existing illustrated-presentation suite passed
211 checks, Auto Buy passed 22, and crown progression passed 38. Existing engine
startup/shutdown diagnostics remain; these runs had no script errors. SHA-256
checks confirmed all three player save files were unchanged by this work.

## Prompts

### Forest ground

Seamless repeating square ground texture for an inked fantasy railway game: a forest floor of dusty olive moss, muted sage grass tufts, small tan roots, dark earth, sparse ochre fallen leaves and a few tiny gray pebbles. Flat top-down orthographic material, all four edges tile seamlessly, evenly distributed small details, no central focal point or perspective. Strong irregular near-black ink contours, broad simple cel shading and warm earthy palette matching a hand-drawn dungeon graphic novel. Mostly subdued mid-dark moss green, so pale enemies and railway sleepers remain readable. No railway tracks, trees, scene, text, border, vignette, cast shadows or glow. Opaque square texture.

### Forest tree

One entire broad old forest tree, upright isolated production cutout sprite for hand-inked fantasy railway game. Portrait 2:3 canvas, full trunk, roots and complete canopy visible with padding on every side. Gnarled brown oak trunk with a few large twists, broad irregular layered dusty olive and sage foliage canopy, small ochre leaves mixed in, roots at bottom. Strong near-black ink outlines, broad simple two-tone cel shading, muted earthy colors, clear graphic shapes, a little hand-drawn texture matching a graphic novel dungeon game. Straight front view, believable natural tree proportions, not a squashed bush or a photorealistic tree. Genuine transparent background including gaps between branches. No scenery, ground plane, sky, shadow outside the tree, text, frame, border or glow.

### Infernal stone

Seamless square tileable material for the FINAL HELL RAILWAY level of an inked fantasy game. Jagged large black basalt stones and dark burgundy volcanic rock plates, angular charcoal cracks with restrained narrow burnt orange and ember-red fissures, occasional tiny dull copper flecks. Mostly DARK stone, only sparse red hot cracks so monsters and rails remain legible. Bold near-black hand-inked contours, broad two-tone cel shading, textured graphic novel illustration matching a cartoon dungeon railway. Straight-on orthographic evenly lit surface that works on walls and ground; all four edges repeat seamlessly. No perspective, objects, railway tracks, skull faces, central subject, bright fireball, text, border, vignette or glow haze. Opaque square texture.

