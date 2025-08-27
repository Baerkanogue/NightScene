extends Node

## Push error to console and stop target node process.
func kill_and_warn(target: Node, error_message: String) -> void:
	var message: String = "\n{error}\nFlushing: \"{node}\"."
	message = message.format({"error": error_message, "node": target})
	push_error(message)
	target.set_process(false)

### Returns the sine transform of a float.[br]
### [br]
### [b]Parameters:[/b]
### Target: Float to transform.[br]
### Frequency: The amount of waves in a unit of time.[br]
### Amplitude: The "contrast" of the wave.[br]
### Phase Offset: The horizontal offset of the wave. Makes it scrolls.[br]
### Vertical Offset: Offset vertically the whole wave.
#func sine_transform(target: float, frequency: float, amplitude: float, phase_offset: float, vertical_offset: float) -> float:
	#return sin(target * frequency + phase_offset) * amplitude + vertical_offset
