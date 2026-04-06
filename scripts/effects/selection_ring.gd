extends Node2D

# Selection ring effect - visual indicator for selected units

var _ring: Line2D
var _radius: float = 24.0
var _color: Color = Color(0.3, 0.9, 1.0, 0.8)
var _pulse_time: float = 0.0
var _is_player: bool = true

func _ready() -> void:
	_setup_ring()
	_pulse_time = randf() * TAU

func _setup_ring() -> void:
	_ring = Line2D.new()
	_ring.width = 2.0
	_ring.default_color = _color
	_ring.joint_mode = Line2D.LINE_JOINT_ROUND
	_ring.begin_cap_mode = Line2D.LINE_CAP_ROUND
	_ring.end_cap_mode = Line2D.LINE_CAP_ROUND
	
	var points: PackedVector2Array = PackedVector2Array()
	var segments = 32
	for i in range(segments + 1):
		var angle = (float(i) / segments) * TAU
		points.append(Vector2(cos(angle) * _radius, sin(angle) * _radius))
	_ring.points = points
	
	add_child(_ring)

func set_team(is_player_team: bool) -> void:
	_is_player = is_player_team
	if _is_player:
		_color = Color(0.3, 0.9, 1.0, 0.8)
	else:
		_color = Color(1.0, 0.3, 0.3, 0.8)
	_ring.default_color = _color

func _process(delta: float) -> void:
	_pulse_time += delta * 3.0
	var pulse = 0.8 + 0.2 * sin(_pulse_time)
	_ring.default_color.a = pulse * 0.8

func _exit_tree() -> void:
	_ring.queue_free()
