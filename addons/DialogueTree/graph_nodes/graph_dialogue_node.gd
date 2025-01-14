class_name GraphDialogueNode
extends GraphNode

@export var dialogue_node: DialogueNode:
	set(value):
		if dialogue_node == value: return
		dialogue_node = value
		update()


func _ready() -> void:
	resizable = true
	custom_minimum_size.x = 200.0
	
	position_offset_changed.connect(
		func() -> void:
			if not dialogue_node: return
			dialogue_node.position = position_offset
			dialogue_node.emit_changed()
	)
	node_selected.connect(_on_selected)


func _on_selected() -> void:
	if not dialogue_node: return
	EditorInterface.edit_resource(dialogue_node)


func update() -> void:
	if dialogue_node == null: return
	position_offset = dialogue_node.position
	title = dialogue_node._get_name()
	
	if not is_inside_tree():
		await tree_entered
	
	# Add property fields
	var data_group := false
	for property in dialogue_node.get_property_list():
		if property[&"usage"] == PROPERTY_USAGE_GROUP:
			data_group = property[&"name"] == "Data"
			continue
			
		if not data_group: continue
		
		var label := Label.new()
		label.text = (property[&"name"] as String).capitalize()
		add_child(label)
		
		match property[&"type"]:
			TYPE_BOOL:
				var check_box := CheckBox.new()
				check_box.button_pressed = dialogue_node.get(property[&"name"]) as bool
				check_box.toggled.connect(
					func(toggled_on: bool) -> void:
						dialogue_node.set(property[&"name"], toggled_on)
				)
				add_child(check_box)
			TYPE_STRING:
				if property[&"hint"] == PROPERTY_HINT_MULTILINE_TEXT:
					var text_edit := TextEdit.new()
					text_edit.text = dialogue_node.get(property[&"name"]) as String
					text_edit.scroll_fit_content_height = true
					text_edit.text_changed.connect(
						func() -> void:
							dialogue_node.set(property[&"name"], text_edit.text)
					)
					add_child(text_edit)
				elif property[&"hint"] == PROPERTY_HINT_ENUM:
					var option_btn := OptionButton.new()
					for option in property[&"hint_string"].split(","):
						option_btn.add_item(option)
					option_btn.item_selected.connect(
						func(index: int) -> void:
							dialogue_node.set(property[&"name"], option_btn.get_item_text(index))
					)
					add_child(option_btn)
				else:
					var line_edit := LineEdit.new()
					line_edit.text = dialogue_node.get(property[&"name"]) as String
					line_edit.text_changed.connect(
						func(new_text: String) -> void:
							dialogue_node.set(property[&"name"], new_text)
					)
					add_child(line_edit)
			TYPE_OBJECT:
				if not GraphDialogueNode.class_is_resource(property[&"class_name"]):
					continue
				
				var resource_picker := ClassDB.instantiate("EditorResourcePicker") as EditorResourcePicker
				resource_picker.base_type = property[&"class_name"]
				resource_picker.edited_resource = dialogue_node.get(property[&"name"])
				resource_picker.resource_changed.connect(
					func(p_resource: Resource) -> void:
						dialogue_node.set(property[&"name"], p_resource)
				)
				resource_picker.resource_selected.connect(
					func(p_resource: Resource, _p_inspect: bool) -> void:
						EditorInterface.edit_resource(p_resource)
				)
				add_child(resource_picker)
	
	# Theme
	var color := dialogue_node._get_color()
	var stylebox: StyleBoxFlat = get_theme_stylebox("titlebar", "GraphNode").duplicate()
	stylebox.bg_color = color
	add_theme_stylebox_override("titlebar", stylebox)
	
	# Add slots
	for slot in dialogue_node.slots:
		var label := Label.new()
		label.text = slot.name
		add_child(label)
		var index := label.get_index()
		if slot.ingoing_type >= 0:
			set_slot_enabled_left(index, true)
			set_slot_type_left(index, slot.ingoing_type)
			set_slot_color_left(index, color)
		if slot.outgoing_type >= 0:
			set_slot_enabled_right(index, true)
			set_slot_type_right(index, slot.outgoing_type)
			set_slot_color_right(index, color)


func get_port_from_dialogue_slot(p_dialogue_slot: int, left: bool) -> int:
	var current_dialogue_slot := -1
	var port_index := -1

	for slot in get_child_count():
		if (is_slot_enabled_left(slot) or is_slot_enabled_right(slot)):
			current_dialogue_slot += 1
		else:
			continue
		
		if (left and is_slot_enabled_left(slot)) or (not left and is_slot_enabled_right(slot)):
			port_index += 1
		
		if current_dialogue_slot == p_dialogue_slot:
			return port_index
		
	return -1


func get_dialogue_slot_from_port(p_port_index: int, left: bool) -> int:
	var slot := get_input_port_slot(p_port_index) if left \
					else get_output_port_slot(p_port_index)

	for slot_index in range(0, slot):
		if not (is_slot_enabled_left(slot_index) or is_slot_enabled_right(slot_index)):
			slot -= 1
	
	return slot


static func class_is_resource(p_class_name: StringName) -> bool:
	if ClassDB.is_parent_class(p_class_name, &"Resource"):
		return true
	
	for global_class in ProjectSettings.get_global_class_list():
		if global_class[&"class"] == p_class_name:
			return ClassDB.is_parent_class(global_class[&"base"], &"Resource")
	
	return false
