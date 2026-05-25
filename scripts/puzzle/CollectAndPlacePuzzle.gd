class_name CollectAndPlacePuzzle extends BasePuzzle
##
## CollectAndPlacePuzzle — nhặt item rồi đặt vào slot.
## GDD §B.4.1, IMPLEMENTATION_PLAN T2.5
##

@export var slot_paths: Array[NodePath] = []

var _placed_log: Array = []  # Array of {slot_id, item}

func _on_start() -> void:
	for p in slot_paths:
		var slot: PlaceSlot = get_node_or_null(p)
		if slot:
			slot.item_placed.connect(_on_item_placed.bind(slot.slot_id))

func _on_item_placed(item_id: String, slot_id: String) -> void:
	_placed_log.append({"slot_id": slot_id, "item": item_id})
	if check_solution():
		complete()

func check_solution() -> bool:
	var required: Array = _data.get("required_items", [])
	var placed_items: Array = []
	for entry in _placed_log:
		placed_items.append(entry["item"])
	if _data.get("order_matters", false):
		var order: Array = _data.get("correct_order", [])
		return placed_items == order
	# Set check
	for r in required:
		if not r in placed_items:
			return false
	return true
