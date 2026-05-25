class_name OrderedSlotsPuzzle extends BasePuzzle
##
## OrderedSlotsPuzzle — mỗi slot expect 1 item cụ thể.
## GDD §B.4.2, IMPLEMENTATION_PLAN T2.6
##

@export var slot_paths: Array[NodePath] = []

func _on_start() -> void:
	for p in slot_paths:
		var slot: PlaceSlot = get_node_or_null(p)
		if slot:
			slot.item_placed.connect(_check)

func _check(_item: String) -> void:
	if check_solution():
		complete()

func check_solution() -> bool:
	for slot_def in _data.get("slots", []):
		var sid: String = slot_def.get("slot_id", "")
		var expected: String = slot_def.get("expected_item", "")
		var slot: PlaceSlot = _find_slot(sid)
		if slot == null or slot.placed_item != expected:
			return false
	return true

func _find_slot(sid: String) -> PlaceSlot:
	for p in slot_paths:
		var s: PlaceSlot = get_node_or_null(p)
		if s and s.slot_id == sid:
			return s
	return null
