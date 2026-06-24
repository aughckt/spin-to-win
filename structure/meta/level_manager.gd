class_name LevelManager
extends Node2D

static var INST: LevelManager

@export var current_level_index: int = 0
var level_array: Array[PackedScene] = [
	#preload("res://structure/levels/loop.tscn"),
	preload("res://structure/levels/level_gunturn.tscn"),
	preload("res://structure/levels/level_aoe_intro.tscn"),
	preload("res://structure/levels/level_multilane.tscn")]
var current_level: Level = null
var current_hp: int = 20
var is_build_phase: bool = true

##array of array of WaveData
var current_wave_list: Array[Array]

var current_wave_index: int = 0

signal wave_started

@onready var level_won_timer: Timer = %LevelWonTimer
@onready var level_lost_timer: Timer = %LevelLostTimer
@onready var level_lost_banner: Control = %LevelLostLabel
@onready var level_won_banner: Control = %LevelWonLabel
@onready var phase_transition_timer: Timer = %PhaseTransitionTimer
@onready var wave_banner: Control = %WavePhaseLabel
@onready var build_banner: Control = %BuildPhaseLabel

signal wave_finished

func _ready() -> void:
	assert(INST == null)
	INST = self
	
	if current_level == null:
		load_level()
	
	phase_transition_timer.timeout.connect(_on_phase_transition_timeout)
	level_won_timer.timeout.connect(_on_won_timer_timeout)
	level_lost_timer.timeout.connect(_on_lost_timer_timeout)


func _input(event: InputEvent) -> void:
	## Debug. Press space to skip level
	if event.is_action_pressed("toggle_wave"):
		current_level_index += 1
		load_level()
		set_build_phase(true)


func win_level() -> void:
	print("%s: Level %s won" % [name, current_level_index])
	current_level_index += 1
	level_won_timer.start()
	level_won_banner.visible = true
	


func lose_level() -> void:
	TrooperSpawner.INST.set_waves([])
	print("%s: Level %s lost" % [name, current_level_index])
	level_lost_timer.start()
	level_lost_banner.visible = true


func load_level() -> void:
	if current_level != null:
		current_level.queue_free()
		TrooperSpawner.INST.finished.disconnect(end_wave)
	
	if Env.INST:
		Env.INST.delete()
	
	if level_array.size() <= current_level_index:
		print("You won the game!")
		return
	current_level = level_array[current_level_index].instantiate()
	set_build_phase(true)
	add_child(current_level)
	current_hp = current_level.level_hp
	current_wave_list = current_level.waves
	for wave in current_wave_list:
		for x: Variant in wave:
			assert(x is WaveData)
			var w := (x as WaveData).credit_curve
			assert(w.sample(w.max_domain) as int >= 1, "The end of a curve should be >= 1 so that the credits can always be spent completely")
	current_wave_index = 0
	TrooperSpawner.INST.spawn_points = current_level.spawn_points
	TrooperSpawner.INST.finished.connect(end_wave)


func start_wave() -> void:
	set_build_phase(false)
	if current_wave_index >= current_wave_list.size():
		return
	print("%s: Wave %s started!" % [name, current_wave_index])
	var current_waves: Array[WaveData] = []
	for spawn_idx in range(current_wave_list.size()):
		#this being null is fine because the spawner ignores it
		var wave: WaveData = current_wave_list[spawn_idx].get(current_wave_index)
		current_waves.push_back(wave)
	
	if current_waves.all(func(x: WaveData) -> bool: return x == null):
		win_level()
		return
	
	#for spawn_point: SpawnPoint in current_level.spawn_points:
		#if spawn_point.wave_list.size() <= current_wave_index:
			#continue
		#current_waves.append(spawn_point.wave_list[current_wave_index])
	TrooperSpawner.INST.enable()
	TrooperSpawner.INST.set_waves(current_waves)
	wave_started.emit()


func end_wave() -> void:
	print("%s: Wave %s ended!" % [name, current_wave_index])
	set_build_phase(true)
	current_wave_index += 1
	TrooperSpawner.INST.disable()
	wave_finished.emit()
	if current_wave_index >= current_wave_list.size():
		win_level()
		return


func set_build_phase(value: bool) -> void:
	is_build_phase = value
	
	TrooperSpawner.INST.clear_troopers()
	TrooperSpawner.INST.active = !value
	
	wave_banner.visible = not value
	build_banner.visible = value
	phase_transition_timer.start()
	if current_level:
		current_level.set_build_phase(value)


func take_damage(amount: int) -> void:
	if current_hp <= 0:
		return
	current_hp -= amount
	print("%s: hp is now %s" % [name, current_hp])
	if current_hp <= 0:
		lose_level()


func _on_phase_transition_timeout() -> void:
	wave_banner.visible = false
	build_banner.visible = false


func _on_lost_timer_timeout() -> void:
	load_level()
	level_lost_banner.visible = false


func _on_won_timer_timeout() -> void:
	load_level()
	level_won_banner.visible = false
