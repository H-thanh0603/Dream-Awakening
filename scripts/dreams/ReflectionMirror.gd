class_name ReflectionMirror extends Interactable
##
## ReflectionMirror — gương "phản chiếu phía sau" trong Hành Lang Mặt Nạ.
## Chỉ hiện vật được đặt sau cột bằng cách tween modulate.alpha hoặc set visible
## của target_node khi player đứng trong tầm.
##

@export var reveal_target_path: NodePath
@export var reveal_only_when_in_range: bool = true
@export var reveal_dialogue: String = "mira_reflection_hint"

var _revealed: bool = false

func _ready() -> void:
	super._ready()
	prompt_text = "E - Soi gương"
	_set_target_visible(false)

func _on_interact() -> void:
	if _revealed:
		return
	_revealed = true
	_set_target_visible(true)
	AudioManager.play_sfx("interact")
	if DialogueManager._dialogues.has(reveal_dialogue):
		DialogueManager.play(reveal_dialogue)
	else:
		# Fallback inline dialogue
		DialogueManager.register_from_dict({
			"id": "reflection_hint_inline",
			"lines": [{"speaker": "???", "text": "Có gì đó đứng sau cột — chỉ gương này thấy."}]
		})
		DialogueManager.play("reflection_hint_inline")

func _set_target_visible(v: bool) -> void:
	var t = get_node_or_null(reveal_target_path)
	if t == null:
		return
	if "visible" in t:
		t.visible = v
	if "enabled" in t:
		t.enabled = v
