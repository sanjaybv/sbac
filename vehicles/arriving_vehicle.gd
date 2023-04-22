extends "res://vehicles/vehicle.gd"

const slowing_distance: int = 250

func steer(target: RigidBody2D) -> Vector2:
	# Calculate clipped speed
	var target_offset: Vector2 = target.position - position
	var distance := target_offset.length()
	var ramped_speed: float = max_speed * (distance / slowing_distance)
	var clipped_speed: float = minf(ramped_speed, max_speed)
	
	var desired_velocity: Vector2 = (target.position - position).normalized() * clipped_speed
	var steering = desired_velocity - linear_velocity
	return steering
