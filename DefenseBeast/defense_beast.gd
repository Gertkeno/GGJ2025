extends Node3D
class_name DefenseBeast

@onready var bubble_animal = $DefaultBehavior/BubbleAnimal
@onready var default_behavior: DefaultBehavior = $DefaultBehavior
@onready var defense_behavior: DefenseBehavior = $DefenseBehavior
@onready var dizzy_timer: Timer = $DefenseBehavior/DizzyTimer

@export var default_curve: Path3D
@export_range(1.0, 20.0, 0.1) var knockback_force: float = 7.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	default_behavior.init_curve_points(default_curve)
	defense_behavior.bubble_animal = bubble_animal
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _physics_process(delta: float) -> void:
	if dizzy_timer.is_stopped():
		if bubble_animal.get_parent() == default_behavior:
			default_behavior.process_behavior(delta) # do default behavior stuff
		else:
			defense_behavior.process_behavior(delta) # do defense behavior stuff
	
func _input(event: InputEvent) -> void:
	# TODO have it change behavior if it notices the player.
	if event.is_action_pressed("jump"):
		if bubble_animal.get_parent() == defense_behavior:
			bubble_animal.reparent(default_behavior)

func _on_bubble_animal_notice_player(player: Player) -> void:
	# do the collisioning
	if bubble_animal.get_parent() == default_behavior:
		defense_behavior.player = player
		bubble_animal.reparent(defense_behavior)

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
