extends "res://vehicles/vehicle.gd"

func _draw():
	# global space to local space transformation
	var p := future_target_position() * get_global_transform_with_canvas()
	draw_circle(p, 3, Color.GREEN)
	draw_line(Vector2.ZERO, linear_velocity.orthogonal().normalized()*-20, Color.YELLOW)
	super._draw()

func steer(target: RigidBody2D) -> Vector2:
	var desired_velocity: Vector2 = (future_target_position() - position).normalized() * max_speed
	var steering = desired_velocity - linear_velocity
	return steering

func future_target_position() -> Vector2:
	const radius := 10
	
	# project to local coordinate space
	var local_target_position := target.position * get_global_transform_with_canvas()
	var local_projection := local_target_position.project(linear_velocity.orthogonal())
	local_projection = local_projection.normalized() * -1 * radius
	print("local projection", local_projection)
	
	var new_target_position := local_target_position + local_projection
	var new_global_target_position := new_target_position * get_global_transform_with_canvas().inverse()
	
	if (new_global_target_position.is_finite()):
		return new_global_target_position
	return target.position
