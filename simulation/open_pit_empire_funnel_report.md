# Open Pit Empire Layer Progression Simulation

This pass models a persistent-destruction layer run with money, XP, and core upgrades, plus global layer-clear powerups that ramp from 1.5x to 3.0x damage and carry forward into every deeper layer.

## Best Scenario
- Scenario: `ultra_expensive_2`
- 30 minute demo progress: 44.4% through the top-side descent (22.2% of the full layer arc)
- Root Well reached: 69.2m
- Crown of Ash cleared: 125.6m
- Runs: 57
- Average purchases per run: 2.98
- Runs without a purchase: 0

## Proposed Layer-Clear Powerups
- 20% layer clear: `Layer Breaker I` = 1.5x global mining damage
- 40% layer clear: `Layer Breaker II` = 2.0x global mining damage
- 65% layer clear: `Layer Breaker III` = 2.5x global mining damage
- 88% layer clear: `Layer Breaker IV` = 3.0x global mining damage
- These persist forever, so every deeper layer has to be tuned around the player arriving with several prior layer-breaker stacks online.

## Upgrade Additions Used By The Sim
- Money early-mid: `Shock Bits`, `Breach Drones`, `Salvage Contract`, `Funnel Resonance`, `Daemon Lances`, `Root Breaker`
- Money late: `Overburn Reactors`, `Seismic Lattice`, `Mantle Drills`, `Fault Charges`, `Void Cutters`, `Inversion Drives`, `Vault Pulsers`, `Gravity Wells`, `Abyssal Rigs`
- Money NG+: `Mirror Saws`, `Fault Harpoons`, `Null Borers`, `Ash Crowns`
- XP late: `Crash Cartography`, `Kernel Rehearsal`, `Deep Manifest`, `Thermal Mapping`, `Vault Heuristics`, `Graveyard Index`, `Mirror Daemons`
- XP NG+: `Inversion Ledger`, `Fault Oracles`, `Null Archive`, `Ash Scriptures`
- Core late: `Pressure Vent`, `Core Siphon`, `Salvage Limiter`, `Mantle Permits`, `Inversion Tether`, `Voidfire Brakes`
- Core NG+: `Mirror Keys`, `Fault Insulation`, `Null Anchor`, `Ash Ward`

## Difficulty Spikes Added
- Ghost Sector, Kernel Vault, and Root Well all now have longer dwell windows so the player has to build power across each layer instead of skipping straight to the next core.
- The upside-down half is now a five-layer New Game Plus descent: `Mirror Shelf`, `Reverse Fault`, `Null Vein`, `Grave Mantle`, and `Crown of Ash`.
- Each upside-down layer has its own core, its own hardness spikes, and its own upgrade band so the late game keeps presenting fresh buying decisions.

## Demo Gate Recommendation
- Best gate point: Ghost Sector completion. The player gets a full top-side slice, sees a core clear, and then hits a clean hard gate before Kernel Vault.
- Demo implementation: make `Kernel Breach` a hidden core upgrade earned after Ghost Sector but unavailable in demo mode. Without it, Kernel Vault remains unmineable.
- Demo-visible tree cutoff: hide `Kernel Breach` and every stage-3+ upgrade: `Root Breaker`, `Overburn Reactors`, `Seismic Lattice`, `Mantle Drills`, `Fault Charges`, `Void Cutters`, `Inversion Drives`, `Vault Pulsers`, `Gravity Wells`, `Abyssal Rigs`, `Mirror Saws`, `Fault Harpoons`, `Null Borers`, `Ash Crowns`, `Kernel Rehearsal`, `Deep Manifest`, `Thermal Mapping`, `Vault Heuristics`, `Graveyard Index`, `Mirror Daemons`, `Inversion Ledger`, `Fault Oracles`, `Null Archive`, `Ash Scriptures`, `Core Siphon`, `Root Access`, `Salvage Limiter`, `Mantle Permits`, `Inversion Tether`, `Voidfire Brakes`, `Mirror Keys`, `Fault Insulation`, `Null Anchor`, and `Ash Ward`.

## Actual Blocks Per Run
- These are actual blocks cleared per run, not block HP or damage. The current best run averages `7373` blocks per sortie.
- Lowest-clear sortie: run `1` in `Proxy Cache` with `105` blocks.
- Highest-clear sortie: run `56` in `Crown of Ash` with `96057` blocks.
- `Proxy Cache`: `105` to `406` actual blocks per run, averaging `239`.
- `Cipher Depths`: `129` to `636` actual blocks per run, averaging `332`.
- `Ghost Sector`: `333` to `1272` actual blocks per run, averaging `716`.
- `Kernel Vault`: `630` to `1862` actual blocks per run, averaging `1152`.
- `Root Well`: `1058` to `2901` actual blocks per run, averaging `1789`.
- `Mirror Shelf`: `593` to `8441` actual blocks per run, averaging `3058`.
- `Reverse Fault`: `9438` to `15454` actual blocks per run, averaging `12350`.
- `Null Vein`: `18120` to `28902` actual blocks per run, averaging `22162`.
- `Grave Mantle`: `25231` to `59860` actual blocks per run, averaging `42546`.
- `Crown of Ash`: `57976` to `96057` actual blocks per run, averaging `77016`.

## Run Report
| Run | Window | Zone | Result | Barriers | Clear | Core | Rewards | Purchases | Wallets |
|---:|---|---|---|---|---|---|---|---|---|
| 1 | 0.0m-1.1m | Proxy Cache | Return | 1.09/1 | 0.0% -> 3.5% (105 blocks, no layer breaker) | 0 | $439, 70 xp, 0 cores | Laser Cutter 1, Laser Cutter 2 | $87 / 70 xp / 0 cores |
| 2 | 1.1m-2.1m | Proxy Cache | Return | 1.07/1 | 3.5% -> 8.6% (153 blocks, no layer breaker) | 0 | $526, 103 xp, 0 cores | Laser Cutter 3, Packet Sniffer 1, Cargo Racks 1 | $131 / 66 xp / 0 cores |
| 3 | 2.1m-3.2m | Proxy Cache | Return | 1.03/1 | 8.6% -> 14.6% (181 blocks, no layer breaker) | 0 | $617, 156 xp, 0 cores | Laser Cutter 4, Packet Sniffer 2, Cargo Racks 2 | $7 / 36 xp / 0 cores |
| 4 | 3.2m-4.3m | Proxy Cache | Return | 0.99/1 | 14.6% -> 21.7% (211 blocks, no layer breaker) | 0 | $711, 221 xp, 0 cores | Cargo Racks 3, Trace Scrubber 1, Fuel Cells 1 | $235 / 97 xp / 0 cores |
| 5 | 4.3m-5.5m | Proxy Cache | Return | 0.94/1 | 21.7% -> 35.2% (406 blocks, 1.5x layer breaker) | 0 | $1103, 426 xp, 0 cores | Laser Cutter 5, Packet Sniffer 3, Cargo Racks 4 | $16 / 197 xp / 0 cores |
| 6 | 5.5m-6.8m | Proxy Cache | Return | 0.85/1 | 35.2% -> 100.0% (378 blocks, 1.5x layer breaker) | 3735 and core cleared | $1092, 468 xp, 2 cores | Cargo Racks 5, Packet Sniffer 4, Signal Sniffer 1 | $310 / 94 xp / 1 cores |
| 7 | 6.8m-8.1m | Cipher Depths | Return | 1.14/1 | 0.0% -> 2.5% (129 blocks, no layer breaker) | 0 | $1099, 275 xp, 0 cores | Laser Cutter 6, Trace Scrubber 2, Ghost Entry 1 | $174 / 89 xp / 0 cores |
| 8 | 8.1m-9.5m | Cipher Depths | Return | 1.12/1 | 2.5% -> 5.7% (167 blocks, no layer breaker) | 0 | $1293, 357 xp, 0 cores | Cargo Racks 6, Heap Climber 1, Fuel Cells 2 | $40 / 260 xp / 0 cores |
| 9 | 9.5m-11.0m | Cipher Depths | Return | 1.10/1 | 5.7% -> 9.3% (186 blocks, no layer breaker) | 0 | $1478, 397 xp, 0 cores | Fuel Cells 3, Trace Scrubber 3, Fuel Cells 4 | $672 / 167 xp / 0 cores |
| 10 | 11.0m-12.8m | Cipher Depths | Return | 1.07/1 | 9.3% -> 13.8% (235 blocks, no layer breaker) | 0 | $1727, 503 xp, 0 cores | Laser Cutter 7, Heap Climber 2, Rapid Cycle 1 | $324 / 334 xp / 0 cores |
| 11 | 12.8m-14.6m | Cipher Depths | Return | 1.04/1 | 13.8% -> 19.6% (301 blocks, no layer breaker) | 0 | $2108, 643 xp, 0 cores | Cargo Racks 7, Trace Scrubber 4, Rapid Cycle 2 | $334 / 120 xp / 0 cores |
| 12 | 14.6m-16.6m | Cipher Depths | Return | 1.00/1 | 19.6% -> 26.6% (365 blocks, no layer breaker) | 0 | $2480, 781 xp, 0 cores | Fuel Cells 5, Heap Climber 3, Fuel Cells 6 | $782 / 297 xp / 0 cores |
| 13 | 16.6m-18.7m | Cipher Depths | Return | 0.95/1 | 26.6% -> 38.8% (636 blocks, 1.5x layer breaker) | 0 | $3900, 1359 xp, 0 cores | Laser Cutter 8, Heap Climber 4, Rapid Cycle 3 | $1314 / 568 xp / 0 cores |
| 14 | 18.7m-20.9m | Cipher Depths | Return | 0.86/1 | 38.8% -> 100.0% (636 blocks, 1.5x layer breaker) | 20110 and core cleared | $3953, 1359 xp, 2 cores | Rapid Cycle 4, Cache Warmers 1, Rapid Cycle 5 | $3629 / 1776 xp / 2 cores |
| 15 | 20.9m-23.1m | Ghost Sector | Return | 1.06/1 | 0.0% -> 4.1% (333 blocks, no layer breaker) | 0 | $5189, 1108 xp, 0 cores | Rapid Cycle 6, Cache Warmers 2, Rapid Cycle 7 | $4728 / 2620 xp / 2 cores |
| 16 | 23.1m-25.4m | Ghost Sector | Return | 0.88/1 | 4.1% -> 9.5% (445 blocks, no layer breaker) | 0 | $6682, 1480 xp, 0 cores | Ore Appraisal 1, Cache Warmers 3, Ore Appraisal 2 | $10932 / 3638 xp / 2 cores |
| 17 | 25.4m-27.8m | Ghost Sector | Return | 0.73/1 | 9.5% -> 15.7% (506 blocks, no layer breaker) | 0 | $9111, 1681 xp, 0 cores | Ore Appraisal 3, Cache Warmers 4, Ore Appraisal 4 | $18818 / 4510 xp / 2 cores |
| 18 | 27.8m-30.2m | Ghost Sector | Return | 0.62/1 | 15.7% -> 22.6% (572 blocks, no layer breaker) | 0 | $12035, 1900 xp, 0 cores | Ore Appraisal 5, Deep Scan 1, Ore Appraisal 6 | $27718 / 6170 xp / 2 cores |
| 19 | 30.2m-32.6m | Ghost Sector | Return | 0.59/1 | 22.6% -> 34.6% (983 blocks, 1.5x layer breaker) | 0 | $23316, 3268 xp, 0 cores | Barrier Mesh 1, Deep Scan 2, Barrier Mesh 2 | $50100 / 8994 xp / 2 cores |
| 20 | 32.6m-35.0m | Ghost Sector | Return | 0.43/3 | 34.6% -> 45.6% (900 blocks, 1.5x layer breaker) | 0 | $21418, 2993 xp, 0 cores | Barrier Mesh 3, Deep Scan 3, Shock Bits 1 | $69919 / 11166 xp / 2 cores |
| 21 | 35.0m-37.3m | Ghost Sector | Return | 0.31/4 | 45.6% -> 100.0% (1272 blocks, 2.0x layer breaker) | 87713 and core cleared | $29947, 4228 xp, 3 cores | Kernel Breach 1, Shock Bits 2, Deep Scan 4 | $99101 / 13876 xp / 1 cores |
| 22 | 37.3m-39.8m | Kernel Vault | Return | 0.56/4 | 0.0% -> 5.2% (630 blocks, no layer breaker) | 0 | $31027, 2542 xp, 0 cores | Shock Bits 3, Sidechannel 1, Shock Bits 4 | $126448 / 16107 xp / 1 cores |
| 23 | 39.8m-42.3m | Kernel Vault | Return | 0.54/4 | 5.2% -> 11.5% (747 blocks, no layer breaker) | 0 | $40270, 3016 xp, 0 cores | Breach Drones 1, Sidechannel 2, Breach Drones 2 | $165044 / 18532 xp / 1 cores |
| 24 | 42.3m-44.7m | Kernel Vault | Return | 0.52/4 | 11.5% -> 19.6% (976 blocks, no layer breaker) | 0 | $57043, 3938 xp, 0 cores | Breach Drones 3, Sidechannel 3, Breach Drones 4 | $216661 / 21348 xp / 1 cores |
| 25 | 44.7m-47.2m | Kernel Vault | Return | 0.49/4 | 19.6% -> 29.8% (1220 blocks, no layer breaker) | 0 | $77000, 4923 xp, 0 cores | Salvage Contract 1, Sidechannel 4, Salvage Contract 2 | $292270 / 24139 xp / 1 cores |
| 26 | 47.2m-49.6m | Kernel Vault | Return | 0.46/4 | 29.8% -> 45.3% (1862 blocks, 1.5x layer breaker) | 0 | $126138, 7517 xp, 0 cores | Salvage Contract 3, Zero-Day 1, Salvage Contract 4 | $414146 / 31123 xp / 1 cores |
| 27 | 49.6m-52.1m | Kernel Vault | Return | 0.36/4 | 45.3% -> 100.0% (1479 blocks, 2.0x layer breaker) | 209160 and core cleared | $100304, 7879 xp, 3 cores | Funnel Resonance 1, Zero-Day 2, Barrier Patch 1 | $513484 / 37936 xp / 1 cores |
| 28 | 52.1m-54.5m | Root Well | Return | 0.77/5 | 0.0% -> 5.4% (1079 blocks, no layer breaker) | 0 | $110863, 8821 xp, 0 cores | Funnel Resonance 2, Zero-Day 3, Funnel Resonance 3 | $619025 / 44626 xp / 1 cores |
| 29 | 54.5m-57.0m | Root Well | Return | 0.74/5 | 5.4% -> 12.1% (1337 blocks, no layer breaker) | 0 | $137240, 13068 xp, 0 cores | Funnel Resonance 4, Crash Cartography 1, Daemon Lances 1 | $748443 / 57028 xp / 1 cores |
| 30 | 57.0m-59.4m | Root Well | Return | 0.71/5 | 12.1% -> 19.5% (1492 blocks, no layer breaker) | 0 | $153088, 14585 xp, 0 cores | Daemon Lances 2, Crash Cartography 2, Daemon Lances 3 | $895225 / 70281 xp / 1 cores |
| 31 | 59.4m-61.9m | Root Well | Return | 0.68/5 | 19.5% -> 24.8% (1058 blocks, no layer breaker) | 0 | $108785, 10344 xp, 0 cores | Daemon Lances 4, Crash Cartography 3, Root Breaker 1 | $989224 / 77961 xp / 1 cores |
| 32 | 61.9m-64.3m | Root Well | Return | 0.65/5 | 24.8% -> 34.7% (1972 blocks, 1.5x layer breaker) | 0 | $202100, 19277 xp, 0 cores | Root Breaker 2, Kernel Rehearsal 1, Root Breaker 3 | $1148047 / 94681 xp / 1 cores |
| 33 | 64.3m-66.8m | Root Well | Return | 0.60/5 | 34.7% -> 48.1% (2684 blocks, 1.5x layer breaker) | 0 | $274722, 26229 xp, 0 cores | Overburn Reactors 1, Kernel Rehearsal 2, Overburn Reactors 2 | $1385012 / 115667 xp / 1 cores |
| 34 | 66.8m-69.2m | Root Well | Return | 0.48/5 | 48.1% -> 100.0% (2901 blocks, 2.0x layer breaker) | 3823310 and core cleared | $296898, 28352 xp, 4 cores | Overburn Reactors 3, Kernel Rehearsal 3, Backdoor Exit 1 | $1636569 / 133271 xp / 2 cores |
| 35 | 69.2m-71.7m | Mirror Shelf | Return | 1.05/5 | 0.0% -> 1.0% (593 blocks, no layer breaker) | 0 | $114127, 7454 xp, 0 cores | Overburn Reactors 4, Deep Manifest 1, Seismic Lattice 1 | $1647679 / 137031 xp / 2 cores |
| 36 | 71.7m-74.1m | Mirror Shelf | Return | 1.05/5 | 1.0% -> 2.4% (834 blocks, no layer breaker) | 0 | $172891, 10479 xp, 0 cores | Seismic Lattice 2, Deep Manifest 2, Seismic Lattice 3 | $1719675 / 140122 xp / 2 cores |
| 37 | 74.1m-76.6m | Mirror Shelf | Return | 1.04/5 | 2.4% -> 4.3% (1176 blocks, no layer breaker) | 0 | $261426, 14774 xp, 0 cores | Seismic Lattice 4, Deep Manifest 3, Mantle Drills 1 | $1793699 / 140120 xp / 2 cores |
| 38 | 76.6m-79.0m | Mirror Shelf | Return | 1.03/5 | 4.3% -> 7.0% (1585 blocks, no layer breaker) | 0 | $376396, 19916 xp, 0 cores | Mantle Drills 2, Deep Manifest 4, Mantle Drills 3 | $1798727 / 130483 xp / 2 cores |
| 39 | 79.0m-81.5m | Mirror Shelf | Return | 1.01/5 | 7.0% -> 10.4% (2071 blocks, no layer breaker) | 0 | $523314, 26026 xp, 0 cores | Mantle Drills 4, Thermal Mapping 1, Fault Charges 1 | $1772242 / 149121 xp / 2 cores |
| 40 | 81.5m-84.0m | Mirror Shelf | Return | 0.99/5 | 10.4% -> 14.6% (2515 blocks, no layer breaker) | 0 | $635230, 31599 xp, 0 cores | Fault Charges 2, Thermal Mapping 2, Fault Charges 3 | $1941750 / 165574 xp / 2 cores |
| 41 | 84.0m-86.4m | Mirror Shelf | Return | 0.96/5 | 14.6% -> 17.2% (1568 blocks, no layer breaker) | 0 | $396327, 19701 xp, 0 cores | Fault Charges 4, Thermal Mapping 3, Void Cutters 1 | $1601756 / 154226 xp / 2 cores |
| 42 | 86.4m-88.9m | Mirror Shelf | Return | 0.94/5 | 17.2% -> 20.6% (2026 blocks, no layer breaker) | 0 | $511846, 25455 xp, 0 cores | Void Cutters 2, Thermal Mapping 4, Void Cutters 3 | $1331188 / 116031 xp / 2 cores |
| 43 | 88.9m-91.3m | Mirror Shelf | Return | 0.92/5 | 20.6% -> 27.9% (4391 blocks, 1.5x layer breaker) | 0 | $1108591, 55174 xp, 0 cores | Void Cutters 4, Vault Heuristics 1, Inversion Drives 1 | $1243434 / 149950 xp / 2 cores |
| 44 | 91.3m-93.8m | Mirror Shelf | Return | 0.87/5 | 27.9% -> 38.2% (6152 blocks, 1.5x layer breaker) | 0 | $1552859, 77300 xp, 0 cores | Void Cutters 5, Vault Heuristics 2, Inversion Drives 2 | $472811 / 183677 xp / 2 cores |
| 45 | 93.8m-96.2m | Mirror Shelf | Return | 0.80/5 | 38.2% -> 47.1% (5340 blocks, 1.5x layer breaker) | 0 | $1347942, 67094 xp, 0 cores | Inversion Drives 3, Vault Heuristics 3, Vault Pulsers 1 | $559785 / 161446 xp / 2 cores |
| 46 | 96.2m-98.7m | Mirror Shelf | Return | 0.66/5 | 47.1% -> 100.0% (8441 blocks, 2.0x layer breaker) | 60920933 and core cleared | $2130396, 106063 xp, 2 cores | Inversion Drives 4, Vault Heuristics 4, Panic Tunnel 1 | $1401874 / 84393 xp / 1 cores |
| 47 | 98.7m-101.1m | Reverse Fault | Return | 1.15/5 | 0.0% -> 18.0% (13657 blocks, no layer breaker) | 0 | $4307883, 193852 xp, 0 cores | Vault Pulsers 2, Graveyard Index 1, Vault Pulsers 3 | $2356556 / 231359 xp / 1 cores |
| 48 | 101.1m-103.6m | Reverse Fault | Return | 1.02/5 | 18.0% -> 30.4% (9438 blocks, no layer breaker) | 0 | $3275067, 152726 xp, 0 cores | Vault Pulsers 4, Graveyard Index 2, Gravity Wells 1 | $467419 / 287968 xp / 1 cores |
| 49 | 103.6m-106.0m | Reverse Fault | Return | 0.93/5 | 30.4% -> 44.7% (10850 blocks, 1.5x layer breaker) | 0 | $4107133, 197138 xp, 0 cores | Gravity Wells 2, Graveyard Index 3, Abyssal Rigs 1 | $1614654 / 288066 xp / 1 cores |
| 50 | 106.0m-108.5m | Reverse Fault | Return | 0.73/5 | 44.7% -> 100.0% (15454 blocks, 2.0x layer breaker) | 180883721 and core cleared | $6336740, 311482 xp, 2 cores | Gravity Wells 3, Graveyard Index 4, Abyssal Rigs 2 | $2300386 / 195616 xp / 3 cores |
| 51 | 108.5m-110.9m | Null Vein | Return | 1.26/5 | 0.0% -> 30.4% (28902 blocks, no layer breaker) | 0 | $15777939, 713401 xp, 0 cores | Vault Pulsers 5, Mirror Daemons 1, Gravity Wells 4 | $3874829 / 840250 xp / 3 cores |
| 52 | 110.9m-113.4m | Null Vein | Return | 1.02/5 | 30.4% -> 49.5% (18120 blocks, 1.5x layer breaker) | 0 | $9892252, 447263 xp, 0 cores | Abyssal Rigs 3, Mirror Daemons 2, Mirror Saws 1 | $6745297 / 1143103 xp / 3 cores |
| 53 | 113.4m-115.8m | Null Vein | Return | 0.77/5 | 49.5% -> 100.0% (19466 blocks, 2.0x layer breaker) | 560083211 and core cleared | $10627486, 480504 xp, 3 cores | Abyssal Rigs 4, Mirror Daemons 3, Daemon Focus 1 | $7745949 / 1320346 xp / 2 cores |
| 54 | 115.8m-118.3m | Grave Mantle | Return | 1.37/5 | 0.0% -> 49.9% (59860 blocks, no layer breaker) | 0 | $40367038, 1651423 xp, 0 cores | Abyssal Rigs 5, Mirror Daemons 4, Mirror Saws 2 | $25734318 / 2334920 xp / 2 cores |
| 55 | 118.3m-120.7m | Grave Mantle | Return | 0.84/5 | 49.9% -> 100.0% (25231 blocks, 2.0x layer breaker) | 1447742454 and core cleared | $17015447, 696073 xp, 3 cores | Mirror Saws 3, Inversion Ledger 1, Pressure Vent 1 | $35193179 / 2915340 xp / 1 cores |
| 56 | 120.7m-123.2m | Crown of Ash | Return | 1.15/5 | 0.0% -> 60.0% (96057 blocks, no layer breaker) | 0 | $81740128, 3438027 xp, 0 cores | Mirror Saws 4, Inversion Ledger 2, Fault Harpoons 1 | $99294202 / 6110495 xp / 1 cores |
| 57 | 123.2m-125.6m | Crown of Ash | Return | 0.65/5 | 60.0% -> 100.0% (57976 blocks, 2.0x layer breaker) | 4879040534 and core cleared | $49335148, 2361250 xp, 4 cores | Fault Harpoons 2, Inversion Ledger 3, Fault Harpoons 3 | $131490765 / 7961715 xp / 5 cores |
