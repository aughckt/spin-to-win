class_name Hud
extends Control

@export var towers: Array[TowerData] = []
@export var tower_panels: Control
@export var tower_panel_scene: PackedScene

@export var health_label: Label
@export var money_label: Label

@export var start_wave_button: Button
@export var pause_button: Button

signal data_selected (data: TowerData)

func _ready() -> void:
	show()
	LevelManager.INST.wave_finished.connect(_on_wave_finished)
	start_wave_button.pressed.connect(_on_start_wave_button_pressed)
	
	pause_button.pressed.connect(_on_pause_button_pressed)
	pause_button.process_mode = Node.PROCESS_MODE_ALWAYS
	
	for node in tower_panels.get_children():
		if node is TowerPanel:
			#i want them to be visible in the editor and also im lazy
			node.queue_free()
	
	for tower in towers:
		add_tower_data(tower)

func _process(_delta: float) -> void:
	health_label.text = str(LevelManager.INST.current_hp)
	money_label.text = str(Env.INST.budget)

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
	if tree.paused:
		pause_button.text = "Pause"
	else:
		pause_button.text = "Continue"
	tree.paused = !tree.paused
