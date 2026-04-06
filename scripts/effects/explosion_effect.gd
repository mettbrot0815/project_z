extends Node2D

# Explosion effect - visual particles + sound

var _particles: CPUParticles2D
var _light: PointLight2D
var _scale: float = 1.0

func _ready() -> void:
	_setup_particles()
	_setup_light()

func _setup_particles() -> void:
	_particles = CPUParticles2D.new()
	_particles.emitting = false
	_particles.amount = 20
	_particles.lifetime = 0.5
	_particles.explosiveness = 0.8
	_particles.randomness = 0.3
	_particles.direction = Vector2(0, 0)
	_particles.spread = 180
	_particles.initial_velocity_min = 80
	_particles.initial_velocity_max = 200
	_particles.gravity = Vector2(0, 200)
	_particles.scale = Vector2(_scale, _scale)
	
	var color_ramp = Gradient.new()
	color_ramp.set_color(0, Color(1.0, 0.8, 0.3))
	color_ramp.set_color(0.3, Color(1.0, 0.4, 0.1))
	color_ramp.set_color(0.7, Color(0.6, 0.2, 0.1))
	color_ramp.set_color(1.0, Color(0.2, 0.1, 0.05))
	_particles.color_ramp = color_ramp
	
	add_child(_particles)

func _setup_light() -> void:
	_light = PointLight2D.new()
	_light.enabled = false
	_light.energy = 2.0
	_light.radius = 100
	_light.color = Color(1.0, 0.6, 0.2)
	_light.shadow_enabled = false
	add_child(_light)

func explode(position: Vector2, scale: float = 1.0, damage_size: float = 1.0) -> void:
	global_position = position
	_scale = scale
	
	# Create scale vector from the scalar value
	var scale_vec = Vector2(_scale, _scale)
	
	_particles.amount = int(20 * damage_size)
	_particles.initial_velocity_min = 80 * damage_size
	_particles.initial_velocity_max = 200 * damage_size
	_particles.scale = scale_vec
	
	_light.radius = 100 * _scale
	_light.enabled = true
	
	AudioManager.play_explosion(damage_size)
	
	_particles.emitting = true
	
	await get_tree().create_timer(0.3).timeout
	_light.enabled = false
	
	await get_tree().create_timer(0.3).timeout
	queue_free()

func _exit_tree() -> void:
	if _particles:
		_particles.emitting = false
