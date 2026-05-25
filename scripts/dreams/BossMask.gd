class_name BossMask extends Node2D
##
## BossMask — flying mask in room 4. Teleports every 3s.
##

signal mask_captured(count: int)

@onready var mask_sprite: Sprite2D = $MaskSprite
@onready var timer_label: Label = $TimerLabel
@onready var capture_label: Label = $CaptureLabel
@export var time_limit: float = 90.0

var _captures: int = 0
const TOTAL_CAPTURES: int = 4
var _time_left: float = 90.0
var _teleport_t: float = 0.0
var _telepart_period: float = 3.0
var _started: bool = false
var _anchors: Array = []
var _player: Node2D
var _bobble_t: float = 0.0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	_time_left = time_limit
	visible = false

func start_fight(player: Node2D) -> void:
	_player = player
	_started = true
	visible = true
	_time_left = time_limit
	_captures = 0
	# Refresh anchor list at fight start (allows scene to fully load)
	_anchors = get_tree().get_nodes_in_group("boss_anchor")
	for a in _anchors:
		if a.has_method("refresh"):
			a.refresh()
	_teleport()
	_update_labels()

func _process(delta: float) -> void:
	if not _started:
		return
	_time_left -= delta
	_teleport_t += delta
	_bobble_t += delta
	mask_sprite.position.y = -8.0 + sin(_bobble_t * 4.0) * 4.0
	if _teleport_t >= _telepart_period:
		_teleport_t = 0.0
		_teleport()
	_update_labels()
	if _time_left <= 0.0:
		_fail_timeout()
	if Input.is_action_just_pressed("interact") and not GameState.current_state in ["DIALOGUE_ACTIVE", "PAUSED"]:
		_try_capture()

func _teleport() -> void:
	var spots := [
		Vector2(560, 320), Vector2(720, 320), Vector2(880, 320),
		Vector2(560, 420), Vector2(720, 420), Vector2(880, 420),
		Vector2(640, 370), Vector2(800, 370)
	]
	position = spots.pick_random()

func _try_capture() -> void:
	if _player == null:
		return
	var nearest_anchor = null
	var best_d: float = 24.0
	for a in _anchors:
		if not a.active:
			continue
		var d: float = a.global_position.distance_to(_player.global_position)
		if d < best_d:
			best_d = d
			nearest_anchor = a
	if nearest_anchor == null:
		return
	var dx: float = abs(global_position.x - _player.global_position.x)
	var dy: float = global_position.y - _player.global_position.y
	if dx < 50.0 and dy > -80.0 and dy < 30.0:
		_captures += 1
		nearest_anchor.consume()
		mask_captured.emit(_captures)
		LucidityManager.recover(15.0)
		_update_labels()
		if _captures >= TOTAL_CAPTURES:
			_win()
		else:
			_teleport_t = 0.0
			_teleport()

func _win() -> void:
	_started = false
	visible = false
	var parent_dream = get_parent()
	if parent_dream and parent_dream.has_method("on_boss_defeated"):
		parent_dream.on_boss_defeated()

func _fail_timeout() -> void:
	_captures = 0
	_time_left = time_limit
	for a in _anchors:
		if a.has_method("refresh"):
			a.refresh()
	LucidityManager.damage(20.0)
	DialogueManager.register_from_dict({
		"id": "mira_boss_fail_%d" % Engine.get_process_frames(),
		"lines": [{"speaker": "Mira", "text": "Em không kịp... Lại nữa thôi."}]
	})
	DialogueManager.play("mira_boss_fail_%d" % Engine.get_process_frames())

func _update_labels() -> void:
	timer_label.text = "Thời gian: %d giây" % int(max(0.0, _time_left))
	capture_label.text = "Mặt nạ: %d/%d" % [_captures, TOTAL_CAPTURES]
