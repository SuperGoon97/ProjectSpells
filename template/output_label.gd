class_name OutputLabel extends RichTextLabel

var timestamp:String = Time.get_time_string_from_unix_time(Time.get_unix_time_from_system() - GVar.time_start)
var output_text:String:
	set(value):
		output_text = value
		update_text()
var _show_timestamps:bool = GVar.show_timestamps

func _ready() -> void:
	GVar.signal_bus.option_change.connect(_option_changed)

func _option_changed(option_string:String,value) -> void:
	if option_string == "show_timestamps":
		_show_timestamps = value
		update_text()

func update_text() -> void:
	var packed_string:PackedStringArray
	if _show_timestamps:
		packed_string.append("[%s]"%timestamp)
	packed_string.append(output_text)
	text = "".join(packed_string)
