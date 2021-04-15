extends Spatial

export var sight_angle = 90
export var sight_distance = 2 
export var turn_speed = 60

onready var animation_player: AnimationPlayer = $chicken/AnimationPlayer
onready var question_mark = $question_mark
onready var move_component = $MoveComponent
onready var collision_shape = $CollisionShape
onready var pickup_component = $PickupComponent
onready var timer = $Timer
onready var nav: Navigation = get_tree().get_nodes_in_group("nav")[0]

enum STATES { IDLE, WALK, LOOK, TRAPPED }

var current_state = STATES.IDLE
var player_ref = null
var all_corn: Array = []
var closest_corn = null
var path = []


func _ready():
	timer.connect("timeout", self, "search_for_corn")
	pickup_component.connect("got_pickup", self, "got_corn")
	search_for_corn()
	player_ref = get_tree().get_nodes_in_group("player")[0]
	all_corn = get_tree().get_nodes_in_group("corn")
	set_closest_corn(all_corn)
	#print(closest_corn)
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
		set_state_idle()
	
	
func look(delta):
	if closest_corn:
		var current_position = global_transform.origin
		var corn_position = closest_corn.global_transform.origin
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
	print("idle")

func set_state_walk():
	current_state = STATES.WALK
	animation_player.play("walk_loop")
	print("walk")

func set_state_look():
	current_state = STATES.LOOK
	animation_player.play("look", 2.0)
	print("look")

func set_state_trapped():
	current_state = STATES.TRAPPED
	animation_player.play("Idle_loop")
	print("trapped")

	
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
			
		#print(distance)
		
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
	
func got_corn():
	print("got corn")
	all_corn.erase(closest_corn)
	closest_corn = null
	move_component.freeze()
	print(all_corn)
	print(closest_corn)
	if all_corn.size() > 0:
		set_closest_corn(all_corn)
		set_state_idle()
		timer.start()
	
func search_for_corn():
	print("searching")
	move_component.unfreeze()
	set_state_look()
	

	
	
