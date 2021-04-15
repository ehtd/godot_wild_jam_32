extends Area

signal got_pickup


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	connect("area_entered", self, "on_area_enter")


func on_area_enter(pickup: Pickup):
	#print(pickup)
	emit_signal("got_pickup")
	pickup.queue_free()
