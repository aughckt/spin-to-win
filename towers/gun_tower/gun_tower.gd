class_name GunTower
extends GenericTower

const SHOOT_FORCE: float = 100.0
var bullet_scene: PackedScene = preload("res://towers/gun_tower/bullet.tscn")
@onready var shooter_sprite: AnimatedSprite2D = %AnimatedShooter
@export var shoot_sound: Sound
@onready var rotate_area: Area2D = %RotateArea
var gun_rotation: float = PI/2


func _ready() -> void:
	rotate_area.input_event.connect(_on_rotate_area_input)


func shoot() -> void:
	shooter_sprite.play()
	var bullet: Bullet = Bullet.create()
	bullet.reparent.call_deferred(Env.INST.bullets)
	bullet.dir = (Vector2.RIGHT).rotated(-gun_rotation)
	print(bullet.dir)
	bullet.global_position = global_position
	bullet.damage = data.damage
	
	SoundBus.play_sound(shoot_sound)


func _on_rotate_area_input(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event.is_action_pressed("scroll_up"):
		rotate_gun(-PI/2)
	elif event.is_action_pressed("scroll_down"):
		rotate_gun(PI/2)


func rotate_gun(amount: float) -> void:
	shooter_sprite.stop()
	gun_rotation = wrapf(gun_rotation + amount + PI, 0.0, TAU) - PI
	if gun_rotation == -PI:
		gun_rotation = PI
	
	print(gun_rotation)
	
	if gun_rotation == PI:
		shooter_sprite.animation = "shoot_left"
	elif gun_rotation == PI/2:
		shooter_sprite.animation = "shoot_up"
	elif gun_rotation == 0.0:
		shooter_sprite.animation = "shoot_right"
	elif gun_rotation == -PI/2:
		shooter_sprite.animation = "shoot_down"
