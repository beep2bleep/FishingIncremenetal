# Open Pit Empire Demo Layer Progression Simulation

This pass models the demo slice with the hidden `Kernel Breach` core upgrade removed from the store, so the player can fully clear Ghost Sector but cannot enter Kernel Vault.

## Best Scenario
- Scenario: `ultra_expensive_2`
- 30 minute demo progress: 41.2% through the top-side descent (20.6% of the full layer arc)
- Ghost Sector fully cleared: 51.1m
- Demo stop: `Kernel Vault` requires hidden core upgrade `Kernel Breach`
- Runs: 25
- Average purchases per run: 2.96
- Runs without a purchase: 0

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
- These are actual blocks cleared per run, not block HP or damage. The current best run averages `338` blocks per sortie.
- Lowest-clear sortie: run `7` in `Cipher Depths` with `115` blocks.
- Highest-clear sortie: run `24` in `Ghost Sector` with `738` blocks.
- `Proxy Cache`: `132` to `346` actual blocks per run, averaging `249`.
- `Cipher Depths`: `115` to `476` actual blocks per run, averaging `277`.
- `Ghost Sector`: `220` to `738` actual blocks per run, averaging `446`.

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
| 25 | 48.5m-51.1m | Ghost Sector | Return | 0.31/4 | 46.3% -> 100.0% (661 blocks, no clear breach reward) | 49960 and core cleared | $20483, 2199 xp, 3 cores | Salvage Contract 2, Sidechannel 4, Barrier Patch 1 | $94855 / 7625 xp / 2 cores |
