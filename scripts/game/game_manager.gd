extends Node2D

# Main game manager node
# Orchestrates all game systems

@onready var tile_map_layer: TileMapLayer = $TileMap
@onready var navigation_region: NavigationRegion2D = $NavigationRegion2D
@onready var selection_manager: Node = $SelectionManager
@onready var level_loader: Node = $LevelLoader

var units_container: Node2D
var buildings_container: Node2D


func _ready() -> void:
	units_container = Node2D.new()
	units_container.name = "Units"
	add_child(units_container)
	
	buildings_container = Node2D.new()
	buildings_container.name = "Buildings"
	add_child(buildings_container)
	
	# Initialize navigation
	var rect = Rect2(0, 0, 2048, 2048)
	navigation_region.navigation_polygon.add_polygon([
		rect.position,
		rect.end,
		Vector2(rect.position.x, rect.end.y),
		Vector2(rect.end.x, rect.position.y)
	])
	
	await get_tree().process_frame
	
	# Load first campaign level
	level_loader.load_level(0)
	
	# Connect victory signal
	GameState.game_won.connect(_on_game_won)
	
	get_tree().paused = false


func _input(event: InputEvent) -> void:
	# Right click orders
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		var world_pos = get_mouse_world_position()
		selection_manager.issue_move_order(world_pos)
		
		# Play "move" voice bark
		play_voice_bark("moving")


func get_mouse_world_position() -> Vector2:
	return get_viewport().get_canvas_transform().affine_inverse() * get_viewport().get_mouse_position()


func _on_game_won(_winner: int) -> void:
	# Advance to next level after victory
	await get_tree().create_timer(2.0).timeout  # Brief pause
	level_loader.advance_level()


func play_voice_bark(bark_type: String) -> void:
	var barks = {
		"moving": ["Yes sir!", "On my way!", "Roger that!"],
		"attack": ["Fire!", "Engaging enemy!", "Take them down!"],
		"capture": ["Territory captured!", "Sector ours!"],
		"death": ["Aaaaah!", "Noooo!"]
	}
	
	if barks.has(bark_type):
		var line = barks[bark_type][randi() % barks[bark_type].size()]
		# Voice bark played - would play audio here
		pass

