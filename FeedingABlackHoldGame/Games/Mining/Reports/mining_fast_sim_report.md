# Mining Fast Simulation Report

Source: Python fast run simulator with live Godot validation spot-checks.
Date (UTC): 2026-03-24 23:45:27

## Campaign

- Total runs: 424
- Total purchases: 424
- Upgrades per run: 1.000
- Full campaign time: 6324.9 sec
- Demo slice time (100 purchases): 1509.3 sec

## Validation Averages

- Seeds per checkpoint: 3
- Mean money error: 19.7%
- Mean XP error: 20.5%
- Mean time error: 9.2%
- Mean nodes error: 28.4%
- 10% gate passed: no

| Checkpoint | Depth | Samples | Fast Money Avg | Live Money Avg | Money Error % | Fast XP Avg | Live XP Avg | XP Error % | Fast Time Avg | Live Time Avg | Time Error % |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| purchase_1 | 1 | 3 | 32.7 | 32.7 | 0.0 | 32.0 | 28.0 | 14.3 | 17.4 | 16.0 | 8.6 |
| purchase_10 | 3 | 3 | 53.3 | 44.3 | 20.3 | 46.3 | 36.3 | 27.5 | 16.6 | 15.2 | 9.0 |
| purchase_100 | 12 | 3 | 1033.7 | 1390.7 | 25.7 | 160.7 | 225.0 | 28.6 | 12.2 | 11.7 | 4.4 |
| purchase_150 | 11 | 3 | 2188.0 | 2742.3 | 20.2 | 415.7 | 448.3 | 7.3 | 16.3 | 17.6 | 7.1 |
| purchase_220 | 13 | 3 | 4658.3 | 5241.0 | 11.1 | 626.3 | 676.3 | 7.4 | 11.7 | 13.4 | 13.1 |
| purchase_25 | 4 | 3 | 128.0 | 86.7 | 47.7 | 99.0 | 63.0 | 57.1 | 16.9 | 15.2 | 11.1 |
| purchase_300 | 13 | 3 | 10117.7 | 11690.7 | 13.5 | 1192.7 | 1449.3 | 17.7 | 14.9 | 18.1 | 17.5 |
| purchase_50 | 8 | 3 | 366.3 | 308.0 | 18.9 | 169.0 | 162.0 | 4.3 | 15.1 | 14.6 | 3.0 |

## Validation Samples

| Scenario | Checkpoint | Depth | Fast Money | Live Money | Money Error % | Fast XP | Live XP | XP Error % | Fast Time | Live Time | Time Error % |
|---|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| purchase_1_seed_1 | purchase_1 | 1 | 35.0 | 35.0 | 0.0 | 36.0 | 30.0 | 20.0 | 17.5 | 16.0 | 8.9 |
| purchase_1_seed_2 | purchase_1 | 1 | 35.0 | 35.0 | 0.0 | 36.0 | 30.0 | 20.0 | 17.6 | 16.0 | 10.0 |
| purchase_1_seed_3 | purchase_1 | 1 | 28.0 | 28.0 | 0.0 | 24.0 | 24.0 | 0.0 | 17.2 | 16.0 | 7.0 |
| purchase_10_seed_1 | purchase_10 | 3 | 54.0 | 48.0 | 12.5 | 45.0 | 39.0 | 15.4 | 17.4 | 15.2 | 14.2 |
| purchase_10_seed_2 | purchase_10 | 3 | 53.0 | 46.0 | 15.2 | 50.0 | 38.0 | 31.6 | 15.3 | 15.2 | 0.6 |
| purchase_10_seed_3 | purchase_10 | 3 | 53.0 | 39.0 | 35.9 | 44.0 | 32.0 | 37.5 | 17.0 | 15.2 | 12.0 |
| purchase_25_seed_1 | purchase_25 | 4 | 122.0 | 104.0 | 17.3 | 95.0 | 73.0 | 30.1 | 16.7 | 15.2 | 9.6 |
| purchase_25_seed_2 | purchase_25 | 4 | 132.0 | 86.0 | 53.5 | 93.0 | 60.0 | 55.0 | 17.4 | 15.2 | 14.4 |
| purchase_25_seed_3 | purchase_25 | 4 | 130.0 | 70.0 | 85.7 | 109.0 | 56.0 | 94.6 | 16.6 | 15.2 | 9.4 |
| purchase_50_seed_1 | purchase_50 | 8 | 469.0 | 424.0 | 10.6 | 158.0 | 142.0 | 11.3 | 15.7 | 14.6 | 7.1 |
| purchase_50_seed_2 | purchase_50 | 8 | 234.0 | 270.0 | 13.3 | 175.0 | 168.0 | 4.2 | 16.2 | 14.6 | 10.5 |
| purchase_50_seed_3 | purchase_50 | 8 | 396.0 | 230.0 | 72.2 | 174.0 | 176.0 | 1.1 | 13.4 | 14.6 | 8.6 |
| purchase_100_seed_1 | purchase_100 | 12 | 1479.0 | 1190.0 | 24.3 | 186.0 | 190.0 | 2.1 | 12.0 | 10.3 | 16.2 |
| purchase_100_seed_2 | purchase_100 | 12 | 509.0 | 1556.0 | 67.3 | 148.0 | 228.0 | 35.1 | 14.6 | 11.0 | 33.4 |
| purchase_100_seed_3 | purchase_100 | 12 | 1113.0 | 1426.0 | 21.9 | 148.0 | 257.0 | 42.4 | 9.9 | 13.7 | 27.6 |
| purchase_150_seed_1 | purchase_150 | 11 | 1866.0 | 2723.0 | 31.5 | 345.0 | 533.0 | 35.3 | 15.6 | 18.3 | 14.6 |
| purchase_150_seed_2 | purchase_150 | 11 | 1682.0 | 2652.0 | 36.6 | 424.0 | 392.0 | 8.2 | 18.5 | 18.3 | 1.5 |
| purchase_150_seed_3 | purchase_150 | 11 | 3016.0 | 2852.0 | 5.8 | 478.0 | 420.0 | 13.8 | 14.8 | 16.1 | 8.4 |
| purchase_220_seed_1 | purchase_220 | 13 | 4590.0 | 5874.0 | 21.9 | 561.0 | 814.0 | 31.1 | 10.3 | 17.4 | 40.6 |
| purchase_220_seed_2 | purchase_220 | 13 | 5297.0 | 4620.0 | 14.7 | 676.0 | 581.0 | 16.4 | 11.2 | 12.2 | 8.1 |
| purchase_220_seed_3 | purchase_220 | 13 | 4088.0 | 5229.0 | 21.8 | 642.0 | 634.0 | 1.3 | 13.5 | 10.8 | 25.7 |
| purchase_300_seed_1 | purchase_300 | 13 | 10572.0 | 9939.0 | 6.4 | 1222.0 | 1358.0 | 10.0 | 15.1 | 17.8 | 15.3 |
| purchase_300_seed_2 | purchase_300 | 13 | 10100.0 | 12795.0 | 21.1 | 1294.0 | 1472.0 | 12.1 | 17.1 | 15.8 | 8.2 |
| purchase_300_seed_3 | purchase_300 | 13 | 9681.0 | 12338.0 | 21.5 | 1062.0 | 1518.0 | 30.0 | 12.6 | 20.6 | 39.0 |

## Purchase Order

| # | Run | Upgrade | Level | Cost | Cumulative Time (s) |
|---:|---:|---|---:|---:|---:|
| 1 | 1 | Cargo Pods | 1 | 21 | 16.6 |
| 2 | 2 | Cargo Pods | 2 | 24 | 34.6 |
| 3 | 3 | Drill Torque | 1 | 20 | 52.5 |
| 4 | 4 | Cargo Pods | 3 | 27 | 71.1 |
| 5 | 5 | Engine Tuning | 1 | 19 | 87.9 |
| 6 | 6 | Cargo Pods | 4 | 31 | 105.3 |
| 7 | 7 | Vacuum Scoop | 1 | 23 | 122.8 |
| 8 | 8 | Timer Reserve | 1 | 18 | 138.4 |
| 9 | 9 | Cargo Pods | 5 | 36 | 156.0 |
| 10 | 10 | Drill Torque | 2 | 23 | 171.8 |
| 11 | 11 | Drill Torque | 3 | 26 | 187.3 |
| 12 | 12 | Engine Tuning | 2 | 22 | 203.3 |
| 13 | 13 | Engine Tuning | 3 | 25 | 218.7 |
| 14 | 14 | Drill Torque | 4 | 30 | 234.6 |
| 15 | 15 | Engine Tuning | 4 | 28 | 249.1 |
| 16 | 16 | Ore Refinery | 1 | 24 | 264.0 |
| 17 | 17 | Engine Tuning | 5 | 32 | 280.0 |
| 18 | 18 | Ore Refinery | 2 | 28 | 296.2 |
| 19 | 19 | Dirt Softener | 1 | 27 | 312.4 |
| 20 | 20 | Drill Torque | 5 | 34 | 326.4 |
| 21 | 21 | Ore Refinery | 3 | 32 | 340.5 |
| 22 | 22 | Timer Reserve | 2 | 21 | 355.3 |
| 23 | 23 | Drill Plating | 1 | 22 | 371.2 |
| 24 | 24 | Engine Tuning | 6 | 37 | 386.3 |
| 25 | 25 | Drill Torque | 6 | 39 | 402.4 |
| 26 | 26 | Drill Torque | 7 | 44 | 419.6 |
| 27 | 27 | Drill Torque | 8 | 51 | 435.7 |
| 28 | 28 | Ore Refinery | 4 | 36 | 450.6 |
| 29 | 29 | Drill Torque | 9 | 58 | 466.1 |
| 30 | 30 | Dirt Softener | 2 | 31 | 481.9 |
| 31 | 31 | Dirt Softener | 3 | 36 | 497.2 |
| 32 | 32 | Engine Tuning | 7 | 42 | 512.3 |
| 33 | 33 | Timer Reserve | 3 | 23 | 527.1 |
| 34 | 34 | Vacuum Scoop | 2 | 26 | 542.2 |
| 35 | 35 | Dirt Softener | 4 | 41 | 557.0 |
| 36 | 36 | XP Calibration | 1 | 27 | 572.7 |
| 37 | 37 | Drill Plating | 2 | 25 | 587.4 |
| 38 | 38 | Drill Torque | 10 | 66 | 601.4 |
| 39 | 39 | Timer Reserve | 4 | 27 | 616.1 |
| 40 | 40 | Drill Torque | 11 | 75 | 631.3 |
| 41 | 41 | Engine Tuning | 8 | 48 | 644.0 |
| 42 | 42 | Drill Plating | 3 | 29 | 659.2 |
| 43 | 43 | Ore Refinery | 5 | 42 | 673.9 |
| 44 | 44 | Dirt Softener | 5 | 48 | 690.2 |
| 45 | 45 | Vacuum Scoop | 3 | 30 | 704.4 |
| 46 | 46 | XP Calibration | 2 | 31 | 719.1 |
| 47 | 47 | Timer Reserve | 5 | 30 | 731.7 |
| 48 | 48 | Drill Torque | 12 | 86 | 746.7 |
| 49 | 49 | XP Calibration | 3 | 36 | 762.1 |
| 50 | 50 | Engine Tuning | 9 | 54 | 777.3 |
| 51 | 51 | Drill Torque | 13 | 98 | 793.8 |
| 52 | 52 | Ore Refinery | 6 | 48 | 810.8 |
| 53 | 53 | Ore Refinery | 7 | 55 | 826.3 |
| 54 | 54 | Dirt Softener | 6 | 55 | 841.2 |
| 55 | 55 | Ore Refinery | 8 | 63 | 857.6 |
| 56 | 56 | Drill Torque | 14 | 112 | 874.3 |
| 57 | 57 | Engine Tuning | 10 | 62 | 890.0 |
| 58 | 58 | Engine Tuning | 11 | 70 | 904.2 |
| 59 | 59 | Drill Torque | 15 | 128 | 919.8 |
| 60 | 60 | Drill Plating | 4 | 33 | 932.8 |
| 61 | 61 | Route Planner | 1 | 22 | 949.3 |
| 62 | 62 | XP Calibration | 4 | 41 | 961.7 |
| 63 | 63 | Cargo Pods | 6 | 41 | 974.9 |
| 64 | 64 | Timer Reserve | 6 | 35 | 988.9 |
| 65 | 65 | Route Planner | 2 | 25 | 999.2 |
| 66 | 66 | Drill Plating | 5 | 38 | 1012.9 |
| 67 | 67 | Ore Refinery | 9 | 72 | 1029.9 |
| 68 | 68 | Dirt Softener | 7 | 63 | 1046.0 |
| 69 | 69 | Cooling Loop | 1 | 25 | 1063.4 |
| 70 | 70 | Cargo Compressor | 1 | 29 | 1079.9 |
| 71 | 71 | Drill Plating | 6 | 43 | 1094.6 |
| 72 | 72 | Route Planner | 3 | 29 | 1109.9 |
| 73 | 73 | Route Planner | 4 | 33 | 1126.6 |
| 74 | 74 | Drill Torque | 16 | 147 | 1143.6 |
| 75 | 75 | Engine Tuning | 12 | 80 | 1159.0 |
| 76 | 76 | Dirt Softener | 8 | 73 | 1175.7 |
| 77 | 77 | Dirt Softener | 9 | 84 | 1193.3 |
| 78 | 78 | Cargo Compressor | 2 | 34 | 1207.5 |
| 79 | 79 | Ore Refinery | 10 | 83 | 1222.6 |
| 80 | 80 | Cooling Loop | 2 | 29 | 1238.6 |
| 81 | 81 | Timer Reserve | 7 | 40 | 1250.7 |
| 82 | 82 | Cargo Pods | 7 | 47 | 1269.2 |
| 83 | 83 | Vacuum Scoop | 4 | 35 | 1282.9 |
| 84 | 84 | Ore Refinery | 11 | 95 | 1301.3 |
| 85 | 85 | Salvage Drone | 1 | 39 | 1314.0 |
| 86 | 86 | Drill Torque | 17 | 167 | 1331.5 |
| 87 | 87 | Drill Torque | 18 | 191 | 1348.2 |
| 88 | 88 | Drill Plating | 7 | 50 | 1366.4 |
| 89 | 89 | Cargo Compressor | 3 | 39 | 1383.4 |
| 90 | 90 | Cargo Compressor | 4 | 45 | 1393.1 |
| 91 | 91 | Cargo Compressor | 5 | 52 | 1402.3 |
| 92 | 92 | Drill Plating | 8 | 57 | 1414.7 |
| 93 | 93 | Dirt Softener | 10 | 96 | 1430.9 |
| 94 | 94 | Dirt Softener | 11 | 111 | 1446.4 |
| 95 | 95 | Cooling Loop | 3 | 33 | 1456.4 |
| 96 | 96 | Cargo Pods | 8 | 54 | 1470.1 |
| 97 | 97 | Cargo Pods | 9 | 61 | 1478.2 |
| 98 | 98 | Ore Refinery | 12 | 110 | 1487.0 |
| 99 | 99 | Dirt Softener | 12 | 128 | 1498.8 |
| 100 | 100 | Timer Reserve | 8 | 45 | 1509.3 |
| 101 | 101 | Drill Torque | 19 | 218 | 1521.5 |
| 102 | 102 | Ore Refinery | 13 | 126 | 1532.5 |
| 103 | 103 | Cargo Pods | 10 | 70 | 1546.3 |
| 104 | 104 | Ore Refinery | 14 | 144 | 1555.0 |
| 105 | 105 | Route Planner | 5 | 38 | 1566.8 |
| 106 | 106 | Route Planner | 6 | 43 | 1578.7 |
| 107 | 107 | Drill Plating | 9 | 65 | 1591.1 |
| 108 | 108 | Salvage Drone | 2 | 46 | 1602.5 |
| 109 | 109 | Drill Torque | 20 | 249 | 1613.7 |
| 110 | 110 | Depth Scanner | 1 | 34 | 1625.5 |
| 111 | 111 | Timer Reserve | 9 | 51 | 1636.7 |
| 112 | 112 | Drill Plating | 10 | 75 | 1651.2 |
| 113 | 113 | Timer Reserve | 10 | 59 | 1660.2 |
| 114 | 114 | Cargo Compressor | 6 | 60 | 1671.4 |
| 115 | 115 | Drill Torque | 21 | 285 | 1684.5 |
| 116 | 116 | Cooling Loop | 4 | 38 | 1698.5 |
| 117 | 117 | Salvage Drone | 3 | 53 | 1710.3 |
| 118 | 118 | XP Calibration | 5 | 48 | 1723.7 |
| 119 | 119 | Delivery Drone | 1 | 46 | 1739.8 |
| 120 | 120 | Depth Scanner | 2 | 40 | 1749.8 |
| 121 | 121 | Depth Scanner | 3 | 46 | 1762.8 |
| 122 | 122 | Delivery Drone | 2 | 54 | 1780.4 |
| 123 | 123 | Drill Torque | 22 | 325 | 1790.3 |
| 124 | 124 | Drill Plating | 11 | 86 | 1802.0 |
| 125 | 125 | Depth Scanner | 4 | 53 | 1814.6 |
| 126 | 126 | Ore Refinery | 15 | 166 | 1825.8 |
| 127 | 127 | Route Planner | 7 | 50 | 1836.6 |
| 128 | 128 | Cargo Compressor | 7 | 69 | 1849.2 |
| 129 | 129 | Drill Torque | 23 | 371 | 1862.5 |
| 130 | 130 | Delivery Drone | 3 | 64 | 1877.9 |
| 131 | 131 | Drill Torque | 24 | 424 | 1894.5 |
| 132 | 132 | Timer Reserve | 11 | 67 | 1907.3 |
| 133 | 133 | XP Calibration | 6 | 55 | 1919.2 |
| 134 | 134 | Dirt Softener | 13 | 148 | 1934.0 |
| 135 | 135 | Engine Tuning | 13 | 92 | 1943.6 |
| 136 | 136 | Route Planner | 8 | 57 | 1957.0 |
| 137 | 137 | Salvage Drone | 4 | 62 | 1969.1 |
| 138 | 138 | Drill Torque | 25 | 484 | 1978.4 |
| 139 | 139 | Cooling Loop | 5 | 44 | 1988.0 |
| 140 | 140 | Foreman Bot | 1 | 41 | 1999.4 |
| 141 | 141 | Ore Refinery | 16 | 190 | 2007.8 |
| 142 | 142 | Drill Torque | 26 | 553 | 2019.0 |
| 143 | 143 | Route Planner | 9 | 65 | 2029.2 |
| 144 | 144 | Cooling Loop | 6 | 50 | 2042.0 |
| 145 | 145 | Ore Refinery | 17 | 218 | 2054.7 |
| 146 | 146 | XP Calibration | 7 | 63 | 2066.6 |
| 147 | 147 | Seismic Sonar | 1 | 37 | 2079.0 |
| 148 | 148 | Drill Torque | 27 | 631 | 2089.5 |
| 149 | 149 | Route Planner | 10 | 74 | 2104.3 |
| 150 | 150 | Route Planner | 11 | 85 | 2120.8 |
| 151 | 151 | Engine Tuning | 14 | 104 | 2134.2 |
| 152 | 152 | Dirt Softener | 14 | 170 | 2145.3 |
| 153 | 153 | Cargo Pods | 11 | 80 | 2158.8 |
| 154 | 154 | Cargo Compressor | 8 | 80 | 2167.9 |
| 155 | 155 | Cargo Compressor | 9 | 92 | 2180.9 |
| 156 | 156 | Delivery Drone | 4 | 75 | 2192.3 |
| 157 | 157 | Foreman Bot | 2 | 48 | 2201.2 |
| 158 | 158 | Auto Sorters | 1 | 45 | 2212.5 |
| 159 | 159 | XP Calibration | 8 | 73 | 2227.8 |
| 160 | 160 | Drill Plating | 12 | 99 | 2237.8 |
| 161 | 161 | Foreman Bot | 3 | 56 | 2256.3 |
| 162 | 162 | Ore Refinery | 18 | 251 | 2274.4 |
| 163 | 163 | XP Calibration | 9 | 84 | 2288.1 |
| 164 | 164 | Drill Plating | 13 | 113 | 2299.2 |
| 165 | 165 | Cargo Compressor | 10 | 107 | 2317.4 |
| 166 | 166 | Drill Torque | 28 | 721 | 2330.2 |
| 167 | 167 | Drill Torque | 29 | 824 | 2339.2 |
| 168 | 168 | Cooling Loop | 7 | 58 | 2350.8 |
| 169 | 169 | Drill Plating | 14 | 129 | 2364.4 |
| 170 | 170 | Route Planner | 12 | 98 | 2375.4 |
| 171 | 171 | XP Calibration | 10 | 96 | 2385.6 |
| 172 | 172 | Engine Tuning | 15 | 119 | 2398.2 |
| 173 | 173 | Seismic Sonar | 2 | 43 | 2413.6 |
| 174 | 174 | Vacuum Scoop | 5 | 40 | 2426.5 |
| 175 | 175 | Vacuum Scoop | 6 | 45 | 2438.6 |
| 176 | 176 | Cooling Loop | 8 | 66 | 2454.0 |
| 177 | 177 | Drill Torque | 30 | 940 | 2465.9 |
| 178 | 178 | Cooling Loop | 9 | 76 | 2478.6 |
| 179 | 179 | Cooling Loop | 10 | 87 | 2491.1 |
| 180 | 180 | Drill Plating | 15 | 148 | 2503.2 |
| 181 | 181 | Ore Refinery | 19 | 288 | 2517.4 |
| 182 | 182 | Dirt Softener | 15 | 196 | 2530.7 |
| 183 | 183 | Drill Torque | 31 | 1074 | 2545.9 |
| 184 | 184 | Salvage Drone | 5 | 73 | 2560.5 |
| 185 | 185 | Depth Scanner | 5 | 62 | 2572.8 |
| 186 | 186 | Engine Tuning | 16 | 136 | 2584.1 |
| 187 | 187 | Delivery Drone | 5 | 89 | 2598.1 |
| 188 | 188 | Seismic Sonar | 3 | 50 | 2613.3 |
| 189 | 189 | Timer Reserve | 12 | 76 | 2622.0 |
| 190 | 190 | Engine Tuning | 17 | 155 | 2633.6 |
| 191 | 191 | Drill Torque | 32 | 1227 | 2646.5 |
| 192 | 192 | Vacuum Scoop | 7 | 52 | 2656.6 |
| 193 | 193 | Seismic Sonar | 4 | 59 | 2671.4 |
| 194 | 194 | Foreman Bot | 4 | 66 | 2684.1 |
| 195 | 195 | Cargo Pods | 12 | 91 | 2697.3 |
| 196 | 196 | Drill Torque | 33 | 1401 | 2712.6 |
| 197 | 197 | Salvage Drone | 6 | 86 | 2725.9 |
| 198 | 198 | Drill Plating | 16 | 170 | 2736.1 |
| 199 | 199 | Auto Sorters | 2 | 53 | 2750.0 |
| 200 | 200 | Foreman Bot | 5 | 77 | 2764.4 |
| 201 | 201 | Drill Torque | 34 | 1600 | 2777.7 |
| 202 | 202 | Cargo Compressor | 11 | 124 | 2792.0 |
| 203 | 203 | Ore Refinery | 20 | 330 | 2804.3 |
| 204 | 204 | Cargo Compressor | 12 | 143 | 2816.5 |
| 205 | 205 | Cargo Compressor | 13 | 165 | 2832.0 |
| 206 | 206 | Vacuum Scoop | 8 | 60 | 2843.4 |
| 207 | 207 | Salvage Drone | 7 | 100 | 2855.0 |
| 208 | 208 | Drill Plating | 17 | 195 | 2865.8 |
| 209 | 209 | Drill Torque | 35 | 1827 | 2879.1 |
| 210 | 210 | Drill Torque | 36 | 2086 | 2894.8 |
| 211 | 211 | Salvage Drone | 8 | 117 | 2909.0 |
| 212 | 212 | Dirt Softener | 16 | 226 | 2922.6 |
| 213 | 213 | XP Calibration | 11 | 111 | 2935.8 |
| 214 | 214 | Vacuum Scoop | 9 | 68 | 2948.8 |
| 215 | 215 | Dirt Softener | 17 | 260 | 2964.2 |
| 216 | 216 | Ore Refinery | 21 | 379 | 2976.6 |
| 217 | 217 | Ore Refinery | 22 | 436 | 2987.0 |
| 218 | 218 | Timer Reserve | 13 | 87 | 3002.7 |
| 219 | 219 | Seismic Sonar | 5 | 69 | 3018.0 |
| 220 | 220 | Ore Refinery | 23 | 500 | 3028.5 |
| 221 | 221 | Auto Sorters | 3 | 62 | 3040.4 |
| 222 | 222 | Drill Torque | 37 | 2382 | 3051.9 |
| 223 | 223 | Foreman Bot | 6 | 91 | 3065.6 |
| 224 | 224 | Salvage Drone | 9 | 137 | 3075.9 |
| 225 | 225 | Cargo Compressor | 14 | 191 | 3091.1 |
| 226 | 226 | Drill Torque | 38 | 2721 | 3107.4 |
| 227 | 227 | Timer Reserve | 14 | 99 | 3122.7 |
| 228 | 228 | Depth Scanner | 6 | 72 | 3132.6 |
| 229 | 229 | Seismic Sonar | 6 | 80 | 3142.7 |
| 230 | 230 | Cooling Loop | 11 | 100 | 3157.7 |
| 231 | 231 | Drill Torque | 39 | 3107 | 3170.0 |
| 232 | 232 | Vacuum Scoop | 10 | 78 | 3185.6 |
| 233 | 233 | Vacuum Scoop | 11 | 90 | 3195.9 |
| 234 | 234 | Route Planner | 13 | 112 | 3211.3 |
| 235 | 235 | Ore Refinery | 24 | 574 | 3223.7 |
| 236 | 236 | Ore Refinery | 25 | 659 | 3234.0 |
| 237 | 237 | Auto Sorters | 4 | 73 | 3244.8 |
| 238 | 238 | Auto Sorters | 5 | 86 | 3255.9 |
| 239 | 239 | Engine Tuning | 18 | 176 | 3265.4 |
| 240 | 240 | Cooling Loop | 12 | 115 | 3276.3 |
| 241 | 241 | Salvage Drone | 10 | 160 | 3290.2 |
| 242 | 242 | Ore Refinery | 26 | 756 | 3300.4 |
| 243 | 243 | Foreman Bot | 7 | 106 | 3310.8 |
| 244 | 244 | Depth Scanner | 7 | 84 | 3323.4 |
| 245 | 245 | Salvage Drone | 11 | 187 | 3336.5 |
| 246 | 246 | Engine Tuning | 19 | 201 | 3351.8 |
| 247 | 247 | Auto Sorters | 6 | 101 | 3363.7 |
| 248 | 248 | Cooling Loop | 13 | 132 | 3379.1 |
| 249 | 249 | Dirt Softener | 18 | 299 | 3394.2 |
| 250 | 250 | XP Calibration | 12 | 128 | 3410.5 |
| 251 | 251 | Engine Tuning | 20 | 229 | 3425.4 |
| 252 | 252 | Foreman Bot | 8 | 125 | 3444.3 |
| 253 | 253 | Seismic Sonar | 7 | 94 | 3457.2 |
| 254 | 254 | Drill Plating | 18 | 223 | 3469.2 |
| 255 | 255 | Drill Plating | 19 | 256 | 3483.3 |
| 256 | 256 | Engine Tuning | 21 | 261 | 3495.4 |
| 257 | 257 | Engine Tuning | 22 | 298 | 3507.6 |
| 258 | 258 | Ore Refinery | 27 | 868 | 3520.1 |
| 259 | 259 | Cargo Compressor | 15 | 221 | 3533.9 |
| 260 | 260 | Timer Reserve | 15 | 113 | 3549.7 |
| 261 | 261 | Foreman Bot | 9 | 146 | 3563.5 |
| 262 | 262 | Route Planner | 14 | 128 | 3576.7 |
| 263 | 263 | Cooling Loop | 14 | 152 | 3591.8 |
| 264 | 264 | Foreman Bot | 10 | 171 | 3605.3 |
| 265 | 265 | Route Planner | 15 | 146 | 3621.0 |
| 266 | 266 | Depth Scanner | 8 | 97 | 3635.5 |
| 267 | 267 | Vacuum Scoop | 12 | 103 | 3651.0 |
| 268 | 268 | Cooling Loop | 15 | 175 | 3665.0 |
| 269 | 269 | Ore Refinery | 28 | 997 | 3676.7 |
| 270 | 270 | Drill Torque | 40 | 3548 | 3690.2 |
| 271 | 271 | Foreman Bot | 11 | 200 | 3702.6 |
| 272 | 272 | Auto Sorters | 7 | 119 | 3715.5 |
| 273 | 273 | Seismic Sonar | 8 | 110 | 3731.9 |
| 274 | 274 | Drill Plating | 20 | 293 | 3743.6 |
| 275 | 275 | Ore Refinery | 29 | 1144 | 3755.5 |
| 276 | 276 | Ore Refinery | 30 | 1314 | 3767.6 |
| 277 | 277 | Delivery Drone | 6 | 104 | 3787.0 |
| 278 | 278 | Engine Tuning | 23 | 339 | 3803.4 |
| 279 | 279 | Drill Plating | 21 | 336 | 3818.0 |
| 280 | 280 | Auto Sorters | 8 | 140 | 3831.8 |
| 281 | 281 | Depth Scanner | 9 | 113 | 3849.3 |
| 282 | 282 | Delivery Drone | 7 | 123 | 3865.4 |
| 283 | 283 | Depth Scanner | 10 | 131 | 3877.2 |
| 284 | 284 | Delivery Drone | 8 | 145 | 3889.2 |
| 285 | 285 | Depth Scanner | 11 | 153 | 3905.6 |
| 286 | 286 | Engine Tuning | 24 | 387 | 3920.7 |
| 287 | 287 | Engine Tuning | 25 | 441 | 3932.6 |
| 288 | 288 | Cargo Compressor | 16 | 255 | 3950.5 |
| 289 | 289 | Ore Refinery | 31 | 1508 | 3963.4 |
| 290 | 290 | XP Calibration | 13 | 148 | 3977.7 |
| 291 | 291 | Dirt Softener | 19 | 345 | 3989.9 |
| 292 | 292 | Route Planner | 16 | 168 | 4005.5 |
| 293 | 293 | Foreman Bot | 12 | 235 | 4018.4 |
| 294 | 294 | XP Calibration | 14 | 170 | 4035.8 |
| 295 | 295 | Cargo Compressor | 17 | 295 | 4051.3 |
| 296 | 296 | Route Planner | 17 | 192 | 4067.6 |
| 297 | 297 | Drill Plating | 22 | 385 | 4078.7 |
| 298 | 298 | Ore Refinery | 32 | 1731 | 4094.0 |
| 299 | 299 | Depth Scanner | 12 | 177 | 4114.2 |
| 300 | 300 | XP Calibration | 15 | 196 | 4128.6 |
| 301 | 301 | Foreman Bot | 13 | 275 | 4140.1 |
| 302 | 302 | Foreman Bot | 14 | 323 | 4154.2 |
| 303 | 303 | XP Calibration | 16 | 226 | 4168.8 |
| 304 | 304 | Cargo Compressor | 18 | 341 | 4182.9 |
| 305 | 305 | XP Calibration | 17 | 260 | 4194.6 |
| 306 | 306 | Seismic Sonar | 9 | 128 | 4208.3 |
| 307 | 307 | Engine Tuning | 26 | 503 | 4222.5 |
| 308 | 308 | Auto Sorters | 9 | 165 | 4238.8 |
| 309 | 309 | Cooling Loop | 16 | 201 | 4250.3 |
| 310 | 310 | Engine Tuning | 27 | 573 | 4268.1 |
| 311 | 311 | Timer Reserve | 16 | 128 | 4284.3 |
| 312 | 312 | Engine Tuning | 28 | 653 | 4295.6 |
| 313 | 313 | Cargo Compressor | 19 | 394 | 4308.4 |
| 314 | 314 | Cargo Pods | 13 | 104 | 4319.3 |
| 315 | 315 | Drill Plating | 23 | 441 | 4334.5 |
| 316 | 316 | Foreman Bot | 15 | 378 | 4352.9 |
| 317 | 317 | Delivery Drone | 9 | 171 | 4368.1 |
| 318 | 318 | Salvage Drone | 12 | 219 | 4384.1 |
| 319 | 319 | Cargo Compressor | 20 | 456 | 4396.9 |
| 320 | 320 | Vacuum Scoop | 13 | 118 | 4413.9 |
| 321 | 321 | Dirt Softener | 20 | 397 | 4430.8 |
| 322 | 322 | Cargo Compressor | 21 | 527 | 4445.8 |
| 323 | 323 | Auto Sorters | 10 | 194 | 4461.7 |
| 324 | 324 | Auto Sorters | 11 | 228 | 4478.3 |
| 325 | 325 | Auto Sorters | 12 | 268 | 4493.0 |
| 326 | 326 | Seismic Sonar | 10 | 150 | 4510.7 |
| 327 | 327 | Drill Plating | 24 | 505 | 4526.0 |
| 328 | 328 | Delivery Drone | 10 | 201 | 4543.0 |
| 329 | 329 | Cooling Loop | 17 | 231 | 4560.1 |
| 330 | 330 | Seismic Sonar | 11 | 175 | 4578.9 |
| 331 | 331 | Salvage Drone | 13 | 257 | 4593.5 |
| 332 | 332 | Cargo Compressor | 22 | 609 | 4608.6 |
| 333 | 333 | Seismic Sonar | 12 | 204 | 4625.2 |
| 334 | 334 | XP Calibration | 18 | 299 | 4639.4 |
| 335 | 335 | Drill Plating | 25 | 579 | 4656.5 |
| 336 | 336 | Drill Plating | 26 | 664 | 4672.0 |
| 337 | 337 | Delivery Drone | 11 | 237 | 4693.0 |
| 338 | 338 | Seismic Sonar | 13 | 239 | 4706.6 |
| 339 | 339 | XP Calibration | 19 | 345 | 4721.1 |
| 340 | 340 | XP Calibration | 20 | 397 | 4739.1 |
| 341 | 341 | Delivery Drone | 12 | 279 | 4756.8 |
| 342 | 342 | Foreman Bot | 16 | 443 | 4773.4 |
| 343 | 343 | XP Calibration | 21 | 458 | 4787.1 |
| 344 | 344 | Drill Plating | 27 | 761 | 4802.7 |
| 345 | 345 | Cooling Loop | 18 | 265 | 4822.4 |
| 346 | 346 | Foreman Bot | 17 | 520 | 4836.7 |
| 347 | 347 | XP Calibration | 22 | 527 | 4850.0 |
| 348 | 348 | Drill Plating | 28 | 872 | 4870.8 |
| 349 | 349 | Cargo Pods | 14 | 119 | 4888.4 |
| 350 | 350 | Foreman Bot | 18 | 609 | 4903.6 |
| 351 | 351 | Timer Reserve | 17 | 146 | 4918.2 |
| 352 | 352 | Drill Plating | 29 | 999 | 4934.4 |
| 353 | 353 | Dirt Softener | 21 | 458 | 4956.9 |
| 354 | 354 | XP Calibration | 23 | 607 | 4975.0 |
| 355 | 355 | Cargo Pods | 15 | 136 | 4991.4 |
| 356 | 356 | Vacuum Scoop | 14 | 135 | 5009.0 |
| 357 | 357 | Route Planner | 18 | 220 | 5025.6 |
| 358 | 358 | Auto Sorters | 13 | 315 | 5043.9 |
| 359 | 359 | Delivery Drone | 13 | 328 | 5060.8 |
| 360 | 360 | Drill Plating | 30 | 1145 | 5079.3 |
| 361 | 361 | Route Planner | 19 | 252 | 5099.6 |
| 362 | 362 | Salvage Drone | 14 | 300 | 5119.8 |
| 363 | 363 | XP Calibration | 24 | 699 | 5136.6 |
| 364 | 364 | Dirt Softener | 22 | 527 | 5153.1 |
| 365 | 365 | XP Calibration | 25 | 806 | 5172.1 |
| 366 | 366 | Seismic Sonar | 14 | 279 | 5188.0 |
| 367 | 367 | Cooling Loop | 19 | 305 | 5209.0 |
| 368 | 368 | Cargo Pods | 16 | 156 | 5228.6 |
| 369 | 369 | XP Calibration | 26 | 928 | 5245.2 |
| 370 | 370 | Auto Sorters | 14 | 370 | 5263.5 |
| 371 | 371 | Cargo Pods | 17 | 178 | 5283.8 |
| 372 | 372 | Vacuum Scoop | 15 | 155 | 5301.9 |
| 373 | 373 | Delivery Drone | 14 | 387 | 5317.9 |
| 374 | 374 | Seismic Sonar | 15 | 325 | 5337.9 |
| 375 | 375 | Seismic Sonar | 16 | 380 | 5357.0 |
| 376 | 376 | Drill Plating | 31 | 1312 | 5376.6 |
| 377 | 377 | Drill Plating | 32 | 1504 | 5398.1 |
| 378 | 378 | Timer Reserve | 18 | 167 | 5414.6 |
| 379 | 379 | Seismic Sonar | 17 | 444 | 5430.0 |
| 380 | 380 | Salvage Drone | 15 | 351 | 5448.2 |
| 381 | 381 | Auto Sorters | 15 | 435 | 5465.7 |
| 382 | 382 | Vacuum Scoop | 16 | 178 | 5487.4 |
| 383 | 383 | Salvage Drone | 16 | 411 | 5507.3 |
| 384 | 384 | Timer Reserve | 19 | 190 | 5522.5 |
| 385 | 385 | Vacuum Scoop | 17 | 204 | 5543.9 |
| 386 | 386 | Cooling Loop | 20 | 350 | 5563.7 |
| 387 | 387 | Cooling Loop | 21 | 402 | 5583.3 |
| 388 | 388 | Auto Sorters | 16 | 512 | 5605.6 |
| 389 | 389 | Route Planner | 20 | 288 | 5624.5 |
| 390 | 390 | Seismic Sonar | 18 | 518 | 5641.5 |
| 391 | 391 | Cooling Loop | 22 | 462 | 5659.6 |
| 392 | 392 | Cooling Loop | 23 | 531 | 5680.2 |
| 393 | 393 | Timer Reserve | 20 | 217 | 5698.2 |
| 394 | 394 | Cooling Loop | 24 | 610 | 5716.5 |
| 395 | 395 | Cargo Pods | 18 | 204 | 5734.2 |
| 396 | 396 | Vacuum Scoop | 18 | 233 | 5754.8 |
| 397 | 397 | Delivery Drone | 15 | 456 | 5774.9 |
| 398 | 398 | Delivery Drone | 16 | 537 | 5793.7 |
| 399 | 399 | Salvage Drone | 17 | 481 | 5816.7 |
| 400 | 400 | Salvage Drone | 18 | 563 | 5833.9 |
| 401 | 401 | Timer Reserve | 21 | 247 | 5856.4 |
| 402 | 402 | Timer Reserve | 22 | 282 | 5876.3 |
| 403 | 403 | Timer Reserve | 23 | 321 | 5896.0 |
| 404 | 404 | Timer Reserve | 24 | 367 | 5918.1 |
| 405 | 405 | Delivery Drone | 17 | 633 | 5937.1 |
| 406 | 406 | Timer Reserve | 25 | 418 | 5955.6 |
| 407 | 407 | Cargo Pods | 19 | 233 | 5975.4 |
| 408 | 408 | Delivery Drone | 18 | 745 | 5996.2 |
| 409 | 409 | Timer Reserve | 26 | 476 | 6016.3 |
| 410 | 410 | Vacuum Scoop | 19 | 267 | 6034.5 |
| 411 | 411 | Timer Reserve | 27 | 543 | 6054.7 |
| 412 | 412 | Salvage Drone | 19 | 658 | 6077.0 |
| 413 | 413 | Timer Reserve | 28 | 619 | 6098.3 |
| 414 | 414 | Cargo Pods | 20 | 266 | 6118.3 |
| 415 | 415 | Cargo Pods | 21 | 304 | 6138.4 |
| 416 | 416 | Cargo Pods | 22 | 348 | 6155.9 |
| 417 | 417 | Vacuum Scoop | 20 | 306 | 6173.1 |
| 418 | 418 | Salvage Drone | 20 | 770 | 6196.0 |
| 419 | 419 | Cargo Pods | 23 | 397 | 6219.1 |
| 420 | 420 | Vacuum Scoop | 21 | 351 | 6242.0 |
| 421 | 421 | Cargo Pods | 24 | 454 | 6260.7 |
| 422 | 422 | Cargo Pods | 25 | 519 | 6283.2 |
| 423 | 423 | Vacuum Scoop | 22 | 402 | 6306.9 |
| 424 | 424 | Cargo Pods | 26 | 593 | 6324.9 |