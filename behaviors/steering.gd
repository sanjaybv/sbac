extends Object

enum Behaviors {SEEK, FLEE, PURSUE, EVADE, OFFSET_PURSUE, ARRIVE, AVOID_OBSTACLES, WANDER}

var _behavior_funcs: Dictionary = {
	Behaviors.SEEK: seek,
	Behaviors.FLEE: flee,
	Behaviors.PURSUE: pursue,
	Behaviors.EVADE: evade,
	Behaviors.OFFSET_PURSUE: offset_pursue,
	Behaviors.ARRIVE: arrive,
	Behaviors.AVOID_OBSTACLES: avoid_obstacles,
	Behaviors.WANDER: wander,
}

var _max_speed: float

var _behavior_weights: Dictionary
var _raycasts: Array[RayCast2D]


func _init(max_speed: float) -> void:
	_max_speed = max_speed
	

func add_behavior(b: Behaviors, weight: float) -> void:
	_behavior_weights[b] = weight


func set_raycasts(rcs: Array[RayCast2D]) -> void:
	_raycasts = rcs
	
# steer applies the behavior on the character with respect to the target and returns force
func steer(character: RigidBody2D, target: RigidBody2D) -> Vector2:
	var force: Vector2
	for b in _behavior_weights:
		force += Callable(_behavior_funcs[b]).call(character, target) * _behavior_weights[b]
	return force

func seek(character: RigidBody2D, target: RigidBody2D) -> Vector2:
	var desired_velocity: Vector2 = (target.position - character.position).normalized() * _max_speed
	var steering = desired_velocity - character.linear_velocity
	return steering

func flee(character: RigidBody2D, target: RigidBody2D) -> Vector2:
	var desired_velocity: Vector2 = (character.position - target.position).normalized() * _max_speed
	var steering = desired_velocity - character.linear_velocity
	return steering

func pursue(character: RigidBody2D, target: RigidBody2D) -> Vector2:
	var desired_velocity: Vector2 = (
		future_target_position(character, target) - character.position
	).normalized() * _max_speed
	var steering = desired_velocity - character.linear_velocity
	return steering
	
func evade(character: RigidBody2D, target: RigidBody2D) -> Vector2:
	var desired_velocity: Vector2 = (
		character.position - future_target_position(character, target)
	).normalized() * _max_speed
	var steering = desired_velocity - character.linear_velocity
	return steering
	
func offset_pursue(character: RigidBody2D, target: RigidBody2D) -> Vector2:
	var desired_velocity: Vector2 = (
		future_offset_target_position(character, target) - character.position
	).normalized() * _max_speed
	var steering = desired_velocity - character.linear_velocity
	return steering
	
func arrive(character: RigidBody2D, target: RigidBody2D) -> Vector2:
	# Calculate clipped speed
	var target_offset: Vector2 = target.position - character.position
	var distance := target_offset.length()
	var ramped_speed: float = _max_speed * (distance / slowing_distance)
	var clipped_speed: float = minf(ramped_speed, _max_speed)
	
	var desired_velocity: Vector2 = (
		target.position - character.position
	).normalized() * clipped_speed
	var steering = desired_velocity - character.linear_velocity
	return steering

func avoid_obstacles(character: RigidBody2D, target: RigidBody2D) -> Vector2:
	for rc in _raycasts:
		if rc.is_colliding() and rc.get_collider() != null:
			var c := rc.get_collider()
			return (rc.get_collision_point() - c.position).normalized() * _max_speed
	return Vector2.ZERO

func wander(character: RigidBody2D, target: RigidBody2D) -> Vector2:
	var circle := Vector2(0, 100) + character.position
	var r := Vector2.from_angle(randf_range(0, 2*PI))
	print(r)
	var new_target := circle + r * 100
	
	var desired_velocity := (new_target - character.position).normalized() * _max_speed
	return desired_velocity - character.linear_velocity

func future_target_position(character: RigidBody2D, target: RigidBody2D) -> Vector2:
	# future_time_look_ahead = distance / speed
	var look_ahead: float 
	if !character.linear_velocity.is_zero_approx():
		look_ahead = (character.position.distance_to(target.position)) / \
			character.linear_velocity.length()
	
	# 20 is a constant, a turning parameter as Chris Reynolds puts it.
	return target.position + (target.linear_velocity * look_ahead) / 20

const slowing_distance: int = 250

func future_offset_target_position(character: RigidBody2D, target: RigidBody2D) -> Vector2:
	const radius := 10
	
	# project to local coordinate space
	var local_target_position := target.position * character.get_global_transform_with_canvas()
	var local_projection := local_target_position.project(character.linear_velocity.orthogonal())
	local_projection = local_projection.normalized() * -1 * radius
	print("local projection", local_projection)
	
	var new_target_position := local_target_position + local_projection
	var new_global_target_position := \
		new_target_position * character.get_global_transform_with_canvas().inverse()
	
	if (new_global_target_position.is_finite()):
		return new_global_target_position
	return target.position


