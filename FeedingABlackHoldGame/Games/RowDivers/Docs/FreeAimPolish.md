# Free aim feel and readability — 26 October 2026

- Ground targets now use a swept body ellipsoid: 0.70 m horizontal radius and
  1.05 m vertical radius, centered 0.15 m above the actor origin. The old radius
  was 0.36 m. Bosses use 0.90 / 1.35 m. Bats retain the 0.36 m sphere.
  Cursor highlighting and ordinary arrow collisions share the same shape.
- Player arrows use forward-aligned 3D shafts, broadheads and fletching with dark
  silhouettes. Fire/cursed arrows retain their colors. Enemy and bat shots use
  the same ink-edged material family, colored flame faces, and pointed tails.
  Meshes are shared across projectiles. Projectile speed, damage and cooldowns
  are unchanged by the visual replacement.
- The four-page startup tutorial is now one screen: A/D and left/right arrow
  pictures, a mouse with the left button highlighted, and Play. It also remains
  available through How to Play. Pause and death text retain their normal layout.
- Free aim starts with 0.84 m collection range instead of 0.60 m (+40%). Older
  free aim saves gain +0.24 m once, preserving purchased bonuses. Classic retains
  its original range. The `flight_pickup_v2` flag prevents repeat application.

Validation: 78 existing free-aim checks across three visual styles, 19 targeted
checks covering collision edges, high shots, swept motion, visuals, tutorial flow
and pickup migration, plus two editor cursor/tooltip checks and six exact live/model
flight comparisons. Six classic comparisons also retain the earlier outcomes. Current
validation outputs are in `Simulation/PolishValidation/`, separate from the earlier
balance study. Its campaign counts describe the earlier hit areas and collection
range; the generated simulator now uses the updated gameplay rules.

[Tutorial preview](Previews/free_aim_controls.png) ·
[Projectile preview](Previews/free_aim_projectiles.png)
