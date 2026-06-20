class_name GearSet

var gears: PackedVector2Array

var has_ori_gear: bool
var ori_gear_tile: Vector2i

var is_frozen := true

static func create(has_origin_gear: bool, origin_gear_tile: Vector2i = Vector2i.ZERO) -> GearSet:
	var gear_set := GearSet.new()
	gear_set.gears = PackedVector2Array()
	
	gear_set.has_ori_gear = has_origin_gear
	gear_set.ori_gear_tile = origin_gear_tile
	
	return gear_set

func add_gear(gear: Vector2i) -> void:
	gears.push_back(gear)

func set_ori_gear(tile: Vector2i) -> void:
	has_ori_gear = true
	ori_gear_tile = tile

func clear_ori_gear() -> void:
	has_ori_gear = false
	ori_gear_tile = Vector2.ZERO
