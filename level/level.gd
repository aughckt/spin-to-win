class_name Level
extends Node2D

@export_category("Fixed variables")
@export var env: Env
@export var spawn_point: Node2D

@export_category("Custom stuff")
@export var level_hp: int = 20
@export var wave_list: Array[Curve]
@export var starting_budget: int = 10



func get_spawn_point() -> Vector2:
	return spawn_point.global_position


func set_build_phase(value: bool) -> void:
	env.is_build_phase = value
