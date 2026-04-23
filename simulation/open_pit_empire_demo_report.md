# Open Pit Empire Demo Layer Progression Simulation

This pass models the demo slice with the hidden `Kernel Breach` core upgrade removed from the store, so the player can fully clear Ghost Sector but cannot enter Kernel Vault.

## Best Scenario
- Scenario: `ultra_expensive_2`
- 30 minute demo progress: 44.4% through the top-side descent (22.2% of the full layer arc)
- Ghost Sector fully cleared: 37.3m
- Demo stop: `Kernel Vault` requires hidden core upgrade `Kernel Breach`
- Runs: 21
- Average purchases per run: 2.95
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
- These are actual blocks cleared per run, not block HP or damage. The current best run averages `433` blocks per sortie.
- Lowest-clear sortie: run `1` in `Proxy Cache` with `105` blocks.
- Highest-clear sortie: run `21` in `Ghost Sector` with `1272` blocks.
- `Proxy Cache`: `105` to `406` actual blocks per run, averaging `239`.
- `Cipher Depths`: `129` to `636` actual blocks per run, averaging `332`.
- `Ghost Sector`: `333` to `1272` actual blocks per run, averaging `716`.

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
| 21 | 35.0m-37.3m | Ghost Sector | Return | 0.31/4 | 45.6% -> 100.0% (1272 blocks, 2.0x layer breaker) | 87713 and core cleared | $29947, 4228 xp, 3 cores | Shock Bits 2, Deep Scan 4, Barrier Patch 1 | $99101 / 13876 xp / 2 cores |
