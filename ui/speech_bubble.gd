class_name SpeechBubble
extends Node2D

@export var important_label: RichTextLabel
@export var temp_label: RichTextLabel
@export var separator: HSeparator
@onready var talk_timer: Timer = %TalkTimer

var time_left: float = -1

func _ready() -> void:
	talk_timer.timeout.connect(stop_talking)
	clear_text_important()

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
	var guy: Node = get_tree().get_first_node_in_group("TalkyGuy")
	var talky_guy: AnimatedSprite2D = guy as AnimatedSprite2D
	if randf() < 0.8:
		talky_guy.play("normal")
	else:
		talky_guy.play("angry")
	talk_timer.start()


func set_text_important(text: String) -> void:
	important_label.text = text
	important_label.show()
	update_visible()
	var guy: Node = get_tree().get_first_node_in_group("TalkyGuy")
	var talky_guy: AnimatedSprite2D = guy as AnimatedSprite2D
	if randf() < 0.8:
		talky_guy.play("happy")
	else:
		talky_guy.play("normal")
	talk_timer.start()


func clear_text_important() -> void:
	important_label.text = ""
	important_label.hide()
	update_visible()
	var guy: Node = get_tree().get_first_node_in_group("TalkyGuy")
	var talky_guy: AnimatedSprite2D = guy as AnimatedSprite2D
	talky_guy.play("idle")


func update_visible() -> void:
	visible = important_label.visible || temp_label.visible
	separator.visible = important_label.visible && temp_label.visible


func stop_talking() -> void:
	var guy: Node = get_tree().get_first_node_in_group("TalkyGuy")
	var talky_guy: AnimatedSprite2D = guy as AnimatedSprite2D
	talky_guy.play("idle")
