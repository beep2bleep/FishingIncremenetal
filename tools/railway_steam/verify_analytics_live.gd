extends SceneTree
## Explicit opt-in smoke check: sends a labelled session to the edition's live GA game.
var responses: Array[int] = []
func _initialize(): call_deferred("run")
func run():
	var manager = root.get_node("GameAnalytics")
	if manager._enabled:
		push_error("Use the source launcher configuration so analytics starts deferred.")
		quit(1)
		return
	var demo = "demo" in OS.get_cmdline_user_args()
	ProjectSettings.set_setting("railway_fury/demo/enabled", demo)
	root.get_node("Util").set_active_game_id("rowdivers")
	manager.setEnabledInfoLog(false)
	manager.configureBuild("analytics-verification-20261030")
	manager._http.request_completed.connect(func(_result, code, _headers, body):
		responses.append(code)
		if code < 200 or code >= 300: print("GA verification error: ", code, " ", body.get_string_from_utf8()))
	manager.refresh_active_game_session()
	manager.track_design_event("railway_fury:integration_check", null, {"demo": demo, "verification": true})
	var deadline = Time.get_ticks_msec() + 45000
	while Time.get_ticks_msec() < deadline:
		await create_timer(0.1).timeout
		if not manager._request_in_flight and manager._pending.is_empty(): break
	var passed = manager._init_done and responses.size() >= 2 and responses.all(func(code): return code >= 200 and code < 300) and not manager._request_in_flight
	print("GA LIVE VERIFICATION: edition=", "demo" if demo else "full", " responses=",responses," passed=",passed)
	quit(0 if passed else 1)
