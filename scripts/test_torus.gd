@tool
extends MeshInstance3D

func _process(delta: float) -> void:
	self.rotate_y(delta)
