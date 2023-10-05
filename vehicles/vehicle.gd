extends RigidBody2D

const max_force = 100000
const max_speed = 250

@export var target: RigidBody2D

var acceleration := Vector2.ZERO

var screen := DisplayServer.window_get_size()

func _draw():
	var direction = linear_velocity.normalized()
	var points = PackedVector2Array([
		Vector2(0, -5).rotated(direction.angle()), 
		Vector2(20, 0).rotated(direction.angle()), 
		Vector2(0, 5).rotated(direction.angle())],
	)
	draw_colored_polygon(points, Color.WHITE, points)
	# TODO: I don't like that the direction and position are from two different spaces. 
	draw_line(Vector2.ZERO, linear_velocity, Color.GREEN, 2.0)
	draw_line(Vector2.ZERO, acceleration, Color.BLUE, 2.0)

func _process(delta):
	var force := steer(target)
	
	var steering_force := force.limit_length(max_force)
	acceleration = steering_force / mass
	linear_velocity += acceleration * delta
	linear_velocity = linear_velocity.limit_length(max_speed)
	
	move_and_collide(linear_velocity*delta)
	position = position.posmodv(screen)
	
	queue_redraw()

func steer(target: RigidBody2D) -> Vector2:
	print("steer should be overriden.")
	assert(false)
	return Vector2.ZERO
