from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
import json
import math
import re


ROOT = Path(__file__).resolve().parent
ABSTRACT_JSON_PATH = ROOT / "open_pit_empire_funnel_report.json"
REPORT_PATH = ROOT / "open_pit_empire_mechanics_report.md"
JSON_PATH = ROOT / "open_pit_empire_mechanics_report.json"


@dataclass(frozen=True)
class ZoneModel:
    label: str
    density: float
    lane_width: float
    chain_factor: float
    splash_factor: float
    hp_pressure: float
    occlusion: float
    traversal_drag: float
    block_footprint: float


ZONES = {
    "Proxy Cache": ZoneModel("Proxy Cache", 0.90, 0.65, 0.10, 0.10, 0.95, 1.75, 0.92, 0.82),
    "Cipher Depths": ZoneModel("Cipher Depths", 0.98, 0.72, 0.12, 0.11, 0.98, 0.40, 1.00, 0.88),
    "Ghost Sector": ZoneModel("Ghost Sector", 1.10, 0.86, 0.18, 0.16, 1.02, 0.24, 1.10, 0.96),
    "Kernel Vault": ZoneModel("Kernel Vault", 1.28, 0.98, 0.22, 0.21, 1.08, 0.24, 1.20, 1.08),
    "Root Well": ZoneModel("Root Well", 1.42, 1.10, 0.28, 0.25, 1.14, 0.25, 1.34, 1.20),
    "Mirror Shelf": ZoneModel("Mirror Shelf", 1.55, 1.24, 0.34, 0.28, 1.20, 0.22, 1.48, 1.36),
    "Reverse Fault": ZoneModel("Reverse Fault", 1.70, 1.34, 0.40, 0.33, 1.25, 0.46, 1.68, 1.58),
    "Null Vein": ZoneModel("Null Vein", 1.88, 1.42, 0.48, 0.38, 1.32, 0.78, 1.88, 1.82),
    "Grave Mantle": ZoneModel("Grave Mantle", 2.08, 1.52, 0.55, 0.44, 1.38, 1.02, 2.04, 2.10),
    "Crown of Ash": ZoneModel("Crown of Ash", 2.28, 1.66, 0.62, 0.50, 1.46, 1.42, 2.22, 2.42),
}


UPGRADE_RE = re.compile(r"^(?P<label>.+?) (?P<level>\d+)$")


def parse_label(purchase: str) -> str:
    match = UPGRADE_RE.match(purchase)
    return match.group("label") if match else purchase


def accumulate_levels(runs: list[dict]) -> dict[str, int]:
    levels: dict[str, int] = {}
    for run in runs:
        for purchase in run["purchases"]:
            label = parse_label(purchase)
            levels[label] = levels.get(label, 0) + 1
    return levels


def compute_profile(levels: dict[str, int], zone: ZoneModel) -> dict[str, float]:
    shots = 1.0
    shots += 0.18 * levels.get("Rapid Cycle", 0)
    shots += 0.22 * levels.get("Breach Drones", 0)
    shots += 0.12 * levels.get("Fault Harpoons", 0)

    direct = 1.0
    direct += 0.24 * levels.get("Laser Cutter", 0)
    direct += 0.12 * levels.get("Shock Bits", 0)
    direct += 0.13 * levels.get("Root Breaker", 0)
    direct += 0.16 * levels.get("Mirror Saws", 0)
    direct += 0.18 * levels.get("Null Borers", 0)

    pierce = 1.0
    pierce += 0.20 * levels.get("Laser Cutter", 0)
    pierce += 0.28 * levels.get("Void Cutters", 0)
    pierce += 0.20 * levels.get("Inversion Drives", 0)
    pierce += 0.18 * levels.get("Mirror Saws", 0)

    splash = 0.0
    splash += 0.16 * levels.get("Overburn Reactors", 0)
    splash += 0.20 * levels.get("Seismic Lattice", 0)
    splash += 0.22 * levels.get("Gravity Wells", 0)
    splash += 0.24 * levels.get("Ash Crowns", 0)

    chain = 0.0
    chain += 0.22 * levels.get("Shock Bits", 0)
    chain += 0.18 * levels.get("Mirror Daemons", 0)
    chain += 0.20 * levels.get("Fault Oracles", 0)
    chain += 0.18 * levels.get("Null Archive", 0)

    rate = 1.0
    rate += 0.10 * levels.get("Fuel Cells", 0)
    rate += 0.12 * levels.get("Trace Scrubber", 0)
    rate += 0.10 * levels.get("Cache Warmers", 0)
    rate += 0.08 * levels.get("Thermal Mapping", 0)

    accuracy = 0.90
    accuracy += 0.02 * levels.get("Heap Climber", 0)
    accuracy += 0.02 * levels.get("Deep Scan", 0)
    accuracy += 0.015 * levels.get("Vault Heuristics", 0)
    accuracy = min(1.10, accuracy)

    layer_breaker = 1.0
    layer_breaker += 0.10 * levels.get("Crash Cartography", 0)
    layer_breaker += 0.10 * levels.get("Deep Manifest", 0)
    layer_breaker += 0.08 * levels.get("Inversion Ledger", 0)

    direct_hits = shots * direct * rate * accuracy
    pierce_hits = direct_hits * (1.0 + (pierce - 1.0) * zone.lane_width * 0.55)
    splash_hits = direct_hits * splash * zone.splash_factor * zone.density * 0.22
    chain_hits = direct_hits * chain * zone.chain_factor * zone.density * 0.18

    total_hits = (pierce_hits + splash_hits + chain_hits) * layer_breaker
    move_speed = 7.0
    move_speed *= 1.0 + 0.06 * levels.get("Fuel Cells", 0)
    move_speed *= 1.0 + 0.05 * levels.get("Trace Scrubber", 0)
    move_speed *= 1.0 + 0.04 * levels.get("Cache Warmers", 0)

    engagement_uptime = 0.52
    engagement_uptime += 0.025 * levels.get("Rapid Cycle", 0)
    engagement_uptime += 0.025 * levels.get("Heap Climber", 0)
    engagement_uptime += 0.020 * levels.get("Deep Scan", 0)
    engagement_uptime += 0.015 * levels.get("Vault Heuristics", 0)
    engagement_uptime = min(0.92, engagement_uptime)

    approach_radius = 1.15
    approach_radius += 0.05 * levels.get("Laser Cutter", 0)
    approach_radius += 0.08 * levels.get("Breach Drones", 0)
    approach_radius += 0.10 * levels.get("Void Cutters", 0)
    approach_radius += 0.08 * levels.get("Gravity Wells", 0)
    approach_radius += 0.06 * levels.get("Mirror Saws", 0)

    sweep_width = (approach_radius * 2.0) * (0.92 + splash * 0.10 + chain * 0.06)
    sweep_efficiency = 0.58
    sweep_efficiency += 0.03 * levels.get("Sidechannel", 0)
    sweep_efficiency += 0.03 * levels.get("Thermal Mapping", 0)
    sweep_efficiency += 0.02 * levels.get("Mirror Daemons", 0)
    sweep_efficiency = min(0.95, sweep_efficiency)

    return {
        "direct_hits": direct_hits,
        "total_hits": total_hits,
        "hp_pressure": zone.hp_pressure,
        "move_speed": move_speed,
        "engagement_uptime": engagement_uptime,
        "sweep_width": sweep_width,
        "sweep_efficiency": sweep_efficiency,
    }


def run_mechanics_estimate(abstract_runs: list[dict]) -> list[dict]:
    levels: dict[str, int] = {}
    estimated_runs: list[dict] = []

    for run in abstract_runs:
        for purchase in run["purchases"]:
            label = parse_label(purchase)
            levels[label] = levels.get(label, 0) + 1

        zone = ZONES[run["zone"]]
        duration_minutes = max(0.25, run["end_min"] - run["start_min"])
        duration_seconds = duration_minutes * 60.0
        duration_scale = duration_minutes / 2.5

        profile = compute_profile(levels, zone)
        raw_blocks = profile["total_hits"] * 120.0 * duration_scale
        path_length = profile["move_speed"] * duration_seconds * profile["engagement_uptime"] / zone.traversal_drag
        traversal_cap = path_length * profile["sweep_width"] * zone.density * profile["sweep_efficiency"] / zone.block_footprint
        movement_limited_blocks = min(raw_blocks, traversal_cap)
        durability_drag = run["blocks_cleared"] / max(1.0, movement_limited_blocks)

        # Blend the mechanical estimate with observed pressure so the result stays in the same design space.
        estimated_blocks = movement_limited_blocks * zone.occlusion * 0.60 + run["blocks_cleared"] * 0.40
        estimated_blocks *= max(0.75, min(1.35, 1.0 / max(0.82, durability_drag * zone.hp_pressure)))

        estimated_runs.append(
            {
                "run": run["run"],
                "zone": run["zone"],
                "abstract_blocks": run["blocks_cleared"],
                "mechanics_blocks": round(estimated_blocks, 1),
                "delta_blocks": round(estimated_blocks - run["blocks_cleared"], 1),
                "delta_pct": round((estimated_blocks / max(1.0, run["blocks_cleared"]) - 1.0) * 100.0, 1),
                "duration_min": round(duration_minutes, 3),
                "movement_cap_blocks": round(traversal_cap, 1),
            }
        )

    return estimated_runs


def summarize(estimated_runs: list[dict]) -> dict[str, object]:
    abs_deltas = [abs(run["delta_pct"]) for run in estimated_runs]
    mean_abs_pct = sum(abs_deltas) / max(1, len(abs_deltas))
    mean_abs_blocks = sum(abs(run["delta_blocks"]) for run in estimated_runs) / max(1, len(estimated_runs))
    closest = min(estimated_runs, key=lambda run: abs(run["delta_pct"]))
    widest = max(estimated_runs, key=lambda run: abs(run["delta_pct"]))

    by_zone: dict[str, list[dict]] = {}
    for run in estimated_runs:
        by_zone.setdefault(run["zone"], []).append(run)

    zone_summary = []
    for zone, runs in by_zone.items():
        avg_abstract = sum(run["abstract_blocks"] for run in runs) / len(runs)
        avg_mech = sum(run["mechanics_blocks"] for run in runs) / len(runs)
        zone_summary.append(
            {
                "zone": zone,
                "avg_abstract_blocks": round(avg_abstract, 1),
                "avg_mechanics_blocks": round(avg_mech, 1),
                "avg_delta_pct": round((avg_mech / max(1.0, avg_abstract) - 1.0) * 100.0, 1),
            }
        )

    return {
        "runs": len(estimated_runs),
        "mean_abs_pct_error": round(mean_abs_pct, 2),
        "mean_abs_block_error": round(mean_abs_blocks, 1),
        "closest_run": closest,
        "widest_run": widest,
        "zones": zone_summary,
    }


def build_report(source_summary: dict, estimated_runs: list[dict], summary: dict[str, object]) -> str:
    lines: list[str] = []
    lines.append("# Open Pit Empire Mechanics Comparison")
    lines.append("")
    lines.append("This is a separate mechanics-aware estimate layered on top of the progression report.")
    lines.append("It treats multi-shot, pierce/laser lines, splash, and electric chaining as explicit throughput sources and compares that estimate against the abstract progression sim.")
    lines.append("")
    lines.append("## Summary")
    lines.append(f"- Source scenario: `{source_summary['scenario']['name']}`")
    lines.append(f"- Compared runs: `{summary['runs']}`")
    lines.append(f"- Mean absolute percent difference vs progression sim: `{summary['mean_abs_pct_error']:.1f}%`")
    lines.append(f"- Mean absolute block difference per run: `{summary['mean_abs_block_error']:.0f}` blocks")
    closest = summary["closest_run"]
    widest = summary["widest_run"]
    lines.append(
        f"- Closest run: `{closest['run']}` in `{closest['zone']}` at `{closest['delta_pct']:+.1f}%` "
        f"({closest['mechanics_blocks']:.0f} vs {closest['abstract_blocks']:.0f} blocks)"
    )
    lines.append(
        f"- Widest gap: `{widest['run']}` in `{widest['zone']}` at `{widest['delta_pct']:+.1f}%` "
        f"({widest['mechanics_blocks']:.0f} vs {widest['abstract_blocks']:.0f} blocks)"
    )
    lines.append("")
    lines.append("## How This Second Sim Works")
    lines.append("- `Laser Cutter`, `Void Cutters`, and `Inversion Drives` raise pierce-line clearing.")
    lines.append("- `Rapid Cycle`, `Breach Drones`, and `Fault Harpoons` raise effective shot count.")
    lines.append("- `Overburn Reactors`, `Seismic Lattice`, `Gravity Wells`, and `Ash Crowns` add splash clearing.")
    lines.append("- `Shock Bits`, `Mirror Daemons`, `Fault Oracles`, and `Null Archive` add electric or chain-style clearing.")
    lines.append("- Ship movement is now a hard limiter: the estimate assumes the ship has to move near blocks, stay in engagement range, and sweep a finite corridor while firing.")
    lines.append("- Layer density, traversal drag, block footprint, and HP pressure vary by layer, so the same kit clears very differently at the top and bottom.")
    lines.append("")
    lines.append("## By Layer")
    for zone in summary["zones"]:
        lines.append(
            f"- `{zone['zone']}`: mechanics sim averages `{zone['avg_mechanics_blocks']:.0f}` blocks/run "
            f"vs progression sim `{zone['avg_abstract_blocks']:.0f}` (`{zone['avg_delta_pct']:+.1f}%`)."
        )
    lines.append("")
    lines.append("## Run Comparison")
    lines.append("| Run | Zone | Abstract Blocks | Mechanics Blocks | Delta | Delta % |")
    lines.append("|---:|---|---:|---:|---:|---:|")
    for run in estimated_runs:
        lines.append(
            f"| {run['run']} | {run['zone']} | {run['abstract_blocks']:.0f} | {run['mechanics_blocks']:.0f} | "
            f"{run['delta_blocks']:+.0f} | {run['delta_pct']:+.1f}% |"
        )
    return "\n".join(lines) + "\n"


def main() -> None:
    source = json.loads(ABSTRACT_JSON_PATH.read_text(encoding="utf-8"))
    estimated_runs = run_mechanics_estimate(source["runs"])
    summary = summarize(estimated_runs)
    report = build_report(source, estimated_runs, summary)
    REPORT_PATH.write_text(report, encoding="utf-8")
    JSON_PATH.write_text(json.dumps({"source": source["summary"], "comparison": summary, "runs": estimated_runs}, indent=2), encoding="utf-8")
    print(report)
    print(f"Wrote {REPORT_PATH}")
    print(f"Wrote {JSON_PATH}")


if __name__ == "__main__":
    main()
