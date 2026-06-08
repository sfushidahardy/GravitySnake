extends Area2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var dir = Vector2(1,0)
var life = 0
onready var deathtimer = $Timer
var projtimername

var state = 1

var rng = RandomNumberGenerator.new()
var rand = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	state = 1
	$Particles2D.set_one_shot(true)
	rng.randomize()

func newdirection(direction):
	dir = direction

func _on_projectile_area_entered(area):
	if area.is_in_group("enemies"):
		area.die()
	projectile_death_sequence()

func projectile_death_sequence():
	state = 0
	$CollisionShape2D.queue_free()
	play_poof()
	$Particles2D.restart()
	$Sprite.queue_free()
	deathtimer.start()

func _on_Timer_timeout():
	queue_free()
	
func play_poof():
	$Sounds/poof1.pitch_scale = rng.randf_range(0.9, 1.1)
	$Sounds/poof1.volume_db = 0
	$Sounds/poof1.play()
