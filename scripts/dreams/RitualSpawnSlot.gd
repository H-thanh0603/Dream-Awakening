class_name RitualSpawnSlot extends Interactable
##
## RitualSpawnSlot — slot dùng trong Nghi Thức.
## Khi player E + đang cầm `required_item`:
##   1. Item bị tiêu thụ
##   2. Set `set_flag` (nếu cấu hình)
##   3. Hiện node `reveal_path` (vd: spawn Mira Nhỏ; visual gương thật)
##   4. Có thể phát dialogue
##

signal placed

@export var slot_id: String = "ritual_slot"
@export var required_item: String = ""
@export var set_flag: String = ""
@export var reveal_path: NodePath
@export var dialogue_id: String = ""
@export var place_prompt: String = "E - Đặt vật phẩm"

var _placed: bool = false

func _ready() -> void:
	super._ready()
	prompt_text = place_prompt

func _on_interact() -> void:
	if _placed:
		return
	if required_item != "" and not InventoryManager.has_item(required_item):
		_show_need()
		return
	if required_item != "":
		InventoryManager.remove_item(required_item)
	_placed = true
	if set_flag != "":
		GameState.set_flag(set_flag, true)
	var n = get_node_or_null(reveal_path)
	if n:
		n.visible = true
		# Nếu là MiraFollower → vẫn idle
		if "modulate" in n:
			n.modulate.a = 0.0
			var tw := create_tween()
			tw.tween_property(n, "modulate:a", 1.0, 0.6)
	enabled = false
	_hide_prompt()
	if dialogue_id != "" and DialogueManager._dialogues.has(dialogue_id):
		DialogueManager.play(dialogue_id)
	placed.emit()

func _show_need() -> void:
	var p: Label = get_node_or_null("Prompt")
	if p == null: return
	var orig := p.text
	p.text = "Cần: %s" % required_item
	p.modulate = Color(1, 0.6, 0.6, 1)
	await get_tree().create_timer(1.0).timeout
	if p:
		p.text = orig
		p.modulate = Color(1, 0.95, 0.6, 1)
