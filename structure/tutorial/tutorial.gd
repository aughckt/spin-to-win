class_name Tutorial
extends Node

var env: Env

var lines := "and youre the new guy
basically youll have a bunch|of lunatics coming down|the lanes here
its your job to make|them emplyable
also about the|rc robot thing
the best i have is that it adds another degree to|any technically illegal activity|you might have to do on behalf of the company
tried to ask legal but they wouldnt tell me
said it would \"make me complicit\"
anyway you know wasd right?
@MOVE
ok good
you see that orange gear thing over there?
we call these \"origin gears\"
if you go next to it and|hold space youll start spinning it
@SPIN
@BUILD_UNLOCK
you can also place stuff with the mouse
@BUILD_GEAR
if you connect some|gears to the origin|theyll start spinning too
@GEAR_SPIN
(it may be difficult to grasp|but youre somehow far|from the bottom of the barrel)
now if you select a tower|from the menu you|can place it on any gear
just be mindful,|the gear needs to be spinning|for the tower to be active
@TOWER_SHOOT
you can rotate towers|with the mouse wheel|or arrow keys
if you want to sell|a gear or tower you can|do that with right click
also be on the lookout for noses
theyre basically concentrated joy,|extremely valuable
you can use them to buy|more towers and gears
youll see
ok i think thats everything
press the start wave button|when youre ready and|we'll unleash the horde
good luck".split("\n")

var current_line: int = 0
var finished: bool = false
var speech_bubble: SpeechBubble

func _ready() -> void:
	env = Env.INST
	env.hud.start_wave_button.hide()
	env.is_build_phase = false
	env.build_visual.hide()
	speech_bubble = env.hud.speech_bubble
	
	advance()

func advance(force: bool = false) -> void:
	if finished:
		return
	
	if force:
		current_line += 1
	
	if current_line >= lines.size():
		env.hud.start_wave_button.show()
		env.build_visual.show()
		env.is_build_phase = true
		finished = true
		speech_bubble.clear_text_important()
		print("TUTORIAL DONE")
		return
	
	if lines[current_line].begins_with("@"):
		return
	
	speech_bubble.set_text_important(lines[current_line].replace_char(Quip.replace, Quip.lbreak))
	current_line += 1

func cond_advance() -> void:
	match lines[current_line].trim_suffix("\n"):
		"@MOVE":
			if Input.get_vector("left", "right", "up", "down") as Vector2i != Vector2i.ZERO:
				advance(true)
		"@SPIN":
			if env.ori_gear_state.values().any(func (active: bool) -> bool: return active):
				advance(true)
		"@BUILD_UNLOCK":
			env.build_visual.show()
			env.is_build_phase = true
			advance(true)
		"@BUILD_GEAR":
			if env.tile_to_gear_set.values().size() > 0:
				advance(true)
		"@GEAR_SPIN":
			if env.tile_to_gear_set.values().any(func (gs: GearSet) -> bool: 
				return gs.has_ori_gear && env.ori_gear_state[gs.ori_gear_tile]
				):
				env.hud.add_tower_data(preload("res://towers/tower_data/gun_tower_data.tres"))
				advance(true)
		"@TOWER_SHOOT":
			if env.tile_to_tower.values().any(func (tower: GenericTower) -> bool:
				if !env.is_position_powered(tower.global_position):
					return false
				
				#good enough
				return tower.shoot_timer <= get_process_delta_time()
			):
				advance(true)
		_:
			assert(false, "unhandled special line: %s" % lines[current_line])

func _physics_process(_delta: float) -> void:
	if current_line < lines.size() && lines[current_line].begins_with("@"):
		cond_advance()
		return
	
	if Input.is_action_just_pressed("interact"):
		advance()
