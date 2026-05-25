extends Node2D
##
## DreamTutorial — màn mở đầu dạy player cơ bản.
## GDD §10, IMPLEMENTATION_PLAN T2.13
##

func _ready() -> void:
	GameState.set_state("DREAM_EXPLORE")
	NotebookManager.set_objective("Bật đèn để tìm manh mối.")
	# Wire interactions
	$Lamp.interacted.connect(_on_lamp)
	$Door.interacted.connect(_on_door)
	# Start dialogue intro
	await get_tree().create_timer(0.5).timeout
	DialogueManager.play("tutorial_intro")

func _on_lamp(_by) -> void:
	if GameState.has_flag("tutorial_lamp_on"):
		return
	GameState.set_flag("tutorial_lamp_on", true)
	$Lamp/Visual.color = Color(1, 0.9, 0.5, 1)
	$Background.color = Color(0.12, 0.1, 0.15, 1)
	$PaperClue.enabled = true
	$Lamp.enabled = false
	NotebookManager.set_objective("Nhặt mảnh giấy gần đèn.")
	NotebookManager.add_entry("SYMBOL", "lamp", {
		"title_vi": "Đèn cũ",
		"description_vi": "Khi đèn sáng, mọi thứ rõ ràng hơn."
	})

# After tutorial_completed flag set → enable door
func _process(_delta: float) -> void:
	if GameState.has_flag("tutorial_completed") and not $Door.enabled:
		$Door.enabled = true
		NotebookManager.set_objective("Bước qua cửa để tỉnh dậy.")
		NotebookManager.add_entry("MEMORY", "tutorial_clue", {
			"title_vi": "Mảnh giấy đầu tiên",
			"description_vi": "Ký ức không mất, chỉ bị đặt sai chỗ."
		})

func _on_door(_by) -> void:
	if not GameState.has_flag("tutorial_completed"):
		return
	GameState.set_state("EXPLORE_VILLAGE")
	SceneLoader.fade_to("res://scenes/world/Village.tscn", 1.0)
