# Placeholder art inventory

All reference art is replaced by code-created shapes; no Unity art is bundled.

| Element | Current representation | Replacement needed |
| --- | --- | --- |
| Player bow / arrow | Brown horizontal box and thin ivory box in first-person view | Bow, string, hands, reload animation |
| Dagger | Automatic attack logic with knife sound | First-person dagger and stab animation |
| Zombie | Green box body and cube head | Zombie sprite/mesh and animations |
| Zombie variant I | Tan body/head boxes | Armored/strong variant artwork |
| Zombie variant II | Purple body/head boxes | Damage variant artwork |
| Mummy | Pale body/head boxes moving toward the player | Mummy sprite/mesh and walk animation |
| Two minibosses | Larger red/pink boxes | Separate miniboss artwork, entrances and defeat animation |
| Final boss | Larger gold box | Boss artwork, entrance and defeat animation |
| Six corridor variants | Box floor, ceiling, walls and repeating dark seams | Dungeon geometry, materials and decorative variation |
| Bow projectiles | Thin ivory boxes | Arrow sprites/meshes and trails |
| Fire / curse / shuriken | Purple projectile boxes, distinct damage logic | Distinct projectile sprites, fire, curse and spinning shuriken effects |
| Enemy projectiles | Pink narrow boxes | Enemy projectile artwork |
| Third Eye | Mouse-targeted damage logic | Eye icon, beam and hit effects |
| Gold/chest drops | Small gold cubes | Coin and copper/silver/gold chest models |
| Gem drops | Small purple cubes | Gem model and attraction effect |
| Crown | Text currency reward | Crown icon / boss reward effect |
| Upgrade icons | Arrow, cross, diamond, dagger, triangle, star and circle glyphs | 112 upgrade icons; original graph coordinates and rarity borders are retained |
| Ability states | Text timers | Four ability icons, active/cooldown fills |
| Health, armor, distance | Text HUD | Bars and final HUD art |
| Bestiary / achievements | Text lists and claim buttons | Enemy portraits and achievement icons |
| Upgrade background | Solid dark rectangle | Final background art |
| Damage, critical, heal, status | Health labels and game logic | Floating numbers, status icons and particles |

Music and effects are from `C:\Game Assets`, with exact file paths and processing listed in `../Audio/sources.json`. Music is full-length PCM16 and loops. Effects are normalized and limited to two seconds. The two tracks are Phat Phrog Studio's *Dark Abyss — Shaded Fragments* (upgrades) and *Void Warden* (gameplay).
