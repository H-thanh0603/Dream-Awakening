class_name InspectInteractable extends Interactable
##
## InspectInteractable — phát một dialogue và (tuỳ chọn) thêm entry vào Sổ Mộng
## khi tương tác. Dùng cho tượng, mặt nạ tường, sổ mộng để bàn, vv.
##

@export var dialogue_id: String = ""
@export var notebook_category: String = ""
@export var notebook_entry_id: String = ""
@export var notebook_data: Dictionary = {}
@export var play_once: bool = false

var _played: bool = false

func _ready() -> void:
	super._ready()
	if prompt_text == "E":
		prompt_text = "E - Quan sát"

func _on_interact() -> void:
	if play_once and _played:
		return
	_played = true
	if notebook_category != "" and notebook_entry_id != "":
		NotebookManager.add_entry(notebook_category, notebook_entry_id, notebook_data)
	if dialogue_id != "" and DialogueManager._dialogues.has(dialogue_id):
		DialogueManager.play(dialogue_id)
