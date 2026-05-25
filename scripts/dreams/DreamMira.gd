extends Node2D
##
## DreamMira — Màn 1: Phòng gương méo.
## GDD §10.1, IMPLEMENTATION_PLAN T3.1-T3.9
##
## Layout:
##   [Phòng trung tâm] - puzzle hoa
##   [Khu gương vỡ]    - puzzle 1: 3 mảnh gương
##   [Khu tranh ký ức] - puzzle 2: 4 mảnh ký ức
##   [Khu vườn hoa héo]- puzzle 3: làm hoa nở
##   [Gương thật + cửa]- ritual + exit
##

@onready var step_label: Label = $HintHUD/StepBox/StepLabel
@onready var memory_label: Label = $HintHUD/MemoryBox/MemoryLabel
@onready var mirror_warped: Sprite2D = $CenterRoom/MirrorWarped
@onready var mirror_real: Sprite2D = $CenterRoom/MirrorReal
@onready var flower_wilted: Sprite2D = $FlowerArea/FlowerWilted
@onready var flower_bloomed: Sprite2D = $FlowerArea/FlowerBloomed
@onready var ritual_door: Area2D = $RitualDoor
@onready var mira_npc: Area2D = $MiraInDream
@onready var mask: Area2D = $RitualMask
@onready var background: ColorRect = $Background

var memories_collected: Array[String] = []
var ritual_active: bool = false

func _ready() -> void:
	GameState.set_state("DREAM_EXPLORE")
	GameState.current_dream_id = "mira"
	NotebookManager.set_objective("Tìm 3 mảnh gương thật để sửa gương méo.")
	_set_step("Khám phá phòng gương — tìm 3 mảnh gương")
	_update_memory_label()
	# Wire interactions
	for shard in $MirrorArea/Shards.get_children():
		shard.interacted.connect(_on_shard_picked.bind(shard))
	for mem in $MemoryArea/Memories.get_children():
		mem.interacted.connect(_on_memory_picked.bind(mem))
	$CenterRoom/MirrorWarpedSlot.item_placed.connect(_on_shard_placed)
	# Flower puzzle slots
	$FlowerArea/LightSlot.item_placed.connect(_on_essence_placed.bind("light"))
	$FlowerArea/MemorySlot.item_placed.connect(_on_essence_placed.bind("memory_essence"))
	$FlowerArea/WaterSlot.item_placed.connect(_on_essence_placed.bind("water"))
	# Ritual: mask + door
	mask.interacted.connect(_on_mask_interact)
	ritual_door.interacted.connect(_on_ritual_door)
	# Listen for puzzle complete
	GameState.flag_changed.connect(_on_flag_changed)
	# Hide things
	mirror_real.visible = false
	flower_bloomed.visible = false
	ritual_door.enabled = false
	mask.enabled = false
	# Intro narration
	await get_tree().create_timer(0.5).timeout
	DialogueManager.play("mira_intro_dream") if DialogueManager._dialogues.has("mira_intro_dream") else _set_step("Tìm 3 mảnh gương")

func _set_step(text: String) -> void:
	if step_label:
		step_label.text = text

func _update_memory_label() -> void:
	if memory_label:
		memory_label.text = "Ký ức: %d/4   Mảnh gương: %d/3" % [memories_collected.size(), _count_shards_placed()]

var _shards_placed: int = 0

func _count_shards_placed() -> int:
	return _shards_placed

func _on_shard_picked(_by, shard) -> void:
	var shard_id: String = shard.item_id if "item_id" in shard else ""
	if shard_id != "":
		NotebookManager.set_objective("Đặt mảnh gương vào khung ở phòng trung tâm.")
		_set_step("Đặt mảnh gương vào gương méo")

func _on_shard_placed(item_id: String) -> void:
	_shards_placed += 1
	_update_memory_label()
	if _shards_placed >= 3:
		GameState.set_flag("mira_mirror_repaired", true)
		mirror_warped.visible = false
		mirror_real.visible = true
		NotebookManager.set_objective("Tìm 4 mảnh tranh ký ức về Mira.")
		NotebookManager.add_entry("SYMBOL", "mirror_real", {
			"title_vi": "Gương thật",
			"description_vi": "Phản chiếu lại được hình em rồi."
		})
		DialogueManager.play("mira_mirror_done")
		_set_step("Tìm 4 mảnh ký ức ở khu tranh")
	else:
		_set_step("Mảnh %d/3 đã đặt — tìm tiếp" % _shards_placed)

func _on_memory_picked(_by, mem) -> void:
	var mid: String = mem.item_id if "item_id" in mem else ""
	if mid == "":
		return
	if mid in memories_collected:
		return
	memories_collected.append(mid)
	_update_memory_label()
	NotebookManager.add_entry("MEMORY", mid, _memory_data(mid))
	if memories_collected.size() >= 4:
		GameState.set_flag("mira_memories_complete", true)
		DialogueManager.play("mira_memories_done")
		NotebookManager.set_objective("Mang ánh sáng, ký ức và nước đến chỗ hoa héo.")
		_set_step("Đặt 3 yếu tố vào hoa héo")
		# Spawn essence pickups
		$FlowerArea/LightPickup.enabled = true
		$FlowerArea/MemoryEssencePickup.enabled = true
		$FlowerArea/WaterPickup.enabled = true
	else:
		_set_step("Ký ức %d/4 đã thu — tìm tiếp" % memories_collected.size())

func _memory_data(mid: String) -> Dictionary:
	var map := {
		"mira_cat": {"title_vi": "Con mèo bị thương", "description_vi": "Em ngồi cả đêm bên nó."},
		"mira_flower": {"title_vi": "Bông hoa cho bà cụ", "description_vi": "Bà cụ đã khóc."},
		"mira_child": {"title_vi": "Đưa em bé về nhà", "description_vi": "Em bé đã cười."},
		"mira_friend": {"title_vi": "Lắng nghe bạn khóc", "description_vi": "Em chỉ ngồi đó, không nói gì."}
	}
	return map.get(mid, {"title_vi": mid})

var _essences_placed: int = 0

func _on_essence_placed(item_id: String, _placed_id: String = "") -> void:
	_essences_placed += 1
	if _essences_placed >= 3:
		GameState.set_flag("mira_flower_bloomed", true)
		flower_wilted.visible = false
		flower_bloomed.visible = true
		DialogueManager.play("mira_flower_done")
		background.color = Color(0.18, 0.14, 0.26, 1)
		_set_step("Đến gặp Mira ở phòng trung tâm")
		NotebookManager.set_objective("Dẫn Mira đến gương thật. Đặt mặt nạ xuống.")
		mask.enabled = true
		mira_npc.modulate = Color(1, 0.95, 0.95, 1)

func _on_mask_interact(_by) -> void:
	if ritual_active:
		return
	ritual_active = true
	GameState.set_state("RITUAL_READY")
	DialogueManager.play("mira_ritual")
	# Mask falls
	$RitualMask/Sprite.modulate = Color(1, 1, 1, 0.3)
	# Listen for ritual dialogue end → enable door
	DialogueManager.dialogue_ended.connect(_on_ritual_dialogue_ended, CONNECT_ONE_SHOT)

func _on_ritual_dialogue_ended(dialogue_id: String) -> void:
	if dialogue_id != "mira_ritual":
		return
	ritual_door.enabled = true
	_set_step("Bước qua cửa tỉnh mộng")
	GameState.set_state("WAKE_UP")

func _on_ritual_door(_by) -> void:
	if not GameState.has_flag("mira_realized"):
		return
	DreamStateManager.set_npc_state("mira", "AWAKE_CHANGED")
	GameState.set_state("EXPLORE_VILLAGE")
	SceneLoader.fade_to("res://scenes/world/Village.tscn", 1.5)

func _on_flag_changed(name: String, _val: bool) -> void:
	if name == "mira_realized":
		NotebookManager.add_entry("MEMORY", "mira_realization", {
			"title_vi": "Khoảnh khắc Mira đặt mặt nạ xuống",
			"description_vi": "Em vẫn còn sợ, nhưng em không muốn trốn nữa."
		})
