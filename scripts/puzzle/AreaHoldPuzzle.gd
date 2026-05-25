class_name AreaHoldPuzzle extends BasePuzzle
##
## AreaHoldPuzzle — player giữ trong area X giây.
## GDD §B.4.5, IMPLEMENTATION_PLAN T2.9
##

@export var area_path: NodePath

var _player_inside: bool = false
var _elapsed: float = 0.0

func _on_start() -> void:
	var area: Area2D = get_node_or_null(area_path)
	if area == null:
		push_error("AreaHoldPuzzle: area_path không hợp lệ")
		return
	area.body_entered.connect(_on_enter)
	area.body_exited.connect(_on_exit)

func _on_enter(body: Node) -> void:
	if body.is_in_group("player"):
		_player_inside = true

func _on_exit(body: Node) -> void:
	if body.is_in_group("player"):
		_player_inside = false
		if _data.get("interrupt_resets", true):
			_elapsed = 0.0

func _process(delta: float) -> void:
	if not _started or _completed:
		return
	if _player_inside:
		_elapsed += delta
		if _elapsed >= float(_data.get("hold_duration_sec", 5.0)):
			complete()

func check_solution() -> bool:
	return _elapsed >= float(_data.get("hold_duration_sec", 5.0))
