extends Node3D
class_name DefenseBeast

@onready var bubble_animal: Node3D = $DefaultBehavior/BubbleAnimal
@onready var default_behavior: DefaultBehavior = $DefaultBehavior
@onready var defense_behavior: DefenseBehavior = $DefenseBehavior
@onready var dizzy_timer: Timer = $DefenseBehavior/DizzyTimer

@export var descriptor: AnimalDescriptor
@export var default_curve: Path3D
@export_range(1.0, 20.0, 0.1) var knockback_force: float = 7.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().process_frame
	default_behavior.init_curve_points(default_curve)
	defense_behavior.bubble_animal = bubble_animal
	pass # Replace with function body.


func _physics_process(delta: float) -> void:
	if dizzy_timer.is_stopped():
		if bubble_animal.get_parent() == default_behavior:
			default_behavior.process_behavior(delta) # do default behavior stuff
		else:
			defense_behavior.process_behavior(delta) # do defense behavior stuff


func _on_bullhorn_body_entered(body: Node3D) -> void:
	if body is Player:
		if dizzy_timer.is_stopped():
			# do the thing
			var diff: Vector3 = body.global_position - bubble_animal.global_position
			var direction := Vector2(diff.x, diff.z).normalized() #flat
			body.knockback(Vector3(direction.x, 0, direction.y) * knockback_force)
			dizzy_timer.start(1); # wait a second to move again.
		


func _on_dizzy_timer_timeout() -> void:
	bubble_animal.reparent(default_behavior)


func _on_vision_collision_entered(body: Node3D) -> void:
	if body is Player:
		if bubble_animal.get_parent() == default_behavior:
			defense_behavior.player = body
			bubble_animal.reparent.call_deferred(defense_behavior)
