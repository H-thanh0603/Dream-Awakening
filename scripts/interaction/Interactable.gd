class_name Interactable extends Area2D
##
## Interactable — base class cho NPC/PickupItem/Door/PlaceSlot/Rotator/...
## GDD §C, IMPLEMENTATION_PLAN T1.5
##

signal interacted(by_node: Node)

@export var prompt_text: String = "E"
@export var enabled: bool = true

var _player_in_range: bool = false

func _ready() -> void:
	# Layer 4 = interactables, mask layer 2 = player
	collision_layer = 4
	collision_mask = 2
	monitoring = true
	monitorable = true
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	_hide_prompt()

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player") and enabled:
		_player_in_range = true
		_show_prompt()

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		_player_in_range = false
		_hide_prompt()

func _process(_delta: float) -> void:
	if not _player_in_range or not enabled:
		return
	if not Input.is_action_just_pressed("interact"):
		return
	# Don't trigger during dialogue/pause/ritual
	if GameState.current_state in ["DIALOGUE_ACTIVE", "PAUSED", "RITUAL_READY"]:
		return
	_hide_prompt()
	interacted.emit(self)
	_on_interact()

func _show_prompt() -> void:
	var p = get_node_or_null("Prompt")
	if p:
		p.visible = true
		if "text" in p:
			p.text = prompt_text

func _hide_prompt() -> void:
	var p = get_node_or_null("Prompt")
	if p:
		p.visible = false

# Subclass override
func _on_interact() -> void:
	pass
