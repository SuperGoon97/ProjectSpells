class_name DebugRect extends ReferenceRect

@export var control_to_outline:Control

func _ready() -> void:
	if control_to_outline:
		control_to_outline.resized.connect(_size_changed)
	_size_changed()

func _size_changed():
	await get_tree().process_frame
	set_deferred("position",control_to_outline.position)
	set_deferred("size",control_to_outline.size)
