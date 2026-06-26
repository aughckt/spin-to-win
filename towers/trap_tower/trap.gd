class_name Trap
extends Area2D

static var pool: Pool
const scene: PackedScene = preload("res://towers/trap_tower/trap.tscn")
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

signal triggered(trap: Trap)

const STUN_TIME_S: float = 1.5
var damage: int

var active: bool

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	
	var random: float = randf()
	if random > 0.66:
		animated_sprite.play("default")
	elif random > 0.33:
		animated_sprite.play("default2")
	else:
		animated_sprite.play("default3")

func _on_area_entered(area: Area2D) -> void:
	if area is not Trooper:
		return
	
	var trooper := area as Trooper
	if trooper.stun_time_s > 0:
		#dont want to waste trap on a stunned trooper
		return
	
	trooper.take_damage(damage)
	trooper.stun_time_s = STUN_TIME_S
	triggered.emit(self)

static func _get_pool() -> Pool:
	if pool == null:
		pool = Pool.create(scene)
	return pool


static func create() -> Trap:
	var trap: Trap = _get_pool().get_inst()
	trap.active = true
	return trap

func remove() -> void:
	if !active:
		return
	active = false
	_get_pool().pool(self)
