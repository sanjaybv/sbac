extends "res://vehicles/vehicle.gd"

func steer(target: RigidBody2D) -> Vector2:
	var desired_velocity: Vector2 = (position - target.position).normalized() * max_speed
	var steering = desired_velocity - linear_velocity
	return steering
