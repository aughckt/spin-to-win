class_name GearSet

var gears: PackedVector2Array
var is_powered: bool

static func create(powered: bool) -> GearSet:
	var gear_set := GearSet.new()
	gear_set.gears = PackedVector2Array()
	gear_set.is_powered = powered
	
	return gear_set

func add_gear(gear: Vector2i) -> void:
	gears.push_back(gear)
