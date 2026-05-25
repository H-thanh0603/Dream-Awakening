extends Node
##
## SaveManager — save/load tiến trình.
## Contract: GDD §C.9
## Phase 0: skeleton. Phase 2 T2.11 implement đầy đủ.
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
	push_warning("SaveManager.save_game() chưa implement (Phase 2 T2.11)")
	return false

func load_game() -> bool:
	push_warning("SaveManager.load_game() chưa implement (Phase 2 T2.11)")
	return false

func delete_save() -> void:
	if has_save():
		DirAccess.remove_absolute(SAVE_PATH)
