extends VehicleBase

# Jeep - fast scout vehicle, intelligence 2

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
