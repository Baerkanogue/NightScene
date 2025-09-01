@tool
extends MeshInstance3D


@onready var player: CharacterBody3D = $"../../../Player"
@onready var mat: ShaderMaterial = self.mesh.surface_get_material(0)

func _physics_process(_delta: float) -> void:
	mat.set_shader_parameter("PlayerPosition", player.global_position)
