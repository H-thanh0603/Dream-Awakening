class_name LiteratureMatch extends Interactable
##
## LiteratureMatch — ghép 4 trang văn vào 4 khung tranh có biểu tượng đúng.
## UI: 2 cột — bên trái là các trang chưa ghép, bên phải là các khung biểu tượng.
## Click một trang rồi click một khung để gắn. Khi đủ 4 cặp đúng → solved.
##

signal solved
signal cancelled

## Mỗi pair có dạng {"page_id": "...", "page_label": "...", "symbol_id": "...", "symbol_label": "..."}
@export var pairs: Array[Dictionary] = []

var _ui: CanvasLayer
var _selected_page_id: String = ""
var _matches: Dictionary = {}    ## page_id -> symbol_id chosen
var _solved: bool = false

func _ready() -> void:
	super._ready()
	prompt_text = "E - Xem trang văn"

func _on_interact() -> void:
	if _solved:
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
	dim.color = Color(0, 0, 0, 0.65)
	dim.anchor_right = 1; dim.anchor_bottom = 1
	dim.mouse_filter = Control.MOUSE_FILTER_STOP
	_ui.add_child(dim)

	var panel := PanelContainer.new()
	panel.anchor_left = 0.5; panel.anchor_top = 0.5
	panel.anchor_right = 0.5; panel.anchor_bottom = 0.5
	panel.offset_left = -200; panel.offset_top = -160
	panel.offset_right = 200; panel.offset_bottom = 160
	_ui.add_child(panel)

	var vb := VBoxContainer.new()
	panel.add_child(vb)
	var t := Label.new()
	t.text = "Ghép trang văn — biểu tượng"
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vb.add_child(t)

	var hb := HBoxContainer.new()
	hb.add_theme_constant_override("separation", 16)
	vb.add_child(hb)

	var pages_vbox := VBoxContainer.new()
	var lbl_pages := Label.new(); lbl_pages.text = "Trang văn"; lbl_pages.modulate = Color(1, 0.95, 0.7)
	pages_vbox.add_child(lbl_pages)
	hb.add_child(pages_vbox)

	var symbols_vbox := VBoxContainer.new()
	var lbl_sym := Label.new(); lbl_sym.text = "Biểu tượng"; lbl_sym.modulate = Color(1, 0.95, 0.7)
	symbols_vbox.add_child(lbl_sym)
	hb.add_child(symbols_vbox)

	# Build buttons
	for p in pairs:
		var bp := Button.new()
		bp.text = "📜 " + str(p.get("page_label", p["page_id"]))
		bp.toggle_mode = true
		bp.pressed.connect(_on_page_clicked.bind(p["page_id"], bp))
		bp.set_meta("page_id", p["page_id"])
		pages_vbox.add_child(bp)
	for p in pairs:
		var bs := Button.new()
		bs.text = "❉ " + str(p.get("symbol_label", p["symbol_id"]))
		bs.pressed.connect(_on_symbol_clicked.bind(p["symbol_id"], bs))
		bs.set_meta("symbol_id", p["symbol_id"])
		symbols_vbox.add_child(bs)

	var hint := Label.new()
	hint.text = "Click 1 trang, sau đó click 1 biểu tượng để ghép."
	hint.modulate = Color(0.85, 0.95, 1)
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vb.add_child(hint)

	var hb2 := HBoxContainer.new()
	hb2.alignment = BoxContainer.ALIGNMENT_CENTER
	vb.add_child(hb2)
	var b_check := Button.new(); b_check.text = "Kiểm tra"; b_check.pressed.connect(_on_check); hb2.add_child(b_check)
	var b_close := Button.new(); b_close.text = "Để sau (Esc)"; b_close.pressed.connect(_close); hb2.add_child(b_close)

func _on_page_clicked(page_id: String, btn: Button) -> void:
	_selected_page_id = page_id
	# Untoggle other page buttons (cosmetic)
	for child in btn.get_parent().get_children():
		if child is Button and child != btn and child.has_meta("page_id"):
			child.button_pressed = false

func _on_symbol_clicked(symbol_id: String, btn: Button) -> void:
	if _selected_page_id == "":
		return
	_matches[_selected_page_id] = symbol_id
	# Visual: gắn label vào symbol button
	btn.text = "✓ " + btn.text.lstrip("✓").strip_edges() + "  ← " + _label_for_page(_selected_page_id)
	_selected_page_id = ""

func _label_for_page(page_id: String) -> String:
	for p in pairs:
		if p["page_id"] == page_id:
			return str(p.get("page_label", page_id))
	return page_id

func _on_check() -> void:
	if _matches.size() < pairs.size():
		_show_msg("Còn thiếu cặp ghép")
		return
	for p in pairs:
		if _matches.get(p["page_id"], "") != p["symbol_id"]:
			_show_msg("Chưa đúng — thử lại")
			LucidityManager.damage(4.0)
			_matches.clear()
			return
	_solved = true
	enabled = false
	solved.emit()
	_close()

func _show_msg(msg: String) -> void:
	if _ui == null: return
	var l := Label.new()
	l.text = msg
	l.modulate = Color(1, 0.6, 0.6)
	_ui.add_child(l)
	l.position = Vector2(20, 50)
	var tw := create_tween()
	tw.tween_property(l, "modulate:a", 0.0, 1.5)
	tw.tween_callback(l.queue_free)

func _close() -> void:
	if _ui:
		_ui.queue_free()
		_ui = null
	if GameState.current_state == "PUZZLE_SOLVING":
		GameState.set_state("DREAM_EXPLORE")
	if not _solved:
		cancelled.emit()

func _unhandled_input(event: InputEvent) -> void:
	if _ui == null: return
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		_close()
