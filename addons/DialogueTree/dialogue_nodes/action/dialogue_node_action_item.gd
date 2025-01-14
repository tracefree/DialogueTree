@tool
class_name DialogueNodeItem
extends DialogueNode
## An example action for exchanging items (you need to bring your own inventory system)

@export var item: Resource
@export var amount := 1
@export var give_to_initiator := true
@export var remove_from_inventory := true

var flow_slot_index := 0

func _init() -> void:
	if slots.size() == 0:
		slots.push_back(DialogueConnectionSlot.new(1, 1))


func execute(p_context: DialogueTree.Context) -> Error:
	## Implement logic to interact with your inventory system here
	return OK


func get_next(p_context: DialogueTree.Context) -> Array[DialogueNode]:
	return slots[flow_slot_index].get_next(p_context)


func _blocks_flow() -> bool:
	return false


func _get_name() -> String:
	return "Action: Item Exchange"


func _get_color() -> Color:
	return Color.ORANGE
