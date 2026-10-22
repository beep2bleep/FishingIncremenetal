extends RefCounted
## Small original vector badges; cached at UI resolution, with no external art dependency.
static var cache: Dictionary = {}

static func _badge(key: String, drawing: String, color: String) -> Texture2D:
	if cache.has(key): return cache[key]
	var svg := '<svg xmlns="http://www.w3.org/2000/svg" width="64" height="64" viewBox="0 0 64 64"><rect x="2" y="2" width="60" height="60" rx="12" fill="#172431" stroke="#%s" stroke-width="2"/><g fill="none" stroke="#%s" stroke-width="3" stroke-linecap="round" stroke-linejoin="round">%s</g></svg>' % [color, color, drawing]
	var bitmap := Image.new()
	bitmap.load_svg_from_string(svg)
	cache[key] = ImageTexture.create_from_image(bitmap)
	return cache[key]

static func achievement(key: String) -> Texture2D:
	var graphics = preload("res://Games/RowDivers/RowDiversGraphics.gd")
	if graphics.original() and graphics.catalog().achievements.has(key): return graphics.texture(graphics.catalog().achievements[key])
	var art := '<path d="M22 15h20v12c0 15-20 15-20 0zM22 20H15v7q0 9 10 9M42 20h7v7q0 9-10 9M32 39v10M23 50h18"/>'
	if "Bow" in key: art = '<path d="M19 13q30 19 0 38l10-19zM14 32h37m-8-8 8 8-8 8"/>'
	elif "Armor" in key: art = '<path d="m32 12 18 7v13q-2 15-18 22Q16 47 14 32V19zM32 20v24m-9-12h18"/>'
	elif "Heal" in key or "Benevolent" in key: art = '<path d="M25 14h14v11h11v14H39v11H25V39H14V25h11z"/>'
	elif "Vampire" in key: art = '<path d="M14 20q8-8 18 3 10-11 18-3 10 14-18 33Q4 34 14 20zM22 23l4 10 4-9m8 0 4 9 3-10"/>'
	elif "Gem" in key: art = '<path d="m20 16-9 14 21 23 21-23-9-14zM11 30h42M20 16l12 37 12-37"/>'
	elif "Coin" in key: art = '<circle cx="32" cy="32" r="20"/><path d="M40 22H27q-10 9 5 10 15 1 5 10H24m8-25v30"/>'
	elif "Prestige" in key or "Evil" in key: art = '<path d="m12 22 8 25h24l8-25-13 11-7-18-7 18zM20 52h24"/>'
	elif "Zombie" in key or "Kill" in key: art = '<path d="M18 37q-15-25 14-25t14 25v13H18zM25 43v7m14-7v7"/><circle cx="24" cy="29" r="4"/><circle cx="40" cy="29" r="4"/>'
	elif "Game" in key: art = '<path d="m16 32 11 11 23-26M12 51h40"/>'
	return _badge("achievement_" + key, art, "eec782")

static func enemy(kind: int) -> Texture2D:
	var graphics = preload("res://Games/RowDivers/RowDiversGraphics.gd")
	if graphics.original(): return graphics.texture(graphics.ENEMIES[clampi(kind, 0, 6)])
	var colors := ["d6d0b1", "9ebacb", "dc9b96", "a4c29e", "aabd73", "c5a9df", "eeae71"]
	var art := '<path d="M13 55q1-15 19-15t19 15M20 34V24q0-16 12-16t12 16v10l-7 8H27z"/><path d="M23 26h5m8 0h5m-12 9h6"/>'
	if kind == 1: art += '<path d="m17 22 4-13h22l4 13M12 48l9-6m31 6-9-6"/>'
	elif kind == 2: art += '<path d="m22 17 20 8m-23 5 22 8"/>'
	elif kind == 3: art += '<path d="M15 35Q10 5 32 5t17 30M17 18l15-9 15 9"/>'
	elif kind == 4: art += '<path d="m17 24 15 15 15-15M32 39l-5-13h10zM12 15h40M21 14V6h22v8"/>'
	elif kind == 5: art += '<path d="M16 21 32 4l16 17M32 7v13M27 14h10M32 43v14"/>'
	elif kind == 6: art += '<path d="m17 19-5-13 13 7 7-10 7 10 13-7-5 13M19 45l13 10 13-10"/>'
	return _badge("enemy_%d" % kind, art, colors[clampi(kind, 0, 6)])
