class_name SpawnPoint
extends Node2D

@export var entry_dir: EntryDir


#not the most efficient setup but its convenient
@export var sprite_up: Node2D
@export var sprite_left: Node2D
@export var sprite_right: Node2D

var anim: AnimatedSprite2D
@onready var particles: GPUParticles2D = $GPUParticles2D
@onready var spawn_particles: GPUParticles2D = $GPUParticles2D2

enum EntryDir {
	Up,
	Left,
	Right
}

#either "up" or "left"
var anim_postfix: String

func _ready() -> void:
	match entry_dir:
		EntryDir.Up:
			anim_postfix = "up"
			anim = sprite_up
		EntryDir.Left:
			anim_postfix = "left"
			anim = sprite_left
		EntryDir.Right:
			anim_postfix = "left"
			anim = sprite_right
	
	if anim == null:
		return
	
	anim.show()
	anim.animation_finished.connect(_on_intro_finished)
	anim.play("intro_%s" % anim_postfix)

func _on_intro_finished() -> void:
	anim.animation_finished.disconnect(_on_intro_finished)
	anim.animation_finished.connect(_on_door_open_finished)
	anim.play("door_open_%s" % anim_postfix)

func _on_door_open_finished() -> void:
	anim.animation_finished.disconnect(_on_door_open_finished)
	anim.play("idle_%s" % anim_postfix)


func play_animation() -> void:
	particles.restart()
	particles.emitting = true


func play_spawn_aimation() -> void:
	spawn_particles.restart()
	spawn_particles.emitting = true
