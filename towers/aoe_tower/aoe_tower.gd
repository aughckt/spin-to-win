class_name AOETower
extends GenericTower

@onready var aoe_area: Area2D = %Area2D
@onready var sprite: Sprite2D = $AreaIcon
@onready var megaphone_sprite: AnimatedSprite2D = %AnimatedMegaphone

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
			var trooper: Trooper = area
			trooper.take_damage(data.damage)
