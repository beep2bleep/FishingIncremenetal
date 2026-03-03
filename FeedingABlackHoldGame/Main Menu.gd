extends Node2D
class_name MainMenu

const HERO_SCENE: PackedScene = preload("res://Fishing/CombatSprite.tscn")
const PLATFORMING_PACK_SPRITES := "C:/Godot Projects/FishingIncremental/PlatformingPack/Sprites"


enum STATES{MENU, SETTINGS, GAME_MODE}

var state: STATES = STATES.MENU:
    set(new_value):
        var old_value = state
        state = new_value

        %"Main Menu Stuff".hide()
        %"Setting Pannel".hide()
        %"Game Mode Screen".hide()

        match state:
            STATES.MENU:

                %"Main Menu Stuff".show()
                if old_value != new_value:
                    %AudioStreamPlayer.play()
                    %"Main Menu Stuff".modulate.a = 0.0

                do_tween_state_change(Vector2.ZERO, Vector2.ONE, %"Main Menu Stuff", true)

                update_input(ControllerIcons.get_last_input_type())

            STATES.SETTINGS:
                var zoom = 2.0
                %Logo.modulate.a = 0
                %"Setting Pannel".show()
                if old_value != new_value:
                    %AudioStreamPlayer.play()
                    %"Setting Pannel".modulate.a = 0.0
                do_tween_state_change(Vector2( - get_viewport_rect().size.x / (2 * zoom), 0), Vector2(zoom, zoom), %"Setting Pannel")
                %"Settings Comp".show_screen()

            STATES.GAME_MODE:
                var zoom = 1.5
                %Logo.modulate.a = 0
                %"Game Mode Screen".show()
                if old_value != new_value:
                    %AudioStreamPlayer.play()
                    %"Game Mode Screen".modulate.a = 0.0


                do_tween_state_change(Vector2(0, - get_viewport_rect().size.y / (2.0 * zoom)), Vector2(zoom, zoom), %"Game Mode Screen")


var tween_state_change: Tween
func do_tween_state_change(pivot_pos, zoom, to_stuff, show_logo = false):

    var duration = 1.0

    if tween_state_change:
        tween_state_change.kill()



    tween_state_change = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
    tween_state_change.tween_callback( func():
        if to_stuff.has_method("show_screen"):
            to_stuff.show_screen()
    )
    tween_state_change.tween_property( %Pivot, "global_position", pivot_pos, duration)

    tween_state_change.parallel().tween_property( %Camera2D, "zoom", zoom, duration)
    tween_state_change.parallel().tween_property(to_stuff, "modulate:a", 1.0, duration)
    if show_logo:
        tween_state_change.parallel().tween_property( %Logo, "modulate:a", 1.0, duration)



func _input(event: InputEvent) -> void :
    if event.is_action_pressed("back"):
        state = STATES.MENU

func _ready():


    ControllerIcons.input_type_changed.connect(_on_input_type_changed)

    state = STATES.MENU

    SaveHandler.update_first_time_load(true)



    Global.game_state = Util.GAME_STATES.MAIN_MENU




    %"Setting Pannel".hide()


    %"Black Hole Art".maw_texture.width = 512
    %"Black Hole Art".bh_texture.width = 512
    %"Black Hole Art".maw_texture.height = 512
    %"Black Hole Art".bh_texture.height = 512








    SaveHandler.update_has_shown_pick_locale_first_time(true)

    %ObjectManager.outer_radius = get_viewport_rect().size.y / 2.0
    %ObjectManager.create_specific_num_asteroids(64, 256)

    SignalBus.pallet_updated.connect(_on_pallet_updated)

    update_color()

    # Replace Black Hole Art with a simple hero/enemy showcase and update title
    var pivot = get_node_or_null("Pivot")
    if pivot:
        var black_hole = pivot.get_node_or_null("Black Hole Art")
        if black_hole:
            black_hole.queue_free()

        var showcase = Node2D.new()
        showcase.name = "StartShowcase"
        pivot.add_child(showcase)

        # Add simple hero/enemy placeholders instead of composing sheets here
        var hero_sprite: Sprite2D = Sprite2D.new()
        var hero_tex = load("res://Art/Logo Base White.png")
        if hero_tex != null:
            hero_sprite.texture = hero_tex
        hero_sprite.position = Vector2(-80, 520)
        hero_sprite.scale = Vector2(0.6, 0.6)
        showcase.add_child(hero_sprite)

        var enemy_sprite: Sprite2D = Sprite2D.new()
        var enemy_tex = load("res://Art/star_tiny.png")
        if enemy_tex != null:
            enemy_sprite.texture = enemy_tex
        enemy_sprite.position = Vector2(80, 520)
        enemy_sprite.scale = Vector2(1.6, 1.6)
        showcase.add_child(enemy_sprite)

    var logo_node = get_node_or_null("CanvasLayer/MarginContainer2/Logo")
    if logo_node:
        logo_node.visible = false
    if has_node("%MainTitle"):
        %MainTitle.text = "VANGUARD: IDLE AUTO-BATTLER"
    if has_node("%Discord"):
        %Discord.disabled = true
    if has_node("%Press Kit"):
        %"Press Kit".disabled = true


func _on_input_type_changed(input_type: ControllerIcons.InputType, controller: int):
    update_input(input_type)

func update_input(input_type):
    if state == STATES.MENU:
        if ControllerIcons.get_last_input_type() == ControllerIcons.InputType.CONTROLLER:
            %Play.grab_focus()
        else:
            pass


func _on_pallet_updated():
    update_color()

func update_color():
    %ColorRect.color = Refs.pallet.background

    %Logo.modulate = Refs.pallet.text_base_color
    if has_node("%MainTitle"):
        %MainTitle.modulate = Refs.pallet.text_base_color
    var color_light = Refs.pallet.background
    color_light.v *= 1.05
    %"GPUParticles2D Light".modulate = color_light

    var color_dark = Refs.pallet.background
    color_dark.v *= 0.95
    %"GPUParticles2D2 Dark".modulate = color_dark










func _on_start_new_game_pressed() -> void :
    %"Main Menu Stuff".hide()
    %"Game Modes Pannel".show()


func _on_contiunue_old_game_pressed() -> void :
    Global.load_saved_run = true
    SceneChanger.change_to_new_scene(Util.PATH_MAIN)


func _on_quit_pressed() -> void :
    get_tree().quit()


func _on_wishlist_pressed() -> void :
    OS.shell_open("https://store.steampowered.com/app/3694480/A_Game_About_A_Black_Hole/")


func _on_discord_pressed() -> void :
    OS.shell_open("https://discord.gg/qSs4QAsmf9")


func _on_press_kit_pressed() -> void :
    OS.shell_open("https://drive.google.com/drive/folders/1onWePx7nawiXxfadZjMezKlE13q4gbkE?usp=sharing")


func _on_settings_pressed() -> void :
    state = STATES.SETTINGS


func _on_hide_settings_pressed() -> void :
    state = STATES.MENU










func _on_hide_game_modes_pressed() -> void :
    %"Main Menu Stuff".show()
    %"Game Modes Pannel".hide()















func _on_play_pressed() -> void :
    Global.ensure_default_game_mode_data()
    Global.start_in_upgrade_scene = true
    Global.load_saved_run = false
    SceneChanger.change_to_new_scene(Util.PATH_MAIN, null, 0.2)


func _on_game_mode_screen_back() -> void :
    state = STATES.MENU


func _on_game_mode_screen_play_new_game_mode(game_mode_data: GameModeData) -> void :

    Global.current_game_mode_data = game_mode_data
    Global.new_game()

    Global.load_saved_run = false
    Global.start_in_upgrade_scene = true
    SceneChanger.change_to_new_scene(Util.PATH_MAIN, null, 0.2)


func _on_game_mode_screen_continue_game_mode(game_mode_data: GameModeData) -> void :
    Global.current_game_mode_data = game_mode_data
    Global.new_game()

    Global.load_saved_run = true
    Global.start_in_upgrade_scene = true
    SceneChanger.change_to_new_scene(Util.PATH_MAIN, null, 0.2)
