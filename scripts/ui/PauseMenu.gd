extends CanvasLayer
##
## PauseMenu — Esc để pause/resume.
## GDD §6, IMPLEMENTATION_PLAN T1.10
##

func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		toggle()

func toggle() -> void:
	visible = not visible
	get_tree().paused = visible
	if visible:
		GameState.set_state("PAUSED")
	else:
		GameState.set_state("EXPLORE_VILLAGE")
	get_viewport().set_input_as_handled()

func _on_resume_pressed() -> void:
	toggle()

func _on_save_pressed() -> void:
	# Phase 2: SaveManager.save_game()
	print("[PauseMenu] Save pressed (Phase 2 T2.11)")

func _on_quit_pressed() -> void:
	get_tree().quit()
