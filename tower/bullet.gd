class_name Bullet
extends RigidBody2D

var life_time: float = 5.0


func _physics_process(delta: float) -> void:
	life_time -= delta
	if life_time <= 0:
		queue_free()
