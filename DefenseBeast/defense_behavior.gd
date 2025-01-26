extends Node3D
class_name DefenseBehavior

var player: Player = null
var bubble_animal: BubbleAnimal = null


func process_behavior(delta: float) -> void:
	bubble_animal.move_speed = 8
	#bubble_animal.direction = player.global_position
	bubble_animal.direction = bubble_animal.global_position.direction_to(player.global_position)
	bubble_animal.look_at(player.global_position)
	bubble_animal.apply_movement(delta)
	
