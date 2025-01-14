@tool
class_name DialogueConnectionSlot
extends Resource

@export var name: StringName = &"Flow"
@export var ingoing_type := -1
@export var outgoing_type := -1
@export var ingoing: Array[DialogueConnection]
@export var outgoing: Array[DialogueConnection]


func _init(p_ingoing_type: int = -1, p_outgoing_type: int = -1, p_name: StringName = &"") -> void:
	if ingoing_type == -1:
		ingoing_type = p_ingoing_type
	if outgoing_type == -1:
		outgoing_type = p_outgoing_type
	name = p_name


func get_next(p_context: DialogueTree.Context) -> Array[DialogueNode]:
	var next_nodes: Array[DialogueNode] = []
	for connection in outgoing:
		if connection.node._blocks_flow():
			next_nodes.push_back(connection.node)
		else:
			connection.node.execute(p_context)
			next_nodes.append_array(connection.node.get_next(p_context))
	
	return next_nodes
