extends Node3D
class_name PassiveBeast

@onready var bubble_animal = $DefaultBehavior/BubbleAnimal
@onready var default_behavior: DefaultBehavior = $DefaultBehavior

@export var default_curve: Path3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().process_frame
	default_behavior.init_curve_points(default_curve)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _physics_process(delta: float) -> void:
	default_behavior.process_behavior(delta)
