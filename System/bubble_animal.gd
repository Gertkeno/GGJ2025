extends CharacterBody3D
class_name BubbleAnimal

const default_move_speed: float = 4.0

signal on_notice_player(player: Player)

@export var descriptor: AnimalDescriptor
@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D
var direction: Vector3 = Vector3.ZERO
var move_speed: float = default_move_speed


func reset_move_speed() -> void:
	move_speed = default_move_speed


func apply_movement() -> void:
	velocity = direction * move_speed
	move_and_slide()


func _on_vision_collision_entered_tree(node: Node) -> void:
	if node is Player:
		on_notice_player.emit(node)
