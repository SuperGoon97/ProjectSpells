extends Node

var out_dict:Dictionary[String,TextOutputBox]

func out(target:String,string:String) -> void:
	if out_dict[target]:
		out_dict[target].add_line(string)
	else:
		push_error("GOut out %s does not exist" %target)
