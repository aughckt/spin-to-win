class_name Level
extends Node2D

@export var level_hp: int = 20
@export var spawn_point: Node2D
@export var tilemap: TileMapLayer


func get_spawn_point() -> Vector2:
	return spawn_point.global_position


func get_tilemap() -> TileMapLayer:
	return tilemap
