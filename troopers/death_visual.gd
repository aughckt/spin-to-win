class_name DeathVisual
extends Node2D

const scene: PackedScene = preload("res://troopers/death_visual.tscn")

@export var sprite: AnimatedSprite2D
@export var poof_sprite: AnimatedSprite2D

var ori_set: bool = false
var ori: Vector2

const SPEED: float = 500
const TARGET_DIST: float = 3000

static var pool: Pool

static func _get_pool() -> Pool:
	if pool == null:
		pool = Pool.create(scene)
	return pool


static func create(is_jumbo: bool) -> DeathVisual:
	var dv: DeathVisual = _get_pool().get_inst()
	if is_jumbo:
		dv.sprite.play("jumbo")
		dv.poof_sprite.play("default1")
	else:
		dv.sprite.play("little")
		dv.poof_sprite.play("default2")
	dv.ori_set = false
	return dv


func _ready() -> void:
	poof_sprite.animation_finished.connect(poof_finished)


func _process(delta: float) -> void:
	if !ori_set:
		ori = global_position
		ori_set = true
	
	poof_sprite.global_position = ori
	
	global_position.y -= SPEED * delta
	if ori.y - global_position.y >= TARGET_DIST:
		_get_pool().pool(self)


func poof_finished() -> void:
	poof_sprite.visible = false
