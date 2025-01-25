extends Node3D
class_name DefenseBeast

@onready var bubble_animal = $DefaultBehavior/BubbleAnimal
@onready var default_behavior: DefaultBehavior = $DefaultBehavior
@onready var defense_behavior: DefenseBehavior = $DefenseBehavior

@export var default_curve: Curve3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	default_behavior.init_curve_points(default_curve)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _physics_process(delta: float) -> void:
	if bubble_animal.get_parent() == default_behavior:
		default_behavior.process_behavior(delta) # do default behavior stuff
	else:
		defense_behavior.process_behavior(delta) # do defense behavior stuff
	
func _input(event: InputEvent) -> void:
	# TODO have it change behavior if it notices the player.
	if event.is_action_pressed("jump"):
		if bubble_animal.get_parent() == default_behavior:
			bubble_animal.reparent(defense_behavior)
		else:
			bubble_animal.reparent(default_behavior)
		pass
