extends StaticBody2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var _animation_player = $AnimationPlayer
var tile_size = 16

# Called when the node enters the scene tree for the first time.
func _ready():
	_animation_player.play("diamond")
	position = position.snapped(Vector2.ONE * tile_size)
	position += Vector2.ONE * tile_size/2
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
func _on_snake_eat_food(headposition):
	if position == headposition:
		$CollisionShape2D.queue_free()
		play_sfx()
		$fadetween.interpolate_property($Sprite, "modulate", Color(1, 1, 1, 1), Color(1, 1, 1, 0), 0.5, Tween.TRANS_LINEAR)
		$scaletween.interpolate_property($Sprite, "scale", Vector2(1,1), Vector2(4,4), 0.5, Tween.TRANS_LINEAR)
		$fadetween.start()
		$scaletween.start()
		$terminationtimer.start()

func play_sfx():
	$gem.pitch_scale = 0.8
	$gem.volume_db = -20
	$gem.play()


func _on_terminationtimer_timeout():
	queue_free()
