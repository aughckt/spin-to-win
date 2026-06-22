class_name BuildVisual
extends Node2D

@export var child: Node2D
@export var mat: ShaderMaterial

@export var gear_visual: GearVisual

@export var clear_color: Color
@export var obstructed_color: Color

@export var gun_data: TowerData

var data: TowerData

func _ready() -> void:
	child.process_mode = Node.PROCESS_MODE_DISABLED
	gear_visual.anim.material = mat.duplicate()

func set_data(tdata: TowerData) -> void:
	for n in child.get_children():
		n.queue_free()
	
	data = tdata
	if data == null:
		return
	
	var tower := data.scene.instantiate() as GenericTower
	child.add_child(tower)
	for n in child.get_children():
		_update_nodes(n)

func _update_nodes(node: Node) -> void:
	if node is Area2D:
		node.queue_free()
		return
	elif node is Sprite2D:
		var sprite := node as Sprite2D
		sprite.material = mat
		assert(sprite.material != null)
	elif node is AnimatedSprite2D:
		var anim_sprite := node as AnimatedSprite2D
		anim_sprite.material = mat
		assert(anim_sprite.material != null)
	
	for n in node.get_children():
		_update_nodes(n)

func _unhandled_input(event: InputEvent) -> void:
	#really dont like this
	if data != gun_data:
		return
	
	#TODO
	if event is InputEventKey:
		var key := (event as InputEventKey).keycode
		match key:
			KEY_UP:
				pass
			KEY_LEFT:
				pass
			KEY_DOWN:
				pass
			KEY_RIGHT:
				pass
	elif event is InputEventMouseButton:
		var button := (event as InputEventMouseButton).button_index
		match button:
			MouseButton.MOUSE_BUTTON_WHEEL_DOWN:
				pass
			MouseButton.MOUSE_BUTTON_WHEEL_UP:
				pass

func _process(_delta: float) -> void:
	var map := Env.INST.gearmap
	var mouse_pos := map.get_local_mouse_position()
	var tile := map.local_to_map(mouse_pos)
	global_position = map.to_global(map.map_to_local(tile))
	
	var can_place_gear := Env.INST.place_gear(tile, true) == ""
	var can_place_tower := data != null && Env.INST.place_tower(tile, true) == ""
	
	gear_visual.visible = Env.INST.gear_kind_at(tile) == -1
	child.visible = Env.INST.get_perms(tile) != Env.BuildPerms.Gears && data != null
	
	if child.visible && gear_visual.visible:
		var total_cost := Env.GEAR_COST + data.cost
		if total_cost > Env.INST.budget:
			(gear_visual.anim.material as ShaderMaterial).set_shader_parameter("color", clear_color if can_place_gear else obstructed_color)
			mat.set_shader_parameter("color", obstructed_color)
			return
	
	var col: Color = clear_color if can_place_gear || can_place_tower else obstructed_color
	mat.set_shader_parameter("color", col)
	(gear_visual.anim.material as ShaderMaterial).set_shader_parameter("color", col)
