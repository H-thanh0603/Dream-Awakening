class_name MirrorClone extends CharacterBody2D
##
## MirrorClone — Mira's reflection. Mirrors player X movement; same Y movement.
## Used in Mirror Hallway puzzle.
##

const SPEED := 80.0

@export var player_path: NodePath
var _player: CharacterBody2D = null

func _ready() -> void:
	collision_layer = 16
	collision_mask = 1
	add_to_group("mirror_clone")
	if player_path:
		_player = get_node_or_null(player_path)

func _physics_process(_delta: float) -> void:
	if _player == null:
		return
	if GameState.current_state in ["DIALOGUE_ACTIVE", "PAUSED", "RITUAL_READY"]:
		velocity = Vector2.ZERO
		move_and_slide()
		return
	var input_vec := Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_up", "move_down")
	)
	if input_vec.length() > 1.0:
		input_vec = input_vec.normalized()
	# MIRROR: invert X
	input_vec.x = -input_vec.x
	velocity = input_vec * SPEED
	move_and_slide()
