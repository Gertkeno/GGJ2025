extends Node3D
class_name DefenseBeast

@onready var bubble_animal = $DefaultBehavior/Path3D/PathFollow3D/NeutralBubbleAnimal
@onready var default_behavior = $DefaultBehavior
@onready var defense_behavior = $DefenseBehavior

@export var default_curve: Curve3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	default_behavior.init_curve_points(default_curve)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("jump"):
		if bubble_animal.get_parent() == default_behavior:
			bubble_animal.reparent(defense_behavior)
		else:
			bubble_animal.reparent(default_behavior)
		pass
