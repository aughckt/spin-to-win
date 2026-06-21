class_name GenericTower
extends Node2D


@export var cost: int = 5 
@export var shoot_timer_max: float = 1.0
var is_powered: bool = false
var shoot_timer: float = 0.0


func _physics_process(delta: float) -> void:
	if shoot_timer > 0:
		shoot_timer -= delta
	elif Env.INST.is_position_powered(global_position):
		shoot_timer = shoot_timer_max
		shoot()


func shoot() -> void:
	print("%s: Generic tower shooting not implemented" % name)
