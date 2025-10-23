extends CanvasLayer

enum Screen {
	MAIN_MENU,
	DURING_GAME,
	SETTINGS,
	SETTINGS_DURING_GAME,
	END_GAME
}

var current_screen: Screen = Screen.MAIN_MENU
var screens = {}

var mobile_direction: Vector2 = Vector2.ZERO

func _ready():
	global.music_volume_changed.connect(_on_music_volume_changed)
	global.sound_volume_changed.connect(_on_sound_volume_changed)
	
	init_sliders()
	update_volume_labels()
	
	screens[Screen.MAIN_MENU] = $main_menu_screen
	screens[Screen.DURING_GAME] = $during_game_screen
	screens[Screen.SETTINGS] = $settings_screen
	screens[Screen.SETTINGS_DURING_GAME] = $settings_during_game_screen
	screens[Screen.END_GAME] = $end_of_game_screen
	hide_all_screens()
	show_screen(Screen.MAIN_MENU)

func init_sliders():
	# Получаем слайдеры
	var music_slider_settings = $settings_screen/music_slider
	var sound_slider_settings = $settings_screen/sound_slider
	var music_slider_in_game = $settings_during_game_screen/music_slider
	var sound_slider_in_game = $settings_during_game_screen/sound_slider
	
	music_slider_settings.value = global.music_volume
	music_slider_settings.value_changed.connect(_on_music_slider_changed)
	sound_slider_settings.value = global.sound_volume
	sound_slider_settings.value_changed.connect(_on_sound_slider_changed)
	music_slider_in_game.value = global.music_volume
	music_slider_in_game.value_changed.connect(_on_music_slider_changed)
	sound_slider_in_game.value = global.sound_volume
	sound_slider_in_game.value_changed.connect(_on_sound_slider_changed)
		
func _on_music_slider_changed(value: float):
	global.set_music_volume(value)
	update_volume_labels()

func _on_sound_slider_changed(value: float):
	global.set_sound_volume(value)
	update_volume_labels()

func _on_music_volume_changed(volume: float):
	var music_slider = $settings_screen/music_slider
	music_slider.value = volume
	update_volume_labels()

func _on_sound_volume_changed(volume: float):
	var sound_slider = $settings_screen/sound_slider
	sound_slider.value = volume
	update_volume_labels()

func update_volume_labels():
	var music_percent_settings = $settings_screen/music_percent
	var sound_percent_settings = $settings_screen/sound_percent
	var music_percent_in_game = $settings_during_game_screen/music_percent
	var sound_percent_in_game = $settings_during_game_screen/sound_percent
	music_percent_settings.text = str(int(global.music_volume * 100)) + "%"
	sound_percent_settings.text = str(int(global.sound_volume * 100)) + "%"
	music_percent_in_game.text = str(int(global.music_volume * 100)) + "%"
	sound_percent_in_game.text = str(int(global.sound_volume * 100)) + "%"

func hide_all_screens():
	for screen in screens.values():
		if screen:
			screen.visible = false

func show_screen(screen_type: Screen):
	hide_all_screens()
	
	if screens.has(screen_type) and screens[screen_type]:
		screens[screen_type].visible = true
		current_screen = screen_type
		
		manage_worlds_for_screen(screen_type)
		manage_pause_for_screen(screen_type)
		match screen_type:
			Screen.END_GAME:
				update_end_game_score()
			Screen.DURING_GAME:
				update_score()

func manage_pause_for_screen(screen_type: Screen):
	match screen_type:
		Screen.SETTINGS_DURING_GAME:
			get_tree().paused = true	
		Screen.DURING_GAME, Screen.MAIN_MENU, Screen.SETTINGS, Screen.END_GAME:
			get_tree().paused = false

func update_end_game_score():
	$end_of_game_screen/Score.text = str(global.current_score)

func update_score():
	$during_game_screen/Score.text = str(global.current_score)

func manage_worlds_for_screen(screen_type: Screen):
	var world = get_tree().current_scene
	
	match screen_type:
		Screen.MAIN_MENU, Screen.SETTINGS:
			world.show_bg()
		
		Screen.DURING_GAME, Screen.SETTINGS_DURING_GAME, Screen.END_GAME:
			world.show_level()
	


func show_main_menu():
	show_screen(Screen.MAIN_MENU)

func show_during_game():
	show_screen(Screen.DURING_GAME)

func show_settings():
	show_screen(Screen.SETTINGS)

func show_settings_during_game():
	show_screen(Screen.SETTINGS_DURING_GAME)

func show_end_game():
	show_screen(Screen.END_GAME)



func _on_restart_button_button_up() -> void:
	global.play_sound("click")
	await get_tree().create_timer(0.1).timeout
	get_tree().current_scene.new_game()
	show_during_game()

func _on_quit_button_button_up() -> void:
	global.play_sound("click")
	await get_tree().create_timer(0.1).timeout
	show_main_menu()

func _on_play_button_button_up() -> void:
	global.play_sound("click")
	await get_tree().create_timer(0.1).timeout
	get_tree().current_scene.new_game()
	show_during_game()

func _on_settings_button_button_up() -> void:
	global.play_sound("click")
	await get_tree().create_timer(0.1).timeout
	show_settings()

func _on_exit_button_button_up() -> void:
	global.play_sound("click")
	await get_tree().create_timer(0.1).timeout
	get_tree().quit()

func _on_close_button_button_up() -> void:
	global.play_sound("click")
	await get_tree().create_timer(0.1).timeout
	show_during_game()

func _on_settings_during_game_button_button_up() -> void:
	global.play_sound("click")
	await get_tree().create_timer(0.1).timeout
	show_settings_during_game()
	
func on_game_over():
	show_end_game()


func _on_up_button_pressed() -> void:
	global.up = true
	update_mobile_direction()


func _on_up_button_button_up() -> void:
	global.up = false
	update_mobile_direction()


func _on_right_button_pressed() -> void:
	global.right = true
	update_mobile_direction()


func _on_right_button_button_up() -> void:
	global.right = false
	update_mobile_direction()


func _on_down_button_pressed() -> void:
	global.down = true
	update_mobile_direction()


func _on_down_button_button_up() -> void:
	global.down = false
	update_mobile_direction()


func _on_left_button_pressed() -> void:
	global.left = true
	update_mobile_direction()


func _on_left_button_button_up() -> void:
	global.left = false
	update_mobile_direction()


func _on_attack_button_pressed() -> void:
	var player = get_tree().current_scene.find_child("player", true, false)
	player.mobile_attack()
	
func update_mobile_direction():
	var player = get_tree().current_scene.find_child("player", true, false)
	if player and player.has_method("set_mobile_direction"):
		player.set_mobile_direction(mobile_direction)
