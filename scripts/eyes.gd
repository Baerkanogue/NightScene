extends Node3D


@export var max_angle: float = 20.0
@export var lerp_speed: float = 5.0

@onready var whisp: CharacterBody3D = self.get_parent()


func _process(delta: float) -> void:
	var _whisp_vel: Vector3 = whisp.get_real_velocity()
	var whisp_dir = Vector2(_whisp_vel.x, _whisp_vel.y).normalized()
	
	var target_rot_x: float = whisp_dir.y * (-1) * deg_to_rad(max_angle)
	var target_rot_y: float = whisp_dir.x * deg_to_rad(max_angle)
	
	self.rotation.z = lerp_angle(self.rotation.z, target_rot_x, lerp_speed * delta)
	self.rotation.y = lerp_angle(self.rotation.y, target_rot_y, lerp_speed * delta)
