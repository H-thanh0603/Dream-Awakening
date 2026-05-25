extends Node2D
##
## DreamTutorial — màn mở đầu dạy player cơ bản.
## GDD §10, IMPLEMENTATION_PLAN T2.13
##

@onready var step_label: Label = $HintHUD/StepBox/StepLabel
@onready var lamp_sprite: Sprite2D = $Lamp/Sprite
@onready var frame_sprite: Sprite2D = $EmptyFrame/Sprite
@onready var door_sprite: Sprite2D = $Door/Sprite

var lamp_on_tex: Texture2D = preload("res://assets/sprites/items/lamp_on.png")
var frame_filled_tex: Texture2D = preload("res://assets/sprites/items/mirror_filled.png")
var door_open_tex: Texture2D = preload("res://assets/sprites/items/door_open.png")

func _ready() -> void:
	GameState.set_state("DREAM_EXPLORE")
	NotebookManager.set_objective("Bật đèn để tìm manh mối.")
	# Wire interactions
	$Lamp.interacted.connect(_on_lamp)
	$Door.interacted.connect(_on_door)
	$PaperClue.interacted.connect(_on_paper_picked)
	$EmptyFrame.item_placed.connect(_on_paper_placed)
	$Puzzle.puzzle_completed.connect(_on_puzzle_completed)
	_set_step("B1: Đến gần Đèn rồi nhấn E")
	await get_tree().create_timer(0.5).timeout
	DialogueManager.play("tutorial_intro")

func _set_step(text: String) -> void:
	if step_label:
		step_label.text = text

func _on_lamp(_by) -> void:
	if GameState.has_flag("tutorial_lamp_on"):
		return
	GameState.set_flag("tutorial_lamp_on", true)
	if lamp_sprite:
		lamp_sprite.texture = lamp_on_tex
	$Background.color = Color(0.16, 0.13, 0.22, 1)
	$PaperClue.enabled = true
	$Lamp.enabled = false
	NotebookManager.set_objective("Nhặt mảnh giấy gần đèn.")
	NotebookManager.add_entry("SYMBOL", "lamp", {
		"title_vi": "Đèn cũ",
		"description_vi": "Khi đèn sáng, mọi thứ rõ ràng hơn."
	})
	_set_step("B2: Đến mảnh giấy → nhấn E")

func _on_paper_picked(_by) -> void:
	NotebookManager.set_objective("Đặt mảnh giấy vào khung trống.")
	_set_step("B3: Đến Khung trống → nhấn E")

func _on_paper_placed(_item_id: String) -> void:
	if frame_sprite:
		frame_sprite.texture = frame_filled_tex
	_set_step("B4: Đợi cửa mở...")

func _on_puzzle_completed(_pid: String) -> void:
	_set_step("B5: Bước qua cửa")

# After tutorial_completed flag set → enable door
func _process(_delta: float) -> void:
	if GameState.has_flag("tutorial_completed") and not $Door.enabled:
		$Door.enabled = true
		if door_sprite:
			door_sprite.texture = door_open_tex
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
