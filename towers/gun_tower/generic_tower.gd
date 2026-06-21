class_name GenericTower
extends Node2D


var is_powered: bool = false
var shoot_timer: float = 0.0

var data: TowerData

func _physics_process(delta: float) -> void:
	is_powered = Env.INST.is_position_powered(global_position)
	
	if shoot_timer > 0:
		shoot_timer -= delta
	elif is_powered:
		shoot_timer = data.shot_delay_sec
		shoot()


func shoot() -> void:
	print("%s: Generic tower shooting not implemented" % name)
