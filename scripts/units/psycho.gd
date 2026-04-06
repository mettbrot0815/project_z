extends UnitBase

# Psycho - rapid fire, machine gun, intelligence 1

var _sprite: AnimatedSprite2D

func _ready() -> void:
	super._ready()
	max_hp = 65
	hp = 65
	damage = 6
	move_speed = 120
	intelligence = 1
	unit_type = "psycho"
	fire_rate = 0.15
	
	_setup_sprite()


func _setup_sprite() -> void:
	if has_node("Sprite2D"):
		var old_sprite = $Sprite2D
		remove_child(old_sprite)
		old_sprite.queue_free()
	
	_sprite = SpriteManager.create_robot_sprite("psycho", team_id)
	add_child(_sprite)
	_sprite.play("walk")


func _process(delta: float) -> void:
	super._process(delta)
	last_fired += delta

	if last_fired >= fire_rate:
		var target = find_nearest_enemy()
		if target and global_position.distance_to(target.global_position) < 200:
			CombatManager.fire_projectile(global_position, target.global_position, damage, self)
			last_fired = 0.0
