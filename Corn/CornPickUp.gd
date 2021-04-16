extends Area

class_name Pickup

onready var collision_shape = $CollisionShape

func disable():
	hide()
	collision_shape.disabled = true

