extends Spatial

export var chicken_sight_angle = 90

onready var animation_player = $chicken/AnimationPlayer

enum STATES { IDLE, WALK, LOOK, TRAPPED }

var current_state = STATES.IDLE
var player_ref = null

func _ready():
	set_state_idle()
	player_ref = get_tree().get_nodes_in_group("player")[0]


func _process(delta):
	print(can_see_player())
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
	pass
	
func look(delta):
	pass
	
func trapped(delta):
	pass

func set_state_idle():
	current_state = STATES.IDLE
	animation_player.play("Idle_loop")
	pass

func set_state_walk():
	current_state = STATES.WALK
	animation_player.play("walk_loop")
	pass

func set_state_look():
	current_state = STATES.LOOK
	animation_player.play("look")
	pass

func set_state_trapped():
	current_state = STATES.TRAPPED
	animation_player.play("Idle_loop")
	pass

func can_see_player():
	var direction_to_player = global_transform.origin.direction_to(player_ref.global_transform.origin)
	var forward = global_transform.basis.z
	return rad2deg(forward.angle_to(direction_to_player)) < chicken_sight_angle
	
func has_los_player():
	var current_position = global_transform.origin + Vector3.UP
	var player_position = player_ref.global_transform.origin + Vector3.UP
	
	var space_state = get_world().direct_space_state
	var result = space_state.intersect_ray(current_position, player_position, [], 2)
	if result:
		return true
	
	return false
	
	
