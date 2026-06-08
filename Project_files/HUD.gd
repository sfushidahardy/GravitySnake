extends CanvasLayer

const heart = preload("res://heart.tscn")

var tile_size = 16
var heart_spacing = 20
var first_heart_pos = Vector2(16,16)

var lives = 3
var hearts = []

# Called when the node enters the scene tree for the first time.
func _ready():
	for n in lives:
		var grabbedinstance = heart.instance()
		hearts.append([grabbedinstance, first_heart_pos + Vector2.RIGHT * n * heart_spacing])
		grabbedinstance.position = hearts[n][1]
		self.add_child(grabbedinstance)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_snake_lost_a_life():
	hearts[-1][0].queue_free()
	hearts.remove(len(hearts)-1)
