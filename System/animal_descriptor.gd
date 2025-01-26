class_name AnimalDescriptor extends Resource

enum Type {SKITTISH, NEUTRAL, DEFENSIVE}

@export_placeholder("Jeremy") var name: String
@export_multiline var description: String
@export_range(0.0, 1.0, 0.01) var rating: float = 0.5

@export var color: Color = Color.WHITE
@export var type: Type

func _init(animal_name: String, animal_color: Color, animal_type: Type) -> void:
	name = animal_name
	color = animal_color
	type = animal_type
