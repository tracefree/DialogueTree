@tool
extends PopupMenu

signal graph_node_created(graph_node: GraphNode)

const DIALOGUE_NODE_DIR := &"res://addons/DialogueTree/dialogue_nodes/"

var node_types: Dictionary[String, Dictionary] = {
	"": {},
}

func _init() -> void:
	clear()
	for folder_name in DirAccess.get_directories_at(DIALOGUE_NODE_DIR):
		if folder_name == "abstract": continue
		
		var submenu := PopupMenu.new()
		submenu.name = folder_name.capitalize()
		submenu.id_pressed.connect(_on_id_pressed.bind(submenu.name))
		add_child(submenu)
		add_submenu_item(submenu.name, submenu.name)
		node_types[submenu.name] = {} as Dictionary[int, GDScript]
		
		var subdir := DIALOGUE_NODE_DIR.path_join(folder_name)
		var dir_id := 0
		for file_name in DirAccess.get_files_at(subdir):
			if file_name.ends_with(".uid"): continue
			
			var node_name := " ".join(file_name.split("_").slice(3)).get_basename().capitalize()
			submenu.add_item(node_name, dir_id)
			var script_path := subdir.path_join(file_name)
			node_types[submenu.name][dir_id] = load(script_path)
			dir_id += 1
	
	var top_id := 0
	for file_name in DirAccess.get_files_at(DIALOGUE_NODE_DIR):
		if file_name.ends_with(".uid"): continue
		
		var node_name := " ".join(file_name.split("_").slice(2)).get_basename().capitalize()
		add_item(node_name, top_id)
		
		var script_path := DIALOGUE_NODE_DIR.path_join(file_name)
		node_types[""][top_id] = load(script_path)
		top_id += 1
	
	id_pressed.connect(_on_id_pressed.bind(""))


func _on_id_pressed(id: int, category: String) -> void:
	var node_type: GDScript = node_types[category][id]
	var dialogue_node: DialogueNode = node_type.new()
	var graph_node := GraphDialogueNode.new()
	graph_node.dialogue_node = dialogue_node
	graph_node_created.emit(graph_node)
