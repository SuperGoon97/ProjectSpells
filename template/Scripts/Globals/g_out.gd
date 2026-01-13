extends Node

var out_dict:Dictionary[String,TextOutputBox]

func out(target:String,string:String) -> void:
	if out_dict[target]:
		out_dict["all_debug"].add_line(string)
		match target:
			"debug":
				out_dict[target].add_line(string)
			_:
				out_dict[target].add_line(string)
				out_dict["all"].add_line(string)
	else:
		push_error("GOut out %s does not exist" %target)
