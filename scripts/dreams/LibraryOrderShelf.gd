class_name LibraryOrderShelf extends Interactable
##
## LibraryOrderShelf — kệ sách yêu cầu xếp các quyển/trang đúng thứ tự.
## Khi tương tác mở UI panel với danh sách N nút có thể "đẩy lên / xuống".
## Solved khi thứ tự khớp `correct_order`.
##

signal solved
signal cancelled

@export var title_vi: String = "Xếp đúng thứ tự"
@export var subtitle_vi: String = "Bấm mũi tên để di chuyển."
@export var items_vi: Array[String] = []          # nhãn hiển thị
@export var correct_order: Array[int] = []        # index mong muốn (0..N-1)
@export var initial_shuffle: Array[int] = []      # nếu rỗng, sẽ dùng đảo ngược

var _ui: CanvasLayer
var _list_box: VBoxContainer
var _state: Array[int] = []
var _solved: bool = false

func _ready() -> void:
	super._ready()
	prompt_text = "E - Xem kệ"

func _on_interact() -> void:
	if _solved:
		_flash("Đã xếp đúng")
		return
	_open_ui()

func _open_ui() -> void:
	if _ui != null:
		return
	_state = (initial_shuffle.duplicate() if initial_shuffle.size() == items_vi.size()
		else _default_shuffle())
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
	panel.offset_left = -160; panel.offset_top = -150
	panel.offset_right = 160; panel.offset_bottom = 150
	_ui.add_child(panel)

	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 4)
	panel.add_child(vb)

	var t := Label.new()
	t.text = title_vi
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vb.add_child(t)

	var sub := Label.new()
	sub.text = subtitle_vi
	sub.modulate = Color(1, 0.95, 0.7)
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vb.add_child(sub)

	_list_box = VBoxContainer.new()
	vb.add_child(_list_box)
	_redraw()

	var hb := HBoxContainer.new()
	hb.alignment = BoxContainer.ALIGNMENT_CENTER
	vb.add_child(hb)
	var btn_check := Button.new()
	btn_check.text = "Kiểm tra"
	btn_check.pressed.connect(_on_check)
	hb.add_child(btn_check)
	var btn_close := Button.new()
	btn_close.text = "Để sau (Esc)"
	btn_close.pressed.connect(_close)
	hb.add_child(btn_close)

func _default_shuffle() -> Array[int]:
	var n := items_vi.size()
	var arr: Array[int] = []
	for i in range(n):
		arr.append(n - 1 - i)
	return arr

func _redraw() -> void:
	for c in _list_box.get_children():
		c.queue_free()
	for i in range(_state.size()):
		var row := HBoxContainer.new()
		var lbl := Label.new()
		lbl.text = "%d. %s" % [i + 1, items_vi[_state[i]]]
		lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(lbl)
		var up := Button.new()
		up.text = "↑"
		up.disabled = i == 0
		up.pressed.connect(_swap.bind(i, i - 1))
		row.add_child(up)
		var down := Button.new()
		down.text = "↓"
		down.disabled = i >= _state.size() - 1
		down.pressed.connect(_swap.bind(i, i + 1))
		row.add_child(down)
		_list_box.add_child(row)

func _swap(a: int, b: int) -> void:
	var tmp := _state[a]
	_state[a] = _state[b]
	_state[b] = tmp
	_redraw()

func _on_check() -> void:
	for i in range(_state.size()):
		if _state[i] != correct_order[i]:
			_flash_in_panel("Chưa đúng — thử lại")
			LucidityManager.damage(4.0)
			return
	_solved = true
	enabled = false
	prompt_text = "Đã xếp đúng"
	solved.emit()
	_close()

func _flash_in_panel(msg: String) -> void:
	# Add a tiny label fade
	var l := Label.new()
	l.text = msg
	l.modulate = Color(1, 0.6, 0.6, 1)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	if _ui:
		_ui.add_child(l)
		l.position = Vector2(0, 30)
		var tw := create_tween()
		tw.tween_property(l, "modulate:a", 0.0, 1.4)
		tw.tween_callback(l.queue_free)

func _close() -> void:
	if _ui:
		_ui.queue_free()
		_ui = null
	if GameState.current_state == "PUZZLE_SOLVING":
		GameState.set_state("DREAM_EXPLORE")
	if not _solved:
		cancelled.emit()

func _flash(msg: String) -> void:
	var p: Label = get_node_or_null("Prompt")
	if p == null: return
	var orig := p.text
	p.text = msg
	await get_tree().create_timer(0.8).timeout
	if p:
		p.text = orig

func _unhandled_input(event: InputEvent) -> void:
	if _ui == null: return
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		_close()
