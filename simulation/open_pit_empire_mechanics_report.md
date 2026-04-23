# Open Pit Empire Mechanics Comparison

This is a separate mechanics-aware estimate layered on top of the progression report.
It treats multi-shot, pierce/laser lines, splash, and electric chaining as explicit throughput sources and compares that estimate against the abstract progression sim.

## Summary
- Source scenario: `ultra_expensive_2`
- Compared runs: `57`
- Mean absolute percent difference vs progression sim: `30.9%`
- Mean absolute block difference per run: `4333` blocks
- Closest run: `27` in `Kernel Vault` at `-0.2%` (1475 vs 1479 blocks)
- Widest gap: `15` in `Ghost Sector` at `+69.5%` (565 vs 333 blocks)

## How This Second Sim Works
- `Laser Cutter`, `Void Cutters`, and `Inversion Drives` raise pierce-line clearing.
- `Rapid Cycle`, `Breach Drones`, and `Fault Harpoons` raise effective shot count.
- `Overburn Reactors`, `Seismic Lattice`, `Gravity Wells`, and `Ash Crowns` add splash clearing.
- `Shock Bits`, `Mirror Daemons`, `Fault Oracles`, and `Null Archive` add electric or chain-style clearing.
- Ship movement is now a hard limiter: the estimate assumes the ship has to move near blocks, stay in engagement range, and sweep a finite corridor while firing.
- Layer density, traversal drag, block footprint, and HP pressure vary by layer, so the same kit clears very differently at the top and bottom.

## By Layer
- `Proxy Cache`: mechanics sim averages `182` blocks/run vs progression sim `239` (`-24.1%`).
- `Cipher Depths`: mechanics sim averages `425` blocks/run vs progression sim `332` (`+28.1%`).
- `Ghost Sector`: mechanics sim averages `812` blocks/run vs progression sim `716` (`+13.5%`).
- `Kernel Vault`: mechanics sim averages `1255` blocks/run vs progression sim `1152` (`+8.9%`).
- `Root Well`: mechanics sim averages `1582` blocks/run vs progression sim `1789` (`-11.6%`).
- `Mirror Shelf`: mechanics sim averages `1870` blocks/run vs progression sim `3058` (`-38.9%`).
- `Reverse Fault`: mechanics sim averages `4823` blocks/run vs progression sim `12350` (`-61.0%`).
- `Null Vein`: mechanics sim averages `8642` blocks/run vs progression sim `22162` (`-61.0%`).
- `Grave Mantle`: mechanics sim averages `15314` blocks/run vs progression sim `42546` (`-64.0%`).
- `Crown of Ash`: mechanics sim averages `26308` blocks/run vs progression sim `77016` (`-65.8%`).

## Run Comparison
| Run | Zone | Abstract Blocks | Mechanics Blocks | Delta | Delta % |
|---:|---|---:|---:|---:|---:|
| 1 | Proxy Cache | 105 | 97 | -8 | -7.3% |
| 2 | Proxy Cache | 153 | 122 | -32 | -20.6% |
| 3 | Proxy Cache | 181 | 146 | -35 | -19.5% |
| 4 | Proxy Cache | 211 | 175 | -36 | -17.2% |
| 5 | Proxy Cache | 406 | 279 | -128 | -31.4% |
| 6 | Proxy Cache | 378 | 270 | -108 | -28.5% |
| 7 | Cipher Depths | 129 | 142 | +13 | +10.3% |
| 8 | Cipher Depths | 167 | 174 | +7 | +4.3% |
| 9 | Cipher Depths | 186 | 214 | +28 | +15.0% |
| 10 | Cipher Depths | 235 | 324 | +89 | +37.6% |
| 11 | Cipher Depths | 301 | 404 | +103 | +34.3% |
| 12 | Cipher Depths | 365 | 483 | +118 | +32.2% |
| 13 | Cipher Depths | 636 | 764 | +128 | +20.1% |
| 14 | Cipher Depths | 636 | 897 | +261 | +41.1% |
| 15 | Ghost Sector | 333 | 565 | +231 | +69.5% |
| 16 | Ghost Sector | 445 | 642 | +197 | +44.3% |
| 17 | Ghost Sector | 506 | 695 | +190 | +37.5% |
| 18 | Ghost Sector | 572 | 748 | +176 | +30.8% |
| 19 | Ghost Sector | 983 | 960 | -23 | -2.4% |
| 20 | Ghost Sector | 900 | 938 | +38 | +4.2% |
| 21 | Ghost Sector | 1272 | 1138 | -134 | -10.5% |
| 22 | Kernel Vault | 630 | 852 | +222 | +35.3% |
| 23 | Kernel Vault | 747 | 994 | +247 | +33.1% |
| 24 | Kernel Vault | 976 | 1197 | +222 | +22.7% |
| 25 | Kernel Vault | 1220 | 1348 | +129 | +10.6% |
| 26 | Kernel Vault | 1862 | 1662 | -200 | -10.7% |
| 27 | Kernel Vault | 1479 | 1475 | -4 | -0.2% |
| 28 | Root Well | 1079 | 1228 | +149 | +13.8% |
| 29 | Root Well | 1337 | 1354 | +17 | +1.3% |
| 30 | Root Well | 1492 | 1430 | -62 | -4.2% |
| 31 | Root Well | 1058 | 1218 | +160 | +15.1% |
| 32 | Root Well | 1972 | 1664 | -308 | -15.6% |
| 33 | Root Well | 2684 | 2034 | -650 | -24.2% |
| 34 | Root Well | 2901 | 2148 | -753 | -26.0% |
| 35 | Mirror Shelf | 593 | 875 | +282 | +47.5% |
| 36 | Mirror Shelf | 834 | 1014 | +180 | +21.6% |
| 37 | Mirror Shelf | 1176 | 1192 | +16 | +1.4% |
| 38 | Mirror Shelf | 1585 | 1392 | -193 | -12.2% |
| 39 | Mirror Shelf | 2071 | 1655 | -416 | -20.1% |
| 40 | Mirror Shelf | 2515 | 1898 | -617 | -24.5% |
| 41 | Mirror Shelf | 1568 | 1500 | -68 | -4.3% |
| 42 | Mirror Shelf | 2026 | 1829 | -197 | -9.7% |
| 43 | Mirror Shelf | 4391 | 2625 | -1766 | -40.2% |
| 44 | Mirror Shelf | 6152 | 2589 | -3562 | -57.9% |
| 45 | Mirror Shelf | 5340 | 2740 | -2599 | -48.7% |
| 46 | Mirror Shelf | 8441 | 3126 | -5315 | -63.0% |
| 47 | Reverse Fault | 13657 | 5130 | -8527 | -62.4% |
| 48 | Reverse Fault | 9438 | 3920 | -5518 | -58.5% |
| 49 | Reverse Fault | 10850 | 4400 | -6450 | -59.4% |
| 50 | Reverse Fault | 15454 | 5840 | -9613 | -62.2% |
| 51 | Null Vein | 28902 | 10572 | -18330 | -63.4% |
| 52 | Null Vein | 18120 | 7442 | -10677 | -58.9% |
| 53 | Null Vein | 19466 | 7912 | -11554 | -59.4% |
| 54 | Grave Mantle | 59860 | 20482 | -39378 | -65.8% |
| 55 | Grave Mantle | 25231 | 10146 | -15085 | -59.8% |
| 56 | Crown of Ash | 96057 | 32020 | -64037 | -66.7% |
| 57 | Crown of Ash | 57976 | 20596 | -37380 | -64.5% |
