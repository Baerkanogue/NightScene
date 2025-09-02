#@tool
extends MeshInstance3D


func _ready() -> void:
	var mat: ShaderMaterial = self.mesh.surface_get_material(0)
	var noise_texture: NoiseTexture2D = mat.get_shader_parameter("VertexNoise")
	var new_noise_texture: NoiseTexture2D = noise_texture.duplicate()
	var new_noise: FastNoiseLite = new_noise_texture.noise
	new_noise.seed = randi()
	mat.set_shader_parameter("VertexNoise", new_noise_texture)
