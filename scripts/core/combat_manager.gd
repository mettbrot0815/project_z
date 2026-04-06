extends Node

# Singleton Combat Manager
# Handles projectiles, collision detection, splash damage

signal projectile_fired(origin: Vector2, target: Vector2)
signal unit_damaged(unit: Node2D, damage: float, attacker: Node2D)

var active_projectiles: Array = []
const PROJECTILE_SPEED = 800.0
const MAX_PROJECTILE_DISTANCE: float = 2000.0

var _enemy_cache: Array = []
var _cache_timer: float = 0.0
const CACHE_INTERVAL: float = 0.25


func fire_projectile(origin: Vector2, target: Vector2, damage: float, attacker: Node2D) -> void:
	var projectile = {
		"position": origin,
		"origin": origin,
		"target": target,
		"damage": damage,
		"attacker": attacker,
		"velocity": origin.direction_to(target) * PROJECTILE_SPEED
	}
	active_projectiles.append(projectile)
	projectile_fired.emit(origin, target)
	
	if attacker and attacker.has_method("get_unit_type"):
		var unit_type = attacker.get_unit_type()
		AudioManager.play_fire_sound(unit_type)
	
	if attacker and attacker.has_method("spawn_muzzle_flash"):
		var direction = origin.direction_to(target).normalized()
		attacker.spawn_muzzle_flash(direction)


func _physics_process(delta: float) -> void:
	_cache_timer += delta
	if _cache_timer >= CACHE_INTERVAL:
		_cache_timer = 0.0
		_update_enemy_cache()
	
	for i in range(active_projectiles.size() -1, -1, -1):
		var proj = active_projectiles[i]
		proj.position += proj.velocity * delta
		
		var query = PhysicsPointQueryParameters2D.new()
		query.position = proj.position
		query.collide_with_areas = false
		query.collision_mask = 0b1
		
		var results = get_viewport().get_world_2d().direct_space_state.intersect_point(query)
		
		for result in results:
			var hit_unit = result["collider"]
			if hit_unit != proj.attacker and hit_unit.has_method("take_damage"):
				hit_unit.take_damage(proj.damage, proj.attacker)
				unit_damaged.emit(hit_unit, proj.damage, proj.attacker)
				active_projectiles.remove_at(i)
				break
		
		if proj.position.distance_to(proj.target) < 16 or proj.position.distance_to(proj.origin) > MAX_PROJECTILE_DISTANCE:
			active_projectiles.remove_at(i)


func _update_enemy_cache() -> void:
	var new_cache: Array = []
	for unit in get_tree().get_nodes_in_group("selectable"):
		if unit.has_method("get_team_id") and unit.hp > 0:
			new_cache.append(unit)
	_enemy_cache = new_cache


func get_cached_enemies() -> Array:
	return _enemy_cache


func apply_splash_damage(origin: Vector2, radius: float, damage: float, attacker: Node2D) -> void:
	var query = PhysicsShapeQueryParameters2D.new()
	query.shape = CircleShape2D.new()
	query.shape.radius = radius
	query.transform = Transform2D(0, origin)
	query.collision_mask = 0b1  # Only damage units on layer 1
	
	var results = get_viewport().get_world_2d().direct_space_state.intersect_shape(query)
	
	for result in results:
		var unit = result["collider"]
		if unit != attacker and unit.has_method("take_damage"):
			var dist = unit.global_position.distance_to(origin)
			var falloff = 1.0 - (dist / radius)
			if falloff > 0:
				unit.take_damage(damage * falloff, attacker)
