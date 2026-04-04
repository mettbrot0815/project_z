extends VehicleBase

# Light Tank - balanced vehicle, intelligence 2

func _ready() -> void:
	super._ready()
	max_hp = 200
	hp = 200
	damage = 25
	move_speed = 130
	intelligence = 2
	unit_type = "light_tank"
	fire_rate = 1.5
	last_fired = 0.0
	has_driver = true


func _process(delta: float) -> void:
	super._process(delta)

	if not driver_alive:
		return

	last_fired += delta

	if last_fired >= fire_rate:
		var target = find_nearest_enemy()
		if target and global_position.distance_to(target.global_position) < 300:
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
	# Light tanks explode with turret flying
	CombatManager.apply_splash_damage(global_position, 96, damage * 1.5, killer)

	# Create flying turret effect
	var turret_scene = load("res://scenes/effects/flying_turret.tscn")
	if turret_scene:
		var turret = turret_scene.instantiate()
		turret.global_position = global_position
		turret.velocity = Vector2(RANDF_RANGE(-200, 200), -300)
		get_parent().add_child(turret)

	super.die(killer)