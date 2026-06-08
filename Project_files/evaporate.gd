extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var sprite = get_parent()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func start():
	$fadetween.interpolate_property(sprite, "modulate", Color(1, 1, 1, 1), Color(1, 1, 1, 0), 0.5, Tween.TRANS_LINEAR)
	$positiontween.interpolate_property(sprite, "position", sprite.position, sprite.position + Vector2(0,-30), 0.5, Tween.TRANS_QUAD)
	$fadetween.start()
	$positiontween.start()
