class_name DeathVisual
extends Node2D

const scene: PackedScene = preload("res://troopers/death_visual.tscn")

@export var sprite: AnimatedSprite2D

var ori_set: bool = false
var ori: Vector2

const SPEED: float = 500
const TARGET_DIST: float = 3000

static var pool: Pool

static func _get_pool() -> Pool:
	if pool == null:
		pool = Pool.create(scene)
	return pool

static func create() -> DeathVisual:
	var dv: DeathVisual = _get_pool().get_inst()
	dv.sprite.play("default")
	dv.ori_set = false
	return dv

func _process(delta: float) -> void:
	if !ori_set:
		ori = global_position
		ori_set = true
	
	global_position.y -= SPEED * delta
	if ori.y - global_position.y >= TARGET_DIST:
		print("FREE THINGY")
		_get_pool().pool(self)
