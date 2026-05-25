extends Node
##
## SceneLoader — chuyển scene có fade transition.
## GDD §C.3, IMPLEMENTATION_PLAN T1.6
##

signal scene_changed(old_path: String, new_path: String)
signal fade_in_complete()
signal fade_out_complete()

var _overlay: ColorRect = null
var _is_transitioning: bool = false

func _ready() -> void:
	print("[SceneLoader] ready")
	call_deferred("_setup_overlay")

func _setup_overlay() -> void:
	# Create persistent fade overlay above all scenes
	var canvas := CanvasLayer.new()
	canvas.layer = 128
	canvas.name = "FadeOverlay"
	get_tree().root.add_child(canvas)

	_overlay = ColorRect.new()
	_overlay.color = Color(0, 0, 0, 0)
	_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.add_child(_overlay)

func fade_to(scene_path: String, duration: float = 0.5) -> void:
	if _is_transitioning:
		return
	_is_transitioning = true

	var old_path: String = ""
	if get_tree().current_scene != null:
		old_path = get_tree().current_scene.scene_file_path

	# Fade out
	if _overlay != null:
		var t := create_tween()
		t.tween_property(_overlay, "color:a", 1.0, duration)
		await t.finished
	fade_out_complete.emit()

	# Switch scene
	var err := get_tree().change_scene_to_file(scene_path)
	if err != OK:
		push_error("SceneLoader: failed to load %s (err=%d)" % [scene_path, err])
		_is_transitioning = false
		return
	await get_tree().process_frame

	# Fade in
	if _overlay != null:
		var t2 := create_tween()
		t2.tween_property(_overlay, "color:a", 0.0, duration)
		await t2.finished
	fade_in_complete.emit()

	scene_changed.emit(old_path, scene_path)
	_is_transitioning = false

func reload_current() -> void:
	get_tree().reload_current_scene()

func get_current_scene_path() -> String:
	if get_tree().current_scene != null:
		return get_tree().current_scene.scene_file_path
	return ""
