class_name RotateReflectPuzzle extends BasePuzzle
##
## RotateReflectPuzzle — xoay rotator đến góc đúng (có tolerance).
## GDD §B.4.3, IMPLEMENTATION_PLAN T2.7
##

func _on_start() -> void:
	for r in _data.get("rotators", []):
		var path: String = r.get("node_path", "")
		var rot: Rotator = get_node_or_null(path)
		if rot:
			rot.rotated.connect(_check)

func _check(_angle: float) -> void:
	if check_solution():
		complete()

func check_solution() -> bool:
	var tol: float = float(_data.get("tolerance_deg", 5.0))
	for r in _data.get("rotators", []):
		var rot: Rotator = get_node_or_null(r.get("node_path", ""))
		if rot == null:
			return false
		var target: float = float(r.get("correct_angle_deg", 0.0))
		var diff: float = abs(fposmod(rot.current_angle - target + 180.0, 360.0) - 180.0)
		if diff > tol:
			return false
	return true
