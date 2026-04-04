extends CharacterBody2D

# Base unit class for all robots, vehicles, and guns

enum Owner { NEUTRAL, RED, BLUE }

@export var max_hp: float = 100.0
@export var damage: float = 10.0
@export var move_speed: float = 100.0
@export var intelligence: int = 0 # 0-5 scale: lower = dumber
@export var unit_type: String = "robot"

signal died(killer: Node2D)
signal owner_changed(new_owner: Owner)

var hp: float = max_hp
var owner: Owner = Owner.NEUTRAL:
	set(value):
		owner = value
		owner_changed.emit(value)

var current_order: Dictionary = {}
var target: Node2D = null

var navigation_agent: NavigationAgent2D


func _ready() -> void:
	navigation_agent = $NavigationAgent2D
	navigation_agent.max_speed = move_speed
	
	if intelligence > 0:
		set_process_internal(true)


func _physics_process(delta: float) -> void:
	if hp <= 0:
		return
	
	if navigation_agent.is_navigation_finished():
		return
	
	var next_pos = navigation_agent.get_next_path_position()
	velocity = global_position.direction_to(next_pos) * move_speed
	move_and_slide()


func move_to(target_position: Vector2) -> void:
	navigation_agent.target_position = target_position


func attack(target_unit: Node2D) -> void:
	target = target_unit
	# Implement attack logic
	pass


func take_damage(amount: float, attacker: Node2D) -> void:
	hp -= amount
	if hp <= 0:
		die(attacker)


func die(killer: Node2D) -> void:
	died.emit(killer)
	queue_free()


func get_owner() -> Owner:
	return owner


# Intelligence based autonomous AI
func _process(_delta: float) -> void:
	if owner == Owner.NEUTRAL:
		return
	
	match intelligence:
		0: # Grunt: only rush flags
			_find_nearest_flag()
		1: # Psycho: attack nearest enemy
			_find_nearest_enemy()
		2: # Tough: attack vehicles
			_find_nearest_vehicle()
		3: # Sniper: prioritize drivers
			_find_nearest_driver()
		4: # Elite: avoid danger
			_avoid_threats()
		5: # Commander: strategic decisions
			_strategic_behaviour()


func _find_nearest_flag() -> void:
	pass


func _find_nearest_enemy() -> void:
	pass


func _find_nearest_vehicle() -> void:
	pass


func _find_nearest_driver() -> void:
	pass


func _avoid_threats() -> void:
	pass


func _strategic_behaviour() -> void:
	pass
