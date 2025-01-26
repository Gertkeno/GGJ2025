extends Node3D
class_name SkittishBehavior

var player: Player = null
var bubble_animal: BubbleAnimal = null
var destination: Vector3


signal finished_fleeing

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func process_behavior(delta: float) -> void:
	
	if is_nav_finished():
		finished_fleeing.emit()
	else:
		bubble_animal.direction = bubble_animal.global_position.direction_to(destination)
		bubble_animal.look_at(destination)
		bubble_animal.apply_movement()
	
func is_nav_finished() -> bool:
	return bubble_animal.navigation_agent.is_navigation_finished()
	# return bubble_animal.navigation_agent.is_target_reached()
