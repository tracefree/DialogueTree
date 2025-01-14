@tool
class_name DialogueNodeCondition
extends DialogueNode

const FLOW_INDEX	= 0
const TRUE_INDEX	= 1
const FALSE_INDEX	= 2

var result: bool


func _init() -> void:
	if slots.size() == 0:
		slots.push_back(DialogueConnectionSlot.new(1, -1))
		slots.push_back(DialogueConnectionSlot.new(-1, 1, &"True"))
		slots.push_back(DialogueConnectionSlot.new(-1, 1, &"False"))


func execute(p_context: DialogueTree.Context) -> Error:
	result = evaluate(p_context)
	return OK


func _blocks_flow() -> bool:
	return false


func _get_name() -> String:
	return &"Condition"


func _get_color() -> Color:
	return Color.LIGHT_BLUE


@warning_ignore("unused_parameter")
func evaluate(p_context: DialogueTree.Context) -> bool:
	return false


func get_next(p_context: DialogueTree.Context) -> Array[DialogueNode]:
	var index := TRUE_INDEX if result else FALSE_INDEX
	var next_nodes := slots[index].get_next(p_context)
	for node in next_nodes:
		if node is DialogueNodeCondition:
			next_nodes.append_array(node.get_next(p_context))
	return next_nodes
