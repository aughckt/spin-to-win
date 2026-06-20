class_name TrooperSpawner
extends Node2D

#TODO Currently the logic is really simple, just spawn one every 2 seconds. 

static var INST: TrooperSpawner
const MAX_TIMER: float = 3.0
@export var spawn_point: Vector2 
var timer: float = 0.0
var enabled: bool = true
@onready var trooper_scene: PackedScene = preload("res://troopers/trooper.tscn")


func _ready() -> void:
	assert(INST == null)
	INST = self


func _physics_process(delta: float) -> void:
	if not enabled: 
		return
	
	timer -= delta
	if timer <= 0:
		timer = MAX_TIMER
		spawn_trooper()


func spawn_trooper() -> void:
	var trooper: Trooper = trooper_scene.instantiate()
	add_child(trooper)
	trooper.global_position = spawn_point
	trooper.target_pos = trooper.global_position 


func clear_troopers() -> void:
	timer = 0.0
	for child: Node in get_children():
		child.queue_free()
