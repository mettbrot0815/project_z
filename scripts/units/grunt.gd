extends UnitBase

# Grunt - lowest intelligence, fastest, weakest

func _ready() -> void:
	super._ready()
	max_hp = 50
	hp = 50
	damage = 8
	move_speed = 140
	intelligence = 0
	unit_type = "grunt"
	fire_rate = 0.8
	last_fired = 0.0


func _process(delta: float) -> void:
	super._process(delta)
	
	# Auto attack nearby enemies
	var nearest_enemy = find_nearest_enemy()
	if nearest_enemy and global_position.distance_to(nearest_enemy.global_position) < 150:
		attack(nearest_enemy)


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
