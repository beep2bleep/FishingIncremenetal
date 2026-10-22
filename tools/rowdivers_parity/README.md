# Row Divers differential logic replay

From the repository root:

```powershell
python -m pip install -r tools/rowdivers_parity/requirements.txt
python tools/rowdivers_parity/run.py --campaign --self-test
```

Requires Python 3, a .NET 8 SDK, the bundled Godot executable, and the local decompiled project at `C:\Decompiled\Row Divers\ExportedProject`. Override that path with `--source`. Nothing launches a game window, touches the original game installation/save, or writes the Railway Fury progression save.

Generated reference copies, builds, action tapes, state traces and logs go under `.validation/rowdivers-parity/`. The original C# is not committed. `prepare_reference.py` copies the listed classes byte-for-byte and extracts named methods verbatim from the larger controllers; SHA-256 hashes are recorded. `SourceMethods.cs.txt` contains adapters and insertion markers, not translated combat implementations. The `.NET` driver executes those original methods against `UnityAdapters.cs`. Godot executes our actual progression/battle code through a headless probe that suppresses corridor construction and floating text. Audio and UI services are inherited but no display is opened.

The importer separately regenerates reference design data from the current Unity scenes/prefabs. It is checked against the committed catalog before results are accepted. This catches edited or stale design data, though both data extractions use the same importer and its assumptions still need auditing.

## What the action tapes compare

- All 330 legal purchases in forward, reverse and seeded mixed orders: every intermediate price, level, stat, visible node, unlock and achievement.
- Consecutive/repeated victory events, original miniboss/boss achievement logic, prestige progression and one-time crowns.
- Chamber payment, insufficient funds, repeat entry, both ending states, all achievement reward attempts and repeat claims.
- Enemy health for all seven kinds, four prestiges and four group indices.
- Row damage, movement, running, pause/resume, all ability effects/timers/repeat activation, shield blocking and Harvester rewards.
- Actual original arrow/fire/curse/shuriken hit methods, including repeated reuse of one pooled projectile, overlapping statuses, critical hits, life steal and poison.
- Original dagger and Third Eye damage routines against normal/boss targets with each status.

Inputs are normalized logic events: axis values, ticks, ability presses, purchases and explicit projectile impacts/targets/random draws. A direct dagger/beam damage case invokes the original damage routine at impact; it does not model attack travel, raycasts or beam acquisition. This is **not a recording of identical raw mouse/keyboard input through two complete engines**.

`--campaign` additionally runs our four complete gameplay rows with one continuous, memory-only progress dictionary and the legally purchased maximum loadout. Fixture currency funds those initial purchases; this does not simulate the natural fresh-save earning grind. Currency, achievements, crowns and run count then carry between rows, and both endings are exercised. Original C# progression events are compared separately; an entire original combat campaign is not replayed alongside this test.

## Reading the result

`report.json` includes the first divergent input and state field for each failing case. `inputs.json`, `reference.json` and `railway.json` retain complete evidence. Tolerances are explicit: absolute `2e-5`, relative `2e-6` for ordinary numeric fields and `1e-12` for health, so large enemy health cannot hide damage differences.

`--self-test` injects +1 arrow damage into an ignored reference copy and requires the comparison to catch it. The copy is restored in `finally` and rebuilt; original sources remain unchanged.

Exit codes: **0** means the covered logic cases match; **1** means a difference/design mismatch; **2** means full end-to-end certification was requested but remains unverified. Use `--require-end-to-end` for that strict gate. Script/compiler errors also fail the run.

`exact_end_to_end_certified` intentionally remains **false**. The adapters omit Unity native collision/rigidbody physics, raw input smoothing, native frame/coroutine scheduling, original projectile flight/raycast ordering, section selection and projectile shuffle RNG. The harness cannot certify a complete original campaign, all possible input sequences, visual behavior, or the fresh-save grind. Passing these fixtures must not be described as proof of exact whole-game parity.

## Native original capture and recorded-control replay

```powershell
python tools/rowdivers_parity/run_native.py
# Reuse the existing native capture:
python tools/rowdivers_parity/run_native.py --replay-only
```

Requires the installed Unity 6000.0.68f1 editor (override with `--unity`). The export targets 6000.0.27f1, so this is not a bit-identical released executable test. The runner exports the maximum-loadout fixture, copies the entire original project into `.validation/rowdivers-parity/native-unity`, disables Steam only in that copy, redirects its saves, resets only those instrumentation saves, and supplies scripted controls in batch mode. Player-only Input System plugins are excluded from the copy to permit Editor execution; gameplay uses legacy input. Original source, saves and installed executable are untouched.

The original scenes/physics/coroutines then run through consecutive rows, stopping at death or four wins. `native-frames.jsonl` records actual axes, key presses, pointer pixels, health/armor and position. The Godot recorder replays the controls against our real scene at the recorded viewport. `native-control-replay.json` records first health/armor divergences, terminal states, position error, engine metadata and input/fixture hashes. Native exceptions or timeouts fail capture; observed differences return **1**. With no observed differences the runner still returns **2**, since layout/RNG/scheduling equivalence remains unproven.

Current evidence: both clear rows 0–2, with different health/armor. On row 3 the original dies at 82.35 s and our replay at 61.97 s. No prestige forcing was needed. Section/spawn RNG streams and scheduling are **not synchronized**, so these traces do not isolate a single formula as the cause. The original uses 50 Hz fixed updates; the port replay steps at the recorded 60 Hz. This is separate from the successful adaptive four-row Godot fixture. See the committed `Docs/PARITY_SIMULATION.md` report for both results and remaining certification work.
