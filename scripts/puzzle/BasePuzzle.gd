class_name BasePuzzle extends Node
##
## BasePuzzle — abstract class cho 5 loại puzzle.
## GDD §C.8, IMPLEMENTATION_PLAN T2.4
##

signal puzzle_started(puzzle_id: String)
signal puzzle_completed(puzzle_id: String)
signal puzzle_failed(puzzle_id: String, reason: String)

@export var puzzle_id: String = ""
@export var auto_start: bool = true

var _data: Dictionary = {}
var _started: bool = false
var _completed: bool = false

func _ready() -> void:
	if puzzle_id == "":
		push_error("BasePuzzle: puzzle_id chưa set")
		return
	_data = JsonLoader.load_file("res://data/puzzles/%s.json" % puzzle_id)
	if _data.is_empty():
		push_error("Puzzle data not found: " + puzzle_id)
		return
	if auto_start and can_start():
		start()
	else:
		# Wait for required flags
		GameState.flag_changed.connect(_on_flag_changed)

func _on_flag_changed(_name: String, _val: bool) -> void:
	if not _started and can_start():
		start()

func can_start() -> bool:
	var req: Array = _data.get("required_flags", [])
	return GameState.has_all_flags(req)

func start() -> void:
	if _started:
		return
	_started = true
	puzzle_started.emit(puzzle_id)
	_on_start()

# Subclass override
func _on_start() -> void: pass
func check_solution() -> bool:
	push_error("check_solution() must be overridden")
	return false

func complete() -> void:
	if _completed:
		return
	_completed = true
	for f in _data.get("reward_flags", []):
		GameState.set_flag(str(f), true)
	var dial: String = _data.get("on_complete_dialogue", "")
	if dial != "":
		DialogueManager.play(dial)
	var sfx: String = _data.get("on_complete_sfx", "puzzle_solved")
	AudioManager.play_sfx(sfx)
	puzzle_completed.emit(puzzle_id)
