class_name TowerPanel
extends Control

signal selected(data: TowerData)

@export var button: Button
var data: TowerData

@export var name_label: Label
@export var cost_label: Label
@export var icon_rect: TextureRect

const gear_icon: Texture = preload("res://environment/gears/gear.png")

func _ready() -> void:
	button.pressed.connect(_on_button_pressed)

func _on_button_pressed() -> void:
	selected.emit(data)

func set_tower_data(tdata: TowerData) -> void:
	data = tdata
	if data != null:
		name_label.text = data.name
		cost_label.text = "Cost: %s" % data.cost
		icon_rect.texture = data.icon
	else:
		name_label.text = "Gear"
		cost_label.text = "Cost: %s" % Env.GEAR_COST
		icon_rect.texture = gear_icon
