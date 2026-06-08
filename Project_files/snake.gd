extends Node2D

#COLLISIONS
#object collision (the ground, etc) is layer 1
#food collision is layer 2
#dangerous object collision is layer 3

signal eat_food(headposition)
signal head_pos(headposition)
signal lost_a_life
signal restart_level
signal next_level

const snakehead = preload("res://snakehead.tscn")
const snakebodybent = preload("res://snakebodybent.tscn")
const snakebodystraight = preload("res://snakebodystraight.tscn")
const snaketail = preload("res://snaketail.tscn")
const shake = preload("res://shake.tscn")
const evaporate = preload("res://evaporate.tscn")
const projectile = preload("res://projectile.tscn")
const projtimer = preload("res://projectiletimer.tscn")
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var inputs = {"ui_right": Vector2.RIGHT,
			"ui_left": Vector2.LEFT,
			"ui_up": Vector2.UP,
			"ui_down": Vector2.DOWN}

var screen_size = Vector2(800,600)
var tile_size = 16
var proj_speed = 4
var can_move_now = true
var can_shoot_now = true
var can_fall_now = true
var freefalling = false
var fallingfruitcount = 0
#var snakebodcoords = [position]
var snakebodcoords = [0,0,0,0]
var snakespritenames = []
var snakeboddirections = [Vector2.RIGHT, Vector2.RIGHT, Vector2.RIGHT, Vector2.RIGHT]
var shakernames = []
var evaporaternames = []
var evapsegment = 0
var headposition = Vector2(0,0)
var portal_id = 0

var dmgimmunity = false
var lives = 3

var rng = RandomNumberGenerator.new()
var rand = 0

onready var ray = $RayCast2D
onready var foodray = $RayCast2D2
onready var deathray = $RayCast2D3
onready var portalray = $RayCast2D4
onready var goalray = $RayCast2D5

enum{
	alive
	dead
}
var state = alive

enum{
	up
	down
}
var gravity = down

# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()
	position = Vector2.ZERO
	#headposition = Vector2(2,2)*tile_size + tile_size*Vector2.ONE/2
	#snakebodcoords[0] = headposition
	#snakebodcoords[1] = headposition - tile_size*Vector2(1,0)
	#snakebodcoords[2] = headposition - tile_size*Vector2(2,0)
	#snakebodcoords[-1] = headposition - tile_size*Vector2(3,0)
	#render_snake()
	
func initial_render():
	snakebodcoords[0] = headposition
	snakebodcoords[1] = headposition - tile_size*Vector2(1,0)
	snakebodcoords[2] = headposition - tile_size*Vector2(2,0)
	snakebodcoords[-1] = headposition - tile_size*Vector2(3,0)
	render_snake()
	$Camera2D.position = headposition

func render_snake():
	render_head()
	render_body_elsewhere()
	render_tail()

#Make instance
#var GrabbedInstance = MySmokeResource.instance()
	#You could now make changes to the new instance if you wanted
 #   CurrentEntry.name = "SmokeA"
	#Attach it to the tree
  #  self.add_child(GrabbedInstance)

func render_tail():
	var grabbedinstance = snaketail.instance()
	grabbedinstance.position = snakebodcoords[-1]
	var rot = snakeboddirections[-2]
	var x = -rot.x
	var y = -rot.y
	grabbedinstance.set_transform(Transform2D(Vector2(-x, -y), Vector2(y, -x), snakebodcoords[-1]))
	self.add_child(grabbedinstance)
	snakespritenames.append(grabbedinstance)

func render_head():
	var grabbedinstance = snakehead.instance()
	grabbedinstance.position = snakebodcoords[0]
	var rot = snakeboddirections[0]
	var x = -rot.x
	var y = -rot.y
	grabbedinstance.set_transform(Transform2D(Vector2(y, -x), Vector2(x, y), headposition))
	self.add_child(grabbedinstance)
	snakespritenames.insert(0,grabbedinstance)
	
func render_body_elsewhere():
	for pos in len(snakebodcoords)-2:
		var grabbedinstance = snakebodystraight.instance()
		grabbedinstance.position = snakebodcoords[pos+1]
		self.add_child(grabbedinstance)
		snakespritenames.insert(pos+1,grabbedinstance)

func render_body(n):
	var dir1 = snakeboddirections[n-1]
	var dir2 = snakeboddirections[n]
	if dir1.dot(dir2) != 0:
		var grabbedinstance = snakebodystraight.instance()
		grabbedinstance.position = snakebodcoords[n]
		var x = dir1.x
		var y = dir1.y
		grabbedinstance.set_transform(Transform2D(Vector2(x, y), Vector2(-y, x), snakebodcoords[n]))
		self.add_child(grabbedinstance)
		snakespritenames[n].queue_free()
		snakespritenames.remove(n)
		snakespritenames.insert(n,grabbedinstance)
	else:
		var grabbedinstance = snakebodybent.instance()
		grabbedinstance.position = snakebodcoords[n]
		if dir1.x > 0 or dir2.x < 0:
			if dir1.y < 0 or dir2.y > 0:
				grabbedinstance.set_transform(Transform2D(Vector2(1, 0), Vector2(0, -1), snakebodcoords[n]))
		elif dir1.x < 0 or dir2.x > 0:
			if dir1.y < 0 or dir2.y > 0:
				grabbedinstance.set_transform(Transform2D(Vector2(-1,0), Vector2(0,-1), snakebodcoords[n]))
			else: grabbedinstance.set_transform(Transform2D(Vector2(-1,0), Vector2(0,1),snakebodcoords[n]))
		self.add_child(grabbedinstance)
		snakespritenames[n].queue_free()
		snakespritenames.remove(n)
		snakespritenames.insert(n,grabbedinstance)
	
#func render_body():
#	var grabbedinstance = snakebody.instance()
#	grabbedinstance

func purge_tail():
	snakespritenames[-1].queue_free()
	snakespritenames[-2].queue_free()
	snakespritenames.remove(len(snakespritenames)-1)
	snakespritenames.remove(len(snakespritenames)-1)
	snakebodcoords.remove(len(snakebodcoords)-1)
	render_tail()

func attach_head():
	snakebodcoords.insert(0, headposition)
	render_head()
	render_body(1)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
func _physics_process(_delta):
	for proj in get_tree().get_nodes_in_group("projectiles"):
		if proj.state == 1:
			if proj.projtimername.time_left == 0: 
				proj.position = check_for_portal(proj.dir,proj.position)
				if actual_portal_check(proj.dir, proj.position) == true:
					proj.projtimername.start()
			else: print(proj.position, proj.projtimername.time_left)
			if gravity == up:
				proj.position += proj.dir*proj_speed + Vector2.UP*proj.life/16
				proj.life += 1
			else:
				proj.position += proj.dir*proj_speed + Vector2.DOWN*proj.life/16
				proj.life += 1
	if freefalling == false and state == alive:
		check_moveability()
		if check_for_dmg() == true and dmgimmunity == false:
				dmgprocess()
		if check_for_goal() == true:
				goalprocess()
	if can_shoot_now == true and state == alive:
		if Input.is_action_pressed("ui_select"):
			can_shoot_now = false
			$shootingcooldown.start()
			shoot(snakeboddirections[0])
	if can_move_now == true and state == alive:
		if Input.is_action_pressed("ui_left"):
			can_move_now = false
			$movementcooldown.start()
			move("ui_left")
		elif Input.is_action_pressed("ui_right"):
			can_move_now = false
			$movementcooldown.start()
			move("ui_right")
		elif Input.is_action_pressed("ui_up"):
			can_move_now = false
			$movementcooldown.start()
			move("ui_up")
		elif Input.is_action_pressed("ui_down"):
			can_move_now = false
			$movementcooldown.start()
			move("ui_down")
	if can_fall_now == true and freefalling == true and state == alive:
		if headposition.y > screen_size.y + tile_size or headposition.y < -tile_size*2:
			deathprocess()
		can_fall_now = false
		if gravity == down:
			headposition = headposition + Vector2.DOWN * tile_size
			emit_signal("head_pos", headposition)
			$Camera2D.position = headposition
			for n in len(snakebodcoords):
				snakebodcoords[n] = snakebodcoords[n] + Vector2.DOWN * tile_size
			if check_for_dmg() == true and dmgimmunity == false:
				dmgprocess()
			for n in len(snakespritenames):
				snakespritenames[n].position = snakespritenames[n].position + Vector2.DOWN * tile_size
		if gravity == up:
			headposition = headposition - Vector2.DOWN * tile_size
			emit_signal("head_pos", headposition)
			$Camera2D.position = headposition
			for n in len(snakebodcoords):
				snakebodcoords[n] = snakebodcoords[n] - Vector2.DOWN * tile_size
			if check_for_dmg() == true and dmgimmunity == false:
				dmgprocess()
			for n in len(snakespritenames):
				snakespritenames[n].position = snakespritenames[n].position - Vector2.DOWN * tile_size
		var food = check_for_food()
		if food == true:
			fallingfruitcount += 1
		$freefalltimer.start()
		check_footing()
		

func _unhandled_input(event):
	if can_move_now == true and state == alive:
		for dir in inputs.keys():
			if event.is_action_pressed(dir):
				can_move_now = false
				$movementcooldown.start()
				move(dir)

func shoot(dir):
	var grabbedinstance = projectile.instance()
	grabbedinstance.position = snakebodcoords[0]
	grabbedinstance.newdirection(dir)
	play_shootsound()
	self.add_child(grabbedinstance)
	var timerinstance = projtimer.instance()
	grabbedinstance.projtimername = timerinstance
	grabbedinstance.add_child(timerinstance)
	timerinstance.stop()

func move(dir):
	ray.position = headposition
	ray.cast_to = inputs[dir] * tile_size
	ray.force_raycast_update()
	if !ray.is_colliding() and within_range(dir) == 1 and wont_hit_snake(dir):
		snakeboddirections.insert(0,inputs[dir])
		headposition = check_for_portal(inputs[dir], headposition)
		headposition += inputs[dir]*tile_size
		emit_signal("head_pos", headposition)
		attach_head()
		check_for_gravbutton()
		$Camera2D.position = headposition
		if check_for_dmg() == true and dmgimmunity == false:
			dmgprocess()
		var food = check_for_food()
		if food == false and fallingfruitcount == 0:
			snakeboddirections.remove(len(snakeboddirections)-1)
			purge_tail()
		elif food == false and fallingfruitcount > 0:
			fallingfruitcount -= 1
		check_footing()

func check_for_gravbutton():
	for button in get_tree().get_nodes_in_group("gravitybuttons"):
		#print(button.position, headposition + Vector2(0,8))
		if button.position == headposition:
			swap_gravity()
			swap_enemy_gravity()
			swap_gravbuttons()

func swap_gravity():
	if gravity == up:
		gravity = down
	else: gravity = up
	
func swap_gravbuttons():
	get_tree().call_group("gravitybuttons","reverse_gravity")

func swap_enemy_gravity():
	get_tree().call_group("enemies", "gravity_swap")

func actual_portal_check(dir, pos):
	portalray.position = pos
	portalray.cast_to = dir * tile_size/2
	portalray.force_raycast_update()
	if portalray.is_colliding():
		return true
	else: return false

func check_for_portal(dir, pos):
	portalray.position = pos
	portalray.cast_to = dir * tile_size/2
	portalray.force_raycast_update()
	var new_pos = pos
	if portalray.is_colliding():
		var portal_in_use = portalray.get_collider()
		new_pos += do_portal(portal_in_use)
	return new_pos

func do_portal(portal_in_use):
	var displacement = Vector2(0,0)
	for portal in get_tree().get_nodes_in_group("Portal"):
		if portal != portal_in_use:
			if portal.id == portal_in_use.id:
				displacement = portal.position - portal_in_use.position
	return displacement

func check_moveability():
	var next_moves = [headposition + Vector2.UP * tile_size, headposition + Vector2.DOWN * tile_size, headposition + Vector2.LEFT * tile_size, headposition + Vector2.RIGHT * tile_size]
	var legal = false
	for pos in next_moves:
		ray.position = headposition
		ray.cast_to = pos - headposition
		ray.force_raycast_update()
		if !ray.is_colliding() and !snakebodcoords.has(pos):
			legal = true
	if legal == false:
		deathprocess()

func check_for_dmg():
	for n in len(snakebodcoords):
		deathray.position = snakebodcoords[n] + Vector2.ONE * tile_size/3
		deathray.cast_to = - Vector2.ONE * tile_size/3
		deathray.force_raycast_update()
		if deathray.is_colliding():
			return true
	return false
	
func check_for_goal():
	for n in len(snakebodcoords):
		goalray.position = snakebodcoords[n] + Vector2.ONE * tile_size/3
		goalray.cast_to = - Vector2.ONE * tile_size/3
		goalray.force_raycast_update()
		if goalray.is_colliding():
			return true
	return false

func check_for_food():
	foodray.position = headposition
	foodray.cast_to = Vector2.ONE * tile_size/3
	foodray.force_raycast_update()
	if foodray.is_colliding():
		emit_signal("eat_food", headposition)
		return true
	else: return false

func check_footing():
	var footing = 0
	for pos in snakebodcoords:
		ray.position = pos
		if gravity == down:
			ray.cast_to = Vector2.DOWN * tile_size
		else: ray.cast_to = Vector2.UP * tile_size
		ray.force_raycast_update()
		if ray.is_colliding():
			footing = 1
	if footing == 1:
		freefalling = false
	else: freefalling = true


func wont_hit_snake(dir):
	var wont_hit = 1
	for pos in snakebodcoords:
		if headposition + inputs[dir]*tile_size == pos:
			wont_hit = 0
	return wont_hit

func within_range(dir):
	var newheadposition = headposition + inputs[dir]*tile_size
	if newheadposition.x >= tile_size/2 and newheadposition.x <= screen_size.x - tile_size/2 and newheadposition.y >= tile_size/2 and newheadposition.y <= screen_size.y - tile_size/2:
		return 1
	else:
		return 0

func dmgprocess():
	lives -= 1
	emit_signal("lost_a_life")
	camerashake()
	play_hitsound()
	if lives == 0:
		deathprocess()
	else:
		takedamage()

func takedamage():
	dmgimmunity = true
	$dmgtimer.start()
	snakeimmunityflash()

func deathprocess():
	if state == alive:
		$deathtimer.start()
		shakesnake()
	state = dead

func goalprocess():
	play_nyuum()
	state = dead
	$evapsegmenttimer.start()

func shakesnake():
	for n in len(snakespritenames):
		var grabbedinstance = shake.instance()
		snakespritenames[n].add_child(grabbedinstance)
		shakernames.append(grabbedinstance)
		shakernames[n].start(5, 15, 1, 0)

func camerashake():
	var grabbedinstance = shake.instance()
	$Camera2D.add_child(grabbedinstance)
	grabbedinstance.start(0.2, 15, 3, 0)

func _on_movementcooldown_timeout():
	can_move_now = true

func _on_freefalltimer_timeout():
	can_fall_now = true

func _on_deathtimer_timeout():
	emit_signal("restart_level")
	print("dead")

func _on_evapsegmenttimer_timeout():
	var n = evapsegment
	if n < len(snakespritenames):
		var grabbedinstance = evaporate.instance()
		snakespritenames[n].add_child(grabbedinstance)
		evaporaternames.append(grabbedinstance)
		evaporaternames[n].start()
		evapsegment += 1
		$evapsegmenttimer.start()
	else: $wintimer.start()


func _on_wintimer_timeout():
	emit_signal("next_level")
	print("done")


func _on_shootingcooldown_timeout():
	can_shoot_now = true


func _on_dmgtimer_timeout():
	modulate = Color(1,1,1,1)
	dmgimmunity = false

func play_shootsound():
	$Sounds/pop1.pitch_scale = rng.randf_range(0.9, 1.1)
	$Sounds/pop1.volume_db = -5
	$Sounds/pop1.play()

func play_hitsound():
	$Sounds/hit1.pitch_scale = rng.randf_range(0.9, 1.1)
	$Sounds/hit1.volume_db = 0
	$Sounds/hit1.play()

func play_nyuum():
	$Sounds/nyuum.volume_db = 0
	$Sounds/nyuum.play()

func snakeimmunityflash():
	_on_flashcolourtimer_timeout()

func _on_flashcolourtimer_timeout():
	if $dmgtimer.time_left > 0:
		modulate = Color(3,3,3,3)
		$flashwhitetimer.start()

func _on_flashwhitetimer_timeout():
	if $dmgtimer.time_left > 0:
		modulate = Color(1,1,1,1)
		$flashcolourtimer.start()
