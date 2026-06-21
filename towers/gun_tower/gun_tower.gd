class_name GunTower
extends GenericTower

const SHOOT_FORCE: float = 100.0
var bullet_scene: PackedScene = preload("res://towers/gun_tower/bullet.tscn")
@onready var shooter_sprite: AnimatedSprite2D = %AnimatedShooter




func shoot() -> void:
	shooter_sprite.play("shoot_up")
	var bullet: Bullet = Bullet.create()
	bullet.reparent.call_deferred(Env.INST.bullets)
	bullet.dir = (Vector2.UP).rotated(rotation)
	bullet.global_position = global_position
	bullet.damage = data.damage
