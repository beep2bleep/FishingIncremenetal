/**
 * Generate upgrade list markdown with descriptions (like upgrade_ui_removal_list.md).
 * Reads current FishingUpgradeData.json and outputs each upgrade with color and description.
 * Run: node FeedingABlackHoldGame/Data/gen_upgrade_list_with_descriptions.mjs
 */
import { readFileSync, writeFileSync } from "fs";
import { fileURLToPath } from "url";
import { dirname, join } from "path";

const __dirname = dirname(fileURLToPath(import.meta.url));
const JSON_PATH = join(__dirname, "FishingUpgradeData.json");
const OUT_PATH = join(dirname(dirname(__dirname)), "upgrade_list_with_descriptions.md");

const EXTRA_NAME_A = ["Adaptive", "Fractal", "Iron", "Solar", "Echo", "Rift", "Pulse", "Aegis", "Vector", "Nova"];
const EXTRA_NAME_B = ["Circuit", "Relay", "Ledger", "Spine", "Burst", "Anchor", "Lattice", "Compass", "Engine", "Matrix"];
const EXTRA_FAMILY_ORDER = ["ECON", "DENS", "SURV", "MOVE", "POWR", "ACTV", "BOSS", "TEAM"];

const SPECIFIC_NAMES = {
  cursor_pickup_unlock: "Cursor Pickup Unlock",
  recruit_archer: "Recruit Archer",
  auto_attack_unlock: "Tactical Telemetry",
  battle_speed_unlock: "Temporal Throttle",
  knight_vamp_unlock: "Knight Vampirism Unlock",
  archer_pierce_unlock: "Archer Pierce Unlock",
  power_harvest_unlock: "Power Harvest Unlock",
  recruit_guardian: "Recruit Guardian",
  guardian_fortify_unlock: "Guardian Fortify Unlock",
  recruit_mage: "Recruit Mage",
  mage_storm_unlock: "Mage Storm Unlock",
  party_damage_boost: "Party Power",
  party_battle_standard: "Battle Standard",
  party_war_drums: "War Drums",
  party_execution_doctrine: "Execution Doctrine",
  party_apex_overdrive: "Apex Overdrive",
  vitality_foundation: "Vitality Foundation",
};

const SPECIFIC_DESCRIPTIONS = {
  cursor_pickup_unlock: "Unlocks cursor pickup bonuses so cursor-collected coins are worth more.",
  hero_coin_gain: "Multiplies coin value by +20% per level (exponential over 25 levels). Applies to coins collected by heroes or cursor.",
  cursor_capture_gain: "Multiplies cursor-captured coin value by +2.5% per level (exponential over 25 levels).",
  recruit_archer: "Adds the Archer hero to your combat lineup.",
  auto_attack_unlock: "Unlocks Tactical Telemetry: reveals enemies remaining during battle using the blue progress HUD.",
  battle_speed_unlock: "Unlocks battle speed control in non-editor builds. Buy levels to unlock 2x, then 4x, then 8x speed.",
  knight_vamp_unlock: "Unlocks the Knight active and improves life steal sustain.",
  archer_pierce_unlock: "Unlocks the Archer active with piercing attack coverage.",
  power_harvest_unlock: "Unlocks stronger power generation from combat and pickups.",
  recruit_guardian: "Adds the Guardian hero to your combat lineup.",
  guardian_fortify_unlock: "Unlocks the Guardian active: grants a Limited-Time Fortify that reduces incoming damage.",
  recruit_mage: "Adds the Mage hero to your combat lineup.",
  mage_storm_unlock: "Unlocks the Mage active: while active, the storm repeatedly damages all enemies on screen.",
  party_damage_boost: "Increases all party damage by 8% per level.",
  party_battle_standard: "Increases all party damage by 12% per level.",
  party_war_drums: "Increases all party damage by 16% per level.",
  party_execution_doctrine: "Increases all party damage by 20% per level.",
  party_apex_overdrive: "Increases all party damage by 25% per level.",
  vitality_foundation: "Unlocks the Vitality tree: +50 max Health. From here you can invest in Hitpoints, Power, or Channel time.",
  vitality_hitpoints: "Increases max Health by 20% per level. Each of the five tracks (I–V) adds 20% per level; cost scales 3x per track depth. Stacks multiplicatively across all levels.",
  vitality_power: "Increases power generation and power capacity by 5% per level. Each of the five tracks (I–V) adds 5% per level; cost scales 3x per track depth.",
  vitality_channel: "Increases active ability channel (duration) by 5% per level, but also increases the power cost to activate per character by 5% per level. Lets actives run longer at a higher activation cost. Cost scales 3x per track depth.",
};

const THEME_COLORS = {
  1: { name: "Green", hex: "#4D9E60" },
  2: { name: "Red", hex: "#D75252" },
  3: { name: "Cyan", hex: "#40B2CD" },
  4: { name: "Blue", hex: "#5282E0" },
  5: { name: "Purple", hex: "#A966D8" },
  6: { name: "Orange", hex: "#E78A3D" },
  7: { name: "Gold", hex: "#D8BE42" },
};

function roman(value) {
  const v = Math.max(1, parseInt(value, 10) || 1);
  const r = ["I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X"];
  return r[v - 1] || String(v);
}

function themeActForKey(key) {
  const lower = key.toLowerCase();
  if (lower === "vitality_foundation" || lower === "vitality_hitpoints") return 4;
  if (lower === "vitality_power" || lower === "vitality_channel") return 5;
  if (lower.startsWith("extra_skill_")) {
    const n = parseInt(lower.replace("extra_skill_", ""), 10) || 0;
    if (n > 0) {
      const cycle = [3, 6, 4, 3, 5, 5, 6, 7];
      return cycle[(n - 1) % cycle.length];
    }
  }
  if (lower.startsWith("recruit_")) return 1;
  if (/damage|speed|pierce|storm|bloodline|vamp|wave|impact|sigil|piercing|drill|line_pressure|auto_attack/.test(lower)) return 2;
  if (/cursor|pickup|drop|salvage|broker|collector|market|scanner|magnet|lens|breathing|rhythm|momentum/.test(lower)) return 3;
  if (/armor|plate|carapace|shock|hemostasis|bulwark|fortify|deflector/.test(lower)) return 4;
  if (/power|reservoir|condensed|invocation|channel|overclock|cadence|active/.test(lower)) return 5;
  if (/boss|horde|density|wave|crowd|pressure|front_compression/.test(lower)) return 6;
  return 7;
}

function getDisplayName(entry) {
  const key = String(entry.key || "").trim();
  const level = parseInt(entry.level, 10) || 1;
  const baseKey = key.replace(/__L\d+$/, "").replace(/_60$/, "");
  if (baseKey === "vitality_hitpoints") return `Vitality Hitpoints ${roman(Math.floor((level - 1) / 5) + 1)}`;
  if (baseKey === "vitality_power") return `Vitality Power ${roman(Math.floor((level - 1) / 5) + 1)}`;
  if (baseKey === "vitality_channel") return `Vitality Channel ${roman(Math.floor((level - 1) / 5) + 1)}`;
  if (SPECIFIC_NAMES[baseKey]) return SPECIFIC_NAMES[baseKey];
  if (key.startsWith("extra_skill_")) {
    const n = parseInt(key.replace("extra_skill_", ""), 10) || 0;
    if (n > 0) {
      const idx = (n - 1) % EXTRA_NAME_A.length;
      return `${EXTRA_NAME_A[idx]} ${EXTRA_NAME_B[idx]} ${n}`;
    }
  }
  if (key.startsWith("core_")) {
    if (key === "core_armor") return "Core Armor";
    if (key.startsWith("core_armor_enemy_")) {
      const track = key.replace("core_armor_enemy_", "");
      return `Core Armor Enemy ${track} ${roman(level)}`;
    }
    if (key.startsWith("core_armor_dot_")) {
      const track = key.replace("core_armor_dot_", "");
      return `Core Armor DOT ${track} ${roman(level)}`;
    }
    if (key.startsWith("core_armor_boss_")) {
      const track = key.replace("core_armor_boss_", "");
      return `Core Armor Boss ${track} ${roman(level)}`;
    }
    if (key === "core_drop") return "Core Drop";
    if (key === "core_power") return "Core Power";
    if (/core_(knight|archer|guardian|mage)_(damage|speed)/.test(key)) {
      const hero = key.includes("knight") ? "Knight" : key.includes("archer") ? "Archer" : key.includes("guardian") ? "Guardian" : "Mage";
      const stat = key.includes("damage") ? "Damage" : "Speed";
      const roman = ["I", "II", "III", "IV", "V"][Math.min(Math.floor((level - 1) / 5), 4)] || String(level);
      return `${hero} ${stat} ${roman}`;
    }
  }
  const name = String(entry.name || key).replace(/_/g, " ").toLowerCase();
  return name.replace(/\b\w/g, (c) => c.toUpperCase());
}

function getDescription(entry) {
  const key = String(entry.key || "").trim();
  const level = parseInt(entry.level, 10) || 1;
  const baseKey = key.replace(/__L\d+$/, "").replace(/_60$/, "");
  if (SPECIFIC_DESCRIPTIONS[baseKey]) return SPECIFIC_DESCRIPTIONS[baseKey];
  if (entry.description) return entry.description;
  const lower = key.toLowerCase();
  if (key.startsWith("core_")) {
    if (key === "core_armor") return "Unlocks the Core Armor branch: three paths that reduce enemy, DOT, and boss damage taken.";
    if (key.startsWith("core_armor_enemy_")) {
      const total = level >= 1 ? Math.floor((Math.pow(3, level + 1) - 3) / 2) : 0;
      return `Reduces regular enemy contact damage taken by ${total} (3x per level, cumulative over ${level} purchases). Cost 6x per level.`;
    }
    if (key.startsWith("core_armor_dot_")) {
      const total = level >= 1 ? Math.floor((Math.pow(3, level + 1) - 3) / 2) : 0;
      return `Reduces damage-over-time taken by ${total} (3x per level, cumulative over ${level} purchases). Cost 6x per level.`;
    }
    if (key.startsWith("core_armor_boss_")) {
      const total = level >= 1 ? Math.floor((Math.pow(3, level + 2) - 9) / 2) : 0;
      return `Reduces boss damage taken by ${total} (3x per level, cumulative over ${level} purchases). Cost 6x per level.`;
    }
    if (key === "core_drop") return "Increase coin drop value scaling by +8% per level.";
    if (key === "core_power") return "Increase power gain by +12% per level, power cap by +8, and reduce active power cost by about 2% per level.";
    if (/damage/.test(lower)) return "Increases direct damage output (typically about +1.2%–1.5% total team DPS per level before global tuning).";
    if (/speed/.test(lower)) return "Increases attack cadence (typically about +0.9%–1.2% faster attacks per level before global tuning).";
    return "Increase this core stat scaling.";
  }
  if (key.startsWith("extra_skill_")) {
    const n = parseInt(key.replace("extra_skill_", ""), 10) || 0;
    const family = n > 0 ? EXTRA_FAMILY_ORDER[(n - 1) % EXTRA_FAMILY_ORDER.length] : "TEAM";
    const desc = {
      ECON: "Increases combat reward efficiency so each kill converts into more useful coin and stronger next-run upgrades.",
      DENS: "Raises enemy density/pressure so your DPS kills more targets per second and increases coin-per-minute ceiling.",
      SURV: "Improves survivability (armor/contact/DoT mitigation) so the team survives deeper waves and reaches bosses more often.",
      MOVE: "Improves formation movement and retarget tempo so heroes spend less time repositioning and more time dealing damage.",
      POWR: "Improves power generation/cap/refund so actives trigger earlier and more frequently in each run.",
      ACTV: "Improves active uptime (duration and cooldown cadence), increasing burst windows and sustained team DPS.",
      BOSS: "Improves boss-phase effectiveness (damage throughput, mitigation, or reward scaling) to clear more boss segments.",
      TEAM: "Improves hero-specific combat stats and active ceilings, increasing total squad damage and consistency.",
    };
    return desc[family] || "Boosts combat scaling for this branch and improves clear speed against enemies and boss phases.";
  }
  if (/armor|plate|fortify|hemostasis/.test(lower)) return "Reduces incoming damage (roughly -0.8% to -1.2% taken per level before global tuning).";
  if (/power|reservoir|invocation|active/.test(lower)) return "Improves active ability economy (about +2.5% power gain per level and modest cooldown/cost reductions before global tuning).";
  if (/boss|segment/.test(lower)) return "Improves boss progression (reduces effective boss HP or increases boss rewards by a few percent per level).";
  if (/drop|pickup|coin|salvage/.test(lower)) return "Increases coin conversion from combat by roughly +3% income per level (before cursor and extra-skill bonuses).";
  if (/archer|knight|guardian|mage/.test(lower)) return "Improves hero-specific combat contribution (roughly +1%–2% total squad DPS or safety per level depending on the hero).";
  if (lower.includes("battle_speed")) return "Unlocks the Speed button and enables battle speed selection; upgrade for more options (4x, 8x).";
  return "Improves run combat effectiveness by boosting hero output, uptime, durability, or reward conversion on this branch.";
}

const data = JSON.parse(readFileSync(JSON_PATH, "utf8"));
const upgrades = data.upgrades || [];
const lines = [
  "# Upgrade List With Descriptions",
  "",
  "All upgrades currently in the tree, with theme color and a short description of what each does.",
  "",
  "Theme colors: Green `#4D9E60`, Red `#D75252`, Cyan `#40B2CD`, Blue `#5282E0`, Purple `#A966D8`, Orange `#E78A3D`, Gold `#D8BE42`.",
  "",
  `Total upgrade nodes: ${upgrades.length}`,
  "",
];

for (const entry of upgrades) {
  const key = String(entry.key || "").trim();
  const theme = themeActForKey(key);
  const color = THEME_COLORS[theme] || THEME_COLORS[7];
  const displayName = getDisplayName(entry);
  const description = getDescription(entry);
  lines.push(`* [${color.name} ${color.hex}] **${displayName}**`);
  lines.push(`  ${description}`);
  lines.push("");
}

writeFileSync(OUT_PATH, lines.join("\n"), "utf8");
console.log(`Wrote ${upgrades.length} upgrades to ${OUT_PATH}`);
