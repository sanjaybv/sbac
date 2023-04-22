extends RigidBody2D

func _draw():
	draw_circle(Vector2.ZERO, 10, Color.RED)

func _physics_process(delta):
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		position = get_global_mouse_position()
