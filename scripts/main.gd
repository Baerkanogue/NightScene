extends Node3D

@export var world_environment: WorldEnvironment
@export var reflection_proble: ReflectionProbe
## 0: No force[br]
## 1: Force low[br]
## 2: Force high
@export_range(0.0, 2.0, 1.0) var force_mode: int = 0
@export var print_infos: bool = false
@export var light_strartup_delay: float = 1.0
@export var show_intro: bool = true
@export_range(0.0, 1.0, 0.01) var intro_speed_scale: float = 1.0

@onready var shader_text: RichTextLabel = $MainControl/ShaderText
@onready var background: ColorRect = $MainControl/Background
@onready var proximity_skybox: MeshInstance3D = $Environment/ProximitySkybox

var show_more: bool = false


func _ready() -> void:
	check_nulls()
	
	if proximity_skybox:
		proximity_skybox.show()
	
	var is_low_spec: bool = not is_system_capable()
	match force_mode:
		1: is_low_spec = true
		2: is_low_spec = false
	var args: Array = OS.get_cmdline_args()
	for arg in args:
		match arg:
			"-verbose":
				print_infos = true
				continue
			"-force_mode_1":
				is_low_spec = true
				continue
			"-force_mode_2":
				is_low_spec = false
				continue
	if is_low_spec:
		set_settings_low()
	
	if not OS.is_debug_build():
		print_rich("[color=web_gray]-verbose: Print infos\n-force_mode_1 = Force low fidelity\n-force_mode_2 = Force high fidelity\n[/color]")
		show_intro = true
		
	if print_infos:
		print_rich("[color=green]" + get_specs() + "[/color]")
		var fps_clock: Timer = Timer.new()
		fps_clock.set_name("fps_clock")
		self.add_child(fps_clock, true)
		fps_clock.timeout.connect(_on_fps_clock)
		fps_clock.start(5)
	
	if not show_intro:
		shader_text.hide()
		background.hide()
		return
	
	background.show()
	shader_text.show()
	var intro_clock: Timer = Timer.new()
	self.add_child(intro_clock)
	intro_clock.start(1.0)
	await intro_clock.timeout
	shader_text.hide()
	background.hide()
	if is_instance_valid(intro_clock):
		intro_clock.queue_free()
	light_startup()


func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("show_more"):
		show_more = not show_more
		show_more_stuff(show_more)


func show_more_stuff(show_node: bool) -> void:
	var nodes_to_show: Array[Node] = [
		$Geometry/TestTorus,
		$MainControl/Credits,
	]
	for node in nodes_to_show:
		if show_node:
			node.show()
		else:
			node.hide()


func is_system_capable() -> bool:
	var res: bool = false
	
	var adapter_type: int = RenderingServer.get_video_adapter_type()
	if adapter_type == RenderingDevice.DEVICE_TYPE_DISCRETE_GPU:
		res = true
	
	return res


func get_specs() -> String:
	var res: String = "GPU Type: {gpu_t}\nGPU Name: {gpu_n}\nCPU Name: {cpu_n}\nProcessors count: {p_count}\nMotherboard Name: {motherb}\nArchitechture: {bits}\nScreen Size: {s_size}\nScreen refresh rate: {s_rate}\n"
	
	res = res.format({
		"gpu_t": RenderingServer.get_video_adapter_type(),
		"gpu_n": RenderingServer.get_video_adapter_name(),
		"cpu_n": OS.get_processor_name(),
		"p_count": OS.get_processor_count(),
		"motherb": OS.get_model_name(),
		"bits": Engine.get_architecture_name(),
		"s_size": DisplayServer.screen_get_size(),
		"s_rate": DisplayServer.screen_get_refresh_rate()
	})
	return res


func check_nulls() -> void:
	if world_environment and reflection_proble:
		return
	
	var childs = Utils.find_all_childrens(self)
	for child in childs:
		if child is WorldEnvironment:
			world_environment = child
		elif child is ReflectionProbe:
			reflection_proble = child
		if world_environment and reflection_proble:
			return
	
	Utils.kill_and_warn(self, "World Environment or Reflection Proble not found.")


func light_startup() -> void:
	var anim_player: AnimationPlayer = $AnimationPlayer
	var lamp_post_lamps: Array[OmniLight3D] = [
		$Geometry/LampPost/Circle/LampOmniLight3D,
		$Geometry/LampPost2/Circle/LampOmniLight3D,
	]
	var lights: Array[Light3D] = [
	$Environment/EnvSpotLight3D,
	$Geometry/Fountain/OmniLight3D,
	$Geometry/Fountain/OmniLight3D2,
	$Geometry/Ground/GroundOmniLight3D,
	lamp_post_lamps[0],
	lamp_post_lamps[1],
]
	
	var verif_count: int = 6
	if lights.size() != verif_count or not anim_player:
		push_error("Error in light startup routine. Lights or animation nodes found doesnt match the verif_count.")
		return
	
	for light in lights:
		light.light_energy = 0.0
	
	var light_clock: Timer = Timer.new()
	self.add_child(light_clock)
	light_clock.start(light_strartup_delay)
	await light_clock.timeout
	if is_instance_valid(light_clock):
		light_clock.queue_free()
	anim_player.set_speed_scale(intro_speed_scale)
	anim_player.play_backwards("light")
	await anim_player.animation_finished
	if is_instance_valid(anim_player):
		anim_player.queue_free()
	for light in lamp_post_lamps:
		light.get_parent().get_parent().is_flickering = true


func set_settings_low() -> void:
	var env: Environment = world_environment.environment
	env.sdfgi_enabled = false
	env.glow_enabled = false
	env.ssao_enabled = false
	
	Engine.max_fps = 60
	Engine.physics_ticks_per_second = 30
	Engine.set_physics_jitter_fix(2.0)
	
	var viewp: Viewport = get_viewport()
	viewp.msaa_3d = Viewport.MSAA_DISABLED
	viewp.screen_space_aa = Viewport.SCREEN_SPACE_AA_DISABLED
	viewp.use_taa = false
	viewp.use_debanding = false
	viewp.anisotropic_filtering_level = Viewport.ANISOTROPY_DISABLED


func _on_fps_clock() -> void:
	var fps: int = int(Engine.get_frames_per_second())
	var print_color: String = "green"
	if fps < 60:
		if fps < 30:
			print_color = "red"
		else:
			print_color = "orange"
	print_rich("[color=" + print_color + "]" + str(fps) + " fps[/color]")
