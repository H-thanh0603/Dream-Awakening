extends Node

var dm: Node
var failures: Array[String] = []
var checks: int = 0

func _ready() -> void:
	print("\n=== MIRA PLAYTHROUGH TEST ===")
	var scn: PackedScene = load("res://scenes/dreams/Dream_Mira_MirrorRoom.tscn")
	dm = scn.instantiate()
	add_child(dm)
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	_run_test()

func _check(cond: bool, name: String) -> void:
	checks += 1
	print("  %s  %s" % ["PASS" if cond else "FAIL", name])
	if not cond:
		failures.append(name)

func _run_test() -> void:
	print("\n[STAGE 0] Boot state")
	_check(dm != null, "DreamMira instance exists")
	_check(dm.has_node("Player"), "Player exists")
	_check(dm.has_node("Room1/PlateA"), "PlateA exists")
	_check(dm.has_node("Room1/PlateB"), "PlateB exists")
	_check(dm.has_node("Room1/BoxA"), "BoxA exists")
	_check(dm.has_node("Room1/BoxB"), "BoxB exists")
	_check(dm.has_node("Doors/DoorR1R2"), "Door R1->R2 exists")
	_check(dm.has_node("Doors/DoorR2R3"), "Door R2->R3 exists")
	_check(dm.has_node("Doors/DoorR3R4"), "Door R3->R4 exists")
	_check(dm.has_node("Boss"), "Boss exists")
	_check(LucidityManager._enabled, "Lucidity enabled at start")
	_check(LucidityManager.lucidity == 100.0, "Lucidity starts 100")

	print("\n[STAGE 1] Room 1 — fake plates pressed + manual solve check")
	var plate_a = dm.get_node("Room1/PlateA")
	var plate_b = dm.get_node("Room1/PlateB")
	var box_a = dm.get_node("Room1/BoxA")
	var box_b = dm.get_node("Room1/BoxB")
	plate_a._on_plate.append(box_a)
	plate_b._on_plate.append(box_b)
	_check(plate_a.is_pressed(), "PlateA reports pressed when box added")
	_check(plate_b.is_pressed(), "PlateB reports pressed when box added")
	dm._check_room1_solved()
	_check(dm._room1_solved, "Room 1 marked solved")
	_check(GameState.has_flag("mira_room1_solved"), "Flag mira_room1_solved set")
	_check(not dm.get_node("Doors/DoorR1R2").visible, "Door R1->R2 visible=false (open)")

	print("\n[STAGE 2] Room 2 — pick up 4 memories")
	var memories = dm.get_node("Room2/Memories").get_children()
	_check(memories.size() == 4, "4 memories present (got %d)" % memories.size())
	for mem in memories:
		dm._on_memory_picked(null, mem)
	_check(dm._memory_count >= 4, "All 4 memories collected (count=%d)" % dm._memory_count)
	_check(GameState.has_flag("mira_room2_solved"), "Flag mira_room2_solved set")
	_check(not dm.get_node("Doors/DoorR2R3").visible, "Door R2->R3 open")

	print("\n[STAGE 3a] Room 3 — wrong order should reset")
	dm._on_essence_placed("light", "light")
	_check(dm._essence_order.is_empty(), "Wrong-order resets _essence_order")
	_check(not GameState.has_flag("mira_room3_solved"), "Room 3 NOT solved on wrong order")

	print("\n[STAGE 3b] Room 3 — correct order water->light->memory")
	dm._on_essence_placed("water", "water")
	dm._on_essence_placed("light", "light")
	dm._on_essence_placed("memory_essence", "memory_essence")
	_check(GameState.has_flag("mira_room3_solved"), "Flag mira_room3_solved set")
	_check(not dm.get_node("Doors/DoorR3R4").visible, "Door R3->R4 open")
	_check(dm.get_node("Room3/FlowerBloomed").visible, "Flower bloomed")

	print("\n[STAGE 4] Room 4 — boss confrontation")
	var boss = dm.get_node("Boss")
	var player = dm.get_node("Player")
	player.position = Vector2(720, 380)
	boss.start_fight(player)
	_check(boss._started, "Boss fight started")
	_check(boss.visible, "Boss visible")
	var anchors = dm.get_node("Room4/Anchors").get_children()
	_check(anchors.size() == 4, "4 boss anchors present (got %d)" % anchors.size())
	for i in range(4):
		var anc = anchors[i]
		player.global_position = anc.global_position
		boss.global_position = anc.global_position + Vector2(0, -10)
		boss._try_capture()
	# allow boss._win() async path — wait a few frames
	for j in range(10):
		await get_tree().process_frame
	_check(boss._captures >= 4, "Mask captured 4x (got %d)" % boss._captures)
	_check(GameState.has_flag("mira_realized"), "Flag mira_realized set")

	print("\n=== RESULT ===")
	print("Checks: %d  Failures: %d" % [checks, failures.size()])
	for f in failures:
		print("  -> %s" % f)
	print("ALL PASS" if failures.is_empty() else "FAILURES PRESENT")
	get_tree().quit(failures.size())
