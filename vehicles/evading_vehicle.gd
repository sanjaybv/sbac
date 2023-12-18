extends "res://vehicles/vehicle.gd"


func _draw():
	var p := future_target_position() * get_global_transform_with_canvas()
	draw_circle(p, 3, Color.GREEN)
	super._draw()

func steer(target: RigidBody2D) -> Vector2:
	var desired_velocity: Vector2 = (position - future_target_position()).normalized() * max_speed
	var steering = desired_velocity - linear_velocity
	return steering

func future_target_position() -> Vector2:
	# future_time_look_ahead = distance / speed
	var look_ahead: float 
	if !linear_velocity.is_zero_approx():
		look_ahead = (position.distance_to(target.position)) / linear_velocity.length()
	
	# 20 is a constant, a turning parameter as Craig Reynolds puts it.
	return target.position + (target.linear_velocity * look_ahead) / 20
