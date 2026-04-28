from __future__ import annotations

from dataclasses import dataclass, field
from pathlib import Path
import json
import math


ROOT = Path(__file__).resolve().parent
REPORT_PATH = ROOT / "open_pit_empire_funnel_report.md"
JSON_PATH = ROOT / "open_pit_empire_funnel_report.json"
DEMO_REPORT_PATH = ROOT / "open_pit_empire_demo_report.md"
DEMO_JSON_PATH = ROOT / "open_pit_empire_demo_report.json"
FIRST_FUNNEL_ZONES = 5
CLEAR_REWARD_THRESHOLDS = (0.25, 0.50, 0.75)


@dataclass(frozen=True)
class Zone:
    id: str
    label: str
    block_hp: float
    block_value: float
    xp_per_block: float
    total_blocks: float
    core_hp: float
    core_reward: int
    expose_at: float
    hazard: float
    global_gate: float


@dataclass(frozen=True)
class Upgrade:
    id: str
    label: str
    currency: str
    base_cost: float
    cost_mult: float
    max_level: int = 1
    stage: int = 0
    category: str = ""
    requires: tuple[str, int] | None = None


@dataclass
class RunLog:
    run: int
    zone: str
    start_min: float
    end_min: float
    survived: bool
    barriers_taken: float
    barriers_available: int
    blocks_cleared: float
    run_seconds: float
    cargo_capacity: float
    cargo_collected: float
    cargo_fill_seconds: float | None
    cargo_fill_fuel_ratio: float | None
    cargo_collection_efficiency: float
    zone_clear_before: float
    zone_clear_after: float
    core_damage: float
    core_destroyed: bool
    money_earned: int
    xp_earned: int
    core_earned: int
    salvage_ratio: float
    purchases: list[str]
    wallets_after: dict[str, int]
    mastery_note: str


@dataclass(frozen=True)
class CargoEstimate:
    capacity: float
    collected: float
    fill_seconds: float | None
    fill_fuel_ratio: float | None
    collection_efficiency: float


@dataclass
class State:
    money: float = 0.0
    xp: float = 0.0
    cores: float = 0.0
    elapsed: float = 0.0
    run_index: int = 0
    current_zone: int = 0
    current_power: list[float] = field(default_factory=list)
    core_hp_remaining: list[float] = field(default_factory=list)
    upgrades: dict[str, int] = field(default_factory=dict)
    logs: list[RunLog] = field(default_factory=list)
    milestones: dict[str, float] = field(default_factory=dict)
    demo_gate_zone: int = 4
    demo_gate_clear: float = 0.58
    economy: dict[str, float] = field(default_factory=dict)
    demo_mode: bool = False


ZONES = [
    Zone("proxy", "Proxy Cache", 18.0, 10.0, 1.2, 3000.0, 1600.0, 2, 0.34, 0.96, 0.00),
    Zone("cipher", "Cipher Depths", 52.0, 28.0, 1.8, 5200.0, 5200.0, 2, 0.36, 1.00, 0.12),
    Zone("ghost", "Ghost Sector", 152.0, 74.0, 2.8, 8200.0, 18000.0, 3, 0.40, 1.14, 0.32),
    Zone("mantle", "Kernel Vault", 290.0, 155.0, 3.4, 12000.0, 76000.0, 3, 0.44, 1.30, 0.54),
    Zone("root", "Root Well", 650.0, 235.0, 4.2, 20000.0, 360000.0, 4, 0.48, 1.78, 0.82),
    Zone("mirror_shelf", "Mirror Shelf", 3200.0, 440.0, 5.4, 60000.0, 3200000.0, 2, 0.42, 2.44, 1.76),
    Zone("reverse_fault", "Reverse Fault", 4600.0, 550.0, 6.1, 76000.0, 5600000.0, 2, 0.44, 2.66, 2.08),
    Zone("null_vein", "Null Vein", 6200.0, 680.0, 6.8, 95000.0, 9000000.0, 3, 0.46, 2.92, 2.42),
    Zone("grave_mantle", "Grave Mantle", 8600.0, 840.0, 7.6, 120000.0, 13800000.0, 3, 0.48, 3.18, 2.82),
    Zone("crown_of_ash", "Crown of Ash", 11800.0, 1060.0, 8.5, 160000.0, 22000000.0, 4, 0.50, 3.42, 3.28),
]

UPGRADES = [
    Upgrade("laser_cutter", "Laser Cutter", "money", 60, 1.55, 8, 0, "power"),
    Upgrade("rapid_cycle", "Rapid Cycle", "money", 70, 1.58, 7, 0, "rate"),
    Upgrade("cargo_racks", "Cargo Racks", "money", 65, 1.52, 7, 0, "cargo"),
    Upgrade("fuel_cells", "Fuel Cells", "money", 60, 1.55, 6, 0, "time"),
    Upgrade("ore_appraisal", "Ore Appraisal", "money", 80, 1.60, 6, 0, "value"),
    Upgrade("barrier_mesh", "Barrier Mesh", "money", 140, 1.90, 3, 1, "barrier"),
    Upgrade("shock_bits", "Shock Bits", "money", 190, 1.75, 4, 1, "power"),
    Upgrade("breach_drones", "Breach Drones", "money", 260, 1.80, 4, 1, "power"),
    Upgrade("salvage_contract", "Salvage Contract", "money", 220, 1.75, 4, 1, "salvage"),
    Upgrade("funnel_resonance", "Funnel Resonance", "money", 420, 1.90, 4, 2, "deep"),
    Upgrade("daemon_lances", "Daemon Lances", "money", 520, 1.85, 4, 2, "core"),
    Upgrade("root_breaker", "Root Breaker", "money", 980, 2.00, 3, 3, "inversion"),
    Upgrade("overburn_reactors", "Overburn Reactors", "money", 1800, 1.85, 4, 3, "power"),
    Upgrade("seismic_lattice", "Seismic Lattice", "money", 2600, 1.85, 4, 3, "deep"),
    Upgrade("void_cutters", "Void Cutters", "money", 4200, 1.95, 5, 4, "inversion"),
    Upgrade("inversion_drives", "Inversion Drives", "money", 5800, 1.90, 4, 4, "inversion"),
    Upgrade("mantle_drills", "Mantle Drills", "money", 9000, 1.92, 4, 3, "power"),
    Upgrade("fault_charges", "Fault Charges", "money", 11000, 1.95, 4, 3, "core"),
    Upgrade("vault_pulsers", "Vault Pulsers", "money", 18000, 1.95, 5, 4, "inversion"),
    Upgrade("gravity_wells", "Gravity Wells", "money", 26000, 1.90, 4, 4, "inversion"),
    Upgrade("abyssal_rigs", "Abyssal Rigs", "money", 42000, 1.92, 5, 4, "inversion"),
    Upgrade("mirror_saws", "Mirror Saws", "money", 62000, 1.94, 4, 5, "ng_plus"),
    Upgrade("fault_harpoons", "Fault Harpoons", "money", 92000, 1.95, 4, 6, "ng_plus"),
    Upgrade("null_borers", "Null Borers", "money", 138000, 1.96, 4, 7, "ng_plus"),
    Upgrade("ash_crowns", "Ash Crowns", "money", 220000, 1.98, 5, 8, "ng_plus"),
    Upgrade("packet_sniffer", "Packet Sniffer", "xp", 24, 1.75, 4, 0, "xp"),
    Upgrade("cache_warmers", "Cache Warmers", "xp", 34, 1.75, 4, 0, "efficiency"),
    Upgrade("trace_scrubber", "Trace Scrubber", "xp", 36, 1.75, 4, 0, "time"),
    Upgrade("heap_climber", "Heap Climber", "xp", 42, 1.80, 4, 0, "cargo"),
    Upgrade("deep_scan", "Deep Scan", "xp", 54, 1.85, 4, 1, "efficiency"),
    Upgrade("sidechannel", "Sidechannel", "xp", 70, 1.90, 4, 1, "value"),
    Upgrade("zero_day", "Zero-Day", "xp", 120, 2.00, 3, 2, "xp"),
    Upgrade("crash_cartography", "Crash Cartography", "xp", 150, 2.00, 3, 2, "mastery"),
    Upgrade("kernel_rehearsal", "Kernel Rehearsal", "xp", 180, 2.05, 3, 3, "core"),
    Upgrade("deep_manifest", "Deep Manifest", "xp", 260, 2.00, 4, 3, "deep"),
    Upgrade("vault_heuristics", "Vault Heuristics", "xp", 340, 2.05, 4, 4, "inversion"),
    Upgrade("thermal_mapping", "Thermal Mapping", "xp", 520, 2.05, 4, 3, "deep"),
    Upgrade("graveyard_index", "Graveyard Index", "xp", 750, 2.05, 4, 4, "inversion"),
    Upgrade("mirror_daemons", "Mirror Daemons", "xp", 1100, 2.10, 4, 4, "inversion"),
    Upgrade("inversion_ledger", "Inversion Ledger", "xp", 1850, 2.10, 4, 5, "ng_plus"),
    Upgrade("fault_oracles", "Fault Oracles", "xp", 2800, 2.12, 4, 6, "ng_plus"),
    Upgrade("null_archive", "Null Archive", "xp", 4300, 2.12, 4, 7, "ng_plus"),
    Upgrade("ash_scriptures", "Ash Scriptures", "xp", 6800, 2.14, 4, 8, "ng_plus"),
    Upgrade("signal_sniffer", "Signal Sniffer", "core", 1, 1.0, 1, 0, "core"),
    Upgrade("ghost_entry", "Ghost Entry", "core", 1, 1.0, 1, 0, "efficiency"),
    Upgrade("barrier_patch", "Barrier Patch", "core", 2, 1.0, 1, 1, "barrier"),
    Upgrade("backdoor_exit", "Backdoor Exit", "core", 2, 1.0, 1, 1, "value"),
    Upgrade("panic_tunnel", "Panic Tunnel", "core", 2, 1.0, 1, 1, "salvage"),
    Upgrade("daemon_focus", "Daemon Focus", "core", 3, 1.0, 1, 2, "core"),
    Upgrade("kernel_breach", "Kernel Breach", "core", 3, 1.0, 1, 2, "unlock"),
    Upgrade("pressure_vent", "Pressure Vent", "core", 3, 1.0, 1, 2, "defense"),
    Upgrade("core_siphon", "Core Siphon", "core", 4, 1.0, 1, 3, "core"),
    Upgrade("root_access", "Root Access", "core", 4, 1.0, 1, 3, "unlock"),
    Upgrade("salvage_limiter", "Salvage Limiter", "core", 5, 1.0, 1, 3, "salvage"),
    Upgrade("inversion_tether", "Inversion Tether", "core", 6, 1.0, 1, 4, "inversion"),
    Upgrade("mantle_permits", "Mantle Permits", "core", 7, 1.0, 1, 3, "deep"),
    Upgrade("voidfire_brakes", "Voidfire Brakes", "core", 8, 1.0, 1, 4, "inversion"),
    Upgrade("mirror_keys", "Mirror Keys", "core", 9, 1.0, 1, 5, "ng_plus"),
    Upgrade("fault_insulation", "Fault Insulation", "core", 10, 1.0, 1, 6, "ng_plus"),
    Upgrade("null_anchor", "Null Anchor", "core", 12, 1.0, 1, 7, "ng_plus"),
    Upgrade("ash_ward", "Ash Ward", "core", 14, 1.0, 1, 8, "ng_plus"),
    Upgrade("demo_lock_override", "Demo Lock Override", "core", 99, 1.0, 1, 4, "hidden"),
]

UPGRADE_MAP = {upgrade.id: upgrade for upgrade in UPGRADES}

MONEY_PRIORITY = [
    "laser_cutter",
    "cargo_racks",
    "fuel_cells",
    "rapid_cycle",
    "ore_appraisal",
    "barrier_mesh",
    "shock_bits",
    "breach_drones",
    "salvage_contract",
    "funnel_resonance",
    "daemon_lances",
    "root_breaker",
    "overburn_reactors",
    "seismic_lattice",
    "mantle_drills",
    "fault_charges",
    "void_cutters",
    "inversion_drives",
    "vault_pulsers",
    "gravity_wells",
    "abyssal_rigs",
    "mirror_saws",
    "fault_harpoons",
    "null_borers",
    "ash_crowns",
]
XP_PRIORITY = [
    "packet_sniffer",
    "trace_scrubber",
    "heap_climber",
    "cache_warmers",
    "deep_scan",
    "sidechannel",
    "zero_day",
    "crash_cartography",
    "kernel_rehearsal",
    "deep_manifest",
    "thermal_mapping",
    "vault_heuristics",
    "graveyard_index",
    "mirror_daemons",
    "inversion_ledger",
    "fault_oracles",
    "null_archive",
    "ash_scriptures",
]
CORE_PRIORITY = [
    "signal_sniffer",
    "ghost_entry",
    "barrier_patch",
    "backdoor_exit",
    "panic_tunnel",
    "daemon_focus",
    "kernel_breach",
    "pressure_vent",
    "core_siphon",
    "root_access",
    "salvage_limiter",
    "mantle_permits",
    "inversion_tether",
    "voidfire_brakes",
    "mirror_keys",
    "fault_insulation",
    "null_anchor",
    "ash_ward",
    "demo_lock_override",
]


SCENARIOS = [
    {"name": "baseline", "power_scale": 1.00, "economy_scale": 1.00, "hazard_scale": 1.00, "mastery_scale": 1.00, "xp_scale": 1.00, "money_cost_scale": 1.00, "xp_cost_scale": 1.00, "core_cost_scale": 1.00, "late_cost_scale": 1.00, "end_cost_scale": 1.00},
    {"name": "faster_power", "power_scale": 1.07, "economy_scale": 0.98, "hazard_scale": 1.00, "mastery_scale": 1.05, "xp_scale": 1.00, "money_cost_scale": 1.00, "xp_cost_scale": 1.00, "core_cost_scale": 1.00, "late_cost_scale": 1.06, "end_cost_scale": 1.10},
    {"name": "safer_midgame", "power_scale": 1.02, "economy_scale": 1.00, "hazard_scale": 0.93, "mastery_scale": 1.02, "xp_scale": 1.00, "money_cost_scale": 1.02, "xp_cost_scale": 1.02, "core_cost_scale": 1.00, "late_cost_scale": 1.08, "end_cost_scale": 1.12},
    {"name": "deeper_demo", "power_scale": 1.03, "economy_scale": 1.05, "hazard_scale": 0.96, "mastery_scale": 1.08, "xp_scale": 1.05, "money_cost_scale": 1.08, "xp_cost_scale": 1.08, "core_cost_scale": 1.00, "late_cost_scale": 1.16, "end_cost_scale": 1.24},
    {"name": "two_hour_target", "power_scale": 1.05, "economy_scale": 1.04, "hazard_scale": 0.95, "mastery_scale": 1.10, "xp_scale": 1.02, "money_cost_scale": 1.10, "xp_cost_scale": 1.12, "core_cost_scale": 1.00, "late_cost_scale": 1.22, "end_cost_scale": 1.38},
    {"name": "expensive_late", "power_scale": 1.07, "economy_scale": 1.02, "hazard_scale": 0.95, "mastery_scale": 1.10, "xp_scale": 0.98, "money_cost_scale": 1.14, "xp_cost_scale": 1.12, "core_cost_scale": 1.00, "late_cost_scale": 1.34, "end_cost_scale": 1.62},
    {"name": "xp_tighter", "power_scale": 1.06, "economy_scale": 1.03, "hazard_scale": 0.95, "mastery_scale": 1.10, "xp_scale": 0.90, "money_cost_scale": 1.08, "xp_cost_scale": 1.22, "core_cost_scale": 1.00, "late_cost_scale": 1.26, "end_cost_scale": 1.48},
    {"name": "price_heavy", "power_scale": 1.08, "economy_scale": 1.00, "hazard_scale": 0.94, "mastery_scale": 1.10, "xp_scale": 0.96, "money_cost_scale": 1.18, "xp_cost_scale": 1.18, "core_cost_scale": 1.05, "late_cost_scale": 1.40, "end_cost_scale": 1.70},
    {"name": "price_heavy_2", "power_scale": 1.09, "economy_scale": 0.99, "hazard_scale": 0.95, "mastery_scale": 1.10, "xp_scale": 0.92, "money_cost_scale": 1.24, "xp_cost_scale": 1.24, "core_cost_scale": 1.08, "late_cost_scale": 1.52, "end_cost_scale": 1.92},
    {"name": "price_heavy_3", "power_scale": 1.10, "economy_scale": 0.97, "hazard_scale": 0.96, "mastery_scale": 1.09, "xp_scale": 0.88, "money_cost_scale": 1.30, "xp_cost_scale": 1.30, "core_cost_scale": 1.10, "late_cost_scale": 1.66, "end_cost_scale": 2.10},
    {"name": "xp_starved", "power_scale": 1.08, "economy_scale": 1.00, "hazard_scale": 0.95, "mastery_scale": 1.08, "xp_scale": 0.82, "money_cost_scale": 1.18, "xp_cost_scale": 1.38, "core_cost_scale": 1.05, "late_cost_scale": 1.48, "end_cost_scale": 1.82},
    {"name": "slow_shop", "power_scale": 1.06, "economy_scale": 0.96, "hazard_scale": 0.95, "mastery_scale": 1.08, "xp_scale": 0.88, "money_cost_scale": 1.28, "xp_cost_scale": 1.34, "core_cost_scale": 1.08, "late_cost_scale": 1.58, "end_cost_scale": 2.00},
    {"name": "very_expensive", "power_scale": 1.08, "economy_scale": 0.92, "hazard_scale": 0.95, "mastery_scale": 1.08, "xp_scale": 0.78, "money_cost_scale": 1.42, "xp_cost_scale": 1.48, "core_cost_scale": 1.12, "late_cost_scale": 1.85, "end_cost_scale": 2.35},
    {"name": "very_expensive_2", "power_scale": 1.10, "economy_scale": 0.90, "hazard_scale": 0.96, "mastery_scale": 1.08, "xp_scale": 0.72, "money_cost_scale": 1.55, "xp_cost_scale": 1.62, "core_cost_scale": 1.16, "late_cost_scale": 2.05, "end_cost_scale": 2.75},
    {"name": "very_expensive_3", "power_scale": 1.12, "economy_scale": 0.88, "hazard_scale": 0.96, "mastery_scale": 1.07, "xp_scale": 0.68, "money_cost_scale": 1.70, "xp_cost_scale": 1.78, "core_cost_scale": 1.20, "late_cost_scale": 2.30, "end_cost_scale": 3.10},
    {"name": "ultra_expensive", "power_scale": 1.14, "economy_scale": 0.84, "hazard_scale": 0.97, "mastery_scale": 1.06, "xp_scale": 0.62, "money_cost_scale": 2.00, "xp_cost_scale": 2.10, "core_cost_scale": 1.28, "late_cost_scale": 2.80, "end_cost_scale": 3.80},
    {"name": "ultra_expensive_2", "power_scale": 1.16, "economy_scale": 0.82, "hazard_scale": 0.98, "mastery_scale": 1.05, "xp_scale": 0.56, "money_cost_scale": 2.30, "xp_cost_scale": 2.40, "core_cost_scale": 1.35, "late_cost_scale": 3.20, "end_cost_scale": 4.40},
]


def current_level(state: State, upgrade_id: str) -> int:
    return state.upgrades.get(upgrade_id, 0)


def upgrade_cost(state: State, upgrade_id: str) -> int:
    upgrade = UPGRADE_MAP[upgrade_id]
    level = current_level(state, upgrade_id)
    cost = upgrade.base_cost * (upgrade.cost_mult ** level)
    currency_scale = {
        "money": float(state.economy.get("money_cost_scale", 1.0)),
        "xp": float(state.economy.get("xp_cost_scale", 1.0)) * 1.85,
        "core": float(state.economy.get("core_cost_scale", 1.0)),
    }[upgrade.currency]
    late_scale = 1.0
    if upgrade.stage >= 3:
        late_scale *= float(state.economy.get("late_cost_scale", 1.0))
    if upgrade.stage >= 4:
        late_scale *= float(state.economy.get("end_cost_scale", 1.0))
    return int(round(cost * currency_scale * late_scale))


def can_buy(state: State, upgrade_id: str) -> bool:
    upgrade = UPGRADE_MAP[upgrade_id]
    level = current_level(state, upgrade_id)
    if level >= upgrade.max_level:
        return False
    if upgrade.stage > state.current_zone:
        return False
    if upgrade.requires is not None:
        req_id, req_level = upgrade.requires
        if current_level(state, req_id) < req_level:
            return False
    currency_amount = {"money": state.money, "xp": state.xp, "core": state.cores}[upgrade.currency]
    return currency_amount >= upgrade_cost(state, upgrade_id)


def is_demo_hidden_upgrade(upgrade_id: str) -> bool:
    if upgrade_id == "kernel_breach":
        return True
    upgrade = UPGRADE_MAP[upgrade_id]
    return upgrade.stage >= 3


def can_enter_zone(state: State, zone_index: int) -> bool:
    if zone_index != 3:
        return True
    return current_level(state, "kernel_breach") > 0


def buy_upgrade(state: State, upgrade_id: str) -> str:
    upgrade = UPGRADE_MAP[upgrade_id]
    cost = upgrade_cost(state, upgrade_id)
    if upgrade.currency == "money":
        state.money -= cost
    elif upgrade.currency == "xp":
        state.xp -= cost
    else:
        state.cores -= cost
    state.upgrades[upgrade_id] = current_level(state, upgrade_id) + 1
    return f"{upgrade.label} {state.upgrades[upgrade_id]}"


def stage_progress(state: State) -> float:
    completed = 0.0
    for zone_index, power in enumerate(state.current_power):
        if power >= 1.0:
            completed += 1.0
        elif zone_index == state.current_zone:
            completed += power
            break
        else:
            break
    return completed / len(ZONES)


def first_funnel_progress(state: State) -> float:
    total = FIRST_FUNNEL_ZONES
    completed = 0.0
    for zone_index in range(total):
        power = state.current_power[zone_index]
        if power >= 1.0:
            completed += 1.0
            continue
        if zone_index == state.current_zone:
            completed += power
        break
    if state.current_zone >= total:
        return 1.0
    return completed / total


def progress_at_minutes(state: State, minute_mark: float, first_only: bool) -> float:
    target = minute_mark
    completed_by_zone = [0.0 for _ in ZONES]
    for log in state.logs:
        if target > log.end_min:
            zone_index = next(index for index, zone in enumerate(ZONES) if zone.label == log.zone)
            completed_by_zone[zone_index] = 1.0 if log.core_destroyed else max(completed_by_zone[zone_index], log.zone_clear_after / 100.0)
            continue
        span = max(0.01, log.end_min - log.start_min)
        ratio = max(0.0, min(1.0, (target - log.start_min) / span))
        zone_index = next(index for index, zone in enumerate(ZONES) if zone.label == log.zone)
        current = log.zone_clear_before / 100.0 + (log.zone_clear_after - log.zone_clear_before) / 100.0 * ratio
        if log.core_destroyed and ratio >= 0.9:
            current = 1.0
        completed_by_zone[zone_index] = max(completed_by_zone[zone_index], current)
        break

    if first_only:
        completed = 0.0
        for zone_index in range(FIRST_FUNNEL_ZONES):
            progress = completed_by_zone[zone_index]
            if progress >= 1.0:
                completed += 1.0
            else:
                completed += progress
                break
        return completed / FIRST_FUNNEL_ZONES

    completed = 0.0
    for zone_index in range(len(ZONES)):
        progress = completed_by_zone[zone_index]
        if progress >= 1.0:
            completed += 1.0
        else:
            completed += progress
            break
    return completed / len(ZONES)


def global_clear_ratio(state: State) -> float:
    total_blocks = sum(zone.total_blocks for zone in ZONES[:FIRST_FUNNEL_ZONES])
    if total_blocks <= 0.0:
        return 0.0
    cleared_blocks = 0.0
    for zone_index, zone in enumerate(ZONES[:FIRST_FUNNEL_ZONES]):
        cleared_blocks += zone.total_blocks * max(0.0, min(1.0, state.current_power[zone_index]))
    return max(0.0, min(1.0, cleared_blocks / total_blocks))


def global_clear_reward_count_from_ratio(clear_ratio: float) -> int:
    count = 0
    for threshold in CLEAR_REWARD_THRESHOLDS:
        if clear_ratio >= threshold:
            count += 1
    return count


def global_clear_reward_count(state: State) -> int:
    return global_clear_reward_count_from_ratio(global_clear_ratio(state))


def global_clear_reward_multiplier(clear_ratio: float) -> float:
    return 1.5 ** global_clear_reward_count_from_ratio(clear_ratio)


def mastery_tier(state: State) -> tuple[float, str]:
    clear_ratio = global_clear_ratio(state)
    reward_count = global_clear_reward_count_from_ratio(clear_ratio)
    reward_labels = {
        0: "no clear breach reward",
        1: "Clear Breach I active",
        2: "Clear Breach II active",
        3: "Clear Breach III active",
    }
    return global_clear_reward_multiplier(clear_ratio), reward_labels.get(reward_count, "Clear Breach III active")


def base_run_time(state: State) -> float:
    seconds = 56.0
    seconds += 8.0 * current_level(state, "fuel_cells")
    seconds += 6.0 * current_level(state, "trace_scrubber")
    seconds += 2.5 * current_level(state, "cache_warmers")
    return seconds


def barrier_count(state: State) -> int:
    barriers = 1
    barriers += current_level(state, "barrier_mesh")
    if current_level(state, "barrier_patch") > 0:
        barriers += 1
    return barriers


def salvage_keep(state: State) -> float:
    keep = 0.08 * current_level(state, "salvage_contract")
    if current_level(state, "panic_tunnel") > 0:
        keep += 0.25
    if current_level(state, "salvage_limiter") > 0:
        keep += 0.25
    return min(1.0, keep)


def bank_fraction(state: State) -> float:
    fraction = 0.68
    fraction += 0.05 * current_level(state, "cargo_racks")
    fraction += 0.03 * current_level(state, "heap_climber")
    fraction += 0.06 * current_level(state, "backdoor_exit")
    return min(0.96, fraction)


def cargo_cap(state: State) -> float:
    cap = 380.0
    cap *= 1.0 + 0.18 * current_level(state, "cargo_racks")
    cap *= 1.0 + 0.12 * current_level(state, "heap_climber")
    return cap


def money_value_mult(state: State) -> float:
    mult = 1.0
    mult *= 1.0 + 0.12 * current_level(state, "ore_appraisal")
    mult *= 1.0 + 0.10 * current_level(state, "sidechannel")
    mult *= 1.0 + 0.08 * current_level(state, "deep_manifest")
    mult *= 1.0 + 0.10 * current_level(state, "graveyard_index")
    return mult


def xp_value_mult(state: State) -> float:
    mult = 1.0
    mult *= 1.0 + 0.28 * current_level(state, "packet_sniffer")
    mult *= 1.0 + 0.32 * current_level(state, "zero_day")
    mult *= 1.0 + 0.14 * current_level(state, "graveyard_index")
    mult *= 1.0 + 0.16 * current_level(state, "inversion_ledger")
    return mult


def efficiency_mult(state: State) -> float:
    mult = 1.0
    mult *= 1.0 + 0.11 * current_level(state, "cache_warmers")
    mult *= 1.0 + 0.11 * current_level(state, "deep_scan")
    mult *= 1.0 + 0.08 * current_level(state, "deep_manifest")
    mult *= 1.0 + 0.10 * current_level(state, "thermal_mapping")
    if current_level(state, "ghost_entry") > 0:
        mult *= 1.08
    if current_level(state, "mantle_permits") > 0:
        mult *= 1.12
    return mult


def global_power_mult(state: State, zone_index: int) -> float:
    breaker_count = float(global_clear_reward_count(state))
    mult = 1.0 + breaker_count * 0.10
    if zone_index >= 2:
        mult *= 1.0 + breaker_count * 0.025
    if zone_index >= 4:
        mult *= 1.0 + breaker_count * 0.03
    if zone_index >= FIRST_FUNNEL_ZONES:
        mult *= 1.0 + breaker_count * 0.02
    return mult


def mining_power(state: State, zone_index: int, scenario: dict[str, float]) -> float:
    mult = scenario["power_scale"]
    if zone_index < FIRST_FUNNEL_ZONES:
        mult *= 1.55
    else:
        mult *= 0.72
    mult *= global_power_mult(state, zone_index)
    mult *= 1.0 + 0.26 * current_level(state, "laser_cutter")
    mult *= 1.0 + 0.17 * current_level(state, "rapid_cycle")
    mult *= 1.0 + 0.12 * current_level(state, "shock_bits")
    mult *= 1.0 + 0.14 * current_level(state, "breach_drones")
    if zone_index >= 2:
        mult *= 1.0 + 0.12 * current_level(state, "funnel_resonance")
        mult *= 1.0 + 0.14 * current_level(state, "overburn_reactors")
        mult *= 1.0 + 0.18 * current_level(state, "seismic_lattice")
        mult *= 1.0 + 0.14 * current_level(state, "mantle_drills")
    if zone_index >= 4:
        mult *= 1.0 + 0.22 * current_level(state, "root_breaker")
        mult *= 1.0 + 0.18 * current_level(state, "void_cutters")
        mult *= 1.0 + 0.12 * current_level(state, "inversion_drives")
        mult *= 1.0 + 0.14 * current_level(state, "vault_heuristics")
        mult *= 1.0 + 0.12 * current_level(state, "vault_pulsers")
        mult *= 1.0 + 0.10 * current_level(state, "gravity_wells")
        mult *= 1.0 + 0.14 * current_level(state, "abyssal_rigs")
        mult *= 1.0 + 0.12 * current_level(state, "mirror_daemons")
    if zone_index >= 5:
        mult *= 1.0 + 0.16 * current_level(state, "mirror_saws")
        mult *= 1.0 + 0.14 * current_level(state, "inversion_ledger")
    if zone_index >= 6:
        mult *= 1.0 + 0.18 * current_level(state, "fault_harpoons")
        mult *= 1.0 + 0.14 * current_level(state, "fault_oracles")
    if zone_index >= 7:
        mult *= 1.0 + 0.20 * current_level(state, "null_borers")
        mult *= 1.0 + 0.16 * current_level(state, "null_archive")
    if zone_index >= 8:
        mult *= 1.0 + 0.22 * current_level(state, "ash_crowns")
        mult *= 1.0 + 0.16 * current_level(state, "ash_scriptures")
    return 28.0 * mult


def core_power(state: State, zone_index: int, scenario: dict[str, float]) -> float:
    mult = mining_power(state, zone_index, scenario)
    mult *= 1.0 + 0.28 * current_level(state, "daemon_lances")
    mult *= 1.0 + 0.24 * current_level(state, "kernel_rehearsal")
    mult *= 1.0 + 0.14 * current_level(state, "fault_charges")
    if current_level(state, "signal_sniffer") > 0:
        mult *= 1.10
    if current_level(state, "daemon_focus") > 0:
        mult *= 1.25
    if zone_index >= 5 and current_level(state, "inversion_tether") > 0:
        mult *= 1.15
    if zone_index >= 5 and current_level(state, "voidfire_brakes") > 0:
        mult *= 1.18
    if zone_index >= 5 and current_level(state, "mirror_keys") > 0:
        mult *= 1.12
    if zone_index >= 6 and current_level(state, "fault_insulation") > 0:
        mult *= 1.14
    if zone_index >= 7 and current_level(state, "null_anchor") > 0:
        mult *= 1.16
    if zone_index >= 8 and current_level(state, "ash_ward") > 0:
        mult *= 1.18
    if zone_index >= 5:
        mult *= 0.78
    return mult


def cargo_cap(state: State) -> float:
    cap = 320.0
    cap *= 1.0 + 0.16 * current_level(state, "cargo_racks")
    cap *= 1.0 + 0.10 * current_level(state, "heap_climber")
    cap *= 1.0 + 0.14 * current_level(state, "abyssal_rigs")
    return cap


def cargo_unit_cap(state: State) -> float:
    cap = 12.0
    cap += 4.0 * current_level(state, "cargo_racks")
    cap += 6.0 * current_level(state, "heap_climber")
    cap += 18.0 * current_level(state, "daemon_lances")
    cap += 20.0 * current_level(state, "root_breaker")
    cap += 22.0 * current_level(state, "overburn_reactors")
    cap += 26.0 * current_level(state, "seismic_lattice")
    cap += 28.0 * current_level(state, "mantle_drills")
    cap += 30.0 * current_level(state, "fault_charges")
    cap += 34.0 * current_level(state, "void_cutters")
    cap += 32.0 * current_level(state, "inversion_drives")
    cap += 45.0 * current_level(state, "vault_pulsers")
    cap += 55.0 * current_level(state, "gravity_wells")
    cap += 75.0 * current_level(state, "abyssal_rigs")
    cap += 90.0 * current_level(state, "mirror_saws")
    return cap


def live_attack_damage(state: State) -> float:
    damage = 11.0
    damage += 4.0 * current_level(state, "laser_cutter")
    damage += 5.0 * current_level(state, "shock_bits")
    damage += 10.0 * current_level(state, "daemon_lances")
    damage += 11.0 * current_level(state, "mantle_drills")
    damage += 9.0 * current_level(state, "fault_charges")
    damage += 9.0 * current_level(state, "void_cutters")
    damage += 7.0 * current_level(state, "vault_heuristics")
    damage += 15.0 * current_level(state, "mirror_saws")
    damage += 18.0 * current_level(state, "null_borers")
    if current_level(state, "mirror_keys") > 0:
        damage += 14.0
    damage *= 1.0 + 0.12 * current_level(state, "crash_cartography")
    damage *= 1.0 + 0.05 * current_level(state, "deep_manifest")
    if current_level(state, "mantle_permits") > 0:
        damage *= 1.12
    return damage


def live_attack_interval(state: State) -> float:
    return max(0.06, 0.8 - 0.05 * current_level(state, "rapid_cycle"))


def live_attack_radius(state: State) -> float:
    radius = 96.0
    radius += 14.0 * current_level(state, "deep_scan")
    radius += 10.0 * current_level(state, "mantle_drills")
    radius += 16.0 * current_level(state, "void_cutters")
    radius += 10.0 * current_level(state, "vault_heuristics")
    radius += 16.0 * current_level(state, "thermal_mapping")
    return radius


def live_pickup_radius(state: State) -> float:
    return 64.0 + 14.0 * current_level(state, "deep_scan")


def live_move_speed(state: State) -> float:
    speed = 580.0
    speed += 20.0 * current_level(state, "fuel_cells")
    speed += 30.0 * current_level(state, "cache_warmers")
    speed += 20.0 * current_level(state, "thermal_mapping")
    speed += 40.0 * current_level(state, "inversion_drives")
    if current_level(state, "pressure_vent") > 0:
        speed += 35.0
    if current_level(state, "voidfire_brakes") > 0:
        speed += 45.0
    return speed


def live_multi_target_count(state: State) -> int:
    targets = 1
    targets += current_level(state, "null_borers")
    if current_level(state, "null_anchor") > 0:
        targets += 1
    return max(1, targets)


def live_drone_count(state: State) -> int:
    level = current_level(state, "breach_drones")
    return 1 + level if level > 0 else 0


def live_assist_multiplier(state: State, zone_index: int) -> float:
    mult = 1.0
    if current_level(state, "shock_bits") > 0:
        mult += 0.04 * current_level(state, "shock_bits")
    if current_level(state, "seismic_lattice") > 0:
        mult += 0.08 * current_level(state, "seismic_lattice")
    if current_level(state, "overburn_reactors") > 0:
        mult += 0.05 * current_level(state, "overburn_reactors")
    if current_level(state, "fault_harpoons") > 0:
        mult += 0.07 * current_level(state, "fault_harpoons")
    if current_level(state, "null_archive") > 0:
        mult += 0.06 * current_level(state, "null_archive")
    if zone_index >= FIRST_FUNNEL_ZONES:
        mult *= 0.82
    return mult


def estimate_live_cargo_collection(
    state: State,
    zone_index: int,
    run_seconds: float,
    mining_time: float,
    blocks_destroyed: float,
    effective_block_hp: float,
) -> CargoEstimate:
    capacity = cargo_unit_cap(state)
    if blocks_destroyed <= 0.0 or mining_time <= 0.0:
        return CargoEstimate(capacity, 0.0, None, None, 0.0)

    move_speed = live_move_speed(state)
    attack_radius = live_attack_radius(state)
    pickup_radius = live_pickup_radius(state)
    attack_interval = live_attack_interval(state)
    damage = live_attack_damage(state)
    targets = live_multi_target_count(state)
    drones = live_drone_count(state)

    depth_drag = 1.0 + 0.09 * min(zone_index, 4) + (0.08 * max(0, zone_index - 4))
    travel_seconds = min(
        run_seconds * 0.42,
        8.0 + 2.6 * zone_index + (96.0 / max(attack_radius, 32.0)) * 4.0 + depth_drag * 2.0,
    )
    active_seconds = max(0.0, mining_time - travel_seconds)

    hits_to_break = max(1.0, math.ceil(effective_block_hp / max(1.0, damage)))
    range_uptime = max(0.35, min(0.92, 0.42 + attack_radius / 520.0 + move_speed / 5200.0))
    manual_pathing_uptime = max(0.32, min(0.88, range_uptime / depth_drag))
    attack_cycles = active_seconds * manual_pathing_uptime / max(0.06, attack_interval)
    primary_blocks = attack_cycles * float(targets) / hits_to_break

    drone_damage = 8.0 + 4.0 * current_level(state, "breach_drones")
    drone_hits_to_break = max(1.0, math.ceil(effective_block_hp / max(1.0, drone_damage)))
    drone_blocks = active_seconds * float(drones) / max(0.18, 0.9) / drone_hits_to_break

    live_destroyed_capacity = (primary_blocks + drone_blocks) * live_assist_multiplier(state, zone_index)
    live_destroyed_capacity *= 1.55
    destroyed_near_ship = min(blocks_destroyed, live_destroyed_capacity)

    pickup_vs_range = min(1.0, pickup_radius / max(attack_radius, 1.0))
    collection_efficiency = 0.28 + 0.46 * pickup_vs_range + 0.08 * min(1.0, move_speed / 900.0)
    collection_efficiency += 0.03 * min(4, drones)
    if current_level(state, "auto_salvage") > 0:
        collection_efficiency = 1.0
    collection_efficiency = max(0.30, min(1.0, collection_efficiency))

    collected = min(capacity, destroyed_near_ship * collection_efficiency)
    collection_rate = collected / max(0.001, active_seconds)
    if collection_rate <= 0.0 or capacity > collected:
        return CargoEstimate(capacity, collected, None, None, collection_efficiency)

    fill_seconds = travel_seconds + capacity / collection_rate
    if fill_seconds > run_seconds:
        return CargoEstimate(capacity, collected, None, None, collection_efficiency)
    return CargoEstimate(capacity, collected, fill_seconds, fill_seconds / run_seconds, collection_efficiency)


def zone_block_hp_multiplier(state: State, zone_index: int, clear_before: float) -> float:
    mult = 1.0
    progression_pressure = max(0.0, ZONES[zone_index].global_gate - float(global_clear_reward_count(state)) * 0.10)
    if progression_pressure > 0.0:
        mult *= 1.0 + progression_pressure
    if zone_index == 2:
        if clear_before >= 0.30:
            mult *= 1.20
        if clear_before >= 0.55:
            mult *= 1.18
    if zone_index == 3:
        if clear_before >= 0.35:
            mult *= 1.45
        if clear_before >= 0.55:
            mult *= 1.35
        if clear_before >= 0.75:
            mult *= 1.25
        mult /= 1.0 + 0.10 * current_level(state, "mantle_drills")
        mult /= 1.0 + 0.10 * current_level(state, "thermal_mapping")
    if zone_index == 4:
        if clear_before >= 0.18:
            mult *= 1.45
        if clear_before >= 0.38:
            mult *= 1.38
        if clear_before >= 0.60:
            mult *= 1.30
        if clear_before >= 0.78:
            mult *= 1.22
    if zone_index == 5:
        if clear_before >= 0.14:
            mult *= 1.78
        if clear_before >= 0.32:
            mult *= 1.56
        if clear_before >= 0.56:
            mult *= 1.36
        mult /= 1.0 + 0.08 * current_level(state, "mirror_saws")
        mult /= 1.0 + 0.06 * current_level(state, "inversion_ledger")
    if zone_index == 6:
        if clear_before >= 0.12:
            mult *= 1.88
        if clear_before >= 0.28:
            mult *= 1.60
        if clear_before >= 0.45:
            mult *= 1.42
        if clear_before >= 0.62:
            mult *= 1.30
        mult /= 1.0 + 0.08 * current_level(state, "fault_harpoons")
        mult /= 1.0 + 0.06 * current_level(state, "fault_oracles")
    if zone_index == 7:
        if clear_before >= 0.10:
            mult *= 2.00
        if clear_before >= 0.26:
            mult *= 1.70
        if clear_before >= 0.44:
            mult *= 1.52
        if clear_before >= 0.64:
            mult *= 1.38
        mult /= 1.0 + 0.08 * current_level(state, "null_borers")
        mult /= 1.0 + 0.06 * current_level(state, "null_archive")
    if zone_index == 8:
        if clear_before >= 0.10:
            mult *= 2.12
        if clear_before >= 0.24:
            mult *= 1.78
        if clear_before >= 0.42:
            mult *= 1.58
        if clear_before >= 0.60:
            mult *= 1.42
        mult /= 1.0 + 0.08 * current_level(state, "ash_crowns")
        mult /= 1.0 + 0.06 * current_level(state, "ash_scriptures")
    if zone_index == 9:
        if clear_before >= 0.08:
            mult *= 2.28
        if clear_before >= 0.22:
            mult *= 1.96
        if clear_before >= 0.40:
            mult *= 1.72
        if clear_before >= 0.58:
            mult *= 1.54
        if clear_before >= 0.76:
            mult *= 1.36
        mult /= 1.0 + 0.10 * current_level(state, "vault_pulsers")
        mult /= 1.0 + 0.08 * current_level(state, "gravity_wells")
        mult /= 1.0 + 0.08 * current_level(state, "graveyard_index")
        mult /= 1.0 + 0.08 * current_level(state, "ash_crowns")
        mult /= 1.0 + 0.08 * current_level(state, "ash_scriptures")
    return max(1.0, mult)


def hazard_hits(state: State, zone: Zone, clear_before: float, scenario: dict[str, float]) -> float:
    defense = 1.0
    defense += 0.22 * current_level(state, "cache_warmers")
    defense += 0.25 * current_level(state, "barrier_mesh")
    if current_level(state, "pressure_vent") > 0:
        defense += 0.75
    if current_level(state, "voidfire_brakes") > 0:
        defense += 0.55
    if clear_before >= 0.40:
        defense += 0.35
    if clear_before >= 0.65:
        defense += 0.35
    pressure = zone.hazard * scenario["hazard_scale"]
    pressure *= 1.16 - clear_before * 0.72
    return max(0.0, pressure / max(0.9, defense))


def mine_run(state: State, scenario: dict[str, float]) -> None:
    state.run_index += 1
    zone_index = state.current_zone
    zone = ZONES[zone_index]
    clear_before = state.current_power[zone_index]
    mastery_mult, mastery_note = mastery_tier(state)
    mastery_mult = 1.0 + (mastery_mult - 1.0) * scenario["mastery_scale"]

    run_seconds = base_run_time(state)
    run_seconds *= 1.0 + 0.03 * min(zone_index, 3)
    throughput = mining_power(state, zone_index, scenario) * mastery_mult * efficiency_mult(state)
    core_throughput = core_power(state, zone_index, scenario) * mastery_mult
    effective_block_hp = zone.block_hp * zone_block_hp_multiplier(state, zone_index, clear_before)

    mining_time = run_seconds * (0.84 - 0.04 * min(zone_index, 3))
    if clear_before >= zone.expose_at:
        core_time = run_seconds * 0.40
        mining_time -= core_time * 0.35
    else:
        core_time = 0.0

    blocks_mined = throughput * mining_time / effective_block_hp
    blocks_remaining = zone.total_blocks * (1.0 - state.current_power[zone_index])
    blocks_mined = min(blocks_remaining, blocks_mined)
    cargo_estimate = estimate_live_cargo_collection(
        state,
        zone_index,
        run_seconds,
        mining_time,
        blocks_mined,
        effective_block_hp,
    )

    clear_after = min(1.0, clear_before + blocks_mined / zone.total_blocks)
    state.current_power[zone_index] = clear_after

    if clear_before < zone.expose_at and clear_after >= zone.expose_at:
        state.milestones.setdefault(f"{zone.id}_core_exposed", state.elapsed + run_seconds)

    if clear_after >= zone.expose_at:
        exposed_bonus = 0.75 + (clear_after - zone.expose_at) / max(0.1, 1.0 - zone.expose_at)
        core_damage = core_throughput * core_time * exposed_bonus
    else:
        core_damage = 0.0

    if clear_after >= 1.0:
        core_damage *= 1.20

    barriers = barrier_count(state)
    hits = hazard_hits(state, zone, clear_before, scenario)
    survived = hits <= barriers + 0.20

    resource_value = blocks_mined * zone.block_value
    resource_value *= money_value_mult(state) * scenario["economy_scale"]
    banked_value = min(resource_value * bank_fraction(state), cargo_cap(state))
    if resource_value > cargo_cap(state):
        banked_value += (resource_value - cargo_cap(state)) * 0.22

    xp_gained = int(round(blocks_mined * zone.xp_per_block * xp_value_mult(state) * float(state.economy.get("xp_scale", 1.0)))) if survived else 0

    core_destroyed = False
    core_earned = 0
    state.core_hp_remaining[zone_index] = max(0.0, state.core_hp_remaining[zone_index] - core_damage)
    if state.core_hp_remaining[zone_index] <= 0.0 and core_damage > 0.0:
        core_destroyed = True
        core_earned = zone.core_reward + current_level(state, "core_siphon")
        if not survived:
            core_earned = 0

    if survived:
        money_earned = int(round(banked_value))
    else:
        money_earned = int(round(banked_value * salvage_keep(state)))
        xp_gained = 0
        core_earned = 0

    state.money += money_earned
    state.xp += xp_gained
    state.cores += core_earned

    start_time = state.elapsed
    state.elapsed += run_seconds + 12.0

    purchases = buy_phase(state)

    if core_destroyed:
        state.current_power[zone_index] = 1.0
        if zone_index == 4:
            state.milestones.setdefault("bottom_of_first_funnel", state.elapsed)
        if zone_index == len(ZONES) - 1:
            state.milestones.setdefault("second_funnel_defeated", state.elapsed)
        next_zone = zone_index + 1
        if next_zone < len(ZONES):
            if can_enter_zone(state, next_zone):
                state.current_zone = next_zone
            else:
                state.milestones.setdefault("demo_gate_reached", state.elapsed)

    state.logs.append(
        RunLog(
            run=state.run_index,
            zone=zone.label,
            start_min=start_time / 60.0,
            end_min=state.elapsed / 60.0,
            survived=survived,
            barriers_taken=round(hits, 2),
            barriers_available=barriers,
            blocks_cleared=round(blocks_mined, 1),
            run_seconds=round(run_seconds, 2),
            cargo_capacity=round(cargo_estimate.capacity, 1),
            cargo_collected=round(cargo_estimate.collected, 1),
            cargo_fill_seconds=round(cargo_estimate.fill_seconds, 2) if cargo_estimate.fill_seconds is not None else None,
            cargo_fill_fuel_ratio=round(cargo_estimate.fill_fuel_ratio, 4) if cargo_estimate.fill_fuel_ratio is not None else None,
            cargo_collection_efficiency=round(cargo_estimate.collection_efficiency, 4),
            zone_clear_before=round(clear_before * 100.0, 1),
            zone_clear_after=100.0 if core_destroyed else round(clear_after * 100.0, 1),
            core_damage=round(core_damage, 1),
            core_destroyed=core_destroyed,
            money_earned=money_earned,
            xp_earned=xp_gained,
            core_earned=core_earned,
            salvage_ratio=0.0 if survived else round(salvage_keep(state), 2),
            purchases=purchases,
            wallets_after={
                "money": int(round(state.money)),
                "xp": int(round(state.xp)),
                "cores": int(round(state.cores)),
            },
            mastery_note=mastery_note,
        )
    )

    if state.elapsed >= 30.0 * 60.0 and "demo_30m_progress" not in state.milestones:
        state.milestones["demo_30m_progress"] = first_funnel_progress(state)
        state.milestones["demo_30m_overall"] = stage_progress(state)


def buy_phase(state: State) -> list[str]:
    purchases: list[str] = []
    total_cap = 3

    while len(purchases) < total_cap:
        bought_this_pass = False

        if (
            not state.demo_mode
            and current_level(state, "kernel_breach") == 0
            and state.current_zone >= 2
            and can_buy(state, "kernel_breach")
        ):
            purchases.append(buy_upgrade(state, "kernel_breach"))
            bought_this_pass = True
            if len(purchases) >= total_cap:
                break

        for upgrade_id in MONEY_PRIORITY:
            if len(purchases) >= total_cap:
                break
            if state.demo_mode and is_demo_hidden_upgrade(upgrade_id):
                continue
            if can_buy(state, upgrade_id):
                purchases.append(buy_upgrade(state, upgrade_id))
                bought_this_pass = True
                break

        for upgrade_id in XP_PRIORITY:
            if len(purchases) >= total_cap:
                break
            if state.demo_mode and is_demo_hidden_upgrade(upgrade_id):
                continue
            if can_buy(state, upgrade_id):
                purchases.append(buy_upgrade(state, upgrade_id))
                bought_this_pass = True
                break

        for upgrade_id in CORE_PRIORITY:
            if len(purchases) >= total_cap:
                break
            if upgrade_id == "root_access" and state.current_zone < 4:
                continue
            if upgrade_id == "demo_lock_override":
                continue
            if state.demo_mode and is_demo_hidden_upgrade(upgrade_id):
                continue
            if can_buy(state, upgrade_id):
                purchases.append(buy_upgrade(state, upgrade_id))
                bought_this_pass = True
                break

        if not bought_this_pass:
            break

    return purchases


def simulate_scenario(scenario: dict[str, float], demo_mode: bool = False) -> State:
    state = State(
        current_power=[0.0 for _ in ZONES],
        core_hp_remaining=[zone.core_hp for zone in ZONES],
        upgrades={},
        economy=scenario,
        demo_mode=demo_mode,
    )
    while state.elapsed < 2.5 * 60.0 * 60.0 and "second_funnel_defeated" not in state.milestones and "demo_gate_reached" not in state.milestones:
        mine_run(state, scenario)
    return state


def scenario_score(state: State) -> float:
    progress_30 = progress_at_minutes(state, 30.0, True)
    bottom_60 = float(state.milestones.get("bottom_of_first_funnel", 999999.0)) / 60.0
    finish_120 = float(state.milestones.get("second_funnel_defeated", 999999.0)) / 60.0
    avg_purchases = sum(len(log.purchases) for log in state.logs) / max(1, len(state.logs))
    penalty = 0.0
    penalty += abs(progress_30 - 0.72) * 250.0
    penalty += abs(bottom_60 - 60.0) * 6.0
    penalty += abs(finish_120 - 120.0) * 4.0
    penalty += abs(avg_purchases - 2.2) * 140.0
    if avg_purchases < 1.0:
        penalty += 100.0
    if avg_purchases > 2.8:
        penalty += 180.0 + (avg_purchases - 2.8) * 260.0
    if avg_purchases < 1.5:
        penalty += 40.0
    purchase_failures = sum(1 for log in state.logs if not log.purchases)
    penalty += purchase_failures * 12.0
    return penalty


def choose_best() -> tuple[dict[str, float], State]:
    best_scenario: dict[str, float] | None = None
    best_state: State | None = None
    best_score = math.inf
    for scenario in SCENARIOS:
        state = simulate_scenario(scenario)
        score = scenario_score(state)
        if score < best_score:
            best_score = score
            best_scenario = scenario
            best_state = state
    assert best_scenario is not None and best_state is not None
    return best_scenario, best_state


def fmt_time(minutes_value: float) -> str:
    return f"{minutes_value:.1f}m"


def summarize_block_counts(state: State) -> list[str]:
    if not state.logs:
        return ["- No runs recorded."]

    total_blocks = sum(log.blocks_cleared for log in state.logs)
    avg_blocks = total_blocks / len(state.logs)
    max_log = max(state.logs, key=lambda log: log.blocks_cleared)
    min_log = min(state.logs, key=lambda log: log.blocks_cleared)

    lines = [
        f"- These are actual blocks cleared per run, not block HP or damage. The current best run averages `{avg_blocks:.0f}` blocks per sortie.",
        f"- Lowest-clear sortie: run `{min_log.run}` in `{min_log.zone}` with `{min_log.blocks_cleared:.0f}` blocks.",
        f"- Highest-clear sortie: run `{max_log.run}` in `{max_log.zone}` with `{max_log.blocks_cleared:.0f}` blocks.",
    ]

    seen_zones: set[str] = set()
    for zone in ZONES:
        zone_logs = [log for log in state.logs if log.zone == zone.label]
        if not zone_logs:
            continue
        seen_zones.add(zone.label)
        avg_zone = sum(log.blocks_cleared for log in zone_logs) / len(zone_logs)
        min_zone = min(log.blocks_cleared for log in zone_logs)
        max_zone = max(log.blocks_cleared for log in zone_logs)
        lines.append(
            f"- `{zone.label}`: `{min_zone:.0f}` to `{max_zone:.0f}` actual blocks per run, averaging `{avg_zone:.0f}`."
        )

    for log in state.logs:
        if log.zone in seen_zones:
            continue
        lines.append(f"- `{log.zone}`: `{log.blocks_cleared:.0f}` actual blocks in its only recorded run.")
        seen_zones.add(log.zone)

    return lines


def summarize_cargo_timing(state: State) -> list[str]:
    if not state.logs:
        return ["- No runs recorded."]

    avg_capacity = sum(log.cargo_capacity for log in state.logs) / len(state.logs)
    avg_collected = sum(log.cargo_collected for log in state.logs) / len(state.logs)
    max_log = max(state.logs, key=lambda log: log.cargo_collected)
    filled_logs = [log for log in state.logs if log.cargo_fill_fuel_ratio is not None]
    if not filled_logs:
        return [
            "- Cargo never fills before fuel expires in this scenario.",
            f"- Average estimated cargo collected: `{avg_collected:.0f}` units against `{avg_capacity:.0f}` average capacity.",
            f"- Highest estimated cargo run: run `{max_log.run}` in `{max_log.zone}` with `{max_log.cargo_collected:.0f}` collected of `{max_log.cargo_capacity:.0f}` capacity.",
            "- Cargo collection now uses a live-action estimate: travel/setup time, local attack range, attack interval, block HP versus damage, assist damage, and pickup radius.",
        ]

    efficient_logs = [log for log in filled_logs if log.cargo_collected >= log.cargo_capacity]
    target_logs = efficient_logs if efficient_logs else filled_logs
    avg_ratio = sum(float(log.cargo_fill_fuel_ratio) for log in target_logs) / len(target_logs)
    closest = min(target_logs, key=lambda log: abs(float(log.cargo_fill_fuel_ratio) - 0.70))
    earliest = min(target_logs, key=lambda log: float(log.cargo_fill_fuel_ratio))
    latest = max(target_logs, key=lambda log: float(log.cargo_fill_fuel_ratio))

    lines = [
        f"- Average estimated cargo collected: `{avg_collected:.0f}` units against `{avg_capacity:.0f}` average capacity.",
        f"- Highest estimated cargo run: run `{max_log.run}` in `{max_log.zone}` with `{max_log.cargo_collected:.0f}` collected of `{max_log.cargo_capacity:.0f}` capacity.",
        f"- Efficient cargo-limited runs average `{avg_ratio * 100.0:.1f}%` fuel elapsed before cargo fills; target is `70.0%`.",
        f"- Closest target run: run `{closest.run}` in `{closest.zone}` fills cargo at `{float(closest.cargo_fill_fuel_ratio) * 100.0:.1f}%` fuel elapsed (`{float(closest.cargo_fill_seconds):.1f}s` of `{closest.run_seconds:.1f}s`).",
        f"- Fastest fill: run `{earliest.run}` at `{float(earliest.cargo_fill_fuel_ratio) * 100.0:.1f}%`; slowest fill before fuel ends: run `{latest.run}` at `{float(latest.cargo_fill_fuel_ratio) * 100.0:.1f}%`.",
        "- Cargo collection now uses a live-action estimate: travel/setup time, local attack range, attack interval, block HP versus damage, assist damage, and pickup radius.",
    ]

    by_zone: dict[str, list[RunLog]] = {}
    for log in target_logs:
        by_zone.setdefault(log.zone, []).append(log)
    for zone in ZONES:
        logs = by_zone.get(zone.label, [])
        if not logs:
            continue
        zone_avg = sum(float(log.cargo_fill_fuel_ratio) for log in logs) / len(logs)
        lines.append(f"- `{zone.label}` cargo-limited runs average `{zone_avg * 100.0:.1f}%` fuel elapsed before full.")

    return lines


def build_report(scenario: dict[str, float], state: State, demo_mode: bool = False) -> str:
    purchases_per_run = sum(len(log.purchases) for log in state.logs) / max(1, len(state.logs))
    no_purchase_runs = sum(1 for log in state.logs if not log.purchases)
    progress_30 = progress_at_minutes(state, 30.0, True) * 100.0
    progress_30_overall = progress_at_minutes(state, 30.0, False) * 100.0
    bottom_60 = float(state.milestones.get("bottom_of_first_funnel", 0.0)) / 60.0
    finish_120 = float(state.milestones.get("second_funnel_defeated", 0.0)) / 60.0

    lines: list[str] = []
    lines.append("# Open Pit Empire Demo Layer Progression Simulation" if demo_mode else "# Open Pit Empire Layer Progression Simulation")
    lines.append("")
    if demo_mode:
        lines.append("This pass models the demo slice with the hidden `Kernel Breach` core upgrade removed from the store, so the player can fully clear Ghost Sector but cannot enter Kernel Vault.")
    else:
        lines.append("This pass models a persistent-destruction layer run with money, XP, and core upgrades, plus global layer-clear powerups that ramp from 1.5x to 3.0x damage and carry forward into every deeper layer.")
    lines.append("")
    lines.append("## Best Scenario")
    lines.append(f"- Scenario: `{scenario['name']}`")
    lines.append(f"- 30 minute demo progress: {progress_30:.1f}% through the top-side descent ({progress_30_overall:.1f}% of the full layer arc)")
    if demo_mode:
        gate_time = float(state.milestones.get("demo_gate_reached", 0.0)) / 60.0
        lines.append(f"- Ghost Sector fully cleared: {fmt_time(gate_time)}")
        lines.append("- Demo stop: `Kernel Vault` requires hidden core upgrade `Kernel Breach`")
    else:
        lines.append(f"- Root Well reached: {fmt_time(bottom_60)}")
        lines.append(f"- Crown of Ash cleared: {fmt_time(finish_120)}")
    lines.append(f"- Runs: {len(state.logs)}")
    lines.append(f"- Average purchases per run: {purchases_per_run:.2f}")
    lines.append(f"- Runs without a purchase: {no_purchase_runs}")
    lines.append("")
    lines.append("## Proposed Layer-Clear Powerups")
    lines.append("- 25% global persistent clear: `Clear Breach I` = +50% total global mining damage")
    lines.append("- 50% global persistent clear: `Clear Breach II` = another +50% total global mining damage")
    lines.append("- 75% global persistent clear: `Clear Breach III` = another +50% total global mining damage")
    lines.append("- This is one global set of three rewards, not a repeating set per layer. In the sim they stack multiplicatively to 1.5x, 2.25x, then 3.375x total damage.")
    lines.append("")
    lines.append("## Upgrade Additions Used By The Sim")
    lines.append("- Money early-mid: `Shock Bits`, `Breach Drones`, `Salvage Contract`, `Funnel Resonance`, `Daemon Lances`, `Root Breaker`")
    lines.append("- Money late: `Overburn Reactors`, `Seismic Lattice`, `Mantle Drills`, `Fault Charges`, `Void Cutters`, `Inversion Drives`, `Vault Pulsers`, `Gravity Wells`, `Abyssal Rigs`")
    lines.append("- Money NG+: `Mirror Saws`, `Fault Harpoons`, `Null Borers`, `Ash Crowns`")
    lines.append("- XP late: `Crash Cartography`, `Kernel Rehearsal`, `Deep Manifest`, `Thermal Mapping`, `Vault Heuristics`, `Graveyard Index`, `Mirror Daemons`")
    lines.append("- XP NG+: `Inversion Ledger`, `Fault Oracles`, `Null Archive`, `Ash Scriptures`")
    lines.append("- Core late: `Pressure Vent`, `Core Siphon`, `Salvage Limiter`, `Mantle Permits`, `Inversion Tether`, `Voidfire Brakes`")
    lines.append("- Core NG+: `Mirror Keys`, `Fault Insulation`, `Null Anchor`, `Ash Ward`")
    lines.append("")
    lines.append("## Difficulty Spikes Added")
    lines.append("- Ghost Sector, Kernel Vault, and Root Well all now have longer dwell windows so the player has to build power across each layer instead of skipping straight to the next core.")
    lines.append("- The upside-down half is now a five-layer New Game Plus descent: `Mirror Shelf`, `Reverse Fault`, `Null Vein`, `Grave Mantle`, and `Crown of Ash`.")
    lines.append("- Each upside-down layer has its own core, its own hardness spikes, and its own upgrade band so the late game keeps presenting fresh buying decisions.")
    lines.append("")
    lines.append("## Demo Gate Recommendation")
    lines.append("- Best gate point: Ghost Sector completion. The player gets a full top-side slice, sees a core clear, and then hits a clean hard gate before Kernel Vault.")
    lines.append("- Demo implementation: make `Kernel Breach` a hidden core upgrade earned after Ghost Sector but unavailable in demo mode. Without it, Kernel Vault remains unmineable.")
    lines.append("- Demo-visible tree cutoff: hide `Kernel Breach` and every stage-3+ upgrade: `Root Breaker`, `Overburn Reactors`, `Seismic Lattice`, `Mantle Drills`, `Fault Charges`, `Void Cutters`, `Inversion Drives`, `Vault Pulsers`, `Gravity Wells`, `Abyssal Rigs`, `Mirror Saws`, `Fault Harpoons`, `Null Borers`, `Ash Crowns`, `Kernel Rehearsal`, `Deep Manifest`, `Thermal Mapping`, `Vault Heuristics`, `Graveyard Index`, `Mirror Daemons`, `Inversion Ledger`, `Fault Oracles`, `Null Archive`, `Ash Scriptures`, `Core Siphon`, `Root Access`, `Salvage Limiter`, `Mantle Permits`, `Inversion Tether`, `Voidfire Brakes`, `Mirror Keys`, `Fault Insulation`, `Null Anchor`, and `Ash Ward`.")
    lines.append("")
    lines.append("## Actual Blocks Per Run")
    lines.extend(summarize_block_counts(state))
    lines.append("")
    lines.append("## Cargo Limit Timing")
    lines.extend(summarize_cargo_timing(state))
    lines.append("")
    lines.append("## Run Report")
    lines.append("| Run | Window | Zone | Result | Barriers | Cargo | Cargo Full | Clear | Core | Rewards | Purchases | Wallets |")
    lines.append("|---:|---|---|---|---|---|---|---|---|---|---|---|")
    for log in state.logs:
        result = "Return" if log.survived else f"Death ({int(round(log.salvage_ratio * 100.0))}% salvage)"
        clear_text = f"{log.zone_clear_before:.1f}% -> {log.zone_clear_after:.1f}% ({log.blocks_cleared:.0f} blocks, {log.mastery_note})"
        if log.cargo_fill_fuel_ratio is None:
            cargo_text = f"not full ({log.cargo_capacity:.0f} cap)"
        else:
            cargo_text = f"{float(log.cargo_fill_fuel_ratio) * 100.0:.1f}% fuel ({float(log.cargo_fill_seconds):.1f}s, {log.cargo_capacity:.0f} cap)"
        cargo_collected_text = f"{log.cargo_collected:.0f}/{log.cargo_capacity:.0f} ({log.cargo_collection_efficiency * 100.0:.0f}% pickup)"
        core_text = f"{log.core_damage:.0f}"
        if log.core_destroyed:
            core_text += " and core cleared"
        rewards = f"${log.money_earned}, {log.xp_earned} xp, {log.core_earned} cores"
        purchases = ", ".join(log.purchases) if log.purchases else "None"
        wallets = f"${log.wallets_after['money']} / {log.wallets_after['xp']} xp / {log.wallets_after['cores']} cores"
        lines.append(
            f"| {log.run} | {fmt_time(log.start_min)}-{fmt_time(log.end_min)} | {log.zone} | {result} | "
            f"{log.barriers_taken:.2f}/{log.barriers_available} | {cargo_collected_text} | {cargo_text} | {clear_text} | {core_text} | {rewards} | {purchases} | {wallets} |"
        )
    return "\n".join(lines) + "\n"


def build_json_payload(scenario: dict[str, float], state: State, demo_mode: bool = False) -> dict:
    return {
        "scenario": scenario,
        "mode": "demo" if demo_mode else "full",
        "summary": {
            "runs": len(state.logs),
            "progress_at_30m": round(float(state.milestones.get("demo_30m_progress", 0.0)), 4),
            "bottom_of_first_funnel_minutes": round(float(state.milestones.get("bottom_of_first_funnel", 0.0)) / 60.0, 3),
            "second_funnel_defeated_minutes": round(float(state.milestones.get("second_funnel_defeated", 0.0)) / 60.0, 3),
            "demo_gate_reached_minutes": round(float(state.milestones.get("demo_gate_reached", 0.0)) / 60.0, 3),
            "avg_cargo_capacity": round(sum(log.cargo_capacity for log in state.logs) / max(1, len(state.logs)), 3),
            "avg_cargo_collected": round(sum(log.cargo_collected for log in state.logs) / max(1, len(state.logs)), 3),
            "max_cargo_collected": round(max((log.cargo_collected for log in state.logs), default=0.0), 3),
            "avg_purchases_per_run": round(sum(len(log.purchases) for log in state.logs) / max(1, len(state.logs)), 3),
            "no_purchase_runs": sum(1 for log in state.logs if not log.purchases),
            "demo_gate_zone": ZONES[state.demo_gate_zone].label,
            "demo_gate_clear": state.demo_gate_clear,
        },
        "runs": [
            {
                "run": log.run,
                "zone": log.zone,
                "start_min": round(log.start_min, 3),
                "end_min": round(log.end_min, 3),
                "survived": log.survived,
                "barriers_taken": log.barriers_taken,
                "barriers_available": log.barriers_available,
                "blocks_cleared": log.blocks_cleared,
                "run_seconds": log.run_seconds,
                "cargo_capacity": log.cargo_capacity,
                "cargo_collected": log.cargo_collected,
                "cargo_fill_seconds": log.cargo_fill_seconds,
                "cargo_fill_fuel_ratio": log.cargo_fill_fuel_ratio,
                "cargo_collection_efficiency": log.cargo_collection_efficiency,
                "zone_clear_before": log.zone_clear_before,
                "zone_clear_after": log.zone_clear_after,
                "core_damage": log.core_damage,
                "core_destroyed": log.core_destroyed,
                "money_earned": log.money_earned,
                "xp_earned": log.xp_earned,
                "core_earned": log.core_earned,
                "salvage_ratio": log.salvage_ratio,
                "purchases": log.purchases,
                "wallets_after": log.wallets_after,
                "mastery_note": log.mastery_note,
            }
            for log in state.logs
        ],
    }


def main() -> None:
    scenario, state = choose_best()
    demo_state = simulate_scenario(scenario, demo_mode=True)
    report = build_report(scenario, state)
    demo_report = build_report(scenario, demo_state, demo_mode=True)
    REPORT_PATH.write_text(report, encoding="utf-8")
    JSON_PATH.write_text(json.dumps(build_json_payload(scenario, state), indent=2), encoding="utf-8")
    DEMO_REPORT_PATH.write_text(demo_report, encoding="utf-8")
    DEMO_JSON_PATH.write_text(json.dumps(build_json_payload(scenario, demo_state, demo_mode=True), indent=2), encoding="utf-8")
    print(report)
    print("")
    print(demo_report)
    print(f"Wrote {REPORT_PATH}")
    print(f"Wrote {JSON_PATH}")
    print(f"Wrote {DEMO_REPORT_PATH}")
    print(f"Wrote {DEMO_JSON_PATH}")


if __name__ == "__main__":
    main()
