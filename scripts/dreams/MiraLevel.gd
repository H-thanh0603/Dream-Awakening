extends Node2D
##
## MiraLevel — controller cho màn "Chiếc Mặt Nạ Trước Gương" (MVP-1).
## Quản lý 4 khu trong cùng một scene:
##   1) Phòng Trung Tâm  (hub, có cửa 4 khe + tượng + mặt nạ tường + Sổ Mộng)
##   2) Phòng Gương Vỡ   (chuỗi puzzle: đèn → rèm → rương trượt → mắt → ghép gương)
##   3) Hành Lang Mặt Nạ (gương phản chiếu + xếp 6 mặt nạ 2 hàng)
##   4) Nghi Thức Cuối   (mở khi 2 vật phẩm đặt vào cửa: mirror_real + mask_cracked)
## Camera follows player, các khu là quadrant trong world 2x2 (960x540).
##

const QW: int = 480
const QH: int = 270
## World expanded grid: 3 columns × 3 rows of quadrants.
const GRID_COLS: int = 3
const GRID_ROWS: int = 3
const WORLD_W: int = QW * GRID_COLS
const WORLD_H: int = QH * GRID_ROWS

@onready var player: CharacterBody2D = $Player
@onready var camera: Camera2D = $Player/Camera2D
@onready var step_label: Label = $HintHUD/StepBox/StepLabel
@onready var memory_label: Label = $HintHUD/MemoryBox/MemoryLabel

# Phòng Trung Tâm
@onready var central_door: Node2D       = $CentralRoom/CentralDoor
@onready var slot_mirror: Node           = $CentralRoom/CentralDoor/SlotMirror
@onready var slot_mask: Node             = $CentralRoom/CentralDoor/SlotMask
@onready var slot_flower: Node           = $CentralRoom/CentralDoor.get_node_or_null("SlotFlower2")
@onready var slot_portrait: Node         = $CentralRoom/CentralDoor.get_node_or_null("SlotPortrait2")

# Phòng Gương Vỡ
@onready var room_modulate: CanvasModulate = $MirrorRoom/RoomModulate
@onready var stuck_switch: Node          = $MirrorRoom/StuckSwitch
@onready var hairpin_pickup: Node        = $MirrorRoom/Pickups/HairpinPickup
@onready var key_pickup: Node            = $MirrorRoom/Pickups/SilverKeyPickup
@onready var drawer_slot: Node           = $MirrorRoom/DrawerSlot
@onready var curtain: Node2D             = $MirrorRoom/Curtain
@onready var curtain_slot: Node          = $MirrorRoom/CurtainSlot
@onready var chest: Node                 = $MirrorRoom/TilePuzzleChest
@onready var chest_reward_pickup: Node   = $MirrorRoom/Pickups/ChestShardPickup
@onready var memory_cat_pickup: Node     = $MirrorRoom/Pickups/CatMemoryPickup
@onready var hidden_wall: ColorRect      = $MirrorRoom/HiddenWall
@onready var wall_shard_pickup: Node     = $MirrorRoom/Pickups/WallShardPickup
@onready var mirror_assemble: Node2D     = $MirrorRoom/MirrorAssemble
@onready var mirror_shard_slots: Array[Node] = [
	$MirrorRoom/MirrorAssemble/SlotN,
	$MirrorRoom/MirrorAssemble/SlotE,
	$MirrorRoom/MirrorAssemble/SlotS,
	$MirrorRoom/MirrorAssemble/SlotW,
]
@onready var mirror_real_pickup: Node    = $MirrorRoom/Pickups/MirrorRealPickup

# Hành Lang Mặt Nạ
@onready var reflection_mirror: Node     = $MaskHall/ReflectionMirror
@onready var hidden_mask_pickup: Node    = $MaskHall/HiddenMaskPickup
@onready var mask_slots: Array[Node]     = [
	$MaskHall/Wall/Outer1,
	$MaskHall/Wall/Outer2,
	$MaskHall/Wall/Outer3,
	$MaskHall/Wall/Inner1,
	$MaskHall/Wall/Inner2,
	$MaskHall/Wall/Inner3,
]
@onready var abstract_face: Node2D       = $MaskHall/AbstractFace
@onready var mask_cracked_pickup: Node   = $MaskHall/MaskCrackedPickup
@onready var mask_perfect_pickup: Node   = $MaskHall/MaskPerfectPickup

# Nghi Thức Cuối
@onready var mira: Node                  = $Ritual/Mira
@onready var mira_small: Node            = $Ritual/MiraSmall
@onready var ritual_mirror_slot: Node    = $Ritual/RitualMirrorSlot
@onready var ritual_mask_floor: Node     = $Ritual/RitualMaskFloor
@onready var shatter_zone: Area2D        = $Ritual/ShatterZone
@onready var shatter_particles: CPUParticles2D = $Ritual/ShatterParticles

# Eye rotators
@onready var eye_rotators: Array[Node]   = [
	$MirrorRoom/EyeRotators/E1,
	$MirrorRoom/EyeRotators/E2,
	$MirrorRoom/EyeRotators/E3,
	$MirrorRoom/EyeRotators/E4,
]
const EYE_ANSWER := ["up", "right", "down", "left"]

# === State counters ===
var _shards_placed: int = 0
var _last_save_pos: Vector2 = Vector2.ZERO

func _ready() -> void:
	GameState.set_state("DREAM_EXPLORE")
	GameState.current_dream_id = "mira"
	LucidityManager.enable()
	if LucidityManager.has_signal("collapsed") and not LucidityManager.collapsed.is_connected(_on_collapsed):
		LucidityManager.collapsed.connect(_on_collapsed)

	NotebookManager.set_objective("Khám phá Phòng Trung Tâm. Tìm cách mở các khu khác.")
	_set_step("Quan sát tượng và mặt nạ trong Phòng Trung Tâm")

	_register_dialogues()
	_wire_signals()
	_update_camera_for_room()

	player.position = Vector2(QW * 0.5, QH * 0.5)   # spawn ở Phòng Trung Tâm (Q1)
	_last_save_pos = player.position

	await get_tree().create_timer(0.5).timeout
	if DialogueManager._dialogues.has("mira_dream_intro"):
		DialogueManager.play("mira_dream_intro")

func _process(_delta: float) -> void:
	_update_camera_for_room()

func _update_camera_for_room() -> void:
	var p: Vector2 = player.position
	var qx: int = clamp(int(p.x / QW), 0, GRID_COLS - 1)
	var qy: int = clamp(int(p.y / QH), 0, GRID_ROWS - 1)
	camera.limit_left = qx * QW
	camera.limit_top = qy * QH
	camera.limit_right = (qx + 1) * QW
	camera.limit_bottom = (qy + 1) * QH

func _set_step(t: String) -> void:
	if step_label: step_label.text = t

func _set_memory(t: String) -> void:
	if memory_label: memory_label.text = t

# === Dialogues ===

func _register_dialogues() -> void:
	if not DialogueManager._dialogues.has("mira_dream_intro"):
		DialogueManager.register_from_dict({
			"id": "mira_dream_intro",
			"lines": [
				{"speaker": "???", "text": "Một căn phòng tím lặng. Có gì đó đang nhìn từ trong gương."},
				{"speaker": "Người dịch", "text": "Tượng kia... khuôn mặt đã bị mài nhẵn. 'Đẹp là đủ.'"},
				{"speaker": "Người dịch", "text": "Tôi nên bắt đầu từ phòng phía tây — cửa duy nhất chưa khóa."}
			]
		})
	if not DialogueManager._dialogues.has("mira_examine_statue"):
		DialogueManager.register_from_dict({
			"id": "mira_examine_statue",
			"lines": [
				{"speaker": "Người dịch", "text": "Tượng giống hệt Mira. Nhưng khuôn mặt đã bị mài nhẵn."},
				{"speaker": "Người dịch", "text": "Phía dưới khắc: 'Đẹp là đủ.'"},
				{"speaker": "", "text": "[Sổ Mộng cập nhật: Tượng không mặt — Mira có thể đang tự xóa phần thật của mình.]",
					"side_effect": {"set_flags": ["mira_clue_statue"]}}
			]
		})
	if not DialogueManager._dialogues.has("mira_examine_mask"):
		DialogueManager.register_from_dict({
			"id": "mira_examine_mask",
			"lines": [
				{"speaker": "Người dịch", "text": "Mặt nạ này rất đẹp. Nhưng mặt trong đầy vết nứt."},
				{"speaker": "", "text": "[Sổ Mộng cập nhật: Mặt nạ đẹp nhưng nứt bên trong — hình ảnh hoàn hảo có thể đang che giấu điều gì.]",
					"side_effect": {"set_flags": ["mira_clue_mask"]}}
			]
		})
	if not DialogueManager._dialogues.has("mira_mirror_revealed"):
		DialogueManager.register_from_dict({
			"id": "mira_mirror_revealed",
			"lines": [
				{"speaker": "???", "text": "Một nhóm trẻ. Có tiếng cười. Mira cúi đầu."},
				{"speaker": "Gương", "text": "'Che lại đi.'"},
				{"speaker": "Người dịch", "text": "Manh mối lớn 1 — Mira từng bị tổn thương bởi ánh nhìn và lời chê bai.",
					"side_effect": {"set_flags": ["mira_mirror_repaired"], "give_items": ["mirror_real"]}}
			]
		})
	if not DialogueManager._dialogues.has("mira_reflection_hint"):
		DialogueManager.register_from_dict({
			"id": "mira_reflection_hint",
			"lines": [
				{"speaker": "Người dịch", "text": "Gương này không phản chiếu tôi — nó phản chiếu phía sau lưng."},
				{"speaker": "Người dịch", "text": "Có cái gì sau cột kia. Một mặt nạ đang trốn..."}
			]
		})
	if not DialogueManager._dialogues.has("mira_mask_arranged"):
		DialogueManager.register_from_dict({
			"id": "mira_mask_arranged",
			"lines": [
				{"speaker": "???", "text": "Mira đứng trước đám đông. Cô cười, dù bàn tay đang run."},
				{"speaker": "Đám đông", "text": "'Như vậy mới xinh.'"},
				{"speaker": "Người dịch", "text": "Manh mối lớn 2 — Mira học cách cười để được chấp nhận.",
					"side_effect": {"set_flags": ["mira_mask_arranged"]}}
			]
		})
	if not DialogueManager._dialogues.has("mira_mask_wrong_row"):
		DialogueManager.register_from_dict({
			"id": "mira_mask_wrong_row",
			"lines": [
				{"speaker": "???", "text": "'Không phải khuôn mặt đó.'"},
				{"speaker": "???", "text": "'Còn thiếu phần bị che.'"}
			]
		})
	if not DialogueManager._dialogues.has("mira_eye_correct"):
		DialogueManager.register_from_dict({
			"id": "mira_eye_correct",
			"lines": [
				{"speaker": "", "text": "[Một ô tường mở ra — có thứ gì đó lấp lánh bên trong.]"}
			]
		})
	if not DialogueManager._dialogues.has("mira_chest_clue"):
		DialogueManager.register_from_dict({
			"id": "mira_chest_clue",
			"lines": [
				{"speaker": "Người dịch", "text": "Một con mèo dưới mưa. Mira quấn khăn cho nó. Cô bị ướt nhưng vẫn ngồi đó."},
				{"speaker": "Người dịch", "text": "Có lẽ Mira là người tốt bụng... hay còn gì đó cô đang giấu?"}
			]
		})
	if not DialogueManager._dialogues.has("mira_ritual_warn"):
		DialogueManager.register_from_dict({
			"id": "mira_ritual_warn",
			"lines": [
				{"speaker": "???", "text": "Không thể gỡ một lớp phòng vệ nếu chưa có gì thay thế nó."}
			]
		})
	if not DialogueManager._dialogues.has("mira_ritual_done"):
		DialogueManager.register_from_dict({
			"id": "mira_ritual_done",
			"lines": [
				{"speaker": "Mira", "text": "Mình cứ nghĩ nếu không đẹp, không dịu dàng, không luôn ổn..."},
				{"speaker": "Mira", "text": "thì sẽ không còn gì đáng được yêu quý."},
				{"speaker": "Mira", "text": "Nhưng đây cũng là mình. Cả nụ cười. Cả vết nứt."},
				{"speaker": "Mira", "text": "Cả lúc mình giúp người khác. Cả lúc mình muốn được giúp."},
				{"speaker": "Mira", "text": "Mình không muốn sống như một chiếc mặt nạ nữa.",
					"side_effect": {"set_flags": ["mira_realized"]}}
			]
		})
	# === MVP-2/3 dialogues ===
	if not DialogueManager._dialogues.has("mira_library_intro"):
		DialogueManager.register_from_dict({
			"id": "mira_library_intro",
			"lines": [
				{"speaker": "Người dịch", "text": "Sách lộn xộn. Trang thì rách. Một câu chuyện đặt sai chỗ thì không thể đọc."},
				{"speaker": "Người dịch", "text": "Bắt đầu bằng việc đặt mọi thứ đúng thứ tự — lịch sử, văn học, nhật ký."}
			]
		})
	if not DialogueManager._dialogues.has("mira_library_history_done"):
		DialogueManager.register_from_dict({
			"id": "mira_library_history_done",
			"lines": [
				{"speaker": "", "text": "[Kệ Lịch Sử trượt mở. Một mảnh ký ức rơi ra.]"},
				{"speaker": "Người dịch", "text": "Muốn hiểu một câu chuyện, phải đặt nó đúng thứ tự thời gian."}
			]
		})
	if not DialogueManager._dialogues.has("mira_library_lit_done"):
		DialogueManager.register_from_dict({
			"id": "mira_library_lit_done",
			"lines": [
				{"speaker": "", "text": "[Một đoạn văn hiện ra:]"},
				{"speaker": "", "text": "'Một bức chân dung không chỉ được vẽ bằng đường nét.'"},
				{"speaker": "", "text": "'Nó còn được vẽ bằng điều người ấy đã giữ lại trong im lặng.'"}
			]
		})
	if not DialogueManager._dialogues.has("mira_library_diary_done"):
		DialogueManager.register_from_dict({
			"id": "mira_library_diary_done",
			"lines": [
				{"speaker": "Người dịch", "text": "Tổn thương → tạo mặt nạ → được khen vì mặt nạ → mắc kẹt trong mặt nạ."},
				{"speaker": "Người dịch", "text": "Mira không chỉ che ngoại hình. Cô che cả nhu cầu được giúp đỡ."}
			]
		})
	if not DialogueManager._dialogues.has("mira_library_box_open"):
		DialogueManager.register_from_dict({
			"id": "mira_library_box_open",
			"lines": [
				{"speaker": "", "text": "[Hộp mở. Có một bông hoa khô và một dòng chữ: 'Mình không được làm phiền ai.']"}
			]
		})
	if not DialogueManager._dialogues.has("mira_garden_intro"):
		DialogueManager.register_from_dict({
			"id": "mira_garden_intro",
			"lines": [
				{"speaker": "", "text": "[Khu vườn bốn luống hình học. Nước không chảy.]"},
				{"speaker": "Tường", "text": "'Nước sẽ chảy đến nơi có phần thiếu lớn nhất.'"},
				{"speaker": "Tường (chữ nhỏ)", "text": "'Bông hoa đẹp nhất cần nước trước.' — (cẩn thận, đây có thể là lời dụ)"}
			]
		})
	if not DialogueManager._dialogues.has("mira_studio_intro"):
		DialogueManager.register_from_dict({
			"id": "mira_studio_intro",
			"lines": [
				{"speaker": "Người dịch", "text": "Một xưởng vẽ trống. Khung tranh chờ đợi."},
				{"speaker": "Người dịch", "text": "Đây là phần khó nhất — chọn 6 mảnh để vẽ Mira là chính cô."}
			]
		})

# === Wiring ===

func _wire_signals() -> void:
	# Phòng Trung Tâm — slot interactions
	if slot_mirror.has_signal("item_placed"):
		slot_mirror.item_placed.connect(_on_central_slot_placed.bind("mirror"))
	if slot_mask.has_signal("item_placed"):
		slot_mask.item_placed.connect(_on_central_slot_placed.bind("mask"))
	if slot_flower and slot_flower.has_signal("item_placed"):
		slot_flower.item_placed.connect(_on_central_slot_placed.bind("flower"))
	if slot_portrait and slot_portrait.has_signal("item_placed"):
		slot_portrait.item_placed.connect(_on_central_slot_placed.bind("portrait"))

	# Phòng Gương Vỡ
	if stuck_switch.has_signal("unstuck"):
		stuck_switch.unstuck.connect(_on_switch_unstuck)
	if drawer_slot.has_signal("item_placed"):
		drawer_slot.item_placed.connect(_on_drawer_opened)
	if curtain_slot.has_signal("item_placed"):
		curtain_slot.item_placed.connect(_on_curtain_opened)
	if chest.has_signal("opened"):
		chest.opened.connect(_on_chest_opened)
	for er in eye_rotators:
		if er.has_signal("direction_changed"):
			er.direction_changed.connect(_on_eye_changed)
	for s in mirror_shard_slots:
		if s.has_signal("item_placed"):
			s.item_placed.connect(_on_mirror_shard_placed)

	# Hành Lang Mặt Nạ
	for s in mask_slots:
		if s.has_signal("mask_attached"):
			s.mask_attached.connect(_on_mask_attached)
		if s.has_signal("mask_removed"):
			s.mask_removed.connect(_on_mask_removed)

# === Phòng Gương Vỡ ===

func _on_switch_unstuck(_id: String) -> void:
	# Bật đèn ⇒ hé lộ mảnh gương 1 dưới chân bàn trang điểm
	chest_reward_pickup_show_first_shard()
	NotebookManager.add_entry("HINT", "switch_unstuck", {"title_vi": "Đèn đã bật. Có gì đó lấp lánh dưới sàn."})
	_set_step("Nhặt mảnh gương 1, sau đó tìm cách mở rèm")
	# Tween modulate thật (đã được StuckSwitch gọi)

func chest_reward_pickup_show_first_shard() -> void:
	# Mảnh gương 1 đặt sẵn trong scene, ban đầu invisible. Hé lộ:
	var shard1 := $MirrorRoom/Pickups/Shard1Pickup
	if shard1:
		shard1.visible = true
		if "enabled" in shard1: shard1.enabled = true

func _on_drawer_opened(_item_id: String) -> void:
	# Khoá mở: cho dây kéo rèm + giấy 4 mắt vào kho
	InventoryManager.add_item("curtain_cord")
	InventoryManager.add_item("eye_paper")
	NotebookManager.add_entry("HINT", "drawer", {"title_vi": "Trong ngăn kéo: dây rèm và mảnh giấy 4 con mắt."})
	_set_step("Dùng dây rèm để mở rèm")

func _on_curtain_opened(_item_id: String) -> void:
	# Mở rèm → ánh sáng + lộ mảnh gương 2
	if curtain:
		var tw := create_tween()
		tw.tween_property(curtain, "modulate:a", 0.0, 0.6)
		tw.tween_callback(func(): curtain.visible = false)
	var shard2 := $MirrorRoom/Pickups/Shard2Pickup
	if shard2:
		shard2.visible = true
		if "enabled" in shard2: shard2.enabled = true
	# Hiện rương
	if chest and "enabled" in chest:
		chest.enabled = true
	if chest and chest is Node2D:
		chest.visible = true
	_set_step("Giải puzzle tranh trượt trên nắp rương")

func _on_chest_opened() -> void:
	# Mở rương: cho mảnh gương 3 + ký ức mèo
	if chest_reward_pickup:
		chest_reward_pickup.visible = true
		if "enabled" in chest_reward_pickup: chest_reward_pickup.enabled = true
	if memory_cat_pickup:
		memory_cat_pickup.visible = true
		if "enabled" in memory_cat_pickup: memory_cat_pickup.enabled = true
	NotebookManager.add_entry("MEMORY", "mira_cat_outer", {
		"title_vi": "Con mèo dưới mưa",
		"description_vi": "Mira chăm con mèo. Sau đó cô ốm — nhưng vẫn nói: 'Tôi ổn.'"
	})
	if DialogueManager._dialogues.has("mira_chest_clue"):
		DialogueManager.play("mira_chest_clue")
	_set_step("Xoay 4 con mắt theo mảnh giấy: Lên - Phải - Xuống - Trái")

func _on_eye_changed(_eye_id: String, _dir: int) -> void:
	# Check kết quả
	var ok: bool = true
	for i in range(eye_rotators.size()):
		var er = eye_rotators[i]
		if not er.has_method("get_dir_name"):
			ok = false; break
		if er.get_dir_name() != EYE_ANSWER[i]:
			ok = false; break
	if ok:
		_on_eyes_solved()

var _eyes_solved: bool = false
func _on_eyes_solved() -> void:
	if _eyes_solved: return
	_eyes_solved = true
	# Hé lộ wall shard
	if hidden_wall:
		var tw := create_tween()
		tw.tween_property(hidden_wall, "modulate:a", 0.0, 0.6)
	if wall_shard_pickup:
		wall_shard_pickup.visible = true
		if "enabled" in wall_shard_pickup: wall_shard_pickup.enabled = true
	DialogueManager.play("mira_eye_correct")
	_set_step("Đem 4 mảnh gương ráp vào khung gương lớn")

func _on_mirror_shard_placed(_item_id: String) -> void:
	_shards_placed += 1
	_set_memory("Mảnh gương: %d/4" % _shards_placed)
	if _shards_placed >= 4:
		_complete_mirror()

func _complete_mirror() -> void:
	GameState.set_flag("mira_mirror_repaired", true)
	# Visual: gương sáng + cinematic
	var glow: Sprite2D = $MirrorRoom/MirrorAssemble.get_node_or_null("MirrorReal")
	if glow:
		glow.visible = true
		var tw := create_tween()
		tw.tween_property(glow, "modulate:a", 1.0, 0.8)
	if mirror_real_pickup:
		mirror_real_pickup.visible = true
		if "enabled" in mirror_real_pickup: mirror_real_pickup.enabled = true
	DialogueManager.play("mira_mirror_revealed")
	_set_step("Đem Mảnh phản chiếu về Phòng Trung Tâm, đặt vào khe 1")

# === Hành Lang Mặt Nạ ===

const ROW_OUTER := ["mask_smile", "mask_obedient", "mask_quiet"]
const ROW_INNER := ["mask_fear", "mask_tired", "mask_angry"]

func _on_mask_attached(mask_id: String, slot_id: String) -> void:
	# Validate row kind: outer slots cần outer mask, inner slots cần inner mask
	var slot := _get_mask_slot(slot_id)
	if slot == null: return
	var expected_pool: Array = ROW_OUTER if slot.row_kind == "outer" else ROW_INNER
	if not mask_id in expected_pool:
		# wrong row! → trả lại mặt nạ + warning
		await get_tree().create_timer(0.1).timeout
		# Force remove from slot
		if slot.has_method("_remove_current"):
			slot._remove_current()
		LucidityManager.damage(8.0)
		DialogueManager.play("mira_mask_wrong_row")
		return
	_check_mask_arrangement()

func _on_mask_removed(_mask_id: String, _slot_id: String) -> void:
	# nothing special; recheck just in case
	pass

func _get_mask_slot(slot_id: String) -> Node:
	for s in mask_slots:
		if s.slot_id == slot_id:
			return s
	return null

var _mask_arranged: bool = false
func _check_mask_arrangement() -> void:
	if _mask_arranged: return
	for s in mask_slots:
		if s.attached_mask == "":
			return
	_mask_arranged = true
	GameState.set_flag("mira_mask_arranged", true)
	# Glow tween
	for s in mask_slots:
		var att: Sprite2D = s.get_node_or_null("Attached")
		if att:
			var tw := create_tween()
			tw.tween_property(att, "modulate", Color(1.2, 1.05, 0.8), 0.5)
	# Abstract face mở miệng → reward
	if abstract_face:
		var tw2 := create_tween()
		tw2.tween_property(abstract_face, "scale", Vector2(1.1, 1.1), 0.4)
		tw2.tween_property(abstract_face, "scale", Vector2(1.0, 1.0), 0.3)
	if mask_cracked_pickup:
		mask_cracked_pickup.visible = true
		if "enabled" in mask_cracked_pickup: mask_cracked_pickup.enabled = true
	DialogueManager.play("mira_mask_arranged")
	_set_step("Lấy Mảnh mặt nạ nứt — về Phòng Trung Tâm đặt vào khe 2")

# === Phòng Trung Tâm — gắn vật vào cửa ===

func _on_central_slot_placed(_item_id: String, slot_kind: String) -> void:
	if slot_kind == "mirror":
		GameState.set_flag("mira_door_slot1", true)
		_set_step("Đến Hành Lang Mặt Nạ (đông) — tìm 6 mặt nạ và sắp xếp 2 hàng")
		# Visual: glow slot
		var v: ColorRect = slot_mirror.get_node_or_null("Visual")
		if v: v.color = Color(0.7, 0.9, 1, 1)
		# Trả lại Mảnh phản chiếu cho người chơi — sẽ cần ở Nghi Thức Cuối.
		InventoryManager.add_item("mirror_real")
		NotebookManager.add_entry("HINT", "central_slot_mirror_keep", {
			"title_vi": "Mảnh phản chiếu trở lại trong tay",
			"description_vi": "Khe đã ghi nhớ ánh phản chiếu. Em vẫn cần nó cho nghi thức cuối."
		})
	elif slot_kind == "mask":
		GameState.set_flag("mira_door_slot2", true)
		_set_step("Vào Nghi Thức Cuối (đi xuống) — đối diện chính mình")
		var v: ColorRect = slot_mask.get_node_or_null("Visual")
		if v: v.color = Color(1, 0.85, 0.75, 1)
		_unlock_ritual_room()
	elif slot_kind == "flower":
		GameState.set_flag("mira_door_slot3", true)
		_set_step("Cánh cửa thêm sáng — đến Xưởng Chân Dung")
		var v: ColorRect = slot_flower.get_node_or_null("Visual")
		if v: v.color = Color(0.85, 1, 0.75, 1)
	elif slot_kind == "portrait":
		GameState.set_flag("mira_door_slot4", true)
		_set_step("Cửa tỉnh mộng đã đủ ánh sáng — vào Nghi Thức Cuối")
		var v: ColorRect = slot_portrait.get_node_or_null("Visual")
		if v: v.color = Color(1, 0.95, 0.85, 1)

func _unlock_ritual_room() -> void:
	# Cửa Ritual chỉ là visual; player có thể đi tự do, gating qua puzzle.
	pass

# === Nghi Thức Cuối ===

func can_shatter_mask() -> bool:
	# mira_ritual_mirror_placed kéo theo Mira Nhỏ xuất hiện (RitualSpawnSlot reveals it).
	return GameState.has_flag("mira_mirror_repaired") \
		and GameState.has_flag("mira_mask_arranged") \
		and GameState.has_flag("mira_ritual_mirror_placed") \
		and GameState.has_flag("mira_mask_floor_placed")

func try_shatter_mask() -> void:
	if not can_shatter_mask():
		DialogueManager.play("mira_ritual_warn")
		return
	# Particles + camera shake + dialogue
	if shatter_particles:
		shatter_particles.emitting = true
	_camera_shake(0.4, 4.0)
	# Mira tháo mặt nạ
	if mira:
		var spr: Sprite2D = mira.get_node_or_null("Sprite")
		if spr:
			var tw := create_tween()
			tw.tween_property(spr, "modulate", Color(1, 1, 1), 0.6)
	DialogueManager.play("mira_ritual_done")
	# Sau khi dialogue xong → set state and exit
	await DialogueManager.dialogue_ended
	DreamStateManager.set_npc_state("mira", "AWAKE_CHANGED")
	LucidityManager.disable()
	GameState.set_state("EXPLORE_VILLAGE")
	SceneLoader.fade_to("res://scenes/world/Village.tscn", 1.5)

func _camera_shake(duration: float, intensity: float) -> void:
	if camera == null: return
	var orig: Vector2 = camera.offset
	var elapsed: float = 0.0
	while elapsed < duration:
		camera.offset = orig + Vector2(randf_range(-intensity, intensity), randf_range(-intensity, intensity))
		await get_tree().process_frame
		elapsed += get_process_delta_time()
	camera.offset = orig

# === Lucidity collapse ===

func _on_collapsed() -> void:
	player.position = _last_save_pos
	LucidityManager.lucidity = 60.0
	if LucidityManager.has_method("emit"):
		pass
	if LucidityManager.has_signal("lucidity_changed"):
		LucidityManager.lucidity_changed.emit(60.0)
