extends Control
##
## MainMenu — title screen với 3 nút Bắt đầu / Tiếp tục / Thoát.
## Phase 0 placeholder: Start/Continue chỉ in log, Phase 1 sẽ load Village.
##

func _ready() -> void:
	print("[MainMenu] ready")
	# Disable Continue nếu chưa có save
	var continue_btn := $VBoxContainer/ContinueButton
	if continue_btn != null:
		continue_btn.disabled = not SaveManager.has_save()

func _on_start_pressed() -> void:
	print("[MainMenu] Start pressed — Phase 1 sẽ load Village")
	# Phase 1 T1.9: SceneLoader.fade_to("res://scenes/world/Village.tscn")

func _on_continue_pressed() -> void:
	print("[MainMenu] Continue pressed — Phase 2 T2.11 sẽ load save")
	# Phase 2: SaveManager.load_game(), restore scene

func _on_quit_pressed() -> void:
	print("[MainMenu] Quit pressed")
	get_tree().quit()
