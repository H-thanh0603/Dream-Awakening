extends CharacterBody2D
##
## PlayerController — di chuyển 4 hướng top-down, push block, interact.
## GDD §C.12, IMPLEMENTATION_PLAN T1.4
##

const SPEED := 80.0  # px/s

var facing: String = "down"  # "up" | "down" | "left" | "right"

func _ready() -> void:
	add_to_group("player")

func _physics_process(_delta: float) -> void:
	# Lock movement during dialogue / pause
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

	velocity = input_vec * SPEED
	move_and_slide()

	# Update facing — dominant axis
	if abs(input_vec.x) > abs(input_vec.y):
		if input_vec.x > 0:
			facing = "right"
		elif input_vec.x < 0:
			facing = "left"
	elif abs(input_vec.y) > 0.01:
		if input_vec.y > 0:
			facing = "down"
		else:
			facing = "up"

	# Push detection (Phase 2 puzzle GridPush)
	for i in get_slide_collision_count():
		var col := get_slide_collision(i)
		var collider = col.get_collider()
		if collider and collider.has_method("try_push"):
			var dir := Vector2i(round(velocity.normalized().x), round(velocity.normalized().y))
			if dir != Vector2i.ZERO:
				collider.try_push(dir)
