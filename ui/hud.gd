class_name Hud
extends Control

@export var towers: Array[TowerData] = []
@export var tower_panels: Control
@export var tower_panel_scene: PackedScene

@export var health_label: Label
@export var money_label: Label

@export var start_wave_button: TextureButton
@export var continue_wave_button: TextureButton
@export var pause_button: TextureButton

@export var speech_bubble: SpeechBubble

@export var nose_target: Control

signal data_selected (data: TowerData)

#the node that actually defines the huds visible shape and size
@export var actual_shape: Control

@export var health_icon: TextureRect
@export var health_chunk_parent: HBoxContainer
var health_chunk_scene: PackedScene = preload("res://ui/health_chunk.tscn")
var health_chunk_empty: Texture = preload("res://ui/UI_HealthChunk_Empty.png")
var curr_health: int

@onready var level_name: Label = $PanelContainer/MarginContainer/VBoxContainer/LevelName
@onready var wave_count: Label = $PanelContainer/MarginContainer/VBoxContainer/WaveCount


func _ready() -> void:
	show()
	LevelManager.INST.wave_finished.connect(_on_wave_finished)
	start_wave_button.pressed.connect(_on_start_wave_button_pressed)
	
	for node in health_chunk_parent.get_children():
		if node != health_icon:
			node.queue_free()
	curr_health = LevelManager.INST.current_hp
	assert(curr_health <= 10)
	for i in range(10):
		var hc: TextureRect = health_chunk_scene.instantiate()
		if i >= curr_health:
			hc.texture = health_chunk_empty
		health_chunk_parent.add_child(hc)
	
	pause_button.pressed.connect(_on_pause_button_pressed)
	pause_button.process_mode = Node.PROCESS_MODE_ALWAYS
	continue_wave_button.pressed.connect(_on_continue_button_pressed)
	continue_wave_button.process_mode = Node.PROCESS_MODE_ALWAYS
	
	for node in tower_panels.get_children():
		if node is TowerPanel:
			#i want them to be visible in the editor and also im lazy
			node.queue_free()
	
	add_tower_data(null) #gear
	for tower in towers:
		assert(tower != null)
		add_tower_data(tower)

func _process(_delta: float) -> void:
	if not Env.INST:
		return
	
	var new_hp := LevelManager.INST.current_hp
	if new_hp != curr_health && new_hp >= 0:
		while new_hp < curr_health:
			#remember that this is effectively 1-indexed because of the icon
			var trect: TextureRect = health_chunk_parent.get_child(curr_health)
			trect.texture = health_chunk_empty
			curr_health -= 1
	
	health_label.text = str(LevelManager.INST.current_hp)
	money_label.text = str(Env.INST.budget)
	
	level_name.text = LevelManager.INST.current_level.name
	wave_count.text = "Wave %s / %s" % [LevelManager.INST.current_wave_index, LevelManager.INST.current_wave_max]

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		LevelManager.INST.wave_finished.disconnect(_on_wave_finished)

func add_tower_data(data: TowerData) -> void:
	var panel: TowerPanel = tower_panel_scene.instantiate()
	panel.set_tower_data(data)
	panel.selected.connect(_on_panel_selected)
	tower_panels.add_child(panel)

func _on_panel_selected(data: TowerData) -> void:
	data_selected.emit(data)

func _on_start_wave_button_pressed() -> void:
	start_wave_button.hide()
	pause_button.show()
	LevelManager.INST.start_wave()


func _on_wave_finished() -> void:
	start_wave_button.show()
	pause_button.hide()
	assert(!get_tree().paused)

func _on_pause_button_pressed() -> void:
	var tree := get_tree()
	tree.paused = true
	pause_button.visible = false
	continue_wave_button.visible = true


func _on_continue_button_pressed() -> void:
	var tree := get_tree()
	tree.paused = false
	pause_button.visible = true
	continue_wave_button.visible = false
