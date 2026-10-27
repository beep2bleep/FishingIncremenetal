"""Create the independent flying tree from the installed assisted catalog."""
import json
import argparse
from copy import deepcopy
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
MODULE = ROOT/'FeedingABlackHoldGame/Games/RowDivers'

def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--initial',action='store_true')
    args=parser.parse_args()
    original=json.loads((MODULE/'Data/row_divers.json').read_text())
    data=deepcopy(original)
    data['base_stats'].update(Arrow_Damage=30, Arrow_Speed=8, Horizontal_Speed=1, PickupRange=.84)
    nodes={n['id']:n for n in data['upgrades']}
    if not args.initial:
        for node in data['upgrades']:
            if node['upgradeName']=='Medicine II': node['effects'][0]['amount']=800
            if node['upgradeName']=='Red Heart': node['effects'][0]['amount']=2000
            if node['upgradeName']=='Shiny Armor': node['effects'][0]['amount']=750
    crown_parents={1:'6660',2:'6426',3:'6688'}
    for p,parent in crown_parents.items():
        nodes[parent]['minPrestige']=p
    for p in range(4):
        data['base_stats'][f'Fire_Wave_Control_{p}']=0
        if p==0: continue # First crown must be earnable before fire control exists.
        parent=crown_parents[p]
        for rank in range(4):
            node=deepcopy(nodes[parent])
            key=f'flight_{p}_{rank}'
            node.update(id=key, upgradeName=f'Ember Channels {p+1}-{rank+1}',
                upgradeDescription=f'After {nodes[parent]["upgradeName"]} (crown upgrade). Prestige {p} only: +10 fire-wave control per rank. Calms boss escalation; damage stays constant.',
                maxLevel=2,level=0,unlockAtParentLevel=1,isVisible=0,isUnlocked=0,
                baseUpgradeCost=[10,25,50,100][rank]*[1,20,200,2000][p],
                cost=dict(amount=0,currencyType=0),parents=[parent],children=[],unlocks={},
                effects=[dict(stat=f'Fire_Wave_Control_{p}',percentage=False,amount=10)],
                statsToIncrease=[],position=[-45+rank*30,65+p*18],
                local_position=dict(x=-45+rank*30,y=65+p*18),minPrestige=p,rarity=p+1)
            nodes[parent]['children'].append(key)
            data['upgrades'].append(node)
    data['settings'].update(fire_waves=dict(damage=[15,100,400,1200],intro_pressure=.35),
        flight_rewards=dict(gold=2,gems=1),ending_maxed_nodes=112)
    (MODULE/'Data/row_divers_free_aim.json').write_text(json.dumps(data,indent=2)+'\n')
    folder=MODULE/'Simulation/Flight'
    folder.mkdir(exist_ok=True)
    if not (folder/'initial_catalog.json').exists():
        (folder/'initial_catalog.json').write_text(json.dumps(data,indent=2)+'\n')
    print('Prepared 124-node flying tree, three crown-gated prestige control branches.')

if __name__=='__main__':main()
