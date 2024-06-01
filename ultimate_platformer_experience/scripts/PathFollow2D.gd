extends PathFollow2D

# Speed of the bird
@export var speed = 0.1

func _process(delta):
	progress_ratio += delta * speed
