# Crown progression, editor playthrough tools, and endings

## Fire control follows crowns

Free aim has three Ember Channels branches, one for each prestige reached after
earning a crown. Each requires both its crown-priced weapon unlock and the matching
prestige. They cost gold after unlocking; they do not consume additional crowns.

| Prestige | Crown-priced parent | Four node base prices (gold) |
|---:|---|---|
| 1 | Fire Gem | 200 / 500 / 1,000 / 2,000 |
| 2 | Cursed Gem | 2,000 / 5,000 / 10,000 / 20,000 |
| 3 | Third Eye | 20,000 / 50,000 / 100,000 / 200,000 |

Each node has two ranks, +10 whole control points per rank. Second ranks cost 1.2×
the base price, rounded up. The 80-point cap and each prestige's independent stat
remain. Earlier channels cannot calm a later prestige's fire. Crown-priced weapon
nodes are also gated to their matching prestige in the flying tree.

Prestige 0 has no channels: its fire escalation uses 35% pressure, so earning the
first crown is possible before buying crown upgrades. Later prestiges retain the
strong boss escalation. Fire damage stays fixed within a prestige (15 / 100 / 400 /
1,200). Waves reset on each dive. There are now 124 nodes, with 112 maxed nodes
required for the final chamber. Its one-time fee remains 200,000 gold, 10 gems,
and 4 crowns.

Existing saves refund gold for removed Prestige 0 channels and for channels whose
new crown/prestige requirement has not been met. Purchased crown weapons and other
progress remain. The migration runs once and recomputes channel points from the
remaining ranks.

## Playing an accelerated run in the editor

1. Choose Free Aim, start a dive, and select **4× or higher** in Editor Cheats.
2. The same pilot used in the offline simulations aims, shoots, strafes around
   fire waves/projectiles, pursues loot, and uses unlocked abilities on cooldown.
   Its crosshair follows its aim. All damage remains active.
3. **64× and 128×** are available alongside the earlier speeds. Each repeats normal
   physics steps; it does not increase the physics delta. F7 cycles speeds and F8
   returns to 1×. Below 4×, control returns to you. Speed carries between dives for
   this application session.
4. Return to Upgrades and click **EDITOR: AUTO BUY**. At **8× or higher**, this
   starts continuous auto play: each finished run shows its result for one second,
   returns to Upgrades, claims achievements and buys using the campaign policy,
   then starts the next dive after a short pause. The highest unlocked prestige
   is selected before shopping. Runs continue even when nothing is affordable.
5. Click **STOP AUTO LOOP** (or **CANCEL AUTO BUY** while shopping), lower battle
   speed to **4× or below**, press **F8**, or return to the menu to stop. At 1×–4×,
   the first Auto Buy click still performs a single shopping batch; its opt-in
   remains armed until stopped or the speed is explicitly lowered. Starting a
   later dive and raising speed above 4× begins the loop.
6. Once the final chamber is ready and affordable, auto play opens it and stops
   at the ending choice. You choose the ending. Auto play is session-only and
   scoped to the active save profile; restarting the game clears it.

Speed assistance requires the existing editor feature and
`railway_fury/debug/enable_speed_cheats` setting. Auto Buy is also editor-only.
These controls are unavailable in an exported game.

## Auto Buy uses the campaign buyer

The button invokes the real `RunBalanceCampaign.gd` purchase selector in a temporary
autoload-free Godot process. No duplicate scoring approximation is used. Flying
uses the same two-candidate shortlist, 60% reach / 28% gold-rate / 12% gem-rate
weights, shared pilot and native combat model. Classic uses its four-candidate
shortlist. Ready achievements are claimed before shopping and after each purchase.
Prestige 3 retains the campaign's affordable-purchase buffer when possible.

The UI stays responsive and shows forecasted purchases. Clicking again cancels.
The batch is applied and saved only when forecasting finishes and the original
live save still matches. Leaving the screen cancels its worker. Forecast victories
never grant loot or crowns to the live save. Final entry funds are reserved once
the chamber is ready; Auto Buy never chooses an ending for the player. A forecast
error or cancellation stops continuous play rather than silently starting a run.

Each job keeps its inputs, runner/catalog hashes, choices, alternatives, scores,
claims and resulting wallet in
`user://railway_editor_autobuy/session_<id>/result.json`.

## Two endings

The final choice contains only these two endings, each with a finished inked
landscape illustration. The original Free Them and Claim the Throne options have
been removed:

- **Build a Home — The Last Station:** turn the railway into a settlement. The
  engine warms gardens, the carriages become houses, and everyone gets a key.
- **Leave the Tracks — Beyond the Rails:** melt the crowns into tools, dismantle
  the engine, and walk into an uncertain world without its power.

Choices are saved in `ending` and `endings_seen`. The existing ending analytics
milestone accepts these two outcomes and remains deduplicated per save.

[Two choices](Previews/ending_two_choices.png) ·
[The Last Station](Previews/ending_LastStation.png) ·
[Beyond the Rails](Previews/ending_BeyondTheRails.png) ·
[Editor Auto Buy](Previews/editor_auto_buy.png)

Validation and the new campaign trace are stored in `Simulation/CrownValidation/`.
Earlier gem-gated balance reports remain historical records of that earlier tree.

Auto-loop validation: `Tools/VerifyEditorLoop.gd` covers repeated shopping/launch,
prestige advancement, cancellation, result return, stale timers, speed and profile
gates, and the final chamber boundary. Its fixtures intercept navigation and
disable persistence so test runs do not write player progress.

Artwork generation details and prompts: [Ending artwork](EndingArtwork.md).
