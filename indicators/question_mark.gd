extends Spatial

onready var animation_player = $AnimationPlayer
onready var question_mark = $question_mark


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func hide():
	question_mark.visible = false
	
func show():
	question_mark.visible = true
