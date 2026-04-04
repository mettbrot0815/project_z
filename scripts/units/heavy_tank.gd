extends VehicleBase

# Heavy Tank - maximum armor and damage, slow, intelligence 3

func _ready() -> void:
	super._ready()
	max_hp = 500
	hp = 500
	damage = 65
	move_speed = 75
	intelligence = 3
	unit_type = "heavy_tank"
	fire_rate = 3.0
	last_fired = 0.0
	has_driver = true


func _process(delta: float) -> void:
	super._process(delta)

	if not driver_alive:
		return

	last_fired += delta

	if last_fired >= fire_rate:
		var target = find_priority_target()
		if target and global_position.distance_to(target.global_position) < 400:
			CombatManager.fire_projectile(global_position, target.global_position, damage, self)
			last_fired = 0.0


func find_priority_target() -> Node2D:
	# Heavy tank prioritizes buildings and fortified positions
	var buildings = get_tree().get_nodes_in_group("building").filter(func(b):
		return b.owner != owner and b.hp > 0
	)

	if buildings.size() > 0:
		buildings.sort_custom(func(a, b):
			return global_position.distance_to(a.global_position) < global_position.distance_to(b.global_position)
		)
		return buildings[0]

	# Then vehicles
	var vehicles = get_tree().get_nodes_in_group("vehicle").filter(func(v):
		return v.owner != owner and v.hp > 0
	)

	if vehicles.size() > 0:
		vehicles.sort_custom(func(a, b):
			return global_position.distance_to(a.global_position) < global_position.distance_to(b.global_position)
		)
		return vehicles[0]

	return find_nearest_enemy()


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
	# Heavy tanks explode with devastating turret flying
	CombatManager.apply_splash_damage(global_position, 160, damage * 2.5, killer)

	# Create flying turret effect
	var turret_scene = load("res://scenes/effects/flying_turret.tscn")
	if turret_scene:
		var turret = turret_scene.instantiate()
		turret.global_position = global_position
		turret.velocity = Vector2(RANDF_RANGE(-400, 400), -500)
		get_parent().add_child(turret)

	super.die(killer)