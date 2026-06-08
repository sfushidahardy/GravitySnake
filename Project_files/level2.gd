extends Node2D



var tile_size = 16
var screen_size = Vector2(800,600)
var window_size = Vector2(400,300)

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

#offset is a function of the initial headposition of the snake?
#background position should only move when snake is within of 12.5 tiles in the x dirction, and 9.35 tiles in y dir
var offset2 = Vector2(-1,-1)*8*tile_size
var offset1 = Vector2(-1,-1)*12*tile_size

# Called when the node enters the scene tree for the first time.

func _ready():
	$background1.position = offset1 + window_size/4  ##THESE ARE BACKGROUND PARALLAX
	$background2.position = offset2 + 3*window_size/8
	$snake.headposition = Vector2(6,34)*tile_size + tile_size*Vector2.ONE/2
	#$snake.headposition = Vector2(40,2)*tile_size + tile_size*Vector2.ONE/2
	$snake.initial_render()
	_on_snake_head_pos($snake.headposition)

func _on_snake_head_pos(headposition):
	var bgposition_shift = parallaxclamp(headposition)
	$background1.position = offset1 + bgposition_shift/2
	$background2.position = offset2 + 3*bgposition_shift/4
	
func parallaxclamp(pos):
	var newx = clamp(pos.x, window_size.x/2, screen_size.x - window_size.x/2)
	var newy = clamp(pos.y, window_size.y/2, screen_size.y - window_size.y/2)
	return Vector2(newx, newy)


func _on_snake_restart_level():
	get_tree().change_scene("res://level2.tscn")


func _on_snake_next_level():
	get_tree().change_scene("res://level3.tscn")
