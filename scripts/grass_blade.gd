#@tool
extends MeshInstance3D

var player: CharacterBody3D
@onready var mat: ShaderMaterial = self.mesh.surface_get_material(0)


func _ready() -> void:
	var root = self.get_tree().current_scene
	var childs: Array = Utils.find_all_childrens(root)
	for child in childs:
		if child is CharacterBody3D and child.name == "Whisp":
			player = child
	
	if not player:
		Utils.kill_and_warn(self, "Player not found")
		return


func _physics_process(_delta: float) -> void:
	mat.set_shader_parameter("PlayerPosition", player.mesh_instance_3d.global_position)
	
