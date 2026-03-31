extends Node2D

class_name Factory

# Factory configuration
@export var flag_id: String = ""
@export var type: String = "robot"  # "robot" or "vehicle"
@export var team: int = 0
@export var x: float = 0
@export var y: float = 0

# Production settings
@export_group("Production")
@export var base_build_time: int = 5  # seconds
@export var production_multiplier: float = 1.0

# Runtime
var build_timer: float = 0.0
var is_building: bool = false
var next_spawn_time: float = 0.0

# Queue
var build_queue: Array[String] = []  # Unit types waiting to be built

func _ready() -> void:
	_build_timer()

func _process(delta: float) -> void:
	if is_building:
		build_timer += delta

		if build_timer >= base_build_time * production_multiplier:
			_spawn_unit()
			build_timer = 0.0

func _build_timer() -> void:
	is_building = true
	build_timer = 0.0
	_update_next_spawn()

# Set production multiplier (called when sectors are captured)
func update_multiplier(multiplier: float) -> void:
	production_multiplier = multiplier
	print("[Factory] Factory", flag_id, "multiplier updated to:", multiplier)
	_update_next_spawn()

func _update_next_spawn() -> void:
	next_spawn_time = Time.get_ticks_msec() / 1000.0 + base_build_time * production_multiplier

# Build a unit
func build_unit(unit_type: String) -> bool:
	if not build_queue.has(unit_type):
		return false

	build_queue.erase(unit_type)
	is_building = true
	build_timer = 0.0
	print("[Factory] Factory", flag_id, "queued unit:", unit_type)
	return true

# Spawn a unit (called when timer completes)
func _spawn_unit() -> void:
	if build_queue.is_empty():
		return

	var unit_type: String = build_queue[0]
	build_queue.pop_front()

	# Create and add unit to scene
	var unit = Unit.new()
	unit.type = unit_type
	unit.team = team
	unit.x = x + randf_range(-2, 2)
	unit.y = y + randf_range(-2, 2)

	# Add unit as child
	get_parent().add_child(unit)
	unit.add_to_group("units")

	# Emit signal for game to handle
	unit_spawned.emit(unit, unit_type)

	print("[Factory] Spawned", unit_type, "at factory", flag_id)

# Signal emitted when unit is spawned
signal unit_spawned(unit: Unit, unit_type: String)

# Get build queue size
func get_queue_size() -> int:
	return build_queue.size()

# Get next spawn time
func get_next_spawn_time() -> float:
	return next_spawn_time if is_building else 0.0

# Check if can build (queue not full)
func can_build() -> bool:
	return build_queue.size() < 3  # Max 3 units in queue

func get_factory_type() -> String:
	return type

func get_flag() -> String:
	return flag_id
