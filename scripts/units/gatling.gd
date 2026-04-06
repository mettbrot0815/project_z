extends UnitBase

# Gatling Gun - stationary, rapid fire, auto-tracking

@export var turret_rotation_speed: float = 2.0
@export var range: float = 250.0

var target_rotation: float = 0.0
var current_rotation: float = 0.0
var _sprite: AnimatedSprite2D


func _ready() -> void:
	super._ready()
	max_hp = 100
	hp = 100
	damage = 5
	intelligence = 0
	unit_type = "gatling"
	fire_rate = 0.08
	move_speed = 0
	
	_setup_sprite()


func _setup_sprite() -> void:
	if has_node("Sprite2D"):
		var old_sprite = $Sprite2D
		remove_child(old_sprite)
		old_sprite.queue_free()
	
	_sprite = SpriteManager.create_robot_sprite("gatling", team_id)
	add_child(_sprite)
	_sprite.play("walk")


func _process(delta: float) -> void:
	super._process(delta)

	var target = find_nearest_enemy()
	if target and global_position.distance_to(target.global_position) <= range:
		var target_dir = (target.global_position - global_position).normalized()
		target_rotation = target_dir.angle()
		
		var angle_diff = angle_difference(current_rotation, target_rotation)
		current_rotation += sign(angle_diff) * min(abs(angle_diff), turret_rotation_speed * delta)
		
		if abs(angle_difference(current_rotation, target_rotation)) < 0.1:
			last_fired += delta
			if last_fired >= fire_rate:
				CombatManager.fire_projectile(global_position, target.global_position, damage, self)
				last_fired = 0.0
	else:
		last_fired = 0.0
