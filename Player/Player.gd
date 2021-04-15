extends KinematicBody

class_name Player

export var mouse_sensitivity = 0.5
export var ray_length = 200.0
export var max_corn_count = 7

onready var camera = $Camera
onready var move_component = $MoveComponent
onready var raycast = $RayCast

signal place_corn

var corn = preload("res://Corn/CornPickUp.tscn")
var corn_count = 0

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	move_component.init(self)
	corn_count = max_corn_count


func _process(_delta):
	if Input.is_action_just_pressed("exit"):
		get_tree().quit()
	if Input.is_action_just_pressed("restart"):
		get_tree().reload_current_scene()
	
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
	
	if event is InputEventMouseButton and event.pressed and event.button_index == 1:
		var camera = $Camera
		var from = camera.project_ray_origin(event.position)
		var to = from + camera.project_ray_normal(event.position) * ray_length
		
		var space_state = get_world().get_direct_space_state()
		var result = space_state.intersect_ray(from, to, [], 1, true, true)
		if result:
			add_corn_to_position(result.position)
			
func add_corn_to_position(position: Vector3):
	if corn_count > 0:
		var corn_instance = corn.instance()
		get_tree().get_root().add_child(corn_instance)
		corn_instance.global_transform.origin = position
		corn_count = corn_count - 1
		emit_signal("place_corn")

		
