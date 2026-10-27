# Scenery proportions

Replaced the one shared fern with three role-specific transparent sprites made using the built-in imagegen tool. Generated files are copied without pixel editing.

| Source slot | Installed artwork | Native aspect |
|---|---|---|
| plant.png | ../Art/Illustrated/plant_low_wide.png | 2:1 |
| plant2.png | ../Art/Illustrated/plant_wall_wide.png | 2:1 |
| plant3.png | ../Art/Illustrated/plant_overhead_wide.png | 3:1 |

The illustrated scenery renderer fits plants, webs, emblems and spikes within their existing visual footprints, accounting for inherited transforms and the wider Free Aim hallway. It reduces the longer dimension rather than expanding a shortened decoration. Classic source artwork keeps its original transforms. Mounts, animation and combat are unchanged.

Validation: `Tools/VerifySceneryProportions.gd` passed 1,166 checks across all serialized layouts in both hallway widths: natural displayed aspect, no enlargement, stable repeated refreshes, transparent foliage, and unchanged Classic transforms. Rendered and visually inspected the foliage and boss decorations at 1280 × 720. Fixtures disable progress persistence. Existing engine startup/shutdown warnings remain.

[Overhead vine](Previews/scenery_Section_1.png) · [Foliage and spikes](Previews/scenery_Section_4.png) · [Boss decorations](Previews/scenery_MiniBoss2_Section.png)

The existing illustrated-presentation suite also passed all 211 checks, including matching combat state across the three graphics styles.

## Generation prompts

### plant_overhead_wide

Production transparent game scenery sprite, wide 3:1 canvas. One sparse shallow hanging ivy garland for the TOP EDGE of a dungeon hallway. Thin crooked dark brown woody vine stretched horizontally with two gentle shallow arcs, small pointed dusty olive ivy leaves in a few separated clusters, a few short dangling tendrils. Plenty of actual transparent open gaps. This is an unobtrusive ceiling decoration; its silhouette is only a narrow band, no giant fern leaves, no big bush, no roots, no mushrooms. Whole subject visible with padding. Same hand-inked fantasy dungeon style: bold irregular near-black outlines, muted olive/ochre colors, broad simple two-tone cel shading, restrained weathered detail. Natural leaf proportions, not vertically compressed shapes. Front view, isolated cutout, genuinely transparent background including all gaps. No scene, wall, floor, text, frame, shadows, glow or watermark.

### plant_wall_wide

Production transparent game scenery sprite on a wide 2:1 landscape canvas. One slender trailing dungeon ivy vine, swept diagonally in a gentle low curve from upper left towards lower right. Thin knotted woody stem, a few clusters of SMALL pointed dusty olive leaves with gaps between each cluster, two short side tendrils. Loose airy open composition, much more transparent space than foliage. This is shallow unobtrusive wall growth for a first-person narrow hallway: no large fern fronds, no bush or flower pot, no floor base, no mushrooms. Whole vine visible with clear margin, naturally proportioned small leaves. Same hand-inked fantasy dungeon game style: thick irregular near-black outlines, muted olive, ochre and bark brown palette, broad two-tone cel shading. Flat front view isolated cutout. Genuine transparent background including all holes. No wall, floor, scene, text, UI, border, glow, cast shadow or watermark.

### plant_low_wide

Production transparent scenery sprite for hand-inked fantasy dungeon game. Wide 2:1 landscape canvas. A small LOW SPREADING tuft of dusty olive ferns and moss sprouting from a thin crooked root, with two tiny dull ochre mushrooms. Naturally short, splayed outward, silhouette twice as wide as high; deliberately designed as low wall-base foliage rather than a tall plant squeezed short. Several delicate small serrated fronds, clearly separated negative spaces, restrained root base, no giant broad leaves. Thick irregular near-black contour lines, muted earthy olive and ochre colors, broad simple two-tone cel shading matching illustrated dungeon stone and timber. Front view. Whole subject centered with padding, genuine transparent background and gaps. No surrounding terrain, wall, floor, planter, shadow, glow, scene, text, frame, watermark.

