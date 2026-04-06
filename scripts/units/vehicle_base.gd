class_name VehicleBase
extends UnitBase

# Base class for all vehicles including driver sniping mechanic
# Original Z behavior: Driver can be shot out, vehicle becomes neutral

@export var has_driver: bool = true
@export var driver_hitbox_offset: Vector2 = Vector2.ZERO

signal driver_killed()

var driver_alive: bool = true
var driver_hitbox: Area2D


func _ready() -> void:
	super._ready()
	driver_hitbox = $DriverHitbox
	if driver_hitbox:
		driver_hitbox.body_entered.connect(_on_driver_hit)


func take_damage(amount: float, attacker: Node2D) -> void:
	# If driver was hit directly
	if attacker and attacker.global_position.distance_to(global_position + driver_hitbox_offset) < 16:
		if driver_alive and has_driver:
			kill_driver()
			return

	super.take_damage(amount, attacker)
	update_damage_visuals()


func kill_driver() -> void:
	driver_alive = false
	team = Team.NEUTRAL
	team_id = TerritoryManager.Owner.NEUTRAL
	driver_killed.emit()
	
	# Eject driver sprite
	var driver_scene = load("res://scenes/units/driver.tscn")
	if driver_scene == null:
		push_error("VehicleBase: Failed to load driver scene")
	else:
		var driver = driver_scene.instantiate()
		if driver == null:
			push_error("VehicleBase: Failed to instantiate driver")
		else:
			driver.global_position = global_position + driver_hitbox_offset
			driver.velocity = Vector2(randf_range(-80, 80), -150)
			get_parent().add_child(driver)
	
	# Vehicle becomes instantly claimable by any player
	set_process_internal(false)
	if navigation_agent:
		navigation_agent.target_position = global_position
	velocity = Vector2.ZERO


func _on_driver_hit(body: Node2D) -> void:
	if body.is_in_group("projectile"):
		if driver_alive:
			kill_driver()
			body.queue_free()


func can_be_captured() -> bool:
	return has_driver and not driver_alive and team == Team.NEUTRAL


func capture(new_owner: Team) -> void:
	if can_be_captured():
		team_id = new_owner
		team = new_owner
		driver_alive = true
		set_process_internal(intelligence > 0)


func update_damage_visuals() -> void:
	if max_hp <= 0:
		return
	var damage_percent = (max_hp - hp) / max_hp

	if damage_percent < 0.3:
		set_damage_state(0)
	elif damage_percent < 0.6:
		set_damage_state(1)
	elif damage_percent < 0.9:
		set_damage_state(2)
	else:
		set_damage_state(3)


func set_damage_state(state: int) -> void:
	match state:
		0:
			print("%s: No damage" % unit_type)
		1:
			print("%s: Smoking" % unit_type)
		2:
			print("%s: On fire" % unit_type)
		3:
			print("%s: Critical damage" % unit_type)
