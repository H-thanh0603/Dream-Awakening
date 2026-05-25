extends Node
##
## InventoryManager — vật phẩm puzzle.
## Contract: GDD §C.6
## Phase 0: skeleton. Phase 2 T2.3 implement đầy đủ.
##

signal item_added(item_id: String)
signal item_removed(item_id: String)
signal active_item_changed(old_id: String, new_id: String)

const MAX_SLOTS := 8

var _items: Array = []
var _active: String = ""

func _ready() -> void:
	print("[InventoryManager] ready")

func add_item(item_id: String) -> bool:
	if _items.size() >= MAX_SLOTS:
		return false
	if item_id in _items:
		return false
	_items.append(item_id)
	item_added.emit(item_id)
	if _active == "":
		set_active_item(item_id)
	return true

func remove_item(item_id: String) -> bool:
	if not item_id in _items:
		return false
	_items.erase(item_id)
	item_removed.emit(item_id)
	if _active == item_id:
		set_active_item(_items[0] if _items.size() > 0 else "")
	return true

func has_item(item_id: String) -> bool:
	return item_id in _items

func get_all_items() -> Array:
	return _items.duplicate()

func set_active_item(item_id: String) -> void:
	if _active == item_id:
		return
	var old: String = _active
	_active = item_id
	active_item_changed.emit(old, item_id)

func get_active_item() -> String:
	return _active
