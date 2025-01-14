@tool
extends DialogueNodeCondition
## This is an example, you'd need a quest system and implement checks for it here

@export var quest_id: StringName
@export_enum("inactive", "active", "completed") var quest_condition := "inactive"
@export_enum("none", "equal", "before", "after") var stage_condition := "none"
@export var stage := 0


func evaluate(_p_context: DialogueTree.Context) -> bool:
	## Implement logic to interact with your quest system
	return false


func _get_name() -> String:
	return "Condition: Quest"
