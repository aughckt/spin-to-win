class_name GearVisual
extends Node2D

@export var sprite: Sprite2D
@export var anim: AnimatedSprite2D
var frozen: bool = true
var is_origin: bool = false

static var scene: PackedScene = preload("res://environment/gears/gear_visual.tscn")
static var pool: Pool

static func create_basic() -> GearVisual:
	var visual: GearVisual = _get_pool().get_inst()
	visual.is_origin = false
	#visual.sprite.frame = 0
	visual.anim.animation = "default"
	return visual

static func create_ori() -> GearVisual:
	var visual: GearVisual = _get_pool().get_inst()
	#visual.sprite.frame = 1
	visual.is_origin = true
	visual.anim.animation = "ori_gear"
	return visual

static func create_underground() -> GearVisual:
	var visual: GearVisual = _get_pool().get_inst()
	visual.is_origin = false
	visual.anim.animation = "underground"
	return visual

static func _get_pool() -> Pool:
	if pool == null:
		pool = Pool.create(scene)
	
	return pool

func remove() -> void:
	_get_pool().pool(self)


func freeze() -> void:
	anim.pause()
	frozen = true

func unfreeze() -> void:
	var gearmap := Env.INST.gearmap
	var tile := gearmap.local_to_map(gearmap.to_local(global_position))
	var x_rem := tile.x & 1
	var y_rem := tile.y & 1
	
	anim.play("", 1 if x_rem == y_rem else -1)
	frozen = false
