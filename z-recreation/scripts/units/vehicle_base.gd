extends unit_base

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
	driver_hitbox.body_entered.connect(_on_driver_hit)


func take_damage(amount: float, attacker: Node2D) -> void:
	# If driver was hit directly
	if attacker and attacker.global_position.distance_to(global_position + driver_hitbox_offset) < 16:
		if driver_alive and has_driver:
			kill_driver()
			return
	
	super.take_damage(amount, attacker)


func kill_driver() -> void:
	driver_alive = false
	owner = Owner.NEUTRAL
	driver_killed.emit()
	
	# Eject driver sprite
	var driver_scene = load("res://scenes/units/driver.tscn")
	if driver_scene:
		var driver = driver_scene.instantiate()
		driver.global_position = global_position + driver_hitbox_offset
		driver.velocity = Vector2(RANDF_RANGE(-80, 80), -150)
		get_parent().add_child(driver)
	
	# Vehicle becomes instantly claimable by any player
	set_process_internal(false)
	navigation_agent.target_position = global_position
	velocity = Vector2.ZERO


func _on_driver_hit(body: Node2D) -> void:
	if body.is_in_group("projectile"):
		if driver_alive:
			kill_driver()
			body.queue_free()


func can_be_captured() -> bool:
	return has_driver and not driver_alive and owner == Owner.NEUTRAL


func capture(new_owner: Owner) -> void:
	if can_be_captured():
		owner = new_owner
		driver_alive = true
		set_process_internal(intelligence > 0)
