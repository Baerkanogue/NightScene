@tool
extends Node3D


@export var mesh_instance: MeshInstance3D
@export_group("Movement")
@export_subgroup("BaseMovement")
@export_range(0.0, 0.5, 0.01) var radius: float = 0.3
@export_range(0.0, 2.5, 0.01) var speed: float = 1.0
@export_subgroup("Y-Axis Sine", "y_")
@export_range(0.0, 0.3, 0.01) var y_amplitude: float = 0.1
@export_range(0.0, 5.0, 0.01) var y_frequency: float = 1.0
@export_subgroup("Flicker", "flicker_")
@export_range(0.0, 10.0, 0.01) var flicker_frequency: float = 0.1

var mat: ShaderMaterial
var sprite_color: Color
var sprite_size: float
var sprite_alpha_multiplier: float
var sprite_emission_mulitplier : float
var are_shader_params_ready: bool = false

var angle: float = 0.0
var y_phase: float = 0.0
var flicker_phase: float = 0.0

@onready var firefly_omni_light_3d: OmniLight3D = $FireflyMesh/FireflyOmniLight3D


func _ready() -> void:
	var childs: Array = Utils.find_all_childrens(self)
	if not mesh_instance in childs or not mesh_instance:
		for child in childs:
			if child is MeshInstance3D:
				mesh_instance = child
	if not mesh_instance:
		Utils.kill_and_warn(self, "No mesh instance found.")
	else:
		mat = mesh_instance.mesh.surface_get_material(0)
		are_shader_params_ready = true if shader_params_safe_loader() else false


func _process(delta: float) -> void:
	go_round(delta)
	flicker(delta)


func flicker(delta: float) -> void:
	const MAX_SIZE: float = 0.9
	const MIN_SIZE: float = 1.2
	
	flicker_phase += flicker_frequency * delta
	flicker_phase = fmod(flicker_phase, TAU)
	
	var value: float = (sin(TAU * flicker_phase) + 1.0) * 0.5
	mat.set_shader_parameter("Size", lerp(MAX_SIZE, MIN_SIZE, value))


func go_round(delta: float) -> void:
	angle += speed * delta
	angle = fmod(angle, TAU)
	var x: float = self.global_position.x + radius * cos(angle)
	var z: float = self.global_position.z + radius * sin(angle)
	
	var y: float = self.global_position.y + y_sine_transform(delta)
	
	mesh_instance.global_position = Vector3(x, y, z)


func y_sine_transform(delta: float) -> float:
	var y_offset: float = 0.0
	y_phase += y_frequency * delta
	y_phase = fmod(y_phase, TAU)
	y_offset = sin(y_phase) * y_amplitude
	return y_offset


func shader_params_safe_loader() -> bool:
	var are_params_safe: bool = true
	var safe_params_count: int = 0
	var params_name_type_dict: Dictionary = {
		"Color": TYPE_COLOR,
		"Size": TYPE_FLOAT,
		"AlphaMultiplier": TYPE_FLOAT,
		"EmissionMultiplier": TYPE_FLOAT,
	}
	for param in params_name_type_dict.keys():
		var param_type: int = params_name_type_dict[param]
		var buffer: Variant = mat.get_shader_parameter(param)
		if typeof(buffer) == param_type:
			safe_params_count += 1
		else:
			var error_message: String = "{name} parameter of type {type} doesnt match expected type {true_type}."
			error_message = error_message.format({
				"name": param,
				"type": type_string(typeof(buffer)),
				"true_type": type_string(param_type)
			})
			push_error(error_message)
			are_params_safe = false
	
	if safe_params_count != params_name_type_dict.size():
		are_params_safe = false
	
	if are_params_safe:
		sprite_color = mat.get_shader_parameter("Color")
		sprite_size = mat.get_shader_parameter("Size")
		sprite_alpha_multiplier = mat.get_shader_parameter("AlphaMultiplier")
		sprite_emission_mulitplier = mat.get_shader_parameter("EmissionMultiplier")
	
	return are_params_safe
