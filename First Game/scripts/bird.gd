extends Node2D

@export var SPEED = 60
@export var MIN_X = 170
@export var MAX_X = 400

var direction = 1

@onready var animated_sprite = $AnimatedSprite2D
@onready var collision_shape = $Area2D/CollisionShape2D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Check if the bird has reached the horizontal boundaries
	if position.x >= MAX_X:
		direction = -1
		animated_sprite.flip_h = true
	if position.x <= MIN_X:
		direction = 1
		animated_sprite.flip_h = false
	
	position.x += direction * SPEED * delta
