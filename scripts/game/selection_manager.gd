extends Node

# Unit selection system: single, drag box, groups

signal selection_changed(selected_units: Array)

var selected_units: Array = []
var selection_start: Vector2 = Vector2.ZERO
var is_dragging_selection: bool = false

var groups: Array = [ [], [], [], [], [], [], [], [], [], [] ] # 0-9 hotkey groups


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				selection_start = get_global_mouse_position()
				is_dragging_selection = true
			else:
				finish_selection()
				is_dragging_selection = false

	if event is InputEventMouseMotion and is_dragging_selection:
		update_selection_box()

	# Group hotkeys
	for i in range(10):
		if event.is_action_pressed("group_%d" % i):
			if Input.is_key_pressed(KEY_CTRL):
				groups[i] = selected_units.duplicate()
			else:
				set_selection(groups[i])


func update_selection_box() -> void:
	var current_pos = get_global_mouse_position()
	var rect = Rect2(selection_start, current_pos - selection_start).abs()

	var new_selection = []
	for unit in get_tree().get_nodes_in_group("selectable"):
		if rect.has_point(unit.global_position):
			if unit.get_team_id() == TerritoryManager.Owner.RED:
				new_selection.append(unit)

	selected_units = new_selection
	selection_changed.emit(selected_units)


func finish_selection() -> void:
	# If no drag, single click selection
	if get_global_mouse_position().distance_to(selection_start) < 6:
		var query = PhysicsPointQueryParameters2D.new()
		query.position = get_global_mouse_position()
		query.collision_mask = 0b1

		var results = get_viewport().get_world_2d().direct_space_state.intersect_point(query)
		if results.size() > 0:
			var unit = results[0]["collider"]
			if unit.get_team_id() == TerritoryManager.Owner.RED:
				set_selection([unit])
			else:
				clear_selection()
		else:
			clear_selection()


func set_selection(units: Array) -> void:
	for unit in selected_units:
		unit.set("selected", false)

	selected_units = units

	for unit in selected_units:
		unit.set("selected", true)

	selection_changed.emit(selected_units)


func clear_selection() -> void:
	set_selection([])


func issue_move_order(target_pos: Vector2) -> void:
	for unit in selected_units:
		unit.move_to(target_pos)


func get_global_mouse_position() -> Vector2:
	return get_viewport().get_canvas_transform().affine_inverse() * get_viewport().get_mouse_position()

