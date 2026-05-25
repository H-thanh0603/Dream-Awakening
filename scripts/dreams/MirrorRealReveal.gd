class_name MirrorRealReveal extends Interactable
##
## MirrorRealReveal — đối tượng được "soi" bằng Mảnh phản chiếu (mirror_real).
## Khi player có item `mirror_real` đứng trước nó và E:
##   - đổi sprite sang `revealed_sprite` (hoặc set visible target)
##   - set flag
##   - phát dialogue
## Không tiêu thụ mirror_real (phản chiếu là công cụ).
##

signal revealed

@export var required_item: String = "mirror_real"
@export var set_flag_on_reveal: String = ""
@export var dialogue_id: String = ""
@export var revealed_target_path: NodePath
@export var hide_self_after: bool = false
@export var reveal_prompt: String = "E - Soi bằng Mảnh phản chiếu"

var _revealed: bool = false

func _ready() -> void:
	super._ready()
	prompt_text = reveal_prompt

func _on_interact() -> void:
	if _revealed:
		return
	if required_item != "" and not InventoryManager.has_item(required_item):
		_show_need()
		return
	_revealed = true
	if set_flag_on_reveal != "":
		GameState.set_flag(set_flag_on_reveal, true)
	var t = get_node_or_null(revealed_target_path)
	if t and "visible" in t:
		t.visible = true
	if dialogue_id != "" and DialogueManager._dialogues.has(dialogue_id):
		DialogueManager.play(dialogue_id)
	if hide_self_after:
		visible = false
		enabled = false
	revealed.emit()

func _show_need() -> void:
	var p: Label = get_node_or_null("Prompt")
	if p == null: return
	var orig := p.text
	p.text = "Cần Mảnh phản chiếu"
	p.modulate = Color(1, 0.6, 0.6, 1)
	await get_tree().create_timer(1.0).timeout
	if p:
		p.text = orig
		p.modulate = Color(1, 0.95, 0.6, 1)
