@tool
extends Control

@export var graph_edit: GraphEdit
var dialogue_tree: DialogueTree


func _ready() -> void:
	graph_edit.add_valid_connection_type(DialogueConnection.Type.FLOW, DialogueConnection.Type.FLOW)
	graph_edit.node_created.connect(_on_node_created)
	graph_edit.node_deleted.connect(_on_node_deleted)
	graph_edit.nodes_connected.connect(_on_nodes_connected)
	graph_edit.nodes_disconnected.connect(_on_nodes_disconnected)


func open_dialogue_tree(p_dialogue_tree: DialogueTree) -> void:
	clear()
	await get_tree().process_frame
	
	dialogue_tree = p_dialogue_tree
	if dialogue_tree == null:
		return
	
	graph_edit.scroll_offset = dialogue_tree.scroll_offset
	graph_edit.zoom = dialogue_tree.zoom
	
	for dialogue_node in dialogue_tree.nodes:
		var graph_node := GraphDialogueNode.new()
		graph_node.dialogue_node = dialogue_node
		if graph_node == null: continue
		graph_edit.add_child(graph_node)
	
	for dialogue_node in dialogue_tree.nodes:
		var from_graph_node := get_graph_node_by_dialogue(dialogue_node)
		for slot in dialogue_node.slots:
			for connection in slot.outgoing:
				var to_graph_node := get_graph_node_by_dialogue(connection.node)
				graph_edit.connect_node(
						from_graph_node.name, from_graph_node.get_port_from_dialogue_slot(dialogue_node.slots.find(slot), false), \
						to_graph_node.name, to_graph_node.get_port_from_dialogue_slot(connection.slot_index, true)
				)


func clear() -> void:
	for child in graph_edit.get_children():
		# Avoid freeing _connection_layer
		if child is GraphDialogueNode: child.queue_free()


func get_graph_node_by_dialogue(dialogue_node: DialogueNode) -> GraphDialogueNode:
	for child in graph_edit.get_children():
		var graph_node := child as GraphDialogueNode
		if not graph_node: continue
		if graph_node.dialogue_node == dialogue_node:
			return graph_node
	
	return null


func _on_node_created(p_node: GraphDialogueNode) -> void:
	dialogue_tree.nodes.push_back(p_node.dialogue_node)
	dialogue_tree.emit_changed()


func _on_node_deleted(p_node: GraphDialogueNode) -> void:
	dialogue_tree.nodes.erase(p_node.dialogue_node)
	dialogue_tree.emit_changed()


func _on_nodes_connected(from_node: StringName, from_port: int, to_node: StringName, to_port: int) -> void:
	var from_graph_node := graph_edit.get_node(NodePath(from_node)) as GraphDialogueNode
	var to_graph_node := graph_edit.get_node(NodePath(to_node)) as GraphDialogueNode

	var from_slot := from_graph_node.get_dialogue_slot_from_port(from_port, false)
	var to_slot := to_graph_node.get_dialogue_slot_from_port(to_port, true)
	
	var to_connection := DialogueConnection.new()
	to_connection.node = to_graph_node.dialogue_node
	to_connection.slot_index = to_slot
	from_graph_node.dialogue_node.slots[from_slot].outgoing.push_back(to_connection)
	dialogue_tree.emit_changed()


func _on_nodes_disconnected(from_node: StringName, from_port: int, to_node: StringName, to_port: int) -> void:
	var from_graph_node := graph_edit.get_node(NodePath(from_node)) as GraphDialogueNode
	var to_graph_node := graph_edit.get_node(NodePath(to_node)) as GraphDialogueNode
	
	var from_slot := from_graph_node.get_dialogue_slot_from_port(from_port, false)
	var to_slot := to_graph_node.get_dialogue_slot_from_port(to_port, true)
	
	for connection in from_graph_node.dialogue_node.slots[from_slot].outgoing:
		if connection.node == to_graph_node.dialogue_node and connection.slot_index == to_slot:
			from_graph_node.dialogue_node.slots[from_slot].outgoing.erase(connection)
	
	dialogue_tree.emit_changed()


func save() -> void:
	if not dialogue_tree: return
	dialogue_tree.scroll_offset = graph_edit.scroll_offset
	dialogue_tree.zoom = graph_edit.zoom
