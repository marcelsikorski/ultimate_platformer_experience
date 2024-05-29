extends CharacterBody2D

@export var jump_height_curve: Curve
@export var jump_held_max_time_ms: int
@export var jump_held_modifier: float = 0.5

const SPEED = 180.0
const JUMP_VELOCITY = -300.0
var jump_start_time_ms: int
var isJumping: bool = false
var isChargingJump: bool = false
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@export var cliff_detector: CliffDetector
var direction
@onready var animated_sprite = $AnimatedSprite2D
var can_change_direction = true



func _ready():
	if cliff_detector != null:
		var children = get_children()
		for child in children:
			if child.name == "CliffDetector":
				cliff_detector = child

func wants_to_jump_imediately()->bool:
	return direction != 0 #and cliff_detector.is_at_the_edge(direction)

func _unhandled_input(event):
	if event.is_action_pressed("jump"):
		isChargingJump = true
		if is_on_floor():
			if wants_to_jump_imediately():
				# this means the player is near a cliff
				velocity.y = JUMP_VELOCITY
			else:
				# get ms since start of the engine
				jump_start_time_ms = Time.get_ticks_msec()
			isJumping = true
	if event.is_action_released("jump"):
		isChargingJump = false		
		if is_on_floor():
			# how long was "jump" pressed for
			var jump_held_time_ms: int = Time.get_ticks_msec() - jump_start_time_ms
			# how long relative to max time (from 0 to 1)
			var time_held_fraction = clamp(float(jump_held_time_ms) / float(jump_held_max_time_ms), 0, 1)
			# plug those values into a curve and get the additional jump value
			var additional_jump = float(JUMP_VELOCITY)*jump_held_modifier*jump_height_curve.sample(time_held_fraction)
			velocity.y = JUMP_VELOCITY + additional_jump
			jump_start_time_ms = 0
			isJumping = false

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		jump_start_time_ms = 0
		velocity.y += gravity * delta
		can_change_direction = false
	else:
		isJumping = false
		

		
	# Get the input direction: -1, 0, 1
	if not isJumping:
		direction = Input.get_axis("move_left", "move_right")
	else:
		velocity.x = velocity.x
		
	
	# Flip the Sprite
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true
	
	if not can_change_direction:
		velocity.x = 0;

	# Play animations
	if is_on_floor():
		if jump_start_time_ms != 0 or isChargingJump:
			# should be charging animation
			animated_sprite.play("jump")
		elif direction == 0:
			animated_sprite.play("idle")
		else:
			animated_sprite.play("run")
	else:
		animated_sprite.play("jump")
	

		
	# Apply movement
	if not is_on_floor():
		if direction and not isJumping:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
