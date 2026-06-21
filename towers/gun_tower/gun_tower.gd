class_name GunTower
extends GenericTower

const SHOOT_FORCE: float = 100.0
var bullet_scene: PackedScene = preload("res://towers/gun_tower/bullet.tscn")
@export var shoot_sound: Sound

func shoot() -> void:
	var bullet: Bullet = Bullet.create()
	bullet.reparent.call_deferred(Env.INST.bullets)
	bullet.dir = (Vector2.UP).rotated(rotation)
	bullet.global_position = global_position
	bullet.damage = data.damage
	
	SoundBus.play_sound(shoot_sound)
