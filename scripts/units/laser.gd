extends UnitBase

# Laser - powerful laser weapon, high intelligence, accurate

var _sprite: AnimatedSprite2D

func _ready() -> void:
	super._ready()
	max_hp = 75
	hp = 75
	damage = 20
	move_speed = 100
	intelligence = 4
	unit_type = "laser"
	fire_rate = 0.4
	
	_setup_sprite()


func _setup_sprite() -> void:

	const _SPRITE_SCRIPT = preload("res://scripts/core/sprite_manager.gd")
	if has_node("Sprite2D"):
		var old_sprite = $Sprite2D
		remove_child(old_sprite)
		old_sprite.queue_free()
	
	_sprite = _SPRITE_SCRIPT.create_robot_sprite("laser", team_id)
	add_child(_sprite)
	_sprite.play("walk")


func _process(delta: float) -> void:
	super._process(delta)
	last_fired += delta

	if last_fired >= fire_rate:
		var target = find_priority_target()
		if target and global_position.distance_to(target.global_position) < 300:
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


func _avoid_threats() -> void:
	var threats = get_tree().get_nodes_in_group("selectable").filter(func(unit):
		return unit.team != team_id and unit.hp > 0 and global_position.distance_to(unit.global_position) < 200
	)

	if threats.size() > 0:
		var closest = threats[0]
		var direction = (global_position - closest.global_position).normalized()
		var target_pos = global_position + direction * 150
		move_to(target_pos)


