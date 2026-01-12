class_name InputManager
extends ManagerBase

func _game_ready():
	pass

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed:
			match event.keycode:
				KEY_SPACE:
					GOut.out("debug","TEST")
				KEY_E:
					GVar.show_timestamps = !GVar.show_timestamps
				KEY_U:
					GVar.game_manager.signal_bus.option_change.emit("toggle_ui",-1)
