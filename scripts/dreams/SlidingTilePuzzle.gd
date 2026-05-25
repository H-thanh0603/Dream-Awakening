class_name SlidingTilePuzzle extends CanvasLayer
##
## SlidingTilePuzzle — UI overlay 3x3 cho puzzle tranh trượt.
## Sử dụng đơn giản bằng GridContainer + 9 nút. 8 mảnh + 1 ô trống.
## Khi solved → emit signal `solved` rồi đóng UI.
##

signal solved
signal cancelled

const SIZE_N: int = 3   # 3x3
const TILE_PX: int = 64

@export var auto_open: bool = false
@export var image_path: String = "res://assets/sprites/dream_mira/injured_cat.png"

var _tiles: Array[int] = []   ## index 0..8, 8 = trống
var _buttons: Array[Button] = []
var _grid: GridContainer
var _root: Control
var _title: Label
var _hint: Label
var _texture: Texture2D

func _ready() -> void:
	layer = 50
	visible = auto_open
	_build_ui()
	if auto_open:
		open()

func _build_ui() -> void:
	_root = Control.new()
	_root.name = "Root"
	_root.anchor_right = 1
	_root.anchor_bottom = 1
	_root.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_root)

	# Dimmer
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.65)
	dim.anchor_right = 1
	dim.anchor_bottom = 1
	dim.mouse_filter = Control.MOUSE_FILTER_STOP
	_root.add_child(dim)

	var panel := PanelContainer.new()
	panel.anchor_left = 0.5
	panel.anchor_top = 0.5
	panel.anchor_right = 0.5
	panel.anchor_bottom = 0.5
	panel.offset_left = -130
	panel.offset_top = -160
	panel.offset_right = 130
	panel.offset_bottom = 160
	_root.add_child(panel)

	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 6)
	panel.add_child(vb)

	_title = Label.new()
	_title.text = "Tranh trượt — Con mèo trong khăn"
	_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vb.add_child(_title)

	_hint = Label.new()
	_hint.text = "Bấm vào ô cạnh ô trống để trượt"
	_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_hint.modulate = Color(1, 0.95, 0.7)
	vb.add_child(_hint)

	_grid = GridContainer.new()
	_grid.columns = SIZE_N
	_grid.add_theme_constant_override("h_separation", 2)
	_grid.add_theme_constant_override("v_separation", 2)
	vb.add_child(_grid)

	# Build 9 buttons
	if ResourceLoader.exists(image_path):
		_texture = load(image_path)
	for i in range(SIZE_N * SIZE_N):
		var b := Button.new()
		b.custom_minimum_size = Vector2(TILE_PX, TILE_PX)
		b.expand_icon = true
		b.toggle_mode = false
		b.pressed.connect(_on_tile_pressed.bind(i))
		_buttons.append(b)
		_grid.add_child(b)

	var btn_row := HBoxContainer.new()
	btn_row.alignment = BoxContainer.ALIGNMENT_CENTER
	vb.add_child(btn_row)
	var btn_close := Button.new()
	btn_close.text = "Để sau (Esc)"
	btn_close.pressed.connect(close)
	btn_row.add_child(btn_close)

func open() -> void:
	visible = true
	GameState.set_state("PUZZLE_SOLVING")
	_init_state()
	_redraw()

func close() -> void:
	visible = false
	if GameState.current_state == "PUZZLE_SOLVING":
		GameState.set_state("DREAM_EXPLORE")
	cancelled.emit()

func _init_state() -> void:
	# Solvable shuffle: do N random valid swaps from solved.
	_tiles.clear()
	for i in range(SIZE_N * SIZE_N):
		_tiles.append(i)
	# Đảo trộn 80 bước hợp lệ → vẫn đảm bảo có nghiệm
	for _i in range(80):
		var empty_idx: int = _tiles.find(SIZE_N * SIZE_N - 1)
		var moves: Array[int] = _neighbors_of(empty_idx)
		var pick: int = moves[randi() % moves.size()]
		_tiles[empty_idx] = _tiles[pick]
		_tiles[pick] = SIZE_N * SIZE_N - 1

func _neighbors_of(idx: int) -> Array[int]:
	var r: int = idx / SIZE_N
	var c: int = idx % SIZE_N
	var out: Array[int] = []
	if r > 0:           out.append(idx - SIZE_N)
	if r < SIZE_N - 1:  out.append(idx + SIZE_N)
	if c > 0:           out.append(idx - 1)
	if c < SIZE_N - 1:  out.append(idx + 1)
	return out

func _on_tile_pressed(slot_idx: int) -> void:
	var empty_idx: int = _tiles.find(SIZE_N * SIZE_N - 1)
	if not slot_idx in _neighbors_of(empty_idx):
		return
	# Hoán đổi
	_tiles[empty_idx] = _tiles[slot_idx]
	_tiles[slot_idx] = SIZE_N * SIZE_N - 1
	_redraw()
	if _is_solved():
		_hint.text = "Đã xếp đúng!"
		_hint.modulate = Color(0.7, 1, 0.7)
		await get_tree().create_timer(0.6).timeout
		solved.emit()
		# Đóng UI sau khi emit
		visible = false
		if GameState.current_state == "PUZZLE_SOLVING":
			GameState.set_state("DREAM_EXPLORE")

func _redraw() -> void:
	for slot in range(_buttons.size()):
		var t: int = _tiles[slot]
		var b: Button = _buttons[slot]
		if t == SIZE_N * SIZE_N - 1:
			b.text = ""
			b.icon = null
			b.modulate = Color(0.15, 0.13, 0.18, 1)
			b.disabled = true
		else:
			b.disabled = false
			b.modulate = Color(1, 1, 1, 1)
			# Cắt phần texture tương ứng
			if _texture != null:
				var atlas := AtlasTexture.new()
				atlas.atlas = _texture
				var tw: int = _texture.get_width() / SIZE_N
				var th: int = _texture.get_height() / SIZE_N
				var r: int = t / SIZE_N
				var c: int = t % SIZE_N
				atlas.region = Rect2(c * tw, r * th, tw, th)
				b.icon = atlas
				b.text = ""
			else:
				b.text = str(t + 1)

func _is_solved() -> bool:
	for i in range(_tiles.size()):
		if _tiles[i] != i:
			return false
	return true

func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		close()
