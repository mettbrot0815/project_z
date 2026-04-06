class_name FlyingTurret
extends CharacterBody2D

# Flying turret effect - explodes when tank dies

var velocity_vector: Vector2 = Vector2.ZERO
var life_time: float = 2.0
var timer: float = 0.0

const GRAVITY = 800.0


func _ready() -> void:
	# Turret has no AI, just falls and explodes
	pass


func _physics_process(delta: float) -> void:
	if life_time <= 0:
		queue_free()
		return
	
	# Apply gravity
	velocity_vector.y += GRAVITY * delta
	velocity_vector = velocity_vector.limit_length(500)
	
	# Move turret
	global_position += velocity_vector * delta
	
	# Fall to ground
	if global_position.y > 1000:  # Ground level
		impact()
		queue_free()
	
	life_time -= delta


func impact() -> void:
	# Explode on impact - do splash damage
	if CombatManager:
		CombatManager.apply_splash_damage(global_position, 64, 50, null)
