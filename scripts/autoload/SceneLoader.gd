extends Node
##
## SceneLoader — chuyển scene có fade transition.
## Contract: GDD §C.3
## Phase 0: skeleton chỉ change_scene_to_file, fade sẽ làm ở Phase 1 (T1.6).
##

signal scene_changed(old_path: String, new_path: String)

func _ready() -> void:
	print("[SceneLoader] ready")

func fade_to(scene_path: String, duration: float = 0.5) -> void:
	# Phase 0 placeholder: chuyển scene ngay không fade.
	# Phase 1 T1.6 sẽ implement fade overlay đầy đủ.
	var old: String = ""
	if get_tree().current_scene != null:
		old = get_tree().current_scene.scene_file_path
	get_tree().change_scene_to_file(scene_path)
	await get_tree().process_frame
	scene_changed.emit(old, scene_path)

func reload_current() -> void:
	get_tree().reload_current_scene()

func get_current_scene_path() -> String:
	if get_tree().current_scene != null:
		return get_tree().current_scene.scene_file_path
	return ""
