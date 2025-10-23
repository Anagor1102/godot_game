extends Node2D

enum GameState {IDLE, RUNNING, ENDED}
var game_state

func _ready() -> void:
	game_state = GameState.IDLE
	global.play_music()
	$HUD.show_main_menu()
	$level/player.player_died.connect(end_game)

func _process(delta: float) -> void:
	pass
	
func new_game():
	game_state = GameState.RUNNING
	global.current_score = 0
	
	show_level()
	
	$HUD.show_during_game()
	$level/player.reset_player()
	$level/spawner.reset_spawner()
	
func end_game():
	game_state = GameState.ENDED
	$HUD.on_game_over()

func add_score(points):
	if game_state == GameState.RUNNING:
		global.current_score += points
		$HUD.update_score()

func show_bg():
	$bg.visible = true
	$bg.process_mode = Node.PROCESS_MODE_INHERIT
	$level.visible = false
	$level.process_mode = Node.PROCESS_MODE_DISABLED
	set_physics_process(false)

func show_level():
	$bg.visible = false
	$bg.process_mode = Node.PROCESS_MODE_DISABLED
	$level.visible = true
	$level.process_mode = Node.PROCESS_MODE_INHERIT
	set_physics_process(true)
