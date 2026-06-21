class_name Bullet
extends Area2D

const speed: float = 500
const damage: int = 25
const life_time: float = 5.0
var time_left: float

var dir: Vector2
 
static var pool: Pool
const scene: PackedScene = preload("res://towers/gun_tower/bullet.tscn")

func _physics_process(delta: float) -> void:
	time_left -= delta
	if time_left <= 0:
		remove()
	
	global_position += dir * speed * delta


static func _get_pool() -> Pool:
	if pool == null:
		pool = Pool.create(scene)
	return pool


static func create() -> Bullet:
	var bullet: Bullet = _get_pool().get_inst()
	
	bullet.time_left = life_time
	bullet.dir = Vector2.ZERO
	
	return bullet

func remove() -> void:
	_get_pool().pool(self)
