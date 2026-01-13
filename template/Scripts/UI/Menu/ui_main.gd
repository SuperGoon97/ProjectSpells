class_name UiMain
extends Control

@export var outputbox_array:Array[TextOutputBox]

@onready var control: Control = $Control
@onready var option_button: OptionButton = $OptionButton

func _game_ready() -> void:
	GVar.signal_bus.option_change.connect(_option_changed)
	setup_textoutput()

func setup_textoutput() -> void:
	for output in outputbox_array:
		output.visible = false
	outputbox_array[option_button.selected].visible = true

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

func _on_option_button_item_selected(index: int) -> void:
	for output in outputbox_array:
		output.visible = false
	outputbox_array[index].visible = true
	pass # Replace with function body.
