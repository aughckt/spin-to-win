class_name Nose
extends Sprite2D

const TURN_RATE: float = 5
const ACCEL: float = 10
const TARGET_SPEED: float = 600
const MIN_TARGET_DIST: float = 5
##just a failsafe
const LIFE_TIME: float = 5 

var target_point: Vector2
var vel: Vector2
var time: float

static var pool: Pool
const scene: PackedScene = preload("res://ui/nose/nose.tscn")

@export var sound: Sound

func _process(delta: float) -> void:
	if time < 0 || global_position.distance_squared_to(target_point) <= MIN_TARGET_DIST * MIN_TARGET_DIST:
		Env.INST.budget += 1
		SoundBus.play_sound(sound)
		remove()
		return
	
	var to_target := target_point - global_position
	
	var angle := vel.angle()
	var target_angle := to_target.angle()
	var new_angle := lerp_angle(angle, target_angle, TURN_RATE * delta)
	
	vel = Vector2.RIGHT.rotated(new_angle) * lerpf(vel.length(), TARGET_SPEED, ACCEL * delta)
	global_position += vel * delta
	
	time -= delta

static func _get_pool() -> Pool:
	if pool == null:
		pool = Pool.create(scene)
	return pool

static func create() -> Nose:
	var nose: Nose = _get_pool().get_inst()
	nose.time = LIFE_TIME
	return nose

func remove() -> void:
	_get_pool().pool(self)
