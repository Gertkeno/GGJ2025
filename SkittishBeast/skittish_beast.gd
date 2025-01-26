extends Node3D
class_name SkittishBeast

@onready var bubble_animal: BubbleAnimal = $DefaultBehavior/BubbleAnimal
@onready var default_behavior: DefaultBehavior = $DefaultBehavior
@onready var skittish_behavior: SkittishBehavior = $SkittishBehavior

@export var default_curve: Path3D
@export_range(1.0, 20.0, 0.1) var distance_to_run_away: float = 7.0
@export var descriptor: AnimalDescriptor

var rng := RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().process_frame
	default_behavior.init_curve_points(default_curve)
	skittish_behavior.bubble_animal = bubble_animal


func _physics_process(delta: float) -> void:
	if bubble_animal.get_parent() == default_behavior:
		default_behavior.process_behavior(delta) # do default behavior stuff
	else:
		skittish_behavior.process_behavior(delta) # do defense behavior stuff


func _on_skittish_behavior_finished_fleeing() -> void:
	bubble_animal.reparent(default_behavior)
	
	
func _on_vision_collision_entered(body: Node3D) -> void:
	if body is Player:
		if bubble_animal.get_parent() == default_behavior:
			skittish_behavior.player = body
			# skittish_behavior.distance_to_run = distance_to_run_away
			
			bubble_animal.move_speed = 8
			
			var displacement: Vector3 = bubble_animal.global_position - body.global_position
			displacement.normalized()
			var random_angle := rng.randf_range(-0.349066, 0.349066)
			displacement.rotated(Vector3.UP, random_angle)
			
			displacement *= distance_to_run_away
			displacement += bubble_animal.global_position
			
			var destination := Vector3(displacement.x, bubble_animal.global_position.y, displacement.z)
			skittish_behavior.destination = destination
			
			bubble_animal.navigation_agent.target_position = destination
			
			bubble_animal.reparent.call_deferred(skittish_behavior)
