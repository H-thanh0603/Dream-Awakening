extends Node
##
## DreamStateManager — track state mỗi NPC, auto transition theo flag pattern.
## GDD §C.7, §16, IMPLEMENTATION_PLAN T2.12
##

signal npc_state_changed(npc_id: String, old: String, new: String)

const STATES := ["LOCKED", "INTRODUCED", "DENY", "DISTURBED",
				 "CONFRONTING", "RITUAL_READY", "REALIZATION", "AWAKE_CHANGED"]

var _states: Dictionary = {}      # npc_id -> state
var _npc_data: Dictionary ={}# npc_id -> JSON data

func _ready() -> void:
	print("[DreamStateManager] ready")
	_npc_data = JsonLoader.load_dir("res://data/npcs")
	for nid in _npc_data:
		_states[nid] = "LOCKED"
	# Mira mở khoá ngay từ đầu (sau tutorial)
	if "mira" in _states:
		_states["mira"] = "INTRODUCED"
	GameState.flag_changed.connect(_on_flag_changed)
	print("[DreamStateManager] tracking %d NPCs" % _npc_data.size())

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
	print("[DreamStateManager] %s: %s → %s" % [npc_id, old, new_state])

func _on_flag_changed(_name: String, _val: bool) -> void:
	for nid in _npc_data:
		evaluate_state_for_npc(nid)
	# Special: mira_realized sets unlock_theo, etc.
	_handle_unlock_chain()

func evaluate_state_for_npc(npc_id: String) -> void:
	var data: Dictionary = _npc_data.get(npc_id, {})
	if data.is_empty():
		return
	var current: String = get_npc_state(npc_id)
	if current in ["LOCKED", "AWAKE_CHANGED"]:
		return
	var memories: Array = data.get("required_memories", [])
	var restored: int = 0
	for m in memories:
		var flag := "%s_memory_%s_restored" % [npc_id, str(m).replace(npc_id + "_", "")]
		if GameState.has_flag(flag):
			restored += 1
	var ritual_done: bool = GameState.has_flag("%s_realized" % npc_id)
	var new_state: String = current
	if ritual_done:
		new_state = "REALIZATION"
	elif restored >= memories.size() and memories.size() > 0:
		new_state = "CONFRONTING"
	elif restored >= 1:
		new_state = "DISTURBED"
	elif current == "INTRODUCED" and GameState.has_flag("%s_intro_done" % npc_id):
		new_state = "DENY"
	if new_state != current:
		set_npc_state(npc_id, new_state)

func _handle_unlock_chain() -> void:
	# After mira_realized → unlock theo
	if GameState.has_flag("mira_realized") and get_npc_state("theo") == "LOCKED":
		set_npc_state("theo", "INTRODUCED")
		GameState.set_flag("theo_unlocked", true)
	if GameState.has_flag("theo_realized") and get_npc_state("rell") == "LOCKED":
		set_npc_state("rell", "INTRODUCED")
		GameState.set_flag("rell_unlocked", true)
	if GameState.has_flag("rell_realized") and get_npc_state("lina") == "LOCKED":
		set_npc_state("lina", "INTRODUCED")
		GameState.set_flag("lina_unlocked", true)
