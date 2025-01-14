@tool
class_name DialogueNodeStart
extends DialogueNode

var start_slot_index := 0


func _init() -> void:
	if slots.size() == 0:
		slots.push_back(DialogueConnectionSlot.new(-1, 1))


@warning_ignore("unused_parameter")
func execute(p_context: DialogueTree.Context) -> Error:
	return OK


func get_next(p_context: DialogueTree.Context) -> Array[DialogueNode]:
	return slots[start_slot_index].get_next(p_context)


func _get_name() -> String:
	return "Start"
