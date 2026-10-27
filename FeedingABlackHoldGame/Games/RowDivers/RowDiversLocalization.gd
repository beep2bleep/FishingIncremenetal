extends Node
## English source messages remain in data/save identifiers; only presentation is translated.
const CATALOG_PATH = "res://Games/RowDivers/Translations/catalog.json"
var translations: Array[Translation] = []
var initialized = false

func _ready() -> void:
	if not Util.is_row_divers_game_active(): return
	var catalog: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(CATALOG_PATH))
	for locale in catalog:
		var translation := Translation.new()
		translation.locale = locale
		for source in catalog[locale]:
			translation.add_message(source, catalog[locale][source])
		TranslationServer.add_translation(translation)
		translations.append(translation)
	initialized = true
	_configure_fonts()

func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED and initialized: _configure_fonts()

func _configure_fonts() -> void:
	# Web has no operating-system font fallback. Keep its existing language list,
	# but explicitly supply Cyrillic and Vietnamese glyphs for supported locales.
	var fallbacks: Array[Font] = [load("res://Theme/Fallbacks/NotoSans-Regular.ttf")]
	if not OS.has_feature("web"):
		var cjk = ["NotoSansCJKjp-Regular.otf","NotoSansCJKsc-Regular.otf","NotoSansCJKkr-Regular.otf"]
		var locale = TranslationServer.get_locale().get_slice("_",0)
		if locale=="zh": cjk = [cjk[1],cjk[0],cjk[2]]
		elif locale=="ko": cjk = [cjk[2],cjk[0],cjk[1]]
		for filename in cjk: fallbacks.append(load("res://Theme/Fallbacks/"+filename))
		fallbacks.append(load("res://Theme/Fallbacks/NotoSansThai-Regular.ttf"))
	for filename in ["Montserrat-SemiBold.ttf","Poppins-Bold.ttf","Poppins-Regular.ttf","Poppins-SemiBold.ttf","RobotoMono-SemiBold.ttf","Exo2-Bold.ttf","Exo2-BoldItalic.ttf"]:
		var font: FontFile = load("res://Theme/"+filename)
		font.fallbacks = fallbacks
