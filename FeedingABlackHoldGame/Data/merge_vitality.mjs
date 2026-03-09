import fs from 'fs';
const dir = process.cwd();
const mainPath = dir + '/FishingUpgradeData.json';
const vitalityPath = dir + '/vitality_tree.json';
let mainStr = fs.readFileSync(mainPath, 'utf8');
if (mainStr.charCodeAt(0) === 0xFEFF) mainStr = mainStr.slice(1);
const main = JSON.parse(mainStr);
let vitBuf = fs.readFileSync(vitalityPath);
let vitStr = (vitBuf[0] === 0xFF && vitBuf[1] === 0xFE) ? vitBuf.slice(2).toString('utf16le') : vitBuf.toString('utf8');
if (vitStr.charCodeAt(0) === 0xFEFF) vitStr = vitStr.slice(1);
const vitality = JSON.parse(vitStr);
// vitality[0] is root - already added manually. Add L1..L25 for each path (indices 1..25, 26..50, 51..75)
const toAdd = vitality.slice(1);
for (const e of toAdd) {
  main.upgrades.push(e);
}
main.total_nodes = main.upgrades.length;
fs.writeFileSync(mainPath, JSON.stringify(main, null, 4), 'utf8');
console.log('Added', toAdd.length, 'vitality path nodes. Total upgrades:', main.upgrades.length);
