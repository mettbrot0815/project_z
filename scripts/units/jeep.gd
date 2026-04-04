extends VehicleBase

# Jeep - fast scout vehicle, intelligence 2

func _ready() -> void:
	super._ready()
	max_hp = 80
	hp = 80
	damage = 10
	move_speed = 220
	intelligence = 2
	unit_type = "jeep"
	fire_rate = 0.5
	last_fired = 0.0
	has_driver = true


func _process(delta: float) -> void:
	super._process(delta)

	if not driver_alive:
		return

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


func die(killer: Node2D) -> void:
	# Jeeps explode with small splash
	CombatManager.apply_splash_damage(global_position, 32, damage, killer)
	super.die(killer)