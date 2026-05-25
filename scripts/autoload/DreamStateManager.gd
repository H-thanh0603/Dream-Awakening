extends Node
##
## DreamStateManager — track state mỗi NPC trong giấc mơ.
## Contract: GDD §C.7
## Phase 0: skeleton. Phase 2 T2.12 implement đầy đủ.
##

signal npc_state_changed(npc_id: String, old: String, new: String)

const STATES := ["LOCKED", "INTRODUCED", "DENY", "DISTURBED",
                 "CONFRONTING", "RITUAL_READY", "REALIZATION", "AWAKE_CHANGED"]

var _states: Dictionary = {}

func _ready() -> void:
	print("[DreamStateManager] ready")

func get_npc_state(npc_id: String) -> String:
	return _states.get(npc_id, "LOCKED")

func set_npc_state(npc_id: String, new_state: String) -> void:
	if not new_state in STATES:
		push_error("Unknown state: " + new_state)
		return
	var old: String = get_npc_state(npc_id)
	if old == new_state:
		return
	_states[npc_id] = new_state
	npc_state_changed.emit(npc_id, old, new_state)

func evaluate_state_for_npc(npc_id: String) -> void:
	# Phase 2 T2.12 sẽ implement logic auto-transition theo flag pattern.
	pass
