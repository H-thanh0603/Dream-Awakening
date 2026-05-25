extends Node2D
##
## DreamLina — Phòng không cửa. 3 puzzle: dừng nhạc → xếp khung ảnh → kéo rèm.
## Ritual: trao chìa khoá cho Lina, cô tự mở cửa.
##

@onready var step_label: Label = $HintHUD/StepBox/StepLabel
@onready var box_playing: Sprite2D = $MusicBox/Playing
@onready var box_silent: Sprite2D = $MusicBox/Silent
@onready var curtain_closed: Sprite2D = $WallArea/CurtainClosed
@onready var curtain_open: Sprite2D = $WallArea/CurtainOpen
@onready var door_inner: Sprite2D = $WallArea/DoorInner
@onready var door_open: Sprite2D = $WallArea/DoorOpen
@onready var ritual_door: Area2D = $RitualDoor

var frames_placed: int = 0

func _ready() -> void:
	GameState.set_state("DREAM_EXPLORE")
	GameState.current_dream_id = "lina"
	NotebookManager.set_objective("Tắt hộp nhạc đang phát.")
	_set_step("B1: Đến hộp nhạc → nhấn E để tắt")
	$MusicBox.interacted.connect(_on_box_silenced)
	for f in $FramesArea/Frames.get_children():
		f.interacted.connect(_on_frame_picked.bind(f))
	for s in $FramesArea/Slots.get_children():
		s.item_placed.connect(_on_frame_placed)
	$WallArea/CurtainClosed.set_meta("interactable", true)
	$CurtainPull.interacted.connect(_on_curtain_pulled)
	$KeyPickup.interacted.connect(_on_key_picked)
	$WallArea/DoorInner.set_meta("ritual", true)
	$RitualDoor.interacted.connect(_on_ritual_door_interact)
	box_silent.visible = false
	curtain_open.visible = false
	door_inner.visible = false
	door_open.visible = false
	ritual_door.enabled = false
	$CurtainPull.enabled = false
	$KeyPickup.enabled = false
	await get_tree().create_timer(0.5).timeout

func _set_step(text: String) -> void:
	if step_label:
		step_label.text = text

func _on_box_silenced(_by) -> void:
	GameState.set_flag("lina_box_silenced", true)
	box_playing.visible = false
	box_silent.visible = true
	$MusicBox.enabled = false
	DialogueManager.play("lina_box_silenced")
	NotebookManager.set_objective("Lật và xếp 4 khung ảnh theo thứ tự ký ức.")
	_set_step("B2: Lật 4 khung ảnh, đặt vào 4 vị trí")

func _on_frame_picked(_by, _frame) -> void:
	_set_step("Đặt khung vào vị trí trống trên tường")

func _on_frame_placed(_item_id: String) -> void:
	frames_placed += 1
	if frames_placed >= 4:
		GameState.set_flag("lina_frames_done", true)
		DialogueManager.play("lina_frames_done")
		NotebookManager.set_objective("Kéo rèm cửa sổ. Xem có gì sau đó.")
		_set_step("B3: Đến rèm → nhấn E để kéo")
		$CurtainPull.enabled = true

func _on_curtain_pulled(_by) -> void:
	curtain_closed.visible = false
	curtain_open.visible = true
	door_inner.visible = true
	$CurtainPull.enabled = false
	GameState.set_flag("lina_door_revealed", true)
	DialogueManager.play("lina_door_revealed")
	NotebookManager.set_objective("Tìm chìa khoá. Trao cho Lina.")
	_set_step("B4: Lấy chìa khoá → đến gần Lina")
	$KeyPickup.enabled = true

var _ritual_active: bool = false

func _on_key_picked(_by) -> void:
	_set_step("Đến gần Lina → đặt chìa khoá")

func _on_ritual_door_interact(_by) -> void:
	if _ritual_active:
		if GameState.has_flag("lina_realized"):
			DreamStateManager.set_npc_state("lina", "AWAKE_CHANGED")
			GameState.set_state("EXPLORE_VILLAGE")
			SceneLoader.fade_to("res://scenes/world/Village.tscn", 1.5)
		return
	if not InventoryManager.has_item("lina_key"):
		return
	_ritual_active = true
	GameState.set_state("RITUAL_READY")
	InventoryManager.remove_item("lina_key")
	door_inner.visible = false
	door_open.visible = true
	DialogueManager.play("lina_ritual")
	DialogueManager.dialogue_ended.connect(_on_ritual_done, CONNECT_ONE_SHOT)

func _on_ritual_done(dialogue_id: String) -> void:
	if dialogue_id != "lina_ritual":
		return
	ritual_door.enabled = true
	_set_step("Bước qua cửa Lina vừa mở")
	GameState.set_state("WAKE_UP")
