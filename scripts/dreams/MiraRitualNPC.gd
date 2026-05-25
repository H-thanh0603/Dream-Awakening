class_name MiraRitualNPC extends Interactable
##
## MiraRitualNPC — tương tác với Mira trong Nghi Thức.
## Theo cycle:
##   - Lần 1: yêu cầu dẫn đến Gương Thật (set following)
##   - Khi gần Gương Thật + có ritual_mirror_placed: tiếp tục
##   - Mỗi lần E khi đủ điều kiện sẽ gọi `level.try_shatter_mask()`
##

@export var follower_path: NodePath
@export var level_path: NodePath
@export var mirror_anchor_path: NodePath

var _phase: int = 0    ## 0 = chưa nói chuyện, 1 = đang theo, 2 = đã đến gương
var _follower: MiraFollower
var _level: Node

func _ready() -> void:
	super._ready()
	prompt_text = "E - Nói chuyện với Mira"
	_follower = get_node_or_null(follower_path) as MiraFollower
	_level = get_node_or_null(level_path)

func _on_interact() -> void:
	match _phase:
		0:
			_register_dialog("mira_ritual_phase0", [
				{"speaker": "Mira", "text": "Bạn muốn... tôi đi đâu? Mặt nạ này không tháo được."},
				{"speaker": "Người dịch", "text": "Hãy đi với tôi đến Gương Thật. Em phải tự nhìn em — không qua mặt nạ nữa."}
			])
			DialogueManager.play("mira_ritual_phase0")
			if _follower:
				_follower.start_following()
			_phase = 1
		1:
			# Nếu Mira (follower) đủ gần điểm anchor gương → tiến phase
			var anchor := get_node_or_null(mirror_anchor_path) as Node2D
			var ref_pos: Vector2 = global_position
			if _follower:
				ref_pos = _follower.global_position
			if anchor and ref_pos.distance_to(anchor.global_position) < 48.0:
				if _follower: _follower.stop_following()
				_register_dialog("mira_ritual_phase1", [
					{"speaker": "Mira", "text": "Tôi sợ. Tôi không muốn nhìn."},
					{"speaker": "Người dịch", "text": "Đặt Mảnh phản chiếu trước em. Hãy để em bé Mira đứng cạnh em."}
				])
				DialogueManager.play("mira_ritual_phase1")
				_phase = 2
			else:
				_register_dialog("mira_ritual_too_far", [
					{"speaker": "Mira", "text": "Còn xa Gương Thật. Hãy đi tiếp."}
				])
				DialogueManager.play("mira_ritual_too_far")
		_:
			# Đã đến phase shatter — uỷ quyền cho level
			if _level and _level.has_method("try_shatter_mask"):
				_level.try_shatter_mask()

func _register_dialog(id: String, lines: Array) -> void:
	if not DialogueManager._dialogues.has(id):
		DialogueManager.register_from_dict({"id": id, "lines": lines})
