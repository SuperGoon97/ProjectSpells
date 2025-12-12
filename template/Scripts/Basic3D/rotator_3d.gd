extends Node3D

@export var rotation_angle:Vector3 = Vector3(0.0,0.0,0.0):
	set(value):
		rotation_angle = value

@export var rotation_speed:float = 1.0

func _process(delta: float) -> void:
	rotate(rotation_angle,rotation_speed*delta)
