class_name Env # Environment was taken :(
extends Node2D

static var INST: Env

@export var tilemap: TileMapLayer
@export var gearmap: TileMapLayer
@export var gears: Node2D
@export var towers: Node2D
@export var coords_label: Label
@export var budget_label: Label
@export var budget: int = 20

@export var tower_data: TowerData

const GEAR_COST := 2

var tile_to_gear_set: Dictionary[Vector2i, GearSet] = {}
var tile_to_visual: Dictionary[Vector2i, GearVisual] = {}
var tile_to_tower: Dictionary[Vector2i, Node2D] = {}
##true if powered
var ori_gear_state: Dictionary[Vector2i, bool] = {}

const directions: Array[Vector2i] = [Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT, Vector2i.UP]
const end_tile_type := 4

##source id of basic gears in the tileset
const BASIC_GEAR := 0
##source id of origin gears in the tileset
const ORIGIN_GEAR := 1

const ATLAS_COORDS := [Vector2i(0, 0), Vector2i(1, 0)]

##name of the tileset property Type, which is basically just an id that tells troopers what to do
const name_type := "Type"

var is_build_phase: bool = true

###emitted when any origin gear is powered on or off. new_status is true if the power is on, false otherwise.
#signal OriGearPowerSet(tile: Vector2i, new_status: bool)

func _ready() -> void:
	assert(INST == null)
	INST = self
	spend(0) #update budget display
	gearmap.hide()
	#TODO this is pretty inefficient in theory but its only run once per level + the gear map should be close to empty.
	#ideally youd update the gears as you go but eh
	for tile in gearmap.get_used_cells():
		if gear_kind_at(tile) == ORIGIN_GEAR:
			ori_gear_state[tile] = false
			
			var visual := GearVisual.create_ori()
			visual.global_position = gearmap.to_global(gearmap.map_to_local(tile))
			visual.reparent.call_deferred(gears)
			tile_to_visual[tile] = visual

func _process(_delta: float) -> void:
	#could do this through signals or explicit updated but this has a lower risk of introducing bugs
	for gset: GearSet in tile_to_gear_set.values():
		var powered := is_gear_set_powered(gset)
		if powered == gset.is_frozen:
			gset.is_frozen = !powered
			
			if powered:
				for tile in gset.gears:
					tile_to_visual[tile as Vector2i].unfreeze()
			else:
				for tile in gset.gears:
					tile_to_visual[tile as Vector2i].freeze()

func delete() -> void:
	assert(INST == self)
	INST = null


func _physics_process(_delta: float) -> void:

	var mouse_pos := gearmap.get_local_mouse_position()
	var tile := gearmap.local_to_map(mouse_pos)

	coords_label.text = str(tile)

	if Input.is_action_just_pressed("M1") and is_build_phase:
		place_gear(tile)
	elif Input.is_action_just_pressed("M2") and is_build_phase:
		if tile_to_tower.has(tile):
			remove_tower(tile)
		else:
			remove_gear(tile)
	elif Input.is_action_just_pressed("M3"):
		var gset: GearSet = tile_to_gear_set.get(tile)
		if gset != null:
			print("Gear power: %s" % is_gear_set_powered(gset))
		elif ori_gear_state.has(tile):
			toggle_ori(tile)
	elif Input.is_action_just_pressed("SecondaryInteract") and is_build_phase:
		if budget >= tower_data.cost:
			place_tower(tile)


##returns the new target position in global or the given position if its an end tile
func move_target_from_global(global_pos: Vector2) -> Vector2:
	if not tilemap:
		return Vector2i.ZERO

	var tile: Vector2i = tilemap.local_to_map(tilemap.to_local(global_pos))
	var tile_data := tilemap.get_cell_tile_data(tile)
	if not tile_data:
		return global_pos
	var idx: int = tile_data.get_custom_data(name_type)

	if idx == end_tile_type:
		return global_pos

	#could walk the path until you reach a tile with a different direction so that the trooper doesnt have to check all the time.
	#also trust that the tiles are set up correctly but that should be super obvious during development because the map would consistently crash
	return tilemap.to_global(tilemap.map_to_local(tile + directions[idx]))


func place_gear(tile: Vector2i) -> void:
		if gearmap.get_cell_source_id(tile) != -1:
			return
		#only place if you have enough money
		if budget < GEAR_COST:
			print("Not enough money to place gear")
			return


		# none of the neighbours are allowed to be in the same set
		# we cant have more than 1 of the neighbours sets be powered

		var neighbour_sets: Array[GearSet] = []
		var has_powered_neighbour := false
		var neighbour_ori := Vector2i.ZERO
		for candidate: Vector2i in directions:
			candidate += tile
			var gset: GearSet = tile_to_gear_set.get(candidate)
			if gset != null:
				if neighbour_sets.has(gset):
					print("Cannot place gear because it would create a loop")
					return

				if gset.has_ori_gear:
						if has_powered_neighbour:
							print("Cannot place gear because it would connect 2 powered sets")
							return
						else:
							has_powered_neighbour = true
							neighbour_ori = gset.ori_gear_tile

				neighbour_sets.push_back(gset)

			else:
				if gear_kind_at(candidate) == ORIGIN_GEAR:
					if has_powered_neighbour:
						print("Cannot place gear because it would connect 2 powered sets (directly next to ori)")
						return

					has_powered_neighbour = true
					neighbour_ori = candidate

		gearmap.set_cell(tile, gearmap.tile_set.get_source_id(0), ATLAS_COORDS[BASIC_GEAR])
		var visual := GearVisual.create_basic()
		visual.global_position = gearmap.to_global(gearmap.map_to_local(tile))
		visual.reparent.call_deferred(gears)
		tile_to_visual[tile] = visual
		
		match neighbour_sets.size():
			0:
				#create new set
				var new_set := GearSet.create(has_powered_neighbour, neighbour_ori)
				new_set.add_gear(tile)
				tile_to_gear_set[tile] = new_set

				
				if is_gear_set_powered(new_set):
					visual.unfreeze()
			1:
				#add to set
				var gear_set := neighbour_sets[0]

				if has_powered_neighbour:
					assert(!gear_set.has_ori_gear || gear_set.ori_gear_tile == neighbour_ori)
					gear_set.set_ori_gear(neighbour_ori)


				gear_set.add_gear(tile)
				tile_to_gear_set[tile] = gear_set

				
				if is_gear_set_powered(gear_set):
					visual.unfreeze()
			_:
				#merge all of the sets
				var new_set := GearSet.create(has_powered_neighbour, neighbour_ori)

				for gset in neighbour_sets:
					for gear in gset.gears:
						#i mean surely we wouldnt run into rounding errors right
						tile_to_gear_set[gear as Vector2i] = new_set

					new_set.gears.append_array(gset.gears)

				new_set.gears.append(tile)
				tile_to_gear_set[tile] = new_set

		
		assert(tile_to_gear_set.get(tile) != null)
		
		#adjust budget display
		spend(GEAR_COST)

		assert(log_set_count())

func remove_gear(tile: Vector2i) -> void:
	#only gear in set -> erase (i think this is implicit due to gc)
	#check if this has >1 neighbours, if it does the set is split, otherwise just remove tile
	var old_set: GearSet = tile_to_gear_set.get(tile)
	if old_set == null:
		return
	tile_to_visual[tile].remove()
	tile_to_visual.erase(tile)
	
	if old_set.gears.size() == 1:
		#refund budget
		spend(-GEAR_COST)
		
		tile_to_gear_set.erase(tile)
		gearmap.erase_cell(tile)
		assert(log_set_count())
		return

	var next_to_origin_gear := false
	var neighbours: Array[Vector2i] = []
	for candidate in directions:
		candidate += tile
		var gset: GearSet = tile_to_gear_set.get(candidate)
		if gset != null:
			assert(gset == old_set)
			neighbours.push_back(candidate)

		if gear_kind_at(candidate) == ORIGIN_GEAR:
			assert(!next_to_origin_gear)
			next_to_origin_gear = true

	#just remove the current tile from the set
	if neighbours.size() == 1:
		var removed_successfully := old_set.gears.erase(tile)
		assert(removed_successfully)

		if next_to_origin_gear:
			assert(old_set.has_ori_gear)
			old_set.clear_ori_gear()

		tile_to_gear_set.erase(tile)
		
		#refund budget
		spend(-GEAR_COST)

		gearmap.erase_cell(tile)
		assert(log_set_count())
		return

	#split up the old set
	for ntile in neighbours:
		var new_set := GearSet.create(false)
		tile_to_gear_set[ntile] = new_set
		build_set_recursive(ntile, tile, new_set)

		#a little counter intuitive but this basically invalidates the sets state
		#and its corrected the next time process is run
		new_set.is_frozen = is_gear_set_powered(new_set)
		
		print("Create set: %s" % new_set.gears)
	
	tile_to_gear_set.erase(tile)

	#refund budget
	spend(-GEAR_COST)

	assert(!tile_to_gear_set.values().has(old_set))

	for gear in old_set.gears:
		var gset: GearSet = tile_to_gear_set.get(gear)
		if gset == old_set:
			printerr("problem at tile %s" % gear)


	gearmap.erase_cell(tile)
	assert(log_set_count())

func build_set_recursive(tile: Vector2i, previous_tile: Vector2i, gset: GearSet) -> void:
	gset.gears.push_back(tile)
	tile_to_gear_set[tile] = gset

	for candidate in directions:
		candidate += tile
		if candidate == previous_tile:
			continue

		match gear_kind_at(candidate):
			BASIC_GEAR:
				build_set_recursive(candidate, tile, gset)
			ORIGIN_GEAR:
				gset.set_ori_gear(candidate)

func gear_kind_at(tile: Vector2i) -> int:
	var atlas_coords := gearmap.get_cell_atlas_coords(tile)
	match atlas_coords:
		- Vector2i.ONE:
			return -1
		ATLAS_COORDS[BASIC_GEAR]:
			return 0
		ATLAS_COORDS[ORIGIN_GEAR]:
			return 1

	assert(false)
	return 0

func is_gear_set_powered(gear_set: GearSet) -> bool:
	#return gear_set.has_ori_gear && ori_gear_state[gear_set.ori_gear_tile]
	#long version in case of bugs
	if !gear_set.has_ori_gear:
		return false

	var state: bool = ori_gear_state.get(gear_set.ori_gear_tile)
	if state == null:
		push_error("Unknown origin gear at %s" % gear_set.ori_gear_tile)
		return false

	return state

func set_ori_on(tile: Vector2i) -> void:
	assert(ori_gear_state.has(tile))
	ori_gear_state[tile] = true

	tile_to_visual[tile].unfreeze()
	
func set_ori_off(tile: Vector2i) -> void:
	assert(ori_gear_state.has(tile))
	ori_gear_state[tile] = false
	tile_to_visual[tile].freeze()

func toggle_ori(tile: Vector2i) -> void:
	assert(ori_gear_state.has(tile))
	if ori_gear_state[tile]:
		set_ori_off(tile)
	else:
		set_ori_on(tile)

##walks every gear set so its pretty imperformant, only use from within assert so it isnt included in the release
func log_set_count() -> bool:
	var sets: Array[GearSet] = []
	for gset: GearSet in tile_to_gear_set.values():
		if !sets.has(gset):
			sets.push_back(gset)

	print("Set count: %s" % sets.size())

	return true


func is_position_powered(pos: Vector2) -> bool:
	var tile: Vector2i = gearmap.local_to_map(pos)
	
	if not tile_to_gear_set.has(tile):
		return false
	
	var gear_set: GearSet = tile_to_gear_set[tile]
	return is_gear_set_powered(gear_set)


func spend(credits: int) -> void:
	budget -= credits
	budget = max(budget, 0)
	budget_label.text = str(budget)

func place_tower(tile: Vector2i) -> void:
	if gear_kind_at(tile) != BASIC_GEAR:
		return
	
	if tile_to_tower.has(tile):
		return
	
	spend(tower_data.cost)
	
	var tower: Node2D = tower_data.scene.instantiate()
	towers.add_child(tower)
	tower.global_position = gearmap.to_global(gearmap.map_to_local(tile))
	
	tile_to_tower[tile] = tower

func remove_tower(tile: Vector2i) -> void:
	var tower: Node2D = tile_to_tower.get(tile)
	if tile == null:
		return
	
	#BUG (or possibility of): store the cost of a tower in the tower itself
	#so that you dont accidentally refund the wrong amount
	spend(-tower_data.cost)
	tile_to_tower.erase(tile)
	tower.queue_free()
