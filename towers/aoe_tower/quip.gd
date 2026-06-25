class_name Quip
extends Node2D

const BBCODE_PREFIX: String = "\n[shake rate=10][wave amp=10.0 freq=3.5]"
@export var label: RichTextLabel

static var pool: Pool
const scene: PackedScene = preload("res://towers/aoe_tower/quip.tscn")

const LIFE_TIME_S: Vector2 = Vector2(0.8, 1.2)
var life_time: float
var vel: Vector2

static var replace: int = "|".to_ascii_buffer()[0]
static var lbreak: int = "\n".to_ascii_buffer()[0]

func _process(delta: float) -> void:
	if life_time < 0:
		remove()
		return
	life_time -= delta
	
	global_position += vel * delta

func set_text(text: String) -> void:
	label.text = BBCODE_PREFIX + text.replace_char(replace, lbreak) + "\n "

static func _get_pool() -> Pool:
	if pool == null:
		pool = Pool.create(scene)
	return pool

static func create() -> Quip:
	var quip: Quip = _get_pool().get_inst()
	quip.life_time = randf_range(LIFE_TIME_S.x, LIFE_TIME_S.y)
	return quip

func remove() -> void:
	_get_pool().pool(self)
