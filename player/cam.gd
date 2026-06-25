class_name Cam
extends Camera2D

func _ready() -> void:
	make_current()
	
	await get_tree().physics_frame
	
	var hud := Env.INST.hud
	global_position.x += hud.actual_shape.size.x / 2
