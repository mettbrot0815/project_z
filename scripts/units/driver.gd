class_name Driver
extends CharacterBody2D

# Driver for vehicles - ejected when driver is sniped

@export var move_speed: float = 80.0

var owner: int = 0  # Team owner (0=NEUTRAL, 1=RED, 2=BLUE)
var team: int = 0
var hp: float = 20.0
var max_hp: float = 20.0


func _ready() -> void:
	# Set team based on owner
	if owner == 1:
		team = TerritoryManager.Owner.RED
	elif owner == 2:
		team = TerritoryManager.Owner.BLUE
	else:
		team = TerritoryManager.Owner.NEUTRAL


func _physics_process(delta: float) -> void:
	if hp <= 0:
		return
	
	# Drivers try to run away when ejected
	velocity = velocity.lerp(Vector2.DOWN * 500, delta * 10)
	move_and_slide()


func take_damage(amount: float, attacker: Node2D) -> void:
	hp -= amount
	if hp <= 0:
		die(attacker)


func die(killer: Node2D) -> void:
	# Driver dies, vehicle becomes neutral
	if killer:
		killer.emit_signal("driver_killed")
	queue_free()
