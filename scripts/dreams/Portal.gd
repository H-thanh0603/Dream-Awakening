class_name Portal extends Interactable
##
## Portal — tương tác để teleport player tới vị trí khác trong scene.
## Có thể bị khoá bằng required_flag.
##

@export var target_position: Vector2 = Vector2.ZERO
@export var required_flag: String = ""
@export var locked_prompt: String = "Cánh cổng đang khoá"
@export var open_prompt: String = "E - Bước qua"
@export var on_use_dialogue: String = ""

func _ready() -> void:
	super._ready()
	_refresh_prompt()
	GameState.flag_changed.connect(_on_flag_changed)

func _on_flag_changed(_n: String, _v: bool) -> void:
	_refresh_prompt()

func _refresh_prompt() -> void:
	if _is_unlocked():
		prompt_text = open_prompt
		var v = get_node_or_null("Visual")
		if v and "color" in v:
			v.color = Color(0.6, 0.85, 1, 1)
	else:
		prompt_text = locked_prompt
		var v = get_node_or_null("Visual")
		if v and "color" in v:
			v.color = Color(0.30, 0.30, 0.30, 1)

func _is_unlocked() -> bool:
	return required_flag == "" or GameState.has_flag(required_flag)

func _on_interact() -> void:
	if not _is_unlocked():
		_flash("Đang khoá")
		return
	# Find player and teleport
	var players := get_tree().get_nodes_in_group("player")
	if players.size() == 0:
		return
	var player: Node2D = players[0]
	player.global_position = target_position
	AudioManager.play_sfx("interact")
	if on_use_dialogue != "" and DialogueManager._dialogues.has(on_use_dialogue):
		DialogueManager.play(on_use_dialogue)

func _flash(msg: String) -> void:
	var p: Label = get_node_or_null("Prompt")
	if p == null: return
	var orig := p.text
	p.text = msg
	p.modulate = Color(1, 0.6, 0.6, 1)
	await get_tree().create_timer(0.8).timeout
	if p:
		p.text = orig
		p.modulate = Color(1, 0.95, 0.6, 1)
