# Open Pit Empire Layer Progression Simulation

This pass models a persistent-destruction layer run with money, XP, and core upgrades, plus global layer-clear powerups that ramp from 1.5x to 3.0x damage and carry forward into every deeper layer.

## Best Scenario
- Scenario: `ultra_expensive_2`
- 30 minute demo progress: 41.2% through the top-side descent (20.6% of the full layer arc)
- Root Well reached: 86.3m
- Crown of Ash cleared: 0.0m
- Runs: 62
- Average purchases per run: 2.40
- Runs without a purchase: 4

## Proposed Layer-Clear Powerups
- 25% global persistent clear: `Clear Breach I` = +50% total global mining damage
- 50% global persistent clear: `Clear Breach II` = another +50% total global mining damage
- 75% global persistent clear: `Clear Breach III` = another +50% total global mining damage
- This is one global set of three rewards, not a repeating set per layer. In the sim they stack multiplicatively to 1.5x, 2.25x, then 3.375x total damage.

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
- These are actual blocks cleared per run, not block HP or damage. The current best run averages `1443` blocks per sortie.
- Lowest-clear sortie: run `7` in `Cipher Depths` with `115` blocks.
- Highest-clear sortie: run `57` in `Reverse Fault` with `5414` blocks.
- `Proxy Cache`: `132` to `346` actual blocks per run, averaging `249`.
- `Cipher Depths`: `115` to `476` actual blocks per run, averaging `277`.
- `Ghost Sector`: `220` to `738` actual blocks per run, averaging `446`.
- `Kernel Vault`: `644` to `1159` actual blocks per run, averaging `900`.
- `Root Well`: `1370` to `4314` actual blocks per run, averaging `2447`.
- `Mirror Shelf`: `782` to `2656` actual blocks per run, averaging `1811`.
- `Reverse Fault`: `3158` to `5414` actual blocks per run, averaging `3880`.

## Run Report
| Run | Window | Zone | Result | Barriers | Clear | Core | Rewards | Purchases | Wallets |
|---:|---|---|---|---|---|---|---|---|---|
| 1 | 0.0m-1.1m | Proxy Cache | Return | 1.09/1 | 0.0% -> 4.4% (132 blocks, no clear breach reward) | 0 | $487, 88 xp, 0 cores | Laser Cutter 1, Laser Cutter 2 | $135 / 88 xp / 0 cores |
| 2 | 1.1m-2.3m | Proxy Cache | Return | 1.06/1 | 4.4% -> 11.1% (200 blocks, no clear breach reward) | 0 | $610, 134 xp, 0 cores | Laser Cutter 3, Packet Sniffer 1, Cargo Racks 1 | $263 / 115 xp / 0 cores |
| 3 | 2.3m-3.4m | Proxy Cache | Return | 1.02/1 | 11.1% -> 18.9% (234 blocks, no clear breach reward) | 0 | $712, 201 xp, 0 cores | Laser Cutter 4, Packet Sniffer 2, Cargo Racks 2 | $234 / 130 xp / 0 cores |
| 4 | 3.4m-4.5m | Proxy Cache | Return | 0.96/1 | 18.9% -> 27.8% (268 blocks, no clear breach reward) | 0 | $814, 281 xp, 0 cores | Laser Cutter 5, Packet Sniffer 3, Fuel Cells 1 | $113 / 85 xp / 0 cores |
| 5 | 4.5m-5.8m | Proxy Cache | Return | 0.90/1 | 27.8% -> 39.3% (346 blocks, no clear breach reward) | 0 | $953, 428 xp, 0 cores | Cargo Racks 3, Trace Scrubber 1, Cargo Racks 4 | $196 / 353 xp / 0 cores |
| 6 | 5.8m-7.2m | Proxy Cache | Return | 0.82/1 | 39.3% -> 100.0% (315 blocks, no clear breach reward) | 3210 and core cleared | $978, 390 xp, 2 cores | Cargo Racks 5, Packet Sniffer 4, Signal Sniffer 1 | $376 / 172 xp / 1 cores |
| 7 | 7.2m-8.6m | Cipher Depths | Return | 1.14/1 | 0.0% -> 2.2% (115 blocks, no clear breach reward) | 0 | $1029, 245 xp, 0 cores | Laser Cutter 6, Trace Scrubber 2, Ghost Entry 1 | $170 / 137 xp / 0 cores |
| 8 | 8.6m-10.1m | Cipher Depths | Return | 1.12/1 | 2.2% -> 5.1% (150 blocks, no clear breach reward) | 0 | $1205, 320 xp, 0 cores | Cargo Racks 6, Heap Climber 1, Rapid Cycle 1 | $1 / 271 xp / 0 cores |
| 9 | 10.1m-11.6m | Cipher Depths | Return | 1.10/1 | 5.1% -> 8.5% (175 blocks, no clear breach reward) | 0 | $1423, 374 xp, 0 cores | Fuel Cells 2, Trace Scrubber 3, Fuel Cells 3 | $878 / 155 xp / 0 cores |
| 10 | 11.6m-13.5m | Cipher Depths | Return | 1.08/1 | 8.5% -> 12.8% (226 blocks, no clear breach reward) | 0 | $1679, 483 xp, 0 cores | Laser Cutter 7, Heap Climber 2, Fuel Cells 4 | $129 / 302 xp / 0 cores |
| 11 | 13.5m-15.5m | Cipher Depths | Return | 1.05/1 | 12.8% -> 18.0% (269 blocks, no clear breach reward) | 0 | $1946, 575 xp, 0 cores | Cargo Racks 7, Trace Scrubber 4, Ore Appraisal 1 | $47 / 20 xp / 0 cores |
| 12 | 15.5m-17.6m | Cipher Depths | Return | 1.01/1 | 18.0% -> 23.4% (284 blocks, no clear breach reward) | 0 | $2243, 607 xp, 0 cores | Fuel Cells 5, Heap Climber 3, Fuel Cells 6 | $258 / 23 xp / 0 cores |
| 13 | 17.6m-20.0m | Cipher Depths | Return | 0.97/1 | 23.4% -> 29.7% (325 blocks, no clear breach reward) | 0 | $2526, 694 xp, 0 cores | Rapid Cycle 2, Cache Warmers 1, Rapid Cycle 3 | $2128 / 566 xp / 0 cores |
| 14 | 20.0m-22.4m | Cipher Depths | Return | 0.76/1 | 29.7% -> 38.8% (474 blocks, no clear breach reward) | 0 | $3372, 1014 xp, 0 cores | Laser Cutter 8, Heap Climber 4, Rapid Cycle 4 | $1899 / 492 xp / 0 cores |
| 15 | 22.4m-24.9m | Cipher Depths | Return | 0.71/1 | 38.8% -> 100.0% (476 blocks, no clear breach reward) | 14433 and core cleared | $3432, 1017 xp, 2 cores | Rapid Cycle 5, Cache Warmers 2, Rapid Cycle 6 | $2743 / 1245 xp / 2 cores |
| 16 | 24.9m-27.4m | Ghost Sector | Return | 0.90/1 | 0.0% -> 2.7% (220 blocks, no clear breach reward) | 0 | $4036, 733 xp, 0 cores | Rapid Cycle 7, Cache Warmers 3, Ore Appraisal 2 | $3980 / 1516 xp / 2 cores |
| 17 | 27.4m-30.0m | Ghost Sector | Return | 0.77/1 | 2.7% -> 5.9% (265 blocks, no clear breach reward) | 0 | $5134, 882 xp, 0 cores | Ore Appraisal 3, Cache Warmers 4, Ore Appraisal 4 | $7889 / 1589 xp / 2 cores |
| 18 | 30.0m-32.7m | Ghost Sector | Return | 0.66/1 | 5.9% -> 9.5% (293 blocks, no clear breach reward) | 0 | $6522, 973 xp, 0 cores | Ore Appraisal 5, Deep Scan 1, Ore Appraisal 6 | $11276 / 2322 xp / 2 cores |
| 19 | 32.7m-35.3m | Ghost Sector | Return | 0.65/1 | 9.5% -> 13.5% (325 blocks, no clear breach reward) | 0 | $8199, 1080 xp, 0 cores | Barrier Mesh 1, Deep Scan 2, Barrier Mesh 2 | $18541 / 2958 xp / 2 cores |
| 20 | 35.3m-37.9m | Ghost Sector | Return | 0.50/3 | 13.5% -> 17.8% (357 blocks, no clear breach reward) | 0 | $8938, 1187 xp, 0 cores | Barrier Mesh 3, Deep Scan 3, Shock Bits 1 | $25880 / 3324 xp / 2 cores |
| 21 | 37.9m-40.6m | Ghost Sector | Return | 0.44/4 | 17.8% -> 23.1% (436 blocks, no clear breach reward) | 0 | $10749, 1449 xp, 0 cores | Shock Bits 2, Deep Scan 4, Shock Bits 3 | $34526 / 3255 xp / 2 cores |
| 22 | 40.6m-43.2m | Ghost Sector | Return | 0.42/4 | 23.1% -> 30.1% (573 blocks, no clear breach reward) | 0 | $13899, 1905 xp, 0 cores | Shock Bits 4, Sidechannel 1, Breach Drones 1 | $45485 / 4849 xp / 2 cores |
| 23 | 43.2m-45.9m | Ghost Sector | Return | 0.40/4 | 30.1% -> 37.3% (592 blocks, no clear breach reward) | 0 | $15705, 1969 xp, 0 cores | Breach Drones 2, Sidechannel 2, Breach Drones 3 | $58176 / 6227 xp / 2 cores |
| 24 | 45.9m-48.5m | Ghost Sector | Return | 0.38/4 | 37.3% -> 46.3% (738 blocks, no clear breach reward) | 0 | $21075, 2453 xp, 0 cores | Breach Drones 4, Sidechannel 3, Salvage Contract 1 | $75257 / 7558 xp / 2 cores |
| 25 | 48.5m-51.1m | Ghost Sector | Return | 0.31/4 | 46.3% -> 100.0% (661 blocks, no clear breach reward) | 49960 and core cleared | $20483, 2199 xp, 3 cores | Kernel Breach 1, Salvage Contract 2, Sidechannel 4 | $94855 / 7625 xp / 1 cores |
| 26 | 51.1m-53.8m | Kernel Vault | Return | 0.56/4 | 0.0% -> 6.5% (783 blocks, Clear Breach I active) | 0 | $53460, 3160 xp, 0 cores | Salvage Contract 3, Zero-Day 1, Salvage Contract 4 | $144053 / 10252 xp / 1 cores |
| 27 | 53.8m-56.5m | Kernel Vault | Return | 0.54/4 | 6.5% -> 13.0% (783 blocks, Clear Breach I active) | 0 | $53460, 4172 xp, 0 cores | Funnel Resonance 1, Zero-Day 2, Funnel Resonance 2 | $194712 / 13358 xp / 1 cores |
| 28 | 56.5m-59.2m | Kernel Vault | Return | 0.52/4 | 13.0% -> 21.1% (971 blocks, Clear Breach I active) | 0 | $66112, 6427 xp, 0 cores | Funnel Resonance 3, Zero-Day 3, Funnel Resonance 4 | $250711 / 17654 xp / 1 cores |
| 29 | 59.2m-62.0m | Kernel Vault | Return | 0.49/4 | 21.1% -> 30.8% (1159 blocks, Clear Breach I active) | 0 | $78765, 9168 xp, 0 cores | Daemon Lances 1, Crash Cartography 1, Daemon Lances 2 | $326067 / 26156 xp / 1 cores |
| 30 | 62.0m-64.7m | Kernel Vault | Return | 0.45/4 | 30.8% -> 40.5% (1159 blocks, Clear Breach I active) | 0 | $78765, 9168 xp, 0 cores | Daemon Lances 3, Crash Cartography 2, Daemon Lances 4 | $393166 / 33992 xp / 1 cores |
| 31 | 64.7m-67.4m | Kernel Vault | Return | 0.37/4 | 40.5% -> 47.1% (799 blocks, Clear Breach I active) | 0 | $54550, 6323 xp, 0 cores | Root Breaker 1, Crash Cartography 3, Root Breaker 2 | $426077 / 37651 xp / 1 cores |
| 32 | 67.4m-70.1m | Kernel Vault | Return | 0.35/4 | 47.1% -> 100.0% (644 blocks, Clear Breach I active) | 252337 and core cleared | $44087, 5093 xp, 3 cores | Root Breaker 3, Kernel Rehearsal 1, Barrier Patch 1 | $441313 / 40187 xp / 1 cores |
| 33 | 70.1m-72.8m | Root Well | Return | 0.77/5 | 0.0% -> 6.9% (1370 blocks, Clear Breach II active) | 0 | $140627, 13392 xp, 0 cores | Overburn Reactors 1, Kernel Rehearsal 2, Overburn Reactors 2 | $544183 / 48336 xp / 1 cores |
| 34 | 72.8m-75.5m | Root Well | Return | 0.74/5 | 6.9% -> 15.6% (1754 blocks, Clear Breach II active) | 0 | $179796, 17142 xp, 0 cores | Overburn Reactors 3, Kernel Rehearsal 3, Overburn Reactors 4 | $594757 / 54730 xp / 1 cores |
| 35 | 75.5m-78.2m | Root Well | Return | 0.69/5 | 15.6% -> 26.3% (2138 blocks, Clear Breach II active) | 0 | $218964, 20891 xp, 0 cores | Seismic Lattice 1, Deep Manifest 1, Seismic Lattice 2 | $759183 / 71927 xp / 1 cores |
| 36 | 78.2m-80.9m | Root Well | Return | 0.64/5 | 26.3% -> 37.1% (2165 blocks, Clear Breach II active) | 0 | $239477, 21162 xp, 0 cores | Seismic Lattice 3, Deep Manifest 2, Seismic Lattice 4 | $812005 / 85701 xp / 1 cores |
| 37 | 80.9m-83.6m | Root Well | Return | 0.59/5 | 37.1% -> 51.8% (2941 blocks, Clear Breach II active) | 0 | $349060, 28747 xp, 0 cores | Mantle Drills 1, Deep Manifest 3, Mantle Drills 2 | $967644 / 99672 xp / 1 cores |
| 38 | 83.6m-86.3m | Root Well | Return | 0.46/5 | 51.8% -> 100.0% (4314 blocks, Clear Breach III active) | 10525608 and core cleared | $546894, 42166 xp, 4 cores | Mantle Drills 3, Deep Manifest 4, Backdoor Exit 1 | $1270351 / 112285 xp / 2 cores |
| 39 | 86.3m-89.0m | Mirror Shelf | Return | 1.05/5 | 0.0% -> 1.3% (782 blocks, Clear Breach III active) | 0 | $198079, 9828 xp, 0 cores | Mantle Drills 4, Thermal Mapping 1, Fault Charges 1 | $918631 / 114725 xp / 2 cores |
| 40 | 89.0m-91.7m | Mirror Shelf | Return | 1.05/5 | 1.3% -> 2.9% (945 blocks, Clear Breach III active) | 0 | $239215, 11877 xp, 0 cores | Fault Charges 2, Thermal Mapping 2, Fault Charges 3 | $692124 / 111456 xp / 2 cores |
| 41 | 91.7m-94.4m | Mirror Shelf | Return | 1.04/5 | 2.9% -> 4.6% (1031 blocks, Clear Breach III active) | 0 | $260894, 12956 xp, 0 cores | Fault Charges 4, Thermal Mapping 3, Void Cutters 1 | $216697 / 93363 xp / 2 cores |
| 42 | 94.4m-97.1m | Mirror Shelf | Return | 1.02/5 | 4.6% -> 6.8% (1318 blocks, Clear Breach III active) | 0 | $333304, 16563 xp, 0 cores | Void Cutters 2, Thermal Mapping 4, Inversion Drives 1 | $96949 / 46276 xp / 2 cores |
| 43 | 97.1m-99.9m | Mirror Shelf | Return | 1.01/5 | 6.8% -> 9.8% (1832 blocks, Clear Breach III active) | 0 | $463051, 23024 xp, 0 cores | Void Cutters 3, Vault Heuristics 1, Vault Heuristics 2 | $42811 / 4472 xp / 2 cores |
| 44 | 99.9m-102.6m | Mirror Shelf | Return | 0.99/5 | 9.8% -> 14.3% (2656 blocks, Clear Breach III active) | 0 | $670818, 33372 xp, 0 cores | Inversion Drives 2 | $356757 / 37844 xp / 2 cores |
| 45 | 102.6m-105.3m | Mirror Shelf | Return | 0.96/5 | 14.3% -> 17.0% (1652 blocks, Clear Breach III active) | 0 | $417523, 20757 xp, 0 cores | Inversion Drives 3, Graveyard Index 1 | $96224 / 11715 xp / 2 cores |
| 46 | 105.3m-108.0m | Mirror Shelf | Return | 0.94/5 | 17.0% -> 20.0% (1812 blocks, Clear Breach III active) | 0 | $503568, 25953 xp, 0 cores | Vault Pulsers 1 | $16880 / 37668 xp / 2 cores |
| 47 | 108.0m-110.7m | Mirror Shelf | Return | 0.92/5 | 20.0% -> 23.4% (2029 blocks, Clear Breach III active) | 0 | $563907, 29067 xp, 0 cores | None | $580787 / 66735 xp / 2 cores |
| 48 | 110.7m-113.4m | Mirror Shelf | Return | 0.90/5 | 23.4% -> 26.8% (2029 blocks, Clear Breach III active) | 0 | $563907, 29067 xp, 0 cores | Void Cutters 4, Vault Heuristics 3 | $136176 / 6477 xp / 2 cores |
| 49 | 113.4m-116.1m | Mirror Shelf | Return | 0.88/5 | 26.8% -> 31.0% (2514 blocks, Clear Breach III active) | 0 | $698528, 36015 xp, 0 cores | None | $834704 / 42492 xp / 2 cores |
| 50 | 116.1m-118.8m | Mirror Shelf | Return | 0.85/5 | 31.0% -> 35.2% (2514 blocks, Clear Breach III active) | 0 | $698528, 36015 xp, 0 cores | Inversion Drives 4, Mirror Daemons 1 | $244925 / 9740 xp / 2 cores |
| 51 | 118.8m-121.5m | Mirror Shelf | Return | 0.82/5 | 35.2% -> 38.5% (1964 blocks, Clear Breach III active) | 0 | $545920, 28139 xp, 0 cores | None | $790845 / 37879 xp / 2 cores |
| 52 | 121.5m-124.2m | Mirror Shelf | Return | 0.80/5 | 38.5% -> 41.7% (1964 blocks, Clear Breach III active) | 0 | $545920, 28139 xp, 0 cores | Vault Pulsers 2 | $200087 / 66018 xp / 2 cores |
| 53 | 124.2m-126.9m | Mirror Shelf | Return | 0.69/5 | 41.7% -> 45.4% (2175 blocks, Clear Breach III active) | 0 | $604332, 31154 xp, 0 cores | Graveyard Index 2 | $804419 / 1055 xp / 2 cores |
| 54 | 126.9m-129.6m | Mirror Shelf | Return | 0.67/5 | 45.4% -> 100.0% (1752 blocks, Clear Breach III active) | 26735249 and core cleared | $531169, 28178 xp, 2 cores | Gravity Wells 1, Panic Tunnel 1 | $493604 / 29233 xp / 1 cores |
| 55 | 129.6m-132.3m | Reverse Fault | Return | 1.15/5 | 0.0% -> 5.4% (4089 blocks, Clear Breach III active) | 0 | $1548349, 74297 xp, 0 cores | Void Cutters 5 | $75343 / 103530 xp / 1 cores |
| 56 | 132.3m-135.0m | Reverse Fault | Return | 1.11/5 | 5.4% -> 11.3% (4517 blocks, Clear Breach III active) | 0 | $1710308, 82072 xp, 0 cores | Gravity Wells 2, Vault Heuristics 4 | $185881 / 2486 xp / 1 cores |
| 57 | 135.0m-137.8m | Reverse Fault | Return | 1.07/5 | 11.3% -> 18.4% (5414 blocks, Clear Breach III active) | 0 | $2049595, 98360 xp, 0 cores | Vault Pulsers 3 | $18953 / 100846 xp / 1 cores |
| 58 | 137.8m-140.5m | Reverse Fault | Return | 1.02/5 | 18.4% -> 22.6% (3158 blocks, Clear Breach III active) | 0 | $1196023, 57382 xp, 0 cores | Mirror Daemons 2 | $1214976 / 13818 xp / 1 cores |
| 59 | 140.5m-143.2m | Reverse Fault | Return | 0.99/5 | 22.6% -> 27.2% (3497 blocks, Clear Breach III active) | 0 | $1324089, 63531 xp, 0 cores | Abyssal Rigs 1 | $1178937 / 77349 xp / 1 cores |
| 60 | 143.2m-145.9m | Reverse Fault | Return | 0.96/5 | 27.2% -> 32.4% (3986 blocks, Clear Breach III active) | 0 | $1509461, 72425 xp, 0 cores | Abyssal Rigs 2, Inversion Ledger 1 | $76952 / 34121 xp / 1 cores |
| 61 | 145.9m-148.6m | Reverse Fault | Return | 0.92/5 | 32.4% -> 36.6% (3189 blocks, Clear Breach III active) | 0 | $1207842, 67210 xp, 0 cores | None | $1284794 / 101331 xp / 1 cores |
| 62 | 148.6m-151.3m | Reverse Fault | Return | 0.89/5 | 36.6% -> 40.8% (3189 blocks, Clear Breach III active) | 0 | $1207842, 67210 xp, 0 cores | Mirror Saws 1 | $484828 / 168541 xp / 1 cores |
