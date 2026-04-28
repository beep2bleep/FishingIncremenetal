extends Node

const BALANCE := preload("res://Games/OpenPitEmpire/OpenPitEmpireBalance.gd")
const PROGRESS := preload("res://Games/OpenPitEmpire/OpenPitEmpireProgress.gd")
const MAIN_SCENE := preload("res://Games/OpenPitEmpire/Scenes/OpenPitEmpireMain.tscn")

const DEFAULT_MODES: Array[String] = ["normal", "fast_render", "no_render"]
const DEFAULT_MAX_SORTIES := 160
const DEFAULT_TIMEOUT_SECONDS := 1800.0
const BASE_SEED := 913572

var _modes: Array[String] = DEFAULT_MODES.duplicate()
var _max_sorties := DEFAULT_MAX_SORTIES
var _timeout_seconds := DEFAULT_TIMEOUT_SECONDS
var _report_dir := "user://validation"
var _exit_code := 0
var _backup_dir := "user://open_pit_empire_validation_save_backup"
var _validation_id := ""
var _perf_jsonl_path := ""
var _run_summary_jsonl_path := ""

func _ready() -> void:
    call_deferred("_run")

func _run() -> void:
    ProjectSettings.set_setting(Util.ACTIVE_GAME_PROJECT_SETTING, Util.ACTIVE_GAME_OPEN_PIT)
    _parse_args()
    DirAccess.make_dir_recursive_absolute(_global_path(_report_dir))
    _backup_dir = "%s/save_backup" % _report_dir
    _validation_id = Time.get_datetime_string_from_system(true, true).replace(":", "").replace("-", "").replace(" ", "_")
    _perf_jsonl_path = "%s/frame_rate_data.jsonl" % _report_dir
    _run_summary_jsonl_path = "%s/run_summaries.jsonl" % _report_dir

    var report := {
        "game": "Open Pit Empire",
        "validation_id": _validation_id,
        "date_utc": Time.get_datetime_string_from_system(true, true),
        "modes": [],
        "max_sorties": _max_sorties,
        "timeout_seconds": _timeout_seconds,
        "append_files": {
            "frame_rate_data": _global_path(_perf_jsonl_path),
            "run_summaries": _global_path(_run_summary_jsonl_path),
        },
    }
    _backup_existing_progress()
    var mode_results: Array[Dictionary] = []
    for mode in _modes:
        var result := await _run_mode(mode)
        mode_results.append(result)
        report["modes"].append(result)
        _write_json("%s/%s.json" % [_report_dir, mode], result)

    var comparison := _compare_mode_results(mode_results)
    report["comparison"] = comparison
    report["aggregate"] = _build_aggregate_summary(mode_results)
    _write_json("%s/summary.json" % _report_dir, report)
    _write_text("%s/summary.md" % _report_dir, _render_markdown_report(report))
    _restore_existing_progress()
    _exit_code = 0 if bool(comparison.get("ok", false)) else 1
    print("[OpenPitValidation] report=%s" % _global_path("%s/summary.md" % _report_dir))
    get_tree().quit(_exit_code)

func _parse_args() -> void:
    for arg in OS.get_cmdline_user_args():
        if arg.begins_with("--modes="):
            _modes.clear()
            for raw_mode in arg.trim_prefix("--modes=").split(",", false):
                var mode := str(raw_mode).strip_edges().to_lower()
                if mode != "":
                    _modes.append(mode)
        elif arg.begins_with("--max-sorties="):
            _max_sorties = maxi(1, int(arg.trim_prefix("--max-sorties=")))
        elif arg.begins_with("--timeout-seconds="):
            _timeout_seconds = maxf(5.0, float(arg.trim_prefix("--timeout-seconds=")))
        elif arg.begins_with("--report-dir="):
            _report_dir = arg.trim_prefix("--report-dir=").strip_edges()
    if _modes.is_empty():
        _modes = DEFAULT_MODES.duplicate()

func _run_mode(mode: String) -> Dictionary:
    print("[OpenPitValidation] mode=%s reset_progress" % mode)
    _reset_validation_progress()
    var started_msec := Time.get_ticks_msec()
    var sorties: Array[Dictionary] = []
    var purchases_by_cycle: Array[Dictionary] = []
    var end_reached := false
    var fail_reason := ""

    for sortie_index in range(_max_sorties):
        var data_before_purchase := PROGRESS.load_data()
        var purchase_result := _buy_all_affordable_upgrades()
        purchases_by_cycle.append(purchase_result)
        var data_before := PROGRESS.load_data()
        if _is_end_reached(data_before):
            end_reached = true
            break

        var run_summary := await _run_one_sortie(mode, sortie_index)
        var data_after := PROGRESS.load_data()
        var run_record := _build_run_record(
            mode,
            sortie_index,
            data_before_purchase,
            data_before,
            data_after,
            purchase_result,
            run_summary
        )
        sorties.append(run_record)
        _append_json_line(_perf_jsonl_path, _build_perf_record(run_record))
        _append_json_line(_run_summary_jsonl_path, _build_balance_record(run_record))
        print("[OpenPitValidation] mode=%s sortie=%d money=%d xp=%d cores=%d clear=%.3f boss=%s bought=%d" % [
            mode,
            sortie_index + 1,
            int(data_after.get("wallet", 0)),
            int(data_after.get("xp_currency", 0)),
            int(data_after.get("core_currency", 0)),
            float(run_record.get("persistent_clear", 0.0)),
            str(bool(data_after.get("boss_defeated", false))),
            int(purchase_result.get("count", 0)),
        ])
        if _is_end_reached(data_after):
            _buy_all_affordable_upgrades()
            end_reached = true
            break
        if float(Time.get_ticks_msec() - started_msec) / 1000.0 > _timeout_seconds:
            fail_reason = "Timed out after %.1f seconds." % _timeout_seconds
            break

    var final_data := PROGRESS.load_data()
    if not end_reached and fail_reason == "":
        fail_reason = "Reached max sorties (%d) before the end condition." % _max_sorties
    return {
        "mode": mode,
        "ok": end_reached,
        "fail_reason": fail_reason,
        "elapsed_seconds": float(Time.get_ticks_msec() - started_msec) / 1000.0,
        "sortie_count": sorties.size(),
        "sorties": sorties,
        "purchase_cycles": purchases_by_cycle,
        "final": _build_progress_signature(final_data),
    }

func _run_one_sortie(mode: String, sortie_index: int) -> Dictionary:
    var scene = MAIN_SCENE.instantiate()
    scene.validation_rng_seed = BASE_SEED + sortie_index
    scene.validation_autopilot_mode = mode
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
    summary["sortie_index"] = sortie_index
    scene.queue_free()
    await get_tree().process_frame
    return summary

func _build_run_record(mode: String, sortie_index: int, data_before_purchase: Dictionary, data_before_run: Dictionary, data_after_run: Dictionary, purchase_result: Dictionary, scene_summary: Dictionary) -> Dictionary:
    var run_time := float(scene_summary.get("run_time", 0.0))
    var mining_time := float(scene_summary.get("mining_time", 0.0))
    var nodes_mined := int(scene_summary.get("nodes_mined", 0))
    var money_gained := int(data_after_run.get("wallet", 0)) - int(data_before_run.get("wallet", 0))
    var xp_gained := int(data_after_run.get("xp_currency", 0)) - int(data_before_run.get("xp_currency", 0))
    var core_gained := int(data_after_run.get("core_currency", 0)) - int(data_before_run.get("core_currency", 0))
    var record := {
        "validation_id": _validation_id,
        "date_utc": Time.get_datetime_string_from_system(true, true),
        "mode": mode,
        "sortie_index": sortie_index,
        "run_number": sortie_index + 1,
        "seed": BASE_SEED + sortie_index,
        "depth_level": int(scene_summary.get("depth_level", 1)),
        "run_time_s": run_time,
        "mining_time_s": mining_time,
        "wall_elapsed_s": float(scene_summary.get("wall_elapsed_seconds", 0.0)),
        "rendered_frames": int(scene_summary.get("rendered_frames", 0)),
        "nodes_mined": nodes_mined,
        "nodes_per_run_second": float(nodes_mined) / maxf(run_time, 0.001),
        "nodes_per_mining_second": float(nodes_mined) / maxf(mining_time, 0.001),
        "money_gained": money_gained,
        "xp_gained": xp_gained,
        "core_currency_gained": core_gained,
        "cores_destroyed": int(scene_summary.get("cores_destroyed", 0)),
        "persistent_clear": float(scene_summary.get("persistent_clear", 0.0)),
        "boss_defeated": bool(data_after_run.get("boss_defeated", false)),
        "deepest_level_unlocked": int(data_after_run.get("deepest_level_unlocked", 1)),
        "wallet_before_purchase": int(data_before_purchase.get("wallet", 0)),
        "xp_before_purchase": int(data_before_purchase.get("xp_currency", 0)),
        "core_before_purchase": int(data_before_purchase.get("core_currency", 0)),
        "wallet_before_run": int(data_before_run.get("wallet", 0)),
        "xp_before_run": int(data_before_run.get("xp_currency", 0)),
        "core_before_run": int(data_before_run.get("core_currency", 0)),
        "wallet_after_run": int(data_after_run.get("wallet", 0)),
        "xp_after_run": int(data_after_run.get("xp_currency", 0)),
        "core_after_run": int(data_after_run.get("core_currency", 0)),
        "upgrades_bought_count": int(purchase_result.get("count", 0)),
        "upgrades_bought": Array(purchase_result.get("purchases", [])).duplicate(true),
        "autopilot_return_reason": str(scene_summary.get("autopilot_return_reason", "")),
        "perf": scene_summary.get("perf", {}),
    }
    return record

func _build_perf_record(run_record: Dictionary) -> Dictionary:
    return _sanitize_for_json({
        "validation_id": run_record.get("validation_id", ""),
        "date_utc": run_record.get("date_utc", ""),
        "mode": run_record.get("mode", ""),
        "run_number": int(run_record.get("run_number", 0)),
        "sortie_index": int(run_record.get("sortie_index", 0)),
        "seed": int(run_record.get("seed", 0)),
        "wall_elapsed_s": float(run_record.get("wall_elapsed_s", 0.0)),
        "rendered_frames": int(run_record.get("rendered_frames", 0)),
        "run_time_s": float(run_record.get("run_time_s", 0.0)),
        "mining_time_s": float(run_record.get("mining_time_s", 0.0)),
        "nodes_mined": int(run_record.get("nodes_mined", 0)),
        "persistent_clear": float(run_record.get("persistent_clear", 0.0)),
        "perf": run_record.get("perf", {}),
    })

func _build_balance_record(run_record: Dictionary) -> Dictionary:
    var balance_record := run_record.duplicate(true)
    balance_record.erase("perf")
    return _sanitize_for_json(balance_record)

func _buy_all_affordable_upgrades() -> Dictionary:
    var bought: Array[Dictionary] = []
    var pass_count := 0
    var bought_this_pass := true
    while bought_this_pass and pass_count < 128:
        bought_this_pass = false
        pass_count += 1
        for entry in BALANCE.get_upgrade_catalog():
            if _try_buy_upgrade(str(entry.get("id", "")), "cash", bought):
                bought_this_pass = true
        for entry in BALANCE.get_xp_upgrade_catalog():
            if _try_buy_upgrade(str(entry.get("id", "")), "xp", bought):
                bought_this_pass = true
        for entry in BALANCE.get_core_upgrade_catalog():
            var upgrade_id := str(entry.get("id", ""))
            if BALANCE.is_reward_core_upgrade(upgrade_id):
                continue
            if _try_buy_upgrade(upgrade_id, "core", bought):
                bought_this_pass = true
    return {"count": bought.size(), "purchases": bought}

func _try_buy_upgrade(upgrade_id: String, currency_kind: String, bought: Array[Dictionary]) -> bool:
    if upgrade_id == "":
        return false
    var data := PROGRESS.load_data()
    var current_level := _owned_level(data, upgrade_id)
    var max_level := _max_level(upgrade_id)
    if current_level >= max_level:
        return false
    if not _dependency_met(data, upgrade_id):
        return false
    var cost := _cost_for(upgrade_id, current_level)
    var wallet_key := _wallet_key(currency_kind)
    var wallet := int(data.get(wallet_key, 0))
    if wallet < cost:
        return false
    PROGRESS.apply_tree_purchase(upgrade_id, current_level + 1, wallet - cost)
    bought.append({
        "id": upgrade_id,
        "level": current_level + 1,
        "currency": currency_kind,
        "cost": cost,
    })
    return true

func _owned_level(data: Dictionary, upgrade_id: String) -> int:
    if BALANCE.is_core_upgrade(upgrade_id):
        var trimmed := upgrade_id.trim_prefix(BALANCE.CORE_PREFIX)
        return 1 if trimmed in Array(data.get("purchased_core_upgrades", [])) else 0
    if BALANCE.is_xp_upgrade(upgrade_id):
        return int(Dictionary(data.get("xp_upgrades", {})).get(upgrade_id, 0))
    return int(Dictionary(data.get("upgrades", {})).get(upgrade_id, 0))

func _max_level(upgrade_id: String) -> int:
    if BALANCE.is_core_upgrade(upgrade_id):
        return int(BALANCE.CORE_UPGRADES.get(upgrade_id.trim_prefix(BALANCE.CORE_PREFIX), {}).get("max_level", 1))
    if BALANCE.is_xp_upgrade(upgrade_id):
        return int(BALANCE.XP_UPGRADES.get(upgrade_id.trim_prefix(BALANCE.XP_PREFIX), {}).get("max_level", 1))
    return int(BALANCE.RAW_NODE_DATA.get(upgrade_id, {}).get("max_level", 1))

func _cost_for(upgrade_id: String, current_level: int) -> int:
    if BALANCE.is_core_upgrade(upgrade_id):
        return BALANCE.get_core_upgrade_cost(upgrade_id, current_level)
    if BALANCE.is_xp_upgrade(upgrade_id):
        return BALANCE.get_xp_upgrade_cost(upgrade_id, current_level)
    return BALANCE.get_upgrade_cost(upgrade_id, current_level)

func _dependency_met(data: Dictionary, upgrade_id: String) -> bool:
    var dependency := ""
    if BALANCE.is_core_upgrade(upgrade_id):
        dependency = BALANCE.get_core_upgrade_dependency(upgrade_id)
    elif BALANCE.is_xp_upgrade(upgrade_id):
        dependency = BALANCE.get_xp_upgrade_dependency(upgrade_id)
    else:
        dependency = BALANCE.get_upgrade_dependency(upgrade_id)
    if dependency == "" or dependency == "start":
        return true
    return _owned_level(data, dependency) > 0

func _wallet_key(currency_kind: String) -> String:
    match currency_kind:
        "xp":
            return "xp_currency"
        "core":
            return "core_currency"
        _:
            return "wallet"

func _is_end_reached(data: Dictionary) -> bool:
    return bool(data.get("boss_defeated", false)) or bool(data.get("planet_mastery_unlocked", false))

func _reset_validation_progress() -> void:
    PROGRESS.flush_async_planet_state_save()
    PROGRESS.clear_cache()
    _remove_path(PROGRESS.SAVE_PATH)
    _remove_path(PROGRESS.PLANET_SAVE_DIR)
    _remove_path(PROGRESS.LEGACY_PLANET_SAVE_PATH)
    PROGRESS.save_data(PROGRESS.get_default_data())
    PROGRESS.clear_runtime_planet_data()

func _build_progress_signature(data: Dictionary) -> Dictionary:
    return {
        "wallet": int(data.get("wallet", 0)),
        "xp_currency": int(data.get("xp_currency", 0)),
        "core_currency": int(data.get("core_currency", 0)),
        "deepest_level_unlocked": int(data.get("deepest_level_unlocked", 1)),
        "boss_defeated": bool(data.get("boss_defeated", false)),
        "bottom_phase_unlocked": bool(data.get("bottom_phase_unlocked", false)),
        "planet_mastery_unlocked": bool(data.get("planet_mastery_unlocked", false)),
        "free_planet_mode": bool(data.get("free_planet_mode", false)),
        "total_cores_destroyed": int(data.get("total_cores_destroyed", 0)),
        "upgrades": _sorted_dictionary(data.get("upgrades", {})),
        "xp_upgrades": _sorted_dictionary(data.get("xp_upgrades", {})),
        "purchased_core_upgrades": _sorted_array(data.get("purchased_core_upgrades", [])),
        "best_layer_clear_percents": _rounded_layer_percents(data.get("best_layer_clear_percents", {})),
    }

func _compare_mode_results(results: Array[Dictionary]) -> Dictionary:
    if results.is_empty():
        return {"ok": false, "differences": ["No validation modes ran."]}
    var differences: Array[String] = []
    var baseline := results[0]
    if not bool(baseline.get("ok", false)):
        differences.append("%s did not reach the end: %s" % [baseline.get("mode", "baseline"), baseline.get("fail_reason", "")])
    var baseline_final := JSON.stringify(baseline.get("final", {}))
    for idx in range(1, results.size()):
        var result := results[idx]
        if not bool(result.get("ok", false)):
            differences.append("%s did not reach the end: %s" % [result.get("mode", ""), result.get("fail_reason", "")])
        if JSON.stringify(result.get("final", {})) != baseline_final:
            differences.append("%s final progress differs from %s." % [result.get("mode", ""), baseline.get("mode", "")])
        if int(result.get("sortie_count", 0)) != int(baseline.get("sortie_count", 0)):
            differences.append("%s sortie count %d differs from %s sortie count %d." % [
                result.get("mode", ""),
                int(result.get("sortie_count", 0)),
                baseline.get("mode", ""),
                int(baseline.get("sortie_count", 0)),
            ])
    return {"ok": differences.is_empty(), "baseline_mode": baseline.get("mode", ""), "differences": differences}

func _build_aggregate_summary(results: Array[Dictionary]) -> Dictionary:
    var by_mode: Array[Dictionary] = []
    for mode_result in results:
        var runs: Array = mode_result.get("sorties", [])
        var total_money := 0
        var total_xp := 0
        var total_cores := 0
        var total_nodes := 0
        var total_mining_time := 0.0
        var total_wall_time := 0.0
        var worst_min_fps := 1000000
        var worst_frame_ms := 0.0
        var worst_cpu_ms := 0.0
        var worst_process_ms := 0.0
        var final_clear := 0.0
        for run_variant in runs:
            var run: Dictionary = run_variant
            total_money += int(run.get("money_gained", 0))
            total_xp += int(run.get("xp_gained", 0))
            total_cores += int(run.get("core_currency_gained", 0))
            total_nodes += int(run.get("nodes_mined", 0))
            total_mining_time += float(run.get("mining_time_s", 0.0))
            total_wall_time += float(run.get("wall_elapsed_s", 0.0))
            final_clear = float(run.get("persistent_clear", final_clear))
            var perf: Dictionary = run.get("perf", {})
            var extremes: Dictionary = perf.get("run_extremes", {})
            worst_min_fps = mini(worst_min_fps, int(extremes.get("min_fps", worst_min_fps)))
            worst_frame_ms = maxf(worst_frame_ms, float(extremes.get("max_frame_ms", 0.0)))
            worst_cpu_ms = maxf(worst_cpu_ms, float(extremes.get("max_cpu_ms", 0.0)))
            var worst_frame: Dictionary = perf.get("run_worst_frame", {})
            worst_process_ms = maxf(worst_process_ms, float(worst_frame.get("process_frame_ms", 0.0)))
        by_mode.append({
            "mode": str(mode_result.get("mode", "")),
            "ok": bool(mode_result.get("ok", false)),
            "sorties": runs.size(),
            "total_money": total_money,
            "total_xp": total_xp,
            "total_core_currency": total_cores,
            "total_nodes": total_nodes,
            "total_mining_time_s": total_mining_time,
            "total_wall_time_s": total_wall_time,
            "nodes_per_mining_second": float(total_nodes) / maxf(total_mining_time, 0.001),
            "money_per_mining_second": float(total_money) / maxf(total_mining_time, 0.001),
            "xp_per_mining_second": float(total_xp) / maxf(total_mining_time, 0.001),
            "final_clear": final_clear,
            "worst_min_fps": 0 if worst_min_fps == 1000000 else worst_min_fps,
            "worst_frame_ms": worst_frame_ms,
            "worst_cpu_ms": worst_cpu_ms,
            "worst_process_frame_ms": worst_process_ms,
        })
    return {"by_mode": by_mode}

func _sorted_dictionary(value: Variant) -> Dictionary:
    var result := {}
    if not (value is Dictionary):
        return result
    var keys := Array((value as Dictionary).keys())
    keys.sort()
    for key in keys:
        result[str(key)] = (value as Dictionary)[key]
    return result

func _rounded_layer_percents(value: Variant) -> Dictionary:
    var sorted := _sorted_dictionary(value)
    for key in sorted.keys():
        sorted[key] = snappedf(float(sorted[key]), 0.001)
    return sorted

func _sorted_array(value: Variant) -> Array:
    if not (value is Array):
        return []
    var result := Array(value).duplicate()
    result.sort()
    return result

func _write_json(path: String, data: Variant) -> void:
    _write_text(path, JSON.stringify(_sanitize_for_json(data), "\t"))

func _append_json_line(path: String, data: Variant) -> void:
    var global_path := _global_path(path)
    DirAccess.make_dir_recursive_absolute(global_path.get_base_dir())
    var file: FileAccess = null
    if FileAccess.file_exists(global_path):
        file = FileAccess.open(global_path, FileAccess.READ_WRITE)
        if file != null:
            file.seek_end()
    else:
        file = FileAccess.open(global_path, FileAccess.WRITE)
    if file == null:
        push_error("Could not append %s" % path)
        return
    file.store_line(JSON.stringify(_sanitize_for_json(data)))

func _write_text(path: String, text: String) -> void:
    var file := FileAccess.open(path, FileAccess.WRITE)
    if file == null:
        push_error("Could not write %s" % path)
        return
    file.store_string(text)

func _backup_existing_progress() -> void:
    _remove_path(_backup_dir)
    DirAccess.make_dir_recursive_absolute(_global_path(_backup_dir))
    _copy_path(PROGRESS.SAVE_PATH, "%s/open_pit_empire_save_v3.json" % _backup_dir)
    _copy_path(PROGRESS.PLANET_SAVE_DIR, "%s/open_pit_empire_planet_state_v3" % _backup_dir)
    _copy_path(PROGRESS.LEGACY_PLANET_SAVE_PATH, "%s/open_pit_empire_planet_state_v1.json" % _backup_dir)

func _restore_existing_progress() -> void:
    PROGRESS.clear_runtime_planet_data()
    _remove_path(PROGRESS.SAVE_PATH)
    _remove_path(PROGRESS.PLANET_SAVE_DIR)
    _remove_path(PROGRESS.LEGACY_PLANET_SAVE_PATH)
    _copy_path("%s/open_pit_empire_save_v3.json" % _backup_dir, PROGRESS.SAVE_PATH)
    _copy_path("%s/open_pit_empire_planet_state_v3" % _backup_dir, PROGRESS.PLANET_SAVE_DIR)
    _copy_path("%s/open_pit_empire_planet_state_v1.json" % _backup_dir, PROGRESS.LEGACY_PLANET_SAVE_PATH)
    _remove_path(_backup_dir)

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
    var target_parent := _global_path(target).get_base_dir()
    DirAccess.make_dir_recursive_absolute(target_parent)
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

func _render_markdown_report(report: Dictionary) -> String:
    var lines: Array[String] = []
    var comparison: Dictionary = report.get("comparison", {})
    lines.append("# Open Pit Empire Validation")
    lines.append("")
    lines.append("Result: **%s**" % ("PASS" if bool(comparison.get("ok", false)) else "FAIL"))
    lines.append("")
    lines.append("| Mode | End reached | Sorties | Elapsed | Wallet | XP | Cores | Boss |")
    lines.append("| --- | --- | ---: | ---: | ---: | ---: | ---: | --- |")
    for mode_result in Array(report.get("modes", [])):
        var final: Dictionary = Dictionary(mode_result).get("final", {})
        lines.append("| %s | %s | %d | %.2fs | %d | %d | %d | %s |" % [
            mode_result.get("mode", ""),
            "yes" if bool(mode_result.get("ok", false)) else "no",
            int(mode_result.get("sortie_count", 0)),
            float(mode_result.get("elapsed_seconds", 0.0)),
            int(final.get("wallet", 0)),
            int(final.get("xp_currency", 0)),
            int(final.get("core_currency", 0)),
            str(bool(final.get("boss_defeated", false))),
        ])
    var differences: Array = comparison.get("differences", [])
    if not differences.is_empty():
        lines.append("")
        lines.append("## Differences")
        for difference in differences:
            lines.append("- %s" % difference)
    lines.append("")
    lines.append("## Balance Summary")
    lines.append("")
    lines.append("| Mode | Sorties | Nodes | Money | XP | Cores | Mining Time | Nodes/s | Money/s | Worst FPS | Worst Frame |")
    lines.append("| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |")
    var aggregate: Dictionary = report.get("aggregate", {})
    for row_variant in Array(aggregate.get("by_mode", [])):
        var row: Dictionary = row_variant
        lines.append("| %s | %d | %d | %d | %d | %d | %.1f | %.3f | %.3f | %d | %.2fms |" % [
            str(row.get("mode", "")),
            int(row.get("sorties", 0)),
            int(row.get("total_nodes", 0)),
            int(row.get("total_money", 0)),
            int(row.get("total_xp", 0)),
            int(row.get("total_core_currency", 0)),
            float(row.get("total_mining_time_s", 0.0)),
            float(row.get("nodes_per_mining_second", 0.0)),
            float(row.get("money_per_mining_second", 0.0)),
            int(row.get("worst_min_fps", 0)),
            float(row.get("worst_frame_ms", 0.0)),
        ])
    lines.append("")
    lines.append("Detailed mode JSON files are written next to this report.")
    lines.append("Append-only ledgers:")
    lines.append("- Frame/perf data: `%s`" % str(Dictionary(report.get("append_files", {})).get("frame_rate_data", "")))
    lines.append("- Run summaries: `%s`" % str(Dictionary(report.get("append_files", {})).get("run_summaries", "")))
    return "\n".join(lines)
