class_name GunTower
extends GenericTower

const SHOOT_FORCE: float = 100.0
@export var bullet_sprite: Texture2D
@onready var shooter_sprite: AnimatedSprite2D = %AnimatedShooter
@export var shoot_sound: Sound
@onready var rotate_area: Area2D = %RotateArea
var gun_rotation: float = PI/2



@export var piercing: int = 0



#func _ready() -> void:
	#rotate_area.input_event.connect(_on_rotate_area_input)


func shoot() -> void:
	shooter_sprite.play()
	var bullet: Bullet = Bullet.create()
	bullet.reparent.call_deferred(Env.INST.bullets)
	bullet.dir = (Vector2.RIGHT).rotated(-gun_rotation)
	bullet.global_position = global_position
	bullet.damage = data.damage
	bullet.piercing = piercing
	bullet.sprite.texture = bullet_sprite
	
	var dir := bullet.dir as Vector2i #if you dont cast it to ints you get -0, i love floating point precision errors
	if abs(dir.x) > abs(dir.y):
		bullet.sprite.rotation_degrees = 90
		bullet.sprite.flip_v = dir.x < 0
	else:
		bullet.sprite.rotation_degrees = 0
		bullet.sprite.flip_v = dir.y > 0
	
	SoundBus.play_sound(shoot_sound)


#func _on_rotate_area_input(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	#if event.is_action_pressed("scroll_up"):
		#rotate_gun(-PI/2)
	#elif event.is_action_pressed("scroll_down"):
		#rotate_gun(PI/2)

func set_gun_rotation(rad: float) -> void:
	gun_rotation = wrapf(rad + PI, 0.0, TAU) - PI
	if gun_rotation == -PI:
		gun_rotation = PI
	
	shooter_sprite.stop()
	
	if gun_rotation == PI:
		shooter_sprite.animation = "shoot_left"
	elif gun_rotation == PI/2:
		shooter_sprite.animation = "shoot_up"
	elif gun_rotation == 0.0:
		shooter_sprite.animation = "shoot_right"
	elif gun_rotation == -PI/2:
		shooter_sprite.animation = "shoot_down"

func rotate_gun(amount: float) -> void:
	set_gun_rotation(gun_rotation + amount)
