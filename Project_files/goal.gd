extends Area2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var tile_size = 16

enum{
	off
	turning_on
	on
}
var state

# Called when the node enters the scene tree for the first time.
func _ready():
	state = off
	$CollisionShape2D.disabled = true
	$Area2D/CollisionShape2D.disabled = true
	$Particles2D.emitting = false
	$Sprite.visible = false
	$Sprite2.visible = true
	position = position.snapped(Vector2.ONE * tile_size)
	position += Vector2.ONE * tile_size/2

func _process(delta):
	if state == off:
		var food_left = get_tree().get_nodes_in_group("Food")
		if len(food_left) == 0:
			state = turning_on
	elif state == turning_on:
		$CollisionShape2D.disabled = false
		$Area2D/CollisionShape2D.disabled = false
		$Particles2D.emitting = true
		$Sprite.visible = true
		$Sprite2.visible = false
		$poweron.volume_db = 0
		$poweron.play()
		state = on
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
