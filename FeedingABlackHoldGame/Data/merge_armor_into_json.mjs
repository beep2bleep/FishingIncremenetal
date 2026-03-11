/**
 * Replace 15 armor nodes with 75 (5 tracks x 5 levels x 3 types).
 * Contact/boss armor use the standard 1.55 scaling curve.
 * DOT armor keeps its current track entry prices but follows the same 1.55 scaling.
 */
import { readFileSync, writeFileSync } from "fs";
import { fileURLToPath } from "url";
import { dirname, join } from "path";

const __dirname = dirname(fileURLToPath(import.meta.url));
const JSON_PATH = join(__dirname, "FishingUpgradeData.json");

const ROMAN = ["I", "II", "III", "IV", "V"];
const CONTACT_COSTS = [360, 558, 864.9, 1340.6, 2077.9];
const DOT_TRACK_STARTS = [370, 2220, 13320, 79920, 479520];
const TYPES = [
  { key: "enemy", baseX: 15, growth: 1.55, costForLevel: (_track, level) => CONTACT_COSTS[level - 1] },
  {
    key: "dot",
    baseX: 14,
    growth: 1.55,
    costForLevel: (track, level) => Math.round(DOT_TRACK_STARTS[track - 1] * Math.pow(1.55, level - 1) * 10) / 10,
  },
  { key: "boss", baseX: 13, growth: 1.55, costForLevel: (_track, level) => CONTACT_COSTS[level - 1] },
];

function buildArmorNodes() {
  const nodes = [];
  for (const { key: type, baseX, growth, costForLevel } of TYPES) {
    for (let track = 1; track <= 5; track++) {
      const key = `core_armor_${type}_${track}`;
      const gridX = baseX + (track - 1);
      for (let level = 1; level <= 5; level++) {
        const id = `${key}__L${level}`;
        const dep = level === 1 ? "core_armor__L1" : `${key}__L${level - 1}`;
        nodes.push({
          id,
          key,
          level,
          is_level_node: true,
          name: `CORE ARMOR ${type.toUpperCase()} ${track} ${ROMAN[level - 1]}`,
          icon: "res://generatedicon/core_armor.png",
          cost: costForLevel(track, level),
          repeatable: true,
          growth,
          dependency: dep,
          group: 1,
          group_pos: level,
          grid_x: gridX,
          grid_y: 7 + level,
        });
      }
    }
  }
  return nodes;
}

const data = JSON.parse(readFileSync(JSON_PATH, "utf8"));
const upgrades = data.upgrades || [];
const armorStart = upgrades.findIndex((n) => n.id === "core_armor_enemy__L1");
if (armorStart < 0) {
  console.error("Armor block not found");
  process.exit(1);
}
const armorEnd = armorStart + 15;
const newUpgrades = [
  ...upgrades.slice(0, armorStart),
  ...buildArmorNodes(),
  ...upgrades.slice(armorEnd),
];
data.upgrades = newUpgrades;
data.total_nodes = newUpgrades.length;
writeFileSync(JSON_PATH, JSON.stringify(data, null, 4), "utf8");
console.log(`Replaced armor block: ${armorStart}..${armorStart + 15} with 75 nodes. Total nodes: ${newUpgrades.length}`);
