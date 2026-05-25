class_name MaskSlot extends Interactable
##
## MaskSlot — khe gắn mặt nạ trên tường. Hai loại "outer" / "inner".
## Khi item placed, hỏi MiraMaskWall để check correctness.
##

signal mask_attached(mask_id: String, slot_id: String)
signal mask_removed(mask_id: String, slot_id: String)

@export var slot_id: String = "slot"
@export var row_kind: String = "outer"   # "outer" | "inner"
@export var accepts_items: Array[String] = []
@export var place_prompt: String = "E - Gắn mặt nạ"
@export var remove_prompt: String = "E - Tháo"

var attached_mask: String = ""

func _ready() -> void:
	super._ready()
	prompt_text = place_prompt

func _on_interact() -> void:
	if attached_mask != "":
		_remove_current()
		return
	var active := InventoryManager.get_active_item()
	if accepts_items.size() > 0 and not active in accepts_items:
		# Tự tìm mặt nạ phù hợp trong inventory
		var found := ""
		for it in InventoryManager.get_all_items():
			if it in accepts_items:
				found = it
				break
		if found == "":
			_flash("Không gắn được mặt nạ này vào đây")
			return
		InventoryManager.set_active_item(found)
		active = found
	if active == "":
		_flash("Không có mặt nạ trong tay")
		return
	attached_mask = active
	InventoryManager.remove_item(active)
	prompt_text = remove_prompt
	AudioManager.play_sfx("interact")
	_update_visual()
	mask_attached.emit(active, slot_id)

func _remove_current() -> void:
	if attached_mask == "":
		return
	var mid := attached_mask
	InventoryManager.add_item(mid)
	mask_removed.emit(mid, slot_id)
	attached_mask = ""
	prompt_text = place_prompt
	_update_visual()

func _update_visual() -> void:
	var ph: Node = get_node_or_null("Placeholder")
	var attached: Sprite2D = get_node_or_null("Attached")
	if ph and "visible" in ph:
		ph.visible = attached_mask == ""
	if attached:
		attached.visible = attached_mask != ""
		if attached_mask != "":
			# tint theo cảm xúc đơn giản
			attached.modulate = _tint_for(attached_mask)

func _tint_for(mid: String) -> Color:
	match mid:
		"mask_smile":     return Color(1.0, 0.95, 0.75)
		"mask_obedient":  return Color(0.95, 0.95, 1.0)
		"mask_quiet":     return Color(0.85, 0.9, 0.95)
		"mask_fear":      return Color(0.85, 0.7, 0.95)
		"mask_tired":     return Color(0.7, 0.75, 0.85)
		"mask_angry":     return Color(1.0, 0.65, 0.65)
		_:                return Color(1, 1, 1)

func _flash(msg: String) -> void:
	var p: Label = get_node_or_null("Prompt")
	if p == null:
		return
	var orig := p.text
	p.text = msg
	p.modulate = Color(1, 0.6, 0.6, 1)
	await get_tree().create_timer(1.0).timeout
	if p:
		p.text = orig
		p.modulate = Color(1, 0.95, 0.6, 1)
