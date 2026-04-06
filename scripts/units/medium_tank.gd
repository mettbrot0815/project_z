extends VehicleBase

# Medium Tank - heavy armor, powerful weapon, intelligence 3

func _ready() -> void:
	super._ready()
	max_hp = 350
	hp = 350
	damage = 40
	move_speed = 100
	intelligence = 3
	unit_type = "medium_tank"
	fire_rate = 2.0
	has_driver = true
	
	_setup_sprite()


func _setup_sprite() -> void:
	if has_node("Sprite2D"):
		var old_sprite = $Sprite2D
		remove_child(old_sprite)
		old_sprite.queue_free()
	
	_sprite = SpriteManager.create_vehicle_sprite("medium_tank", team_id)
	add_child(_sprite)
	_sprite.play("base")


func _process(delta: float) -> void:
	super._process(delta)

	if not driver_alive:
		return

	last_fired += delta

	if last_fired >= fire_rate:
		var target = find_priority_target()
		if target and global_position.distance_to(target.global_position) < 350:
			CombatManager.fire_projectile(global_position, target.global_position, damage, self)
			last_fired = 0.0


func find_priority_target() -> Node2D:
	var vehicles = get_tree().get_nodes_in_group("vehicle").filter(func(v):
		return v.team != self.team and v.hp > 0
	)

	if vehicles.size() > 0:
		vehicles.sort_custom(func(a, b):
			return global_position.distance_to(a.global_position) < global_position.distance_to(b.global_position)
		)
		return vehicles[0]

	return find_nearest_enemy()


func die(killer: Node2D) -> void:
	CombatManager.apply_splash_damage(global_position, 128, damage * 2.0, killer)

	# Create flying turret effect
	var turret_scene = load("res://scenes/effects/flying_turret.tscn")
	if turret_scene:
		var turret = turret_scene.instantiate()
		turret.global_position = global_position
		turret.velocity = Vector2(randf_range(-300, 300), -400)
		get_parent().add_child(turret)

	super.die(killer)
