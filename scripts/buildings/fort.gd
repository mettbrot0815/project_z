extends Node2D

# Fort - main base, victory condition when destroyed

@export var max_hp: float = 1000
@export var team_owner: int = TerritoryManager.Team.NEUTRAL

var hp: float = max_hp
var corner_turrets: Array = []

signal destroyed(by_owner: int)
signal damaged(amount: float, attacker: Node2D)


func _ready() -> void:
	add_to_group("fort")
	add_to_group("building")
	
	# Create corner turrets
	for i in range(4):
		var turret_angle = i * PI/2
		var turret_pos = Vector2(cos(turret_angle), sin(turret_angle)) * 120
		
		var turret_scene = load("res://scenes/units/gatling.tscn")
		if turret_scene:
			var turret = turret_scene.instantiate()
			turret.global_position = global_position + turret_pos
			turret.team = team_owner
			get_parent().add_child(turret)
			corner_turrets.append(turret)


func take_damage(amount: float, attacker: Node2D) -> void:
	hp -= amount
	damaged.emit(amount, attacker)
	
	if hp <= 0:
		destroy(attacker)


func destroy(attacker: Node2D) -> void:
	# Massive explosion
	CombatManager.apply_splash_damage(global_position, 300, 200, attacker)
	
	# Destroy corner turrets
	for turret in corner_turrets:
		if turret and turret.hp > 0:
			turret.take_damage(9999, attacker)
	
	destroyed.emit(attacker.get_team() if attacker.has_method("get_team") else TerritoryManager.Team.NEUTRAL)
	queue_free()


func get_hp_percentage() -> float:
	return hp / max_hp


func can_enter(unit: Node2D) -> bool:
	# Units can enter enemy fort to destroy it
	return unit.team != team_owner