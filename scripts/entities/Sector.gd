extends Node2D

class_name Sector

# Sector/Flag configuration
@export var id: String = ""
@export var x: float = 0
@export var y: float = 0
@export var owner: int = 0  # 0 = neutral, 1 = red, 2 = blue
@export var is_neutral: bool = true

# Structures in this sector
var structures: Array[String] = []  # Types like "gatling", "howitzer"
var factories: Array[Factory] = []
var turrets: Array[Unit] = []

# Production bonus
var production_bonus: float = 1.0
var is_factory: bool = false

func _ready() -> void:
	print("[Sector] Sector initialized:", id)

# Add a structure type
func add_structure(struct_type: String) -> void:
	if not structures.has(struct_type):
		structures.append(struct_type)
		# Fixed: Only set is_factory if structure type indicates a factory
		is_factory = struct_type in ["gatling", "howitzer", "missile", "turret"]
	print("[Sector] Added structure:", struct_type)

# Remove a structure
func remove_structure(struct_type: String) -> void:
	structures.erase(struct_type)
	# Fixed: Only set is_factory = false if no factories remain
	is_factory = structures.size() == 0 or not any(struct in ["gatling", "howitzer", "missile", "turret"] for struct in structures)
	print("[Sector] Removed structure:", struct_type)

# Check if sector has structures
func has_structures() -> bool:
	return structures.size() > 0

# Get structure types
func get_structures() -> Array:
	return structures.duplicate()

# Get factories owned by team
func get_team_factories(team: int) -> Array:
	var team_factories: Array[Factory] = []
	for factory in factories:
		if factory.team == team:
			team_factories.append(factory)
	return team_factories

# Check if sector is owned
func is_owned() -> bool:
	return owner != 0

# Check if sector is neutral
func is_empty() -> bool:
	return is_neutral and structures.size() == 0

# Get owner team name
func get_owner_team_name() -> String:
	match owner:
		1:
			return "RED"
		2:
			return "BLUE"
		_:
			return "NEUTRAL"

# Get ownership color for display
func get_owner_color() -> Color:
	match owner:
		1:
			return Color(1, 0, 0)  # Red
		2:
			return Color(0, 0, 1)  # Blue
		_:
			return Color(1, 1, 1)  # White/Neutral

# Get sector bonus
func get_production_bonus() -> float:
	return production_bonus

# Set sector bonus (called when ownership changes)
func set_production_bonus(bonus: float) -> void:
	production_bonus = bonus
	print("[Sector] Production bonus set to:", bonus)

# Capture sector
func capture(captor_team: int) -> bool:
	if owner == captor_team:
		return false  # Already owned

	owner = captor_team
	is_neutral = false

	# Fixed: Calculate bonus based on sector count, not team number
	# This should be called from SectorManager with the correct multiplier
	production_bonus = 1.0  # Base value - actual multiplier set by SectorManager

	print("[Sector] Captured by team", captor_team)
	return true

# Release sector (neutralize)
func neutralize() -> bool:
	if owner == 0:
		return false  # Already neutral

	owner = 0
	is_neutral = true
	production_bonus = 1.0

	print("[Sector] Neutralized")
	return true

# Get position
func get_position() -> Vector2:
	return Vector2(x, y)

# Set position
func set_position(pos: Vector2) -> void:
	x = pos.x
	y = pos.y

# Check if unit is within capture range
func can_capture(unit: Unit) -> bool:
	return Vector2(unit.x, unit.y).distance_to(get_position()) < 10

# Get all units in sector
func get_units() -> Array:
	var units: Array[Unit] = turrets.duplicate()
	for factory in factories:
		# Factory might have spawned units
		pass
	return units

# Get sector info for display
func get_info() -> Dictionary:
	return {
		"id": id,
		"owner": get_owner_team_name(),
		"is_neutral": is_neutral,
		"structures": structures,
		"position": get_position()
	}

# Reset sector (for level restart)
func reset() -> void:
	owner = 0
	is_neutral = true
	structures.clear()
	factories.clear()
	turrets.clear()
	production_bonus = 1.0
	print("[Sector] Sector reset:", id)
