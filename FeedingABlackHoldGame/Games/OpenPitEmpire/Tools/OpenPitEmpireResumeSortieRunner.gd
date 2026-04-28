extends Node

const PROGRESS := preload("res://Games/OpenPitEmpire/OpenPitEmpireProgress.gd")
const MAIN_SCENE := preload("res://Games/OpenPitEmpire/Scenes/OpenPitEmpireMain.tscn")

const DEFAULT_MODE := "fast_render"
const DEFAULT_SEED := 913732

var _source_json := ""
var _mode := DEFAULT_MODE
var _seed := DEFAULT_SEED
var _report_dir := "user://open_pit_empire_resume"
var _backup_dir := "user://open_pit_empire_resume/save_backup"

func _ready() -> void:
    call_deferred("_run")

func _run() -> void:
    ProjectSettings.set_setting(Util.ACTIVE_GAME_PROJECT_SETTING, Util.ACTIVE_GAME_OPEN_PIT)
    _parse_args()
    DirAccess.make_dir_recursive_absolute(_global_path(_report_dir))
    _backup_dir = "%s/save_backup" % _report_dir
    _backup_existing_progress()

    var source: Variant = _read_json(_source_json)
    if not (source is Dictionary):
        push_error("Could not read resume source: %s" % _source_json)
        _restore_existing_progress()
        get_tree().quit(1)
        return
    var final_state: Dictionary = Dictionary(source).get("final", {})
    if final_state.is_empty():
        push_error("Resume source did not contain a final progress signature: %s" % _source_json)
        _restore_existing_progress()
        get_tree().quit(1)
        return

    _install_progress_signature(final_state)
    var summary := await _run_one_sortie()
    _write_json("%s/resume_%s.json" % [_report_dir, _mode], summary)
    _restore_existing_progress()
    print("[OpenPitResume] report=%s" % _global_path("%s/resume_%s.json" % [_report_dir, _mode]))
    get_tree().quit(0)

func _parse_args() -> void:
    for arg in OS.get_cmdline_user_args():
        if arg.begins_with("--source-json="):
            _source_json = arg.trim_prefix("--source-json=").strip_edges()
        elif arg.begins_with("--mode="):
            _mode = arg.trim_prefix("--mode=").strip_edges().to_lower()
        elif arg.begins_with("--seed="):
            _seed = int(arg.trim_prefix("--seed="))
        elif arg.begins_with("--report-dir="):
            _report_dir = arg.trim_prefix("--report-dir=").strip_edges()

func _install_progress_signature(final_state: Dictionary) -> void:
    PROGRESS.flush_async_planet_state_save()
    PROGRESS.clear_cache()
    PROGRESS.clear_runtime_planet_data()
    _remove_path(PROGRESS.SAVE_PATH)
    _remove_path(PROGRESS.PLANET_SAVE_DIR)
    _remove_path(PROGRESS.LEGACY_PLANET_SAVE_PATH)

    var data := PROGRESS.get_default_data()
    data["wallet"] = int(final_state.get("wallet", 0))
    data["xp_currency"] = int(final_state.get("xp_currency", 0))
    data["core_currency"] = int(final_state.get("core_currency", 0))
    data["deepest_level_unlocked"] = int(final_state.get("deepest_level_unlocked", 1))
    data["selected_depth_level"] = 1
    data["upgrades"] = Dictionary(final_state.get("upgrades", {})).duplicate(true)
    data["xp_upgrades"] = Dictionary(final_state.get("xp_upgrades", {})).duplicate(true)
    data["purchased_core_upgrades"] = Array(final_state.get("purchased_core_upgrades", [])).duplicate(true)
    data["total_cores_destroyed"] = int(final_state.get("total_cores_destroyed", 0))
    data["boss_defeated"] = bool(final_state.get("boss_defeated", false))
    data["planet_mastery_unlocked"] = bool(final_state.get("planet_mastery_unlocked", false))
    data["free_planet_mode"] = bool(final_state.get("free_planet_mode", false))
    data["bottom_phase_unlocked"] = bool(final_state.get("bottom_phase_unlocked", false))
    data["best_layer_clear_percents"] = Dictionary(final_state.get("best_layer_clear_percents", {})).duplicate(true)
    data["last_run_summary"] = "Resumed from validation final signature."
    PROGRESS.save_data(data)
    PROGRESS.clear_planet_state()

func _run_one_sortie() -> Dictionary:
    var scene = MAIN_SCENE.instantiate()
    scene.validation_rng_seed = _seed
    scene.validation_autopilot_mode = _mode
    var wall_started_msec := Time.get_ticks_msec()
    get_tree().root.add_child(scene)
    await get_tree().process_frame
    var frames := 0
    while not bool(scene.run_finished):
        frames += 1
        await get_tree().process_frame
    while bool(scene.summary_save_pending):
        frames += 1
        await get_tree().process_frame
    var summary: Dictionary = scene.get_validation_run_summary()
    summary["wall_elapsed_seconds"] = float(Time.get_ticks_msec() - wall_started_msec) / 1000.0
    summary["rendered_frames"] = frames
    summary["perf"] = scene.get_validation_perf_summary()
    summary["mode"] = _mode
    summary["seed"] = _seed
    summary["source_json"] = _source_json
    scene.queue_free()
    await get_tree().process_frame
    return _sanitize_for_json(summary)

func _read_json(path: String) -> Variant:
    var global_path := _global_path(path)
    var file := FileAccess.open(global_path, FileAccess.READ)
    if file == null:
        return null
    return JSON.parse_string(file.get_as_text())

func _write_json(path: String, data: Variant) -> void:
    var global_path := _global_path(path)
    DirAccess.make_dir_recursive_absolute(global_path.get_base_dir())
    var file := FileAccess.open(global_path, FileAccess.WRITE)
    if file == null:
        push_error("Could not write %s" % path)
        return
    file.store_string(JSON.stringify(_sanitize_for_json(data), "\t"))

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

func _global_path(path: String) -> String:
    if path.begins_with("user://") or path.begins_with("res://"):
        return ProjectSettings.globalize_path(path)
    return path

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
