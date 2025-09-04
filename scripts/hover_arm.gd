extends Node3D

@export_subgroup("SineTransform", "sine_")
@export var sine_frequency: float = 2.0
@export var sine_amplitude: float = 0.02

@export var min_hover_height: float = -0.775
@export var whisp: CharacterBody3D
@export var mesh: MeshInstance3D

var phase: float = 0.0


func _ready() -> void:
	if not whisp:
		if self.owner.name == "Whisp":
			whisp = self.owner
	if not whisp:
		Utils.kill_and_warn(self, "Whisp not found.")
		return
	
	if not mesh:
		mesh = whisp.mesh_instance_3d
		Utils.kill_and_warn(self, "Whisp mesh not found.")
		return
	


func _physics_process(delta: float) -> void:
	var pos_y: float =  self.global_position.y 
	var margin: float = 0.01
	if pos_y < (min_hover_height - margin):
		self.global_position.y = lerpf(pos_y, min_hover_height - margin, 0.1)
	elif pos_y > (min_hover_height + margin):
		self.global_position.y = lerpf(pos_y, whisp.global_position.y, 0.5)
	
	if whisp.is_on_floor():
		sine_transform(delta)

func sine_transform(delta: float) -> void:
	phase += sine_frequency * delta
	phase = fmod(phase, TAU)
	mesh.position.y = sin(phase) * sine_amplitude
