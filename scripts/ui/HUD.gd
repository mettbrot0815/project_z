extends CanvasLayer

# HUD - Heads Up Display
signal unit_selected(unit: Unit)
signal game_status_changed(status: String)

# UI Elements
@onready var level_label: Label = $LevelLabel
@onready var planet_label: Label = $PlanetLabel
@onready var unit_panel: Control = $UnitPanel
@onready var minimap: Control = $Minimap
@onready var pause_button: Button = $PauseButton

# Game state
var current_level: int = 0
var current_planet: String = ""
var selected_unit: Unit = null
var units_by_type: Dictionary = {}

# References to autoloads - use get_tree() to find them safely
var game_manager: Node = null
var input_handler: Node = null

func _ready() -> void:
	print("[HUD] HUD initialized")
	_connect_signals()
	_initialize_ui()

func _connect_signals() -> void:
	# Connect to game manager signals using get_tree()
	if get_node("/root/GameManager"):
		game_manager = get_node("/root/GameManager")
		if game_manager:
			game_manager.game_paused.connect(_on_game_paused)
			game_manager.game_resumed.connect(_on_game_resumed)

	# Connect to input handler using get_tree()
	if get_node("/root/InputHandler"):
		input_handler = get_node("/root/InputHandler")
		if input_handler:
			input_handler.unit_selected.connect(_on_unit_selected)
			input_handler.unit_deselected.connect(_on_unit_deselected)
			input_handler.unit_cycle_ordered.connect(_on_unit_cycle)

func _initialize_ui() -> void:
	level_label.text = "Level 1"
	planet_label.text = ""
	units_by_type = {}

# Game state updates
func _on_game_paused() -> void:
	pause_button.visible = true
	pause_button.pressed = true
	game_status_changed.emit("paused")

func _on_game_resumed() -> void:
	pause_button.visible = false
	game_status_changed.emit("resumed")

# Unit selection
func _on_unit_selected(unit: Unit) -> void:
	selected_unit = unit
	_update_unit_panel(unit)
	unit_selected.emit(unit)

func _on_unit_deselected() -> void:
	selected_unit = null
	_clear_unit_panel()
	unit_selected.emit(null)

# Unit cycling (F1-F6)
func _on_unit_cycle(type_str: String) -> void:
	var unit_type = type_str.capitalize()
	# Use safe reference to input_handler
	if input_handler:
		var units = input_handler.get_units_by_type(type_str)

		if units.size() > 0:
			# Select first available unit of this type
			var first_unit = units[0]
			if not input_handler.is_unit_selected(first_unit):
				input_handler.select_unit(first_unit)
				_on_unit_selected(first_unit)

# Update unit panel
func _update_unit_panel(unit: Unit) -> void:
	if not unit:
		return

	level_label.text = "Selected: " + unit.get_display_type()
	# Fixed: Use unit.health instead of non-existent unit.max_health
	planet_label.text = "Health: " + str(unit.health)

	# Show unit stats
	var stats = unit.get_stats()
	var panel_text = ""
	panel_text += "Type: " + stats["type"] + "\n"
	panel_text += "Team: " + _get_team_name(stats["team"]) + "\n"
	panel_text += "Health: " + str(stats["health"]) + "\n"
	panel_text += "Armor: " + str(stats["armor"]) + "\n"
	panel_text += "Speed: " + str(round(stats["speed"])) + "\n"
	panel_text += "Damage: " + str(stats["damage"]) + "\n"
	panel_text += "Range: " + str(int(stats["range"])) + "\n"
	panel_text += "Intelligence: " + str(stats["intelligence"]) + "\n"

	unit_panel.text = panel_text

# Clear unit panel
func _clear_unit_panel() -> void:
	unit_panel.text = ""
	planet_label.text = ""

# Helper functions
func _get_team_name(team: int) -> String:
	match team:
		1:
			return "RED"
		2:
			return "BLUE"
		_:
			return "NEUTRAL"

# Level updates
func update_level_info(level_data: Dictionary) -> void:
	current_level = level_data.get("level_index", 1)
	current_planet = level_data.get("planet", "unknown")
	level_label.text = "Level " + str(current_level) + ": " + level_data.get("level_name", "Unknown")
	planet_label.text = "Planet: " + current_planet.capitalize()

# Status messages
func show_status_message(status: String) -> void:
	game_status_changed.emit(status)

# Victory/Defeat screens
func show_victory_screen() -> void:
	game_status_changed.emit("victory")

func show_defeat_screen() -> void:
	game_status_changed.emit("defeat")

# Next level
func next_level() -> void:
	game_status_changed.emit("next_level")

# Pause menu
func toggle_pause() -> void:
	if game_manager:
		game_manager.pause_game()
