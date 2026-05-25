extends CanvasLayer
##
## DialogueBox — UI hiển thị dialogue với typing effect.
## GDD §C.4, IMPLEMENTATION_PLAN T1.7
##

@onready var panel: Panel = $Panel
@onready var speaker_label: Label = $Panel/SpeakerName
@onready var dialogue_text: RichTextLabel = $Panel/DialogueText
@onready var next_hint: Label = $Panel/NextHint

const TYPE_SPEED := 0.025  # seconds per character

var _full_text: String = ""
var _typing_complete: bool = false
var _is_typing: bool = false
var _skip_typing: bool = false

func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	DialogueManager.dialogue_started.connect(_on_dialogue_started)
	DialogueManager.dialogue_line_shown.connect(_on_line_shown)
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)

func _on_dialogue_started(_id: String) -> void:
	visible = true

func _on_line_shown(speaker: String, text: String) -> void:
	speaker_label.text = speaker
	_full_text = text
	dialogue_text.text = ""
	_typing_complete = false
	_skip_typing = false
	next_hint.visible = false
	_is_typing = true

	var i := 0
	while i < _full_text.length():
		if _skip_typing:
			break
		dialogue_text.text = _full_text.substr(0, i + 1)
		await get_tree().create_timer(TYPE_SPEED, true, false, true).timeout
		i += 1
	dialogue_text.text = _full_text
	_typing_complete = true
	_is_typing = false
	next_hint.visible = true

func _on_dialogue_ended(_id: String) -> void:
	visible = false

func _input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("interact"):
		if not _typing_complete:
			_skip_typing = true
		else:
			DialogueManager.next()
