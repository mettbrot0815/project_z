extends VehicleBase

# Crane - repair vehicle, fixes damage, intelligence 3

@export var repair_rate: float = 20.0
@export var repair_range: float = 80.0

var target_to_repair: Node2D = null


func _ready() -> void:
	super._ready()
	max_hp = 120
	hp = 120
	damage = 5
	move_speed = 110
	intelligence = 3
	unit_type = "crane"
	has_driver = true


func _process(delta: float) -> void:
	super._process(delta)

	if not driver_alive:
		return

	# Find damaged allies to repair
	if not target_to_repair or target_to_repair.hp >= target_to_repair.max_hp:
		target_to_repair = find_damaged_ally()

	if target_to_repair and global_position.distance_to(target_to_repair.global_position) <= repair_range:
		# Repair the target
		target_to_repair.hp = min(target_to_repair.hp + repair_rate * delta, target_to_repair.max_hp)
		# Stop moving while repairing
		velocity = Vector2.ZERO
	else:
		# Move towards target
		if target_to_repair:
			move_to(target_to_repair.global_position)


func find_damaged_ally() -> Node2D:
	var damaged_allies = get_tree().get_nodes_in_group("selectable").filter(func(unit):
		return unit.team == owner and unit.hp < unit.max_hp and unit != self
	)

	if damaged_allies.size() == 0:
		return null

	damaged_allies.sort_custom(func(a, b):
		var a_damage_percent = (a.max_hp - a.hp) / float(a.max_hp)
		var b_damage_percent = (b.max_hp - b.hp) / float(b.max_hp)
		return a_damage_percent > b_damage_percent  # Most damaged first
	)

	return damaged_allies[0]


func die(killer: Node2D) -> void:
	CombatManager.apply_splash_damage(global_position, 48, damage, killer)
	super.die(killer)