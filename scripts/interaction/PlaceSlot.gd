class_name PlaceSlot extends Interactable
##
## PlaceSlot — Interactable nhận active item từ inventory đặt vào.
##

signal item_placed(item_id: String)

@export var slot_id: String = ""
@export var accepts_items: Array[String] = [] # rỗng = chấp nhận tất cả
@export var multi_use: bool = false  # true → không tự khoá sau khi đặt

var placed_item: String = ""

func _on_interact() -> void:
	var active: String = InventoryManager.get_active_item()
	# Nếu slot có filter và active không khớp, tìm trong kho item phù hợp
	if accepts_items.size() > 0:
		if not active in accepts_items:
			var found: String = ""
			for it in InventoryManager.get_all_items():
				if it in accepts_items:
					found = it
					break
			if found == "":
				_show_mismatch()
				return
			InventoryManager.set_active_item(found)
			active = found
	if active == "":
		_show_mismatch()
		return
	placed_item = active
	InventoryManager.remove_item(active)
	AudioManager.play_sfx("interact")
	item_placed.emit(active)
	# Visual feedback (green flash)
	var visual := get_node_or_null("Visual")
	if visual and visual is ColorRect:
		visual.color = Color(0.4, 0.9, 0.5, 1)
	if not multi_use:
		enabled = false
		_hide_prompt()

func _show_mismatch() -> void:
	var p: Label = get_node_or_null("Prompt")
	if p:
		var orig: String = p.text
		p.text = "Cần đúng vật phẩm"
		p.modulate = Color(1, 0.5, 0.5, 1)
		await get_tree().create_timer(1.0).timeout
		if p:
			p.text = orig
			p.modulate = Color(1, 0.9, 0.4, 1)
