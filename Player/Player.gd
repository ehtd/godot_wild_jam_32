extends KinematicBody

export var mouse_sensitivity = 0.5

onready var camera = $Camera
onready var move_component = $MoveComponent

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	move_component.init(self)


func _process(_delta):
	if Input.is_action_just_pressed("exit"):
		get_tree().quit()
	
	var move_vector = Vector3()
	if Input.is_action_pressed("move_forward"):
		move_vector += Vector3.FORWARD
	if Input.is_action_pressed("move_backwards"):
		move_vector += Vector3.BACK
	if Input.is_action_pressed("move_left"):
		move_vector += Vector3.LEFT
	if Input.is_action_pressed("move_right"):
		move_vector += Vector3.RIGHT
	
	move_component.set_movement_vector_as_normalized(move_vector)
	
	if Input.is_action_just_pressed("jump"):
		move_component.jump()
	
func _input(event):
	if event is InputEventMouseMotion:
		rotation_degrees.y -= mouse_sensitivity * event.relative.x
		camera.rotation_degrees.x -= mouse_sensitivity * event.relative.y
		camera.rotation_degrees.x = clamp(camera.rotation_degrees.x, -90, 90)
		
