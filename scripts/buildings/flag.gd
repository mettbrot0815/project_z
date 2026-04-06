extends StaticBody2D

# Flag node - captures territories when touched by friendly units

@export var territory_id: int = 0
var team_owner: int = 0  # 0=NEUTRAL, 1=RED, 2=BLUE

signal captured(new_owner: int)

var _sprite: AnimatedSprite2D


func _ready() -> void:
	add_to_group("flag")
	var area = $Area2D
	if area:
		area.body_entered.connect(_on_body_entered)
	
	_sprite = $AnimatedSprite2D
	_update_flag_sprite()


func _update_flag_sprite() -> void:
	if not _sprite:
		return
	
	var frames = SpriteFrames.new()
	frames.add_animation("idle")
	
	# Load flag frames based on team color
	var color_name = _team_to_color_name(team_owner)
	for i in range(4):
		var path = "res://assets/sprites/buildings/fort/flag_%s_n%02d.png" % [color_name, i]
		var texture = load(path) if ResourceLoader.exists(path) else null
		if texture:
			frames.add_frame("idle", texture)
	
	# Fallback if no frames loaded
	if frames.get_frame_count("idle") == 0:
		# Create a simple colored placeholder
		var placeholder = _create_placeholder_texture(_team_to_color(team_owner))
		frames.add_frame("idle", placeholder)
	
	_sprite.sprite_frames = frames
	_sprite.animation = "idle"
	_sprite.play()


func _team_to_color_name(team: int) -> String:
	match team:
		1: return "red"
		2: return "blue"
		_: return "green"  # Neutral


func _team_to_color(team: int) -> Color:
	match team:
		1: return Color(1, 0, 0)  # Red
		2: return Color(0, 0, 1)  # Blue
		_: return Color(0, 1, 0)  # Green


func _create_placeholder_texture(color: Color) -> ImageTexture:
	var image = Image.create(32, 32, false, Image.FORMAT_RGBA8)
	image.fill(color)
	var texture = ImageTexture.create_from_image(image)
	return texture


func get_team_id() -> int:
	return team_owner


func _on_body_entered(body: Node2D) -> void:
	if body.has_method("get_team_id"):
		var unit_owner = body.get_team_id()
		if unit_owner in [TerritoryManager.Owner.RED, TerritoryManager.Owner.BLUE]:
			if team_owner != unit_owner:
				capture(unit_owner)


func capture(new_owner: int) -> void:
	team_owner = new_owner
	_update_flag_sprite()
	captured.emit(new_owner)

