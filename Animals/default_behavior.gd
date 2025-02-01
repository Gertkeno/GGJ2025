extends Node3D
class_name DefaultBehavior

@onready var bubble_animal: BubbleAnimal = $BubbleAnimal

var curve_points: PackedVector3Array = []
var current_curve_point: int = 0


func process_behavior(delta: float) -> void:
	if curve_points.size() == 0:
		return;

	var destination := curve_points[current_curve_point]
	var difference := destination - bubble_animal.global_position

	if difference.length_squared() < 4:
		increment_curve_point()
		process_behavior(delta)
		return;

	bubble_animal.direction = difference.normalized()
	bubble_animal.apply_movement(delta)


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
			curve_points.append(collision["position"])# + Vector3(0, 0.5, 0))
		else:
			curve_points.append(path.curve.get_point_position(pt) + path.global_position)


func increment_curve_point() -> void:
	current_curve_point += 1;
	current_curve_point = current_curve_point % curve_points.size()
	bubble_animal.look_at(curve_points[current_curve_point])
