class_name LevelManager
extends Node2D

static var INST: LevelManager

@export var current_level_index: int = 0
var level_array: Array[PackedScene] = [
	load("res://structure/levels/lock.tscn"),
	#load("res://structure/levels/lock.tscn"),
	#load("res://structure/levels/loop.tscn"),
	#load("res://structure/levels/level_gunturn.tscn"),
	load("res://structure/levels/level_sniper.tscn"),
	load("res://structure/levels/level_multilane.tscn"),
	load("res://structure/levels/level_aoe_intro.tscn"),
	load("res://structure/levels/level_comeback.tscn"),]
var current_level: Level = null
var current_hp: int = 10
var is_build_phase: bool = true

var current_lanes: Array[LaneData]
## This is the amount of waves, maximum of all wave-lists in the level.
var current_wave_max: int = 0
var current_wave_index: int = 0

signal wave_started



@onready var level_won_timer: Timer = %LevelWonTimer
@onready var level_lost_timer: Timer = %LevelLostTimer
@onready var level_lost_banner: Control = %LevelLostLabel
@onready var level_won_banner: Control = %LevelWonLabel
@onready var phase_transition_timer: Timer = %PhaseTransitionTimer
@onready var wave_banner: Control = %WavePhaseLabel
@onready var build_banner: Control = %BuildPhaseLabel
@onready var background_banner: Control = %WavePhasePanel

@onready var start_screen: Control = %StartScreen
@onready var end_screen: Control = %EndScreen


@export var start_level_sound: Sound
@export var start_wave_sound: Sound

signal wave_finished

func _ready() -> void:
	assert(INST == null)
	INST = self
	
	phase_transition_timer.timeout.connect(_on_phase_transition_timeout)
	level_won_timer.timeout.connect(_on_won_timer_timeout)
	level_lost_timer.timeout.connect(_on_lost_timer_timeout)


func _input(event: InputEvent) -> void:
	## Debug. Press space to skip level
	
	if  event.is_action_pressed("M1") and current_level == null and end_screen.visible == false:
		load_level()
		start_screen.visible = false
		
	if event.is_action_pressed("skip_level") and current_level:
		current_level_index += 1
		TrooperSpawner.INST.disable()
		load_level()
	elif event.is_action_pressed("restart_level") and current_level:
		TrooperSpawner.INST.disable()
		load_level()
	elif event.is_action_pressed("skip_wave") and is_build_phase and current_level and background_banner.visible == false:
		end_wave()
		if current_wave_index >= current_wave_max:
			return
		var money: int = 0
		for data: LaneData in current_level.lanes:
			money += data.waves[current_wave_index - 1].total_credits
		Env.INST.budget += money



func win_level() -> void:
	print("%s: Level %s won" % [name, current_level_index])
	current_level_index += 1
	level_won_timer.start()
	level_won_banner.visible = true
	background_banner.visible = true
	TrooperSpawner.INST.disable()


func lose_level() -> void:
	if TrooperSpawner.INST.finished.is_connected(end_wave):
		TrooperSpawner.INST.finished.disconnect(end_wave)
	
	TrooperSpawner.INST.disable()
	print("%s: Level %s lost" % [name, current_level_index])
	level_lost_timer.start()
	level_lost_banner.visible = true
	background_banner.visible = true


func load_level() -> void:
	SoundBus.stop_all_sounds()
	SoundBus.play_sound(start_level_sound)
	if current_level != null:
		current_level.queue_free()
		if TrooperSpawner.INST.finished.is_connected(end_wave):
			TrooperSpawner.INST.finished.disconnect(end_wave)
	
	if Env.INST:
		Env.INST.delete()
	
	if level_array.size() <= current_level_index:
		print("You won the game!")
		end_game()
		return
	background_banner.visible = true
	current_level = level_array[current_level_index].instantiate()
	current_hp = current_level.level_hp
	set_build_phase(true)
	add_child(current_level)
	current_lanes = current_level.lanes
	for lane in current_lanes:
		for wd in lane.waves:
			var cc := (wd as WaveData).credit_curve
			assert(cc.sample(cc.max_domain) as int >= 1, "The end of a curve should be >= 1 so that the credits can always be spent completely")
	
	current_wave_max = 0
	for lane in current_lanes:
		if lane.waves.size() > current_wave_max:
			current_wave_max = lane.waves.size()
	
	current_wave_index = 0
	TrooperSpawner.INST.spawn_points = current_level.spawn_points
	TrooperSpawner.INST.finished.connect(end_wave)


func start_wave() -> void:
	set_build_phase(false)
	SoundBus.play_sound(start_wave_sound)
	if current_wave_index >= current_wave_max:
		return
	print("%s: Wave %s started!" % [name, current_wave_index])
	var current_waves: Array[WaveData] = []
	for spawn_idx in range(current_lanes.size()):
		#this being null is fine because the spawner ignores it
		var wave: WaveData = current_lanes[spawn_idx].waves.get(current_wave_index)
		current_waves.push_back(wave)
	
	Env.INST.last_placed_tower = null
	
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
	current_wave_index += 1
	TrooperSpawner.INST.disable()
	wave_finished.emit()
	
	if current_wave_index >= current_wave_max:
		win_level()
		return
	set_build_phase(true)


func set_build_phase(value: bool) -> void:
	is_build_phase = value
	
	TrooperSpawner.INST.clear_troopers()
	#TrooperSpawner.INST.active = !value
	
	wave_banner.visible = not value
	build_banner.visible = value
	background_banner.visible = true
	phase_transition_timer.start()
	if current_level:
		current_level.set_build_phase(value)


func take_damage(amount: int) -> void:
	if current_hp <= 0:
		return
	current_hp -= amount
	if current_hp <= 0:
		lose_level()


func _on_phase_transition_timeout() -> void:
	wave_banner.visible = false
	build_banner.visible = false
	background_banner.visible = false


func _on_lost_timer_timeout() -> void:
	load_level()
	level_lost_banner.visible = false


func _on_won_timer_timeout() -> void:
	load_level()
	level_won_banner.visible = false


func end_game() -> void:
	print("Game ended")
	end_screen.visible = true
	wave_banner.visible = false
	build_banner.visible = false
	background_banner.visible = false
