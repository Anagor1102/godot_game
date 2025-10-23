extends CharacterBody2D

const speed = 300
var current_dir = "down"

var enemy_inattack_range = false
var enemy_attack_cooldown = true
var health = 100
var player_alive = true

var attack_IP = false

signal player_died
var mobile_input_vector: Vector2 = Vector2.ZERO
var mobile_attack_pressed: bool = false

func _ready():
	$AnimatedSprite2D.play("front_idle")
	
func _physics_process(delta):
	if player_alive:
		player_movement(delta)
		enemy_attack()
		attack()
		update_health()
		
		if health <= 0:
			player_alive = false
			$AnimatedSprite2D.play("death")
			print("player killed")
			player_died.emit()
	else:
		return
		

func player_movement(delta):
	if Input.is_action_pressed("ui_right") or global.right:
		current_dir = "right"
		play_anim(1)
		velocity.x = speed
		velocity.y = 0
	elif Input.is_action_pressed("ui_left") or global.left:
		current_dir = "left"
		play_anim(1)
		velocity.x = -speed
		velocity.y = 0
	elif Input.is_action_pressed("ui_down") or global.down:
		current_dir = "down"
		play_anim(1)
		velocity.x = 0
		velocity.y = speed
	elif Input.is_action_pressed("ui_up") or global.up:
		current_dir = "up"
		play_anim(1)
		velocity.x = 0
		velocity.y = -speed
	else:
		play_anim(0)
		velocity.x = 0
		velocity.y = 0

	move_and_slide()

func mobile_attack():
	mobile_attack_pressed = true

func play_anim(movement):
	var dir = current_dir
	var anim = $AnimatedSprite2D
	
	if dir == "right":
		anim.flip_h = false
		if movement == 1:
			anim.play("side_walk")
		elif movement == 0:
			if attack_IP == false:
				anim.play("side_idle")
	if dir == "left":
		anim.flip_h = true
		if movement == 1:
			anim.play("side_walk")
		elif movement == 0:
			if attack_IP == false:
				anim.play("side_idle")
	
	if dir == "down":
		anim.flip_h = false
		if movement == 1:
			anim.play("front_walk")
		elif movement == 0:
			if attack_IP == false:
				anim.play("front_idle")
	if dir == "up":
		anim.flip_h = false
		if movement == 1:
			anim.play("back_walk")
		elif movement == 0:
			if attack_IP == false:
				anim.play("back_idle")

func player():
	pass

func _on_player_hitbox_body_entered(body: Node2D) -> void:
	if body.has_method("enemy"):
		enemy_inattack_range = true


func _on_player_hitbox_body_exited(body: Node2D) -> void:
	if body.has_method("enemy"):
		enemy_inattack_range = false

func enemy_attack():
	if enemy_inattack_range and enemy_attack_cooldown:
		health = health - 20
		enemy_attack_cooldown = false
		global.play_sound("hurt")
		$attack_cooldown.start()
		print(health)
	
func _on_attack_cooldown_timeout() -> void:
	enemy_attack_cooldown = true
	

func attack():
	var dir = current_dir
	
	if Input.is_action_just_pressed("attack") or (mobile_attack_pressed and player_alive and not attack_IP):
		global.player_current_attack = true
		attack_IP = true
		mobile_attack_pressed = false
		if dir == "right":
			$AnimatedSprite2D.flip_h = false
			$AnimatedSprite2D.play("side_attack")
			$deal_attack_timer.start()
		if dir == "left":
			$AnimatedSprite2D.flip_h = true
			$AnimatedSprite2D.play("side_attack")
			$deal_attack_timer.start()
		if dir == "down":
			$AnimatedSprite2D.play("front_attack")
			$deal_attack_timer.start()
		if dir == "up":
			$AnimatedSprite2D.play("back_attack")
			$deal_attack_timer.start()
		global.play_sound("attack")


func _on_deal_attack_timer_timeout() -> void:
	$deal_attack_timer.stop()
	global.player_current_attack = false
	attack_IP = false

func update_health():
	var healthbar = $healthbar
	healthbar.value = health
	if health >= 100:
		healthbar.visible = false
	else:
		healthbar.visible = true
	if health >= 0 and health <= 40:
		healthbar.modulate = Color.RED
	elif health > 40 and health <= 60:
		healthbar.modulate = Color.ORANGE
	elif health > 60 and health <= 100:
		healthbar.modulate = Color.GREEN

func _on_regen_timer_timeout() -> void:
	if health < 100:
		global.play_sound("regen")
		health = health + 20
		if health > 100:
			health = 100
	if health <= 0:
		health = 0


func _on_player_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("Obstacles"):
		health = health - 20
		global.play_sound("hurt")
		enemy_attack_cooldown = false
		$attack_cooldown.start()
		
		
func reset_player():
	health = 100
	player_alive = true
	enemy_inattack_range = false
	current_dir = "down"
	mobile_input_vector = Vector2.ZERO
	mobile_attack_pressed = false
	position = Vector2(200, 310)
	$AnimatedSprite2D.play("front_idle")
