# 60 Upgrade Concepts (Diverse, Money-Per-Run Focus)

This list is designed to avoid "damage spam" by spreading progression across:
- resource throughput (more enemies, better conversion)
- run depth (survivability, boss handling)
- tempo (walk speed, kill cycle speed)
- active engine (power gain, active uptime, active efficiency)

## Spacing Rules (So Similar Upgrades Are Far Apart)
Use these rules when building your unlock graph:
1. Family cooldown: after buying an upgrade from one family, require at least 2 purchases from other families before the next same-family upgrade.
2. Hard gate tiers: each family has Tier A/B/C. Tier B requires at least 1 upgrade from 3 other families. Tier C requires boss clear milestone + 6 non-family purchases since last same-family pick.
3. Character upgrades: character-specific upgrades require owning the character and at least 3 global upgrades since any previous upgrade for that same character.
4. Repeats allowed only as "Mark II/III" variants and never adjacent in the unlock path.

Families used below:
- `ECON` Economy/Collection
- `DENS` Enemy Count/Spawn Pressure
- `SURV` Survivability/Reach
- `BOSS` Boss-only progression
- `MOVE` Movement/Pathing pace
- `POWR` Power economy
- `ACTV` Active duration/cooldown/efficiency
- `TEAM` Character train synergy

## Upgrade Set (60)

1. `Salvage Hooks` (`ECON`)
- +5% enemy drop value.
- Prereq: none.

2. `Field Magnet` (`ECON`)
- +8% walk-over pickup radius.
- Prereq: `Salvage Hooks`.

3. `Encroaching Horde` (`DENS`)
- +4% regular enemy count.
- Prereq: none.

4. `Trail Boots` (`MOVE`)
- +4% walk speed.
- Prereq: none.

5. `Reinforced Plates` (`SURV`)
- +3% general damage reduction.
- Prereq: none.

6. `Condensed Cores` (`POWR`)
- +10% power gained per enemy kill.
- Prereq: power system unlocked.

7. `Focused Breathing` (`ACTV`)
- +0.4s active duration for all heroes.
- Prereq: power system unlocked.

8. `Boss Stance` (`BOSS`)
- +4% boss-only armor.
- Prereq: first boss encountered.

9. `Knight Bloodline I` (`TEAM`)
- Knight vampirism heal conversion +6%.
- Prereq: Knight active unlocked.

10. `Supply Lenses` (`ECON`)
- Cursor-collected portion increases from 60% to 62%.
- Prereq: `Field Magnet`.

11. `Wave Bringer I` (`DENS`)
- +1 guaranteed elite regular enemy per run (higher drop).
- Prereq: `Encroaching Horde`.

12. `Archer Drill I` (`TEAM`)
- Archer base arrow fire rate +8%.
- Prereq: Archer unlocked.

13. `Impact Weave` (`SURV`)
- Contact damage taken -6%.
- Prereq: `Reinforced Plates`.

14. `Stride Rhythm` (`MOVE`)
- +3% speed and +3% faster transition between targets.
- Prereq: `Trail Boots`.

15. `Power Reservoir I` (`POWR`)
- +12 flat power capacity.
- Prereq: `Condensed Cores`.

16. `Quick Invocation I` (`ACTV`)
- All active cooldowns -4%.
- Prereq: `Focused Breathing`.

17. `Boss Readiness` (`BOSS`)
- Boss contact damage taken -8%.
- Prereq: `Boss Stance`.

18. `Scrap Broker` (`ECON`)
- +7% value from cursor-collected pickups only.
- Prereq: `Supply Lenses`.

19. `Line Pressure I` (`DENS`)
- +5% regular enemy count, +2% enemy drop value.
- Prereq: `Wave Bringer I`.

20. `Guardian Bulwark I` (`TEAM`)
- Guardian grants +4% max HP to whole train.
- Prereq: Guardian unlocked.

21. `Hemostasis Mesh` (`SURV`)
- Environmental DoT taken -10%.
- Prereq: `Impact Weave`.

22. `Momentum Carry` (`MOVE`)
- +5% speed while no enemy is in contact range.
- Prereq: `Stride Rhythm`.

23. `Overflow Capture` (`POWR`)
- At full power, excess converts to +2% drop value (temporary, stacks to 20%).
- Prereq: `Power Reservoir I`.

24. `Extended Channel I` (`ACTV`)
- +0.5s active duration.
- Prereq: `Quick Invocation I`.

25. `Boss Fracture Study` (`BOSS`)
- Boss effective HP -5%.
- Prereq: `Boss Readiness`.

26. `Taxonomy Scanner` (`ECON`)
- +6% value from elite enemies.
- Prereq: `Scrap Broker`.

27. `Archer Piercing Geometry` (`TEAM`)
- Archer active pierce width +15%.
- Prereq: Archer active unlocked.

28. `Crowd Ecology` (`DENS`)
- +6% enemy count, but enemy contact DPS +2%.
- Prereq: `Line Pressure I`.

29. `Shock Padding` (`SURV`)
- First 8 seconds of each encounter: +8% mitigation.
- Prereq: `Hemostasis Mesh`.

30. `Route Memory` (`MOVE`)
- +6% move speed after each kill for 2.5s (refreshing).
- Prereq: `Momentum Carry`.

31. `Power Reservoir II` (`POWR`)
- +20 flat power capacity.
- Prereq: `Power Reservoir I`.

32. `Quick Invocation II` (`ACTV`)
- All active cooldowns -5%.
- Prereq: `Quick Invocation I`.

33. `Boss Armor Mesh` (`BOSS`)
- +5% boss-only armor.
- Prereq: `Boss Fracture Study`.

34. `Collector Drone` (`ECON`)
- Missed pickup share reduced from 10% to 8%.
- Prereq: `Taxonomy Scanner`.

35. `Wave Bringer II` (`DENS`)
- +1 additional elite regular enemy per run.
- Prereq: `Wave Bringer I`.

36. `Mage Sigil I` (`TEAM`)
- Mage storm baseline damage +10%.
- Prereq: Mage unlocked.

37. `Layered Carapace` (`SURV`)
- +3% general damage reduction.
- Prereq: `Shock Padding`.

38. `Quickstep Chain` (`MOVE`)
- +4% move speed and contact exit recovery faster.
- Prereq: `Route Memory`.

39. `Condensed Cores II` (`POWR`)
- +12% power gained per kill.
- Prereq: `Condensed Cores`.

40. `Extended Channel II` (`ACTV`)
- +0.6s active duration.
- Prereq: `Extended Channel I`.

41. `Boss Pattern Map` (`BOSS`)
- Boss encounter time grants +6% train damage scaling (ramps over 20s).
- Prereq: `Boss Armor Mesh`.

42. `Salvage Hooks II` (`ECON`)
- +6% enemy drop value.
- Prereq: `Salvage Hooks`.

43. `Front Compression` (`DENS`)
- +7% enemy count, +3% drop value.
- Prereq: `Crowd Ecology`.

44. `Knight Bloodline II` (`TEAM`)
- Vampirism active also grants +6% contact mitigation while active.
- Prereq: `Knight Bloodline I`.

45. `DoT Deflector` (`SURV`)
- Environmental DoT taken -12%.
- Prereq: `Hemostasis Mesh`.

46. `Pathline Sprint` (`MOVE`)
- +8% speed while above 70% HP.
- Prereq: `Quickstep Chain`.

47. `Power Echo` (`POWR`)
- Every 4th active cast refunds 25% of its power cost.
- Prereq: `Condensed Cores II`.

48. `Cadence Lock` (`ACTV`)
- During any active, all other cooldowns tick 10% faster.
- Prereq: `Quick Invocation II`.

49. `Boss Bastion` (`BOSS`)
- +6% boss-only armor.
- Prereq: `Boss Pattern Map`.

50. `Market Routing` (`ECON`)
- Currency bank interest: +1.5% wallet after each run (capped per run).
- Prereq: `Collector Drone`.

51. `Pressure Ladder` (`DENS`)
- +8% enemy count. For each 10 enemies killed, +1% drop value this run.
- Prereq: `Front Compression`.

52. `Guardian Bulwark II` (`TEAM`)
- Guardian aura: +5% armor to all allies during boss encounter.
- Prereq: `Guardian Bulwark I`.

53. `Shock Sink` (`SURV`)
- Contact damage taken -10%.
- Prereq: `DoT Deflector`.

54. `Long March` (`MOVE`)
- +5% base speed and +10% pickup walk-over efficiency.
- Prereq: `Pathline Sprint`.

55. `Power Reservoir III` (`POWR`)
- +30 power capacity.
- Prereq: `Power Reservoir II`.

56. `Overclock Window` (`ACTV`)
- +0.7s active duration; cooldowns -3%.
- Prereq: `Cadence Lock`.

57. `Boss Rend Protocol` (`BOSS`)
- Boss effective HP -8%.
- Prereq: `Boss Bastion`.

58. `Archer Drill II` (`TEAM`)
- Archer base fire rate +10% and pierce active duration +0.5s.
- Prereq: `Archer Drill I` + `Extended Channel II`.

59. `Mage Sigil II` (`TEAM`)
- Mage storm damage +12%; storm casts generate bonus currency on boss hits.
- Prereq: `Mage Sigil I` + `Boss Pattern Map`.

60. `Run Yield Matrix` (`ECON`)
- End-of-run multiplier: +4% total credited currency if boss reached, +8% if boss defeated.
- Prereq: `Market Routing` + `Boss Rend Protocol`.

## Suggested Milestone Rhythm (Character Unlock Distance)
Use these unlock cost/prereq milestones to keep characters far apart:
- Archer unlock target: around run 20-30.
- Guardian unlock target: 8-15 runs after Archer.
- Mage unlock target: 10-20 runs after Guardian.

Make unlocks depend on mixed-family prerequisites so players must take varied upgrades between characters.

## Implementation Note
When you wire this into simulation, keep two controls:
1. "Availability": prerequisite checks and cost.
2. "Offer/priority": avoid selecting same family consecutively.

That gives variety without sacrificing deterministic balance tuning.
