@tool class_name CustomOmniLight3D extends OmniLight3D

@export var light_hot_cold:Gradient
@export var easing_line:Curve
@export_range(0.0,1.0,0.01) var range_varience:float = 0.1
@export_range(0.0,1.0,0.01) var attenuation_varience:float = 0.1
@export_range(0.0,1.0,0.01) var energy_varience:float = 0.1

@export var flicker_speed:float = 1.0

@onready var default_range:float = omni_range
@onready var default_attenuation:float = omni_attenuation
@onready var default_energy:float = light_energy
@onready var default_color:Color = light_color

@onready var light_alpha:float = randf_range(0.0,1.0)
var eased_light_alpha:float
var direction:float = 1.0

func _process(delta: float) -> void:
	var clamped_alpha = clampf(light_alpha,0.0,1.0)
	eased_light_alpha = easing_line.sample(clamped_alpha)
	omni_range = default_range + lerpf(-range_varience,range_varience,eased_light_alpha)
	omni_attenuation = default_attenuation + lerpf(-attenuation_varience,attenuation_varience,eased_light_alpha)
	light_energy = default_energy + lerp(-energy_varience,energy_varience,clamped_alpha)
	
	if light_hot_cold:
		var sampled_hue:float = light_hot_cold.sample(clamped_alpha).h
		if sampled_hue == 0.0: sampled_hue = 1.0
		light_color = default_color.blend(light_hot_cold.sample(clamped_alpha)*0.33)
	
	if light_alpha > 1.0:
		direction = -1
	elif light_alpha < 0.0:
		direction = 1
	
	light_alpha += flicker_speed * direction * delta
