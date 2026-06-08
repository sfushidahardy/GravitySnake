extends Timer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var tile_size = 16
var proj_speed = 4
var projtimerlength = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	projtimerlength = (tile_size/(proj_speed))*(1.0/30)
	wait_time = projtimerlength

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
