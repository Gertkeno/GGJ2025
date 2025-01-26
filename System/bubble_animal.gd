extends CharacterBody3D
class_name BubbleAnimal

const default_move_speed: float = 4.0

@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D
var direction: Vector3 = Vector3.ZERO
var move_speed: float = default_move_speed


func reset_move_speed() -> void:
	move_speed = default_move_speed


func apply_movement(delta: float) -> void:
	velocity = direction * move_speed
	position += velocity * delta
	#move_and_slide() # too expensive for 150 actors
