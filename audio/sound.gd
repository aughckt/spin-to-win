class_name Sound
extends Resource

@export var stream: AudioStream
@export var volume_linear: float = 1
@export var pitch_scale: float = 1
@export var max_polyphony: int = 1
##the amount of time that has to pass between 2 instances of the same sound being played.
##if it has not yet passed, the new sound is discarded
@export var min_time_between_s: float = 0
#probably shouldnt be stored here but eh
var last_played: float = 0#-1000
