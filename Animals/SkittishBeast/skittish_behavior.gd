extends Node3D
class_name SkittishBehavior

var player: Player = null
var bubble_animal: BubbleAnimal = null
var move_speed: float = 8
var destination: Vector3


signal finished_fleeing


func process_behavior(delta: float) -> void:
	var difference := destination - bubble_animal.global_position
	if difference.length_squared() <= 9:
		finished_fleeing.emit()
		bubble_animal.reset_move_speed()
	else:
		bubble_animal.direction = difference.normalized()
		bubble_animal.apply_movement(delta)
