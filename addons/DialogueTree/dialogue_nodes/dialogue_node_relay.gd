@tool
class_name DialogueNodeRelay
extends DialogueNode

@export_group("Data")
@export var name: String
@export_group("")

var flow_slot_index := 0


func _init() -> void:
	if slots.size() == 0:
		slots.push_back(DialogueConnectionSlot.new(1, 1))


func execute(_p_context: DialogueTree.Context) -> Error:
	return OK


func get_next(p_context: DialogueTree.Context) -> Array[DialogueNode]:
	var next_nodes := slots[flow_slot_index].get_next(p_context)
	if not next_nodes.is_empty():
		return next_nodes
	
	for dialogue_node in p_context.tree.nodes:
		if dialogue_node is DialogueNodeRelay and dialogue_node.name == name:
			return dialogue_node.get_next(p_context)
	
	return []


func _blocks_flow() -> bool:
	return false


func _get_name() -> String:
	return "Relay"


func _get_color() -> Color:
	return Color.WHITE
