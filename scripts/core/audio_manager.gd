extends Node

# Audio Manager - Centralized audio playback for Z (1996)
# Autoload singleton: AudioManager

var master_volume: float = 1.0
var sfx_volume: float = 1.0
var music_volume: float = 0.7
var voice_volume: float = 1.0

var _sfx_player: AudioStreamPlayer
var _sfx_player_2: AudioStreamPlayer
var _sfx_player_3: AudioStreamPlayer
var _music_player: AudioStreamPlayer
var _voice_player: AudioStreamPlayer
var _ambient_player: AudioStreamPlayer

var _current_music: String = ""
var _music_fade_tween: Tween

const MAX_SFX_PLAYERS: int = 3

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_setup_audio_players()

func _setup_audio_players() -> void:
	_sfx_player = AudioStreamPlayer.new()
	_sfx_player.bus = "Master"
	add_child(_sfx_player)
	
	_sfx_player_2 = AudioStreamPlayer.new()
	_sfx_player_2.bus = "Master"
	add_child(_sfx_player_2)
	
	_sfx_player_3 = AudioStreamPlayer.new()
	_sfx_player_3.bus = "Master"
	add_child(_sfx_player_3)
	
	_music_player = AudioStreamPlayer.new()
	_music_player.bus = "Master"
	_music_player.volume_db = -6
	add_child(_music_player)
	
	_voice_player = AudioStreamPlayer.new()
	_voice_player.bus = "Master"
	add_child(_voice_player)
	
	_ambient_player = AudioStreamPlayer.new()
	_ambient_player.bus = "Master"
	_ambient_player.volume_db = -12
	add_child(_ambient_player)

func play_sound(sound_name: String, volume_db: float = 0.0, pitch_scale: float = 1.0) -> void:
	var sound_path = "res://assets/audio/sfx/%s.ogg" % sound_name
	
	if not ResourceLoader.exists(sound_path):
		sound_path = "res://assets/audio/sfx/%s.wav" % sound_name
	
	if not ResourceLoader.exists(sound_path):
		return
	
	var stream = load(sound_path)
	if stream == null:
		return
	
	var player = _get_available_sfx_player()
	if player == null:
		return
	
	player.stream = stream
	player.volume_db = volume_db * sfx_volume * master_volume
	player.pitch_scale = pitch_scale + randf_range(-0.1, 0.1)
	player.play()

func _get_available_sfx_player() -> AudioStreamPlayer:
	if not _sfx_player.playing:
		return _sfx_player
	if not _sfx_player_2.playing:
		return _sfx_player_2
	if not _sfx_player_3.playing:
		return _sfx_player_3
	return null

func play_music(track_path: String, fade_in: bool = true) -> void:
	if _current_music == track_path and _music_player.playing:
		return
	
	if not ResourceLoader.exists(track_path):
		return
	
	_music_fade_tween = null
	
	_music_player.stream = load(track_path)
	_current_music = track_path
	
	if fade_in:
		_music_player.volume_db = -80
		_music_player.play()
		_music_fade_tween = create_tween()
		_music_fade_tween.tween_property(_music_player, "volume_db", linear_to_db(music_volume * master_volume), 2.0)
	else:
		_music_player.volume_db = linear_to_db(music_volume * master_volume)
		_music_player.play()

func stop_music(fade_out: bool = true) -> void:
	if not _music_player.playing:
		return
	
	if fade_out and _music_fade_tween == null:
		_music_fade_tween = create_tween()
		_music_fade_tween.tween_property(_music_player, "volume_db", -80, 1.0)
		_music_fade_tween.tween_callback(_music_player.stop)
	else:
		_music_player.stop()

func play_game_music() -> void:
	var tracks = [
		"res://assets/audio/music/action_loop.ogg",
		"res://assets/audio/music/battle_theme.ogg"
	]
	
	for track in tracks:
		if ResourceLoader.exists(track):
			play_music(track)
			return
	
	_ambient_player.playing = true

func play_menu_music() -> void:
	var menu_track = "res://assets/audio/music/menu_theme.ogg"
	if ResourceLoader.exists(menu_track):
		play_music(menu_track)
	else:
		_ambient_player.playing = true

func play_voice_bark(bark_type: String, team: int, force: bool = false) -> void:
	if not force and randf() > 0.1:
		return
	
	var team_prefix = "neutral"
	match team:
		1: team_prefix = "red"
		2: team_prefix = "blue"
	
	var bark_path = "res://assets/audio/voices/%s/%s_%d.ogg" % [bark_type, team_prefix, randi() % 3]
	
	if not ResourceLoader.exists(bark_path):
		bark_path = "res://assets/audio/voices/%s/%s.ogg" % [bark_type, team_prefix]
	
	if not ResourceLoader.exists(bark_path):
		return
	
	var stream = load(bark_path)
	if stream == null:
		return
	
	_voice_player.stream = stream
	_voice_player.volume_db = linear_to_db(voice_volume * master_volume)
	_voice_player.play()

func set_master_volume(vol: float) -> void:
	master_volume = clamp(vol, 0.0, 1.0)
	_update_volumes()

func set_sfx_volume(vol: float) -> void:
	sfx_volume = clamp(vol, 0.0, 1.0)
	_update_volumes()

func set_music_volume(vol: float) -> void:
	music_volume = clamp(vol, 0.0, 1.0)
	if _music_player.playing:
		_music_player.volume_db = linear_to_db(music_volume * master_volume)

func set_voice_volume(vol: float) -> void:
	voice_volume = clamp(vol, 0.0, 1.0)

func _update_volumes() -> void:
	if _music_player.playing:
		_music_player.volume_db = linear_to_db(music_volume * master_volume)

func play_fire_sound(unit_type: String) -> void:
	match unit_type:
		"grunt", "psycho":
			play_sound("gunshot_light", -3.0, 1.0)
		"sniper", "laser":
			play_sound("gunshot_heavy", -1.0, 0.9)
		"gatling":
			play_sound("gatling_fire", -6.0, 1.2)
		"howitzer":
			play_sound("cannon_fire", 2.0, 0.8)
		"missile_launcher":
			play_sound("missile_launch", 0.0, 0.9)
		"light_tank", "medium_tank", "heavy_tank":
			play_sound("tank_fire", 0.0, 0.95)
		"jeep":
			play_sound("jeep_fire", -4.0, 1.1)
		_:
			play_sound("gunshot_default", -2.0, 1.0)

func play_explosion(size: float = 1.0) -> void:
	if size > 1.5:
		play_sound("explosion_large", 3.0, 0.85)
	elif size > 0.8:
		play_sound("explosion_medium", 0.0, 0.9)
	else:
		play_sound("explosion_small", -3.0, 1.0)

func play_unit_death() -> void:
	play_sound("unit_death", 0.0, 0.9)

func play_vehicle_explosion() -> void:
	play_sound("vehicle_explosion", 2.0, 0.85)
	play_sound("metal_crash", -2.0, 1.1)

func play_ui_select() -> void:
	play_sound("ui_select", -6.0, 1.2)

func play_ui_click() -> void:
	play_sound("ui_click", -8.0, 1.3)

func play_territory_capture() -> void:
	play_sound("territory_capture", -2.0, 1.0)

func play_button_click() -> void:
	play_sound("button_click", -8.0, 1.4)
