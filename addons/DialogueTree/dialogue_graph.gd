@tool
extends GraphEdit

signal node_created(graph_node: GraphDialogueNode)
signal node_deleted(graph_node: GraphDialogueNode)
signal nodes_connected(from_node: StringName, from_port: int, to_node: StringName, to_port: int)
signal nodes_disconnected(from_node: StringName, from_port: int, to_node: StringName, to_port: int)

const DialoguePopupScene := preload("dialogue_tree_popup.tscn")

var connect_to_empty_from_node: String
var connect_to_empty_from_port: int


func _on_connection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int) -> void:
	connect_node(from_node, from_port, to_node, to_port)
	nodes_connected.emit(from_node, from_port, to_node, to_port)


func _on_disconnection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int) -> void:
	disconnect_node(from_node, from_port, to_node, to_port)
	nodes_disconnected.emit(from_node, from_port, to_node, to_port)


func _on_popup_request(p_position: Vector2) -> void:
	show_popup(p_position)


func show_popup(p_position: Vector2, from_node: String = "") -> void:
	var popup := DialoguePopupScene.instantiate()
	add_child(popup)
	popup.position = global_position + p_position
	popup.popup()
	popup.graph_node_created.connect(
		func(graph_node: GraphDialogueNode) -> void:
			graph_node.position_offset = (scroll_offset + p_position) / zoom
			graph_node.dialogue_node.position = graph_node.position_offset
			add_child(graph_node)
			node_created.emit(graph_node)
			if from_node != "":
				connection_request.emit(from_node, 0, graph_node.name, 0)
	)
	popup.popup_hide.connect(
		func() -> void:
			popup.queue_free()
	)


func _on_connection_to_empty(from_node: StringName, from_port: int, release_position: Vector2) -> void:
	show_popup(release_position, from_node)


func _on_delete_nodes_request(nodes: Array[StringName]) -> void:
	for node_name in nodes:
		var graph_node := get_node(NodePath(node_name)) as GraphDialogueNode
		for connection in get_connection_list():
			if connection[&"from_node"] == graph_node.name or connection[&"to_node"] == graph_node.name:
				disconnection_request.emit(
					connection[&"from_node"], connection[&"from_port"],
					connection[&"to_node"], connection[&"to_port"]
				)
		await get_tree().process_frame
		node_deleted.emit(graph_node)
		graph_node.queue_free()
