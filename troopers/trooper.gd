class_name Trooper
extends Node2D

@export var move_speed: float = 100.0

#minimum distance towards target
@export var min_dist_to_target: float = 0.1

var target_pos: Vector2
var walk_normal: Vector2


func _ready() -> void:
	target_pos = global_position
	walk_normal = Vector2.ZERO


func _physics_process(delta: float) -> void:
	var new_pos := global_position + walk_normal * move_speed * delta
	
	if (global_position.distance_squared_to(target_pos) < global_position.distance_squared_to(new_pos) #this check makes sure we dont move past the point
	|| global_position.distance_squared_to(target_pos) < min_dist_to_target * min_dist_to_target):
		global_position = target_pos
		target_pos = Env.INST.move_target_from_global(target_pos)
		
		#this shouldnt fail due to rounding errors because in move_target_from_global were returning the exact vector we pass in
		if target_pos == global_position:
			LevelManager.INST.take_damage(1)
			queue_free()
		
		walk_normal = global_position.direction_to(target_pos)
		new_pos = global_position + walk_normal * move_speed * delta
	
	global_position = new_pos
