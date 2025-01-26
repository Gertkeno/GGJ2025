extends Node3D
class_name SkittishBehavior

var player: Player = null
var bubble_animal: BubbleAnimal = null
var move_speed = 8
var destination: Vector3


signal finished_fleeing


func process_behavior(delta: float) -> void:
	if is_nav_finished():
		finished_fleeing.emit()
	else:
		bubble_animal.move_speed = move_speed
		bubble_animal.direction = bubble_animal.global_position.direction_to(destination)
		bubble_animal.look_at(destination)
		bubble_animal.apply_movement(delta)

func is_nav_finished() -> bool:
	return bubble_animal.navigation_agent.is_navigation_finished()
	# return bubble_animal.navigation_agent.is_target_reached()
