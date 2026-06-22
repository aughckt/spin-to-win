class_name TrooperSpawner
extends Node2D


static var INST: TrooperSpawner
var elapsed_wave_time: float = 0.0
var spawn_timers: Array[float] = []
var trooper_pool: Pool
var current_waves: Array[Curve] = []
var current_lane_amount: int = 1
var spawn_points: Array[Node2D] = []
@onready var trooper_scene: PackedScene = preload("res://troopers/trooper.tscn")


func _ready() -> void:
	assert(INST == null)
	INST = self
	trooper_pool = Pool.create(trooper_scene)


func _physics_process(delta: float) -> void:
	if current_waves.is_empty(): 
		return
	
	elapsed_wave_time += delta
	for timer: float in spawn_timers:
		timer -= delta
	
	var wave_domains: Array[float] = []
	for wave in current_waves:
		wave_domains.append(wave.max_domain)
	if elapsed_wave_time > wave_domains.max() and Env.INST.troopers.get_children().is_empty():
		LevelManager.INST.end_wave()
		return
	for i: int in len(spawn_timers):
		spawn_timers[i] -= delta
		if spawn_timers[i] <= 0:
			spawn_timers[i] = current_waves[i].sample(elapsed_wave_time)
			spawn_trooper(i)


func spawn_trooper(index: int) -> void:
	var trooper: Trooper = trooper_pool.get_inst()
	trooper.reparent.call_deferred(Env.INST.troopers)
	trooper.global_position = spawn_points[index].global_position
	trooper.target_pos = trooper.global_position 
	trooper.setup()


func clear_troopers() -> void:
	elapsed_wave_time = 0.0
	for child: Node in get_children():
		trooper_pool.pool(child)


func pool_trooper(trooper: Trooper) -> void:
	trooper_pool.pool(trooper)


func set_waves(curves: Array[Curve]) -> void:
	print(curves.size())
	current_waves = curves
	if not current_waves.is_empty():
		spawn_timers = []
		for wave: Curve in current_waves:
			spawn_timers.append(wave.sample(elapsed_wave_time))
