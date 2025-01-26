extends Node3D
class_name DefaultBehavior

@onready var bubble_animal: BubbleAnimal = $BubbleAnimal

var curve_points: PackedVector3Array = []
var current_curve_point: int = 0


func _physics_process(_delta: float) -> void:
	# If the animal is not in path, we need to navigate to it
	# if bubble_animal.
	# debug
	# if bubble_animal.navigation_agent.is_target_reachable() == false:
	# 	var dbg = 0
	pass


func process_behavior(_delta: float) -> void:
	if is_nav_finished():
		increment_curve_point()
		update_target_position()
	var destination: Vector3 = bubble_animal.navigation_agent.get_next_path_position()
	var local_destination: Vector3 = destination - bubble_animal.global_position
	var direction: Vector3 = local_destination.normalized()
	bubble_animal.reset_move_speed()
	bubble_animal.direction = direction
	bubble_animal.apply_movement()


func init_curve_points(path: Path3D) -> void:
	if path == null:
		push_warning("Bubble animal '%s' missing path!" % get_path())
		return

	var world_3d := get_world_3d().direct_space_state
	var ray_query := PhysicsRayQueryParameters3D.new()
	ray_query.collision_mask = 3
	for pt in path.curve.point_count:
		var path_point: Vector3 = path.curve.get_point_position(pt) + path.global_position
		ray_query.from = path_point
		ray_query.to = path_point - Vector3(0, 50, 0)
		var collision: Dictionary = world_3d.intersect_ray(ray_query)
		if collision:
			print("collision: ", collision["position"])
			curve_points.append(collision["position"])
		else:
			curve_points.append(path.curve.get_point_position(pt) + path.global_position)
	update_target_position()


func is_nav_finished() -> bool:
	return bubble_animal.navigation_agent.is_target_reached()
	# return bubble_animal.navigation_agent.is_navigation_finished() # && \
	#  bubble_animal.navigation_agent.distance_to_target() <= bubble_animal.navigation_agent.target_desired_distance


func increment_curve_point() -> void:
	current_curve_point += 1;
	current_curve_point = current_curve_point % curve_points.size()


func update_target_position() -> void:
	bubble_animal.navigation_agent.target_position = curve_points[current_curve_point]
	bubble_animal.look_at(curve_points[current_curve_point])
