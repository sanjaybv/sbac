extends RigidBody2D

const Steering = preload("res://behaviors/steering.gd")

const max_speed = 200

@export var target: RigidBody2D
@export var behavior: Array[Steering.Behaviors]

var acceleration := Vector2.ZERO

var screen := DisplayServer.window_get_size()

var steering: Steering = Steering.new(max_speed)



func _ready():
	self.gravity_scale = 0
	
	var raycasts: Array[RayCast2D]
	for cast in $RayCasts.get_children():
		raycasts.append(cast)
	steering.set_raycasts(raycasts)
	
	for b in behavior:
		steering.add_behavior(b, 1.0)


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


#func _process(delta):
	#position = position.posmodv(screen)
#	return


func _physics_process(delta):
	apply_central_force(steering.steer(self, target))
	self.rotation = self.linear_velocity.angle()
	# queue_redraw()
