extends Node3D

@export var world_environment: WorldEnvironment
@export var force_low: bool = false
@export var print_infos: bool = false

var clock: Timer = Timer.new()

func _ready() -> void:
	var is_low_spec: bool = not is_system_capable()
	
	var args: Array = OS.get_cmdline_args()
	if "-low" in args:
		force_low = true
	
	if is_low_spec or force_low:
		var env: Environment = world_environment.environment
		env.sdfgi_enabled = false
		env.glow_enabled = false
		env.ssao_enabled = false
		Engine.max_fps = 60
		Engine.physics_ticks_per_second = 30
		Engine.set_physics_jitter_fix(2.0)
	
	if print_infos:
		print("-low: Force low specs config.\n")
		print_rich("[color=green]" + get_specs() + "[/color]")
		self.add_child(clock)
		clock.start(5)
		await clock.timeout
		print_rich("[color=green]" + str(Engine.get_frames_per_second()) + " fps[/color]")


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
