class_name Level
extends Node2D

@export_category("Fixed variables")
@export var env: Env
@export var spawn_points: Node2D

@export_category("Custom stuff")
@export var level_hp: int = 20
@export var wave_list: Array[Curve]
@export var starting_budget: int = 10
@export var lane_amount: int = 1

func _ready() -> void:
	spawn_marker()
	LevelManager.INST.wave_finished.connect(_on_wave_finished)
	assert(wave_list.size() % lane_amount == 0)


func spawn_marker() -> void:
	var point_array: Array[Node] = spawn_points.get_children()
	for index: int in range(lane_amount):
		var child: Node = point_array[index]
		if not child is Node2D:
			continue
		var spawn_point: Node2D = child as Node2D
		var marker := WaveMarker.create()
		marker.reparent.call_deferred(spawn_point)
		marker.end_reached.connect(_on_marker_end_reached)
		marker.global_position = spawn_point.global_position
		marker.target_pos = marker.global_position


func set_build_phase(value: bool) -> void:
	env.is_build_phase = value


func _on_marker_end_reached(marker: WaveMarker) -> void:
	marker.end_reached.disconnect(_on_marker_end_reached)
	marker.remove()
	
	if LevelManager.INST.is_build_phase:
		spawn_marker()


func _on_wave_finished() -> void:
	spawn_marker()
