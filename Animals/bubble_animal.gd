extends CharacterBody3D
class_name BubbleAnimal

const default_move_speed: float = 4.0

#@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D
var direction: Vector3 = Vector3.ZERO
var move_speed: float = default_move_speed
@export var visual_mesh: MeshInstance3D
var bubble_material: ShaderMaterial


func reset_move_speed() -> void:
	move_speed = default_move_speed


func apply_movement(delta: float) -> void:
	velocity = direction * move_speed
	position += velocity * delta
	#move_and_slide() # too expensive for 150 actors


func _ready() -> void:
	if visual_mesh:
		bubble_material = visual_mesh.get_surface_override_material(0)
		$AnimationPlayer.speed_scale = randf_range(0.9, 1.8)
	else:
		push_warning("Mesh not set for %s" % get_path())
