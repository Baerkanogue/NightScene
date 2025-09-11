extends Node3D

@export var max_angle: float = 20.0
@export var lerp_speed: float = 5.0
@export var whisp: CharacterBody3D
@export_subgroup("Blinking", "blink_")
@export var animation_player: AnimationPlayer
@export_range(0.0, 5.0, 0.1) var blink_min_delay: float = 2.0
@export_range(0.0, 15.0, 0.1) var blink_max_delay: float = 7.0

var blink_timer: Timer = Timer.new()

func _ready() -> void:
	if not whisp:
		var target_whisp: Node = self.owner
		if target_whisp is CharacterBody3D and owner.name == "Whisp":
			whisp = target_whisp
		else:
			Utils.kill_and_warn(self, "Whisp not found.")
			return
	
	if not animation_player:
		var array: Array = Utils.find_all_childrens(self.owner)
		for node in array:
			if node is AnimationPlayer:
				animation_player = node
	if not animation_player:
		Utils.kill_and_warn(self, "Animation player not found.")
		return
	
	self.add_child(blink_timer)
	blink_timer.timeout.connect(_on_blink_timer)
	blink_timer.start(randf_range(blink_min_delay, blink_max_delay))


func _process(delta: float) -> void:
	var _whisp_vel: Vector3 = whisp.get_real_velocity()
	var whisp_dir = Vector2(_whisp_vel.x, _whisp_vel.y).normalized()
	
	var target_rot_x: float = whisp_dir.y * (-1) * deg_to_rad(max_angle)
	var target_rot_y: float = whisp_dir.x * deg_to_rad(max_angle)
	
	self.rotation.z = lerp_angle(self.rotation.z, target_rot_x, lerp_speed * delta)
	self.rotation.y = lerp_angle(self.rotation.y, target_rot_y, lerp_speed * delta)
	

func _on_blink_timer() -> void:
	if not animation_player.is_playing():
		var delta: float = get_process_delta_time()
		var blinking_speed: float = 1000.0
		animation_player.play("blink", -1, blinking_speed * delta)
		blink_timer.start(randf_range(blink_min_delay, blink_max_delay))
