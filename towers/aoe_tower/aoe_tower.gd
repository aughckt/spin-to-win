class_name AOETower
extends GenericTower

@onready var aoe_area: Area2D = %Area2D
@onready var sprite: Sprite2D = $AreaIcon
@onready var megaphone_sprite: AnimatedSprite2D = %AnimatedMegaphone

@export var sound: Sound

const FILE_PATH: String = "res://towers/aoe_tower/speaker_quips.txt"
static var quips: PackedStringArray = FileAccess.get_file_as_string(FILE_PATH).split("\n")

var last_quip_idx: int = -1

const QUIP_SPAWN_DIST: Vector2 = Vector2(50, 100)
const QUIP_SPEED: Vector2 = Vector2(10, 20)

func _process(_delta: float) -> void:
	if is_powered:
		megaphone_sprite.play()
	elif not is_powered:
		megaphone_sprite.stop()

func shoot() -> void:
	sprite.rotate(PI / 4)
	var troopers: Array[Area2D] = aoe_area.get_overlapping_areas()
	for area: Area2D in troopers:
		if area is Trooper:
			print("AOE DAMAGE")
			var trooper: Trooper = area
			trooper.take_damage(data.damage)
	
	SoundBus.play_sound(sound)
	
	var quip := Quip.create()
	quip.set_text(random_quip())
	quip.reparent.call_deferred(Env.INST.quips)
	var dir := Vector2.from_angle(randf_range(0, TAU))
	quip.global_position = global_position + dir * randf_range(QUIP_SPAWN_DIST.x, QUIP_SPAWN_DIST.y)
	quip.vel = dir * randf_range(QUIP_SPEED.x, QUIP_SPEED.y)

func random_quip() -> String:
	var size := quips.size()
	if size == 0:
		return ""
	
	if size == 1:
		return quips[0]
	
	var idx := last_quip_idx
	while idx == last_quip_idx:
		idx = randi_range(0, size - 2) #-2 because godot insists on inserting a line break after the last character
	last_quip_idx = idx
	
	return quips[idx]
