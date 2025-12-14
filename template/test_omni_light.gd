@tool class_name CustomOmniLight3D extends OmniLight3D

@export var process_in_editor:bool = false:
	set (value):
		refresh_defaults()
		process_in_editor = value

@export var light_hot_cold:Gradient
@export var easing_line:Curve
@export var default_light_color:Color = Color.WHITE
@export_range(0.0,1.0,0.01) var range_varience:float = 0.1
@export_range(0.0,1.0,0.01) var attenuation_varience:float = 0.1
@export_range(0.0,1.0,0.01) var energy_varience:float = 0.1

@export var flicker_speed:float = 1.0

@onready var default_range:float = omni_range
@onready var default_attenuation:float = omni_attenuation
@onready var default_energy:float = light_energy
@onready var default_color:Color = default_light_color

@onready var light_alpha:float = randf_range(0.0,1.0)
var eased_light_alpha:float
var direction:float = 1.0

func refresh_defaults():
	default_range = omni_range
	default_attenuation = omni_attenuation
	default_energy = light_energy
	default_color = light_color

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		if process_in_editor == false:
			return
	var clamped_alpha = clampf(light_alpha,0.0,1.0)
	eased_light_alpha = easing_line.sample(clamped_alpha)
	omni_range = default_range + lerpf(-range_varience,range_varience,eased_light_alpha)
	omni_attenuation = default_attenuation + lerpf(-attenuation_varience,attenuation_varience,eased_light_alpha)
	light_energy = default_energy + lerp(-energy_varience,energy_varience,clamped_alpha)
	
	if light_hot_cold:
		light_color = (light_hot_cold.sample(clamped_alpha)*0.1).blend(default_light_color)
	
	if light_alpha > 1.0:
		direction = -1
	elif light_alpha < 0.0:
		direction = 1
	
	light_alpha += flicker_speed * direction * delta
