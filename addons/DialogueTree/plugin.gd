@tool
extends EditorPlugin

const DialogueTreeEditor = preload("dialogue_tree_editor.gd")
const DialogueTreeEditorScene = preload("dialogue_tree_editor.tscn")

var bottom_panel: DialogueTreeEditor
var bottom_panel_button: Button


func _enter_tree() -> void:
	bottom_panel = DialogueTreeEditorScene.instantiate()
	bottom_panel_button = add_control_to_bottom_panel(bottom_panel, "Dialogue")
	bottom_panel_button.visible = false


func _exit_tree() -> void:
	remove_control_from_bottom_panel(bottom_panel)
	bottom_panel.queue_free()


func _handles(object: Object) -> bool:
	return object is DialogueTree


func _edit(object: Object) -> void:
	bottom_panel.save()
	
	var dialogue_tree := object as DialogueTree
	if dialogue_tree:
		make_bottom_panel_item_visible(bottom_panel)
	else:
		return
	bottom_panel_button.visible = (dialogue_tree != null)
	bottom_panel.open_dialogue_tree(dialogue_tree)
	
	if dialogue_tree:
		make_bottom_panel_item_visible(bottom_panel)


func _apply_changes() -> void:
	bottom_panel.save()
