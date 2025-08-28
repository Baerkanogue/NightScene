@tool
extends Node

## Push error to console and stop target node process.
func kill_and_warn(target: Node, error_message: String) -> void:
	var message: String = "\n{error}\nFlushing: \"{node}\"."
	message = message.format({"error": error_message, "node": target})
	push_error(message)
	target.set_process(false)

func find_all_childrens(target: Node) -> Array:
	var childrens: Array = []
	for child in target.get_children():
		childrens.append(child)
		childrens.append_array(find_all_childrens(child))
	return childrens
