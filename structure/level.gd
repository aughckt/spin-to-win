class_name Level
extends Node2D

@export_category("Fixed variables")
@export var env: Env
@export var spawn_point_container: Node2D

@export_category("Custom stuff")
@export var level_hp: int = 20
@export var wave_list: Array[Curve]
@export var starting_budget: int = 10

var spawn_points: Array[SpawnPoint] = []


func _ready() -> void:
	LevelManager.INST.wave_finished.connect(_on_wave_finished)
	for child: Node in spawn_point_container.get_children():
		if not child is SpawnPoint:
			continue
		spawn_points.append(child as SpawnPoint)
	
	spawn_marker()


func spawn_marker() -> void:
	for spawn_point: SpawnPoint in spawn_points:
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
