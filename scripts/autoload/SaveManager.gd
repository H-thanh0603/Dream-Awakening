extends Node
##
## SaveManager — save/load tiến trình ra user://save.json
## GDD §C.9, IMPLEMENTATION_PLAN T2.11
##

const SAVE_PATH := "user://save.json"
const CURRENT_VERSION := 1

signal save_completed()
signal load_completed()

func _ready() -> void:
	print("[SaveManager] ready")

func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)

func save_game() -> bool:
	var data: Dictionary = {
		"version": CURRENT_VERSION,
		"saved_at_iso": Time.get_datetime_string_from_system(true),
		"current_state": GameState.current_state,
		"current_case": GameState.current_case,
		"current_dream_id": GameState.current_dream_id,
		"flags": GameState.flags.duplicate(),
		"inventory": InventoryManager.get_all_items(),
		"active_item": InventoryManager.get_active_item(),
		"notebook_objective": NotebookManager.get_objective(),
		"notebook_entries": _serialize_notebook(),
		"npc_states": _serialize_npc_states()
	}
	var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if f == null:
		push_error("Cannot open save file for writing")
		return false
	f.store_string(JSON.stringify(data, "	"))
	f.close()
	print("[SaveManager] saved at " + SAVE_PATH)
	save_completed.emit()
	return true

func load_game() -> bool:
	if not has_save():
		return false
	var f := FileAccess.open(SAVE_PATH, FileAccess.READ)
	var raw: String = f.get_as_text()
	f.close()
	var data = JSON.parse_string(raw)
	if data == null or not data is Dictionary:
		push_error("Save file corrupt")
		return false
	data = _migrate(data)
	# Restore GameState
	GameState.flags = data.get("flags", {}).duplicate()
	GameState.set_case(str(data.get("current_case", "")))
	GameState.current_dream_id = str(data.get("current_dream_id", ""))
	# Restore inventory
	for item in data.get("inventory", []):
		InventoryManager.add_item(str(item))
	var active: String = str(data.get("active_item", ""))
	if active != "":
		InventoryManager.set_active_item(active)
	# Restore notebook objective
	NotebookManager.set_objective(str(data.get("notebook_objective", "")))
	# Restore notebook entries
	var entries_dict: Dictionary = data.get("notebook_entries", {})
	for cat in entries_dict:
		for entry_id in entries_dict[cat]:
			NotebookManager.add_entry(str(cat), str(entry_id), {"title_vi": str(entry_id)})
	# Restore NPC states
	var npc_states: Dictionary = data.get("npc_states", {})
	for nid in npc_states:
		DreamStateManager.set_npc_state(str(nid), str(npc_states[nid]))
	load_completed.emit()
	print("[SaveManager] loaded successfully")
	return true

func delete_save() -> void:
	if has_save():
		DirAccess.remove_absolute(SAVE_PATH)

func _migrate(data: Dictionary) -> Dictionary:
	var v: int = int(data.get("version", 0))
	if v < CURRENT_VERSION:
		# v0 -> v1: ensure all fields present
		data["version"] = CURRENT_VERSION
		if not data.has("npc_states"):
			data["npc_states"] = {}
	return data

func _serialize_notebook() -> Dictionary:
	var out: Dictionary = {}
	for cat in NotebookManager.CATEGORIES:
		out[cat] = NotebookManager.get_entries(cat).keys()
	return out

func _serialize_npc_states() -> Dictionary:
	var out: Dictionary = {}
	for nid in DreamStateManager._states:
		out[nid] = DreamStateManager._states[nid]
	return out
