extends Node
##
## DialogueManager — hiển thị dialogue với typing effect, evaluate condition.
## GDD §C.4, IMPLEMENTATION_PLAN T1.7-T1.8
##

signal dialogue_started(dialogue_id: String)
signal dialogue_line_shown(speaker: String, text: String)
signal dialogue_ended(dialogue_id: String)

var _inline_dialogues: Dictionary = {}  # id -> Array of lines
var _queue: Array = []                  # pending dialogue ids
var _current_lines: Array = []
var _current_index: int = 0
var _current_id: String = ""
var _active: bool = false
var _previous_state: String = ""

func _ready() -> void:
	print("[DialogueManager] ready")

func register(dialogue_id: String, lines: Array) -> void:
	_inline_dialogues[dialogue_id] = lines

func register_from_dict(data: Dictionary) -> void:
	# Used by Phase 2 JSON loader
	if not data.has("id") or not data.has("lines"):
		push_error("Invalid dialogue dict: " + str(data))
		return
	_inline_dialogues[data["id"]] = data["lines"]

func play(dialogue_id: String) -> void:
	if not _inline_dialogues.has(dialogue_id):
		push_warning("Dialogue not found: " + dialogue_id)
		return
	if _active:
		_queue.append(dialogue_id)
		return
	_start(dialogue_id)

func _start(dialogue_id: String) -> void:
	_current_id = dialogue_id
	_current_lines = _inline_dialogues[dialogue_id].duplicate()
	_current_index = 0
	_active = true
	_previous_state = GameState.current_state
	GameState.set_state("DIALOGUE_ACTIVE")
	dialogue_started.emit(dialogue_id)
	_show_current()

func _show_current() -> void:
	while _current_index < _current_lines.size():
		var line: Dictionary = _current_lines[_current_index]
		var cond: String = line.get("condition", "")
		if cond != "" and not GameState.evaluate(cond):
			_current_index += 1
			continue
		dialogue_line_shown.emit(
			str(line.get("speaker", "")),
			str(line.get("text", ""))
		)
		# Side-effects (set flags, give items, play sfx)
		var effects: Dictionary = line.get("side_effect", {})
		for f in effects.get("set_flags", []):
			GameState.set_flag(str(f), true)
		for item in effects.get("give_items", []):
			InventoryManager.add_item(str(item))
		var sfx: String = effects.get("play_sfx", "")
		if sfx != "":
			AudioManager.play_sfx(sfx)
		return
	_end()

func next() -> void:
	if not _active:
		return
	_current_index += 1
	_show_current()

func cancel() -> void:
	if _active:
		_end()

func _end() -> void:
	var ended_id: String = _current_id
	_active = false
	_current_id = ""
	_current_lines.clear()
	# Restore previous state instead of forcing EXPLORE_VILLAGE
	if _previous_state != "" and _previous_state != "DIALOGUE_ACTIVE":
		GameState.set_state(_previous_state)
	else:
		GameState.set_state("EXPLORE_VILLAGE")
	dialogue_ended.emit(ended_id)
	if _queue.size() > 0:
		var next_id: String = _queue.pop_front()
		_start(next_id)

func is_active() -> bool:
	return _active
