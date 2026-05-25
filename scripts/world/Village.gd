extends Node2D
##
## Village.gd — orchestrate 4 NPC state, dream portals, and unlock chain.
##

const PORTAL_POSITIONS := {
	"mira":  Vector2(120, 140),  # near Mira's house
	"theo":  Vector2(360, 140),
	"rell":  Vector2(120, 220),
	"lina":  Vector2(360, 220),
}

const DREAM_SCENES := {
	"mira": "res://scenes/dreams/Dream_Mira_MirrorRoom.tscn",
	"theo": "res://scenes/dreams/Dream_Theo_EndlessClass.tscn",
	"rell": "res://scenes/dreams/Dream_Rell_ClockTower.tscn",
	"lina": "res://scenes/dreams/Dream_Lina_DoorlessRoom.tscn",
}

func _ready() -> void:
	GameState.set_state("EXPLORE_VILLAGE")
	GameState.set_case("")
	$Player.position = Vector2(240, 200)
	_update_objective()
	DreamStateManager.npc_state_changed.connect(_on_state_changed)
	GameState.flag_changed.connect(_on_flag_changed)
	_apply_npc_state()
	_check_dream_portal()
	SaveManager.save_game()

func _update_objective() -> void:
	if not GameState.has_flag("mira_realized"):
		NotebookManager.set_objective("Tìm hiểu Mira ở căn nhà phía bắc.")
	elif not GameState.has_flag("theo_realized"):
		NotebookManager.set_objective("Theo cũng cần giúp. Hãy gặp cậu.")
	elif not GameState.has_flag("rell_realized"):
		NotebookManager.set_objective("Bác Rell ở góc làng. Tìm bác.")
	elif not GameState.has_flag("lina_realized"):
		NotebookManager.set_objective("Còn Lina nữa. Cô ấy đang đợi.")
	else:
		NotebookManager.set_objective("Bốn người đã tỉnh. Làng đang đổi mới.")

func _on_flag_changed(name: String, _val: bool) -> void:
	_check_dream_portal()
	if name in ["mira_realized", "theo_realized", "rell_realized", "lina_realized"]:
		_update_objective()
		_check_ending()

func _on_state_changed(_npc_id: String, _old: String, _new: String) -> void:
	_apply_npc_state()
	_check_dream_portal()

func _check_dream_portal() -> void:
	var portal: Node = $DreamPortal if has_node("DreamPortal") else null
	if portal == null:
		return
	# Find which NPC needs help next
	var order := ["mira", "theo", "rell", "lina"]
	var active: String = ""
	for nid in order:
		var offered := GameState.has_flag("%s_dream_offered" % nid)
		var realized := GameState.has_flag("%s_realized" % nid)
		if offered and not realized:
			active = nid
			break
	if active == "":
		portal.visible = false
		portal.enabled = false
		return
	portal.visible = true
	portal.enabled = true
	portal.position = PORTAL_POSITIONS[active]
	portal.target_scene = DREAM_SCENES[active]
	portal.prompt_text = "E - Vào giấc mơ %s" % active.capitalize()
	var lbl: Label = portal.get_node_or_null("Label")
	if lbl:
		lbl.text = "Cửa Mộng — %s" % active.capitalize()

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
			npc.modulate = Color(1.1, 1.1, 1.1, 1)
		else:
			npc.enabled = true
			npc.intro_dialogue_id = "%s_intro" % nid
			npc.modulate = Color(1, 1, 1, 1)

func _check_ending() -> void:
	if GameState.has_flag("ending_played"):
		return
	if GameState.has_all_flags(["mira_realized", "theo_realized", "rell_realized", "lina_realized"]):
		GameState.set_flag("ending_played", true)
		await get_tree().create_timer(2.0).timeout
		SceneLoader.fade_to("res://scenes/main/Ending.tscn", 2.0)
