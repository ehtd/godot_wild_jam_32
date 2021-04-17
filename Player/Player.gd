extends KinematicBody

class_name Player

export var mouse_sensitivity = 0.2
export var ray_length_corn = 200.0
export var ray_length_chicken = 2.0
export var max_corn_count = 20

onready var camera = $Camera
onready var move_component = $MoveComponent
onready var raycast = $RayCast
onready var fps_label = $CanvasLayer/Label
onready var corn_count_label = $CanvasLayer/corn_label
onready var crosshair: TextureRect = $CanvasLayer/TextureRect
onready var press_e: RichTextLabel = $CanvasLayer/press_e

var crosshair_normal_tex = null
var crosshair_grab_tex = null

signal place_corn
signal open_storage

var corn = preload("res://Corn/CornPickUp.tscn")
var corn_count = 0

var storage = null
var ground = null

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	move_component.init(self)
	corn_count = max_corn_count
	crosshair_normal_tex = load("res://crosshair.png")
	crosshair_grab_tex = load("res://crosshair_selected.png")
	storage = get_tree().get_nodes_in_group("storage")[0]
	ground = get_tree().get_nodes_in_group("ground")[0]
#	print(ground.get_instance_id())


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
		var result = can_grab_storage()["result"]
		if result:
			corn_count = max_corn_count
			emit_signal("open_storage")

		
		
func _input(event):
	if event is InputEventMouseMotion:
		rotation_degrees.y -= mouse_sensitivity * event.relative.x
		camera.rotation_degrees.x -= mouse_sensitivity * event.relative.y
		camera.rotation_degrees.x = clamp(camera.rotation_degrees.x, -90, 90)
	
	if event is InputEventMouseButton and event.pressed and event.button_index == 1:
		var result = get_ray_intersected_dictionary(event.position, 1, ray_length_corn, [])
		if result:
			var id_to_check = result.collider.get_owner().get_instance_id()
#			print(id_to_check)
			if id_to_check == ground.get_instance_id():
				add_corn_to_position(result.position)

func update_ui():
	fps_label.text = str(Engine.get_frames_per_second())
	corn_count_label.text = " x " + str(corn_count)
	if can_grab_item(4+64)["can_grab"]:
		set_crosshair_grab()
	else:
		set_crosshair_normal()

func can_grab_chicken():
	var chicken_mask = 4
	return can_grab_item(chicken_mask)

func can_grab_storage():
	var storage_mask = 64
	return can_grab_item(storage_mask)
	
func can_grab_item(mask: int):
	var mouse_pos = get_viewport().get_mouse_position()
	var result = get_ray_intersected_dictionary(mouse_pos, mask, ray_length_chicken, [])
	var can_grab = false
	
	if result:
		can_grab = true
	
	return {
		"can_grab": can_grab,
		"result": result
	}
	
func get_ray_intersected_dictionary(coordinates: Vector2, collision_mask: int, ray_length, exclude: Array):
	var camera = $Camera
	var from = camera.project_ray_origin(coordinates)
	var to = from + camera.project_ray_normal(coordinates) * ray_length
	var space_state = get_world().get_direct_space_state()
	var result = space_state.intersect_ray(from, to, exclude, collision_mask, true, true)
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
	press_e.hide()

func set_crosshair_grab():
	crosshair.texture = crosshair_grab_tex
	press_e.show()
