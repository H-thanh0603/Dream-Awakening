class_name TilePuzzleChest extends Interactable
##
## TilePuzzleChest — rương có puzzle tranh trượt 3x3.
## Khi player E lần đầu, instantiate SlidingTilePuzzle UI và chờ signal solved.
##

signal opened

@export var puzzle_image: String = "res://assets/sprites/dream_mira/injured_cat.png"
@export var locked_sprite_path: NodePath
@export var open_sprite_path: NodePath

var _solved: bool = false
var _puzzle: SlidingTilePuzzle = null

func _ready() -> void:
	super._ready()
	prompt_text = "E - Mở rương (giải tranh)"

func _on_interact() -> void:
	if _solved:
		_show_already_open()
		return
	_open_puzzle()

func _open_puzzle() -> void:
	if _puzzle != null:
		return
	_puzzle = SlidingTilePuzzle.new()
	_puzzle.image_path = puzzle_image
	_puzzle.solved.connect(_on_solved)
	_puzzle.cancelled.connect(_on_cancelled)
	# Add to scene tree at root so it survives if rương biến mất
	var host: Node = get_tree().current_scene if get_tree().current_scene else self
	host.add_child(_puzzle)
	_puzzle.open()

func _on_solved() -> void:
	_solved = true
	enabled = true
	prompt_text = "E - Lấy phần thưởng"
	_swap_visual(true)
	opened.emit()
	# Tự huỷ UI
	if _puzzle and _puzzle.is_inside_tree():
		_puzzle.queue_free()
	_puzzle = null

func _on_cancelled() -> void:
	if _puzzle and _puzzle.is_inside_tree():
		_puzzle.queue_free()
	_puzzle = null

func _swap_visual(open: bool) -> void:
	var locked := get_node_or_null(locked_sprite_path)
	var opened_n := get_node_or_null(open_sprite_path)
	if locked: locked.visible = not open
	if opened_n: opened_n.visible = open

func _show_already_open() -> void:
	var p: Label = get_node_or_null("Prompt")
	if p:
		p.text = "Rương đã mở"
		await get_tree().create_timer(0.8).timeout
