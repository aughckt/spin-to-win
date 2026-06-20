class_name Tower
extends Node2D

const SHOOT_TIMER_MAX: float = 1.0
const SHOOT_FORCE: float = 100.0
var is_powered: bool = false
var shoot_timer: float = 1.0
var bullet_scene: PackedScene = preload("res://tower/bullet.tscn")


func _physics_process(delta: float) -> void:
	if shoot_timer > 0:
		shoot_timer -= delta
	elif Env.INST.is_position_powered(global_position):
		shoot()


func shoot() -> void:
	shoot_timer = SHOOT_TIMER_MAX
	var bullet: Bullet = bullet_scene.instantiate()
	add_child(bullet)
	bullet.linear_velocity = (Vector2.UP*SHOOT_FORCE).rotated(rotation)
	bullet.global_position = global_position
