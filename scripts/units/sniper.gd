extends UnitBase

# Sniper - high damage, long range, prioritizes vehicle drivers

var last_fired: float = 0.0
const FIRE_RATE = 2.2
const RANGE = 400.0


func _ready() -> void:
	super._ready()
	max_hp = 45
	hp = 45
	damage = 75
	move_speed = 85
	intelligence = 3
	unit_type = "sniper"


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


func find_nearest_enemy() -> Node2D:
	var enemies = get_tree().get_nodes_in_group("selectable").filter(func(unit):
		return unit.team != owner and unit.hp > 0 and unit != self
	)
	
	if enemies.size() == 0:
		return null
	
	enemies.sort_custom(func(a, b):
		return global_position.distance_to(a.global_position) < global_position.distance_to(b.global_position)
	)
	
	return enemies[0]
