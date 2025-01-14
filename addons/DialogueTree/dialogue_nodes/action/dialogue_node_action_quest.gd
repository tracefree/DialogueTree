@tool
class_name DialogueNodeQuest
extends DialogueNode
## Example, you need to bring your own quest system

@export var quest_id: String
@export_enum("start", "complete") var operation: String


var flow_slot_index := 0


func _init() -> void:
	if slots.size() == 0:
		slots.push_back(DialogueConnectionSlot.new(1, 1))


func execute(_p_context: DialogueTree.Context) -> Error:
	# Implement logic to interact with your quest system here
	return OK


func get_next(p_context: DialogueTree.Context) -> Array[DialogueNode]:
	return slots[flow_slot_index].get_next(p_context)


func _blocks_flow() -> bool:
	return false


func _get_color() -> Color:
	return Color.ORANGE


func _get_name() -> String:
	return "Action: Quest"
