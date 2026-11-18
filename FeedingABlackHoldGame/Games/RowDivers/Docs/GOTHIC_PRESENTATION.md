# Gothic Gore (optional editor presentation)

Run the game from Godot. Use the **ART** dropdown on the main menu, upgrade
screen, or battle HUD and select **ART: GOTHIC GORE**. Changes apply immediately.
The same setting appears as **Art Style** on the scene's **RuntimeArtStyle** node
in Godot's **Remote** inspector (under the HUD's root Control during battle).
Select Modern, Original, or Illustrated to switch back at any time.

This is a session-only alternative. It carries between scenes until the process
exits, preserves the saved artwork preference, and adds no release settings entry.
The picker is only visible when running with the editor feature.

While Gothic Gore is active, two additional dropdowns select **UPGRADE** and
**COMBAT** music independently. These choices also appear under **Gothic Music**
on **RuntimeArtStyle** in the Remote inspector. They carry between scenes for the
current session and use the existing Music volume setting.

- Upgrade: **Sanctum Obscura** (default), **Forbidden Grimoire**, **Dusk Covenant**
  from Phat Phrog Studio's *Dark Arts* collection.
- Combat: **Abyssal Slayer** (default), **Carnage Requiem**, **Blood Crucible**
  from Phat Phrog Studio's *Hellfire Reigns* collection.

Sources are the user's `C:\Game Assets\Music` library. Full tracks are normalized
to -20 LUFS with a -2 dBTP limit and encoded as stereo Vorbis. Source paths,
source/output hashes and durations are recorded in `Audio/Gothic/sources.json`.
Tracks loop and maintain separate playback bookmarks when changing selections,
entering combat, returning to upgrades or switching art styles. Existing styles
retain their own music. Rebuild using `python tools/build_row_divers_gothic_music.py`.
Verify with `res://Games/RowDivers/Tools/VerifyGothicMusic.gd` (29 checks).

The presentation includes seven enemy designs and a bat, a skull-mounted bone bow,
bloodied dagger, serrated bone projectiles, blood sprays and temporary floor marks,
bloodstained charcoal masonry, dark panels and crimson UI accents. All 113 upgrade
entries use skull, radiation, poison, broken-bone, anatomical-heart or occult badges.
Completed upgrades retain their symbol. The charcoal upgrade background animates
repeating symbols through quantized cloth-wave distortion with pixel grain.
Collections and ability badges also use the dark symbols. Other styles retain their
own material and projectile caches. Collision bounds, stats and progression are shared.

The eight enemies use painted transparent PNG sprites based on the Illustrated
linen wraith (`Art/Illustrated/enemy_3.png`): irregular hand-inked contours,
textured cloth, cracked bone, ember eyes and distinct compact silhouettes.
The lineup is Grave Thrall, Iron Executioner, Marrow Brute, Mourning Wraith,
Plague Confessor, Thorn Widow, Ossuary Sovereign and Crypt Bat. Generated source
paths, prompts and SHA-256 hashes are in `Art/Gothic/painted-enemies.json`.
The enemy textures have a slight rendering exposure lift to preserve their
painted detail against the dark corridor fog.

SVG UI and scenery assets live alongside the painted PNGs in `Art/Gothic/`.
Recreate the vectors from the repository root (this preserves the painted enemy
manifest mappings):

```powershell
python tools/create_gothic_art.py
```

Validation (from the repository root):

```powershell
& './Godot/Godot_v4.6-stable_win64_console.exe' --headless --path FeedingABlackHoldGame --script res://Games/RowDivers/Tools/VerifyGothicPresentation.gd
```

To regenerate the rendered gameplay and upgrade previews, omit `--headless` and
append `-- --preview`. The fixture uses fresh in-memory progression, disables
result persistence and redirects local settings to a separate verification file.
It checks asset coverage, every upgrade symbol, all enemy variants, live switching,
RNG isolation, unchanged progression, background activation, and restoration of
the existing artwork. Screenshots are `Docs/Previews/gothic-battle.png` and
`Docs/Previews/gothic-upgrades.png`.
`Docs/Previews/gothic-enemy-gallery.png` shows all eight painted replacements.
