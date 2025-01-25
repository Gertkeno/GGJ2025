extends CharacterBody3D
class_name BubbleAnimal

const default_move_speed = 4.0

@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D
var direction: Vector3 = Vector3.ZERO
var move_speed = default_move_speed


func _unhandled_input(event: InputEvent) -> void:
	pass

func _physics_process(delta: float) -> void:
	pass

func reset_move_speed() -> void:
	move_speed = default_move_speed
	
func apply_movement() -> void:
	velocity = direction * move_speed
	move_and_slide()
