extends Node2D
##
## Village.gd — register intro dialogues for 4 NPCs.
## Phase 1: inline placeholder text. Phase 2 T2.10 sẽ chuyển sang load JSON.
##

func _ready() -> void:
	GameState.set_state("EXPLORE_VILLAGE")
	GameState.set_case("")
	_register_placeholder_dialogues()
	_apply_npc_state()

func _register_placeholder_dialogues() -> void:
	DialogueManager.register("mira_intro", [
		{"speaker": "Mira", "text": "Đừng nhìn em lâu quá... em không quen."},
		{"speaker": "Player", "text": "Dạo này em ngủ không ngon sao?"},
		{"speaker": "Mira", "text": "Trong mơ có rất nhiều gương. Gương nào cũng nói cùng một điều."}
	])
	DialogueManager.register("theo_intro", [
		{"speaker": "Theo", "text": "Tôi đang ôn bài. Tay tôi run."},
		{"speaker": "Theo", "text": "Cậu đến tìm tôi sau nhé."}
	])
	DialogueManager.register("rell_intro", [
		{"speaker": "Rell", "text": "Đồng hồ nào trong tiệm cũng dừng cùng một giờ. Lạ thật."}
	])
	DialogueManager.register("lina_intro", [
		{"speaker": "Lina", "text": "Mình ổn mà. Hôm nay đẹp trời quá nhỉ?"}
	])

func _apply_npc_state() -> void:
	# Phase 1: Mira luôn enabled, các NPC khác chờ flag từ Phase 3+
	for npc in $NPCs.get_children():
		var nid: String = npc.npc_id if "npc_id" in npc else ""
		if nid == "mira":
			npc.enabled = true
		else:
			# Theo unlocks after mira_realized, etc. Placeholder for now.
			var unlock_flag: String = "%s_unlocked" % nid
			npc.enabled = GameState.has_flag(unlock_flag)
