class_name StuckSwitch extends Interactable
##
## StuckSwitch — công tắc đèn bị kẹt. Cần item `hairpin` (hoặc tuỳ chỉnh)
## để gạt mảnh kim loại ra. Khi mở khoá, phát signal `unstuck` và bật đèn.
##

signal unstuck(switch_id: String)

@export var switch_id: String = "switch_main"
@export var required_item: String = "hairpin"
@export var unstuck_prompt: String = "E - Bật đèn"
@export var stuck_prompt: String = "Công tắc bị kẹt — cần thứ gì đó mỏng"
@export var consume_item: bool = true
## Đường tới Light2D / CanvasModulate sẽ được tween khi unstuck.
@export var light_target_path: NodePath
@export var light_target_energy: float = 1.0
## Sprite đèn (nếu có) sẽ được đổi visual.
@export var lamp_off_path: NodePath
@export var lamp_on_path: NodePath

var _is_stuck: bool = true
var _is_on: bool = false

func _ready() -> void:
	super._ready()
	prompt_text = stuck_prompt

func _on_interact() -> void:
	if _is_stuck:
		if InventoryManager.has_item(required_item):
			_unstick()
		else:
			_show_need_item()
		return
	# Đã tháo kẹt → toggle đèn
	_toggle_light()

func _unstick() -> void:
	_is_stuck = false
	if consume_item:
		InventoryManager.remove_item(required_item)
	prompt_text = unstuck_prompt
	AudioManager.play_sfx("interact")
	unstuck.emit(switch_id)
	# Bật đèn ngay
	_toggle_light()

func _toggle_light() -> void:
	_is_on = not _is_on
	# Visual đèn
	var off_node: Node2D = get_node_or_null(lamp_off_path)
	var on_node: Node2D = get_node_or_null(lamp_on_path)
	if off_node:
		off_node.visible = not _is_on
	if on_node:
		on_node.visible = _is_on
	# Tween light target
	var target = get_node_or_null(light_target_path)
	if target == null:
		return
	var tw := create_tween()
	tw.set_trans(Tween.TRANS_SINE)
	if "energy" in target:
		tw.tween_property(target, "energy", light_target_energy if _is_on else 0.0, 0.6)
	elif "color" in target:
		var dest := Color(1, 1, 1, 1) if _is_on else Color(0.2, 0.18, 0.28, 1)
		tw.tween_property(target, "color", dest, 0.6)

func _show_need_item() -> void:
	var p: Label = get_node_or_null("Prompt")
	if p == null:
		return
	var orig := p.text
	p.text = "Cần: %s" % required_item
	p.modulate = Color(1, 0.6, 0.6, 1)
	await get_tree().create_timer(1.2).timeout
	if p:
		p.text = orig
		p.modulate = Color(1, 0.95, 0.6, 1)
