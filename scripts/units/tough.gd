extends UnitBase

# Tough - high HP, slow, powerful shots, intelligence 2

var _sprite: AnimatedSprite2D
const _SPRITE_SCRIPT = preload("res://scripts/core/sprite_manager.gd")

func _ready() -> void:
	super._ready()
	max_hp = 100
	hp = 100
	damage = 12
	move_speed = 90
	intelligence = 2
	unit_type = "tough"
	fire_rate = 0.6
	
	_setup_sprite()


func _setup_sprite() -> void:
	if has_node("Sprite2D"):
		var old_sprite = $Sprite2D
		remove_child(old_sprite)
		old_sprite.queue_free()
	
	_sprite = _SPRITE_SCRIPT.create_robot_sprite("tough", team_id)
	add_child(_sprite)
	_sprite.play("walk")


func _process(delta: float) -> void:
	super._process(delta)
	last_fired += delta

	if last_fired >= fire_rate:
		var target = find_nearest_enemy()
		if target and global_position.distance_to(target.global_position) < 180:
			CombatManager.fire_projectile(global_position, target.global_position, damage, self)
			last_fired = 0.0


