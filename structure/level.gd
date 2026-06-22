class_name Level
extends Node2D

@export_category("Fixed variables")
@export var env: Env
@export var spawn_points: Node2D

@export_category("Custom stuff")
@export var level_hp: int = 20
@export var wave_list: Array[Curve]
@export var starting_budget: int = 10
@export var lane_amount: int = 1


func _ready() -> void:
	assert(wave_list.size() % lane_amount == 0)

func set_build_phase(value: bool) -> void:
	env.is_build_phase = value
