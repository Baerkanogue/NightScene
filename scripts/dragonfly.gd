extends Node3D

@export var markers_node: Node3D
@export var lerp_speed: float = 1.0
@export var wait_time: float = 1.0

var markers_array: Array[Marker3D]
var is_move_ready: bool = true

@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	animation_player.play("dragonfly")
	if not markers_node:
		Utils.kill_and_warn(self, "No marker node found.")
		return
	
	markers_array.append_array(markers_node.get_children())
	
	var pos_timer: Timer = Timer.new()
	self.add_child(pos_timer)
	pos_timer.timeout.connect(_on_pos_timer)
	pos_timer.start(wait_time)


func _process(delta: float) -> void:
	dragonfly(delta)


func dragonfly(delta: float) -> void:
	var chosen_marker: Marker3D = markers_array.pick_random()
	var new_pos: Vector3
	self.rotate_y(randf() * TAU)
	if is_move_ready:
		new_pos = chosen_marker.global_position
		is_move_ready = false
	self.global_position = lerp(self.global_position, new_pos, 10 * delta)
	if self.global_position == new_pos:
		print("ee")


func _on_pos_timer() -> void:
	is_move_ready = true
