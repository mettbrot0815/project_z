extends UnitBase

# Commander - highest intelligence, strategic AI, powerful

var _sprite: AnimatedSprite2D

func _ready() -> void:
	super._ready()
	max_hp = 150
	hp = 150
	damage = 25
	move_speed = 70
	intelligence = 5
	unit_type = "commander"
	fire_rate = 0.5
	
	_setup_sprite()


func _setup_sprite() -> void:
	if has_node("Sprite2D"):
		var old_sprite = $Sprite2D
		remove_child(old_sprite)
		old_sprite.queue_free()
	
	_sprite = SpriteManager.create_robot_sprite("commander", team_id)
	add_child(_sprite)
	_sprite.play("walk")


func _process(delta: float) -> void:
	super._process(delta)
	last_fired += delta

	if last_fired >= fire_rate:
		var target = find_priority_target()
		if target and global_position.distance_to(target.global_position) < 250:
			CombatManager.fire_projectile(global_position, target.global_position, damage, self)
			last_fired = 0.0

	if intelligence >= 5:
		_strategic_behaviour()


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


func _strategic_behaviour() -> void:
	var nearby_enemies = get_tree().get_nodes_in_group("selectable").filter(func(unit):
		return unit.team != team_id and unit.hp > 0 and global_position.distance_to(unit.global_position) < 400
	)

	var nearby_allies = get_tree().get_nodes_in_group("selectable").filter(func(unit):
		return unit.team == team_id and unit.hp > 0 and unit != self
	)

	if nearby_enemies.size() > nearby_allies.size() + 2:
		var nearest_flag = find_nearest_flag()
		if nearest_flag:
			move_to(nearest_flag.global_position)
	elif nearby_enemies.size() < nearby_allies.size():
		var nearest_enemy = find_nearest_enemy()
		if nearest_enemy:
			move_to(nearest_enemy.global_position)


func find_nearest_flag() -> Node2D:
	var flags = get_tree().get_nodes_in_group("flag").filter(func(f):
		return f.team_owner == team_id or f.team_owner == TerritoryManager.Owner.NEUTRAL
	)

	if flags.size() == 0:
		return null

	flags.sort_custom(func(a, b):
		return global_position.distance_to(a.global_position) < global_position.distance_to(b.global_position)
	)

	return flags[0]
