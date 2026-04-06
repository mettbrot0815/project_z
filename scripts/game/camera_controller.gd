extends Camera2D

@export var pan_speed: float = 600.0
@export var zoom_speed: float = 0.1
@export var min_zoom: float = 0.5
@export var max_zoom: float = 2.0
@export var edge_scroll_margin: float = 40.0
@export var enable_edge_scroll: bool = true

var target_zoom: float = 1.0
var viewport_size: Vector2


func _ready() -> void:
	viewport_size = get_viewport_rect().size
	target_zoom = zoom.x
	set_process_input(true)


func _process(delta: float) -> void:
	var movement := Vector2.ZERO
	
	# Keyboard pan
	if Input.is_action_pressed("move_left"):
		movement.x -= 1.0
	if Input.is_action_pressed("move_right"):
		movement.x += 1.0
	if Input.is_action_pressed("move_up"):
		movement.y -= 1.0
	if Input.is_action_pressed("move_down"):
		movement.y += 1.0
	
	# Edge scroll
	if enable_edge_scroll:
		var mouse_pos := get_viewport().get_mouse_position()
		if mouse_pos.x < edge_scroll_margin:
			movement.x -= 1.0
		elif mouse_pos.x > viewport_size.x - edge_scroll_margin:
			movement.x += 1.0
		if mouse_pos.y < edge_scroll_margin:
			movement.y -= 1.0
		elif mouse_pos.y > viewport_size.y - edge_scroll_margin:
			movement.y += 1.0
	
	# Normalize diagonal movement
	if movement.length() > 0:
		movement = movement.normalized()
		position += movement * pan_speed * delta / zoom.x
	
	# Smooth zoom interpolation
	if not is_equal_approx(zoom.x, target_zoom):
		zoom = zoom.lerp(Vector2(target_zoom, target_zoom), delta * 8.0)


func _input(event: InputEvent) -> void:
	# Mouse wheel zoom
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			target_zoom = clamp(target_zoom + zoom_speed, min_zoom, max_zoom)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			target_zoom = clamp(target_zoom - zoom_speed, min_zoom, max_zoom)

