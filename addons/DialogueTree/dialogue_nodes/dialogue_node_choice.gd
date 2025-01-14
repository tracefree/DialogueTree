@tool
class_name DialogueNodeChoice
extends DialogueNode

@export_group("Data")
@export_multiline var text: String
@export_group("")

@export_storage var new_content := true

var flow_slot_index := 0


func _init() -> void:
	if slots.size() == 0:
		slots.push_back(DialogueConnectionSlot.new(1, 1))


func get_next(p_context: DialogueTree.Context) -> Array[DialogueNode]:
	return slots[flow_slot_index].get_next(p_context)


func _blocks_flow() -> bool:
	return true


func _get_name() -> String:
	return "Choice"


func _get_color() -> Color:
	return Color.REBECCA_PURPLE
