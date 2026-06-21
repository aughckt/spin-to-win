class_name Trooper
extends Area2D

@export var move_speed: float = 100.0

#minimum distance towards target
@export var min_dist_to_target: float = 0.1

var target_pos: Vector2
var walk_normal: Vector2
const MAX_HP: int = 100
var hp: int = MAX_HP
@export var sprite: AnimatedSprite2D

func _ready() -> void:
	target_pos = global_position
	walk_normal = Vector2.ZERO
	area_entered.connect(_on_area_entered)


func _physics_process(delta: float) -> void:
	if not Env.INST:
		return
	
	var new_pos := global_position + walk_normal * move_speed * delta
	
	if (global_position.distance_squared_to(target_pos) < global_position.distance_squared_to(new_pos) #this check makes sure we dont move past the point
	|| global_position.distance_squared_to(target_pos) < min_dist_to_target * min_dist_to_target):
		global_position = target_pos
		target_pos = Env.INST.move_target_from_global(target_pos)
		
		#this shouldnt fail due to rounding errors because in move_target_from_global were returning the exact vector we pass in
		if target_pos == global_position:
			reach_end()
			
		
		
		walk_normal = global_position.direction_to(target_pos)
		
		var directions: PackedVector2Array = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]
		var best_idx: int = 0
		var best_dot: float = directions[best_idx].dot(walk_normal)
		for idx in range(4):
			var dot := directions[idx].dot(walk_normal)
			if dot > best_dot:
				best_dot = dot
				best_idx = idx
		
		var animation := ""
		match best_idx:
			0:
				animation = "walk_up"
			1:
				animation = "walk_down"
			2:
				animation = "walk_right"
			3:
				animation = "walk_right"
		sprite.flip_h = best_idx == 2
		sprite.play(animation)
		
		new_pos = global_position + walk_normal * move_speed * delta
	
	global_position = new_pos


func reach_end() -> void:
	LevelManager.INST.take_damage(1)
	pool_self()


func _on_area_entered(area: Area2D) -> void:
	if area is Bullet:
		take_damage(Bullet.damage)
		(area as Bullet).remove()


func take_damage(amount: int) -> void:
	hp -= amount
	#youre not tweening it, right? this just shrinks the clown as it takes damage?
	#sprite.scale = Vector2(hp/100.0,hp/100.0)
	
	
	
	if hp <= 0:
		Env.INST.budget += 1
		pool_self()


func pool_self() -> void:
	TrooperSpawner.INST.pool_trooper(self)
	set_deferred("monitorable", false)
	set_deferred("monitoring", false)


func setup() -> void:
	#sprite.scale = Vector2(1,1)
	set_deferred("monitorable", true)
	set_deferred("monitoring", true)
	hp = MAX_HP
