extends Node3D
class_name PassiveBeast

@onready var bubble_animal: BubbleAnimal = $DefaultBehavior/BubbleAnimal
@onready var default_behavior: DefaultBehavior = $DefaultBehavior

@export var default_curve: Path3D
@export var descriptor: AnimalDescriptor

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().process_frame
	default_behavior.init_curve_points(default_curve)

	if descriptor:
		bubble_animal.bubble_material.set_shader_parameter("rim_color", descriptor.color)
	else:
		push_warning("Animal %s missing descriptor!" % get_path())


func _physics_process(delta: float) -> void:
	default_behavior.process_behavior(delta)
