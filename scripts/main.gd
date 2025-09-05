extends Node3D

@export var world_environment: WorldEnvironment
@export var reflection_proble: ReflectionProbe
## 0: No force[br]
## 1: Force low[br]
## 2: Force high
@export_range(0.0, 2.0, 1.0) var force_mode: int = 0
@export var print_infos: bool = false

var clock: Timer = Timer.new()

func _ready() -> void:
	check_nulls()
	var is_low_spec: bool = not is_system_capable()
	
	match force_mode:
		1: is_low_spec = true
		2: is_low_spec = false
	
	var args: Array = OS.get_cmdline_args()
	for arg in args:
		if arg == "-verbose":
			print_infos = true
		elif arg == "-force_mode_1":
			is_low_spec = true
		elif arg == "-force_mode_2":
			is_low_spec = false
		
	if is_low_spec:
		var env: Environment = world_environment.environment
		env.sdfgi_enabled = false
		env.glow_enabled = false
		env.ssao_enabled = false
		
		Engine.max_fps = 60
		Engine.physics_ticks_per_second = 30
		Engine.set_physics_jitter_fix(2.0)
	
	if OS.is_debug_build():
		print_rich("[color=web_gray]-verbose: Print infos\n-force_mode_1 = Force low fidelity\n-force_mode_2 = Force high fidelity\n[/color]")
		
	if print_infos:
		print_rich("[color=green]" + get_specs() + "[/color]")
		self.add_child(clock)
		clock.start(5)
		await clock.timeout
		print_rich("[color=green]" + str(Engine.get_frames_per_second()) + " fps[/color]")
	
	$AnimationPlayer.play_backwards("light")


func is_system_capable() -> bool:
	var res: bool = false
	
	var adapter_type: int = RenderingServer.get_video_adapter_type()
	if adapter_type == RenderingDevice.DEVICE_TYPE_DISCRETE_GPU:
		res = true
	
	return res


func get_specs() -> String:
	var res: String = "GPU Type: {gpu_t}\nGPU Name: {gpu_n}\nCPU Name: {cpu_n}\nProcessors count: {p_count}\nMotherboard Name: {motherb}\nArchitechture: {bits}\nScreen Size: {s_size}\nScreen refresh rate: {s_rate}"
	
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
