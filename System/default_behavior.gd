extends Node3D
class_name DefaultBehavior

@onready var bubble_animal: BubbleAnimal = $BubbleAnimal

var curve_points: PackedVector3Array = []
var current_curve_point: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _physics_process(delta: float) -> void:
	# If the animal is not in path, we need to navigate to it
	# if bubble_animal.
	# debug
	# if bubble_animal.navigation_agent.is_target_reachable() == false:
	# 	var dbg = 0
	pass
	
func process_behavior(delta: float) -> void:
	if is_nav_finished():
		increment_curve_point()
		update_target_position()
	var destination = bubble_animal.navigation_agent.get_next_path_position()
	var local_destination = destination - bubble_animal.global_position
	var direction = local_destination.normalized()
	bubble_animal.reset_move_speed()
	bubble_animal.direction = direction
	bubble_animal.apply_movement()
	
func init_curve_points(curve: Curve3D) -> void:
	for pt in curve.point_count:
		curve_points.append(curve.get_point_position(pt))
	update_target_position()

# func find_closest_curve_point() -> Vector3:
	# return path.curve.get_closest_point(global_position)
	
func is_nav_finished() -> bool:
	return bubble_animal.navigation_agent.is_target_reached()
	# return bubble_animal.navigation_agent.is_navigation_finished() # && \
	#  bubble_animal.navigation_agent.distance_to_target() <= bubble_animal.navigation_agent.target_desired_distance
	
func increment_curve_point() -> void:
	current_curve_point += 1;
	current_curve_point = current_curve_point % curve_points.size()
	
func update_target_position():
	bubble_animal.navigation_agent.target_position = curve_points[current_curve_point]
	bubble_animal.look_at(curve_points[current_curve_point])
