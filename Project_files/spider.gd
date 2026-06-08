extends KinematicBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var tile_size = 16
onready var ray = $RayCast2D
onready var portalray = $portalray

var walkspeed = 1
var fallspeed = 2

var gravvector = {up: Vector2.UP, down: Vector2.DOWN}
enum{
	up
	down
}
var gravity = down

var dirvector = {left: Vector2.LEFT, right: Vector2.RIGHT}
enum{
	left
	right
}
var dir = left

enum{
	alive
	dead
}
var state = alive
var freefalling = false
var portals_enabled = true

# Called when the node enters the scene tree for the first time.
func _ready():
	position = position.snapped(Vector2.ONE * tile_size)
	position += Vector2.ONE * tile_size/2

func _process(delta):
	check_footing()
	if freefalling == false:
		if state == alive:
			position.y = round_to_tile_size(int(position.y))
			check_turn(dir)
			walk(dirvector[dir])
	else:
		fall(gravvector[gravity])

func walk(dirr):
	position = check_for_portal(dirr,position)
	position += dirr*walkspeed

func fall(dirr):
	position += dirr*fallspeed

func check_turn(dirr):
	ray.position = Vector2(0,0)
	ray.cast_to = dirvector[dirr]*tile_size/2
	ray.force_raycast_update()
	if ray.is_colliding():
		turn()
	else:
		ray.position = dirvector[dirr]*tile_size/2
		ray.cast_to = gravvector[gravity]*tile_size
		ray.force_raycast_update()
		if !ray.is_colliding():
			turn()

func turn():
	if dir == left:
		dir = right
	else: dir = left

func check_footing():
	ray.position = Vector2(0,0)
	ray.cast_to = gravvector[gravity] * tile_size
	ray.force_raycast_update()
	if ray.is_colliding():
		freefalling = false
	else: freefalling = true
	
func gravity_swap():
	if gravity == up:
		gravity = down
		$Sprite.set_flip_v(false)
	else:
		gravity = up
		$Sprite.set_flip_v(true)

func round_to_tile_size(n):
	n -= n % tile_size
	n += tile_size/2
	return n
	
func check_for_portal(dirr, pos):
	if portals_enabled == false:
		return pos
	else:
		portalray.position = -dirr * tile_size/4
		portalray.cast_to = dirr * tile_size/4
		portalray.force_raycast_update()
		var new_pos = pos
		if portalray.is_colliding():
			var portal_in_use = portalray.get_collider()
			new_pos += do_portal(portal_in_use)
			portals_enabled = false
			$portaltimer.start()
		return new_pos

func do_portal(portal_in_use):
	var displacement = Vector2(0,0)
	for portal in get_tree().get_nodes_in_group("Portal"):
		if portal != portal_in_use:
			if portal.id == portal_in_use.id:
				displacement = portal.position - portal_in_use.position
	return displacement

func die():
	state = dead
	$splat.volume_db = 10
	$splat.play()
	$CollisionShape2D.queue_free()
	var gravdir = 0
	if gravity == down:
		gravdir = 1
	else: gravdir = -1
	$Particles2D.process_material.gravity = Vector3(0,50,0)*gravdir
	$Particles2D.restart()
	$Sprite.visible = false
	#$Sprite2.visible = true
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_portaltimer_timeout():
	portals_enabled = true
