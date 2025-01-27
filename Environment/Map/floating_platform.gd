extends Node3D

@onready var point_a: Marker3D = $PointA
@onready var point_b: Marker3D = $PointB
@onready var body: AnimatableBody3D = $AnimatableBody3D
@export_range(0.1, 10.0, 0.05) var speed: float = 3.0


func _ready() -> void:
	var t := create_tween().set_loops().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
	var distance: float = point_a.position.distance_to(point_b.position)
	t.tween_property(body, "position", point_a.position, distance / speed).from(point_b.position)
	t.tween_property(body, "position", point_b.position, distance / speed).from(point_a.position)
