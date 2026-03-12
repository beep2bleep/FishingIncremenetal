# Audio License Audit

Date: 2026-03-12
Project: `FishingIncremental`

This audit covers audio files that are referenced by the Godot project, based on:

- `FeedingABlackHoldGame/Audio/Main Music Playlist.tres`
- referenced `.tscn` files
- referenced `.tres` sound effect settings

It does not treat every audio file present in the repository as in use. It covers the files actually referenced by the project.

## Summary

- Confirmed usable with clear source license:
  - 11 `Phat Phrog Studio` music tracks
  - all referenced `zapsplat_*` files under the ZapSplat license family
  - 1 likely `CC0` Julien Matthey impact sound
- Likely usable but still needs original acquisition proof:
  - `skyclad_*`
- High-risk / unresolved:
  - generic renamed SFX files with no traceable source
  - `esm_*`, `sound_ex_machina_*`, and `Voicy_*` files without original license records

## Referenced Music

| File | Referenced by / use | Status | License determination | Notes |
| --- | --- | --- | --- | --- |
| `FeedingABlackHoldGame/Audio/Music/7 - Phat Phrog Studio - Hellfire Tempest - Carnage Cabaret - LOOP.wav` | `Audio/Main Music Playlist.tres`; rotating background music used by `MusicPlayer.tscn` | Confirmed | Phat Phrog Studio commercial usage license | Royalty-free commercial game use; no resale/redistribution of raw asset. |
| `FeedingABlackHoldGame/Audio/Music/7 - Phat Phrog Studio - Verdant Glade - The Quiet Wild.wav` | `Audio/Main Music Playlist.tres`; rotating background music used by `MusicPlayer.tscn` | Confirmed | Phat Phrog Studio commercial usage license | Replaced unresolved `Lofi_Hip_Hop__BPM145.mp3`. |
| `FeedingABlackHoldGame/Audio/Music/1 - Phat Phrog Studio - Wayward Realm - Celestial Veil.wav` | `Audio/Main Music Playlist.tres`; rotating background music used by `MusicPlayer.tscn` | Confirmed | Phat Phrog Studio commercial usage license | Replaced unresolved `BH_Ambient_1__BPM60.mp3`. |
| `FeedingABlackHoldGame/Audio/Music/1 - Phat Phrog Studio - Shadow Exile - Synth Shogun.wav` | `Audio/Main Music Playlist.tres`; rotating background music used by `MusicPlayer.tscn` | Confirmed | Phat Phrog Studio commercial usage license | Replaced unresolved `Drum_n_Bass_1.mp3`. |
| `FeedingABlackHoldGame/Audio/Music/2 - Phat Phrog Studio - Shadow Exile - Night Splice.wav` | `Audio/Main Music Playlist.tres`; rotating background music used by `MusicPlayer.tscn` | Confirmed | Phat Phrog Studio commercial usage license | Replaced unresolved `Electronica__BPM110.mp3`. |
| `FeedingABlackHoldGame/Audio/Music/8 - Phat Phrog Studio - Verdant Glade - Fernsong.wav` | `Audio/Main Music Playlist.tres`; rotating background music used by `MusicPlayer.tscn` | Confirmed | Phat Phrog Studio commercial usage license | Replaced unresolved `Reggae___Lofi_Hip_Hop__BPM75.mp3`. |
| `FeedingABlackHoldGame/Audio/Music/7 - Phat Phrog Studio - Shadow Exile - Tokyo Uprising.wav` | `Audio/Main Music Playlist.tres`; rotating background music used by `MusicPlayer.tscn` | Confirmed | Phat Phrog Studio commercial usage license | Replaced unresolved `Drum_n_Bass_2.mp3`. |
| `FeedingABlackHoldGame/Audio/Music/8 - Phat Phrog Studio - Shadow Exile - Sakura Slipstream.wav` | `Audio/Main Music Playlist.tres`; rotating background music used by `MusicPlayer.tscn` | Confirmed | Phat Phrog Studio commercial usage license | Replaced unresolved `Electronica_2__BPM130.mp3`. |
| `FeedingABlackHoldGame/Audio/Music/7 - Phat Phrog Studio - Skyward Spire - Nova Rift.wav` | `Audio/Main Music Playlist.tres`; rotating background music used by `MusicPlayer.tscn` | Confirmed | Phat Phrog Studio commercial usage license | Replaced unresolved `Reggaeton___Lofi_Hip_Hop__BPM90.wav`. |
| `FeedingABlackHoldGame/Audio/Music/2 - Phat Phrog Studio - Wayward Realm - Astral Winds.wav` | `Audio/Main Music Playlist.tres`; rotating background music used by `MusicPlayer.tscn` | Confirmed | Phat Phrog Studio commercial usage license | Replaced unresolved `BH_Ambient_2__BPM88.mp3`. |
| `FeedingABlackHoldGame/Audio/Music/3 - Phat Phrog Studio - Wayward Realm - Moonsong Kingdom.wav` | `MusicPlayer.tscn`; `MusicPlayer.gd` swaps to this during game over | Confirmed | Phat Phrog Studio commercial usage license | Replaced unresolved `Game Over Song.mp3`. |

## Referenced Sound Effects

| File | Referenced by / use | Status | License determination | Notes |
| --- | --- | --- | --- | --- |
| `FeedingABlackHoldGame/Audio/zapsplat_cartoon_bubble_pop_003_40275.mp3` | `Game Mode Panel.tscn`, `TECH_TREE_NODE_POP_IN.tres`, `STAR_DESTROYED.tres`; pop/hover UI feedback and star destroy pop | Confirmed | ZapSplat Standard License | Attribution required unless downloaded under Gold plan. |
| `FeedingABlackHoldGame/Audio/zapsplat_cartoon_orchestral_musical_tone_ta_da_reveal_103156.mp3` | `End Of Run Summary.tscn`; celebratory reveal sting | Confirmed | ZapSplat Standard License | Attribution required unless downloaded under Gold plan. |
| `FeedingABlackHoldGame/Audio/zapsplat_cartoon_pop_bubble_etc_002_77425.mp3` | `Sound Effect Settings/PLANET_BREAK.tres`; planet break sound | Confirmed | ZapSplat Standard License | Attribution required unless downloaded under Gold plan. |
| `FeedingABlackHoldGame/Audio/zapsplat_cartoon_pop_mouth_011_46674.mp3` | `ON_ASTEROID_SUCK_UP.tres`, `ON_ASTEROID_DESTORY.tres`; asteroid suck-up and destroy pop | Confirmed | ZapSplat Standard License | Attribution required unless downloaded under Gold plan. |
| `FeedingABlackHoldGame/Audio/zapsplat_cartoon_pops_bubbles_several_fast_001_73442.mp3` | `Space/PINATA_BREAK.tres`; pinata break burst | Confirmed | ZapSplat Standard License | Attribution required unless downloaded under Gold plan. |
| `FeedingABlackHoldGame/Audio/zapsplat_foley_stick_medium_swing_in_air_whoosh_fast_001_110466.mp3` | `Tech Tree Stuff/Tech Tree Node.tscn`; node shrink/motion whoosh | Confirmed | ZapSplat Standard License | Attribution required unless downloaded under Gold plan. |
| `FeedingABlackHoldGame/Audio/zapsplat_foley_wood_thick_dense_light_single_tap_could_be_wooden_ball_sriking_another_002_76775.mp3` | `STAR_HIT.tres`, `PLANET_HIT.tres`, `ON_CLICKER_CRIT.tres`, `ON_ASTEROID_CLICKED.tres`; shared hit/impact sound | Confirmed | ZapSplat Standard License | Attribution required unless downloaded under Gold plan. |
| `FeedingABlackHoldGame/Audio/zapsplat_multimedia_button_click_001_68773.mp3` | `Sound Effect Settings/BUTTON_CLICK.tres`; general button click and click reward feedback | Confirmed | ZapSplat Standard License | Attribution required unless downloaded under Gold plan. |
| `FeedingABlackHoldGame/Audio/zapsplat_multimedia_game_sound_clunk_generic_item_tone_003_49778.mp3` | `Sound Effect Settings/BLACK_HOLE_GROW.tres`; black hole growth tone | Confirmed | ZapSplat Standard License | Attribution required unless downloaded under Gold plan. |
| `FeedingABlackHoldGame/Audio/zapsplat_office_pen_biro_nib_tap_on_wood_001_33612.mp3` | `MOON.tres`; moon tap/hit sound | Confirmed | ZapSplat Standard License | Attribution required unless downloaded under Gold plan. |
| `FeedingABlackHoldGame/Audio/zapsplat_shockwave_designed_001_93120.mp3` | `Supernova.tscn`; supernova explosion layer | Confirmed | ZapSplat Standard License | Attribution required unless downloaded under Gold plan. |
| `FeedingABlackHoldGame/Audio/zapsplat_sound_design_electricity_zap_spark_28906.mp3` | `ELECTRIC.tres`, `ELECTRIC_CRIT.tres`; electric hit and crit spark | Confirmed | ZapSplat Standard License | Attribution required unless downloaded under Gold plan. |
| `FeedingABlackHoldGame/Audio/zapsplat_sound_design_hit_thud_into_descending_slowing_tail_slow_motion_001_65460.mp3` | `Supernova.tscn`; supernova shrink/impact lead-in | Confirmed | ZapSplat Standard License | Attribution required unless downloaded under Gold plan. |
| `FeedingABlackHoldGame/Audio/zapsplat_sound_design_whoosh_slow_mo_timewarp_001_106393.mp3` | `Main Menu.tscn`, `SceneChanger.tscn`; menu and scene transition whoosh | Confirmed | ZapSplat Standard License | Attribution required unless downloaded under Gold plan. |
| `FeedingABlackHoldGame/zapsplat_multimedia_game_sound_hit_thud_success_win_finish_73561.mp3` | `Sound Effect Settings/BLACK_HOLE_GROW_MILESTONE.tres`; milestone/win accent | Confirmed | ZapSplat Standard License | Attribution required unless downloaded under Gold plan. |
| `FeedingABlackHoldGame/Audio/julien_matthey_impact_snowball_on_cement_002.mp3` | `Space/FORZEN_SHARD_IMPACT.tres`; frozen shard impact sound | Likely confirmed | Likely CC0 via Freesound | Filename strongly matches Julien Matthey `JM_IMPACT_01b - Snow on cement.wav`. Keep original source record if available. |
| `FeedingABlackHoldGame/Audio/skyclad_sound_gong_sound_design_muffled_low_heavy_ponderous_262.mp3` | `Singletons/Main.tscn`; game-over gong | Likely | Likely ZapSplat Standard License | Web match suggests a ZapSplat-hosted Skyclad Sound asset. Keep original source record if available. |
| `FeedingABlackHoldGame/Audio/sound_ex_machina_Button_Tick_Loop.mp3` | `End Of Run Summary.tscn`, `Tier Summary.tscn`; looping stat-count tick during summary animation | High risk | Likely Artlist asset, but license unclear for this use | Artlist license treatment for apps/games can require specific business coverage. Needs original account/license proof. |
| `FeedingABlackHoldGame/Audio/Voicy_Hitmarker Sound.mp3` | `Sound Effect Settings/RADIOACTIVE_DOT.tres`; DOT/hitmarker feedback | High risk | Unknown | Voicy public clips are not safely assumable for commercial game redistribution. Needs explicit source/license proof. |
| `FeedingABlackHoldGame/Audio/esm_victory_horns_alert_sound_fx_arcade_synth_musical_chord_bling_electronic_casino_kids_mobile_positive_achievement_score.mp3` | `Tier Summary.tscn`; victory/tier-complete sting | High risk | Possibly Epidemic Sound, not confirmed | `esm_` strongly suggests Epidemic Sound, but rights depend on the actual subscription/license path. |
| `FeedingABlackHoldGame/Art/Level_Up_Sound_1.mp3` | `UpgradeScreen.tscn`; one of the upgrade/level-up reward sounds | Unresolved | Unknown | Renamed/localized file with no traceable public source by filename. |
| `FeedingABlackHoldGame/Art/Level_Up_Sound_2.mp3` | `UpgradeScreen.tscn`; one of the upgrade/level-up reward sounds | Unresolved | Unknown | Renamed/localized file with no traceable public source by filename. |
| `FeedingABlackHoldGame/Art/Level_Up_Sound_3.mp3` | `UpgradeScreen.tscn`; one of the upgrade/level-up reward sounds | Unresolved | Unknown | Renamed/localized file with no traceable public source by filename. |
| `FeedingABlackHoldGame/Art/Level_Up_Sound_4.mp3` | `Sound Effect Settings/TECH_TREE_NODE_CLICK.tres`; tech tree purchase/click confirmation | Unresolved | Unknown | Renamed/localized file with no traceable public source by filename. |
| `FeedingABlackHoldGame/Audio/bong_001.mp3` | `AudioManager.tscn`, `CLICK_HIT_NOTHING.tres`, `TECH_TREE_NODE_HOVER.tres`; hover and miss-click feedback | Unresolved | Unknown | Generic filename; no defensible source found. |
| `FeedingABlackHoldGame/Audio/cartoon_success_fanfair.mp3` | `Black Hole Art.tscn`; win-game fanfare | Unresolved | Unknown | Generic filename; no defensible source found. |
| `FeedingABlackHoldGame/Audio/dice_tap.mp3` | `ON_RESOURCE_SUCKED_UP.tres`, `ON_ASTEROID_SPAWNED.tres`; resource/spawn tap sound | Unresolved | Unknown | Generic filename; no defensible source found. |
| `FeedingABlackHoldGame/Audio/golden.mp3` | `ON_GOLDEN_BREAK.tres`, `ON_GOLDEN_BREAK_CRIT.tres`; golden-object break sound | Unresolved | Unknown | Generic filename; no defensible source found. |
| `FeedingABlackHoldGame/Audio/ice freeze.mp3` | `FROZEN_PLANET_BREAK.tres`; frozen planet break sound | Unresolved | Unknown | Generic filename; no defensible source found. |
| `FeedingABlackHoldGame/Audio/Laser.mp3` | `ON_LASER.tres`, `ON_LASER_CRIT.tres`; laser hit/crit sound | Unresolved | Unknown | Generic filename; no defensible source found. |
| `FeedingABlackHoldGame/Audio/Marble_OnCollide.mp3` | `Sound Effect Settings/COMET.tres`; comet collision sound | Unresolved | Unknown | Generic filename; no defensible source found. |
| `FeedingABlackHoldGame/Audio/Supernova.mp3` | `Sound Effect Settings/SUPERNOVA.tres`; supernova activation sound | Unresolved | Unknown | Generic filename; no defensible source found. |
| `FeedingABlackHoldGame/Audio/Swipe.mp3` | `AudioManager.tscn`; loaded as a shared audio resource, but no direct current use was found in the referenced sound settings | Unresolved | Unknown | Generic filename; no defensible source found. May be leftover or used indirectly. |
| `FeedingABlackHoldGame/Black Hole Collapse.mp3` | `Sound Effect Settings/BLACK_HOLE_COLLAPSE.tres`; black hole collapse event sound | Unresolved | Unknown | Renamed/localized file with no traceable public source by filename. |
| `FeedingABlackHoldGame/Black Hole Game Over.mp3` | `Singletons/Main.tscn`; game-over audio layer | Unresolved | Unknown | Renamed/localized file with no traceable public source by filename. |
| `FeedingABlackHoldGame/Star Electric.mp3` | `ELECTRIC_STAR.tres`, `ELECTRIC_STAR_CRIT.tres`; electric-star hit and crit sound | Unresolved | Unknown | Renamed/localized file with no traceable public source by filename. |

## License Notes

### ZapSplat

- Standard license permits use in games and other commercial projects.
- Attribution is required on the standard/free license.
- Attribution may not be required if the asset was downloaded under a paid Gold plan.
- Raw asset redistribution is not allowed.

### Phat Phrog Studio

- Commercial use in games is allowed under their commercial usage license.
- The license is non-exclusive and non-transferable.
- Raw standalone redistribution is not allowed.

### Freesound / CC0

- If the Julien Matthey match is correct, CC0 permits commercial use without attribution.
- This should still be backed by the original download/source record.

### Artlist / Epidemic / Voicy

- These libraries are plan-dependent and use-case-dependent.
- A filename match alone is not enough to prove the shipped game is covered.
- Treat these assets as not cleared unless you have the original account, download history, and applicable license terms for game/app distribution.

## Recommended Actions

1. Replace or re-source all `Unresolved` and `High risk` files.
2. If any `ZapSplat` files were downloaded on the free tier, add attribution before release.
3. Preserve receipts, download confirmations, or account records for every paid or subscription-based asset provider.
4. Prefer keeping the original downloaded filename or maintaining a separate provenance spreadsheet when importing audio.

## Suggested Replacements

The goal here is not to find exact clones of the current files. The goal is to replace risky or untraceable audio with assets whose provenance is easy to prove at release time.

Preferred source order:

1. `Kenney` packs when they fit, because the license position is simple and low-friction.
2. `Freesound` assets that are explicitly `CC0`.
3. `Pixabay` audio with saved download links and filenames.
4. `OpenGameArt` assets only when the specific asset is `CC0` or a license you are prepared to attribute and track.

Avoid as replacements unless you can tie them to the original purchase/account:

- `Artlist`
- `Epidemic Sound`
- `Voicy`
- any reposted audio on random mirror/download sites

### Replacement Matrix

| Current file(s) | In-game role | Suggested replacement profile | Safer source strategy |
| --- | --- | --- | --- |
| `Audio/Music/BH_Ambient_1__BPM60.mp3`, `Audio/Music/BH_Ambient_2__BPM88.mp3` | ambient background playlist | dark ambient, space ambient, drone, low-BPM loopable music | Prefer `Pixabay Music` or `OpenGameArt` assets with clear CC0/CC-BY terms; save download page URLs. |
| `Audio/Music/Drum_n_Bass_1.mp3`, `Audio/Music/Drum_n_Bass_2.mp3` | energetic background playlist | loopable electronic / DnB combat-lite tracks | Prefer `Pixabay Music`; if using `OpenGameArt`, choose only assets with clearly acceptable attribution terms. |
| `Audio/Music/Electronica__BPM110.mp3`, `Audio/Music/Electronica_2__BPM130.mp3` | energetic background playlist | upbeat electronic loops with clean intros/outros | Prefer `Pixabay Music`; save proof of license and download metadata. |
| `Audio/Music/Lofi_Hip_Hop__BPM145.mp3`, `Audio/Music/Reggae___Lofi_Hip_Hop__BPM75.mp3`, `Audio/Music/Reggaeton___Lofi_Hip_Hop__BPM90.wav` | lighter background playlist rotation | mellow loopable instrumental tracks | Prefer `Pixabay Music`; alternatively replace with your own generated loop stems if you want zero chain-of-title ambiguity. |
| `Audio/Music/Game Over Song.mp3` | game over music cue | short, somber 10-30 second sting or loop | Prefer `Pixabay Music`; shorter custom cue is better than a full song for audit simplicity. |
| `Art/Level_Up_Sound_1.mp3`, `Art/Level_Up_Sound_2.mp3`, `Art/Level_Up_Sound_3.mp3`, `Art/Level_Up_Sound_4.mp3` | upgrade / tech tree reward sounds | arcade level-up chime, reward blip, synth success stinger | Replace from `Kenney` if a pack fits, otherwise `Freesound CC0` or `Pixabay Sound Effects`. |
| `Audio/bong_001.mp3` | hover / invalid / miss feedback | short muted UI blip or soft wood/plastic tick | Best replaced from `Kenney UI/Interface`-style packs or `Freesound CC0`. |
| `Audio/cartoon_success_fanfair.mp3` | win-game fanfare | bright success brass/synth fanfare under 2 seconds | Prefer `Pixabay Sound Effects` or `Freesound CC0`. |
| `Audio/dice_tap.mp3` | resource/spawn tap | small tactile click/tap | Prefer `Freesound CC0` with search terms like `ui tap`, `wood tap`, `dice tap`. |
| `Audio/golden.mp3` | golden object break | shiny reward burst, coin sparkle, metallic success bling | Prefer `Pixabay Sound Effects` or `Freesound CC0`. |
| `Audio/ice freeze.mp3` | frozen planet break | ice crack, freeze burst, glassy break | Prefer `Freesound CC0`; these are common and easy to replace. |
| `Audio/Laser.mp3`, `Star Electric.mp3` | laser / electric hits | sci-fi zap, laser shot, electric arc | Prefer `Kenney` if suitable; otherwise `Freesound CC0` or `Pixabay Sound Effects`. |
| `Audio/Marble_OnCollide.mp3` | comet collision | rock hit, marble knock, impact thunk | Prefer `Freesound CC0`. |
| `Audio/Supernova.mp3` | supernova activation | large energy swell, explosion charge-up, cosmic burst | Prefer layered replacement: one CC0 swell + one CC0 impact, rather than one opaque downloaded file. |
| `Audio/Swipe.mp3` | currently appears unused or indirect | whoosh / swipe UI motion | Replace only if you confirm runtime use; use `Freesound CC0` or `Kenney`. |
| `Black Hole Collapse.mp3`, `Black Hole Game Over.mp3` | black hole collapse and game over events | low-frequency collapse, ominous cinematic hit, dark game-over sting | Prefer `Pixabay Sound Effects` or a small custom layered cue built from `CC0` sources. |
| `Audio/sound_ex_machina_Button_Tick_Loop.mp3` | summary count-up loop | subtle ticking / data-count loop / mechanical UI loop | Replace with a simple self-made loop built from one or two `CC0` clicks if possible. This is safer than another library track. |
| `Audio/Voicy_Hitmarker Sound.mp3` | DOT/hitmarker feedback | dry hitmarker click or short digital tick | Prefer `Freesound CC0` or self-generated one-shot. |
| `Audio/esm_victory_horns_alert_sound_fx_arcade_synth_musical_chord_bling_electronic_casino_kids_mobile_positive_achievement_score.mp3` | tier victory sting | short victory sting / arcade achievement bling | Prefer `Pixabay Sound Effects` or `Freesound CC0`. |

### Practical Search Terms

Use these search terms on the safer source libraries:

- `space ambient loop`
- `dark ambient game loop`
- `drum and bass loop game`
- `electronic loop arcade`
- `lofi loop instrumental`
- `game over sting`
- `level up chime`
- `reward stinger`
- `ui click`
- `soft hover blip`
- `coin sparkle`
- `ice crack`
- `laser zap`
- `electric spark`
- `rock impact`
- `sci fi explosion swell`
- `hitmarker`
- `victory sting arcade`

### Replacement Workflow

1. Replace all `High risk` files first.
2. Replace all `Unresolved` files that are player-facing and repeated often:
   - upgrade sounds
   - button/hover sounds
   - combat hit sounds
   - victory/game-over sounds
3. Replace unresolved background music last, because that pass usually requires the most listening time.
4. For every replacement, log:
   - source site
   - asset page URL
   - author/uploader
   - license shown on the asset page
   - original downloaded filename
   - local renamed filename in the project

### Best Low-Risk Option

For UI sounds and short feedback effects, the cleanest path is often to replace them with either:

- `Kenney` assets where available, or
- hand-picked `Freesound` assets that are explicitly `CC0`

For music, the cleanest low-admin path is usually:

- `Pixabay Music`, with the download URL and filename saved alongside your project records

For cinematic one-shots like `Supernova`, `Black Hole Collapse`, and `Game Over`, the safest path is often:

- build a new composite cue from 2-3 clearly documented `CC0` one-shots instead of depending on a single opaque third-party file

## Source Links

- ZapSplat Standard License: <https://zapsplat-assets.s3.amazonaws.com/zapsplat-standard-license.pdf>
- ZapSplat license FAQ: <https://www.zapsplat.com/faq-category/license-and-usage/>
- Phat Phrog Studio asset and license pages: <https://www.phatphrogstudio.com/gamedevassets>
- Phat Phrog Studio commercial usage license PDF: <https://www.phatphrogstudio.com/_files/ugd/e25a6f_16a26f656d8047f696e6f143ee1a171e.pdf>
- Freesound Julien Matthey match: <https://freesound.org/people/Julien_Matthey/sounds/167081/>
- Artlist app-use guidance: <https://help.artlist.io/hc/en-us/articles/6185466981661-Using-the-assets-in-an-app>
- Artlist music and SFX plans: <https://help.artlist.io/hc/en-us/articles/7757827155741-Music-SFX-plans>
- Voicy Premium FAQ: <https://premium.voicy.network/faq>

## Confidence Caveat

This file is an audit, not legal advice. Any asset marked `Likely`, `Unresolved`, or `High risk` should be treated as uncleared for release until you can tie it to the original source page and the exact license terms under which it was acquired.
