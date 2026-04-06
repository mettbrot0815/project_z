# SpriteUtils - Centralized sprite path resolution for Z (1996) assets
# Maps Godot Team enum to original Z sprite colors

# Base path to copied Z (1996) sprite assets
const ASSET_BASE_PATH = "res://assets/sprites/"

# Maps Godot Team enum to zod_engine sprite color names
static func team_to_color(team: int) -> String:
	match team:
		1: return "red"    # Player (RED team)
		2: return "blue"   # AI opponent (BLUE team)
		_: return "green"  # Neutral


# Load a sprite texture, returns null if not found
static func load_sprite_texture(path: String) -> Texture2D:
	if ResourceLoader.exists(path):
		return load(path)
	return null


# Create AnimatedSprite2D with walk animation for a robot unit
static func create_robot_sprite(unit_type: String, team: int) -> AnimatedSprite2D:
	var sprite = AnimatedSprite2D.new()
	sprite.name = "UnitSprite"
	
	var frames = SpriteFrames.new()
	var color = team_to_color(team)
	
	# Walk animation: walk_{color}_r000_n{00-03}.png (in root robots folder)
	frames.add_animation("walk")
	for i in range(4):
		var full_path = ASSET_BASE_PATH + "robots/walk_%s_r000_n%02d.png" % [color, i]
		var texture = load_sprite_texture(full_path)
		if texture:
			frames.add_frame("walk", texture)
	
	# Fire animation: {unit_type}/fire_{color}_r000_n{00-04}.png (in unit subfolder)
	frames.add_animation("fire")
	for i in range(5):
		var full_path = ASSET_BASE_PATH + "robots/%s/fire_%s_r000_n%02d.png" % [unit_type, color, i]
		var texture = load_sprite_texture(full_path)
		if texture:
			frames.add_frame("fire", texture)
	
	# Fallback: if no frames loaded, create a placeholder
	if frames.get_frame_count("walk") == 0:
		var placeholder = create_placeholder_texture(Color(1, 0, 0))  # Red
		frames.add_frame("walk", placeholder)
	
	sprite.sprite_frames = frames
	sprite.animation = "walk"
	sprite.play()  # Use play() method instead of playing = true
	sprite.centered = true
	sprite.offset = Vector2(0, 0)
	
	return sprite


# Create a simple colored placeholder texture
static func create_placeholder_texture(color: Color) -> ImageTexture:
	var image = Image.create(32, 32, false, Image.FORMAT_RGBA8)
	image.fill(color)
	var texture = ImageTexture.create_from_image(image)
	return texture


# Create AnimatedSprite2D with base/damaged animations for a vehicle
static func create_vehicle_sprite(unit_type: String, team: int) -> AnimatedSprite2D:
	var sprite = AnimatedSprite2D.new()
	sprite.name = "UnitSprite"
	
	var frames = SpriteFrames.new()
	var color = team_to_color(team)
	var base_path = ASSET_BASE_PATH + "vehicles/%s/" % unit_type
	
	# Base animation: base_{color}_r000_n{00-02}.png
	frames.add_animation("base")
	for i in range(3):
		var full_path = base_path + "base_%s_r000_n%02d.png" % [color, i]
		var texture = load_sprite_texture(full_path)
		if texture:
			frames.add_frame("base", texture)
	
	# Damaged animation: base_damaged_{color}_r000_n{00-02}.png
	frames.add_animation("damaged")
	for i in range(3):
		var full_path = base_path + "base_damaged_%s_r000_n%02d.png" % [color, i]
		var texture = load_sprite_texture(full_path)
		if texture:
			frames.add_frame("damaged", texture)
	
	# Fallback: if no frames loaded, create a placeholder
	if frames.get_frame_count("base") == 0:
		var placeholder = create_placeholder_texture(Color(0, 0, 1))  # Blue
		frames.add_frame("base", placeholder)
	
	sprite.sprite_frames = frames
	sprite.animation = "base"
	sprite.play()  # Use play() method instead of playing = true
	sprite.centered = true
	sprite.offset = Vector2(0, 0)
	
	return sprite

