extends Node

const MOVE_SPEED: float = 200
@onready var player: Player = $".."
@onready var sprite: AnimatedSprite2D = %AnimatedSprite2D


func _physics_process(_delta: float) -> void:
	var move_dir: Vector2 = Input.get_vector("left","right","up","down")
	player.velocity = move_dir * MOVE_SPEED
	player.move_and_slide()


func _process(_delta: float) -> void:
	if player.velocity.length() == 0 and sprite.is_playing():
		sprite.pause()
	elif player.velocity.length() != 0 and not sprite.is_playing():
		sprite.play()
	
	if player.velocity.y < 0:
		sprite.animation = "walk_up"
		sprite.flip_h = false
	elif player.velocity.y > 0:
		sprite.animation = "walk_down"
		sprite.flip_h = false
	elif player.velocity.x < 0:
		sprite.animation = "walk_right"
		sprite.flip_h = true
	elif player.velocity.x > 0:
		sprite.animation = "walk_right"
		sprite.flip_h = false
		
