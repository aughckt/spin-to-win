class_name Bullet
extends Area2D

const speed: float = 900
const life_time: float = 5.0
var time_left: float
var damage: int

var dir: Vector2
 
static var pool: Pool
const scene: PackedScene = preload("res://towers/gun_tower/bullet.tscn")

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	time_left -= delta
	if time_left <= 0:
		remove()
	
	global_position += dir * speed * delta


static func _get_pool() -> Pool:
	if pool == null:
		pool = Pool.create(scene)
	return pool

func _on_area_entered(area: Area2D) -> void:
	if area is Trooper:
		(area as Trooper).take_damage(damage)
	
	remove()

func _on_body_entered(_body: Node2D) -> void:
	remove()


static func create() -> Bullet:
	var bullet: Bullet = _get_pool().get_inst()
	
	bullet.time_left = life_time
	bullet.dir = Vector2.ZERO
	
	return bullet

func remove() -> void:
	_get_pool().pool(self)
