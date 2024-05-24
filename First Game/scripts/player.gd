extends CharacterBody2D

@export var jump_height_curve: Curve
@export var jump_held_max_time_ms: int
@export var jump_held_modifier: float = 0.5

const SPEED = 130.0
const JUMP_VELOCITY = -300.0
var jump_start_time_ms: int

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var animated_sprite = $AnimatedSprite2D

func _unhandled_input(event):
	if event.is_action_pressed("jump") and is_on_floor():
		jump_start_time_ms = Time.get_ticks_msec()
	if event.is_action_released("jump") and is_on_floor():
		var jump_held_time_ms: int = Time.get_ticks_msec() - jump_start_time_ms
		var time_held_fraction = clamp(float(jump_held_time_ms) / float(jump_held_max_time_ms), 0, 1)
		var additional_jump = float(JUMP_VELOCITY)*jump_held_modifier*jump_height_curve.sample(time_held_fraction)
		velocity.y = JUMP_VELOCITY + additional_jump
		jump_start_time_ms = 0

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
		
		
	# Get the input direction: -1, 0, 1
	var direction = Input.get_axis("move_left", "move_right")
	
	# Flip the Sprite
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true
	
	# Play animations
	if is_on_floor():
		if direction == 0:
			animated_sprite.play("idle")
		else:
			animated_sprite.play("run")
	else:
		animated_sprite.play("jump")
	
	# Apply movement
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
