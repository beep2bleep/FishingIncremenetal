# Achievement rewards and rounded upgrades

The original simulations already claimed achievements before shopping and after every purchase. Unlocking Achievements immediately releases any previously earned rewards; achievements earned in combat are claimed at the next shop. Each recommendation uses the wallet after these claims.

The original three release campaigns each collected 10,875 gold, 20 gems and 3 crowns from achievements. In seed 2401026, unlocking Achievements after run 5 left 2 gold; First Dive added 25 and immediately funded a 3-gold upgrade. The original outcome therefore already includes the benefit of achievement-funded upgrades.

A separate issue was found in standalone recommendation mode: it had not claimed pending rewards before selecting an upgrade. That path now claims them first. Regression cases verify a ready reward funds a recommendation, claimed rewards are not duplicated, and the locked tab prevents claiming.

Eleven upgrade amounts were rounded and the same three seeds were simulated again with the existing reward-aware policy. Health/damage additions and percentages are whole numbers. Small range and dagger-rate increments can use exact quarters. Percentage compounding can still produce fractional resulting stats.

The follow-up also adds a Prestige 3 budget reserve: once a shop has bought an upgrade, the buyer keeps one affordable option for a possible zero-income dive. The check includes achievement rewards that the proposed purchase unlocks. Earlier prestiges keep the original spending policy. The full balance report compares previous and rounded trees using this same final policy. The table below compares the original release policy with the final rounded-and-reserved result, so its differences include both changes.

| Seed | Before rounding: runs | Rounded: runs | Achievement rewards (gold / gems / crowns) |
|---:|---:|---:|---:|
| 2401026 | 48 | 53 | 10875 / 20 / 3 |
| 2401027 | 49 | 47 | 10875 / 20 / 3 |
| 2401028 | 48 | 49 | 10875 / 20 / 3 |

Every campaign completed all four prestiges and paid the final entry fee. The independent audit reconciles the reward credits in every shop phase against recorded purchase wallets, validates reward amounts against the catalog, and rejects duplicate claims.

[Full reward and increment audit](reward_rounding_audit.json) · [Exact rounding changes](round_numbers_p3_buffer/rounding_changes.json) · [Full balance report](TUNING_REPORT.md)
