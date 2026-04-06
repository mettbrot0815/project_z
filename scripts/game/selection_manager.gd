extends Node

# Unit selection system: single, drag box, groups

signal selection_changed(selected_units: Array)

var selected_units: Array = []
var selection_start: Vector2 = Vector2.ZERO
var is_dragging_selection: bool = false

var groups: Array = [ [], [], [], [], [], [], [], [], [], [] ] # 0-9 hotkey groups

var _selection_rings: Dictionary = {}
var _selection_ring_scene: PackedScene


func _ready() -> void:
	_selection_ring_scene = preload("res://scenes/effects/selection_ring.tscn")


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
		_remove_selection_ring(unit)

	selected_units = units

	for unit in selected_units:
		unit.set("selected", true)
		_add_selection_ring(unit)

	if selected_units.size() > 0:
		AudioManager.play_ui_select()

	selection_changed.emit(selected_units)


func _add_selection_ring(unit: Node2D) -> void:
	if _selection_ring_scene == null:
		return
	
	if _selection_rings.has(unit):
		return
	
	var ring = _selection_ring_scene.instantiate()
	ring.global_position = unit.global_position
	ring.set_team(true)
	get_tree().current_scene.add_child(ring)
	_selection_rings[unit] = ring


func _remove_selection_ring(unit: Node2D) -> void:
	if _selection_rings.has(unit):
		_selection_rings[unit].queue_free()
		_selection_rings.erase(unit)


func _process(_delta: float) -> void:
	for unit in _selection_rings:
		if is_instance_valid(unit):
			_selection_rings[unit].global_position = unit.global_position
		else:
			_selection_rings[unit].queue_free()
			_selection_rings.erase(unit)


func clear_selection() -> void:
	set_selection([])


func issue_move_order(target_pos: Vector2) -> void:
	for unit in selected_units:
		unit.move_to(target_pos)


func get_global_mouse_position() -> Vector2:
	return get_viewport().get_canvas_transform().affine_inverse() * get_viewport().get_mouse_position()

