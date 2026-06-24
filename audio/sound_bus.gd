class_name _SoundBus
extends Node

var stream_to_player: Dictionary[AudioStream, AudioStreamPlayer] = {}

##only one combination of settings is supported per stream.
func play_sound(sound: Sound) -> void:
	var stream := sound.stream
	if stream == null:
		return
	
	var player := stream_to_player.get(stream) as AudioStreamPlayer
	if player == null:
		player = AudioStreamPlayer.new()
		player.stream = stream
		player.process_mode = Node.PROCESS_MODE_ALWAYS
		stream_to_player[stream] = player
		add_child(player)
	
	player.volume_linear = sound.volume_linear
	player.pitch_scale = sound.pitch_scale
	player.play()


func stop_sound(sound: Sound) -> void:
	if stream_to_player.has(sound.stream):
		var player: AudioStreamPlayer = stream_to_player.get(sound.stream)
		if player:
			player.stop()
