class_name PortraitStudio extends Interactable
##
## PortraitStudio — chọn 6 mảnh từ 10 để ghép chân dung Mira.
## - "Chỉ tích cực": tranh đẹp nhưng vô hồn.
## - "Chỉ tiêu cực": tranh quá nặng.
## - "Cân bằng" (≥3 cặp tích/tiêu cực bắt buộc): nhận `true_portrait`.
##

signal solved

const PIECES := [
	{"id": "smile",     "label": "Nụ cười",                "kind": "positive"},
	{"id": "tear",      "label": "Nước mắt",               "kind": "negative"},
	{"id": "flower",    "label": "Hoa",                    "kind": "positive"},
	{"id": "crack",     "label": "Vết nứt",                "kind": "negative"},
	{"id": "help_hand", "label": "Bàn tay giúp đỡ",        "kind": "positive"},
	{"id": "ask_hand",  "label": "Bàn tay xin giúp đỡ",    "kind": "negative"},
	{"id": "light",     "label": "Ánh sáng",               "kind": "positive"},
	{"id": "dark",      "label": "Bóng tối",               "kind": "negative"},
	{"id": "eyes_open", "label": "Đôi mắt mở",             "kind": "positive"},
	{"id": "mask",      "label": "Mặt nạ",                 "kind": "neutral"}
]

const PICK_COUNT: int = 6
const REQUIRED_PAIRS := [
	["smile", "tear"],
	["flower", "crack"],
	["help_hand", "ask_hand"]
]

@export var reward_item: String = "true_portrait"

var _ui: CanvasLayer
var _picked: Array[String] = []
var _solved: bool = false

func _ready() -> void:
	super._ready()
	prompt_text = "E - Ghép chân dung"

func _on_interact() -> void:
	if _solved:
		_flash("Đã hoàn thành")
		return
	_open_ui()

func _open_ui() -> void:
	if _ui != null: return
	_ui = CanvasLayer.new()
	_ui.layer = 50
	var host: Node = get_tree().current_scene if get_tree().current_scene else self
	host.add_child(_ui)
	GameState.set_state("PUZZLE_SOLVING")

	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.7)
	dim.anchor_right = 1; dim.anchor_bottom = 1
	dim.mouse_filter = Control.MOUSE_FILTER_STOP
	_ui.add_child(dim)

	var panel := PanelContainer.new()
	panel.anchor_left = 0.5; panel.anchor_top = 0.5
	panel.anchor_right = 0.5; panel.anchor_bottom = 0.5
	panel.offset_left = -220; panel.offset_top = -180
	panel.offset_right = 220; panel.offset_bottom = 180
	_ui.add_child(panel)

	var vb := VBoxContainer.new()
	panel.add_child(vb)

	var t := Label.new()
	t.text = "Xưởng Chân Dung — chọn %d mảnh" % PICK_COUNT
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vb.add_child(t)

	var sub := Label.new()
	sub.text = "Một bức chân dung không chỉ được vẽ bằng đường nét."
	sub.modulate = Color(1, 0.95, 0.7)
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vb.add_child(sub)

	var grid := GridContainer.new()
	grid.columns = 5
	grid.add_theme_constant_override("h_separation", 6)
	grid.add_theme_constant_override("v_separation", 6)
	vb.add_child(grid)
	for piece in PIECES:
		var b := Button.new()
		b.text = "%s\n(%s)" % [piece["label"], piece["kind"]]
		b.toggle_mode = true
		b.custom_minimum_size = Vector2(80, 56)
		b.set_meta("piece_id", piece["id"])
		b.toggled.connect(_on_piece_toggled.bind(piece["id"], b))
		grid.add_child(b)

	var counter := Label.new()
	counter.text = "Đã chọn: 0 / %d" % PICK_COUNT
	counter.modulate = Color(0.85, 0.95, 1)
	counter.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	counter.name = "Counter"
	vb.add_child(counter)

	var hb := HBoxContainer.new()
	hb.alignment = BoxContainer.ALIGNMENT_CENTER
	vb.add_child(hb)
	var ok_btn := Button.new(); ok_btn.text = "Hoàn thành"; ok_btn.pressed.connect(_on_finish); hb.add_child(ok_btn)
	var close_btn := Button.new(); close_btn.text = "Đóng (Esc)"; close_btn.pressed.connect(_close); hb.add_child(close_btn)

func _on_piece_toggled(piece_id: String, btn: Button, pressed: bool) -> void:
	if pressed:
		if _picked.size() >= PICK_COUNT:
			btn.button_pressed = false
			return
		if not piece_id in _picked:
			_picked.append(piece_id)
	else:
		_picked.erase(piece_id)
	_update_counter()

func _update_counter() -> void:
	if _ui == null: return
	var counter: Label = _ui.find_child("Counter", true, false)
	if counter:
		counter.text = "Đã chọn: %d / %d" % [_picked.size(), PICK_COUNT]

func _on_finish() -> void:
	if _picked.size() != PICK_COUNT:
		_show_msg("Cần chọn đúng %d mảnh" % PICK_COUNT)
		return
	# Đếm positive / negative
	var pos := 0; var neg := 0
	for pid in _picked:
		for p in PIECES:
			if p["id"] == pid:
				match p["kind"]:
					"positive": pos += 1
					"negative": neg += 1
		# don't count neutral
	# Quy luật: phải có ít nhất 1 cặp đối — và phải đầy đủ 3 cặp REQUIRED_PAIRS
	var pair_count := 0
	for pair in REQUIRED_PAIRS:
		if pair[0] in _picked and pair[1] in _picked:
			pair_count += 1

	if pos == PICK_COUNT or (pos >= 5 and neg == 0):
		_register_inline("mira_studio_too_pretty", [
			{"speaker": "", "text": "[Bức tranh rất đẹp nhưng vô hồn.]"},
			{"speaker": "", "text": "[Đây là hình ảnh Mira muốn người khác thấy.]"}
		])
		DialogueManager.play("mira_studio_too_pretty")
		_picked.clear()
		_uncheck_all()
		_update_counter()
		LucidityManager.damage(4.0)
		return
	if neg >= 5 and pos == 0:
		_register_inline("mira_studio_too_heavy", [
			{"speaker": "", "text": "[Bức tranh quá nặng.]"},
			{"speaker": "", "text": "[Đây là nỗi đau của Mira, nhưng chưa phải toàn bộ Mira.]"}
		])
		DialogueManager.play("mira_studio_too_heavy")
		_picked.clear()
		_uncheck_all()
		_update_counter()
		LucidityManager.damage(4.0)
		return
	if pair_count < 3:
		_register_inline("mira_studio_unbalanced", [
			{"speaker": "", "text": "[Cần đặt cạnh phần ánh sáng phần bóng tối tương ứng.]"},
			{"speaker": "", "text": "[Cười & Nước mắt — Hoa & Vết nứt — Tay giúp & Tay xin giúp.]"}
		])
		DialogueManager.play("mira_studio_unbalanced")
		_picked.clear()
		_uncheck_all()
		_update_counter()
		return
	# Win
	_solved = true
	enabled = false
	if reward_item != "":
		InventoryManager.add_item(reward_item)
	GameState.set_flag("mira_studio_solved", true)
	_register_inline("mira_studio_solved", [
		{"speaker": "", "text": "[Bức tranh hoàn chỉnh không đẹp hoàn hảo, nhưng có sức sống.]"},
		{"speaker": "Người dịch", "text": "Mira không chỉ là lòng tốt, cũng không chỉ là nỗi đau. Cô là toàn bộ những phần đó."}
	])
	DialogueManager.play("mira_studio_solved")
	solved.emit()
	_close()

func _uncheck_all() -> void:
	if _ui == null: return
	for n in _ui.find_children("*", "Button", true, false):
		if n is Button and n.toggle_mode:
			n.button_pressed = false

func _show_msg(msg: String) -> void:
	if _ui == null: return
	var l := Label.new()
	l.text = msg
	l.modulate = Color(1, 0.6, 0.6, 1)
	_ui.add_child(l)
	l.position = Vector2(20, 50)
	var tw := create_tween()
	tw.tween_property(l, "modulate:a", 0.0, 1.4)
	tw.tween_callback(l.queue_free)

func _flash(msg: String) -> void:
	var p: Label = get_node_or_null("Prompt")
	if p == null: return
	var orig := p.text
	p.text = msg
	await get_tree().create_timer(0.8).timeout
	if p:
		p.text = orig

func _register_inline(id: String, lines: Array) -> void:
	if not DialogueManager._dialogues.has(id):
		DialogueManager.register_from_dict({"id": id, "lines": lines})

func _close() -> void:
	if _ui:
		_ui.queue_free()
		_ui = null
	if GameState.current_state == "PUZZLE_SOLVING":
		GameState.set_state("DREAM_EXPLORE")

func _unhandled_input(event: InputEvent) -> void:
	if _ui == null: return
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		_close()
