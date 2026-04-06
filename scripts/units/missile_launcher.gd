extends VehicleBase

# Mobile Missile Launcher - long range, high damage, slow reload

func _ready() -> void:
	# Override group detection for missile launcher (requires 4+)
	GROUP_SIZE_THRESHOLD = 4
	GROUP_DETECTION_RADIUS = 100.0
	
	super._ready()
	max_hp = 100
	hp = 100
	damage = 100
	move_speed = 80
	intelligence = 3
	unit_type = "missile_launcher"
	fire_rate = 5.0
	has_driver = true
	
	_setup_sprite()


func _setup_sprite() -> void:
	if has_node("Sprite2D"):
		var old_sprite = $Sprite2D
		remove_child(old_sprite)
		old_sprite.queue_free()
	
	_sprite = SpriteManager.create_vehicle_sprite("missile_launcher", team_id)
	add_child(_sprite)
	_sprite.play("base")


func _process(delta: float) -> void:
	super._process(delta)

	if not driver_alive:
		return

	if intelligence > 0:
		_find_high_value_target()

	last_fired += delta

	if last_fired >= fire_rate:
		var target = find_priority_target()
		if target and global_position.distance_to(target.global_position) < 600:
			CombatManager.fire_projectile(global_position, target.global_position, damage, self)
			last_fired = 0.0


func find_priority_target() -> Node2D:
	var buildings = get_tree().get_nodes_in_group("building").filter(func(b):
		return b.team != self.team and b.hp > 0
	)

	if buildings.size() > 0:
		buildings.sort_custom(func(a, b):
			return global_position.distance_to(a.global_position) < global_position.distance_to(b.global_position)
		)
		return buildings[0]

	var enemy_groups = find_enemy_groups()
	if enemy_groups.size() > 0:
		return enemy_groups[0]["center"]

	return find_nearest_enemy()


func _find_high_value_target() -> void:
	var buildings = get_tree().get_nodes_in_group("building").filter(func(b):
		return b.team != self.team and b.hp > 0
	)

	if buildings.size() > 0:
		buildings.sort_custom(func(a, b):
			return global_position.distance_to(a.global_position) < global_position.distance_to(b.global_position)
		)
		move_to(buildings[0].global_position)
		return

	var enemy_groups = find_enemy_groups()
	if enemy_groups.size() > 0:
		move_to(enemy_groups[0]["center"])
		return

	var enemy = find_nearest_enemy()
	if enemy:
		move_to(enemy.global_position)


func die(killer: Node2D) -> void:
	CombatManager.apply_splash_damage(global_position, 200, damage * 1.5, killer)
	super.die(killer)
