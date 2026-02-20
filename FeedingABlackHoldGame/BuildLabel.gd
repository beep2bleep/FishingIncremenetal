extends Control

func _ready():
    %"Build Label".text = ProjectSettings.get_setting("global/Build")
    SignalBus.pallet_updated.connect(_on_pallet_updated)

    _on_pallet_updated()

func _on_pallet_updated():
    %"Build Label".modulate = Refs.pallet.text_base_color
