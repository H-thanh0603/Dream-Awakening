extends Node2D
##
## Village.gd — orchestrate 4 NPC state, dialogues, and dream portals.
##

func _ready() -> void:
	GameState.set_state("EXPLORE_VILLAGE")
	GameState.set_case("")
	# Player spawn
	$Player.position = Vector2(240, 200)
	NotebookManager.set_objective("Tìm hiểu Mira ở căn nhà phía bắc.")
	# Connect NPC state changes
	DreamStateManager.npc_state_changed.connect(_on_state_changed)
	_apply_npc_state()
	# Auto-save on village entry
	SaveManager.save_game()

func _on_state_changed(_npc_id: String, _old: String, _new: String) -> void:
	_apply_npc_state()

func _apply_npc_state() -> void:
	for npc in $NPCs.get_children():
		var nid: String = npc.npc_id if "npc_id" in npc else ""
		if nid == "":
			continue
		var state: String = DreamStateManager.get_npc_state(nid)
		if state in ["LOCKED"]:
			npc.enabled = false
			npc.modulate = Color(0.3, 0.3, 0.3, 0.5)
		elif state in ["AWAKE_CHANGED"]:
			npc.enabled = true
			npc.intro_dialogue_id = "%s_after_wake" % nid
			# Tint slightly brighter
			npc.modulate = Color(1.1, 1.1, 1.1, 1)
		else:
			npc.enabled = true
			npc.intro_dialogue_id = "%s_intro" % nid
			npc.modulate = Color(1, 1, 1, 1)
