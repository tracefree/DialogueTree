@tool
class_name DialogueNodeLine
extends DialogueNode

@export_group("Data")
@export_multiline var text: String
@export var audio: AudioStream

## If true, dialogue continues only when the line was finished or the player presses
## something like "continue". Otherwise the dialogue graph continues evaluating while the line
## is being spoken.
@export var block_flow := true
@export_group("")

var lip_anim: Animation
var flow_slot_index := 0


func _init() -> void:
	if slots.size() == 0:
		slots.push_back(DialogueConnectionSlot.new(1, 1))


func execute(p_context: DialogueTree.Context) -> Error:
	p_context.tree.line_spoken.emit(text)
	# Example of how you could interact with your actor class to let them speak
	# p_context.responder.say(text, audio, facial_expression)
	# p_context.responder.voice_finished.connect(p_context.tree.line_finished.emit, CONNECT_ONE_SHOT)
	if block_flow:
		await p_context.responder.voice_finished
	return OK


func get_next(p_context: DialogueTree.Context) -> Array[DialogueNode]:
	return slots[flow_slot_index].get_next(p_context)


func _blocks_flow() -> bool:
	return block_flow


func _get_name() -> String:
	return "Line"


func _get_color() -> Color:
	return Color.LIGHT_GREEN
