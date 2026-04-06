extends UnitBase

# Sniper - high damage, long range, prioritizes vehicle drivers

const FIRE_RATE = 2.2
const RANGE = 400.0

var _sprite: AnimatedSprite2D


func _ready() -> void:
	super._ready()
	max_hp = 45
	hp = 45
	damage = 75
	move_speed = 85
	intelligence = 3
	unit_type = "sniper"
	
	_setup_sprite()


func _setup_sprite() -> void:

	const _SPRITE_SCRIPT = preload("res://scripts/core/sprite_manager.gd")
	if has_node("Sprite2D"):
		var old_sprite = $Sprite2D
		remove_child(old_sprite)
		old_sprite.queue_free()
	
	_sprite = _SPRITE_SCRIPT.create_robot_sprite("sniper", team_id)
	add_child(_sprite)
	_sprite.play("walk")


func _process(delta: float) -> void:
	super._process(delta)
	last_fired += delta
	
	if last_fired >= FIRE_RATE:
		var target = find_priority_target()
		if target and global_position.distance_to(target.global_position) < RANGE:
			CombatManager.fire_projectile(global_position, target.global_position, damage, self)
			last_fired = 0.0


func find_priority_target() -> Node2D:
	# First priority: vehicle drivers
	var vehicles = get_tree().get_nodes_in_group("vehicle").filter(func(v):
		return v.team != self.team and v.hp > 0 and v.driver_alive
	)
	
	if vehicles.size() > 0:
		vehicles.sort_custom(func(a, b):
			return global_position.distance_to(a.global_position) < global_position.distance_to(b.global_position)
		)
		return vehicles[0]
	
	# Second priority: enemies
	return find_nearest_enemy()


