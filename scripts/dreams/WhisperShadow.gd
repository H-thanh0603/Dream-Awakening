class_name WhisperShadow extends CharacterBody2D
##
## WhisperShadow — patrols a path; if player enters vision cone, drains lucidity.
## Sprites/$VisionArea polygon collider tells line-of-sight.
##
## Setup in scene:
##   patrol_points: Array[Vector2] (in local coords); appended to global pos
##   speed: float
##   facing: -1 = left, 1 = right (auto-flips)
##

@export var patrol_points: Array[Vector2] = []
@export var speed: float = 32.0

var _idx: int = 0
var _player_in_cone: bool = false
var _draining: bool = false
@onready var vision_area: Area2D = $VisionArea
@onready var sprite: Sprite2D = $Sprite

func _ready() -> void:
	collision_layer = 8
	collision_mask = 0
	add_to_group("whisper_shadow")
	if vision_area:
		vision_area.body_entered.connect(_on_player_seen)
		vision_area.body_exited.connect(_on_player_lost)

func _physics_process(delta: float) -> void:
	if patrol_points.is_empty():
		return
	var target: Vector2 = patrol_points[_idx]
	var dir: Vector2 = (target - position)
	if dir.length() < 2.0:
		_idx = (_idx + 1) % patrol_points.size()
		return
	velocity = dir.normalized() * speed
	# Flip vision cone left/right
	if sprite and abs(dir.x) > 0.1:
		var flip: bool = dir.x < 0
		sprite.flip_h = flip
		if vision_area:
			vision_area.scale.x = -1.0 if flip else 1.0
	move_and_slide()

func _on_player_seen(body: Node) -> void:
	if body.is_in_group("player"):
		_player_in_cone = true
		if not _draining:
			LucidityManager.add_drain_source()
			_draining = true

func _on_player_lost(body: Node) -> void:
	if body.is_in_group("player"):
		_player_in_cone = false
		if _draining:
			LucidityManager.remove_drain_source()
			_draining = false

func _exit_tree() -> void:
	if _draining:
		LucidityManager.remove_drain_source()
		_draining = false
