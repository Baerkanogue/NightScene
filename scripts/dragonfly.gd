extends Node3D

@export var markers_node: Node3D
@export var lerp_speed: float = 2.0
@export var wait_time: float = 1.0

var markers_array: Array[Marker3D]
var is_move_ready: bool = true
var new_pos: Vector3
var pos_timer: Timer = Timer.new()
var reached_distance: float = 0.001

@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	animation_player.play("dragonfly")
	if not markers_node:
		Utils.kill_and_warn(self, "No marker node found.")
		return
	
	markers_array.append_array(markers_node.get_children())
	
	self.add_child(pos_timer)
	pos_timer.timeout.connect(_on_pos_timer)
	pos_timer.one_shot = true


func _process(delta: float) -> void:
	dragonfly(delta)


func dragonfly(delta: float) -> void:
	if is_move_ready:
		self.rotate_y(randf() * TAU)
		var chosen_marker: Marker3D = markers_array.pick_random()
		new_pos = chosen_marker.global_position
		is_move_ready = false
	else:
		self.global_position = lerp(self.global_position, new_pos, lerp_speed * delta)
	
	if self.global_position.distance_to(new_pos) < reached_distance:
		if pos_timer.is_stopped():
			pos_timer.start(wait_time)


func _on_pos_timer() -> void:
	is_move_ready = true
