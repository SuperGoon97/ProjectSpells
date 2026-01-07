class_name InputManager
extends ManagerBase

func _game_ready():
	pass

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_SPACE:
			GOut.out("debug","TEST")
		elif event.pressed and event.keycode == KEY_E:
			GVar.show_timestamps = !GVar.show_timestamps
