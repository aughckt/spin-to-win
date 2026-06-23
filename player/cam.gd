class_name Cam
extends Camera2D

var follow_player: bool
@export var player: Player
var pos: Vector2

func _ready() -> void:
	await get_tree().process_frame
	
	make_current()
	
	#var map := Env.INST.terrainmap
	#var used_rect := map.get_used_rect()
	#var view_rect := Rect2i(map.global_position, map.local_to_map(get_viewport_rect().size))
	#
	#if used_rect.encloses(view_rect):
		#print("ENCLOSES")
		#pos = map.global_position
		#follow_player = false
	#else:
		#print("DOESNT ENCLOSE")
		#follow_player = true
	
	#the stuff above doesnt work and i dont feel like figuring out why
	#were unlikely to make that many small levels anyway
	follow_player = true

func _process(_delta: float) -> void:
	if follow_player:
		global_position = player.global_position
	else:
		global_position = pos
