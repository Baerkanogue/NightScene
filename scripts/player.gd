extends CharacterBody3D


@export_subgroup("SineTransform", "sine_")
@export var sine_frequency: float = 2.0
@export var sine_amplitude: float = 0.02

const WALK_SPEED: float = 1.35
const WALK_ACCELERATION: float = 3.0
const JUMP_FORCE: float = 3.5

var friction: float = 3.5
var phase: float = 0.0
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var mat: ShaderMaterial

@onready var z_position: float = self.global_position.z
@onready var mesh_instance_3d: MeshInstance3D = $WhispMeshInstance3D
@onready var mesh_y_offset: float = mesh_instance_3d.position.y


func _ready() -> void:
	if not mesh_instance_3d:
		Utils.kill_and_warn(self, "No mesh instance")
		return
	
	mat = mesh_instance_3d.mesh.surface_get_material(0)


func _physics_process(delta: float) -> void:
	movement_hander(delta)
	self.global_position.z = z_position
	
	if self.is_on_floor():
		sine_transform(delta)
		
	feed_vec_to_shader()


func movement_hander(delta: float) -> void:
	# Ground detection for gravity and y velocity cancellation.
	var is_on_floor_state: bool = true if self.is_on_floor() else false
		
	if is_on_floor_state:
		self.velocity.y = 0.0
	else:
		self.velocity.y -= gravity * delta
	
	if not self.is_on_floor():
		friction = 0.5
	else:
		friction = 3.5
		
	# Horizontal movement.
	var movement_vector: Vector3 = get_movement_vector()
	var turnaround_boost: float = 1.0
	if movement_vector:
		if movement_vector.normalized() == self.velocity.normalized() * (-1):
			turnaround_boost *= 5.0
		self.velocity = self.velocity.move_toward(movement_vector, WALK_ACCELERATION * turnaround_boost * delta)
	else:
		self.velocity = self.velocity.move_toward(Vector3(0.0, self.velocity.y, 0), friction * delta)
	
	if is_on_floor_state and is_jump_requested():
		velocity.y += JUMP_FORCE
	
	self.velocity.z = 0
	self.move_and_slide()


func get_movement_vector() -> Vector3:
	var dir: Vector3 = Vector3.ZERO
	var horizontal_dir: float = Input.get_axis("move_left","move_right")
	dir.x = horizontal_dir
	dir = dir.normalized() * WALK_SPEED
	return dir


func is_jump_requested() -> bool:
	return Input.is_action_pressed("jump") or Input.is_action_pressed("move_up")


func feed_vec_to_shader() -> void:
	var dir: Vector3 = self.get_real_velocity()
	mat.set_shader_parameter("DirectionNormalized", dir.normalized())
	mat.set_shader_parameter("DirectionScalar", dir.length())


func sine_transform(delta: float) -> void:
	phase += sine_frequency * delta
	phase = fmod(phase, TAU)
	mesh_instance_3d.position.y = sin(phase) * sine_amplitude + mesh_y_offset
