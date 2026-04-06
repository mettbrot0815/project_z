extends VehicleBase

# APC - troop transport, carries units, intelligence 2

@export var max_passengers: int = 4
var passengers: Array = []


func _ready() -> void:
	super._ready()
	max_hp = 150
	hp = 150
	damage = 8
	move_speed = 140
	intelligence = 2
	unit_type = "apc"
	fire_rate = 1.0
	has_driver = true


func _process(delta: float) -> void:
	super._process(delta)

	if not driver_alive:
		return

	if intelligence > 0:
		_find_nearest_flag_for_transport()

	last_fired += delta

	if last_fired >= fire_rate and passengers.size() > 0:
		var target = find_nearest_enemy()
		if target and global_position.distance_to(target.global_position) < 200:
			CombatManager.fire_projectile(global_position, target.global_position, damage, self)
			last_fired = 0.0


func _find_nearest_flag_for_transport() -> void:
	var nearest_flag: Node2D = null
	var nearest_distance: float = INF
	
	for territory_id in TerritoryManager.territories:
		var territory = TerritoryManager.territories[territory_id]
		if territory.owner == team_id:
			continue
		
		var flag = territory.flag
		var distance = global_position.distance_to(flag.global_position)
		if distance < nearest_distance:
			nearest_distance = distance
			nearest_flag = flag
	
	if nearest_flag:
		move_to(nearest_flag.global_position)


func can_load_unit(unit: Node2D) -> bool:
	return passengers.size() < max_passengers and unit.team == team_id


func load_unit(unit: Node2D) -> void:
	if can_load_unit(unit) and unit.has_method("get_team_id") and unit.get_team_id() == team_id:
		passengers.append(unit)
		unit.visible = false
		if unit.has_method("set_physics_process"):
			unit.set_physics_process(false)
		if unit.has_method("set_process_internal"):
			unit.set_process_internal(false)
		if "navigation_agent" in unit:
			unit.navigation_agent.target_position = unit.global_position


func unload_units() -> void:
	for passenger in passengers:
		passenger.global_position = global_position + Vector2(randf_range(-32, 32), randf_range(-32, 32))
		passenger.visible = true
		if passenger.has_method("set_physics_process"):
			passenger.set_physics_process(true)
		if passenger.has_method("set_process_internal") and passenger.intelligence > 0:
			passenger.set_process_internal(true)

	passengers.clear()


func die(killer: Node2D) -> void:
	unload_units()
	CombatManager.apply_splash_damage(global_position, 64, damage, killer)
	super.die(killer)
