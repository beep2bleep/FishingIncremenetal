"""Import numeric design data and tree geometry; no reference artwork/audio is copied."""
from pathlib import Path
import argparse, hashlib, json, re
import yaml

ROOT = Path(__file__).resolve().parents[1]
DEST = ROOT / 'FeedingABlackHoldGame/Games/RowDivers/Data'

def documents(path):
    text = path.read_text(encoding='utf-8-sig')
    result = {}
    for kind, uid, body in re.findall(r'^--- !u!(\d+) &(-?\d+)\n(.*?)(?=^--- !u!|\Z)', text, re.M | re.S):
        body = re.sub(r'^(\s*(?:keys|bannedEnemies):) ([0-9a-f]+)$', r'\1 "\2"', body, flags=re.M)
        obj = yaml.safe_load(body)
        if obj:
            result[int(uid)] = (int(kind), next(iter(obj.values())))
    return result

def enum(path):
    content = path.read_text()
    names = re.search(r'enum \w+\s*\{(.*?)\}', content, re.S)[1]
    result, index = {}, 0
    for name, explicit in re.findall(r'(\w+)\s*(?:=\s*(\d+))?\s*(?:,|$)', names.strip()):
        index = int(explicit) if explicit else index
        result[index] = name
        index += 1
    return result

def run(source):
    scripts = source / 'Assets/Scripts/Assembly-CSharp'
    enums = {n: enum(scripts / (n + '.cs')) for n in ['Stat', 'StatType', 'WeaponType', 'FireType', 'TabType', 'AbilityType', 'CurrencyType', 'ZombieType', 'AchievementType']}
    home = documents(source / 'Assets/Scenes/HomeScene.unity')
    game = documents(source / 'Assets/Scenes/GameScene.unity')
    transforms = {v['m_GameObject']['fileID']: (uid, v) for uid, (k, v) in home.items() if k in (4, 224)}
    controllers = {v['m_GameObject']['fileID']: (uid, v) for uid, (k, v) in home.items() if 'childUpgrades' in v}
    upgrade_guid = re.search(r'guid: (\w+)', (scripts / 'UpgradeData.cs.meta').read_text())[1]
    upgrades, controller_to_name = [], {}
    for uid, (kind, v) in home.items():
        if v.get('m_Script', {}).get('guid') != upgrade_guid:
            continue
        go = v['m_GameObject']['fileID']
        transform_uid, transform = transforms[go]
        # Accumulate parent translations/scales so siblings under different roots keep their layout.
        x, y = 0.0, 0.0
        current = transform
        while current:
            pos = current.get('m_AnchoredPosition', current.get('m_LocalPosition', {}))
            scale = current.get('m_LocalScale', {'x': 1, 'y': 1})
            x, y = x * scale['x'] + pos.get('x', 0), y * scale['y'] + pos.get('y', 0)
            parent = current.get('m_Father', {}).get('fileID', 0)
            current = home.get(parent, (0, None))[1]
        item = {k: v[k] for k in ['upgradeName', 'upgradeDescription', 'maxLevel', 'level', 'unlockAtParentLevel', 'rarity', 'isVisible', 'isUnlocked', 'baseUpgradeCost', 'cost', 'statsToIncrease']}
        item['id'] = str(uid)
        item['position'] = [round(x, 6), round(y, 6)]
        item['local_position'] = transform.get('m_AnchoredPosition', transform['m_LocalPosition'])
        item['size'] = transform.get('m_SizeDelta', {'x': 100, 'y': 100})
        item['unlocks'] = {k: enums[e][v[k]] for k, e in [('weaponType', 'WeaponType'), ('fireType', 'FireType'), ('tabType', 'TabType'), ('abilityType', 'AbilityType')] if enums[e][v[k]] != 'None'}
        item['effects'] = [{'stat': enums['Stat'][p['first']], 'percentage': p['second']['first'] == 1, 'amount': p['second']['second']} for p in v['statsToIncrease'] or []]
        cid, controller = controllers[go]
        controller_to_name[cid] = item['id']
        item['child_controllers'] = [c['fileID'] for c in controller.get('childUpgrades', [])]
        upgrades.append(item)
    for item in upgrades:
        item['children'] = [controller_to_name[c] for c in item.pop('child_controllers')]
        item['parents'] = [p['id'] for p in upgrades if item['id'] in p.get('children', [])]
    # Parents are resolved after every children list exists.
    for item in upgrades:
        item['parents'] = [p['id'] for p in upgrades if item['id'] in p['children']]
    stats_guid = re.search(r'guid: (\w+)', (scripts / 'Stats.cs.meta').read_text())[1]
    base_stats = {}
    for scene in [home, game, documents(source / 'Assets/Scenes/MainMenuScene.unity')]:
        for _, v in scene.values():
            if v.get('m_Script', {}).get('guid') == stats_guid:
                pairs = v['baseStats']
                if isinstance(pairs, dict):
                    keys, values = pairs.get('keys', []), pairs.get('values', [])
                    if isinstance(keys, str):
                        keys = [int.from_bytes(bytes.fromhex(keys)[i:i+4], 'little') for i in range(0, len(bytes.fromhex(keys)), 4)]
                    base_stats = {enums['Stat'][int(k)]: val for k, val in zip(keys, values)}
    settings = {}
    settings['achievements'] = []
    for _, v in home.values():
        if 'achievementName' in v:
            settings['achievements'].append({k: v[k] for k in ['achievementName', 'achievementType', 'description', 'currencyType', 'reward']})
    for _, v in game.values():
        if 'forwardSpeed' in v:
            settings['movement'] = {k: v[k] for k in ['forwardSpeed', 'horizontalSpeed', 'runningSpeedMultiplier']}
        if 'abilityDuration' in v:
            settings.setdefault('abilities', []).append({k: v[k] for k in ['abilityName', 'abilityType', 'abilityDuration', 'cooldownDuration']})
    settings['prefabs'] = {}
    settings['sections'] = {}
    def world_position(doc, transform_id):
        point = [0.0, 0.0, 0.0]
        while transform_id:
            transform = doc[transform_id][1]
            p = transform['m_LocalPosition']
            scale = transform['m_LocalScale']
            point = [point[i] * scale[axis] + p[axis] for i, axis in enumerate('xyz')]
            transform_id = transform.get('m_Father', {}).get('fileID', 0)
        return point
    def section_data(doc):
        result = []
        for _, v in doc.values():
            if 'spawnPoints' not in v:
                continue
            for group in v['spawnPoints']:
                banned = group.get('bannedEnemies') or ''
                banned = [int.from_bytes(bytes.fromhex(str(banned))[i:i+4], 'little') for i in range(0, len(bytes.fromhex(str(banned))), 4)] if banned else []
                result.append({'left': [world_position(doc, ref['fileID']) for ref in group['leftSpawnPointsGroup']], 'right': [world_position(doc, ref['fileID']) for ref in group['rightSpawnPointsGroup']], 'banned': banned})
        return result
    settings['sections']['Initial'] = section_data(game)
    for path in (source / 'Assets/GameObject').glob('*.prefab'):
        if not re.match(r'(Zombie|Mummy|Section |MiniBoss[12] Section|Boss Section|Crownless Boss|Coin|Gem|Crown|.*Chest)', path.stem):
            continue
        doc = documents(path)
        groups = section_data(doc)
        if groups:
            settings['sections'][path.stem] = groups
        actors = []
        for _, v in doc.values():
            if any(k in v for k in ['baseHealth', 'currencyValue', 'fireRate', 'spawnPoints']):
                actors.append({k: v[k] for k in ['baseHealth', 'baseShield', 'baseDamage', 'zombieType', 'currencyValue', 'currencyType', 'fireRate', 'amountOfBullets', 'burstCount', 'burstDelay', 'spawnPoints'] if k in v})
        settings['prefabs'][path.stem] = actors
    # Raw serialized dictionaries are kept for auditing importer assumptions.
    raw_stats = [v for s in [home, game, documents(source / 'Assets/Scenes/MainMenuScene.unity')] for _, v in s.values() if v.get('m_Script', {}).get('guid') == stats_guid]
    DEST.mkdir(parents=True, exist_ok=True)
    data = {'source': str(source), 'home_sha256': hashlib.sha256((source / 'Assets/Scenes/HomeScene.unity').read_bytes()).hexdigest(), 'upgrades': upgrades, 'base_stats': base_stats, 'settings': settings, 'enums': enums, 'serialized_stats': raw_stats}
    (DEST / 'row_divers.json').write_text(json.dumps(data, indent=2, ensure_ascii=False), encoding='utf-8')
    print(f"Imported {len(upgrades)} upgrades, {sum(len(u['children']) for u in upgrades)} edges, {len(base_stats)} base stats")
    print(json.dumps(settings, indent=2))
    print(json.dumps(raw_stats, indent=2)[:3000])

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--source', type=Path, default=Path(r'C:\Decompiled\Row Divers\ExportedProject'))
    run(parser.parse_args().source)
