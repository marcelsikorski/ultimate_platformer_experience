extends Node2D

class_name CliffDetector

var left
var right

func _ready():
	var raycasts = get_children()
	for child in raycasts:
		if child.name == "left":
			left = child
		elif child.name == "right":
			right = child

func is_at_the_edge(direction) -> bool:
	direction = sign(direction)
	if direction == 0:
		return false
	if direction == 1:
		return !right.is_colliding()
	else:
		return !left.is_colliding()
