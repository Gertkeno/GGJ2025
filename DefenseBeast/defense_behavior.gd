extends Node3D
class_name DefenseBehavior

var player: Player = null
var bubble_animal: BubbleAnimal = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func process_behavior(delta: float) -> void:
	bubble_animal.move_speed = 8
	#bubble_animal.direction = player.global_position
	bubble_animal.direction = bubble_animal.global_position.direction_to(player.global_position)
	bubble_animal.look_at(player.global_position)
	bubble_animal.apply_movement()
	
