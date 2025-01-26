class_name AnimalDescriptor extends Resource

enum Type {SKITTISH, NEUTRAL, DEFENSIVE}

@export_placeholder("Jeremy") var name: String
@export_multiline var description: String
@export_range(0.0, 1.0, 0.01) var rating: float = 0.5

@export var color: Color = Color.WHITE
@export var type: Type

func _init(name: String, color, Vector4, type: Type) -> void:
	self.name = name
	self.color = color
	self.type = type
