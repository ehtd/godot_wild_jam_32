extends Spatial

export var sight_angle = 90
export var sight_distance = 2 
export var turn_speed = 100
export var corns_to_hatch = 7


onready var animation_player: AnimationPlayer = $chicken/AnimationPlayer
onready var question_mark = $question_mark
onready var move_component = $MoveComponent
onready var collision_shape = $CollisionShape
onready var pickup_component = $PickupComponent
onready var timer = $Timer
onready var nav: Navigation = get_tree().get_nodes_in_group("nav")[0]
onready var spawn_point = $egg_spawn_point

enum STATES { IDLE, WALK, LOOK, TRAPPED, NO_CORN, SCARED }

var current_state = STATES.IDLE
var player_ref: Player = null
var all_corn: Array = []
var closest_corn = null
var path = []
var chicken_speed = [0.2, 0.5, 2, 3, 1, 0.5, 0.2, 0.1]
onready var _egg = preload("res://egg/egg.tscn")
var corn_ate_count = 0

func _ready():
	randomize() 
	timer.connect("timeout", self, "search_for_corn")
	pickup_component.connect("got_pickup", self, "got_corn")
	player_ref = get_tree().get_nodes_in_group("player")[0]
	player_ref.connect("place_corn", self, "new_corn")
	update_all_corn()
	set_closest_corn()
	set_state_look()
#	search_for_corn()
	#print(closest_corn)
	move_component.init(self)
	
	var rng = RandomNumberGenerator.new()
	rng.randomize()

	move_component.set_custom_speed(randi() % chicken_speed.size())
	question_mark.hide()


func _process(delta):
	update_all_corn()
	set_closest_corn()
	
#	if can_see_player():
#		set_state_scared()
#	else:
#		search_for_corn()

	if closest_corn == null:
		move_component.freeze()
		set_state_no_corn()
		
	match current_state:
		STATES.NO_CORN:
			no_corn(delta)
		STATES.IDLE:
			idle(delta)
		STATES.WALK:
			walk(delta)
		STATES.LOOK:
			look(delta)
		STATES.TRAPPED:
			trapped(delta)
		STATES.SCARED:
			scared(delta)

func no_corn(delta):
	pass
	
func idle(delta):
	pass

func walk(delta):
	if closest_corn:
		var current_position = global_transform.origin
		var corn_position = closest_corn.global_transform.origin
		#print(corn_position)
		path = nav.get_simple_path(current_position, corn_position)
		
		var goal_pos = corn_position
		if path.size() > 1:
			goal_pos = path[1]
			
		var dir = goal_pos - current_position
		dir.y = 0
		move_component.set_movement_vector_as_normalized(dir)
		
		face_dir(dir, delta)
	else:
		set_state_no_corn()
	
	
func look(delta):
	if closest_corn:
		var current_position = global_transform.origin
		var corn_position = closest_corn.global_transform.origin
		var dir = corn_position - current_position
		var completed = face_dir(dir, delta)
		if (completed):
			move_component.unfreeze()
			set_state_walk()

func scared(delta):
	move_component.freeze()
	pass
	
func trapped(delta):
	move_component.freeze()
	collision_shape.disabled = true

func set_state_no_corn():
	current_state = STATES.NO_CORN
	animation_player.play("look")
	#print("no_Corn")
	
func set_state_idle():
	current_state = STATES.IDLE
	animation_player.play("Idle_loop")
	#print("idle")

func set_state_walk():
	current_state = STATES.WALK
	animation_player.play("walk_loop", -1.0, 2.0)
	#print("walk")

func set_state_look():
	current_state = STATES.LOOK
	animation_player.play("look", 2.0)
	#print("look")

func set_state_trapped():
	current_state = STATES.TRAPPED
	animation_player.play("Idle_loop")
	#print("trapped")

func set_state_scared():
	current_state = STATES.SCARED
	animation_player.play("Idle_loop")
	#print("scared")
	
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
		
func set_closest_corn():
	var current_position = global_transform.origin + Vector3.UP
	var closest = null
	var best_distance = 99999999.0
	for c in get_visible_corn():
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
	print(" ", self, "got corn")
	corn_ate_count = corn_ate_count + 1
	if (corn_ate_count >= corns_to_hatch):
		print("about to hatch")
		corn_ate_count = 0
		var egg_instance = _egg.instance()
		get_tree().get_root().add_child(egg_instance)
		egg_instance.global_transform.origin = spawn_point.global_transform.origin
		scale = scale * Vector3(1.2, 1.2, 1.2)
		corns_to_hatch += 7
		
		
	closest_corn = null
	move_component.freeze()
#	print(all_corn)
#	print(closest_corn)
	if get_visible_corn().size() > 0:
#		set_closest_corn()
		set_state_idle()
		timer.start()
	
func search_for_corn():
	#print("searching")
	if get_visible_corn().size() > 0:
#		move_component.unfreeze()
		set_state_look()
	
func update_all_corn():
	all_corn = get_tree().get_nodes_in_group("corn")

func get_visible_corn():
	var visible_corn = []
	for c in get_tree().get_nodes_in_group("corn"):
		if c.visible:
			visible_corn.append(c)
	return visible_corn

func new_corn():
#	print("new corn")
	update_all_corn()
	set_closest_corn()
	search_for_corn()
	
