class_name WaveMarker
extends Node2D

#WARNING: this code is just copy pasted from the trooper

@export var move_speed: float = 100.0

#minimum distance towards target
@export var min_dist_to_target: float = 0.1

@export var particles: GPUParticles2D

var target_pos: Vector2
var walk_normal: Vector2

var spawn_point: SpawnPoint
signal end_reached(marker: WaveMarker)

static var pool: Pool
const scene: PackedScene = preload("res://environment/wave_marker.tscn")

func _ready() -> void:
	target_pos = global_position
	walk_normal = Vector2.ZERO

func _physics_process(delta: float) -> void:
	if not Env.INST:
		return
	
	var new_pos := global_position + walk_normal * move_speed * delta
	
	if (global_position.distance_squared_to(target_pos) < global_position.distance_squared_to(new_pos) #this check makes sure we dont move past the point
	|| global_position.distance_squared_to(target_pos) < min_dist_to_target * min_dist_to_target):
		global_position = target_pos
		target_pos = Env.INST.move_target_from_global(target_pos)
		
		#this shouldnt fail due to rounding errors because in move_target_from_global were returning the exact vector we pass in
		if target_pos == global_position:
			reach_end()
		
		walk_normal = global_position.direction_to(target_pos)
		new_pos = global_position + walk_normal * move_speed * delta
	
	global_position = new_pos


static func _get_pool() -> Pool:
	if pool == null:
		pool = Pool.create(scene)
	
	return pool

func reach_end() -> void:
	end_reached.emit(self)

static func create() -> WaveMarker:
	var marker := _get_pool().get_inst() as WaveMarker
	marker.target_pos = marker.global_position
	marker.walk_normal = Vector2.ZERO
	marker.spawn_point = null
	
	#probably not optimal but 100 times better than particles randomly disappearing
	marker.particles.visibility_rect = Env.INST.get_viewport_rect()
	
	return marker

func remove() -> void:
	_get_pool().pool(self)
