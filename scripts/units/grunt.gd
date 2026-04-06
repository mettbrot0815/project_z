extends UnitBase

# Grunt - lowest intelligence, fastest, weakest

var _sprite: AnimatedSprite2D

func _ready() -> void:
	super._ready()
	max_hp = 50
	hp = 50
	damage = 8
	move_speed = 140
	intelligence = 0
	unit_type = "grunt"
	fire_rate = 0.8
	
	_setup_sprite()


func _setup_sprite() -> void:
	# Remove existing Sprite2D if present
	if has_node("Sprite2D"):
		var old_sprite = $Sprite2D
		remove_child(old_sprite)
		old_sprite.queue_free()
	
	# Create AnimatedSprite2D with walk animation
	_sprite = SpriteManager.create_robot_sprite("grunt", team_id)
	add_child(_sprite)
	
	# Set animation speed (10 FPS = 0.1 seconds per frame)
	_sprite.speed_scale = 2.0  # Adjust for visual speed
	_sprite.play("walk")


func _process(delta: float) -> void:
	super._process(delta)
	
	# Auto attack nearby enemies
	var nearest_enemy = find_nearest_enemy()
	if nearest_enemy and global_position.distance_to(nearest_enemy.global_position) < 150:
		attack(nearest_enemy)
