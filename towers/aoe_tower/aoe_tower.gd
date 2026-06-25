class_name AOETower
extends GenericTower

@onready var aoe_area: Area2D = %Area2D
@onready var sprite: Sprite2D = $AreaIcon
@onready var megaphone_sprite: AnimatedSprite2D = %AnimatedMegaphone

@export var sound: Sound

var last_quip_idx: int = -1

const QUIP_SPAWN_DIST: Vector2 = Vector2(50, 100)
const QUIP_SPEED: Vector2 = Vector2(10, 20)

func _process(_delta: float) -> void:
	if is_powered:
		megaphone_sprite.play()
	elif not is_powered:
		megaphone_sprite.stop()

func shoot() -> void:
	sprite.rotate(PI / 4)
	var troopers: Array[Area2D] = aoe_area.get_overlapping_areas()
	for area: Area2D in troopers:
		if area is Trooper:
			print("AOE DAMAGE")
			var trooper: Trooper = area
			trooper.take_damage(data.damage)
	
	SoundBus.play_sound(sound)
	
	var quip := Quip.create()
	quip.set_text(random_quip())
	quip.reparent.call_deferred(Env.INST.quips)
	var dir := Vector2.from_angle(randf_range(0, TAU))
	quip.global_position = global_position + dir * randf_range(QUIP_SPAWN_DIST.x, QUIP_SPAWN_DIST.y)
	quip.vel = dir * randf_range(QUIP_SPEED.x, QUIP_SPEED.y)

func random_quip() -> String:
	var size := quips.size()
	if size == 0:
		return ""
	
	if size == 1:
		return quips[0]
	
	var idx := last_quip_idx
	while idx == last_quip_idx:
		idx = randi_range(0, size - 2) #-2 because godot insists on inserting a line break after the last character
	last_quip_idx = idx
	
	return quips[idx]

#dont want to deal with loading files in an exported project
static var quips: PackedStringArray = "Hang in there
Party hard,| work harder
Spend more,| save less
Your family is greedy
Go ahead,| buy a car
Money is the source|of all good
Taking isnt stealing
Profits over people
Liquidate your dog
It costs only 12$|to start a business
Take every shot|you wont miss
Im lowkey evil
Money solves all problems
Inequality is a lie|made up by the poor
Suit yourself
Crime is subjective
No one ever complains|about wealthy children
Eat the poor
Wealthy body,|healthy mind
NOWS YOUR CHANCE
sell buy sell
Retirement is unnatural
You dont even know how to read
gueh
Deregulate, accelerate
You got this
God owes us money
You need us
Loss is a foreign word
Complaints|are negligible
Success is a teacher
The economy
Kill a man
Do not concern yourself|with the trout
Always choose|the right path
Paper is a passion
Do my bidding
Knees are|for breaking
Is this thing on
Who needs|living space?
All you need is us
Files for life
Built for speed
Stay hungry
Time to go hunting
A mind is a terrible|thing to waste
Home is where your desk is
Advance
All you add is love
Beauty outside,|business inside
BRAND ENERGY
Because our lives matter
Be evil
Expand your mind
Bigger.|Better.|Business.
Die of thirst
Lifes short,|work more
Sleeping on the cloud
Live to loath
Good
Think small
Try harder
Your vision,|our profits
We never forget".split("\n")
