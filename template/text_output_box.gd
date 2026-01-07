class_name TextOutputBox extends Control

const OUTPUT_LABEL = preload("res://output_label.tscn")

## String used by GOut to find this output box
@export var text_output_string:String = "default"

var dif:float = 0.0

@onready var text_scroll_bar: VSlider = $CropRegion/TextScrollBar
@onready var text_container: VBoxContainer = $CropRegion/TextContainer
@onready var debug_rect: DebugRect = $DebugRect
@onready var crop_region: Control = $CropRegion
@onready var last:float = text_container.size.y
@onready var default_y_pos:float = text_container.position.y


func _ready() -> void:
	text_container.resized.connect(text_container_resize)
	GOut.out_dict[text_output_string] = self

func text_container_resize():
	text_scroll_bar.visible = true
	dif = text_container.size.y - crop_region.size.y
	default_y_pos -= text_container.size.y - last
	if text_scroll_bar.value == 0:
		text_container.set_deferred("position",Vector2(text_container.position.x,default_y_pos))
	else:
		update_text_container_position(text_scroll_bar.value)
	last = text_container.size.y

func add_line(value:String):
	var new_line:OutputLabel = OUTPUT_LABEL.instantiate()
	new_line.output_text = value
	text_container.add_child(new_line)

func update_text_container_position(value:float):
	var text_container_position = dif * (value/100.0)
	text_container.set_deferred("position",Vector2(text_container.position.x,default_y_pos + text_container_position))

func _on_text_scroll_bar_value_changed(value: float) -> void:
	debug_rect._size_changed()
	update_text_container_position(value)

func _debug_toggle_text_container_outline(value:int = -1) -> void:
	match value:
		-1:
			debug_rect.visible = !debug_rect.visible
		0:
			debug_rect.visible = false
		1: 
			debug_rect.visible = true
		_:
			print("invalid")
