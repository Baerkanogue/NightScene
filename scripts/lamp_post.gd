@tool
extends Node3D


@export var light: OmniLight3D
@export var amplitude: float = 1.0
@export var frequency: float = 1.0
@export var v_offset: float = 1.0

var phase: float = 0.0


func _ready() -> void:
	var childs: Array = find_all_childrens(self)
	if not light in childs or not light:
		for child in childs:
			if child is OmniLight3D:
				light = child
	
	if not light:
		Utils.kill_and_warn(self,"No Omnilight found.")


func _process(delta: float) -> void:
	light_flicker(delta)

func find_all_childrens(target: Node) -> Array:
	var childrens: Array = []
	for child in target.get_children():
		childrens.append(child)
		childrens.append_array(find_all_childrens(child))
	return childrens

func light_flicker(delta: float) -> void:
	phase += frequency * delta
	phase = fmod(phase, TAU)
	light.light_energy = sin(phase) * amplitude + v_offset
