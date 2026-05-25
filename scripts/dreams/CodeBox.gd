class_name CodeBox extends Interactable
##
## CodeBox — hộp khoá 4 ký hiệu. Mở khi đã thu đủ 4 ký hiệu (qua flag).
## Phần thưởng: thêm vật phẩm vào kho và set một flag.
##

signal opened

@export var required_flags: Array[String] = []
@export var reward_item: String = ""
@export var reward_flag: String = ""
@export var locked_prompt: String = "Hộp khoá — cần 4 ký hiệu"
@export var ready_prompt: String = "E - Mở hộp"
@export var dialogue_id: String = ""

var _opened: bool = false

func _ready() -> void:
	super._ready()
	prompt_text = locked_prompt

func _on_interact() -> void:
	if _opened:
		return
	if not _has_all_flags():
		_flash_missing()
		return
	_opened = true
	enabled = false
	if reward_item != "":
		InventoryManager.add_item(reward_item)
	if reward_flag != "":
		GameState.set_flag(reward_flag, true)
	AudioManager.play_sfx("interact")
	if dialogue_id != "" and DialogueManager._dialogues.has(dialogue_id):
		DialogueManager.play(dialogue_id)
	opened.emit()

func _has_all_flags() -> bool:
	for f in required_flags:
		if not GameState.has_flag(f):
			return false
	return true

func _flash_missing() -> void:
	var got := 0
	for f in required_flags:
		if GameState.has_flag(f):
			got += 1
	var p: Label = get_node_or_null("Prompt")
	if p == null: return
	var orig := p.text
	p.text = "Cần %d/%d ký hiệu" % [got, required_flags.size()]
	p.modulate = Color(1, 0.6, 0.6, 1)
	await get_tree().create_timer(1.2).timeout
	if p:
		p.text = orig
		p.modulate = Color(1, 0.95, 0.6, 1)

func update_prompt_state() -> void:
	if _has_all_flags():
		prompt_text = ready_prompt
