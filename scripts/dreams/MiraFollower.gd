class_name MiraFollower extends CharacterBody2D
##
## MiraFollower — Mira (đeo mặt nạ) hoặc Mira Nhỏ. Khi `following = true`
## sẽ đi theo player trong khoảng cách `follow_distance`.
##

@export var following: bool = false
@export var follow_distance: float = 24.0
@export var speed: float = 50.0
@export var bob_amplitude: float = 1.5
@export var bob_speed: float = 2.0

var _target: Node2D
var _bob_t: float = 0.0
var _base_y_offset: float = 0.0

@onready var _sprite: Sprite2D = $Sprite

func _ready() -> void:
	add_to_group("mira_follower")
	# Tìm player theo group
	var players := get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		_target = players[0]
	if _sprite:
		_base_y_offset = _sprite.position.y

func _physics_process(delta: float) -> void:
	_bob_t += delta * bob_speed
	if _sprite:
		_sprite.position.y = _base_y_offset + sin(_bob_t * TAU) * bob_amplitude
	if not following or _target == null:
		velocity = Vector2.ZERO
		move_and_slide()
		return
	var to: Vector2 = _target.global_position - global_position
	if to.length() <= follow_distance:
		velocity = velocity.lerp(Vector2.ZERO, 0.2)
	else:
		velocity = to.normalized() * speed
		if _sprite and to.x != 0:
			_sprite.flip_h = to.x < 0
	move_and_slide()

func start_following() -> void:
	following = true

func stop_following() -> void:
	following = false

func teleport_to(pos: Vector2) -> void:
	global_position = pos
