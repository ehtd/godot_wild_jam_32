extends Spatial

onready var timer = $Timer

# Called when the node enters the scene tree for the first time.
func _ready():
	timer.connect("timeout",self,"hatch")
	timer.start()

func hatch():
	print("hatching")
	var chicken = load("res://Chicken/Chicken_scn.tscn")
	var chicken_instance = chicken.instance()
	get_tree().get_root().add_child(chicken_instance)
	var current_pos = global_transform.origin
	chicken_instance.global_transform.origin = current_pos
	hide()


