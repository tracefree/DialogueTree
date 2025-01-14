@tool
class_name DialogueNodeFollow
extends DialogueNode


func _init() -> void:
	if slots.size() == 0:
		slots.push_back(DialogueConnectionSlot.new(1, -1))


func execute(p_context: DialogueTree.Context) -> Error:
	p_context.responder.ai.toggle_follow(p_context.initiator)
	return OK


func _blocks_flow() -> bool:
	return true


func _get_name() -> String:
	return &"Toggle Follow"


func _get_color() -> Color:
	return Color.ORANGE
