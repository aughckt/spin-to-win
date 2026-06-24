class_name Jumbo
extends Trooper

const scene_jumbo: PackedScene = preload("res://troopers/jumbo.tscn")
static var pool_jumbo: Pool

static func _get_pool() -> Pool:
	print("JUMBO")
	if pool_jumbo == null:
		pool_jumbo = Pool.create(scene_jumbo)
	return pool_jumbo

static func create() -> Trooper:
	var jumbo: Jumbo = _get_pool().get_inst()
	jumbo.setup()
	return jumbo

func remove() -> void:
	super.remove()


static func cost() -> int:
	return 4
