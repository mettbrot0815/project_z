extends unit_base

# Psycho - rapid fire, machine gun, intelligence 1

func _ready() -> void:
	super._ready()
	max_hp = 65
	hp = 65
	damage = 6
	move_speed = 120
	intelligence = 1
	unit_type = "psycho"
	fire_rate = 0.15
	last_fired = 0.0


func _process(delta: float) -> void:
	super._process(delta)
	last_fired += delta

	if last_fired >= fire_rate:
		var target = find_nearest_enemy()
		if target and global_position.distance_to(target.global_position) < 200:
			CombatManager.fire_projectile(global_position, target.global_position, damage, self)
			last_fired = 0.0


func find_nearest_enemy() -> Node2D:
	var enemies = get_tree().get_nodes_in_group("selectable").filter(func(unit):
		return unit.owner != owner and unit.hp > 0 and unit != self
	)

	if enemies.size() == 0:
		return null

	enemies.sort_custom(func(a, b):
		return global_position.distance_to(a.global_position) < global_position.distance_to(b.global_position)
	)

	return enemies[0]