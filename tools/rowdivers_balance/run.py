"""Run current balance in an isolated, autoload-free Godot project."""
from pathlib import Path
import argparse
import json
import hashlib
import runpy
import shutil
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[2]
MODULE = ROOT / 'FeedingABlackHoldGame/Games/RowDivers'

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--config', type=Path)
    parser.add_argument('--free-aim', action='store_true')
    parser.add_argument('--frozen-snapshot', type=Path, help='Use the exact model/runner/catalog saved with an earlier experiment')
    parser.add_argument('--current-runner', action='store_true', help='Use current experiment instrumentation with frozen combat')
    parser.add_argument('--catalog', type=Path, help='Upgrade catalog for this isolated experiment')
    parser.add_argument('--output', type=Path, default=MODULE / 'Simulation/Results/campaign.json')
    parser.add_argument('--input', type=Path, help='Read-only progression snapshot; omit for fresh save')
    parser.add_argument('--snapshot', action='store_true')
    parser.add_argument('--repeats', type=int, default=10)
    parser.add_argument('--max-runs', type=int, default=1500)
    parser.add_argument('--dt', type=float, default=1/60)
    args = parser.parse_args()
    if args.free_aim and args.frozen_snapshot and not (args.frozen_snapshot/'GeneratedFreeAimModel.gd.txt').exists():
        raise SystemExit('This snapshot predates the flying simulation; capture a current flying snapshot first.')
    if not args.frozen_snapshot:
        runpy.run_path(str(Path(__file__).with_name('build_model.py')))
    config = dict(mode='snapshot' if args.snapshot else 'campaign', repeats=args.repeats,
                  max_runs=args.max_runs, dt=args.dt)
    if args.config:
        config.update(json.loads(args.config.read_text(encoding='utf-8')))
    else:
        config.update(shortlist=4, ending_reserve=True, purchase_buffer=True,
                      purchase_buffer_min_prestige=3, policy='separate-normal-and-boss-v4-p3-buffer',
                      weights=dict(distance=.60, gold_rate=.28, gem_rate=.12))
    config['output'] = args.output.resolve().as_posix()
    if args.input:
        config['input'] = args.input.resolve().as_posix()
    config.setdefault('seed', 2401026)
    if args.free_aim: config['free_aim'] = True
    manifest = args.frozen_snapshot / 'manifest.json' if args.frozen_snapshot else MODULE / 'Simulation/source_manifest.json'
    config['source_manifest'] = json.loads(manifest.read_text())
    args.output.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory(prefix='railway-balance-') as folder:
        staging = Path(folder)
        (staging / 'project.godot').write_text('config_version=5\n[application]\nconfig/name="Railway Balance Offline"\n[rendering]\nrenderer/rendering_method="gl_compatibility"\n', encoding='utf-8')
        dest = staging / 'Games/RowDivers'
        (dest / 'Simulation').mkdir(parents=True)
        (dest / 'Data').mkdir()
        for rel in ['RowDiversProgress.gd', 'Data/row_divers.json', 'Simulation/GeneratedCombatModel.gd', 'Simulation/RunBalanceCampaign.gd']:
            filename = Path(rel).name
            frozen = filename if filename.endswith('.json') else filename + '.txt'
            source_file = args.frozen_snapshot / frozen if args.frozen_snapshot else MODULE / rel
            if args.current_runner and filename == 'RunBalanceCampaign.gd':
                source_file = MODULE / rel
            shutil.copyfile(source_file, dest / rel)
        if args.catalog:
            shutil.copyfile(args.catalog, dest / 'Data/row_divers.json')
        for rel in ['RowDiversDemo.gd','RowDiversTiming.gd','RowDiversFireWaves.gd','Simulation/FlightPilot.gd','Simulation/GeneratedFreeAimModel.gd']:
            frozen = args.frozen_snapshot / (Path(rel).name+'.txt') if args.frozen_snapshot else None
            shutil.copyfile(frozen if frozen and frozen.exists() else MODULE/rel, dest/rel)
        flight_catalog = args.catalog if args.catalog else MODULE/'Data/row_divers_free_aim.json'
        shutil.copyfile(flight_catalog, dest/'Data/row_divers_free_aim.json')
        if config.get('free_aim'):
            shutil.copyfile(flight_catalog, dest/'Data/row_divers.json')
        config['runner_sha256'] = hashlib.sha256((dest / 'Simulation/RunBalanceCampaign.gd').read_bytes()).hexdigest()
        config['catalog_sha256'] = hashlib.sha256((dest / 'Data/row_divers.json').read_bytes()).hexdigest()
        if args.catalog:
            shutil.copyfile(dest / 'Simulation/RunBalanceCampaign.gd', args.output.parent / ('runner_' + config['runner_sha256'][:12] + '.gd.txt'))
        cfg = staging / 'config.json'
        cfg.write_text(json.dumps(config), encoding='utf-8')
        command = [str(ROOT / 'Godot/Godot_v4.6-stable_win64_console.exe'), '--headless', '--path', str(staging),
                   '--script', 'res://Games/RowDivers/Simulation/RunBalanceCampaign.gd', '--', str(cfg)]
        process = subprocess.Popen(command, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True, encoding='utf-8', errors='replace', creationflags=getattr(subprocess, 'BELOW_NORMAL_PRIORITY_CLASS', 0))
        script_error = False
        for line in process.stdout:
            print(line, end='', flush=True)
            script_error |= 'SCRIPT ERROR:' in line or line.startswith('ERROR:')
        status = process.wait()
        if status or script_error:
            raise SystemExit(f'Godot simulation failed (exit={status}, error output={script_error})')

if __name__ == '__main__':
    main()
