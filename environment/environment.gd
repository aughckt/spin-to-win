class_name Env #Environment was taken :(
extends Node2D

static var INST: Env

@export var tilemap: TileMapLayer

const directions: Array[Vector2i] = [Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT, Vector2i.UP]
const end_tile_type := 4

##name of the tileset property Type, which is basically just an id that tells troopers what to do
const name_type := "Type"


func _ready() -> void:
	assert(INST == null)
	INST = self


func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		assert(INST == self)
		INST = null

##returns the new target position in global or the given position if its an end tile
func move_target_from_global(global_pos: Vector2) -> Vector2:
	if not tilemap:
		return Vector2i.ZERO
	
	var tile: Vector2i = tilemap.local_to_map(tilemap.to_local(global_pos))
	var tile_data := tilemap.get_cell_tile_data(tile)
	var idx: int = tile_data.get_custom_data(name_type)
	
	if idx == end_tile_type:
		return global_pos
	
	#could walk the path until you reach a tile with a different direction so that the trooper doesnt have to check all the time.
	#also trust that the tiles are set up correctly but that should be super obvious during development because the map would consistently crash
	return tilemap.to_global(tilemap.map_to_local(tile + directions[idx]))
