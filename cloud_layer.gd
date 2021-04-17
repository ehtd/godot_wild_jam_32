extends Spatial

export var rotation_speed = 0.001

func _process(delta):
	rotate_y(rotation_speed * delta)
