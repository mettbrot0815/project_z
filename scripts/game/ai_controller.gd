extends Node

# AI Controller - Centralized AI opponent state machine and production logic
# Autoload singleton: AIController

enum AIState {
	IDLE,       # No units, waiting for production
	EXPAND,     # Capture nearby unclaimed territories
	ATTACK,     # Push toward enemy base
	DEFEND,     # Protect key territories
	REINFORCE   # Rebuild after losses
}

enum Difficulty {
	EASY,       # Slow production, passive
	NORMAL,     # Balanced
	HARD        # Fast production, aggressive
}

var current_state: AIState = AIState.IDLE
var difficulty: Difficulty = Difficulty.NORMAL

var target_position: Vector2 = Vector2.ZERO
var defend_position: Vector2 = Vector2.ZERO

var production_queue: Array[String] = []
var command_cooldown: float = 0.0
var state_cooldown: float = 0.0
var vision_timer: float = 0.0

var known_enemies: Array[Dictionary] = []
var explored_territories: Array[int] = []

const UPDATE_INTERVAL: float = 1.0
const COMMAND_INTERVAL: float = 0.5

const BLUE_TEAM: int = 2
const RED_TEAM: int = 1

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func _physics_process(delta: float) -> void:
	if not GameState.game_running:
		return
	
	command_cooldown -= delta
	state_cooldown -= delta
	vision_timer -= delta
	
	if state_cooldown <= 0:
		state_cooldown = UPDATE_INTERVAL
		evaluate_state()
		update_vision()
		update_map_awareness()
	
	if command_cooldown <= 0:
		command_cooldown = COMMAND_INTERVAL
		execute_commands()

func initialize(diff: Difficulty = Difficulty.NORMAL) -> void:
	difficulty = diff
	current_state = AIState.IDLE
	production_queue.clear()
	known_enemies.clear()
	explored_territories.clear()
	state_cooldown = 2.0
	print("AIController: Initialized with difficulty ", difficulty)

func cleanup() -> void:
	current_state = AIState.IDLE
	production_queue.clear()
	known_enemies.clear()

func evaluate_state() -> void:
	var territories = TerritoryManager.get_territory_count(BLUE_TEAM)
	var unit_count = get_ai_unit_count()
	var enemy_count = get_enemy_unit_count()
	var factories = get_ai_factories()
	var is_producing = factories.any(func(f): return f.is_producing())
	
	var new_state = current_state
	
	match current_state:
		AIState.IDLE:
			if is_producing:
				new_state = AIState.IDLE
			elif territories < 3:
				new_state = AIState.EXPAND
			elif unit_count >= 5:
				new_state = AIState.ATTACK
			else:
				new_state = AIState.EXPAND
		
		AIState.EXPAND:
			if territories >= 3 and unit_count >= get_attack_threshold():
				new_state = AIState.ATTACK
			elif enemy_count > unit_count * 2 and unit_count < 3:
				new_state = AIState.DEFEND
			elif is_producing:
				new_state = AIState.IDLE
		
		AIState.ATTACK:
			if unit_count < 2:
				new_state = AIState.REINFORCE
			elif enemy_count > unit_count * 3:
				new_state = AIState.DEFEND
			elif territories < 2:
				new_state = AIState.EXPAND
		
		AIState.DEFEND:
			if unit_count >= get_attack_threshold():
				new_state = AIState.ATTACK
			elif enemy_count < unit_count:
				new_state = AIState.EXPAND
		
		AIState.REINFORCE:
			if unit_count >= 3:
				new_state = AIState.EXPAND
	
	if new_state != current_state:
		current_state = new_state
		on_state_changed()
		print("AIController: State changed to ", AIState.keys()[current_state])

func on_state_changed() -> void:
	match current_state:
		AIState.EXPAND:
			target_position = find_nearest_unclaimed_flag()
		AIState.ATTACK:
			target_position = find_enemy_fort_position()
		AIState.DEFEND:
			target_position = defend_position
		AIState.REINFORCE:
			target_position = get_ai_fort_position()

func execute_commands() -> void:
	match current_state:
		AIState.EXPAND:
			command_expand()
		AIState.ATTACK:
			command_attack()
		AIState.DEFEND:
			command_defend()
		AIState.REINFORCE:
			command_reinforce()
	
	execute_production()

func command_expand() -> void:
	if target_position == Vector2.ZERO:
		target_position = find_nearest_unclaimed_flag()
	if target_position == Vector2.ZERO:
		return
	
	var units = get_idle_ai_units()
	var batch_size = mini(units.size(), 5)
	for i in range(batch_size):
		units[i].move_to(target_position)

func command_attack() -> void:
	if target_position == Vector2.ZERO:
		target_position = find_enemy_fort_position()
	if target_position == Vector2.ZERO:
		return
	
	var units = get_idle_ai_units()
	var batch_size = mini(units.size(), 8)
	var split = mini(batch_size, 3)
	
	for i in range(split):
		var flanking = target_position + Vector2(randf_range(-200, 200), randf_range(-200, 200))
		units[i].move_to(flanking)
	
	for i in range(split, batch_size):
		units[i].move_to(target_position)

func command_defend() -> void:
	if defend_position == Vector2.ZERO:
		defend_position = get_ai_fort_position()
	
	var units = get_idle_ai_units()
	for unit in units:
		unit.move_to(defend_position)

func command_reinforce() -> void:
	var rally_point = get_ai_fort_position()
	var units = get_idle_ai_units()
	for unit in units:
		unit.move_to(rally_point)

func execute_production() -> void:
	var factories = get_ai_factories()
	var idle_factories = factories.filter(func(f): return not f.is_producing())
	
	for factory in idle_factories:
		var unit_type = get_next_production()
		if unit_type != "":
			factory.start_production(unit_type)

func get_next_production() -> String:
	if production_queue.is_empty():
		build_production_queue()
	
	if production_queue.is_empty():
		return ""
	
	return production_queue.pop_front()

func build_production_queue() -> void:
	production_queue.clear()
	var count = 8
	
	match difficulty:
		Difficulty.EASY:
			for i in range(count):
				var r = randf()
				if r < 0.70:
					production_queue.append("grunt")
				elif r < 0.90:
					production_queue.append("tough")
				else:
					production_queue.append("psycho")
		
		Difficulty.NORMAL:
			for i in range(count):
				var r = randf()
				if r < 0.40:
					production_queue.append("grunt")
				elif r < 0.65:
					production_queue.append("tough")
				elif r < 0.80:
					production_queue.append("psycho")
				elif r < 0.90:
					production_queue.append("sniper")
				else:
					production_queue.append("light_tank")
		
		Difficulty.HARD:
			for i in range(count):
				var r = randf()
				if r < 0.30:
					production_queue.append("grunt")
				elif r < 0.50:
					production_queue.append("tough")
				elif r < 0.65:
					production_queue.append("medium_tank")
				elif r < 0.80:
					production_queue.append("sniper")
				elif r < 0.90:
					production_queue.append("laser")
				else:
					production_queue.append("heavy_tank")

func update_vision() -> void:
	if vision_timer > 0:
		return
	vision_timer = 0.5
	
	for unit in get_ai_units():
		var enemies = find_enemies_in_vision(unit)
		for enemy in enemies:
			update_known_enemy(enemy)
	
	var filtered: Array[Dictionary] = []
	for e in known_enemies:
		var last_seen = e.get("last_seen") if e.has("last_seen") else 0.0
		if last_seen > -10.0:
			filtered.append(e)
	known_enemies = filtered

func find_enemies_in_vision(unit: Node2D) -> Array:
	var vision_range = get_vision_range(unit)
	var enemies: Array[Node] = []
	
	var all_enemies = get_tree().get_nodes_in_group("selectable").filter(func(u):
		return u.team == RED_TEAM and u.hp > 0
	)
	
	for enemy in all_enemies:
		if unit.global_position.distance_to(enemy.global_position) < vision_range:
			enemies.append(enemy)
	
	return enemies

func get_vision_range(unit: Node2D) -> float:
	match unit.get("unit_type"):
		"sniper": return 500.0
		"commander": return 400.0
		"howitzer": return 600.0
		_: return 300.0

func update_known_enemy(enemy: Node2D) -> void:
	var found = false
	for e in known_enemies:
		if e.get("unit") == enemy:
			e.last_seen = 0.0
			e.position = enemy.global_position
			found = true
			break
	
	if not found:
		known_enemies.append({
			"unit": enemy,
			"last_seen": 0.0,
			"position": enemy.global_position
		})

func update_map_awareness() -> void:
	var ai_center = get_ai_center()
	
	for flag in get_tree().get_nodes_in_group("flag"):
		var territory_id = flag.territory_id if "territory_id" in flag else -1
		if territory_id == -1:
			continue
		if flag.global_position.distance_to(ai_center) < 1000:
			if not explored_territories.has(territory_id):
				explored_territories.append(territory_id)

func find_nearest_unclaimed_flag() -> Vector2:
	var ai_center = get_ai_center()
	var nearest_pos = Vector2.ZERO
	var nearest_dist = INF
	
	for flag in get_tree().get_nodes_in_group("flag"):
		var territory_id = flag.territory_id if "territory_id" in flag else -1
		if territory_id == -1:
			continue
		var territory = TerritoryManager.territories.get(territory_id)
		if territory == null:
			continue
		var owner = territory.get("owner", -1)
		if owner == TerritoryManager.Owner.NEUTRAL:
			var dist = ai_center.distance_to(flag.global_position)
			if dist < nearest_dist:
				nearest_dist = dist
				nearest_pos = flag.global_position
	
	return nearest_pos

func find_enemy_fort_position() -> Vector2:
	var forts = get_tree().get_nodes_in_group("fort")
	for fort in forts:
		if fort.team == RED_TEAM:
			return fort.global_position
	return Vector2.ZERO

func get_ai_fort_position() -> Vector2:
	var forts = get_tree().get_nodes_in_group("fort")
	for fort in forts:
		if fort.team == BLUE_TEAM:
			return fort.global_position
	return Vector2(500, 500)

func get_ai_center() -> Vector2:
	var units = get_ai_units()
	if units.is_empty():
		return get_ai_fort_position()
	
	var center = Vector2.ZERO
	for unit in units:
		center += unit.global_position
	return center / units.size()

func get_ai_units() -> Array:
	return get_tree().get_nodes_in_group("selectable").filter(func(u):
		return u.team == BLUE_TEAM and u.hp > 0 and u.has_method("move_to")
	)

func get_idle_ai_units() -> Array:
	var units = get_ai_units()
	var idle = []
	
	for unit in units:
		if unit.has_method("is_idle") and unit.is_idle():
			idle.append(unit)
		elif not unit.has_method("is_moving") or not unit.is_moving():
			idle.append(unit)
	
	return idle

func get_ai_unit_count() -> int:
	return get_ai_units().size()

func get_enemy_unit_count() -> int:
	return get_tree().get_nodes_in_group("selectable").filter(func(u):
		return u.team == RED_TEAM and u.hp > 0
	).size()

func get_ai_factories() -> Array:
	var factories = get_tree().get_nodes_in_group("factory")
	return factories.filter(func(f): return f.team == BLUE_TEAM)

func get_attack_threshold() -> int:
	match difficulty:
		Difficulty.EASY: return 5
		Difficulty.NORMAL: return 3
		Difficulty.HARD: return 1
	return 3

func get_flee_threshold() -> float:
	match difficulty:
		Difficulty.EASY: return 0.3
		Difficulty.NORMAL: return 0.1
		Difficulty.HARD: return 0.05
	return 0.1

func get_build_time_multiplier() -> float:
	match difficulty:
		Difficulty.EASY: return 1.5
		Difficulty.NORMAL: return 1.0
		Difficulty.HARD: return 0.7
	return 1.0

func get_current_target() -> Vector2:
	if not known_enemies.is_empty():
		var weakest = known_enemies[0]
		for e in known_enemies:
			if e.unit.hp < weakest.unit.hp:
				weakest = e
		return weakest.position
	return target_position

func set_difficulty(diff: Difficulty) -> void:
	difficulty = diff
	print("AIController: Difficulty set to ", Difficulty.keys()[difficulty])

func get_difficulty() -> Difficulty:
	return difficulty

func get_state() -> AIState:
	return current_state
