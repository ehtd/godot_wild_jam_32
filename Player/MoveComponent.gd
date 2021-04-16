extends Spatial

var kinematic_body: KinematicBody = null

export var movement_acceleration = 4
export var max_speed = 25
export var jump_force = 30
export var gravity = 60
export var ignore_rotation = false

var drag = 0.0

var pressed_jump = false
var movement_vector: Vector3 = Vector3()
var velocity: Vector3 = Vector3()
var snap_vector: Vector3 = Vector3()
var fps_setting = ProjectSettings.get_setting("physics/common/physics_fps")

signal movement_info

var frozen = false

func _ready():
	drag = float(movement_acceleration) / max_speed

func init(_kinematic_body: KinematicBody):
	kinematic_body = _kinematic_body
	
func jump():
	pressed_jump = true
	
func set_movement_vector_as_normalized(_movement_vector: Vector3):
	movement_vector = _movement_vector.normalized()
	
func _physics_process(delta):
	if frozen:
		return
	
	var current_movement_vector = movement_vector
	
	if ignore_rotation == false:
		current_movement_vector = current_movement_vector.rotated(Vector3.UP, kinematic_body.rotation.y)

	velocity += movement_acceleration * current_movement_vector - velocity * Vector3(drag, 0, drag) + gravity * Vector3.DOWN * delta
	kinematic_body.move_and_slide_with_snap(velocity, snap_vector, Vector3.UP)

	
	
func freeze():
	frozen = true
	
func unfreeze():
	frozen = false
	




