class_name TrooperSpawner
extends Node2D


static var INST: TrooperSpawner
var elapsed_wave_time: float = 0.0
var spawn_timers: Array[float] = []
var trooper_pool: Pool

var current_waves: Array[WaveData] = []
var wave_credits_left: Array[int] = []
var wave_credits_active: Array[int] = []

var current_lane_amount: int = 1
var spawn_points: Array[SpawnPoint] = []
@onready var trooper_scene: PackedScene = preload("res://troopers/trooper.tscn")

const SPAWN_TIMER_S: float = 0.4
var spawn_cooldown: float

var active: bool = false

signal finished

#var thing: Array[Variant.Type] = [Trooper]

func _ready() -> void:
	assert(INST == null)
	INST = self
	trooper_pool = Pool.create(trooper_scene)


func _physics_process(delta: float) -> void:
	if !active:
		return
	
	if current_waves.is_empty(): 
		return
	elapsed_wave_time += delta
	
	spawn_cooldown -= delta
	if spawn_cooldown > 0:
		return
	spawn_cooldown = SPAWN_TIMER_S
	
	var finished_waves: int = 0
	for i in range(current_waves.size()):
		if current_waves[i] == null:
			finished_waves += 1
			continue
		
		if wave_credits_left[i] <= 0:
		#dont care about time because then we could still have unspent credits
		# || elapsed_wave_time > current_waves[i].credit_curve.max_domain:
			
			if wave_credits_active[i] == 0:
				finished_waves += 1
			continue
		
		spawn_trooper(i)
	
	if finished_waves == current_waves.size():
		assert(false, "HOOK UP FINISHED SIGNAL")
		finished.emit()
	
	#var wave_domains: Array[float] = []
	#for wave in current_waves:
		#wave_domains.append(wave.max_domain)
	#if elapsed_wave_time > wave_domains.max():
		#if Env.INST.troopers.get_child_count() == 0:
			#LevelManager.INST.end_wave()
		#return
	#
	#for i in range(spawn_timers.size()):
		#spawn_trooper(i)


func spawn_trooper(index: int) -> void:
	#at this points all waves have credits and time left
	var wave := current_waves[index]
	
	var max_rn := wave.credit_curve.sample(minf(elapsed_wave_time, wave.credit_curve.max_domain)) as int
	var budget := mini(
		wave_credits_left[index],
		max_rn - wave_credits_active[index],
	)
	
	if budget <= 0:
		#push_warning("spawn credit issue, didnt cause any damage")
		return
	
	var trooper: Trooper
	if budget >= Jumbo.cost():
		trooper = Jumbo.create()
	else:
		assert(budget >= Trooper.cost())
		trooper = Trooper.create()
	spend_credits(trooper.cost(), index)
	trooper.removed.connect(_on_trooper_removed)
	
	trooper.reparent.call_deferred(Env.INST.troopers)
	trooper.global_position = spawn_points[index].global_position
	trooper.target_pos = trooper.global_position 

func spend_credits(count: int, idx: int) -> void:
	wave_credits_active[idx] += count
	wave_credits_left[idx] -= count

func _on_trooper_removed(trooper: Trooper) -> void:
	wave_credits_active[trooper.lane_idx] -= trooper.cost()
	trooper.removed.disconnect(_on_trooper_removed)
	
	if range(current_waves.size()).all(func (idx: int) -> bool:
		return wave_credits_active[idx] == 0 && wave_credits_left[idx] == 0
	):
		finished.emit()

func clear_troopers() -> void:
	elapsed_wave_time = 0.0
	for child: Node in get_children():
		trooper_pool.pool(child)


func pool_trooper(trooper: Trooper) -> void:
	trooper_pool.pool(trooper)


func set_waves(waves: Array[WaveData]) -> void:
	current_waves = waves
	wave_credits_left.clear()
	wave_credits_active.clear()
	for wave in current_waves:
		wave_credits_left.push_back(wave.total_credits)
		wave_credits_active.push_back(0)

func enable() -> void:
	active = true

func disable() -> void:
	active = false
