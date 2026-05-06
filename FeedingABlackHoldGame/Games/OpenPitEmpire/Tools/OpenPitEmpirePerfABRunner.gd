extends Node

const BALANCE := preload("res://Games/OpenPitEmpire/OpenPitEmpireBalance.gd")
const PROGRESS := preload("res://Games/OpenPitEmpire/OpenPitEmpireProgress.gd")
const MAIN_SCENE := preload("res://Games/OpenPitEmpire/Scenes/OpenPitEmpireMain.tscn")

const DEFAULT_REPORT_DIR := "user://open_pit_empire_perf_ab"
const DEFAULT_SEED := 924611
const DEFAULT_DURATION_SECONDS := 90.0
const DEFAULT_WARMUP_SECONDS := 12.0

var _label := "candidate"
var _report_dir := DEFAULT_REPORT_DIR
var _backup_dir := ""
var _seed := DEFAULT_SEED
var _duration_seconds := DEFAULT_DURATION_SECONDS
var _warmup_seconds := DEFAULT_WARMUP_SECONDS
var _exit_code := 0

func _ready() -> void:
    call_deferred("_run")

func _run() -> void:
    ProjectSettings.set_setting(Util.ACTIVE_GAME_PROJECT_SETTING, Util.ACTIVE_GAME_OPEN_PIT)
    _parse_args()
    DirAccess.make_dir_recursive_absolute(_global_path(_report_dir))
    _backup_dir = "%s/save_backup_%s" % [_report_dir, _safe_path_segment(_label)]
    _backup_existing_progress()
    _install_full_unlock_regenerated_progress()
    _configure_full_speed_rendering()

    var summary := await _run_perf_sortie()
    var report_path := "%s/%s_perf.json" % [_report_dir, _safe_path_segment(_label)]
    _write_json(report_path, summary)
    _restore_existing_progress()
    print("[OpenPitPerfAB] label=%s report=%s" % [_label, _global_path(report_path)])
    get_tree().quit(_exit_code)

func _parse_args() -> void:
    for arg in OS.get_cmdline_user_args():
        if arg.begins_with("--label="):
            _label = arg.trim_prefix("--label=").strip_edges()
        elif arg.begins_with("--report-dir="):
            _report_dir = arg.trim_prefix("--report-dir=").strip_edges()
        elif arg.begins_with("--seed="):
            _seed = int(arg.trim_prefix("--seed="))
        elif arg.begins_with("--duration-seconds="):
            _duration_seconds = maxf(5.0, float(arg.trim_prefix("--duration-seconds=")))
        elif arg.begins_with("--warmup-seconds="):
            _warmup_seconds = clampf(float(arg.trim_prefix("--warmup-seconds=")), 0.0, _duration_seconds - 1.0)

func _configure_full_speed_rendering() -> void:
    Engine.max_fps = 0
    Engine.time_scale = 1.0
    if DisplayServer.get_name() != "headless":
        DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)

func _install_full_unlock_regenerated_progress() -> void:
    PROGRESS.flush_async_planet_state_save()
    PROGRESS.clear_cache()
    PROGRESS.clear_runtime_planet_data()
    _remove_path(PROGRESS.SAVE_PATH)
    _remove_path(PROGRESS.PLANET_SAVE_DIR)
    _remove_path(PROGRESS.LEGACY_PLANET_SAVE_PATH)

    var data := PROGRESS.get_default_data()
    var upgrades := {}
    for upgrade_id in BALANCE.RAW_NODE_DATA.keys():
        upgrades[str(upgrade_id)] = BALANCE.get_upgrade_max_level(str(upgrade_id))
    var xp_upgrades := {}
    for upgrade_id in BALANCE.XP_UPGRADES.keys():
        var prefixed := "%s%s" % [BALANCE.XP_PREFIX, str(upgrade_id)]
        xp_upgrades[prefixed] = BALANCE.get_xp_upgrade_max_level(prefixed)
    var purchased_core_upgrades: Array = []
    for upgrade_id in BALANCE.CORE_UPGRADES.keys():
        purchased_core_upgrades.append(str(upgrade_id))

    data["wallet"] = 0
    data["xp_currency"] = 0
    data["core_currency"] = 0
    data["upgrades"] = upgrades
    data["xp_upgrades"] = xp_upgrades
    data["purchased_core_upgrades"] = purchased_core_upgrades
    data["deepest_level_unlocked"] = BALANCE.MAX_DEPTH_LEVEL
    data["selected_depth_level"] = BALANCE.MAX_DEPTH_LEVEL
    data["boss_defeated"] = false
    data["planet_mastery_unlocked"] = false
    data["free_planet_mode"] = false
    data["bottom_phase_unlocked"] = true
    data["destroyed_cells"] = []
    data["planet_state"] = {}
    data["remaining_layer_block_counts"] = {}
    data["best_layer_clear_percents"] = {}
    data["last_run_summary"] = "Full unlock rendered perf run."
    PROGRESS.save_data(data)
    PROGRESS.regenerate_planet_state()
    PROGRESS.clear_cache()
    PROGRESS.clear_runtime_planet_data()

func _run_perf_sortie() -> Dictionary:
    var scene = MAIN_SCENE.instantiate()
    scene.validation_rng_seed = _seed
    scene.validation_autopilot_mode = "full_render"
    get_tree().root.add_child(scene)
    await get_tree().process_frame
    scene.autopilot_sortie_mode = scene.AUTOPILOT_MODE_DIG_DEEP
    scene.autopilot_dig_deep_anchor_grid = Vector2i(999999, 999999)
    scene.autopilot_enabled = true
    scene.autopilot_returning = false
    await get_tree().process_frame

    var frames := 0
    var measured_frames := 0
    var measured_frame_ms_total := 0.0
    var measured_process_ms_total := 0.0
    var min_instant_fps := 1000000
    var max_frame_ms := 0.0
    var frames_over_16_66 := 0
    var frames_over_20 := 0
    var frames_over_33 := 0
    var wall_started_msec := Time.get_ticks_msec()
    var last_ticks := Time.get_ticks_usec()
    while not bool(scene.run_finished):
        frames += 1
        await get_tree().process_frame
        if not bool(scene.autopilot_returning):
            scene.autopilot_sortie_mode = scene.AUTOPILOT_MODE_DIG_DEEP
        var now_ticks := Time.get_ticks_usec()
        var frame_ms := float(now_ticks - last_ticks) / 1000.0
        last_ticks = now_ticks
        var elapsed_s := float(Time.get_ticks_msec() - wall_started_msec) / 1000.0
        if elapsed_s >= _warmup_seconds:
            measured_frames += 1
            measured_frame_ms_total += frame_ms
            var process_ms := float(Performance.get_monitor(Performance.TIME_PROCESS)) * 1000.0
            measured_process_ms_total += process_ms
            max_frame_ms = maxf(max_frame_ms, frame_ms)
            min_instant_fps = mini(min_instant_fps, int(round(1000.0 / maxf(frame_ms, 0.001))))
            if frame_ms > 16.6667:
                frames_over_16_66 += 1
            if frame_ms > 20.0:
                frames_over_20 += 1
            if frame_ms > 33.3334:
                frames_over_33 += 1
        if elapsed_s >= _duration_seconds:
            break

    var run_summary: Dictionary = scene.get_validation_run_summary()
    var perf_summary: Dictionary = scene.get_validation_perf_summary()
    var elapsed_seconds := float(Time.get_ticks_msec() - wall_started_msec) / 1000.0
    var avg_frame_ms := measured_frame_ms_total / maxf(float(measured_frames), 1.0)
    var result := {
        "label": _label,
        "seed": _seed,
        "duration_seconds": _duration_seconds,
        "warmup_seconds": _warmup_seconds,
        "wall_elapsed_seconds": elapsed_seconds,
        "rendered_frames": frames,
        "measured_frames": measured_frames,
        "avg_fps": 1000.0 / maxf(avg_frame_ms, 0.001),
        "avg_frame_ms": avg_frame_ms,
        "avg_process_ms": measured_process_ms_total / maxf(float(measured_frames), 1.0),
        "min_instant_fps": 0 if min_instant_fps == 1000000 else min_instant_fps,
        "max_frame_ms": max_frame_ms,
        "frames_over_16_66ms": frames_over_16_66,
        "frames_over_20ms": frames_over_20,
        "frames_over_33ms": frames_over_33,
        "run_summary": run_summary,
        "perf": perf_summary,
    }
    scene.queue_free()
    await get_tree().process_frame
    return _sanitize_for_json(result)

func _backup_existing_progress() -> void:
    _remove_path(_backup_dir)
    DirAccess.make_dir_recursive_absolute(_global_path(_backup_dir))
    _copy_path(PROGRESS.SAVE_PATH, "%s/open_pit_empire_save_v3.json" % _backup_dir)
    _copy_path(PROGRESS.PLANET_SAVE_DIR, "%s/open_pit_empire_planet_state_v3" % _backup_dir)
    _copy_path(PROGRESS.LEGACY_PLANET_SAVE_PATH, "%s/open_pit_empire_planet_state_v1.json" % _backup_dir)

func _restore_existing_progress() -> void:
    PROGRESS.flush_async_planet_state_save()
    PROGRESS.clear_runtime_planet_data()
    PROGRESS.clear_cache()
    _remove_path(PROGRESS.SAVE_PATH)
    _remove_path(PROGRESS.PLANET_SAVE_DIR)
    _remove_path(PROGRESS.LEGACY_PLANET_SAVE_PATH)
    _copy_path("%s/open_pit_empire_save_v3.json" % _backup_dir, PROGRESS.SAVE_PATH)
    _copy_path("%s/open_pit_empire_planet_state_v3" % _backup_dir, PROGRESS.PLANET_SAVE_DIR)
    _copy_path("%s/open_pit_empire_planet_state_v1.json" % _backup_dir, PROGRESS.LEGACY_PLANET_SAVE_PATH)
    _remove_path(_backup_dir)
    PROGRESS.clear_cache()

func _copy_path(source: String, target: String) -> void:
    var source_global := _global_path(source)
    if not FileAccess.file_exists(source_global) and not DirAccess.dir_exists_absolute(source_global):
        return
    if DirAccess.dir_exists_absolute(source_global):
        DirAccess.make_dir_recursive_absolute(_global_path(target))
        var dir := DirAccess.open(source_global)
        if dir == null:
            return
        dir.list_dir_begin()
        var entry := dir.get_next()
        while entry != "":
            if entry != "." and entry != "..":
                _copy_path("%s/%s" % [source, entry], "%s/%s" % [target, entry])
            entry = dir.get_next()
        dir.list_dir_end()
        return
    DirAccess.make_dir_recursive_absolute(_global_path(target).get_base_dir())
    DirAccess.copy_absolute(source_global, _global_path(target))

func _remove_path(path: String) -> void:
    var global_path := _global_path(path)
    if DirAccess.dir_exists_absolute(global_path):
        var dir := DirAccess.open(global_path)
        if dir != null:
            dir.list_dir_begin()
            var entry := dir.get_next()
            while entry != "":
                if entry != "." and entry != "..":
                    _remove_path("%s/%s" % [path, entry])
                entry = dir.get_next()
            dir.list_dir_end()
        DirAccess.remove_absolute(global_path)
        return
    if FileAccess.file_exists(global_path):
        DirAccess.remove_absolute(global_path)

func _write_json(path: String, data: Variant) -> void:
    var global_path := _global_path(path)
    DirAccess.make_dir_recursive_absolute(global_path.get_base_dir())
    var file := FileAccess.open(global_path, FileAccess.WRITE)
    if file == null:
        push_error("Could not write %s" % path)
        _exit_code = 1
        return
    file.store_string(JSON.stringify(_sanitize_for_json(data), "\t"))

func _global_path(path: String) -> String:
    if path.begins_with("user://") or path.begins_with("res://"):
        return ProjectSettings.globalize_path(path)
    return path

func _safe_path_segment(value: String) -> String:
    var result := value.strip_edges().to_lower()
    for invalid in [":", "\\", "/", " ", "\t", "\n", "\r"]:
        result = result.replace(invalid, "_")
    return result

func _sanitize_for_json(value: Variant) -> Variant:
    if value is Dictionary:
        var result := {}
        for key_variant in (value as Dictionary).keys():
            result[str(key_variant)] = _sanitize_for_json((value as Dictionary)[key_variant])
        return result
    if value is Array:
        var result_array := []
        for item in (value as Array):
            result_array.append(_sanitize_for_json(item))
        return result_array
    if value is Vector2:
        var vector2_value: Vector2 = value
        return {"x": vector2_value.x, "y": vector2_value.y}
    if value is Vector2i:
        var vector2i_value: Vector2i = value
        return {"x": vector2i_value.x, "y": vector2i_value.y}
    return value
