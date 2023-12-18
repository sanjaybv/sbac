extends CharacterBody2D

const SPEED = 300.0

@onready var nav = $NavigationAgent2D

func _physics_process(delta):
	var nav_vector: Vector2
	print("isnavreached ", nav.is_target_reached())
	if !nav.is_target_reached():
		nav_vector = (nav.get_next_path_position() - global_position).normalized()
	
	velocity = (Input.get_vector("Left", "Right", "Up", "Down") + nav_vector).normalized() * SPEED
	move_and_slide()

func _input(event):
	if event is InputEventMouseButton:
		nav.target_position = event.position
		print("setting nav target to ", event.position)
