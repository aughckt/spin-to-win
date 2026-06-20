class_name TrooperSpawner
extends Node2D


static var INST: TrooperSpawner
@export var spawn_point: Vector2 
var elapsed_wave_time: float = 0.0
var spawn_timer: float = 0.0
var trooper_pool: Pool
var current_wave: Curve = null
@onready var trooper_scene: PackedScene = preload("res://troopers/trooper.tscn")


func _ready() -> void:
	assert(INST == null)
	INST = self
	trooper_pool = Pool.create(trooper_scene)


func _physics_process(delta: float) -> void:
	if not current_wave: 
		return
	
	elapsed_wave_time += delta
	spawn_timer -= delta
	
	if elapsed_wave_time > current_wave.max_domain:
		LevelManager.INST.end_wave()
		return
	
	if spawn_timer <= 0:
		spawn_timer = current_wave.sample(elapsed_wave_time)
		spawn_trooper()


func spawn_trooper() -> void:
	var trooper: Trooper = trooper_pool.get_inst()
	trooper.reparent.call_deferred(self)
	trooper.global_position = spawn_point
	trooper.target_pos = trooper.global_position 
	trooper.enabled = true


func clear_troopers() -> void:
	elapsed_wave_time = 0.0
	for child: Node in get_children():
		trooper_pool.pool(child)


func pool_trooper(trooper: Trooper) -> void:
	trooper.enabled = false
	trooper_pool.pool(trooper)


func set_wave(curve: Curve) -> void:
	current_wave = curve
	if current_wave:
		spawn_timer = current_wave.sample(elapsed_wave_time)
