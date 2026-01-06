class_name TextOutputBox extends Control

const OUTPUT_LABEL = preload("res://output_label.tscn")

var dif:float = 0.0

@onready var text_scroll_bar: VSlider = $CropRegion/TextScrollBar
@onready var text_container: VBoxContainer = $CropRegion/TextContainer
@onready var debug_rect: DebugRect = $DebugRect
@onready var crop_region: Control = $CropRegion
@onready var last:float = text_container.size.y
@onready var default_y_pos:float = text_container.position.y


func _ready() -> void:
	text_container.resized.connect(text_container_resize)

func text_container_resize():
	text_scroll_bar.visible = true
	dif = text_container.size.y - crop_region.size.y
	default_y_pos -= text_container.size.y - last
	if text_scroll_bar.value == 0:
		text_container.set_deferred("position",Vector2(text_container.position.x,default_y_pos))
	else:
		update_text_container_position(text_scroll_bar.value)
	last = text_container.size.y

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_SPACE:
			add_line()

func add_line():
	var new_line:RichTextLabel = OUTPUT_LABEL.instantiate()
	new_line.text = "TEST"
	text_container.add_child(new_line)

func update_text_container_position(value:float):
	var text_container_position = dif * (value/100.0)
	text_container.set_deferred("position",Vector2(text_container.position.x,default_y_pos + text_container_position))

func _on_text_scroll_bar_value_changed(value: float) -> void:
	debug_rect._size_changed()
	update_text_container_position(value)
