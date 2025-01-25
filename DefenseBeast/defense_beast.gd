extends Node3D

@onready var bubble_animal = $DefaultBehavior/Path3D/PathFollow3D/NeutralBubbleAnimal
@onready var default_behavior = $DefaultBehavior
@onready var path = $DefaultBehavior/Path3D
@onready var follow_3d = $DefaultBehavior/Path3D/PathFollow3D
@onready var defense_behavior = $DefenseBehavior

@export var default_curve: Curve3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	path.curve = default_curve
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _physics_process(delta: float) -> void:
	const move_speed = 4.0
	if bubble_animal.get_parent() == follow_3d:
		follow_3d.progress += 4.0 * delta
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("jump"):
		if bubble_animal.get_parent() == follow_3d:
			bubble_animal.reparent(defense_behavior)
		else:
			bubble_animal.reparent(follow_3d)
		pass
