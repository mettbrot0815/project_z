extends UnitBase

# Howitzer - stationary artillery, high damage, splash, slow reload

@export var turret_rotation_speed: float = 1.0
@export var range: float = 500.0
@export var splash_radius: float = 64.0

var target_rotation: float = 0.0
var current_rotation: float = 0.0


func _ready() -> void:
	super._ready()
	max_hp = 120
	hp = 120
	damage = 80
	intelligence = 0
	unit_type = "howitzer"
	fire_rate = 3.0
	move_speed = 0


func _process(delta: float) -> void:
	super._process(delta)

	var target = find_priority_target()
	if target and global_position.distance_to(target.global_position) <= range:
		var target_dir = (target.global_position - global_position).normalized()
		target_rotation = target_dir.angle()
		
		var angle_diff = angle_difference(current_rotation, target_rotation)
		current_rotation += sign(angle_diff) * min(abs(angle_diff), turret_rotation_speed * delta)
		
		if abs(angle_difference(current_rotation, target_rotation)) < 0.2:
			last_fired += delta
			if last_fired >= fire_rate:
				CombatManager.fire_projectile(global_position, target.global_position, damage, self)
				CombatManager.apply_splash_damage(target.global_position, splash_radius, damage * 0.5, self)
				last_fired = 0.0
	else:
		last_fired = 0.0


func find_priority_target() -> Node2D:
	var enemy_groups = find_enemy_groups()
	if enemy_groups.size() > 0:
		return enemy_groups[0]["center"]

	var buildings = get_tree().get_nodes_in_group("building").filter(func(b):
		return b.team != self.team and b.hp > 0
	)

	if buildings.size() > 0:
		buildings.sort_custom(func(a, b):
			return global_position.distance_to(a.global_position) < global_position.distance_to(b.global_position)
		)
		return buildings[0]

	return find_nearest_enemy()


func find_enemy_groups() -> Array:
	var enemies = get_tree().get_nodes_in_group("selectable").filter(func(unit):
		return unit.team != team_id and unit.hp > 0
	)

	var groups = []
	for enemy in enemies:
		var nearby = enemies.filter(func(e):
			return e != enemy and e.global_position.distance_to(enemy.global_position) < 80
		)
		if nearby.size() >= 3:
			var center = Vector2.ZERO
			for e in nearby:
				center += e.global_position
			center /= nearby.size()
			groups.append({"center": center, "count": nearby.size()})

	groups.sort_custom(func(a, b): return a["count"] > b["count"])
	return groups


func find_nearest_enemy() -> Node2D:
	var enemies = get_tree().get_nodes_in_group("selectable").filter(func(unit):
		return unit.team != team_id and unit.hp > 0 and unit != self
	)

	if enemies.size() == 0:
		return null

	enemies.sort_custom(func(a, b):
		return global_position.distance_to(a.global_position) < global_position.distance_to(b.global_position)
	)

	return enemies[0]
