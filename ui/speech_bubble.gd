class_name SpeechBubble
extends Node2D

@export var label: RichTextLabel

var time_left: float = -1

func _process(delta: float) -> void:
	if time_left < 0:
		return
	
	time_left -= delta
	if time_left < 0:
		time_left = -1
		hide()

func set_text(text: String, uptime: float = -1) -> void:
	label.text = text
	time_left = uptime
	show()
