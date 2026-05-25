extends Node
##
## DialogueManager — hiển thị dialogue, evaluate condition theo flag.
## Contract: GDD §C.4
## Phase 0: skeleton + register API. Phase 1 T1.7-T1.8 implement đầy đủ.
##

signal dialogue_started(dialogue_id: String)
signal dialogue_line_shown(speaker: String, text: String)
signal dialogue_ended(dialogue_id: String)

var _inline_dialogues: Dictionary = {}
var _active: bool = false

func _ready() -> void:
	print("[DialogueManager] ready")

func register(dialogue_id: String, lines: Array) -> void:
	_inline_dialogues[dialogue_id] = lines

func play(dialogue_id: String) -> void:
	push_warning("DialogueManager.play() chưa implement (Phase 1 T1.8)")

func next() -> void:
	pass

func cancel() -> void:
	_active = false

func is_active() -> bool:
	return _active
