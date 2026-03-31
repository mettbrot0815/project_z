extends Node

# UnitAI - Controls autonomous AI behaviors for all units
signal unit_moved(unit: Unit)
signal unit_attacked(unit: Unit, target: Unit)
signal unit_retreated(unit: Unit, reason: String)

# AI State Machine
enum AIState {IDLE, MOVE_TO_TARGET, ATTACK, DEFEND_FORT, RETREAT, SEEK_COVER}

# Intelligence tier behaviors
var behavior_profiles: Dictionary = {
	1: {aggressive: true, expose: true, flanking: false, cover: false, retreat: false},
	2: {aggressive: true, expose: false, flanking: false, cover: false, retreat: false},
	3: {aggressive: true, expose: true, flanking: false, cover: false, retreat: false},
	4: {aggressive: true, expose: false, flanking: false, cover: true, retreat: false},
	5: {aggressive: true, expose: false, flanking: false, cover: true, retreat: false},
	6: {aggressive: true, expose: false, flanking: false, cover: true, retreat: false},
	7: {aggressive: true, expose: false, flanking: true, cover: true, retreat: true},
	8: {aggressive: true, expose: false, flanking: true, cover: true, retreat: true},
	9: {aggressive: false, expose: false, flanking: true, cover: true, retreat: true, stealth: true},
	10: {aggressive: false, expose: false, flanking: true, cover: true, retreat: true, stealth: true}
}

# AI Controller for all units in scene
var active_units: Array[Unit] = []
var ai_enabled: bool = true
var decision_interval: float = 1.0

func _ready() -> void:
	print("[UnitAI] AI Controller initialized")
	_scan_units()

func _process(delta: float) -> void:
	if not ai_enabled:
		return

	_update_active_units()
	_make_decisions(delta)

func _scan_units() -> void:
	active_units.clear()
	var units = get_tree().get_nodes_in_group("units")
	for unit in units:
		if unit is Unit:
			active_units.append(unit)
	print("[UnitAI] Found", active_units.size(), "active units")

func _update_active_units() -> void:
	var current_units = get_tree().get_nodes_in_group("units")
	var removed: Array[Unit] = []
	for unit in active_units:
		if not current_units.has(unit):
			removed.append(unit)
	for unit in removed:
		active_units.erase(unit)
	print("[UnitAI] Active units:", active_units.size())

func _make_decisions(delta: float) -> void:
	for unit in active_units:
		if unit.is_dead:
			continue

		_decision_for_unit(unit, delta)

func _decision_for_unit(unit: Unit, delta: float) -> void:
	var tier: int = unit.intelligence
	if tier not in behavior_profiles:
		tier = 5  # Default

	var profile: Dictionary = behavior_profiles[tier]

	# Get nearest enemy
	var nearest_enemy: Unit = _find_nearest_enemy(unit)

	if nearest_enemy and nearest_enemy.is_alive():
		# Combat decision
		if unit.is_vehicle:
			if unit.has_driver and unit.driver_unit.is_alive():
				_vehicle_combat_decision(unit, nearest_enemy, profile)
			else:
				# Driver dead - become neutral
				unit.is_vehicle = false
				unit.has_driver = false
		else:
			_robot_combat_decision(unit, nearest_enemy, profile)
	elif unit.target_position != Vector2.ZERO:
		# Movement decision
		if not unit.is_moving:
			unit.set_order("move", null, unit.target_position)
			unit_moved.emit(unit)
	else:
		# Idle - maybe patrol
		if not unit.is_moving and tier >= 6:
			# Patrol behavior
			unit.target_position = _patrol_position(unit)

func _find_nearest_enemy(unit: Unit) -> Unit:
	var nearest: Unit = null
	var min_dist: float = float("inf")

	var all_units = get_tree().get_nodes_in_group("units")
	for other in all_units:
		if other is Unit and other.team != unit.team and other.is_alive():
			var dist: float = unit.get_position().distance_to(other.get_position())
			if dist < min_dist:
				min_dist = dist
				nearest = other

	return nearest

# Robot combat decision
func _robot_combat_decision(unit: Unit, enemy: Unit, profile: Dictionary) -> void:
	var dist: float = unit.get_position().distance_to(enemy.get_position())
	var tier: int = unit.intelligence

	# Intelligence affects aggression
	var aggression: float = 1.0
	if tier >= 9:
		aggression = 0.3  # Snipers are cautious
	elif tier >= 7:
		aggression = 0.6
	elif tier <= 3:
		aggression = 1.0  # Grunts charge in

	# Move closer if not in range
	if dist > unit.range:
		unit.target_position = enemy.get_position()
		unit.set_order("move", enemy, unit.target_position)

	elif dist <= unit.range:
		# In range - attack
		unit.set_order("attack", enemy, unit.target_position)
		unit_attacked.emit(unit, enemy)

	# High intelligence units might retreat if low health
	if aggression < 0.5 and unit.health < unit.max(health, 1) * 0.3:
		if profile.retreat:
			unit.set_order("retreat")
			unit_retreated.emit(unit, "low health")

# Vehicle combat decision
func _vehicle_combat_decision(unit: Unit, enemy: Unit, profile: Dictionary) -> void:
	# Vehicles prioritize movement and positioning
	var dist: float = unit.get_position().distance_to(enemy.get_position())

	# If has driver, engage
	if unit.has_driver and unit.driver_unit.is_alive():
		if dist > 30:  # Vehicles need to close distance
			unit.target_position = enemy.get_position()
			unit.set_order("move", enemy, unit.target_position)
		elif dist <= 40:
			unit.set_order("attack", enemy, unit.target_position)
	else:
		# No driver - become obstacle
		unit.is_vehicle = false
		unit.has_driver = false

func _patrol_position(unit: Unit) -> Vector2:
	# Simple patrol - move in circle or back and forth
	# Would implement proper waypoint system
	var patrol_radius: float = 50.0
	var angle: float = Time.get_ticks_msec() / 1000.0 * 0.001

	var patrol_x: float = unit.x + cos(angle) * patrol_radius
	var patrol_y: float = unit.y + sin(angle) * patrol_radius

	return Vector2(patrol_x, patrol_y)

# Strategic decisions
func _find_cover(unit: Unit) -> Vector2:
	# Find nearest cover object
	# Simplified - returns current position
	return unit.get_position()

func _find_high_ground(unit: Unit) -> Vector2:
	# Find elevated terrain
	# Simplified
	return unit.get_position()

func _find_sniper_position(unit: Unit) -> Vector2:
	# Sniper hides until enemy is in range
	return Vector2(0, 0)  # Would return hidden position

func _find_flanking_path(unit: Unit, target: Unit) -> Vector2:
	# Calculate flanking route
	# Simplified - just return target for now
	return target.get_position()

# Emergency decisions
func _should_retreat(unit: Unit, reason: String) -> bool:
	match reason:
		"low_health":
			return unit.health < unit.max(health, 1) * 0.25
		"low_ammo":
			return false  # No ammo system in original
		"overwhelmed":
			return true  # Too many enemies
		_:
			return false

func _should_advance(unit: Unit, reason: String) -> bool:
	match reason:
		"enemy_fort":
			# Use GameManager or SectorManager to get fort position
			# Placeholder - return false
			return false
		"flag_capture":
			# Use GameManager or SectorManager to get flag position
			# Placeholder - return false
			return false
		_:
			return false

# Utility functions
func get_units_by_team(team: int) -> Array:
	var teams: Array[Unit] = []
	for unit in active_units:
		if unit.team == team:
			teams.append(unit)
	return teams

func get_units_by_type(type_str: String) -> Array:
	var types: Array[Unit] = []
	for unit in active_units:
		if unit.type == type_str:
			types.append(unit)
	return types

func get_vehicle_units() -> Array:
	var vehicles: Array[Unit] = []
	for unit in active_units:
		if unit.is_vehicle:
			vehicles.append(unit)
	return vehicles

func get_robot_units() -> Array:
	var robots: Array[Unit] = []
	for unit in active_units:
		if not unit.is_vehicle:
			robots.append(unit)
	return robots

func toggle_ai(enabled: bool) -> void:
	ai_enabled = enabled
	print("[UnitAI] AI toggled:", enabled)

func clear_orders(unit: Unit) -> void:
	unit.orders.clear()
	unit.current_order = ""

func set_global_order(team: int, order: String, target: Unit = null, position: Vector2 = Vector2.ZERO) -> void:
	var units = get_units_by_team(team)
	for unit in units:
		unit.set_order(order, target, position)
