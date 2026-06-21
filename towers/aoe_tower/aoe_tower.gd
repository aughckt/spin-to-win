class_name AOETower
extends GenericTower

var aoe_damage: int = 20
@onready var aoe_area: Area2D = %Area2D
@onready var sprite: Sprite2D = $AreaIcon


func shoot() -> void:
	sprite.rotate(PI / 4)
	var troopers: Array[Area2D] = aoe_area.get_overlapping_areas()
	for area: Area2D in troopers:
		if area is Trooper:
			var trooper: Trooper = area
			trooper.take_damage(aoe_damage)
