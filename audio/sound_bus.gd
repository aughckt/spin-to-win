class_name _SoundBus
extends Node

var stream_to_player: Dictionary[AudioStream, AudioStreamPlayer] = {}

##only one combination of settings is supported per stream.
func play_sound(sound: Sound) -> void:
	if sound == null:
		return
	
	var stream := sound.stream
	if stream == null:
		return
	
	var curr_time_ms := Time.get_ticks_msec()
	var last_played_ms := sound.last_played
	var diff := curr_time_ms - last_played_ms
	if diff < sound.min_time_between_s * 1000:
		return
	sound.last_played = curr_time_ms
	
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


func stop_all_sounds() -> void:
	for audio_stream: AudioStream in stream_to_player.keys():
		stream_to_player[audio_stream].stop()
