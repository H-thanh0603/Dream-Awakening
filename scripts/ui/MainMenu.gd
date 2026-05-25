extends Control
##
## MainMenu — title screen với 3 nút Bắt đầu / Tiếp tục / Thoát.
##

func _ready() -> void:
	print("[MainMenu] ready")
	var continue_btn := $VBoxContainer/ContinueButton
	if continue_btn != null:
		continue_btn.disabled = not SaveManager.has_save()

func _on_start_pressed() -> void:
	print("[MainMenu] Start pressed → Tutorial")
	# Reset save and start fresh tutorial
	GameState.flags.clear()
	GameState.set_state("DREAM_EXPLORE")
	SceneLoader.fade_to("res://scenes/dreams/Dream_Tutorial.tscn", 0.6)

func _on_continue_pressed() -> void:
	print("[MainMenu] Continue pressed → load save")
	if SaveManager.load_game():
		# Determine where to go based on saved state
		var case_id: String = GameState.current_case
		if GameState.has_flag("tutorial_completed"):
			SceneLoader.fade_to("res://scenes/world/Village.tscn", 0.6)
		else:
			SceneLoader.fade_to("res://scenes/dreams/Dream_Tutorial.tscn", 0.6)

func _on_quit_pressed() -> void:
	print("[MainMenu] Quit pressed")
	get_tree().quit()
