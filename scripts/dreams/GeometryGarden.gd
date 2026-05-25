class_name GeometryGarden extends Node2D
##
## GeometryGarden — quản lý 4 luống hoa hình học. Người chơi phải tưới theo
## thứ tự diện tích giảm dần: tròn (r=3) → vuông (a=5) → chữ nhật (6x4) → tam giác (8x3).
##
## Mỗi luống là Area2D với prompt "E - Tưới". Khi tưới sai thứ tự → reset + cảnh báo.
##

signal solved

@export var plot_paths: Array[NodePath] = []      ## Thứ tự định danh các luống (id-stable)
@export var correct_sequence: Array[int] = [0, 1, 2, 3]  ## index trong plot_paths theo đúng thứ tự
@export var reward_item: String = "balanced_flower"
@export var solved_dialogue: String = "mira_garden_solved"
@export var wrong_dialogue: String = "mira_garden_wrong"

var _plots: Array[Node] = []
var _watered_seq: Array[int] = []
var _solved: bool = false

func _ready() -> void:
	for path in plot_paths:
		var p = get_node_or_null(path)
		_plots.append(p)
		if p and p.has_signal("watered"):
			p.watered.connect(_on_plot_watered.bind(_plots.size() - 1))

func _on_plot_watered(idx: int) -> void:
	if _solved:
		return
	# Check correctness with current expected step
	var step: int = _watered_seq.size()
	if step >= correct_sequence.size():
		return
	var expected: int = correct_sequence[step]
	if idx != expected:
		# Sai → reset
		_register_inline_dialogue(wrong_dialogue, [
			{"speaker": "Vườn", "text": "'Cảm xúc không biến mất vì bị bỏ đói.'"},
			{"speaker": "Vườn", "text": "'Không phải bông đẹp được tưới trước.'"}
		])
		DialogueManager.play(wrong_dialogue)
		LucidityManager.damage(6.0)
		# Reset visual + state
		for p in _plots:
			if p and p.has_method("reset_water"):
				p.reset_water()
		_watered_seq.clear()
		return
	_watered_seq.append(idx)
	if _watered_seq.size() >= correct_sequence.size():
		_solved = true
		# Reward
		if reward_item != "":
			InventoryManager.add_item(reward_item)
		_register_inline_dialogue(solved_dialogue, [
			{"speaker": "", "text": "[Hoa cân bằng nở. Em đã hiểu — không thể chỉ nuôi phần đẹp.]"}
		])
		DialogueManager.play(solved_dialogue)
		GameState.set_flag("mira_garden_solved", true)
		solved.emit()

func _register_inline_dialogue(id: String, lines: Array) -> void:
	if not DialogueManager._dialogues.has(id):
		DialogueManager.register_from_dict({"id": id, "lines": lines})
