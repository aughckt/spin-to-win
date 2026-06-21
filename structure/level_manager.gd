class_name LevelManager
extends Node2D

static var INST: LevelManager

@export var current_level_index: int = 0
var level_array: Array[PackedScene] = [
	preload("res://structure/levels/template_level.tscn"),
	preload("res://structure/levels/level_snake.tscn")]
var current_level: Level = null
var current_hp: int = 20
var is_build_phase: bool = true
var current_wave_list: Array[Curve]
var current_wave_index: int = 0

signal wave_finished

func _ready() -> void:
	assert(INST == null)
	INST = self
	
	if current_level == null:
		load_level()


func _input(event: InputEvent) -> void:
	## Debug. Press space to start or end a wave
	if event.is_action_pressed("interact"):
		if is_build_phase:
			start_wave()
		else:
			end_wave()


func win_level() -> void:
	print("%s: Level %s won" % [name, current_level_index])
	current_level.queue_free()
	current_level_index += 1
	load_level()


func lose_level() -> void:
	TrooperSpawner.INST.set_wave(null)
	print("%s: Level %s lost" % [name, current_level_index])
	current_level.queue_free()
	load_level()


func load_level() -> void:
	if Env.INST:
		Env.INST.delete()
	
	if level_array.size() <= current_level_index:
		print("You won the game!")
		return
	current_level = level_array[current_level_index].instantiate()
	set_build_phase(true)
	add_child(current_level)
	current_hp = current_level.level_hp
	current_wave_list = current_level.wave_list
	current_wave_index = 0
	TrooperSpawner.INST.spawn_point = current_level.get_spawn_point()


func start_wave() -> void:
	set_build_phase(false)
	print("%s: Wave %s started!" % [name, current_wave_index])
	TrooperSpawner.INST.set_wave(current_wave_list[current_wave_index])


func end_wave() -> void:
	print("%s: Wave %s ended!" % [name, current_wave_index])
	set_build_phase(true)
	current_wave_index += 1
	TrooperSpawner.INST.set_wave(null)
	wave_finished.emit()
	if current_wave_index >= current_wave_list.size():
		win_level()
		return


func set_build_phase(value: bool) -> void:
	is_build_phase = value
	TrooperSpawner.INST.clear_troopers()
	if current_level:
		current_level.set_build_phase(value)


func take_damage(amount: int) -> void:
	if current_hp <= 0:
		return
	current_hp -= amount
	print("%s: hp is now %s" % [name, current_hp])
	if current_hp <= 0:
		lose_level()
