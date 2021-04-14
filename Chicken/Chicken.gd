extends Spatial

export var sight_angle = 90
export var sight_distance = 2 
export var turn_speed = 60

onready var animation_player: AnimationPlayer = $chicken/AnimationPlayer
onready var question_mark = $question_mark
onready var move_component = $MoveComponent
onready var collision_shape = $CollisionShape
onready var nav: Navigation = get_tree().get_nodes_in_group("nav")[0]

enum STATES { IDLE, WALK, LOOK, TRAPPED }

var current_state = STATES.IDLE
var player_ref = null
var all_corn = null
var closest_corn = null
var path = []

func _ready():
	set_state_look()
	player_ref = get_tree().get_nodes_in_group("player")[0]
	all_corn = get_tree().get_nodes_in_group("corn")
	set_closest_corn(all_corn)
	print(closest_corn)
	move_component.init(self)


func _process(delta):
	can_see_player()
	match current_state:
		STATES.IDLE:
			idle(delta)
		STATES.WALK:
			walk(delta)
		STATES.LOOK:
			look(delta)
		STATES.TRAPPED:
			trapped(delta)

func idle(delta):
	pass

func walk(delta):
	if closest_corn:
		var current_position = global_transform.origin
		var corn_position = closest_corn.global_transform.origin
		path = nav.get_simple_path(current_position, corn_position)
		
		var goal_pos = corn_position
		if path.size() > 1:
			goal_pos = path[1]
			
		var dir = goal_pos - current_position
		dir.y = 0
		move_component.set_movement_vector_as_normalized(dir)
		
		face_dir(dir, delta)
	else:
		# todo: rotate randomly?
		set_state_look()
	
	
func look(delta):
	if closest_corn:
		var current_position = global_transform.origin
		var corn_position = closest_corn.global_transform.origin
		path = nav.get_simple_path(current_position, corn_position)
		
		var dir = corn_position - current_position
		var completed = face_dir(dir, delta)
		if (completed):
			set_state_walk()

	
func trapped(delta):
	move_component.freeze()
	collision_shape.disabled = true

func set_state_idle():
	current_state = STATES.IDLE
	animation_player.play("Idle_loop")

func set_state_walk():
	current_state = STATES.WALK
	animation_player.play("walk_loop")

func set_state_look():
	current_state = STATES.LOOK
	animation_player.play("look", 2.0)

func set_state_trapped():
	current_state = STATES.TRAPPED
	animation_player.play("Idle_loop")

	
func can_see_player():
	var direction_to_player = global_transform.origin.direction_to(player_ref.global_transform.origin)
	var forward = global_transform.basis.z
	var visible = has_los_player() and rad2deg(forward.angle_to(direction_to_player)) < sight_angle
	if visible:
		question_mark.show()
	else:
		question_mark.hide()
		
	return visible
	
func has_los_player():
	var current_position = global_transform.origin + Vector3.UP
	var player_position = player_ref.global_transform.origin + Vector3.UP
	
	var space_state = get_world().direct_space_state
	var result = space_state.intersect_ray(current_position, player_position, [], 2)
	if result:
		var current_distance_to_player = current_position.distance_squared_to(player_position)
		#print(current_distance_to_player)
		if current_distance_to_player < sight_angle:
			return true
		else:
			return false
	else:
		return false
		
func set_closest_corn(all_corn):
	var current_position = global_transform.origin + Vector3.UP
	var closest = null
	var best_distance = 99999999.0
	for c in all_corn:
		var corn_position = c.global_transform.origin + Vector3.UP
		var distance = current_position.distance_squared_to(corn_position)
		if distance < best_distance:
			closest = c
			best_distance = distance
			
		print(distance)
		
	closest_corn = closest
	
func face_dir(dir: Vector3, delta):
	var angle_diff = global_transform.basis.z.angle_to(dir)
	var turn_right = sign(global_transform.basis.x.dot(dir))
	if abs(angle_diff) < deg2rad(turn_speed) * delta:
		rotation.y = atan2(dir.x, dir.z)
		return true
	else:
		rotation.y += deg2rad(turn_speed) * delta * turn_right
		return false
	
	
	
	
	
