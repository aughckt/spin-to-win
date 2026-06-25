class_name Trooper
extends Area2D

@export var move_speed: float = 100.0

#minimum distance towards target
@export var min_dist_to_target: float = 0.1

var target_pos: Vector2
var walk_normal: Vector2
@export var max_hp: int = 100
var hp: int = max_hp
@export var sprite: AnimatedSprite2D

@export_category("Sounds")
@export var walk_sound: Sound
@export var hit_sound: Sound
@export var death_sound: Sound
@export var random_sound: Sound

@onready var random_sound_timer: Timer = %RandomSoundTimer
@onready var walk_sound_timer: Timer = %WalkSoundTimer

var stun_time_s: float = 0

static var pool: Pool

const scene_trooper: PackedScene = preload("res://troopers/trooper.tscn")

var lane_idx: int = -1

signal removed(trooper: Trooper)

func _ready() -> void:
	target_pos = global_position
	walk_normal = Vector2.ZERO
	
	random_sound_timer.timeout.connect(_on_random_sound_timer_timeout)
	walk_sound_timer.timeout.connect(_on_walk_sound_timer_timeout)


func _physics_process(delta: float) -> void:
	if Env.INST == null:
		return
	
	if stun_time_s > 0:
		stun_time_s = maxf(stun_time_s - delta, 0)
		return
	
	var new_pos := global_position + walk_normal * move_speed * delta
	
	if (global_position.distance_squared_to(target_pos) < global_position.distance_squared_to(new_pos) #this check makes sure we dont move past the point
	|| global_position.distance_squared_to(target_pos) < min_dist_to_target * min_dist_to_target):
		global_position = target_pos
		target_pos = Env.INST.move_target_from_global(target_pos)
		
		#this shouldnt fail due to rounding errors because in move_target_from_global were returning the exact vector we pass in
		if target_pos == global_position:
			reach_end()
			
		
		
		walk_normal = global_position.direction_to(target_pos)
		
		var directions: PackedVector2Array = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]
		var best_idx: int = 0
		var best_dot: float = directions[best_idx].dot(walk_normal)
		for idx in range(4):
			var dot := directions[idx].dot(walk_normal)
			if dot > best_dot:
				best_dot = dot
				best_idx = idx
		
		var animation := ""
		match best_idx:
			0:
				animation = "walk_up"
			1:
				animation = "walk_down"
			2:
				animation = "walk_right" if !_has_left_anim() else "walk_left"
			3:
				animation = "walk_right"
		sprite.flip_h = best_idx == 2 && !_has_left_anim()
		sprite.play(animation)
		
		new_pos = global_position + walk_normal * move_speed * delta
	
	global_position = new_pos


func reach_end() -> void:
	LevelManager.INST.take_damage(1)
	remove()

func take_damage(amount: int) -> void:
	if hp <= 0:
		return
	
	hp -= amount
	
	SoundBus.play_sound(hit_sound)
	
	if hp <= 0:
		Env.INST.spawn_money(cost(), get_screen_transform().origin)
		remove()
		SoundBus.play_sound(death_sound)
	else:
		update_shader()

func update_shader() -> void:
	var t := clampf(hp as float / max_hp, 0, 1)
	#sprite.set_instance_shader_parameter("y_threshold", t)
	(sprite.material as ShaderMaterial).set_shader_parameter("y_threshold", t)

static func _get_pool() -> Pool:
	if pool == null:
		pool = Pool.create(scene_trooper)
	return pool

static func create() -> Trooper:
	var trooper: Trooper = _get_pool().get_inst()
	trooper.setup()
	return trooper

func setup() -> void:
	set_deferred("monitorable", true)
	set_deferred("monitoring", true)
	hp = max_hp
	stun_time_s = 0
	lane_idx = -1
	update_shader()


func _on_random_sound_timer_timeout() -> void:
	if not get_parent() == GeneralPool:
		SoundBus.play_sound(random_sound)
	random_sound_timer.wait_time = randf() * 1
	random_sound_timer.start()


func _on_walk_sound_timer_timeout() -> void:
	if not get_parent() == GeneralPool:
		SoundBus.play_sound(walk_sound)

func remove() -> void:
	removed.emit(self)
	
	_get_pool().pool(self)
	set_deferred("monitorable", false)
	set_deferred("monitoring", false)

static func cost() -> int:
	#THIS MUST BE 1, THATS WHAT THE LOGIC IN THE TROOPER SPAWNER IS DESIGNED FOR
	return 1

func _has_left_anim() -> bool:
	return false
