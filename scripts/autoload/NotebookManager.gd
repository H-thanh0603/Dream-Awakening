extends Node
##
## NotebookManager — quản lý Sổ Mộng.
## Contract: GDD §C.5
## Phase 0: skeleton. Phase 2 T2.2 implement đầy đủ.
##

signal entry_added(category: String, entry_id: String)
signal objective_changed(new_text: String)

const CATEGORIES := ["OBJECTIVE", "SYMBOL", "MEMORY", "NPC_STATE", "HINT"]

var _entries: Dictionary = {}
var _objective: String = ""

func _ready() -> void:
	for c in CATEGORIES:
		_entries[c] = {}
	print("[NotebookManager] ready")

func add_entry(category: String, entry_id: String, data: Dictionary) -> void:
	if not category in CATEGORIES:
		push_error("Unknown category: " + category)
		return
	_entries[category][entry_id] = data
	entry_added.emit(category, entry_id)

func has_entry(category: String, entry_id: String) -> bool:
	return _entries.get(category, {}).has(entry_id)

func get_entries(category: String) -> Dictionary:
	return _entries.get(category, {}).duplicate(true)

func set_objective(text: String) -> void:
	_objective = text
	objective_changed.emit(text)

func get_objective() -> String:
	return _objective
