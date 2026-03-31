extends Node2D

class_name Unit

# Unit configuration (loaded from JSON)
@export var type: String = "grunt"
@export var team: int = 0
@export var speed: float = 1.0
@export var armor: int = 10
@export var health: int = 100
@export var damage: int = 10
@export var range: float = 12.0
@export var intelligence: int = 5
@export var weapon: String = "none"
@export var color: String = "#FFFFFF"
@export var build_time: int = 5

# Runtime properties
@export_group("Runtime")
var x: float = 0
var y: float = 0
var is_dead: bool = false
var is_vehicle: bool = false
var has_driver: bool = false
var driver_unit: Unit = null
var orders: Array[String] = []  # Command queue
var current_order: String = ""
var target: Unit = null
var target_position: Vector2 = Vector2.ZERO
var is_moving: bool = false
var is_attacking: bool = false

# Behavior state
var behavior_state: String = "idle"  # "idle", "move", "attack", "retreat"
var behavior_timer: float = 0.0
var last_order_time: float = 0.0

# Signals
signal unit_died()
signal unit_taken_damage(amount: int)
signal unit_order_received(order: String)
signal unit_reached_target()

# Constants for weapon damage multipliers
const WEAPON_DAMAGE_MULTIPLIERS := {
	"machinegun": 1.0,
	"sniper": 2.5,
	"flamethrower": 0.66,  # 8 / 12 ≈ 0.66
	"laser": 1.0,
	"cannon": 3.5,
	"mortar": 1.0,
	"gatling": 1.0,
	"turret": 1.0,
	"missile": 1.0
}

func _ready() -> void:
	print("[Unit] Unit spawned:", type, "Team:", team)

func _process(delta: float) -> void:
	if is_dead:
		return

	# Update behavior
	_update_behavior(delta)

	# Execute current order
	if current_order != "":
		_execute_order(delta)

# Update behavior based on intelligence tier
func _update_behavior(delta: float) -> void:
	behavior_timer += delta

	# Check if behavior timer expired
	if behavior_timer < 1.0:
		return

	behavior_timer = 0.0
	behavior_state = "idle"

	# Get intelligence tier
	var tier: int = _get_intelligence_tier()

	# AI Decision Making
	if target and is_alive(target) and not is_moving:
		behavior_state = "attack"
	elif target and is_alive(target) and is_moving:
		behavior_state = "attack"
	else:
		# Find nearby enemies or move to target position
		var nearby_enemy: Unit = _find_nearest_enemy()
		if nearby_enemy and is_alive(nearby_enemy):
			behavior_state = "attack"
			target = nearby_enemy
		elif target_position != Vector2.ZERO:
			behavior_state = "move"
			target_position = _find_path_to_target(target_position)

	# Apply intelligence-based behavior
	_apply_intelligence_behavior(tier)

# Get intelligence tier (1-10)
func _get_intelligence_tier() -> int:
	return intelligence

# Apply intelligence-based behaviors
func _apply_intelligence_behavior(tier: int) -> void:
	match tier:
		1..3:
			# Low intelligence - aggressive, expose position
			if behavior_state == "move":
				target_position = _get_direct_path_to_target()

		4..6:
			# Medium intelligence - balanced
			if behavior_state == "move":
				target_position = _find_safe_path_to_target()

		7..8:
			# High intelligence - tactical
			if behavior_state == "move":
				target_position = _find_tactical_path_to_target()
			if behavior_state == "attack":
				if _is_exposed_to_fire():
					target_position = _find_cover()

		9..10:
			# Elite intelligence - stealth, ambush
			if behavior_state == "move":
				target_position = _get_stealth_approach()
			if behavior_state == "attack":
				if _is_exposed_to_fire():
					target_position = _find_cover()
					# Snipers hide after attack
					if weapon == "sniper":
						target_position = _find_sniper_position()

# Get direct path (ignores obstacles)
func _get_direct_path_to_target() -> Vector2:
	return Vector2(target.x - x, target.y - y) if target else Vector2.ZERO

# Find safe path (avoid exposure)
func _find_safe_path_to_target() -> Vector2:
	# Simplified - in full implementation would use pathfinding with safety checks
	return _get_direct_path_to_target()

# Find tactical path (flanking, positioning)
func _find_tactical_path_to_target() -> Vector2:
	# Simplified - in full implementation would use strategic pathfinding
	return _get_direct_path_to_target()

# Get stealth approach path
func _get_stealth_approach() -> Vector2:
	# Move along terrain edges, avoid open areas
	# Simplified for now
	return _get_direct_path_to_target()

# Find sniper position
func _find_sniper_position() -> Vector2:
	# Find high ground or cover with line of sight
	# Simplified - just return current position or slightly adjusted
	return Vector2(x, y)

# Find cover
func _find_cover() -> Vector2:
	# Find nearest cover object
	return Vector2.ZERO  # Placeholder

# Check if exposed to fire
func _is_exposed_to_fire() -> bool:
	# Check if in open area without cover
	return false  # Simplified - would check surroundings

# Find path to target (simplified)
func _find_path_to_target(pos: Vector2) -> Vector2:
	return _get_direct_path_to_target()

# Find nearest enemy
func _find_nearest_enemy() -> Unit:
	var nearest: Unit = null
	var min_distance: float = float("inf")

	# Would iterate all units and find nearest enemy
	# Simplified - returns null
	return null

# Execute current order
func _execute_order(delta: float) -> void:
	if current_order == "move":
		if target:
			_move_to_target(delta)
		elif target_position != Vector2.ZERO:
			_move_to_position(target_position, delta)

	elif current_order == "attack":
		if target and is_alive(target):
			_attack_target(delta)
		elif target_position != Vector2.ZERO:
			_move_to_position(target_position, delta)

# Move to target unit
func _move_to_target(delta: float) -> void:
	var direction: Vector2 = Vector2(target.x - x, target.y - y).normalized()

	if not _move(direction, delta):
		# Reached target
		current_order = ""
		unit_reached_target.emit()

# Move to position
func _move_to_position(pos: Vector2, delta: float) -> void:
	var direction: Vector2 = (pos - Vector2(x, y)).normalized()

	if not _move(direction, delta):
		current_order = ""

# Move unit
func _move(direction: Vector2, delta: float) -> bool:
	var move_dist: float = speed * delta

	# Update position
	x += direction.x * move_dist
	y += direction.y * move_dist

	is_moving = true

	# Check if reached
	var target_pos: Vector2 = Vector2(target.x, target.y) if target else pos
	var dist: float = get_position().distance_to(target_pos)

	return dist > 1.0

# Attack target
func _attack_target(delta: float) -> void:
	if not is_alive(target):
		target = null
		current_order = ""
		return

	# Check range
	if get_position().distance_to(Vector2(target.x, target.y)) > range:
		current_order = "move"
		return

	# Attack!
	is_attacking = true
	_apply_weapon_damage()
	is_attacking = false

# Apply weapon damage
func _apply_weapon_damage() -> void:
	match weapon:
		"none":
			pass  # Body damage only

		"machinegun":
			damage = get_weapon_damage_modifier("machinegun") if get_weapon_damage_modifier("machinegun") else damage

		"sniper":
			damage = get_weapon_damage_modifier("sniper") if get_weapon_damage_modifier("sniper") else damage * 2.5

		"flamethrower":
			damage = get_weapon_damage_modifier("flamethrower") if get_weapon_damage_modifier("flamethrower") else 8

		"laser":
			damage = get_weapon_damage_modifier("laser") if get_weapon_damage_modifier("laser") else damage

		"cannon":
			damage = get_weapon_damage_modifier("cannon") if get_weapon_damage_modifier("cannon") else damage * 3.5

		"mortar":
			target = null  # Mortars don't target units directly
			current_order = ""
			return

		"gatling", "turret", "missile":
			pass  # Stationary weapons - would have different logic

# Get weapon damage modifier based on weapon type
func get_weapon_damage_modifier(weapon_type: String) -> float:
	return WEAPON_DAMAGE_MULTIPLIERS.get(weapon_type, 1.0) * damage

# Take damage
func take_damage(amount: int, source: Unit = null) -> bool:
	health -= amount

	if health <= 0:
		die()
		return true

	unit_taken_damage.emit(amount)
	return false

# Die
func die() -> void:
	is_dead = true

	if is_vehicle and has_driver:
		# Eject driver - vehicle becomes neutral
		has_driver = false
		driver_unit = null

	unit_died.emit()
	print("[Unit] Unit died:", type, "Team:", team)

func is_alive() -> bool:
	return not is_dead

# Set order
func set_order(order: String, target: Unit = null, position: Vector2 = Vector2.ZERO) -> void:
	orders.append(order)
	if orders.size() > 5:
		orders.pop_front()

	if order == orders[0]:
		current_order = order
		self.target = target if target else null
		target_position = position
		unit_order_received.emit(order)

# Get statistics
func get_stats() -> Dictionary:
	return {
		"type": type,
		"health": health,
		"armor": armor,
		"speed": speed,
		"damage": damage,
		"range": range,
		"intelligence": intelligence,
		"team": team,
		"x": x,
		"y": y
	}

func get_position() -> Vector2:
	return Vector2(x, y)

func set_position(pos: Vector2) -> void:
	x = pos.x
	y = pos.y

# Get unit type for display
func get_display_type() -> String:
	return type.capitalize()

# Get team color
func get_color() -> Color:
	return Color.html_to_rgb(color)

# HTML to RGB conversion
func html_to_rgb(hex: String) -> String:
	# Remove # if present
	hex = hex.lstrip("#")
	return "rgb(%s, %s, %s)" % [hex[0:2], hex[2:4], hex[4:6]]
