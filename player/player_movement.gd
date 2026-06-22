class_name PlayerMovement
extends Node

const MOVE_SPEED: float = 200
var can_move: bool = true
@onready var player: Player = $".."
@onready var sprite: AnimatedSprite2D = %AnimatedSprite2D


func _physics_process(_delta: float) -> void:
	if not can_move:
		return
	
	var move_dir: Vector2 = Input.get_vector("left","right","up","down")
	player.velocity = move_dir * MOVE_SPEED
	player.move_and_slide()


func _process(_delta: float) -> void:
	if not can_move:
		sprite.stop()
		return
	
	
	
	if player.velocity.length() == 0 and sprite.is_playing():
		sprite.stop()
	elif player.velocity.length() != 0 and not sprite.is_playing():
		sprite.play()
	
	var move_dir: Vector2 = Vector2(Input.get_axis("left","right"), Input.get_axis("up","down"))
	match move_dir:
		Vector2.UP:
			sprite.animation = "walk_up"
		Vector2.LEFT:
			sprite.animation = "walk_left"
		Vector2.DOWN:
			sprite.animation = "walk_down"
		Vector2.RIGHT:
			sprite.animation = "walk_right"
		Vector2(1, -1):
			sprite.animation = "walk_ne"
		Vector2(1, 1):
			sprite.animation = "walk_se"
		Vector2(-1, -1):
			sprite.animation = "walk_nw"
		Vector2(-1, 1):
			sprite.animation = "walk_sw"
