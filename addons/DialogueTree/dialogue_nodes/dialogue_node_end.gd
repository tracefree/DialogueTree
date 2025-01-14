@tool
class_name DialogueNodeEnd
extends DialogueNode


func _init() -> void:
	if slots.is_empty():
		slots.push_back(DialogueConnectionSlot.new(1, -1))


func execute(p_context: DialogueTree.Context) -> Error:
	p_context.tree.finished.emit() # Do whatever needs to be done to close your dialogue UI
	return OK


func _blocks_flow() -> bool:
	return true


func _get_name() -> String:
	return "End"
