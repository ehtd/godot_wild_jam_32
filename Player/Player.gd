extends KinematicBody

class_name Player

export var mouse_sensitivity = 0.5
export var ray_length_corn = 200.0
export var ray_length_chicken = 2.0
export var max_corn_count = 7

onready var camera = $Camera
onready var move_component = $MoveComponent
onready var raycast = $RayCast
onready var fps_label = $CanvasLayer/Label
onready var crosshair: TextureRect = $CanvasLayer/TextureRect

var crosshair_normal_tex = null
var crosshair_grab_tex = null

signal place_corn

var corn = preload("res://Corn/CornPickUp.tscn")
var corn_count = 0

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	move_component.init(self)
	corn_count = max_corn_count
	crosshair_normal_tex = load("res://crosshair.png")
	crosshair_grab_tex = load("res://crosshair_selected.png")


func _process(_delta):
	update_ui()
	
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
	
	if Input.is_action_just_pressed("grab"):
		var result = can_grab_chicken()["result"]
		if result:
			add_corn_to_position(result.position)
		
		
func _input(event):
	if event is InputEventMouseMotion:
		rotation_degrees.y -= mouse_sensitivity * event.relative.x
		camera.rotation_degrees.x -= mouse_sensitivity * event.relative.y
		camera.rotation_degrees.x = clamp(camera.rotation_degrees.x, -90, 90)
	
	if event is InputEventMouseButton and event.pressed and event.button_index == 1:
		var result = get_ray_intersected_dictionary(event.position, 1, ray_length_corn)
		if result:
			add_corn_to_position(result.position)

func update_ui():
	fps_label.text = str(Engine.get_frames_per_second())
	
	if can_grab_chicken()["can_grab"]:
		set_crosshair_grab()
	else:
		set_crosshair_normal()
	
func can_grab_chicken():
	var chicken_mask = 4
	var mouse_pos = get_viewport().get_mouse_position()
	var result = get_ray_intersected_dictionary(mouse_pos, chicken_mask, ray_length_chicken)
	var can_grab = false
	
	if result:
		can_grab = true
	
	return {
		"can_grab": can_grab,
		"result": result
	}
	
func get_ray_intersected_dictionary(coordinates: Vector2, collision_mask: int, ray_length):
	var camera = $Camera
	var from = camera.project_ray_origin(coordinates)
	var to = from + camera.project_ray_normal(coordinates) * ray_length
	var space_state = get_world().get_direct_space_state()
	var result = space_state.intersect_ray(from, to, [], collision_mask, true, true)
	return result
		
func add_corn_to_position(position: Vector3):
	if corn_count > 0:
		var corn_instance = corn.instance()
		get_tree().get_root().add_child(corn_instance)
		corn_instance.global_transform.origin = position
		corn_count = corn_count - 1
		emit_signal("place_corn")

func set_crosshair_normal():
	crosshair.texture = crosshair_normal_tex

func set_crosshair_grab():
	crosshair.texture = crosshair_grab_tex
