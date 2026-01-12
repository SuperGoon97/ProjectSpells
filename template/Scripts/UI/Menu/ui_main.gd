class_name UiMain
extends Control

@onready var control: Control = $Control

func _game_ready() -> void:
	GVar.signal_bus.option_change.connect(_option_changed)
	pass

func _option_changed(option_string:String,value) -> void:
	if option_string == "toggle_ui":
		toggle_visibility(value)

func toggle_visibility(value:int = -1) -> void:
	match value:
		-1:
			visible = !visible
		0:
			visible = false
		1:
			visible = true
		_:
			print("invalid")
