class_name TrapTower
extends GenericTower

const TRAP_SCENE: PackedScene = preload("res://towers/trap_tower/trap.tscn")

var positions: Array[Vector2] = []
const MAX_DIFF_FROM_TARGET_POS: float = 15
@onready var animated_spites: AnimatedSprite2D = $AnimatedSprite2D
@export var book_sound: Sound 
@onready var spawn_timer: Timer = $SpawnTimer

const MAX_TRAPS: int = 5
var traps: Array[Trap] = []

func _ready() -> void:
	LevelManager.INST.wave_started.connect(_on_wave_started)
	
	animated_spites.animation_finished.connect(_on_animation_finished)
	animated_spites.play("Idle")
	spawn_timer.timeout.connect(_on_timer_timeout)
	
	var map := Env.INST.tilemap #arrow map, only want to place on path tiles
	var tile := map.local_to_map(map.to_local(global_position))
	
	var tiles: Array[Vector2i] = [Vector2i(1, 1), Vector2i(-1, 1), Vector2i(-1, -1), Vector2i(1, -1)]
	for i in range(tiles.size()):
		tiles[i] += tile
	tiles.append_array(map.get_surrounding_cells(tile))
	
	for t in tiles:
		if map.get_cell_source_id(t) != -1:
			positions.push_back(map.to_global(map.map_to_local(t)))

func shoot() -> void:
	if positions.size() == 0:
		return
	
	animated_spites.play("Dispense")
	
	spawn_timer.start()
	

func destroy_trap(trap: Trap) -> void:
	trap.triggered.disconnect(_on_trap_triggered)
	traps.erase(trap)
	trap.remove()

func _on_trap_triggered(trap: Trap) -> void:
	destroy_trap(trap)

func _on_wave_started() -> void:
	while !traps.is_empty():
		destroy_trap(traps[0])
	assert(traps.size() == 0)


func _on_animation_finished() -> void:
	animated_spites.play("Idle")


func _on_timer_timeout() -> void:
	var pos: Vector2 = positions.pick_random()
	pos += Vector2.RIGHT.rotated(randf_range(0, TAU)) * randfn(0, MAX_DIFF_FROM_TARGET_POS)
	SoundBus.play_sound(book_sound)
	
	var trap := Trap.create()
	trap.global_position = pos
	trap.damage = data.damage
	trap.reparent.call_deferred(Env.INST.bullets)
	
	traps.push_back(trap)
	trap.triggered.connect(_on_trap_triggered)
	
	#still want something to happen instead of the tower just not doing anything
	if traps.size() > MAX_TRAPS:
		_on_trap_triggered(traps[0])
