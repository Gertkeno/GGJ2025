class_name AnimalDescriptor extends Resource

enum Type {SKITTISH, NEUTRAL, DEFENSIVE}

var name: String
var color: Vector4
var type: Type

func _init(name: String, color, Vector4, type: Type) -> void:
	self.name = name
	self.color = color
	self.type = type
