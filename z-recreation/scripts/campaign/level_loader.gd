extends Node

# Loads campaign levels and initializes map state

var current_level: int = 0
var levels_data: Dictionary = {}


func _ready() -> void:
	var file = FileAccess.open("res://data/levels.json", FileAccess.READ)
	if file:
		levels_data = JSON.parse_string(file.get_as_text())
		file.close()


func load_level(level_id: int) -> void:
	current_level = level_id
	var level_data = levels_data["levels"][level_id]
	
	# Load terrain
	var tile_map = $"/root/Game/TileMap"
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
		factory_node.owner = factory["owner"]
		get_parent().add_child(factory_node)
	
	# Place starting units
	for unit in level_data["units"]:
		var unit_scene = load("res://scenes/units/%s.tscn" % unit["type"])
		var unit_node = unit_scene.instantiate()
		unit_node.global_position = Vector2(unit["position"][0], unit["position"][1])
		unit_node.owner = unit["owner"]
		get_parent().add_child(unit_node)
