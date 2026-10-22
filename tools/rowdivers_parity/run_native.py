"""Capture native original controls, replay in Godot, and fail on differences.

The environment/RNG streams are not synchronized. A failure is evidence against
certification, not proof that a particular damage formula caused the divergence.
"""
from pathlib import Path
import argparse, hashlib, json, os, subprocess, sys
from prepare_native import prepare, ROOT, WORK

PROJECT = ROOT / 'FeedingABlackHoldGame'
GODOT = ROOT / 'Godot/Godot_v4.6-stable_win64_console.exe'


def godot(script, *args):
    return [str(GODOT), '--headless', '--path', str(PROJECT),
            '--rendering-method', 'gl_compatibility', '--script',
            'res://Games/RowDivers/Tools/' + script, '--', *map(str, args)]


def logged(command, path, cwd=ROOT, timeout=300):
    with path.open('w', encoding='utf-8') as log:
        subprocess.run(command, cwd=cwd, stdout=log, stderr=subprocess.STDOUT,
                       check=True, timeout=timeout,
                       creationflags=subprocess.CREATE_NO_WINDOW if os.name == 'nt' else 0)
    if 'SCRIPT ERROR:' in path.read_text(errors='replace'):
        raise RuntimeError('Script failed: ' + str(path))


def run(args):
    output = WORK.parent / 'native-control-replay.json'
    if not args.replay_only:
        WORK.parent.mkdir(parents=True, exist_ok=True)
        logged(godot('VerifyRowDiversCampaign.gd', '--export-reference-fixture'),
               WORK.parent / 'native-fixture.log')
        fixture = Path(os.environ['TEMP']) / 'RailwayFury-maxed-reference-fixture.json'
        prepare(play=True, fixture=fixture)
        logged([str(args.unity), '-batchmode', '-nographics', '-projectPath', str(WORK),
                '-executeMethod', 'NativeParityEditor.Run', '-logFile',
                str(WORK.parent / 'native-unity-run.log')],
               WORK.parent / 'native-unity-launch.log', cwd=WORK)
    trace = WORK / 'native-frames.jsonl'
    events = [json.loads(line) for line in trace.read_text().splitlines() if line.strip()]
    if any('error' in e for e in events) or not any('finished' in e for e in events):
        raise RuntimeError('Native capture had exceptions or did not finish: ' + str(trace))
    if any(e.get('exit_code', 0) != 0 for e in events):
        raise RuntimeError('Native capture failed its watchdog')
    logged(godot('ReplayNativeRowDiversInputs.gd', trace, WORK / 'fixture.json', output),
           WORK.parent / 'native-control-replay.log')
    report = json.loads(output.read_text())
    report['capture'] = {
        'exceptions': 0,
        'metadata': [e for e in events if e.get('meta')],
        'finished': [e for e in events if 'finished' in e],
        'trace_sha256': hashlib.sha256(trace.read_bytes()).hexdigest(),
        'fixture_sha256': hashlib.sha256((WORK / 'fixture.json').read_bytes()).hexdigest(),
    }
    report['observed_differences'] = any(r['first_vitals_difference'] or
        r['max_position_delta_m'] > 0.001 or
        r['native'].get('won') != r['railway']['won'] for r in report['runs'])
    output.write_text(json.dumps(report, indent=2))
    print(json.dumps({'runs': len(report['runs']), 'observed_differences': report['observed_differences'],
                      'exact_end_to_end_certified': False, 'report': str(output)}))
    # Never certify identical play merely because coarse vitals happened to match.
    return 1 if report['observed_differences'] else 2


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--unity', type=Path, default=Path(
        r'C:\Program Files\Unity\Hub\Editor\6000.0.68f1\Editor\Unity.exe'))
    parser.add_argument('--replay-only', action='store_true', help='Reuse the existing native capture')
    sys.exit(run(parser.parse_args()))
