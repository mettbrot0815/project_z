extends UnitBase

# Tough - high HP, slow, powerful shots, intelligence 2

func _ready() -> void:
	super._ready()
	max_hp = 100
	hp = 100
	damage = 12
	move_speed = 90
	intelligence = 2
	unit_type = "tough"
	fire_rate = 0.6


func _process(delta: float) -> void:
	super._process(delta)
	last_fired += delta

	if last_fired >= fire_rate:
		var target = find_nearest_enemy()
		if target and global_position.distance_to(target.global_position) < 180:
			CombatManager.fire_projectile(global_position, target.global_position, damage, self)
			last_fired = 0.0
