extends Node

# InputHandler - Manages all player input
signal unit_selected(unit: Unit)
signal unit_deselected()
signal unit_group_selected(group: Array[Unit])
signal unit_moved_to(unit: Unit, target: Vector2)
signal unit_attack_ordered(unit: Unit, target: Unit)
signal unit_attack_point_ordered(unit: Unit, position: Vector2)
signal unit_cycle_ordered(type_str: String)

# Selection state
var selected_units: Array[Unit] = []
var selection_mode: String = "single"  # "single", "box", "free"
var drag_start: Vector2 = Vector2.ZERO
var drag_current: Vector2 = Vector2.ZERO
var is_dragging: bool = false

# Unit cycling
var current_unit_type_index: int = 0
var unit_types: Array[String] = ["grunt", "psycho", "tough", "sniper", "pyro", "laser"]

# Attack mode
var attack_mode: String = "unit"  # "unit" or "position"
var attack_target: Unit = null
var attack_position: Vector2 = Vector2.ZERO

# Camera / viewport
var camera: Node2D = null
var viewport: Control = null
var screen_size: Vector2i = Vector2i.ZERO

# Input state
var mouse_position: Vector2 = Vector2.ZERO
var mouse_screen_position: Vector2 = Vector2.ZERO
var right_button_pressed: bool = false
var right_button_down: bool = false

func _ready() -> void:
	print("[InputHandler] Input handler initialized")
	_connect_input()
	_update_screen_size()

func _process(delta: float) -> void:
	_update_mouse_position()

# Connect input events
func _connect_input() -> void:
	input.mouse_entered.connect(_on_mouse_entered)
	input.mouse_exited.connect(_on_mouse_exited)
	input.mouse_moved.connect(_on_mouse_moved)
	input.mouse_button_down.connect(_on_mouse_button_down)
	input.mouse_button_up.connect(_on_mouse_button_up)
	input.key_pressed.connect(_on_key_pressed)

func _update_mouse_position() -> void:
	if camera:
		mouse_screen_position = input.get_mouse_position()
		mouse_position = camera.get_screen_position(mouse_screen_position)

func _update_screen_size() -> void:
	if viewport:
		screen_size = viewport.get_visible_rect().size

# Mouse events
func _on_mouse_entered() -> void:
	print("[InputHandler] Mouse entered viewport")

func _on_mouse_exited() -> void:
	print("[InputHandler] Mouse exited viewport")
	_deselect_all()

func _on_mouse_moved(position: Vector2) -> void:
	if is_dragging:
		drag_current = position
	else:
		drag_current = position

# Fixed: parameter name was "ppress" (typo)
func _on_mouse_button_down(button: int, pressed: bool) -> void:
	if not pressed:
		match button:
			INPUT.MOUSE_BUTTON_LEFT:
				_handle_left_click()
			INPUT.MOUSE_BUTTON_RIGHT:
				_handle_right_click()

func _on_mouse_button_up(button: int) -> void:
	pass  # Handle in _process for continuous press

func _handle_left_click() -> void:
	var screen_pos = input.get_mouse_position()
	var world_pos = camera.get_screen_position(screen_pos) if camera else screen_pos

	if selected_units.size() == 0:
		# Select single unit
		var clicked_unit: Unit = _get_unit_at_position(world_pos)
		if clicked_unit:
			select_unit(clicked_unit)
		else:
			_deselect_all()
	else:
		# Box selection or drag
		if is_dragging:
			_box_selection(world_pos)
		else:
			# Single click - add to selection
			var clicked_unit: Unit = _get_unit_at_position(world_pos)
			if clicked_unit and not selected_units.has(clicked_unit):
				selected_units.append(clicked_unit)
				unit_selected.emit(clicked_unit)

func _handle_right_click() -> void:
	var screen_pos = input.get_mouse_position()
	var world_pos = camera.get_screen_position(screen_pos) if camera else screen_pos

	if selected_units.size() > 0:
		# Right-click to attack
		attack_mode = "unit"
		var clicked_unit: Unit = _get_unit_at_position(world_pos)
		if clicked_unit:
			attack_target = clicked_unit
			unit_attack_ordered.emit(selected_units[0], attack_target)
		else:
			# Attack position
			attack_position = world_pos
			attack_mode = "position"
			unit_attack_point_ordered.emit(selected_units[0], attack_position)

func _box_selection(end_pos: Vector2) -> void:
	# Convert end position to world
	var end_world = camera.get_screen_position(end_pos) if camera else end_pos

	var units_to_select: Array[Unit] = []
	var units_to_deselect: Array[Unit] = []

	for unit in selected_units:
		# Fixed: Rect2 constructor needs start and end points
		var start_pos = drag_start
		var end_pos_rect = end_world
		var rect = Rect2(Vector2.min(start_pos, end_pos_rect), Vector2.max(start_pos, end_pos_rect) - Vector2.min(start_pos, end_pos_rect))
		
		if Vector2(unit.x, unit.y).position_in_rect(rect):
			units_to_deselect.append(unit)
		elif Vector2(unit.x, unit.y).position_in_rect(Rect2(drag_start, Vector2.ZERO)):
			units_to_select.append(unit)

	# Update selection
	for unit in units_to_deselect:
		if selected_units.has(unit):
			selected_units.erase(unit)

	for unit in units_to_select:
		if not selected_units.has(unit):
			selected_units.append(unit)
			unit_selected.emit(unit)

func _get_unit_at_position(pos: Vector2) -> Unit:
	# Find unit at position
	var all_units = get_tree().get_nodes_in_group("units")
	for unit in all_units:
		if unit is Unit and Vector2(unit.x, unit.y).distance_to(pos) < 5:
			return unit
	return null

func _deselect_all() -> void:
	selected_units.clear()
	unit_deselected.emit()

# Unit cycling (F1-F6)
func _on_key_pressed(event: InputEventKey) -> void:
	if event.keycode in [KEY_1, KEY_2, KEY_3, KEY_4, KEY_5, KEY_6]:
		var index: int = event.keycode - KEY_1
		if index < unit_types.size():
			var type: String = unit_types[index]
			unit_cycle_ordered.emit(type)
			print("[InputHandler] Cycled to unit type:", type)

# Helper functions
func get_selected_units() -> Array:
	return selected_units.duplicate()

func is_unit_selected(unit: Unit) -> bool:
	return selected_units.has(unit)

func get_selection_count() -> int:
	return selected_units.size()

func clear_selection() -> void:
	_deselect_all()

func select_unit(unit: Unit) -> void:
	if not selected_units.has(unit):
		selected_units.append(unit)
		unit_selected.emit(unit)

func deselect_unit(unit: Unit) -> void:
	if selected_units.has(unit):
		selected_units.erase(unit)
		unit_deselected.emit()

# Attack command handlers
func order_attack_unit(attacker: Unit, target: Unit) -> void:
	if attacker and target:
		attacker.set_order("attack", target)
		unit_attack_ordered.emit(attacker, target)

func order_attack_position(attacker: Unit, position: Vector2) -> void:
	if attacker:
		attacker.set_order("move", null, position)
		unit_attack_point_ordered.emit(attacker, position)

func order_move(attacker: Unit, position: Vector2) -> void:
	if attacker:
		attacker.set_order("move", null, position)
		unit_moved_to.emit(attacker, position)

func order_attack_and_move(attacker: Unit, target: Unit) -> void:
	if attacker and target:
		attacker.set_order("attack", target)
		unit_attack_ordered.emit(attacker, target)

# Utility
func get_all_units() -> Array:
	return get_tree().get_nodes_in_group("units")

func get_units_by_team(team: int) -> Array:
	var teams: Array[Unit] = []
	for unit in get_all_units():
		if unit is Unit and unit.team == team:
			teams.append(unit)
	return teams

func get_units_by_type(type_str: String) -> Array:
	var types: Array[Unit] = []
	for unit in get_all_units():
		if unit is Unit and unit.type == type_str:
			types.append(unit)
	return types

func get_vehicle_units() -> Array:
	var vehicles: Array[Unit] = []
	for unit in get_all_units():
		if unit.is_vehicle:
			vehicles.append(unit)
	return vehicles

func get_robot_units() -> Array:
	var robots: Array[Unit] = []
	for unit in get_all_units():
		if unit is Unit and not unit.is_vehicle:
			robots.append(unit)
	return robots

func get_screen_size() -> Vector2i:
	return screen_size

func get_camera() -> Node2D:
	return camera
