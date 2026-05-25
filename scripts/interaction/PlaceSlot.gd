class_name PlaceSlot extends Interactable
##
## PlaceSlot — Interactable nhận active item từ inventory đặt vào.
##

signal item_placed(item_id: String)

@export var slot_id: String = ""
@export var accepts_items: Array[String] = [] # rỗng = chấp nhận tất cả

var placed_item: String = ""

func _on_interact() -> void:
	var active: String = InventoryManager.get_active_item()
	if active == "":
		return
	if accepts_items.size() > 0 and not active in accepts_items:
		return
	placed_item = active
	InventoryManager.remove_item(active)
	AudioManager.play_sfx("interact")
	item_placed.emit(active)
	enabled = false
	# Visual feedback
	var visual := get_node_or_null("Visual")
	if visual and visual is ColorRect:
		visual.color = Color(0.4, 0.9, 0.5, 1)
