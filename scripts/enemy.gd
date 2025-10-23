extends CharacterBody2D


var speed = 150
var player_chase = false
var player = null

var health = 100
var player_inattack_zone = false
var can_take_damage = true

signal died
var is_dead = false
var is_patrolling = true
var patrol_points = []
var current_patrol_index = 0
var patrol_speed = 50
var spawn_position: Vector2

func _ready():
	spawn_position = global_position
	setup_patrol()

func _physics_process(delta: float) -> void:
	if is_dead:
		return
	deal_with_damage()
	update_health()
	
	if player_chase:
		chase_player(delta)
	elif is_patrolling:
		patrol(delta)
	else:
		$AnimatedSprite2D.play("idle")


func setup_patrol():
	var patrol_radius = 50
	patrol_points = [
		spawn_position + Vector2(patrol_radius, 0),
		spawn_position + Vector2(0, patrol_radius),
		spawn_position + Vector2(-patrol_radius, 0),
		spawn_position + Vector2(0, -patrol_radius)
	]

func start_patrol():
	is_patrolling = true


func patrol(delta):
	if patrol_points.is_empty():
		return
		
	var target_point = patrol_points[current_patrol_index]
	var direction = (target_point - global_position).normalized()
	
	velocity = direction * patrol_speed
	move_and_slide()

	$AnimatedSprite2D.play("walk")
	if direction.x < 0:
		$AnimatedSprite2D.flip_h = true
	else:
		$AnimatedSprite2D.flip_h = false

	if global_position.distance_to(target_point) < 5:
		current_patrol_index = (current_patrol_index + 1) % patrol_points.size()

func chase_player(delta):
	if player:
		var direction = (player.position - position).normalized()
		velocity = direction * speed
		move_and_slide()
		
		$AnimatedSprite2D.play("walk")
		if direction.x < 0:
			$AnimatedSprite2D.flip_h = true
		else:
			$AnimatedSprite2D.flip_h = false

func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		player = body
		player_chase = true
		is_patrolling = false


func _on_detection_area_body_exited(body: Node2D) -> void:
	if is_dead:
		return
	if body == player:
		player = null
		player_chase = false
		is_patrolling = true
		current_patrol_index = 0

func enemy():
	pass

func _on_enemy_hitbox_body_entered(body: Node2D) -> void:
	if is_dead:
		return
	if body.has_method("player"):
		player_inattack_zone = true

func _on_enemy_hitbox_body_exited(body: Node2D) -> void:
	if is_dead:
		return
	if body.has_method("player"):
		player_inattack_zone = false

func deal_with_damage():
	if is_dead:	
		return
	if player_inattack_zone and global.player_current_attack:
		if can_take_damage and health > 0:
			health = health - 20
			$take_damage_cooldown.start()
			can_take_damage = false
			if health <= 0:
				is_dead = true
				get_tree().current_scene.add_score(50)
				$AnimatedSprite2D.hide()
				$detection_area/CollisionShape2D.set_deferred("disabled", true)
				$healthbar.visible = false
				$CollisionShape2D.set_deferred("disabled", true)
				$enemy_hitbox/CollisionShape2D.set_deferred("disabled", true)
				
				$dust/AnimationPlayer.play("dust")
				$dust.show()
				global.play_sound("slimeDeath")
				await $dust/AnimationPlayer.animation_finished
				died.emit()
				self.queue_free()


func _on_take_damage_cooldown_timeout() -> void:
	can_take_damage = true

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
