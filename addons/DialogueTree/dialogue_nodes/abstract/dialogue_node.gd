@tool
class_name DialogueNode
extends Resource

@export_storage var id: int
@export_storage var slots: Array[DialogueConnectionSlot]
@export_storage var position: Vector2


@warning_ignore("unused_parameter")
func execute(p_context: DialogueTree.Context) -> Error:
	return OK


@warning_ignore("unused_parameter")
func get_next(p_context: DialogueTree.Context) -> Array[DialogueNode]:
	return []


func _blocks_flow() -> bool:
	return false


func _get_name() -> String:
	return "Node"


func _get_color() -> Color:
	return Color.WHITE


func _to_string() -> String:
	return _get_name()
