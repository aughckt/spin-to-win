class_name Tower
extends GenericTower

const SHOOT_FORCE: float = 100.0
var bullet_scene: PackedScene = preload("res://tower/bullet.tscn")


func shoot() -> void:
	var bullet: Bullet = bullet_scene.instantiate()
	add_child(bullet)
	bullet.linear_velocity = (Vector2.UP*SHOOT_FORCE).rotated(rotation)
	bullet.global_position = global_position
