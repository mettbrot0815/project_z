extends UnitBase

# Tough - high HP, slow, powerful shots, intelligence 2

func _ready() -> void:
	super._ready()
	max_hp = 100
	hp = 100
	damage = 12
	move_speed = 90
	intelligence = 2
	unit_type = "tough"
	fire_rate = 0.6
	last_fired = 0.0


func _process(delta: float) -> void:
	super._process(delta)
	last_fired += delta

	if last_fired >= fire_rate:
		var target = find_nearest_enemy()
		if target and global_position.distance_to(target.global_position) < 180:
			CombatManager.fire_projectile(global_position, target.global_position, damage, self)
			last_fired = 0.0


func find_nearest_enemy() -> Node2D:
	var enemies = get_tree().get_nodes_in_group("selectable").filter(func(unit):
		return unit.unit.team != self.team and unit.hp > 0 and unit != self
	)

	if enemies.size() == 0:
		return null

	enemies.sort_custom(func(a, b):
		return global_position.distance_to(a.global_position) < global_position.distance_to(b.global_position)
	)

	return enemies[0]


