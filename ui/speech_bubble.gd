class_name SpeechBubble
extends Node2D

@export var important_label: RichTextLabel
@export var temp_label: RichTextLabel
@export var separator: HSeparator

var time_left: float = -1

func _process(delta: float) -> void:
	if time_left < 0:
		return
	
	time_left -= delta
	if time_left < 0:
		time_left = -1
		temp_label.hide()
		update_visible()

func set_text_temp(text: String, uptime: float = -1) -> void:
	temp_label.text = text
	time_left = uptime
	temp_label.show()
	update_visible()

func set_text_important(text: String) -> void:
	important_label.text = text
	important_label.show()
	update_visible()

func clear_text_important() -> void:
	important_label.text = ""
	important_label.hide()
	update_visible()

func update_visible() -> void:
	visible = important_label.visible || temp_label.visible
	separator.visible = important_label.visible && temp_label.visible
