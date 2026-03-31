extends Node

# SectorManager - Manages flags, sectors, factories, and production multipliers
signal sector_captured(flag_id: String, team: int)
signal factory_produced_unit(factory_type: String, team: int, unit_type: String)

# Team constants - single source of truth
const TEAM_RED = 1
const TEAM_BLUE = 2

# Sector tracking
var sectors: Dictionary = {}  # flag_id -> Sector data
var factories: Dictionary = {}  # factory_key -> Factory instance

# Team multipliers - initialized in _ready()
var team_multipliers: Dictionary = {
	TEAM_RED: 1.0,
	TEAM_BLUE: 1.0
}

func _ready() -> void:
	print("[SectorManager] Sector manager initialized")

# Initialize sectors from level data
func initialize_sectors(flags: Array) -> void:
	sectors.clear()
	factories.clear()

	for flag in flags:
		var flag_id: String = flag["id"]
		var sector = Sector.new()
		sector.id = flag_id
		sector.x = flag["x"]
		sector.y = flag["y"]
		sector.is_neutral = flag.get("neutral", true)
		sector.owner = 0  # 0 = neutral

		# Initialize structures
		var structures: Array[String] = flag.get("structures", [])
		for struct_type in structures:
			sector.add_structure(struct_type)

		sectors[flag_id] = sector
		print("[SectorManager] Initialized sector:", flag_id)

# Capture a sector (flag)
func capture_sector(flag_id: String, captor_team: int) -> void:
	if not sectors.has(flag_id):
		print("[SectorManager] Sector not found:", flag_id)
		return

	var sector: Sector = sectors[flag_id]
	if sector.owner == captor_team:
		return  # Already owned

	var old_owner: int = sector.owner

	sector.owner = captor_team
	sector.is_neutral = false

	# Notify capture
	sector_captured.emit(flag_id, captor_team)

	# If it wasn't neutral before, it was captured
	if old_owner == 0:
		print("[SectorManager] Captured sector:", flag_id, "by team", captor_team)

	# Update team multiplier
	_update_team_multiplier(captor_team)

	# Activate factories if present
	if sector.has_structures():
		activate_factories(flag_id, captor_team)

# Release sector (neutralize)
func neutralize_sector(flag_id: String) -> void:
	if not sectors.has(flag_id):
		return

	var sector: Sector = sectors[flag_id]
	if sector.owner != 0:
		var old_owner: int = sector.owner
		sector.owner = 0
		sector.is_neutral = true
		_update_team_multiplier(old_owner)
		print("[SectorManager] Sector neutralized:", flag_id)

# Update team multiplier based on owned sectors
func _update_team_multiplier(team: int) -> void:
	# Count owned sectors efficiently
	var count: int = 0
	for sector_data in sectors.values():
		if sector_data.owner == team:
			count += 1

	team_multipliers[team] = 1.0 + (count * 0.2)
	print("[SectorManager] Team", team, "multiplier:", team_multipliers[team], "(", count, "sectors)")

# Get team's sector count
func get_team_sector_count(team: int) -> int:
	var count: int = 0
	for sector_data in sectors.values():
		if sector_data.owner == team:
			count += 1
	return count

# Get team's current multiplier
func get_team_multiplier(team: int) -> float:
	return team_multipliers.get(team, 1.0)

# Activate factories in a sector
func activate_factories(flag_id: String, team: int) -> void:
	if not sectors.has(flag_id):
		return

	var sector: Sector = sectors[flag_id]
	var structures: Array[String] = sector.get_structures()

	for struct_type in structures:
		var factory = _create_factory(flag_id, struct_type, team)
		# Use factory ID as key instead of non-existent .key property
		factories[factory.get_flag() + "_" + factory.get_factory_type()] = factory
		print("[SectorManager] Activated factory:", factory.get_flag(), ":", struct_type)

# Create a factory
func _create_factory(flag_id: String, type: String, team: int) -> Factory:
	var key: String = flag_id + "_" + type
	var factory = Factory.new()
	factory.flag_id = flag_id
	factory.type = type
	factory.team = team
	factory.x = sectors[flag_id].x
	factory.y = sectors[flag_id].y

	return factory

# Get factory by key
func get_factory(key: String) -> Factory:
	return factories.get(key)

# Get all factories owned by a team
func get_team_factories(team: int) -> Array:
	var factories_list: Array[Factory] = []
	for factory in factories.values():
		if factory.team == team:
			factories_list.append(factory)
	return factories_list

# Check if a flag is neutral
func is_flag_neutral(flag_id: String) -> bool:
	if not sectors.has(flag_id):
		return false
	return sectors[flag_id].is_neutral

# Check if a flag is owned by team
func is_flag_owned(flag_id: String, team: int) -> bool:
	if not sectors.has(flag_id):
		return false
	return sectors[flag_id].owner == team

# Get sector ownership
func get_sector_owner(flag_id: String) -> int:
	if not sectors.has(flag_id):
		return 0
	return sectors[flag_id].owner

# Get all neutral flags
func get_neutral_flags() -> Array:
	var neutral: Array[String] = []
	for flag_id, sector in sectors.items():
		if sector.is_neutral:
			neutral.append(flag_id)
	return neutral

# Get all owned flags for a team
func get_owned_flags(team: int) -> Array:
	var owned: Array[String] = []
	for flag_id, sector in sectors.items():
		if sector.owner == team:
			owned.append(flag_id)
	return owned

# Get total sectors for a team
func get_total_sectors(team: int) -> int:
	return get_team_sector_count(team)

# Reset all sectors (for level transition)
func reset_sectors() -> void:
	sectors.clear()
	factories.clear()
	team_multipliers[TEAM_RED] = 1.0
	team_multipliers[TEAM_BLUE] = 1.0
	print("[SectorManager] All sectors reset")

func get_all_sectors() -> Dictionary:
	return sectors.duplicate()
