@tool
class_name DialogueNodeSubtree
extends DialogueNode

@export var subtree: DialogueTree


func _init() -> void:
	if slots.size() == 0:
		slots.push_back(DialogueConnectionSlot.new(1, -1))


func execute(_p_context: DialogueTree.Context) -> Error:
	return OK


func get_next(p_context: DialogueTree.Context) -> Array[DialogueNode]:
	var start_node := subtree.get_start_node()
	if not start_node:
		push_error("Dialogue subtree does not have a start node.")
		return []
	return start_node.get_next(p_context)


func _blocks_flow() -> bool:
	return false


func _get_name() -> String:
	return "Subtree"
