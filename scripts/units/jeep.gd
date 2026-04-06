extends VehicleBase

# Jeep - fast scout vehicle, intelligence 2

const _SPRITE_SCRIPT = preload("res://scripts/core/sprite_manager.gd")

func _ready() -> void:
	super._ready()
	max_hp = 80
	hp = 80
	damage = 10
	move_speed = 220
	intelligence = 2
	unit_type = "jeep"
	fire_rate = 0.5
	has_driver = true
	
	_setup_sprite()


func _setup_sprite() -> void:
	if has_node("Sprite2D"):
		var old_sprite = $Sprite2D
		remove_child(old_sprite)
		old_sprite.queue_free()
	
	_sprite = _SPRITE_SCRIPT.create_vehicle_sprite("jeep", team_id)
	add_child(_sprite)
	_sprite.play("base")


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


func die(killer: Node2D) -> void:
	CombatManager.apply_splash_damage(global_position, 32, damage, killer)
	super.die(killer)


