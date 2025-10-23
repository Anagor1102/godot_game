extends Node

var player_current_attack = false
var current_score = 0
var up = false
var down = false
var left = false
var right = false

var music_volume: float = 0.8
var sound_volume: float = 0.8
var music_player: AudioStreamPlayer
var sound_players: Dictionary = {}

signal music_volume_changed(volume)
signal sound_volume_changed(volume)

func _ready():
	preload_all_sounds()
	# Загружаем настройки из конфига
	load_settings()
	
	
func preload_all_sounds():
	# Создаем AudioStreamPlayer для музыки
	music_player = AudioStreamPlayer.new()
	music_player.name = "BackgroundMusic"
	music_player.stream = preload("res://background.mp3") 
	music_player.stream.loop = true
	music_player.process_mode = AudioStreamPlayer.PROCESS_MODE_ALWAYS
	music_player.volume_db = linear_to_db(music_volume)
	music_player.bus = "Music"
	add_child(music_player)


	var sound_files = {
		"attack": "res://attack.mp3",
		"hurt": "res://hurt.mp3",
		"regen": "res://heal.mp3",
		"click": "res://click.ogg",
		"slimeDeath": "res://slime_death.mp3"
	}
	
	for sound_name in sound_files:
		var sound_path = sound_files[sound_name]
		var sound_player = AudioStreamPlayer.new()
		sound_player.name = sound_name + "Sound"
		sound_player.process_mode = AudioStreamPlayer.PROCESS_MODE_ALWAYS
		
		if ResourceLoader.exists(sound_path):
			sound_player.stream = load(sound_path)
		else:
			print("WARNING: Sound file not found: ", sound_path)
			continue
		if sound_player.stream:
			sound_player.volume_db = linear_to_db(sound_volume)
			sound_player.bus = "SFX"
			add_child(sound_player)
			sound_players[sound_name] = sound_player
			print("Loaded sound: ", sound_name)
		else:
			print("ERROR: Failed to load sound: ", sound_path)
		
func set_music_volume(volume: float):
	music_volume = clamp(volume, 0.0, 1.0)
	music_volume_changed.emit(music_volume)
	
	if music_player:
		music_player.volume_db = linear_to_db(music_volume)
	
	save_settings()

func set_sound_volume(volume: float):
	sound_volume = clamp(volume, 0.0, 1.0)
	sound_volume_changed.emit(sound_volume)
	
	for sound_player in sound_players.values():
		if sound_player:
			sound_player.volume_db = linear_to_db(sound_volume)
	
	save_settings()

func play_music():
	music_player.play()

func play_sound(sound_name: String):
	if sound_players.has(sound_name) and sound_players[sound_name]:
		sound_players[sound_name].play()
		
		
# Сохранение/загрузка настроек
func save_settings():
	var config = {
		"music_volume": music_volume,
		"sound_volume": sound_volume
	}
	var file = FileAccess.open("user://audio_settings.cfg", FileAccess.WRITE)
	if file:
		file.store_var(config)

func load_settings():
	var file = FileAccess.open("user://audio_settings.cfg", FileAccess.READ)
	if file:
		var config = file.get_var()
		if config:
			set_music_volume(config.get("music_volume", 0.8))
			set_sound_volume(config.get("sound_volume", 0.8))
