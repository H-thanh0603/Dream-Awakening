extends Node
##
## GameState — Single source of truth cho flag, state, current case.
## Chi tiết contract: GDD §C.2
##

signal flag_changed(flag_name: String, value: bool)
signal state_changed(old_state: String, new_state: String)
signal case_changed(old_case: String, new_case: String)

const STATES := [
	"EXPLORE_VILLAGE", "ENTER_DREAM", "DREAM_EXPLORE",
	"PUZZLE_SOLVING", "MEMORY_REFLECTION", "RITUAL_READY",
	"WAKE_UP", "DIALOGUE_ACTIVE", "PAUSED"
]

var flags: Dictionary = {}
var current_state: String = "EXPLORE_VILLAGE"
var current_case: String = ""
var current_dream_id: String = ""

func _ready() -> void:
	print("[GameState] ready")

# === Flag API ===

func set_flag(name: String, value: bool = true) -> void:
	var old: bool = flags.get(name, false)
	flags[name] = value
	if old != value:
		flag_changed.emit(name, value)

func get_flag(name: String) -> bool:
	return flags.get(name, false)

func has_flag(name: String) -> bool:
	return flags.has(name) and flags[name]

func has_all_flags(names: Array) -> bool:
	for n in names:
		if not has_flag(n):
			return false
	return true

func has_any_flag(names: Array) -> bool:
	for n in names:
		if has_flag(n):
			return true
	return false

func clear_flag(name: String) -> void:
	if flags.has(name):
		flags.erase(name)
		flag_changed.emit(name, false)

# === State machine ===

func set_state(new_state: String) -> void:
	assert(new_state in STATES, "Unknown state: " + new_state)
	if current_state == new_state:
		return
	var old: String = current_state
	current_state = new_state
	state_changed.emit(old, new_state)

func set_case(new_case: String) -> void:
	if current_case == new_case:
		return
	var old: String = current_case
	current_case = new_case
	case_changed.emit(old, new_case)

# === Boolean expression evaluator (for dialogue.condition) ===
# Supports: "flag_a", "!flag_a", "a && b", "a || b" (flat, no parens)

func evaluate(expr: String) -> bool:
	if expr == null or expr.strip_edges() == "":
		return true
	expr = expr.strip_edges()
	if "||" in expr:
		for part in expr.split("||"):
			if evaluate(part.strip_edges()):
				return true
		return false
	if "&&" in expr:
		for part in expr.split("&&"):
			if not evaluate(part.strip_edges()):
				return false
		return true
	if expr.begins_with("!"):
		return not has_flag(expr.substr(1).strip_edges())
	return has_flag(expr)
