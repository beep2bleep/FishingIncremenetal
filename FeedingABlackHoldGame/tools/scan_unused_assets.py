#!/usr/bin/env python3
"""
Static reachability scan: collect res:// paths reachable from starter roots via
textual references in .tscn, .gd, .tres, .res, .gdshader, .cfg, .import, .json, .csv.
Does not evaluate dynamic load() expressions or UID-only refs without paths.
"""
from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
PROJECT_GODOT = ROOT / "project.godot"

# Paths that must be roots (user-requested closure + bootstrap targets).
EXPLICIT_ROOTS = [
    "res://Core/Boot/AppBootstrap.tscn",
    "res://Core/Boot/GameLauncher.tscn",
    "res://UpgradeScreen.tscn",
    "res://Games/Mining/Scenes/MiningMain.tscn",
    "res://Games/Turkey/Scenes/TurkeyMain.tscn",
    "res://Games/RedSkyDefense/Scenes/MissleMain.tscn",
    "res://Games/Vanguard/Scenes/VanguardMain.tscn",
    "res://Games/Vanguard/Scenes/VanguardBattleScene.tscn",
    "res://Games/ReelIntoDarkness/Scenes/ReelIntoDarknessMain.tscn",
    "res://Games/ReelIntoDarkness/Scenes/ReelIntoDarknessMain.gd",
    "res://Fishing/BattleScene.tscn",
]

# Unquoted paths (no spaces). Quoted paths with spaces are matched separately.
RES_PATH_UNQUOTED_RE = re.compile(r"res://[\w./\-]+")
QUOTED_RES_PATH_RE = re.compile(r'"(res://[^"]+)"')
SINGLE_QUOTED_RES_PATH_RE = re.compile(r"'(res://[^']+)'")


def res_to_abs(p: str) -> Path:
    assert p.startswith("res://")
    return ROOT / Path(p[6:])


def norm_key(path: Path) -> str:
    try:
        return str(path.resolve()).lower()
    except OSError:
        return str(path).lower()


TEXT_SUFFIXES = {
    ".gd",
    ".tscn",
    ".tres",
    ".res",
    ".gdshader",
    ".shader",
    ".cfg",
    ".import",
    ".json",
    ".csv",
    ".txt",
    ".md",
    ".ttf",
    ".tscn.remap",
}


def is_probably_text(path: Path) -> bool:
    suf = "".join(path.suffixes[-2:]) if len(path.suffixes) > 1 else path.suffix
    if path.suffix in TEXT_SUFFIXES:
        return True
    if suf in TEXT_SUFFIXES:
        return True
    return path.suffix == "" and path.name in ("project.godot",)


def _strip_trailing_junk(p: str) -> str:
    while p.endswith((")", ",", ";", '"', "'")):
        p = p[:-1]
    # Keep extension final dot (e.g. .png) — only strip stray sentence periods when no extension
    while p.endswith(".") and p.count(".") > 1:
        p = p[:-1]
    return p


def extract_res_paths(content: str) -> list[str]:
    seen: set[str] = set()
    ordered: list[str] = []

    def add(p: str) -> None:
        p = _strip_trailing_junk(p.strip())
        if p.startswith("res://") and p not in seen:
            seen.add(p)
            ordered.append(p)

    for m in QUOTED_RES_PATH_RE.finditer(content):
        add(m.group(1))
    for m in SINGLE_QUOTED_RES_PATH_RE.finditer(content):
        add(m.group(1))
    for m in RES_PATH_UNQUOTED_RE.finditer(content):
        add(m.group(0))
    return ordered


def project_godot_res_paths() -> list[str]:
    if not PROJECT_GODOT.is_file():
        return []
    text = PROJECT_GODOT.read_text(encoding="utf-8", errors="replace")
    return extract_res_paths(text)


def collect_reachable() -> tuple[set[str], set[str]]:
    """Returns (seen_res_paths, used_asset_norm_keys).

    If a string resolves to a directory, every file under it is marked used (covers
    dynamic paths built from a folder constant like ``res://Art/CombatSprites``).
    """
    seeds = list(EXPLICIT_ROOTS) + project_godot_res_paths()
    seen_res: set[str] = set()
    used_abs: set[str] = set()
    queue: list[str] = []

    def enqueue(raw: str) -> None:
        p = raw.strip().rstrip("/")
        while p.endswith((")", ",", ";", '"', "'")):
            p = p[:-1]
        if not p.startswith("res://"):
            return
        if p not in seen_res:
            seen_res.add(p)
            queue.append(p)

    for s in seeds:
        enqueue(s)

    idx = 0
    while idx < len(queue):
        res_path = queue[idx].rstrip("/")
        idx += 1
        abs_path = res_to_abs(res_path)

        if abs_path.is_dir():
            try:
                for child in abs_path.rglob("*"):
                    if not child.is_file():
                        continue
                    used_abs.add(norm_key(child))
                    c_res = "res://" + child.relative_to(ROOT).as_posix()
                    if is_probably_text(child) and c_res not in seen_res:
                        seen_res.add(c_res)
                        queue.append(c_res)
            except OSError:
                pass
            continue

        if not abs_path.is_file():
            continue

        used_abs.add(norm_key(abs_path))

        if not is_probably_text(abs_path):
            continue
        try:
            content = abs_path.read_text(encoding="utf-8", errors="replace")
        except OSError:
            continue
        for ref in extract_res_paths(content):
            enqueue(ref)
    return seen_res, used_abs


ASSET_SUFFIXES = frozenset(
    {
        ".png",
        ".jpg",
        ".jpeg",
        ".webp",
        ".svg",
        ".bmp",
        ".tga",
        ".ogg",
        ".wav",
        ".mp3",
        ".tres",
        ".res",
        ".gdshader",
        ".shader",
        ".tscn",
        ".ttf",
        ".otf",
        ".woff",
        ".woff2",
        ".json",
        ".csv",
        ".translation",
        ".glb",
        ".gltf",
        ".obj",
        ".fbx",
        ".blend",
        ".exr",
        ".hdr",
    }
)

SKIP_DIR_NAMES = frozenset({".git", ".godot"})


def list_project_asset_files() -> list[Path]:
    files: list[Path] = []
    for p in ROOT.rglob("*"):
        if not p.is_file():
            continue
        rel_parts = p.relative_to(ROOT).parts
        if any(part in SKIP_DIR_NAMES for part in rel_parts):
            continue
        if "addons" in p.relative_to(ROOT).parts:
            continue
        if p.suffix == ".uid":
            continue
        if p.suffix.lower() in ASSET_SUFFIXES or (p.suffix == ".import" and p.with_suffix("").suffix.lower() in ASSET_SUFFIXES):
            files.append(p)
        elif p.suffix == ".import":
            continue
    return files


def main() -> int:
    reachable, used_abs = collect_reachable()
    for r in reachable:
        ap = res_to_abs(r)
        if ap.is_file():
            used_abs.add(norm_key(ap))

    all_assets = list_project_asset_files()
    unused: list[Path] = []
    for f in all_assets:
        k = norm_key(f)
        if k not in used_abs:
            unused.append(f)

    out_path = ROOT.parent / "unusedAssets.MD"
    lines = [
        "# Unused assets (static scan)",
        "",
        "## Method",
        "- **Roots:** `AppBootstrap.tscn`, `GameLauncher.tscn`, `UpgradeScreen.tscn`, main game scenes (Mining, Turkey, Red Sky, Vanguard main + battle, Reel Into Darkness), `Fishing/BattleScene.tscn`, `ReelIntoDarknessMain.gd`, plus every `res://` path found in `project.godot` (main scene, icon, autoloads, translations, plugins, etc.).",
        "- **Traversal:** Textual `res://...` references inside reachable `.gd`, `.tscn`, `.tres`, `.res`, `.gdshader`, `.cfg`, `.import`, `.json`, `.csv`, and similar. If a reference resolves to a **directory**, every file under that directory is treated as used (covers folder constants combined with dynamic filenames).",
        "- **Limitations:** Paths built without a discoverable folder prefix, `uid://` without a `path=` in scanned text, C# resources, editor-only assignments, and `StoreAssets_*` / tooling folders may still produce false positives or misses.",
        "- **Regenerate:** `python FeedingABlackHoldGame/tools/scan_unused_assets.py` (writes this file next to the `FeedingABlackHoldGame` folder).",
        "",
        f"**Reachable `res://` path strings (count):** {len(reachable)}",
        f"**Unused asset files listed below (count):** {len(unused)}",
        "",
        "## Unused files (under `FeedingABlackHoldGame/`, excluding `addons/` and `.godot/`)",
        "",
    ]
    for f in sorted(unused, key=lambda x: x.as_posix().lower()):
        rel = f.relative_to(ROOT.parent).as_posix()
        lines.append(f"- `{rel}`")
    lines.append("")
    out_path.write_text("\n".join(lines), encoding="utf-8")
    print(f"Wrote {out_path} ({len(unused)} unused)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
