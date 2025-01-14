@tool
class_name DialogueTree
extends Resource

class Context extends RefCounted:
	var tree: DialogueTree
	var initiator: Node # Set the type to your Actor / NPC class if you have one
	var responder: Node


signal choice_requested(choices: Array[DialogueNodeChoice])
signal line_spoken(text: String)
signal line_finished
signal finished

@export_storage var nodes: Array[DialogueNode] = []
@export_storage var scroll_offset: Vector2 = Vector2.ZERO
@export_storage var zoom: float = 1.0

var _currently_speaking_line := false


func enter(p_context: Context) -> void:
	if nodes.is_empty():
		finished.emit()
		return
	
	var start_node := get_start_node()
	assert(start_node != null, "Error: Dialogue tree has no start node")
	_evaluate_node(start_node, p_context)
	line_spoken.connect(func(_text: String) -> void: _currently_speaking_line = true)
	line_finished.connect(func() -> void: _currently_speaking_line = false)


func choose(choice: DialogueNodeChoice, p_context: Context) -> void:
	_evaluate_node(choice, p_context)


func get_start_node() -> DialogueNodeStart:
	for node in nodes:
		if node is DialogueNodeStart:
			return node
	return null


func _evaluate_node(node: DialogueNode, p_context: Context) -> void:
	@warning_ignore("redundant_await")
	await node.execute(p_context)

	var next_nodes := node.get_next(p_context)
	var choices: Array[DialogueNodeChoice] = []
	for candidate in next_nodes:
		if candidate is DialogueNodeChoice:
			choices.push_back(candidate)
		else:
			_evaluate_node(candidate, p_context)
			return
	
	if not choices.is_empty():
		if _currently_speaking_line:
			await line_finished
		choice_requested.emit(choices)
