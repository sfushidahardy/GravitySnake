extends Node2D

#signal gravity_swap
var tile_size = 16
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimationPlayer.play("gravdown")
	position = position.snapped(Vector2.ONE * tile_size)
	position += Vector2.ONE * tile_size/2
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func reverse_gravity():
	change_animation()

#func _on_snake_head_pos(headposition):
#	headposition += Vector2(0,8)
#	if headposition == position:
#		change_animation()
#		emit_signal("gravity_swap")

func change_animation():
	if $AnimationPlayer.get_current_animation() == "gravdown":
		$AnimationPlayer.stop()
		$AnimationPlayer.play("gravup")
	else:
		$AnimationPlayer.stop()
		$AnimationPlayer.play("gravdown")
