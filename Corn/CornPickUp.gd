extends Area

class_name Pickup

onready var collision_shape = $CollisionShape

func disable():
	CornManager.deactivate_corn(self)

