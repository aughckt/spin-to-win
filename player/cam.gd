class_name Cam
extends Camera2D

const cursor_normal: Texture = preload("res://ui/cursor_normal.png")
const cursor_pressed: Texture = preload("res://ui/cursor_pressed.png")

func _ready() -> void:
	make_current()
	Input.set_custom_mouse_cursor(cursor_normal)
	await get_tree().physics_frame
	
	var hud := Env.INST.hud
	global_position.x += hud.actual_shape.size.x / 2
	
	process_mode = Node.PROCESS_MODE_ALWAYS

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("M1"):
		Input.set_custom_mouse_cursor(cursor_pressed)
	elif Input.is_action_just_released("M1"):
		Input.set_custom_mouse_cursor(cursor_normal)
