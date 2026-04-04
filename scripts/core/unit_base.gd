class_name UnitBase
extends CharacterBody2D

# Base unit class for all robots, vehicles, and guns

enum Team { NEUTRAL, RED, BLUE }

@export var max_hp: float = 100.0
@export var damage: float = 10.0
@export var move_speed: float = 100.0
@export var intelligence: int = 0 # 0-5 scale: lower = dumber
@export var unit_type: String = "robot"

signal died(killer: Node2D)
signal team_changed(new_team: Team)

var hp: float = max_hp
var team: Team = Team.NEUTRAL:
	set(value):
		team = value
		team_changed.emit(value)

var current_order: Dictionary = {}
var target: Node2D = null

var navigation_agent: NavigationAgent2D


func _ready() -> void:
	navigation_agent = $NavigationAgent2D
	navigation_agent.max_speed = move_speed
	
	if intelligence > 0:
		set_process_internal(true)


func _physics_process(delta: float) -> void:
	if hp <= 0:
		return
	
	if navigation_agent.is_navigation_finished():
		return
	
	var next_pos = navigation_agent.get_next_path_position()
	velocity = global_position.direction_to(next_pos) * move_speed
	move_and_slide()


func move_to(target_position: Vector2) -> void:
	navigation_agent.target_position = target_position


func attack(target_unit: Node2D) -> void:
	target = target_unit
	# Implement attack logic
	pass


func take_damage(amount: float, attacker: Node2D) -> void:
	hp -= amount
	if hp <= 0:
		die(attacker)


func die(killer: Node2D) -> void:
	died.emit(killer)
	queue_free()


func get_team() -> Team:
	return team


# Intelligence based autonomous AI
func _process(delta: float) -> void:
	if team == Team.NEUTRAL:
		return
	
	match intelligence:
		0: # Grunt: only rush flags
			_find_nearest_flag()
		1: # Psycho: attack nearest enemy
			_find_nearest_enemy()
		2: # Tough: attack vehicles
			_find_nearest_vehicle()
		3: # Sniper: prioritize drivers
			_find_nearest_driver()
		4: # Elite: avoid danger
			_avoid_threats()
		5: # Commander: strategic decisions
			_strategic_behaviour()


func _find_nearest_flag() -> void:
	if not TerritoryManager:
		return
	var nearest_flag: Node2D = null
	var nearest_distance: float = INF
	
	for territory_id in TerritoryManager.territories:
		var territory = TerritoryManager.territories[territory_id]
		if territory.owner == team:
			continue
		
		var flag = territory.flag
		if flag:
			var distance = global_position.distance_to(flag.global_position)
			if distance < nearest_distance:
				nearest_distance = distance
				nearest_flag = flag
	
	if nearest_flag:
		move_to(nearest_flag.global_position)


func _find_nearest_enemy() -> void:
	var enemies = get_tree().get_nodes_in_group("selectable").filter(func(unit):
		return unit.team != team and unit.hp > 0 and unit != self
	)
	
	if enemies.size() == 0:
		return
	
	enemies.sort_custom(func(a, b):
		return global_position.distance_to(a.global_position) < global_position.distance_to(b.global_position)
	)
	
	var nearest_enemy = enemies[0]
	if nearest_enemy:
		move_to(nearest_enemy.global_position)


func _find_nearest_vehicle() -> void:
	var vehicles = get_tree().get_nodes_in_group("selectable").filter(func(unit):
		return unit.team != team and unit.hp > 0 and unit != self and unit.unit_type in ["jeep", "light_tank", "medium_tank", "heavy_tank", "apc", "crane", "missile_launcher"]
	)
	
	if vehicles.size() == 0:
		return
	
	vehicles.sort_custom(func(a, b):
		return global_position.distance_to(a.global_position) < global_position.distance_to(b.global_position)
	)
	
	var nearest_vehicle = vehicles[0]
	if nearest_vehicle:
		move_to(nearest_vehicle.global_position)


func _find_nearest_driver() -> void:
	var vehicles_with_drivers = get_tree().get_nodes_in_group("selectable").filter(func(unit):
		return unit.team != team and unit.hp > 0 and unit != self and unit.unit_type in ["jeep", "light_tank", "medium_tank", "heavy_tank", "apc", "crane", "missile_launcher"] and "driver_alive" in unit and unit.driver_alive
	)
	
	if vehicles_with_drivers.size() == 0:
		return
	
	vehicles_with_drivers.sort_custom(func(a, b):
		return global_position.distance_to(a.global_position) < global_position.distance_to(b.global_position)
	)
	
	var nearest_vehicle = vehicles_with_drivers[0]
	if nearest_vehicle:
		move_to(nearest_vehicle.global_position)


func _avoid_threats() -> void:
	# Move away from nearest enemy
	var enemies = get_tree().get_nodes_in_group("selectable").filter(func(unit):
		return unit.team != team and unit.hp > 0 and unit != self
	)
	
	if enemies.size() == 0:
		return
	
	enemies.sort_custom(func(a, b):
		return global_position.distance_to(a.global_position) < global_position.distance_to(b.global_position)
	)
	
	var nearest_enemy = enemies[0]
	if nearest_enemy:
		var away_direction = (global_position - nearest_enemy.global_position).normalized()
		var target_pos = global_position + away_direction * 100  # Move 100 units away
		# Clamp to prevent out-of-bounds
		target_pos.x = clamp(target_pos.x, 0, 2048)  # Assuming map size
		target_pos.y = clamp(target_pos.y, 0, 2048)
		move_to(target_pos)


func _strategic_behaviour() -> void:
	# Alternate between flag-rushing and enemy-seeking
	var rand_choice = randi() % 2
	if rand_choice == 0:
		_find_nearest_flag()
	else:
		_find_nearest_enemy()
