extends SceneTree

var inv: Node
var dlg: Node
var gs: Node

func _initialize() -> void:
	root.call_deferred("_dummy")
	await process_frame
	inv = root.get_node("InventoryManager")
	dlg = root.get_node("DialogueManager")
	gs  = root.get_node("GameState")

	print("=== Full Mira smoke test (MVP-2/3) ===")
	var s: PackedScene = load("res://scenes/dreams/Dream_Mira_MirrorRoom.tscn")
	var inst := s.instantiate()
	root.add_child(inst)
	await process_frame; await process_frame
	print("scene loaded")

	inv.add_item("mirror_real")
	gs.set_flag("mira_library_history_done", true)
	gs.set_flag("mira_library_lit_done", true)
	gs.set_flag("mira_library_diary_done", true)

	print("library: reveal painting")
	var painting = inst.get_node("Library/MiraSmilePainting")
	painting._on_interact()
	await process_frame
	print("  revealed flag:", gs.has_flag("mira_library_portrait_revealed"))

	print("library: open code box")
	var box = inst.get_node("Library/CodeBox")
	box._on_interact()
	await process_frame
	print("  drained dialogues...")
	var max_iter := 50
	while dlg.is_active() and max_iter > 0:
		dlg.next()
		max_iter -= 1
	await process_frame
	print("  has dried_flower:", inv.has_item("dried_flower"))
	if not inv.has_item("dried_flower"):
		print("FAIL"); quit(1); return

	print("garden: water in correct order")
	for pname in ["PlotCircle", "PlotSquare", "PlotRectangle", "PlotTriangle"]:
		var p = inst.get_node("Garden/" + pname)
		print("  watering", pname)
		p._on_interact()
		await process_frame
	print("  drain dialogues...")
	max_iter = 50
	while dlg.is_active() and max_iter > 0:
		dlg.next()
		max_iter -= 1
	await process_frame
	print("  has balanced_flower:", inv.has_item("balanced_flower"))
	if not inv.has_item("balanced_flower"):
		print("FAIL"); quit(1); return

	print("studio: bypass")
	# Studio test: skip UI by setting puzzle done state directly
	var easel = inst.get_node("Studio/Easel")
	# Without UI, inject the picked array and call _on_finish.
	# But _on_finish reads dialogue. Let's test fail path first.
	var picks: Array[String] = ["smile", "tear", "flower", "crack", "help_hand", "ask_hand"]
	easel._picked = picks
	# DON'T open UI — _on_finish only needs _ui != null for _show_msg / _uncheck_all
	# but those branches are only on failure. For success path, _close() needs _ui to free.
	# So we DO need _ui. Build minimal one:
	easel._open_ui()
	await process_frame
	print("  ui open, calling _on_finish")
	easel._on_finish()
	await process_frame
	print("  drain dialogues...")
	max_iter = 50
	while dlg.is_active() and max_iter > 0:
		dlg.next()
		max_iter -= 1
	await process_frame
	print("  has true_portrait:", inv.has_item("true_portrait"))
	if not inv.has_item("true_portrait"):
		print("FAIL"); quit(1); return

	print("=== Full Mira smoke test PASSED ===")
	quit(0)

func _dummy() -> void: pass
