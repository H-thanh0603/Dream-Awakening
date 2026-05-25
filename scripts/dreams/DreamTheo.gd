extends Node2D
##
## DreamTheo — Lớp học vô tận. 3 puzzle: xoá dấu bằng → tìm bài thật → mở cửa sổ.
## Ritual: gấp máy bay giấy thả ra cửa sổ.
##

@onready var step_label: Label = $HintHUD/StepBox/StepLabel
@onready var window_locked: Sprite2D = $WindowArea/WindowLocked
@onready var window_open: Sprite2D = $WindowArea/WindowOpen
@onready var ritual_door: Area2D = $RitualDoor

var papers_collected: int = 0
var locks_opened: int = 0

func _ready() -> void:
	GameState.set_state("DREAM_EXPLORE")
	GameState.current_dream_id = "theo"
	NotebookManager.set_objective("Tìm cục tẩy. Xoá dấu bằng trên bảng đen.")
	_set_step("B1: Tìm cục tẩy → xoá dấu = trên bảng")
	# Wire
	$EraserPickup.interacted.connect(_on_eraser_picked)
	$Blackboard.item_placed.connect(_on_eraser_placed)
	for p in $PapersArea/Papers.get_children():
		p.interacted.connect(_on_paper_picked.bind(p))
	for lock in $WindowArea/Locks.get_children():
		lock.item_placed.connect(_on_lock_unlocked.bind(lock))
	$RitualPlanePickup.interacted.connect(_on_plane_picked)
	$WindowArea/RitualSpot.item_placed.connect(_on_plane_thrown)
	ritual_door.interacted.connect(_on_ritual_door)
	window_open.visible = false
	ritual_door.enabled = false
	await get_tree().create_timer(0.5).timeout

func _set_step(text: String) -> void:
	if step_label:
		step_label.text = text

func _on_eraser_picked(_by) -> void:
	_set_step("Đến bảng đen → đặt cục tẩy")

func _on_eraser_placed(_item_id: String) -> void:
	GameState.set_flag("theo_eraser_done", true)
	DialogueManager.play("theo_eraser_done")
	NotebookManager.set_objective("Tìm bài kiểm tra thật của Theo.")
	_set_step("B2: Tìm bài có hình con mèo ở góc")
	for p in $PapersArea/Papers.get_children():
		if "enabled" in p:
			p.enabled = true

func _on_paper_picked(_by, paper) -> void:
	var pid: String = paper.item_id if "item_id" in paper else ""
	if pid == "theo_real_paper":
		GameState.set_flag("theo_real_paper_found", true)
		DialogueManager.play("theo_paper_found")
		NotebookManager.set_objective("Mở 3 ổ khoá trên cửa sổ.")
		_set_step("B3: Đặt ký ức vào 3 ổ khoá cửa sổ")
		# Spawn 3 memory pickups for the locks
		$WindowArea/MemCourage.enabled = true
		$WindowArea/MemEffort.enabled = true
		$WindowArea/MemAccept.enabled = true
	else:
		NotebookManager.set_objective("Đó không phải bài của Theo. Tìm bài có hình vẽ.")

func _on_lock_unlocked(_item_id: String, _lock) -> void:
	locks_opened += 1
	if locks_opened >= 3:
		GameState.set_flag("theo_window_open", true)
		window_locked.visible = false
		window_open.visible = true
		DialogueManager.play("theo_window_open")
		NotebookManager.set_objective("Gom các tờ điểm đỏ. Gấp máy bay. Thả qua cửa sổ.")
		_set_step("B4: Lấy máy bay giấy → đặt ở cửa sổ")
		$RitualPlanePickup.enabled = true

var _ritual_active: bool = false

func _on_plane_picked(_by) -> void:
	_set_step("Đến cửa sổ → thả máy bay giấy")

func _on_plane_thrown(_item_id: String) -> void:
	if _ritual_active:
		return
	_ritual_active = true
	GameState.set_state("RITUAL_READY")
	DialogueManager.play("theo_ritual")
	DialogueManager.dialogue_ended.connect(_on_ritual_done, CONNECT_ONE_SHOT)

func _on_ritual_done(dialogue_id: String) -> void:
	if dialogue_id != "theo_ritual":
		return
	ritual_door.enabled = true
	_set_step("Bước qua cửa tỉnh mộng")
	GameState.set_state("WAKE_UP")

func _on_ritual_door(_by) -> void:
	if not GameState.has_flag("theo_realized"):
		return
	DreamStateManager.set_npc_state("theo", "AWAKE_CHANGED")
	GameState.set_state("EXPLORE_VILLAGE")
	SceneLoader.fade_to("res://scenes/world/Village.tscn", 1.5)
