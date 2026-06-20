class_name Pool

var _instances: Array[Node]
var _scene: PackedScene


static func create(scene: PackedScene) -> Pool:
	var p := Pool.new()
	p._scene = scene
	p._instances = []
	return p


func get_inst() -> Node:
	var inst: Node
	
	if !_instances.is_empty():
		inst = _instances.pop_back()
		#why does this not autocomplete this is concerning
		inst.reparent.call_deferred(GeneralPool)
	else:
		inst = _scene.instantiate()
		GeneralPool.add_child.call_deferred(inst)
	
	inst.set_deferred("process_mode", Node.PROCESS_MODE_INHERIT)
	return inst


func pool(node: Node) -> void:
	node.reparent.call_deferred(GeneralPool)
	_instances.push_back(node)
	node.set_deferred("process_mode", Node.PROCESS_MODE_DISABLED)
