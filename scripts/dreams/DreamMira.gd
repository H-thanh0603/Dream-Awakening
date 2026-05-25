## DEPRECATED — OBSOLETE
## This script is no longer attached to any scene.
## Mira's actual controller is MiraLevel.gd (used by Dream_Mira_MirrorRoom.tscn).
## Kept only as reference; safe to delete.
##
extends Node2D
##
## DreamMira — main controller for the 4-room redesign.
## Rooms 1..4 in same world; camera follows player.
## Lucidity collapse → restore at last save point.
##

@onready var step_label: Label = $HintHUD/StepBox/StepLabel
@onready var memory_label: Label = $HintHUD/MemoryBox/MemoryLabel
@onready var camera: Camera2D = $Player/Camera2D
@onready var player: CharacterBody2D = $Player

var _last_save_pos: Vector2 = Vector2(60, 200)
var _memory_count: int = 0
const TOTAL_MEMORIES: int = 4

# Door references (door blocks set in _ready by name)
var _door_r1_r2: Node2D
var _door_r2_r3: Node2D
var _door_r3_r4: Node2D

func _ready() -> void:
	GameState.set_state("DREAM_EXPLORE")
	GameState.current_dream_id = "mira"
	LucidityManager.enable()
	LucidityManager.collapsed.connect(_on_collapsed)
	NotebookManager.set_objective("Sống sót khỏi giấc mơ của Mira.")
	_set_step("R1: Đẩy 2 hộp lên 2 nút sáng cùng lúc")

	# Camera limits will be set by _update_camera_for_room()
	player.position = Vector2(60, 200)
	_last_save_pos = player.position
	_update_camera_for_room()

	# Wire save points
	for sp in get_tree().get_nodes_in_group("mira_savepoint"):
		if sp.has_signal("activated"):
			sp.activated.connect(_on_save_activated)

	# Wire pressure plates of room 1
	var plate_a: Area2D = $Room1/PlateA
	var plate_b: Area2D = $Room1/PlateB
	plate_a.pressed.connect(_check_room1_solved)
	plate_a.released.connect(_check_room1_solved)
	plate_b.pressed.connect(_check_room1_solved)
	plate_b.released.connect(_check_room1_solved)

	# Doors
	_door_r1_r2 = $Doors/DoorR1R2
	_door_r2_r3 = $Doors/DoorR2R3
	_door_r3_r4 = $Doors/DoorR3R4

	# Memories (room 2) wired
	for mem in $Room2/Memories.get_children():
		if mem.has_signal("interacted"):
			mem.interacted.connect(_on_memory_picked.bind(mem))

	# Essences (room 3) order check
	$Room3/WaterSlot.item_placed.connect(_on_essence_placed.bind("water"))
	$Room3/LightSlot.item_placed.connect(_on_essence_placed.bind("light"))
	$Room3/MemorySlot.item_placed.connect(_on_essence_placed.bind("memory_essence"))

	# Boss (room 4) — wired by sub-script BossMask.gd

	# Reset memory label
	_update_memory_label()

	await get_tree().create_timer(0.6).timeout
	DialogueManager.play("mira_intro_dream") if DialogueManager._dialogues.has("mira_intro_dream") else null

func _set_step(t: String) -> void:
	if step_label:
		step_label.text = t

func _update_memory_label() -> void:
	if memory_label:
		memory_label.text = "Ký ức: %d/4" % _memory_count

func _process(_delta: float) -> void:
	_update_camera_for_room()

func _update_camera_for_room() -> void:
	# Snap camera limits to whichever quadrant the player is in
	var p: Vector2 = player.position
	var qx: int = 0 if p.x < 480 else 1
	var qy: int = 0 if p.y < 270 else 1
	camera.limit_left = qx * 480
	camera.limit_top = qy * 270
	camera.limit_right = (qx + 1) * 480
	camera.limit_bottom = (qy + 1) * 270

func _on_save_activated(point) -> void:
	_last_save_pos = point.global_position
	NotebookManager.add_entry("HINT", "save_%s" % point.point_id, {"title_vi": "Đã ghi nhớ vị trí"})

func _on_collapsed() -> void:
	# Mira fell unconscious. Reset to save.
	DialogueManager.register_from_dict({
		"id": "mira_collapse_%d" % Engine.get_process_frames(),
		"lines": [{"speaker": "Mira", "text": "...em ngã rồi. Anh giúp em đứng dậy được không?"}]
	})
	player.position = _last_save_pos
	LucidityManager.lucidity = 60.0
	LucidityManager._drain_sources = 0
	LucidityManager.lucidity_changed.emit(60.0)

# === ROOM 1: Mirror Hallway ===

var _room1_solved: bool = false

func _check_room1_solved(_by = null) -> void:
	if _room1_solved:
		return
	var plate_a: Area2D = $Room1/PlateA
	var plate_b: Area2D = $Room1/PlateB
	if plate_a.is_pressed() and plate_b.is_pressed():
		_room1_solved = true
		_open_door(_door_r1_r2)
		GameState.set_flag("mira_room1_solved", true)
		NotebookManager.set_objective("Cửa phía đông đã mở. Đến phòng ký ức.")
		_set_step("Đến phòng ký ức (đông)")

# === ROOM 2: Memories ===

func _on_memory_picked(_by, mem) -> void:
	var mid: String = mem.item_id if "item_id" in mem else ""
	if mid == "":
		return
	_memory_count += 1
	LucidityManager.recover(20.0)
	_update_memory_label()
	if _memory_count >= TOTAL_MEMORIES:
		GameState.set_flag("mira_room2_solved", true)
		_open_door(_door_r2_r3)
		NotebookManager.set_objective("Cửa phía nam đã mở. Đến vườn gương.")
		_set_step("Đến vườn gương (nam) — chú ý thứ tự đặt!")
		DialogueManager.play("mira_memories_done") if DialogueManager._dialogues.has("mira_memories_done") else null

# === ROOM 3: Mirror Garden — order matters: water → light → memory ===

var _essence_order: Array[String] = []

func _on_essence_placed(_item_id: String, slot_kind: String) -> void:
	_essence_order.append(slot_kind)
	var correct := ["water", "light", "memory_essence"]
	var idx: int = _essence_order.size() - 1
	if _essence_order[idx] != correct[idx]:
		# WRONG ORDER — reset
		DialogueManager.register_from_dict({
			"id": "mira_order_wrong",
			"lines": [{"speaker": "???", "text": "Sai thứ tự. Hoa khô lại. Hãy đọc lại lời nhắn ở phòng đầu."}]
		})
		DialogueManager.play("mira_order_wrong")
		_essence_order.clear()
		LucidityManager.damage(10.0)
		# Re-enable all 3 slots and clear placed state
		for slot_name in ["WaterSlot", "LightSlot", "MemorySlot"]:
			var slot: Node = $Room3.get_node(slot_name)
			slot.enabled = true
			if "placed_item" in slot:
				slot.placed_item = ""
			var visual: ColorRect = slot.get_node_or_null("Visual")
			if visual:
				visual.color = Color(0.5, 0.45, 0.5, 1)
		# Re-enable all essence pickups (consumed_on_pickup=false → still in scene)
		for pickup_name in ["WaterPickup", "LightPickup", "MemoryPickup"]:
			var pk: Node = $Room3.get_node(pickup_name)
			pk.visible = true
			pk.enabled = true
		# Drop any essence still in inventory
		for it in ["water", "light", "memory_essence"]:
			if InventoryManager.has_item(it):
				InventoryManager.remove_item(it)
		return
	if _essence_order.size() >= 3:
		# Correct order!
		$Room3/FlowerWilted.visible = false
		$Room3/FlowerBloomed.visible = true
		GameState.set_flag("mira_room3_solved", true)
		_open_door(_door_r3_r4)
		DialogueManager.play("mira_flower_done") if DialogueManager._dialogues.has("mira_flower_done") else null
		NotebookManager.set_objective("Cửa phía đông đã mở. Đối diện chính mình.")
		_set_step("Boss: Bắt Mặt Nạ 4 lần ở 4 ô neo")

func _open_door(door: Node2D) -> void:
	if door == null:
		return
	door.visible = false
	var coll: CollisionShape2D = door.get_node_or_null("Shape")
	if coll:
		coll.set_deferred("disabled", true)

# === ROOM 4: Boss — Mira realized ===

func on_boss_defeated() -> void:
	GameState.set_flag("mira_realized", true)
	DialogueManager.play("mira_ritual") if DialogueManager._dialogues.has("mira_ritual") else null
	await get_tree().create_timer(0.5).timeout
	# Wait for ritual dialogue end
	if DialogueManager._active:
		await DialogueManager.dialogue_ended
	DreamStateManager.set_npc_state("mira", "AWAKE_CHANGED")
	LucidityManager.disable()
	GameState.set_state("EXPLORE_VILLAGE")
	SceneLoader.fade_to("res://scenes/world/Village.tscn", 1.5)
