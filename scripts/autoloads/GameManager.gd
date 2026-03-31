extends Node

# GameManager - Central game controller
signal level_complete()
signal game_won()
signal game_lost()
signal game_paused()
signal game_resumed()

var current_level: Dictionary = {}
var level_index: int = 0
var is_paused: bool = false
var is_game_over: bool = false
var game_mode: String = "singleplayer"  # "singleplayer" or "multiplayer"

# Player teams
const TEAM_RED = 1
const TEAM_BLUE = 2

# Win condition flags
var fort_destroyed: bool = false
var enemy_eliminated: bool = false

# Game state
var time_remaining: float = 0
var time_limit: float = 0

# Production multiplier
var owned_sectors_count: int = 0

# Load level data
var level_data: Dictionary = {}

func _ready() -> void:
	print("[GameManager] Game manager initialized")
	_load_level(0)

# Load a level from data
func _load_level(index: int) -> void:
	level_index = index
	level_complete = false
	is_game_over = false

	# Try to load level data with error handling
	var levels: Array = []
	var error = 0
	var error_string = ""
	var loaded = ResourceLoader.load_threaded_request("res://data/level_data.json", ERR_NONE, &error, &error_string)
	if loaded and error == ERR_NONE:
		levels = ResourceLoader.load_threaded_get("res://data/level_data.json")
	elif not loaded or error != ERR_NONE:
		# Fallback to hardcoded levels if file not found
		levels = _get_default_levels()

	if index >= levels.size():
		print("[GameManager] No level at index", index)
		return

	current_level = levels[index]

	print("[GameManager] Loading level", index + 1, ":", current_level["level_name"])

	# Reset game state
	fort_destroyed = false
	enemy_eliminated = false
	time_remaining = 0
	owned_sectors_count = 0

	# Notify UI and scene tree
	_notify_level_start()

	# Store level data for later use
	level_data = current_level.duplicate()

# Get default levels if JSON not found
func _get_default_levels() -> Array:
	return [
		{
			"level_name": "Desert Outpost",
			"planet": "desert",
			"map_size": Vector2i(100, 80),
			"red_fort": Vector2(50, 50),
			"blue_fort": Vector2(150, 150),
			"starting_units": {},
			"flags": []
		}
	]

# Notify UI of level start
func _notify_level_start() -> void:
	pass  # Connect to UI signals

# Get current level data
func get_current_level() -> Dictionary:
	return current_level

# Get planet name
func get_planet() -> String:
	return current_level.get("planet", "unknown")

# Get level name
func get_level_name() -> String:
	return current_level.get("level_name", "Unknown Level")

# Get map size
func get_map_size() -> Vector2i:
	return Vector2i(
		current_level.get("map_size", Vector2i(100, 80))
	)

# Get fort positions
func get_red_fort_position() -> Vector2:
	return current_level.get("red_fort", Vector2(50, 50))

func get_blue_fort_position() -> Vector2:
	return current_level.get("blue_fort", Vector2(150, 150))

# Get starting units
func get_starting_units() -> Dictionary:
	return current_level.get("starting_units", {})

# Get flags
func get_flags() -> Array:
	return current_level.get("flags", [])

# Merged win condition check - single function replacing two
func _check_victory() -> void:
	# Victory if either fort destroyed OR enemy eliminated
	if fort_destroyed or enemy_eliminated:
		game_won.emit()
		is_game_over = true
		print("[GameManager] VICTORY!")

# Update win conditions
func update_win_conditions(destroyed_team: int) -> void:
	if destroyed_team == TEAM_BLUE:
		fort_destroyed = true
		enemy_eliminated = true
	else:
		# Red team eliminated
		fort_destroyed = true
		enemy_eliminated = true
	_check_victory()

# Update production multiplier
func update_production_multiplier(count: int) -> void:
	owned_sectors_count = count

# Toggle pause
func pause_game() -> void:
	is_paused = not is_paused
	if is_paused:
		game_paused.emit()
	else:
		game_resumed.emit()

func is_game_running() -> bool:
	return not is_game_over and not is_paused

# Removed placeholder functions - will be implemented when needed
# func get_team_count(team: int) -> int:
# 	return 0

# func get_flag_owner(flag_id: String) -> int:
# 	return 0

# Get sector multiplier for a team
func get_sector_multiplier(team: int) -> float:
	# More sectors = faster production
	return 1.0 + (owned_sectors_count * 0.2)

# Calculate build time based on sector multiplier
func calculate_build_time(base_time: float) -> float:
	return base_time / get_sector_multiplier(TEAM_RED)

# Get player team (can be overridden)
func get_player_team() -> int:
	return TEAM_RED

# Add owned sector count
func add_owned_sector() -> void:
	owned_sectors_count += 1
	update_production_multiplier(owned_sectors_count)

# Remove owned sector count
func remove_owned_sector() -> void:
	if owned_sectors_count > 0:
		owned_sectors_count -= 1
		update_production_multiplier(owned_sectors_count)

# Set level complete (for UI updates)
func set_level_complete(completed: bool) -> void:
	level_complete = completed
