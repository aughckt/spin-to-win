class_name Trap
extends Area2D

static var pool: Pool
const scene: PackedScene = preload("res://towers/trap_tower/trap.tscn")

signal triggered(trap: Trap)

const STUN_TIME_S: float = 1.5
var damage: int

func _ready() -> void:
	area_entered.connect(_on_area_entered)

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
	return _get_pool().get_inst()

func remove() -> void:
	_get_pool().pool(self)
