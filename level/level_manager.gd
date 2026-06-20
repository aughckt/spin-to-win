class_name LevelManager
extends Node2D

static var INST: LevelManager

@export var current_level_index: int = 0
var level_array: Array[PackedScene] = [
	preload("res://level/template_level.tscn"),
	preload("res://level/level_snake.tscn")]
var current_level: Level = null
var current_hp: int = 20


func _ready() -> void:
	assert(INST == null)
	INST = self
	
	if current_level == null:
		load_level()


func win_level() -> void:
	print("%s: Level %s won" % [name, current_level_index])
	current_level.queue_free()
	current_level_index += 1
	load_level()


func lose_level() -> void:
	print("%s: Level %s lost" % [name, current_level_index])
	current_level.queue_free()
	load_level()


func load_level() -> void:
	if level_array.size() <= current_level_index:
		print("You won the game!")
		TrooperSpawner.INST.clear_troopers()
		return
	
	current_level = level_array[current_level_index].instantiate()
	add_child(current_level)
	current_hp = current_level.level_hp
	
	TrooperSpawner.INST.clear_troopers()
	TrooperSpawner.INST.spawn_point = current_level.get_spawn_point()
	Env.INST.tilemap = current_level.get_tilemap()


func take_damage(amount: int) -> void:
	if current_hp <= 0:
		return
	current_hp -= amount
	print("%s: hp is now %s" % [name, current_hp])
	if current_hp <= 0:
		win_level()
