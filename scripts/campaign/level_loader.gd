extends Node

# Loads campaign levels and initializes map state

var current_level: int = 0
var levels_data: Dictionary = {}
const MAX_LEVEL: int = 20


func _ready() -> void:
	var file = FileAccess.open("res://data/levels.json", FileAccess.READ)
	if file:
		levels_data = JSON.parse_string(file.get_as_text())
		file.close()


func load_level(level_id: int) -> void:
	current_level = level_id
	var level_data = levels_data["levels"][level_id]
	
	show_cutscene(level_id)
	
	# Load terrain
	var tile_map = $"/root/Main/TileMap"
	tile_map.clear()
	
	# Place territories and flags
	for territory in level_data["territories"]:
		var flag_scene = load("res://scenes/buildings/flag.tscn")
		var flag = flag_scene.instantiate()
		flag.global_position = Vector2(territory["position"][0], territory["position"][1])
		flag.territory_id = territory["id"]
		get_parent().add_child(flag)
		TerritoryManager.register_territory(territory["id"], flag)
	
	# Place factories
	for factory in level_data["factories"]:
		var factory_scene = load("res://scenes/buildings/factory_%s.tscn" % factory["type"])
		var factory_node = factory_scene.instantiate()
		factory_node.global_position = Vector2(factory["position"][0], factory["position"][1])
		factory_node.territory_id = factory["territory_id"]
		factory_node.team_owner = factory["owner"]  # Fixed: use team_owner not owner
		
		# AI production cheat in later levels
		if factory["owner"] == 2 and level_id > 10:
			factory_node.base_production_time *= 0.8  # 20% faster for CPU
		
		get_parent().add_child(factory_node)
	
	# Place starting units
	for unit in level_data["units"]:
		var unit_scene = load("res://scenes/units/%s.tscn" % unit["type"])
		var unit_node = unit_scene.instantiate()
		unit_node.global_position = Vector2(unit["position"][0], unit["position"][1])
		# Set both team_id (int) and team (enum) to match
		unit_node.team_id = unit["owner"]
		unit_node.team = unit["owner"]
		get_parent().add_child(unit_node)
	
	# Set planet theme
	set_planet_theme(level_data["planet"])


func set_planet_theme(planet: String) -> void:
	# Skip theme setting for now - canvas_modulate access is different in Godot 4
	# This can be implemented later with proper viewport reference
	pass


func show_cutscene(level_id: int) -> void:
	var cutscenes = {
		1: "Commander Zod: 'Welcome to the battlefield, soldier! Remember, no resource gathering - just pure tactical mayhem!'",
		5: "Brad: 'Hey Allan, pass the rocket fuel!' Allan: 'Not now Brad, we're in combat!' Brad: 'But it's delicious!'",
		10: "Commander Zod: 'Impressive victory! But beware, the AI is getting smarter... or is it?'",
		15: "Brad: 'Allan, this rocket fuel is making me see double!' Allan: 'That's because you're drinking it wrong!'",
		20: "Commander Zod: 'Congratulations! You've mastered the art of Z. Now go celebrate with some rocket fuel!' Brad & Allan: 'Yay!'"
	}
	
	if cutscenes.has(level_id):
		# Cutscene dialogue would be displayed here
		pass


func advance_level() -> void:
	if current_level < MAX_LEVEL:
		load_level(current_level + 1)
	else:
		print("Campaign Complete!")
