extends Node2D
##
## DreamRell — Xưởng đồng hồ. 3 puzzle: lắp bánh răng → tìm thư → chọn cửa.
##

@onready var step_label: Label = $HintHUD/StepBox/StepLabel
@onready var clock_broken: Sprite2D = $CenterClock/Broken
@onready var clock_fixed: Sprite2D = $CenterClock/Fixed
@onready var lamp_unlit: Sprite2D = $ForwardDoor/LampUnlit
@onready var lamp_lit: Sprite2D = $ForwardDoor/LampLit
@onready var door_forward_locked: Sprite2D = $ForwardDoor/DoorLocked
@onready var door_forward_open: Sprite2D = $ForwardDoor/DoorOpen
@onready var ritual_door: Area2D = $ForwardDoor

var gears_placed: int = 0

func _ready() -> void:
	GameState.set_state("DREAM_EXPLORE")
	GameState.current_dream_id = "rell"
	NotebookManager.set_objective("Lắp 3 bánh răng vào đồng hồ lớn.")
	_set_step("B1: Tìm 3 bánh răng → lắp vào đồng hồ")
	for g in $GearsArea/Gears.get_children():
		g.interacted.connect(_on_gear_picked.bind(g))
	for s in $CenterClock/Slots.get_children():
		s.item_placed.connect(_on_gear_placed)
	$LetterArea/Letter.interacted.connect(_on_letter_picked)
	$ForwardDoor.interacted.connect(_on_forward_door)
	$PastDoor.interacted.connect(_on_past_door)
	$LampPickup.interacted.connect(_on_lamp_picked)
	$ForwardDoor/LampSlot.item_placed.connect(_on_lamp_placed)
	$RitualHandPickup.interacted.connect(_on_hand_picked)
	$CenterClock/HandSlot.item_placed.connect(_on_hand_placed)
	clock_fixed.visible = false
	lamp_lit.visible = false
	door_forward_open.visible = false
	ritual_door.enabled = false
	$LetterArea/Letter.enabled = false
	await get_tree().create_timer(0.5).timeout

func _set_step(text: String) -> void:
	if step_label:
		step_label.text = text

func _on_gear_picked(_by, _gear) -> void:
	_set_step("Lắp bánh răng vào đồng hồ")

func _on_gear_placed(_item_id: String) -> void:
	gears_placed += 1
	if gears_placed >= 3:
		GameState.set_flag("rell_gears_done", true)
		clock_broken.visible = false
		clock_fixed.visible = true
		DialogueManager.play("rell_gears_done")
		$LetterArea/Letter.enabled = true
		NotebookManager.set_objective("Tìm lá thư cũ trong xưởng.")
		_set_step("B2: Tìm lá thư cũ")

func _on_letter_picked(_by) -> void:
	GameState.set_flag("rell_letter_found", true)
	DialogueManager.play("rell_letter_found")
	NotebookManager.set_objective("Có hai cửa. Suy nghĩ kỹ trước khi mở.")
	_set_step("B3: Đến hai cửa - chọn cửa phía trước")
	$LampPickup.enabled = true

func _on_past_door(_by) -> void:
	DialogueManager.play("rell_two_doors")
	NotebookManager.set_objective("Cửa quá khứ chỉ giữ Rell lại. Thắp đèn ở cửa phía trước.")

func _on_lamp_picked(_by) -> void:
	_set_step("Đặt đèn ở cửa phía trước")

func _on_lamp_placed(_item_id: String) -> void:
	lamp_unlit.visible = false
	lamp_lit.visible = true
	GameState.set_flag("rell_lamp_lit", true)
	$RitualHandPickup.enabled = true
	NotebookManager.set_objective("Lắp kim đồng hồ và bước qua cửa phía trước.")
	_set_step("B4: Lắp kim đồng hồ vào đồng hồ lớn")

func _on_hand_picked(_by) -> void:
	_set_step("Đến đồng hồ lớn - lắp kim phút")

var _ritual_active: bool = false

func _on_hand_placed(_item_id: String) -> void:
	if _ritual_active:
		return
	_ritual_active = true
	GameState.set_state("RITUAL_READY")
	door_forward_locked.visible = false
	door_forward_open.visible = true
	DialogueManager.play("rell_ritual")
	DialogueManager.dialogue_ended.connect(_on_ritual_done, CONNECT_ONE_SHOT)

func _on_ritual_done(dialogue_id: String) -> void:
	if dialogue_id != "rell_ritual":
		return
	ritual_door.enabled = true
	_set_step("Bước qua cửa phía trước")
	GameState.set_state("WAKE_UP")

func _on_forward_door(_by) -> void:
	if not GameState.has_flag("rell_realized"):
		return
	DreamStateManager.set_npc_state("rell", "AWAKE_CHANGED")
	GameState.set_state("EXPLORE_VILLAGE")
	SceneLoader.fade_to("res://scenes/world/Village.tscn", 1.5)
