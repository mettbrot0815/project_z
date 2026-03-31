extends Node2D

# GameScene - Main game scene that orchestrates all components
signal game_started()
signal level_loaded(level_index: int)
signal game_ended(result: String)

# Game components
@onready var game_manager: Node = $GameManager
@onready var sector_manager: Node = $SectorManager
@onready var input_handler: Node = $InputHandler
@onready var unit_ai: Node = $UnitAI
@onready var ai_controller: Node = $AIController
@onready var hud: Control = $GameUI/HUD

# Current level
var current_level_index: int = 0
var is_loading: bool = false
var game_running: bool = false

func _ready() -> void:
	print("[GameScene] Main game scene initialized")
	_connect_signals()
	_setup_game()

func _connect_signals() -> void:
	# Connect to GameManager
	if game_manager:
		game_manager.level_complete.connect(_on_level_complete)
		game_manager.game_won.connect(_on_victory)
		game_manager.game_lost.connect(_on_defeat)
		game_manager.game_paused.connect(_on_pause)
		game_manager.game_resumed.connect(_on_resume)
	
	# Connect to SectorManager
	if sector_manager:
		sector_manager.sector_captured.connect(_on_sector_captured)

func _setup_game() -> void:
	# Initialize game components
	game_manager._ready()
	sector_manager._ready()
	input_handler._ready()
	unit_ai._ready()
	ai_controller._ready()
	
	# Start first level
	load_level(0)
	print("[GameScene] Game scene ready, starting level 1")

# Level loading
func load_level(level_index: int) -> void:
	is_loading = true
	current_level_index = level_index
	
	# Load level data
	var levels = load("res://data/level_data.json").json as Array
	if level_index >= levels.size():
		print("[GameScene] No level at index", level_index)
		game_ended.emit("invalid_level")
		return
	
	var level_data = levels[level_index]
	
	# Clear current scene
	_clear_game_area()
	
	# Setup new level
	_setup_level(level_data)
	
	level_loaded.emit(level_index)
	is_loading = false
	
	print("[GameScene] Level loaded:", level_index + 1)

func _clear_game_area() -> void:
	# Remove all units, factories, sectors
	var units = get_tree().get_nodes_in_group("units")
	for unit in units:
		unit.queue_free()
	
	# Remove factories
	var factories = get_tree().get_nodes_in_group("factories")
	for factory in factories:
		factory.queue_free()
	
	# Remove sectors
	var sectors = get_tree().get_nodes_in_group("sectors")
	for sector in sectors:
		sector.queue_free()
	
	print("[GameScene] Game area cleared")

func _setup_level(level_data: Dictionary) -> void:
	# Create map
	_create_map(level_data)
	
	# Create sectors
	_create_sectors(level_data.get("flags", []))
	
	# Create starting units
	_create_starting_units(level_data.get("starting_units", {}))
	
	# Setup forts
	_create_forts(level_data.get("red_fort", {}), level_data.get("blue_fort", {}))
	
	# Initialize sector manager
	if sector_manager:
		sector_manager.initialize_sectors(level_data.get("flags", []))

func _create_map(level_data: Dictionary) -> void:
	# Create TileMap for terrain
	var map_size = Vector2i(level_data.get("map_size", Vector2i(100, 80)))
	
	# Would create actual terrain tiles
	# For now, create empty space
	print("[GameScene] Map size:", map_size)

func _create_sectors(flags: Array) -> void:
	var sectors_node = Node.new()
	sectors_node.name = "Sectors"
	add_child(sectors_node)
	
	for flag in flags:
		var sector = Sector.new()
		sector.id = flag["id"]
		sector.x = flag["x"]
		sector.y = flag["y"]
		sector.is_neutral = flag.get("neutral", true)
		
		# Add structures
		var structures = flag.get("structures", [])
		for struct_type in structures:
			sector.add_structure(struct_type)
		
		sectors_node.add_child(sector)
		print("[GameScene] Created sector:", sector.id)

func _create_starting_units(units: Dictionary) -> void:
	var team = units.keys()[0]  # First team is player
	var unit_data = units[team]
	
	for unit_info in unit_data:
		var unit_type = unit_info["type"]
		var unit = _create_unit(unit_type, unit_info["x"], unit_info["y"])
		unit.team = get_team_id(team)
		add_child(unit)
		print("[GameScene] Created unit:", unit_type, "for team", team)

func _create_unit(type: String, x: float, y: float) -> Unit:
	var unit = Unit.new()
	unit.type = type
	
	# Load stats from JSON
	var stats = load("res://data/unit_stats.json").json
	if type in stats:
		var type_stats = stats[type]
		unit.speed = type_stats.get("speed", 1.0)
		unit.armor = type_stats.get("armor", 10)
		unit.health = type_stats.get("health", 100)
		unit.damage = type_stats.get("damage", 10)
		unit.range = type_stats.get("range", 12.0)
		unit.intelligence = type_stats.get("intelligence", 5)
		unit.weapon = type_stats.get("weapon", "none")
		unit.color = type_stats.get("color", "#FFFFFF")
		unit.build_time = type_stats.get("build_time", 5)
	
	unit.x = x
	unit.y = y
	unit.team = 1  # Default to player
	
	return unit

func _create_forts(red_fort: Dictionary, blue_fort: Dictionary) -> void:
	# Create fort structures
	# Would create actual fort buildings
	print("[GameScene] Forts created at", red_fort, blue_fort)

func get_team_id(team_name: String) -> int:
	if team_name == "red":
		return 1
	elif team_name == "blue":
		return 2
	return 1

# Game events
func _on_level_complete() -> void:
	print("[GameScene] Level complete")
	load_level(current_level_index + 1)

func _on_victory() -> void:
	print("[GameScene] Victory!")
	game_ended.emit("victory")
	hud.show_victory_screen()

func _on_defeat() -> void:
	print("[GameScene] Defeat!")
	game_ended.emit("defeat")
	hud.show_defeat_screen()

func _on_pause() -> void:
	print("[GameScene] Game paused")

func _on_resume() -> void:
	print("[GameScene] Game resumed")

# Utility functions
func get_all_units() -> Array:
	return get_tree().get_nodes_in_group("units")

func get_units_by_team(team: int) -> Array:
	var teams = []
	for unit in get_all_units():
		if unit is Unit and unit.team == team:
			teams.append(unit)
	return teams

func get_units_by_type(type_str: String) -> Array:
	var types = []
	for unit in get_all_units():
		if unit is Unit and unit.type == type_str:
			types.append(unit)
	return types

func get_team_count(team: int) -> int:
	return get_units_by_team(team).size()

# Start game
func start_game() -> void:
	game_running = true
	game_started.emit()
	print("[GameScene] Game started")

# End game
func end_game(reason: String) -> void:
	game_running = false
	game_ended.emit(reason)
	print("[GameScene] Game ended:", reason)
