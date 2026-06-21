extends Node

@onready var interact_area: Area2D = %InteractArea
@onready var movement: PlayerMovement = %PlayerMovement
@onready var player: Player = $".."
var interacting: bool = false
var current_ori_gear: Vector2i = Vector2i.ZERO


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		var gears: Array[Node2D] = interact_area.get_overlapping_bodies()
		
		if not gears.is_empty():
			interacting = true
			movement.can_move = false
			
			# Get closest ori_gear -> activate it.
			var ori_gears: Array[Vector2i] = Env.INST.ori_gear_state.keys()
			var closest_gear: Vector2i = ori_gears[0]
			var min_distance: float = INF
			for gear: Vector2i in ori_gears:
				var distance: float = (player.global_position - Vector2(gear)*64).length()
				if distance < min_distance:
					min_distance = min_distance
					closest_gear = gear
			current_ori_gear = closest_gear
			Env.INST.set_ori_on(current_ori_gear)
			 
	elif event.is_action_released("interact"):
		interacting = false
		movement.can_move = true
		if current_ori_gear != Vector2i.ZERO:
			Env.INST.set_ori_off(current_ori_gear)
