extends StaticBody2D

# Called when the node enters the scene tree for the first time.
func _ready():
	position = position.snapped(Vector2.ONE * tile_size)
	position += Vector2.ONE * tile_size/2
	render(Vector2(0,0), height)

export var id = 0
export var height = 3

var tile_size = 16

const portalspriteend = preload("res://portalend.tscn")
const portalspritemiddle = preload("res://portalmiddle.tscn")

func render(pnp, pnh):
	#First the ends
	var grabbedinstance_topleft = portalspriteend.instance()
	grabbedinstance_topleft.position = pnp
	self.add_child(grabbedinstance_topleft)
	var grabbedinstance_topright = portalspriteend.instance()
	grabbedinstance_topright.position = pnp + Vector2.RIGHT * tile_size
	grabbedinstance_topright.set_scale(Vector2(-1,1))
	self.add_child(grabbedinstance_topright)
	var grabbedinstance_bottomleft = portalspriteend.instance()
	grabbedinstance_bottomleft.position = pnp + Vector2.DOWN * tile_size * pnh
	grabbedinstance_bottomleft.set_scale(Vector2(1,-1))
	self.add_child(grabbedinstance_bottomleft)
	var grabbedinstance_bottomright = portalspriteend.instance()
	grabbedinstance_bottomright.position = pnp + Vector2.DOWN * tile_size * pnh + Vector2.RIGHT * tile_size
	grabbedinstance_bottomright.set_scale(Vector2(-1,-1))
	self.add_child(grabbedinstance_bottomright)
	#Next the middle
	for n in pnh:
		if n != 0:
			var grabbedinstance_left = portalspritemiddle.instance()
			grabbedinstance_left.position = pnp + Vector2.DOWN * tile_size * n
			self.add_child(grabbedinstance_left)
			var grabbedinstance_right = portalspritemiddle.instance()
			grabbedinstance_right.position = pnp + Vector2.DOWN * tile_size * n + Vector2.RIGHT * tile_size
			grabbedinstance_right.set_scale(Vector2(-1,1))
			self.add_child(grabbedinstance_right)
	define_collisions()

func define_collisions():
	var shape = RectangleShape2D.new()
	shape.set_extents(Vector2(4,(height+1)*tile_size/2))
	var collision = $CollisionShape2D
	collision.set_shape(shape)
	collision.position = Vector2(tile_size/2, (height)*tile_size/2)
