extends Node

const BALANCE := preload("res://Games/OpenPitEmpire/OpenPitEmpireBalance.gd")
const PROGRESS := preload("res://Games/OpenPitEmpire/OpenPitEmpireProgress.gd")
const MAIN_SCENE := preload("res://Games/OpenPitEmpire/Scenes/OpenPitEmpireMain.tscn")

const DEFAULT_MODES: Array[String] = ["normal", "fast_render", "no_render"]
const DEFAULT_MAX_SORTIES := 160
const DEFAULT_TIMEOUT_SECONDS := 1800.0
const CHECKPOINT_INTERVAL_SORTIES := 10
const BASE_SEED := 913572

var _modes: Array[String] = DEFAULT_MODES.duplicate()
var _mode_sequence: Array[Dictionary] = []
var _max_sorties := DEFAULT_MAX_SORTIES
var _timeout_seconds := DEFAULT_TIMEOUT_SECONDS
var _report_dir := "user://validation"
var _continue_current_progress := false
var _restore_progress_after_run := true
var _skip_first_purchase := false
var _start_sortie_index := 0
var _resume_checkpoint_path := ""
var _exit_code := 0
var _backup_dir := "user://open_pit_empire_validation_save_backup"
var _validation_id := ""
var _perf_jsonl_path := ""
var _run_summary_jsonl_path := ""
var _checkpoint_run_dir := ""
var _resume_checkpoint_manifest: Dictionary = {}

func _ready() -> void:
    call_deferred("_run")

func _run() -> void:
    ProjectSettings.set_setting(Util.ACTIVE_GAME_PROJECT_SETTING, Util.ACTIVE_GAME_OPEN_PIT)
    _parse_args()
    DirAccess.make_dir_recursive_absolute(_global_path(_report_dir))
    _backup_dir = "%s/save_backup" % _report_dir
    _validation_id = Time.get_datetime_string_from_system(true, true).replace(":", "").replace("-", "").replace(" ", "_")
    if _resume_checkpoint_path != "":
        _resume_checkpoint_manifest = _read_checkpoint_manifest(_resume_checkpoint_path)
        if not FileAccess.file_exists(_global_path("%s/open_pit_empire_save_v3.json" % _resume_checkpoint_path)):
            push_error("Resume checkpoint is missing open_pit_empire_save_v3.json: %s" % _global_path(_resume_checkpoint_path))
            get_tree().quit(1)
            return
        if _start_sortie_index <= 0:
            _start_sortie_index = int(_resume_checkpoint_manifest.get("next_sortie_index", _resume_checkpoint_manifest.get("completed_sorties", _infer_completed_sorties_from_checkpoint_path(_resume_checkpoint_path))))
        _checkpoint_run_dir = "%s/checkpoints/%s_from_%s" % [_report_dir, _validation_id, _checkpoint_source_label(_resume_checkpoint_path)]
    else:
        _checkpoint_run_dir = "%s/checkpoints/%s" % [_report_dir, _validation_id]
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
        "checkpoint_dir": _global_path(_checkpoint_run_dir),
        "resumed_from_checkpoint": _global_path(_resume_checkpoint_path) if _resume_checkpoint_path != "" else "",
    }
    if _restore_progress_after_run:
        _backup_existing_progress()
    var mode_results: Array[Dictionary] = []
    if not _mode_sequence.is_empty():
        var sequence_result := await _run_mode_sequence(_mode_sequence)
        mode_results.append(sequence_result)
        report["modes"].append(sequence_result)
        report["sequence"] = _mode_sequence
        _write_json("%s/sequence.json" % _report_dir, sequence_result)
    else:
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
    if _restore_progress_after_run:
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
        elif arg.begins_with("--sequence="):
            _mode_sequence = _parse_mode_sequence(arg.trim_prefix("--sequence="))
        elif arg.begins_with("--max-sorties="):
            _max_sorties = maxi(1, int(arg.trim_prefix("--max-sorties=")))
        elif arg.begins_with("--timeout-seconds="):
            _timeout_seconds = maxf(5.0, float(arg.trim_prefix("--timeout-seconds=")))
        elif arg.begins_with("--report-dir="):
            _report_dir = arg.trim_prefix("--report-dir=").strip_edges()
        elif arg == "--continue-current":
            _continue_current_progress = true
        elif arg == "--no-restore":
            _restore_progress_after_run = false
        elif arg == "--skip-first-purchase":
            _skip_first_purchase = true
        elif arg.begins_with("--start-sortie-index="):
            _start_sortie_index = maxi(0, int(arg.trim_prefix("--start-sortie-index=")))
        elif arg.begins_with("--resume-checkpoint="):
            _resume_checkpoint_path = arg.trim_prefix("--resume-checkpoint=").strip_edges()
    if _modes.is_empty():
        _modes = DEFAULT_MODES.duplicate()

func _parse_mode_sequence(raw_sequence: String) -> Array[Dictionary]:
    var sequence: Array[Dictionary] = []
    for raw_part in raw_sequence.split(",", false):
        var part := str(raw_part).strip_edges().to_lower()
        if part == "":
            continue
        var pieces := part.split(":", false)
        if pieces.size() != 2:
            continue
        var mode := str(pieces[0]).strip_edges()
        var count := maxi(0, int(str(pieces[1]).strip_edges()))
        if mode != "" and count > 0:
            sequence.append({"mode": mode, "count": count})
    return sequence

func _run_mode(mode: String) -> Dictionary:
    if _resume_checkpoint_path != "":
        print("[OpenPitValidation] mode=%s resume_checkpoint=%s start_sortie_index=%d" % [mode, _global_path(_resume_checkpoint_path), _start_sortie_index])
        _restore_checkpoint_to_progress(_resume_checkpoint_path)
    else:
        print("[OpenPitValidation] mode=%s reset_progress" % mode)
        _reset_validation_progress()
    var started_msec := Time.get_ticks_msec()
    var sorties: Array[Dictionary] = []
    var purchases_by_cycle: Array[Dictionary] = []
    var end_reached := false
    var fail_reason := ""
    var first_sortie_index := _start_sortie_index if _resume_checkpoint_path != "" else 0

    for sortie_index in range(first_sortie_index, _max_sorties):
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
        if _should_save_perf_data_for_mode(mode):
            _append_json_line(_perf_jsonl_path, _build_perf_record(run_record))
        _append_json_line(_run_summary_jsonl_path, _build_balance_record(run_record))
        print("[OpenPitValidation] mode=%s sortie=%d auto=%s return=%s cargo=%d/%d fuel=%.1f/%.1fs money=%d xp=%d cores=%d clear=%.3f remaining=%s live_remaining=%s boss=%s bought=%d" % [
            mode,
            sortie_index + 1,
            str(run_record.get("autopilot_sortie_mode", "")),
            str(run_record.get("autopilot_return_reason", "")),
            int(run_record.get("end_cargo_units", 0)),
            int(run_record.get("end_cargo_capacity", 0)),
            float(run_record.get("end_fuel_left_s", 0.0)),
            float(run_record.get("end_fuel_capacity_s", 0.0)),
            int(data_after.get("wallet", 0)),
            int(data_after.get("xp_currency", 0)),
            int(data_after.get("core_currency", 0)),
            float(run_record.get("persistent_clear", 0.0)),
            _format_layer_block_counts(run_record.get("remaining_layer_block_counts", {})),
            _format_layer_block_counts(run_record.get("live_remaining_layer_block_counts", {})),
            str(bool(data_after.get("boss_defeated", false))),
            int(purchase_result.get("count", 0)),
        ])
        if (sortie_index + 1) % CHECKPOINT_INTERVAL_SORTIES == 0:
            _write_validation_checkpoint(mode, sortie_index + 1, run_record)
        if _is_end_reached(data_after):
            _buy_all_affordable_upgrades()
            end_reached = true
            break
        if float(Time.get_ticks_msec() - started_msec) / 1000.0 > _timeout_seconds:
            fail_reason = "Timed out after %.1f seconds." % _timeout_seconds
            break

    var final_data := PROGRESS.load_data()
    if not end_reached and fail_reason == "":
        fail_reason = "Reached max sortie index (%d) before the end condition." % _max_sorties
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

func _run_mode_sequence(sequence: Array[Dictionary]) -> Dictionary:
    var schedule_text: Array[String] = []
    var planned_sorties := 0
    for segment in sequence:
        planned_sorties += int(segment.get("count", 0))
        schedule_text.append("%s:%d" % [str(segment.get("mode", "")), int(segment.get("count", 0))])
    if _continue_current_progress:
        print("[OpenPitValidation] sequence=%s continue_current start_sortie_index=%d" % [",".join(schedule_text), _start_sortie_index])
    elif _resume_checkpoint_path != "":
        print("[OpenPitValidation] sequence=%s resume_checkpoint=%s start_sortie_index=%d" % [",".join(schedule_text), _global_path(_resume_checkpoint_path), _start_sortie_index])
        _restore_checkpoint_to_progress(_resume_checkpoint_path)
    else:
        print("[OpenPitValidation] sequence=%s reset_progress" % ",".join(schedule_text))
        _reset_validation_progress()
    var started_msec := Time.get_ticks_msec()
    var sorties: Array[Dictionary] = []
    var purchases_by_cycle: Array[Dictionary] = []
    var end_reached := false
    var fail_reason := ""
    var global_sortie_index := _start_sortie_index
    var planned_total := _start_sortie_index + planned_sorties

    for segment_index in range(sequence.size()):
        var segment: Dictionary = sequence[segment_index]
        var mode := str(segment.get("mode", "")).strip_edges().to_lower()
        var count := int(segment.get("count", 0))
        for segment_sortie_index in range(count):
            var data_before_purchase := PROGRESS.load_data()
            var purchase_result := {"count": 0, "purchases": []}
            if not (_skip_first_purchase and sorties.is_empty()):
                purchase_result = _buy_all_affordable_upgrades()
            purchases_by_cycle.append(purchase_result)
            var data_before := PROGRESS.load_data()
            if _is_end_reached(data_before):
                end_reached = true
                break

            var run_summary := await _run_one_sortie(mode, global_sortie_index)
            var data_after := PROGRESS.load_data()
            var run_record := _build_run_record(
                mode,
                global_sortie_index,
                data_before_purchase,
                data_before,
                data_after,
                purchase_result,
                run_summary
            )
            run_record["sequence_mode"] = "sequence"
            run_record["sequence_segment_index"] = segment_index
            run_record["sequence_segment_run_number"] = segment_sortie_index + 1
            sorties.append(run_record)
            if _should_save_perf_data_for_mode(mode):
                _append_json_line(_perf_jsonl_path, _build_perf_record(run_record))
            _append_json_line(_run_summary_jsonl_path, _build_balance_record(run_record))
            print("[OpenPitValidation] sequence sortie=%d/%d mode=%s segment_run=%d/%d auto=%s return=%s cargo=%d/%d fuel=%.1f/%.1fs money=%d xp=%d cores=%d clear=%.3f remaining=%s live_remaining=%s boss=%s bought=%d auto_buy=\"%s\"" % [
                global_sortie_index + 1,
                planned_total,
                mode,
                segment_sortie_index + 1,
                count,
                str(run_record.get("autopilot_sortie_mode", "")),
                str(run_record.get("autopilot_return_reason", "")),
                int(run_record.get("end_cargo_units", 0)),
                int(run_record.get("end_cargo_capacity", 0)),
                float(run_record.get("end_fuel_left_s", 0.0)),
                float(run_record.get("end_fuel_capacity_s", 0.0)),
                int(data_after.get("wallet", 0)),
                int(data_after.get("xp_currency", 0)),
                int(data_after.get("core_currency", 0)),
                float(run_record.get("persistent_clear", 0.0)),
                _format_layer_block_counts(run_record.get("remaining_layer_block_counts", {})),
                _format_layer_block_counts(run_record.get("live_remaining_layer_block_counts", {})),
                str(bool(data_after.get("boss_defeated", false))),
                int(purchase_result.get("count", 0)),
                _format_purchase_summary(purchase_result),
            ])
            if (global_sortie_index + 1) % CHECKPOINT_INTERVAL_SORTIES == 0:
                _write_validation_checkpoint("sequence_%s" % mode, global_sortie_index + 1, run_record)
            global_sortie_index += 1
            if _is_end_reached(data_after):
                _buy_all_affordable_upgrades()
                end_reached = true
                break
            if float(Time.get_ticks_msec() - started_msec) / 1000.0 > _timeout_seconds:
                fail_reason = "Timed out after %.1f seconds." % _timeout_seconds
                break
        if end_reached or fail_reason != "":
            break

    var final_data := PROGRESS.load_data()
    if not end_reached and fail_reason == "":
        fail_reason = "Completed scheduled sorties (%d) before the end condition." % planned_sorties
    return {
        "mode": "sequence",
        "ok": end_reached,
        "fail_reason": fail_reason,
        "elapsed_seconds": float(Time.get_ticks_msec() - started_msec) / 1000.0,
        "sortie_count": sorties.size(),
        "planned_sorties": planned_sorties,
        "sequence": sequence,
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
    if scene.has_method("should_save_validation_perf_data") and bool(scene.call("should_save_validation_perf_data")):
        summary["perf"] = scene.get_validation_perf_summary()
    summary["sortie_index"] = sortie_index
    scene.queue_free()
    await get_tree().process_frame
    return summary

func _build_run_record(mode: String, sortie_index: int, data_before_purchase: Dictionary, data_before_run: Dictionary, data_after_run: Dictionary, purchase_result: Dictionary, scene_summary: Dictionary) -> Dictionary:
    var run_time := float(scene_summary.get("run_time", 0.0))
    var mining_time := float(scene_summary.get("mining_time", 0.0))
    var nodes_mined := int(scene_summary.get("nodes_mined", 0))
    var end_cargo_units := int(scene_summary.get("end_cargo_units", scene_summary.get("cargo_units", 0)))
    var end_cargo_capacity := int(scene_summary.get("end_cargo_capacity", scene_summary.get("cargo_capacity", 0)))
    var end_fuel_left := float(scene_summary.get("end_fuel_left_s", scene_summary.get("fuel_left_s", scene_summary.get("time_left", 0.0))))
    var end_fuel_capacity := float(scene_summary.get("end_fuel_capacity_s", scene_summary.get("fuel_capacity_s", run_time)))
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
        "end_cargo_units": end_cargo_units,
        "end_cargo_capacity": end_cargo_capacity,
        "end_cargo_fill_ratio": float(end_cargo_units) / maxf(float(end_cargo_capacity), 0.001),
        "end_fuel_left_s": end_fuel_left,
        "end_fuel_capacity_s": end_fuel_capacity,
        "end_fuel_used_s": maxf(0.0, end_fuel_capacity - end_fuel_left),
        "end_fuel_left_ratio": end_fuel_left / maxf(end_fuel_capacity, 0.001),
        "money_gained": money_gained,
        "xp_gained": xp_gained,
        "core_currency_gained": core_gained,
        "cores_destroyed": int(scene_summary.get("cores_destroyed", 0)),
        "persistent_clear": float(scene_summary.get("persistent_clear", 0.0)),
        "remaining_layer_block_counts": _normalized_layer_block_counts(data_after_run.get("remaining_layer_block_counts", scene_summary.get("remaining_layer_block_counts", {}))),
        "live_remaining_layer_block_counts": _normalized_layer_block_counts(scene_summary.get("remaining_layer_block_counts", {})),
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
        "autopilot_mode": str(scene_summary.get("autopilot_mode", "")),
        "autopilot_sortie_mode": str(scene_summary.get("autopilot_sortie_mode", "")),
        "autopilot_status": str(scene_summary.get("autopilot_status", "")),
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

func _should_save_perf_data_for_mode(mode: String) -> bool:
    return not (mode.strip_edges().to_lower() in ["fast_render", "fast", "max_render", "no_render", "norender", "sprint"])

func _build_balance_record(run_record: Dictionary) -> Dictionary:
    var balance_record := run_record.duplicate(true)
    balance_record.erase("perf")
    return _sanitize_for_json(balance_record)

func _format_purchase_summary(purchase_result: Dictionary, max_items: int = 8) -> String:
    var purchases: Array = purchase_result.get("purchases", [])
    if purchases.is_empty():
        return "none"
    var parts: Array[String] = []
    var limit := mini(max_items, purchases.size())
    for index in range(limit):
        var purchase: Dictionary = purchases[index]
        parts.append("%s L%d %s%d" % [
            _get_upgrade_label(str(purchase.get("id", ""))),
            int(purchase.get("level", 0)),
            _currency_symbol(str(purchase.get("currency", ""))),
            int(purchase.get("cost", 0)),
        ])
    if purchases.size() > limit:
        parts.append("+%d more" % (purchases.size() - limit))
    return "; ".join(parts)

func _normalized_layer_block_counts(source: Variant) -> Dictionary:
    var counts := {}
    for layer_depth in range(1, 6):
        counts[layer_depth] = 0
    if source is Dictionary:
        var source_dict: Dictionary = source
        for key_variant in source_dict.keys():
            var layer_depth := int(key_variant)
            if layer_depth < 1 or layer_depth > 5:
                continue
            counts[layer_depth] = maxi(0, int(source_dict[key_variant]))
    return counts

func _format_layer_block_counts(source: Variant) -> String:
    var counts := _normalized_layer_block_counts(source)
    var parts: Array[String] = []
    for layer_depth in range(1, 6):
        parts.append("L%d=%d" % [layer_depth, int(counts.get(layer_depth, 0))])
    return " ".join(parts)

func _get_upgrade_label(upgrade_id: String) -> String:
    if BALANCE.is_core_upgrade(upgrade_id):
        var core_id := upgrade_id.trim_prefix(BALANCE.CORE_PREFIX)
        return str(BALANCE.CORE_UPGRADES.get(core_id, {}).get("label", core_id))
    if BALANCE.is_xp_upgrade(upgrade_id):
        var xp_id := upgrade_id.trim_prefix(BALANCE.XP_PREFIX)
        return str(BALANCE.XP_UPGRADES.get(xp_id, {}).get("label", xp_id))
    return str(BALANCE.RAW_NODE_DATA.get(upgrade_id, {}).get("label", upgrade_id))

func _currency_symbol(currency_kind: String) -> String:
    match currency_kind:
        "cash":
            return "$"
        "xp":
            return "XP "
        "core":
            return "core "
    return "%s " % currency_kind

func _buy_all_affordable_upgrades() -> Dictionary:
    var bought: Array[Dictionary] = []
    var data := PROGRESS.load_data()
    var cash_catalog := BALANCE.get_upgrade_catalog()
    var xp_catalog := BALANCE.get_xp_upgrade_catalog()
    var core_catalog := BALANCE.get_core_upgrade_catalog()
    var pass_count := 0
    var bought_this_pass := true
    while bought_this_pass and pass_count < 128:
        bought_this_pass = false
        pass_count += 1
        for entry in cash_catalog:
            if _try_buy_upgrade_in_data(data, str(entry.get("id", "")), "cash", bought):
                bought_this_pass = true
        for entry in xp_catalog:
            if _try_buy_upgrade_in_data(data, str(entry.get("id", "")), "xp", bought):
                bought_this_pass = true
        for entry in core_catalog:
            var upgrade_id := str(entry.get("id", ""))
            if BALANCE.is_reward_core_upgrade(upgrade_id):
                continue
            if _try_buy_upgrade_in_data(data, upgrade_id, "core", bought):
                bought_this_pass = true
    if not bought.is_empty():
        PROGRESS.save_data(data)
    return {"count": bought.size(), "purchases": bought}

func _try_buy_upgrade_in_data(data: Dictionary, upgrade_id: String, currency_kind: String, bought: Array[Dictionary]) -> bool:
    if upgrade_id == "":
        return false
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
    if BALANCE.is_core_upgrade(upgrade_id):
        var core_upgrade_id := upgrade_id.trim_prefix(BALANCE.CORE_PREFIX)
        var purchased: Array = data.get("purchased_core_upgrades", []).duplicate()
        if core_upgrade_id not in purchased:
            purchased.append(core_upgrade_id)
        data["purchased_core_upgrades"] = purchased
        if core_upgrade_id == "planet_mastery":
            data["planet_mastery_unlocked"] = true
            data["free_planet_mode"] = true
        elif core_upgrade_id == "center_unlock":
            data["free_planet_mode"] = false
    elif BALANCE.is_xp_upgrade(upgrade_id):
        var xp_upgrades: Dictionary = data.get("xp_upgrades", {}).duplicate(true)
        xp_upgrades[upgrade_id] = current_level + 1
        data["xp_upgrades"] = xp_upgrades
    else:
        var upgrades: Dictionary = data.get("upgrades", {}).duplicate(true)
        upgrades[upgrade_id] = current_level + 1
        data["upgrades"] = upgrades
        BALANCE.refresh_depth_unlocks(data)
    data[wallet_key] = max(0, wallet - cost)
    bought.append({
        "id": upgrade_id,
        "level": current_level + 1,
        "currency": currency_kind,
        "cost": cost,
    })
    return true

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
        "remaining_layer_block_counts": _normalized_layer_block_counts(data.get("remaining_layer_block_counts", {})),
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
        var cargo_ratio_total := 0.0
        var fuel_ratio_total := 0.0
        var return_reason_buckets := {}
        for run_variant in runs:
            var run: Dictionary = run_variant
            total_money += int(run.get("money_gained", 0))
            total_xp += int(run.get("xp_gained", 0))
            total_cores += int(run.get("core_currency_gained", 0))
            total_nodes += int(run.get("nodes_mined", 0))
            total_mining_time += float(run.get("mining_time_s", 0.0))
            total_wall_time += float(run.get("wall_elapsed_s", 0.0))
            var cargo_ratio := float(run.get("end_cargo_fill_ratio", 0.0))
            var fuel_ratio := float(run.get("end_fuel_left_ratio", 0.0))
            cargo_ratio_total += cargo_ratio
            fuel_ratio_total += fuel_ratio
            var return_reason := str(run.get("autopilot_return_reason", ""))
            if return_reason == "":
                return_reason = "unknown"
            if not return_reason_buckets.has(return_reason):
                return_reason_buckets[return_reason] = {
                    "reason": return_reason,
                    "count": 0,
                    "cargo_ratio_total": 0.0,
                    "fuel_ratio_total": 0.0,
                    "min_cargo_ratio": INF,
                    "max_cargo_ratio": 0.0,
                    "min_fuel_ratio": INF,
                    "max_fuel_ratio": 0.0,
                }
            var bucket: Dictionary = return_reason_buckets[return_reason]
            bucket["count"] = int(bucket.get("count", 0)) + 1
            bucket["cargo_ratio_total"] = float(bucket.get("cargo_ratio_total", 0.0)) + cargo_ratio
            bucket["fuel_ratio_total"] = float(bucket.get("fuel_ratio_total", 0.0)) + fuel_ratio
            bucket["min_cargo_ratio"] = minf(float(bucket.get("min_cargo_ratio", INF)), cargo_ratio)
            bucket["max_cargo_ratio"] = maxf(float(bucket.get("max_cargo_ratio", 0.0)), cargo_ratio)
            bucket["min_fuel_ratio"] = minf(float(bucket.get("min_fuel_ratio", INF)), fuel_ratio)
            bucket["max_fuel_ratio"] = maxf(float(bucket.get("max_fuel_ratio", 0.0)), fuel_ratio)
            return_reason_buckets[return_reason] = bucket
            final_clear = float(run.get("persistent_clear", final_clear))
            var perf: Dictionary = run.get("perf", {})
            var extremes: Dictionary = perf.get("run_extremes", {})
            worst_min_fps = mini(worst_min_fps, int(extremes.get("min_fps", worst_min_fps)))
            worst_frame_ms = maxf(worst_frame_ms, float(extremes.get("max_frame_ms", 0.0)))
            worst_cpu_ms = maxf(worst_cpu_ms, float(extremes.get("max_cpu_ms", 0.0)))
            var worst_frame: Dictionary = perf.get("run_worst_frame", {})
            worst_process_ms = maxf(worst_process_ms, float(worst_frame.get("process_frame_ms", 0.0)))
        var return_reasons: Array[Dictionary] = []
        for reason_key in return_reason_buckets.keys():
            var bucket: Dictionary = return_reason_buckets[reason_key]
            var count := int(bucket.get("count", 0))
            return_reasons.append({
                "reason": str(bucket.get("reason", "")),
                "count": count,
                "avg_cargo_fill_ratio": float(bucket.get("cargo_ratio_total", 0.0)) / float(maxi(1, count)),
                "avg_fuel_left_ratio": float(bucket.get("fuel_ratio_total", 0.0)) / float(maxi(1, count)),
                "min_cargo_fill_ratio": 0.0 if float(bucket.get("min_cargo_ratio", INF)) == INF else float(bucket.get("min_cargo_ratio", 0.0)),
                "max_cargo_fill_ratio": float(bucket.get("max_cargo_ratio", 0.0)),
                "min_fuel_left_ratio": 0.0 if float(bucket.get("min_fuel_ratio", INF)) == INF else float(bucket.get("min_fuel_ratio", 0.0)),
                "max_fuel_left_ratio": float(bucket.get("max_fuel_ratio", 0.0)),
            })
        return_reasons.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
            if int(a.get("count", 0)) != int(b.get("count", 0)):
                return int(a.get("count", 0)) > int(b.get("count", 0))
            return str(a.get("reason", "")) < str(b.get("reason", ""))
        )
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
            "avg_end_cargo_fill_ratio": cargo_ratio_total / float(maxi(1, runs.size())),
            "avg_end_fuel_left_ratio": fuel_ratio_total / float(maxi(1, runs.size())),
            "return_reasons": return_reasons,
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
    var global_path := _global_path(path)
    DirAccess.make_dir_recursive_absolute(global_path.get_base_dir())
    var file := FileAccess.open(global_path, FileAccess.WRITE)
    if file == null:
        push_error("Could not write %s" % path)
        return
    file.store_string(text)

func _write_validation_checkpoint(mode: String, completed_sorties: int, run_record: Dictionary) -> void:
    PROGRESS.flush_async_planet_state_save()
    PROGRESS.clear_cache()
    var safe_mode := _safe_path_segment(mode)
    var checkpoint_name := "sortie_%04d" % completed_sorties
    var checkpoint_dir := "%s/%s/%s" % [_checkpoint_run_dir, safe_mode, checkpoint_name]
    _remove_path(checkpoint_dir)
    DirAccess.make_dir_recursive_absolute(_global_path(checkpoint_dir))
    _copy_path(PROGRESS.SAVE_PATH, "%s/open_pit_empire_save_v3.json" % checkpoint_dir)
    _copy_path(PROGRESS.PLANET_SAVE_DIR, "%s/open_pit_empire_planet_state_v3" % checkpoint_dir)
    _copy_path(PROGRESS.LEGACY_PLANET_SAVE_PATH, "%s/open_pit_empire_planet_state_v1.json" % checkpoint_dir)
    var manifest := {
        "game": "Open Pit Empire",
        "validation_id": _validation_id,
        "date_utc": Time.get_datetime_string_from_system(true, true),
        "mode": mode,
        "completed_sorties": completed_sorties,
        "next_sortie_index": completed_sorties,
        "checkpoint_interval_sorties": CHECKPOINT_INTERVAL_SORTIES,
        "checkpoint_dir": _global_path(checkpoint_dir),
        "resumed_from_checkpoint": _global_path(_resume_checkpoint_path) if _resume_checkpoint_path != "" else "",
        "run_record": _sanitize_for_json(run_record),
    }
    _write_json("%s/manifest.json" % checkpoint_dir, manifest)
    print("[OpenPitValidation] checkpoint=%s completed_sorties=%d" % [_global_path(checkpoint_dir), completed_sorties])

func _restore_checkpoint_to_progress(checkpoint_path: String) -> void:
    PROGRESS.flush_async_planet_state_save()
    PROGRESS.clear_cache()
    PROGRESS.clear_runtime_planet_data()
    _remove_path(PROGRESS.SAVE_PATH)
    _remove_path(PROGRESS.PLANET_SAVE_DIR)
    _remove_path(PROGRESS.LEGACY_PLANET_SAVE_PATH)
    _copy_path("%s/open_pit_empire_save_v3.json" % checkpoint_path, PROGRESS.SAVE_PATH)
    _copy_path("%s/open_pit_empire_planet_state_v3" % checkpoint_path, PROGRESS.PLANET_SAVE_DIR)
    _copy_path("%s/open_pit_empire_planet_state_v1.json" % checkpoint_path, PROGRESS.LEGACY_PLANET_SAVE_PATH)
    PROGRESS.clear_cache()

func _read_checkpoint_manifest(checkpoint_path: String) -> Dictionary:
    var manifest_path := "%s/manifest.json" % checkpoint_path
    var file := FileAccess.open(_global_path(manifest_path), FileAccess.READ)
    if file == null:
        return {}
    var parsed: Variant = JSON.parse_string(file.get_as_text())
    if parsed is Dictionary:
        return parsed
    return {}

func _checkpoint_source_label(checkpoint_path: String) -> String:
    var normalized := checkpoint_path.replace("\\", "/").trim_suffix("/")
    var checkpoint_name := normalized.get_file()
    var parent_name := normalized.get_base_dir().get_file()
    var label := "%s_%s" % [parent_name, checkpoint_name] if parent_name != "" else checkpoint_name
    return _safe_path_segment(label)

func _infer_completed_sorties_from_checkpoint_path(checkpoint_path: String) -> int:
    var checkpoint_name := checkpoint_path.replace("\\", "/").trim_suffix("/").get_file()
    if not checkpoint_name.begins_with("sortie_"):
        return 0
    return maxi(0, int(checkpoint_name.trim_prefix("sortie_")))

func _safe_path_segment(value: String) -> String:
    var safe := value.strip_edges().to_lower()
    for bad in ["\\", "/", ":", "*", "?", "<", ">", "|", " "]:
        safe = safe.replace(bad, "_")
    while safe.contains("__"):
        safe = safe.replace("__", "_")
    safe = safe.strip_edges()
    return "checkpoint" if safe == "" else safe

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
    lines.append("Checkpoint folder: `%s`" % str(report.get("checkpoint_dir", "")))
    if str(report.get("resumed_from_checkpoint", "")) != "":
        lines.append("Resumed from checkpoint: `%s`" % str(report.get("resumed_from_checkpoint", "")))
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
    lines.append("| Mode | Sorties | Nodes | Money | XP | Cores | Mining Time | Nodes/s | Money/s | Avg End Cargo | Avg End Fuel | Worst FPS | Worst Frame |")
    lines.append("| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |")
    var aggregate: Dictionary = report.get("aggregate", {})
    for row_variant in Array(aggregate.get("by_mode", [])):
        var row: Dictionary = row_variant
        lines.append("| %s | %d | %d | %d | %d | %d | %.1f | %.3f | %.3f | %.1f%% | %.1f%% | %d | %.2fms |" % [
            str(row.get("mode", "")),
            int(row.get("sorties", 0)),
            int(row.get("total_nodes", 0)),
            int(row.get("total_money", 0)),
            int(row.get("total_xp", 0)),
            int(row.get("total_core_currency", 0)),
            float(row.get("total_mining_time_s", 0.0)),
            float(row.get("nodes_per_mining_second", 0.0)),
            float(row.get("money_per_mining_second", 0.0)),
            float(row.get("avg_end_cargo_fill_ratio", 0.0)) * 100.0,
            float(row.get("avg_end_fuel_left_ratio", 0.0)) * 100.0,
            int(row.get("worst_min_fps", 0)),
            float(row.get("worst_frame_ms", 0.0)),
        ])
    lines.append("")
    lines.append("## Auto Pilot Return Balance")
    lines.append("")
    lines.append("| Mode | Return Reason | Count | Avg End Cargo | Cargo Range | Avg End Fuel | Fuel Range |")
    lines.append("| --- | --- | ---: | ---: | --- | ---: | --- |")
    for row_variant in Array(aggregate.get("by_mode", [])):
        var row: Dictionary = row_variant
        for reason_variant in Array(row.get("return_reasons", [])):
            var reason: Dictionary = reason_variant
            lines.append("| %s | %s | %d | %.1f%% | %.1f-%.1f%% | %.1f%% | %.1f-%.1f%% |" % [
                str(row.get("mode", "")),
                str(reason.get("reason", "")),
                int(reason.get("count", 0)),
                float(reason.get("avg_cargo_fill_ratio", 0.0)) * 100.0,
                float(reason.get("min_cargo_fill_ratio", 0.0)) * 100.0,
                float(reason.get("max_cargo_fill_ratio", 0.0)) * 100.0,
                float(reason.get("avg_fuel_left_ratio", 0.0)) * 100.0,
                float(reason.get("min_fuel_left_ratio", 0.0)) * 100.0,
                float(reason.get("max_fuel_left_ratio", 0.0)) * 100.0,
            ])
    lines.append("")
    lines.append("Detailed mode JSON files are written next to this report.")
    lines.append("Append-only ledgers:")
    lines.append("- Frame/perf data: `%s`" % str(Dictionary(report.get("append_files", {})).get("frame_rate_data", "")))
    lines.append("- Run summaries: `%s`" % str(Dictionary(report.get("append_files", {})).get("run_summaries", "")))
    return "\n".join(lines)
