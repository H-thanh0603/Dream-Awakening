extends Control
##
## MainMenu — title screen với 3 nút Bắt đầu / Tiếp tục / Thoát.
## Phase 1: Start loads Village. Continue chờ Phase 2 SaveManager.
##

func _ready() -> void:
	print("[MainMenu] ready")
	var continue_btn := $VBoxContainer/ContinueButton
	if continue_btn != null:
		continue_btn.disabled = not SaveManager.has_save()

func _on_start_pressed() -> void:
	print("[MainMenu] Start pressed → Village")
	SceneLoader.fade_to("res://scenes/world/Village.tscn", 0.6)

func _on_continue_pressed() -> void:
	print("[MainMenu] Continue pressed — Phase 2 T2.11 sẽ load save")
	if SaveManager.load_game():
		# TODO Phase 2: restore scene
		pass

func _on_quit_pressed() -> void:
	print("[MainMenu] Quit pressed")
	get_tree().quit()
