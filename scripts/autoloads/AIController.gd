extends Node

# AIController - Central AI controller for all enemy units
signal ai_decision_made(unit: Unit, action: String)

# AI difficulty settings
var difficulty: String = "normal"  # "easy", "normal", "hard"
var ai_enabled: bool = true
var decision_interval: float = 1.0

# AI difficulty presets
var difficulty_settings: Dictionary = {
	"easy": {aggression: 0.7, reaction_time: 2.0, pathfinding: 0.6},
	"normal": {aggression: 1.0, reaction_time: 1.0, pathfinding: 0.8},
	"hard": {aggression: 1.0, reaction_time: 0.5, pathfinding: 1.0}
}

# Current loaded settings
var current_settings: Dictionary = {}

# Timer for decision intervals
var last_decision_time: float = 0.0
var decision_timer: float = 0.0

func _ready() -> void:
	print("[AIController] AI Controller initialized")
	_load_settings()
	_scan_units()

func _process(delta: float) -> void:
	if not ai_enabled:
		return

	# Fixed: Use delta-based timing instead of deprecated Time.get_ticks_fsys()
	decision_timer += delta
	if decision_timer >= decision_interval:
		decision_timer = 0.0
		_make_ai_decisions(delta)

func _load_settings() -> void:
	current_settings = difficulty_settings.get(difficulty, difficulty_settings["normal"])
	print("[AIController] Loaded settings for difficulty:", difficulty)

func _scan_units() -> void:
	# Find all enemy units
	var units = get_tree().get_nodes_in_group("units")
	for unit in units:
		if unit is Unit and unit.team != get_player_team():
			_setup_unit_ai(unit)

func get_player_team() -> int:
	# Returns the player's team (default: red)
	return 1

func _setup_unit_ai(unit: Unit) -> void:
	if not unit.has_method("ai_controller"):
		var ai_unit = AIUnit.new()
		unit.add_child(ai_unit)
		ai_unit.parent_unit = unit
		ai_unit.last_decision_time = Time.get_ticks_msec() / 1000.0

# AIUnit class for per-unit AI control
class AIUnit:
	var parent_unit: Unit = null
	var last_decision_time: float = 0.0
	var current_action: String = "idle"
	var ai_controller_node: Node = null

	func _ready() -> void:
		parent_unit = get_parent() as Unit
		# Reference to AI controller node
		ai_controller_node = get_node("/root/AIController")

	func _process(delta: float) -> void:
		if not ai_controller_node or not ai_controller_node.ai_enabled:
			return

		# Fixed: Use delta-based timing
		var current_time = Time.get_ticks_msec() / 1000.0
		if current_time - last_decision_time >= ai_controller_node.decision_interval:
			last_decision_time = current_time
			_make_decision()

	func _make_decision() -> void:
		var actions: Array[String] = ["idle", "move", "attack", "retreat", "defend"]
		var action: String = _choose_action()
		current_action = action
		ai_controller_node.ai_decision_made.emit(parent_unit, action)

	func _choose_action() -> String:
		# Get difficulty settings from controller
		var ai_settings = ai_controller_node.current_settings
		var aggression: float = ai_settings.get("aggression", 1.0)
		var roll: float = randf()

		# Choose action based on AI settings and unit type
		match parent_unit.type:
			"sniper":
				if roll < 0.3:
					return "hide"
				elif roll < 0.7:
					return "patrol"
				else:
					return "ambush"

			"psycho":
				if roll < 0.5:
					return "attack"
				else:
					return "move"

			"tough":
				if roll < 0.6:
					return "defend"
				else:
					return "move"

			_ :
				# Default behavior based on difficulty
				var difficulty_roll = roll * aggression
				if difficulty_roll < 0.4:
					return "attack"
				elif difficulty_roll < 0.7:
					return "move"
				else:
					return "idle"

		return "idle"

func _make_ai_decisions(delta: float) -> void:
	# Iterate through all enemy units and make decisions
	var units = get_tree().get_nodes_in_group("units")
	for unit in units:
		if unit is Unit and unit.team != get_player_team() and not unit.is_dead:
			if unit.has_method("ai_controller"):
				unit.call("ai_controller")

# Get AI difficulty
func get_difficulty() -> String:
	return difficulty

# Set AI difficulty
func set_difficulty(new_difficulty: String) -> void:
	difficulty = new_difficulty
	_load_settings()
	print("[AIController] Difficulty changed to:", difficulty)

# Toggle AI on/off
func toggle_ai(enabled: bool) -> void:
	ai_enabled = enabled
	print("[AIController] AI toggled:", enabled)

# Get current AI settings
func get_current_settings() -> Dictionary:
	return current_settings

# Enable AI behavior for a specific unit
func enable_ai_for_unit(unit: Unit) -> void:
	if unit.has_method("ai_controller"):
		unit.call("ai_controller")
		print("[AIController] Enabled AI for unit:", unit.type)

# Disable AI behavior for a specific unit
func disable_ai_for_unit(unit: Unit) -> void:
	if unit.has_method("ai_controller"):
		# Clear orders but keep AI controller
		unit.orders.clear()
		unit.current_order = ""
		print("[AIController] Disabled AI for unit:", unit.type)
