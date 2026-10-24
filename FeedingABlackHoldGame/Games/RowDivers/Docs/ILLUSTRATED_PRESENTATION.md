# Illustrated presentation — 24 October 2026

Settings → **Art & Audio Style** offers three independent versions:

- **Modern / Synty** retains the first 3D artwork and replacement soundtrack.
- **Original / Row Divers** retains the supplied artwork, restored corridor and original audio.
- **Illustrated / New** uses the restored corridor layout with new inked combat artwork and a fresh local-library audio set.

Style preferences migrate from the existing original-art setting. The new flag is saved separately; older settings files still select their previous style. Switching changes presentation without resetting the dive, progression or combat randomness.

Upgrade-screen icons always retain the Modern/Synty style in all three choices. Menu music uses a persistent player: moving between the main menu and upgrades preserves both the selected track and its playback position. Leaving a music context bookmarks its track and offset for the current session; returning restores that position. Bookmarks are separate for each context and art/audio style, and restored tracks continue looping.

## New artwork

The main menu uses `Art/Illustrated/RailwayFuryGameplayCover.png`, captured directly from the running game in style 3, without HUD overlays. Rebuild it with `Tools/RenderIllustratedMenuCover.gd` using a rendering display server. The standalone concept illustration remains at `Art/Illustrated/RailwayFuryMenu.png` as an alternative, with its prompt in `menu_generation.json`.

38 PNG assets were made with the built-in `image_gen` tool. The direction is thick hand-inked outlines, muted stone/wood/copper colors, simple shading and readable cartoon silhouettes. All generated PNGs are copied unchanged into `Art/Illustrated/`; generated alpha is preserved. Original/Modern images are not overwritten.

The set includes seven distinct enemies, regular/boss masonry and floors, lava/slime, crossbow, dagger, normal/fire/curse arrows, enemy bolt, throwing star, spell crystals, plants, cobweb, spikes, cell bars, wall plaque, throne, loot, status sprites and ability icons. Existing pillar/room geometry and idle/gate motion are retained. A simple procedural shadow is stored as SVG.

`Art/Illustrated/generated_sources.json` records generation prompts and original output paths. `Art/Illustrated/manifest.json` records prompts, hashes, dimensions and source-to-replacement mappings. Reinstall copies with `python tools/import_row_divers_illustrated.py`.

## New audio

All six music tracks come from `C:\Game Assets\Music`:

| Use | Collection / track |
| --- | --- |
| Combat pool | Serpents Requiem — Enchanted Quest |
| Combat pool | Serpents Requiem — Wizards and Wyverns |
| Combat pool | Heraldry: Medieval Combat — track 3 |
| Upgrades/menu | Taverns: Medieval Inn — track 2 |
| Final chamber | Twilight Pilgrims — Silent Horizon |
| Credits | Serpents Requiem — Lost Chronicle |

Music uses the full track, encoded to stereo Vorbis after loudness normalization. The selection favors melodic fantasy/adventure and medieval material over the first replacement's Dark Abyss atmosphere. No internet music is downloaded.

20 fresh effect cues come from `C:\Game Assets\Sound Effects`, including Membrans cartoon arrows/monsters, L.A. Sounds blade movement, AudioVille wooden sword impacts, Hzandbits coins, Varazuvi stone foley, Sound Spark impacts, Levan Nadashvili footsteps, Articulated Sounds magic, 344 Audio dungeon doors and Eiravaein Works UI sounds. The build checks that none reuse a source from the first replacement set. Effect cues are trimmed to audible gestures, normalized and faded, then mixed through the existing Effects bus. The Music bus retains its existing volume control.

`Audio/Illustrated/sources.json` records every exact source, SHA-256, trim, gain and processing choice. Rebuild with `python tools/build_row_divers_illustrated_audio.py`. The two older audio sets remain in their original directories.

## Verification

`VerifyIllustratedPresentation.gd` checks asset coverage, resource loading, independent material caches, three-way live switching, settings persistence, audio routing and matching normalized gameplay state. `VerifyOriginalGraphics.gd` continues to exercise the retained original version. `VerifyRowDiversCampaign.gd -- --illustrated` runs the four-row campaign fixture with the new artwork/audio.

`PreviewIllustratedPresentation.gd` renders gameplay, a boss room, settings and the three selectable versions into `Docs/Previews/` for visual inspection. This presentation work does not certify the port's unresolved native-engine behavior boundaries.
