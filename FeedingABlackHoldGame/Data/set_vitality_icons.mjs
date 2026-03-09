import fs from "fs";
const dir = process.cwd();
const path = dir + "/FishingUpgradeData.json";
let s = fs.readFileSync(path, "utf8");
if (s.charCodeAt(0) === 0xfeff) s = s.slice(1);
const data = JSON.parse(s);
const vitalityKeys = ["vitality_foundation", "vitality_hitpoints", "vitality_power", "vitality_channel"];
let n = 0;
for (const u of data.upgrades) {
  if (vitalityKeys.includes(u.key)) {
    u.icon = "res://generatedicon/core_drop.png";
    n++;
  }
}
fs.writeFileSync(path, JSON.stringify(data, null, 4), "utf8");
console.log("Reverted icon for", n, "vitality upgrades to core_drop.png");
