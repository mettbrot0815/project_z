extends Node2D

@export var team_owner: int = 0  # 0=NEUTRAL, 1=RED, 2=BLUE

# Factory production system - exact original Z behavior
# Critical: Timer CONTINUES when factory is captured mid-build (no reset)

@export var territory_id: int
@export var base_production_time: float = 10.0
@export var factory_type: String = "robot"

signal production_started(unit_type: String)
signal production_completed(unit: Node2D)

var current_build: String = ""
var build_progress: float = 0.0
var is_producing: bool = false
var production_queue: Array[String] = []

var _sprite: Sprite2D


func _ready() -> void:
	TerritoryManager.production_multiplier_updated.connect(_on_multiplier_updated)
	
	_sprite = $Sprite2D
	_update_sprite()


func _update_sprite() -> void:
	if not _sprite:
		return
	
	var sprite_path = _get_sprite_path()
	if sprite_path and ResourceLoader.exists(sprite_path):
		_sprite.texture = load(sprite_path)
	else:
		# Create placeholder
		_sprite.texture = _create_placeholder()


func _get_sprite_path() -> String:
	match factory_type:
		"robot":
			return "res://assets/sprites/buildings/robot/robot_0.png"
		"vehicle":
			return "res://assets/sprites/buildings/vehicle/tank_0.png"
	return ""


func _create_placeholder() -> ImageTexture:
	var image = Image.create(64, 64, false, Image.FORMAT_RGBA8)
	image.fill(Color(0.5, 0.5, 0.5))
	return ImageTexture.create_from_image(image)


func _physics_process(delta: float) -> void:
	if is_producing and team_owner != 0:  # Not NEUTRAL
		var speed = TerritoryManager.get_production_speed_for_owner(team_owner)
		build_progress += delta * speed
		
		if build_progress >= base_production_time:
			complete_production()


func start_production(unit_type: String) -> void:
	if is_producing:
		production_queue.append(unit_type)
		return
	
	current_build = unit_type
	build_progress = 0.0
	is_producing = true
	production_started.emit(unit_type)


func complete_production() -> void:
	is_producing = false
	
	# Spawn unit with error handling
	var scene_path = "res://scenes/units/%s.tscn" % current_build
	var unit_scene = load(scene_path)
	if unit_scene == null:
		push_error("Factory: Failed to load unit scene: " + scene_path)
		current_build = ""
		build_progress = 0.0
		# Process next in queue
		if production_queue.size() > 0:
			start_production(production_queue.pop_front())
		return
	
	var unit = unit_scene.instantiate()
	if unit == null:
		push_error("Factory: Failed to instantiate unit from: " + scene_path)
		current_build = ""
		build_progress = 0.0
		if production_queue.size() > 0:
			start_production(production_queue.pop_front())
		return
	
	# Set team_id (int) and team (int) to match the pattern used elsewhere
	unit.team_id = team_owner
	unit.team = team_owner  # Direct assignment as int (0=NEUTRAL, 1=RED, 2=BLUE)
	unit.global_position = global_position + Vector2(randf_range(-32, 32), 0)
	# Use units_container from GameManager if available, otherwise fallback
	var game_manager = get_tree().get_node_or_null("GameManager")
	if game_manager:
		game_manager.units_container.add_child(unit)
	else:
		# Fallback - add to current scene
		if get_parent() and get_parent().has_node("Units"):
			get_parent().get_node("Units").add_child(unit)
		else:
			add_child(unit)
	production_completed.emit(unit)
	
	current_build = ""
	build_progress = 0.0
	
	# Process next in queue
	if production_queue.size() > 0:
		start_production(production_queue.pop_front())


func get_build_percentage() -> float:
	if not is_producing:
		return 0.0
	return clamp(build_progress / base_production_time, 0.0, 1.0)


func _on_multiplier_updated(_multiplier: float) -> void:
	# Speed scales dynamically while building is in progress
	# This is the original Z behavior - timer speeds up when more territories are captured
	pass

