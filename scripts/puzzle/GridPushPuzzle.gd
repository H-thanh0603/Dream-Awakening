class_name GridPushPuzzle extends BasePuzzle
##
## GridPushPuzzle — Sokoban-like, đẩy block vào ô đích.
## GDD §B.4.4, IMPLEMENTATION_PLAN T2.8
##

@export var block_paths: Array[NodePath] = []

func _on_start() -> void:
	for p in block_paths:
		var b: PushBlock = get_node_or_null(p)
		if b:
			b.moved.connect(_on_moved)

func _on_moved(_cell: Vector2i) -> void:
	if check_solution():
		complete()

func check_solution() -> bool:
	for tc in _data.get("target_cells", []):
		var bid: String = tc.get("block_id", "")
		var b: PushBlock = _find_block(bid)
		if b == null:
			return false
		var cell := b.get_cell()
		var target_arr: Array = tc.get("cell", [0, 0])
		var target := Vector2i(int(target_arr[0]), int(target_arr[1]))
		if cell != target:
			return false
	return true

func _find_block(bid: String) -> PushBlock:
	for p in block_paths:
		var b: PushBlock = get_node_or_null(p)
		if b and b.block_id == bid:
			return b
	return null
