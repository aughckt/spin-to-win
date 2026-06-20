class_name Level
extends Node2D

@export var level_hp: int = 20
@export var spawn_point: Node2D
@export var wave_list: Array[Curve]
@export var env: Env


func get_spawn_point() -> Vector2:
	return spawn_point.global_position


func set_build_phase(value: bool) -> void:
	env.is_build_phase = value
