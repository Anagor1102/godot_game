extends Node2D

@export var mob_scene: PackedScene
@export var spawn_points: Array[Node2D] = []
@export var initial_mobs_per_wave = 2
@export var mob_increase_per_wave = 2
@export var spawn_cooldown: float = 0.5

var current_wave = 0
var current_mobs = []
var can_spawn = true
var wave_IP = false

func _ready():
	if spawn_points.is_empty():
		for child in get_children():
			if child is Marker2D:
				spawn_points.append(child)

func start_next_wave():
	if wave_IP:
		return
	current_wave += 1
	var mobs_count = initial_mobs_per_wave + (current_wave - 1) * mob_increase_per_wave
	spawn_wave(mobs_count)

func spawn_wave(mobs_count: int):
	if !can_spawn:
		return
		
	can_spawn = false
	wave_IP = true
	
	var available_spawn_points = spawn_points.duplicate()
	available_spawn_points.shuffle()
	
	var points_to_use = []
	for i in range(mobs_count):
		if available_spawn_points.is_empty():
			available_spawn_points = spawn_points.duplicate()
			available_spawn_points.shuffle()
		points_to_use.append(available_spawn_points.pop_front())
	
	for point in points_to_use:
		var mob = mob_scene.instantiate()
		mob.global_position = point.global_position

		get_parent().add_child(mob)

		mob.died.connect(_on_mob_died)
		
		current_mobs.append(mob)

func _on_mob_died():
	var new_mobs = []
	for mob in current_mobs:
		if is_instance_valid(mob) and mob.health > 0:
			new_mobs.append(mob)
	
	current_mobs = new_mobs
	
	if current_mobs.is_empty():
		wave_IP = false
		await get_tree().create_timer(spawn_cooldown).timeout
		can_spawn = true
		start_next_wave()

func reset_spawner():
	current_wave = 0
	for mob in current_mobs:
		if is_instance_valid(mob):
			mob.queue_free()
	current_mobs.clear()
	can_spawn = true
	wave_IP = false
	start_next_wave()
