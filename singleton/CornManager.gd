extends Node

export var corn_pool_size = 2
var corn = preload("res://Corn/CornPickUp.tscn")
var corn_pool = []
var deactivated_corn_pool = []

func new_corn():
	var instance: Pickup = corn.instance()
	
	corn_pool.append(instance)
	
	return instance


func get_active_corn_array():
	var active_corn = []
	for c in corn_pool:
		if c.visible:
			active_corn.append(c)
			
	return active_corn

func deactivate_corn(corn: Pickup):
	corn.hide()
	corn.collision_shape.disabled = true
	corn_pool.erase(corn)
	corn.queue_free()
	
	
