extends "res://vehicles/vehicle.gd"

func _draw():
	draw_circle(Vector2.ZERO, 10, Color.RED)

func _process(delta):
	position = get_global_mouse_position()
	
