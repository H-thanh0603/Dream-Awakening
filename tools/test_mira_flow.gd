extends SceneTree
##
## Smoke test cho Mira level — tự đặt vật phẩm, kiểm tra flag/visibility.
## Truy cập autoload qua root.get_node(...).
##

var inv: Node
var dlg: Node
var gs: Node

func _initialize() -> void:
	# Wait one frame so autoloads exist
	root.call_deferred("_dummy")
	await process_frame
	inv = root.get_node_or_null("InventoryManager")
	dlg = root.get_node_or_null("DialogueManager")
	gs  = root.get_node_or_null("GameState")
	if inv == null or dlg == null or gs == null:
		print("FAIL: autoloads not accessible (inv=", inv, ", dlg=", dlg, ", gs=", gs, ")")
		quit(1)
		return
	print("=== Mira flow smoke test ===")

	var s: PackedScene = load("res://scenes/dreams/Dream_Mira_MirrorRoom.tscn")
	var inst := s.instantiate()
	root.add_child(inst)
	await process_frame
	await process_frame

	# 1) Phòng Gương Vỡ — bật đèn
	inv.add_item("hairpin")
	var sw = inst.get_node("MirrorRoom/StuckSwitch")
	sw._on_interact()
	await process_frame
	if inv.has_item("hairpin"):
		print("FAIL: hairpin should be consumed"); quit(1); return
	if not inst.get_node("MirrorRoom/Pickups/Shard1Pickup").visible:
		print("FAIL: shard1 should be visible"); quit(1); return

	# Mở ngăn kéo
	inv.add_item("silver_key")
	inv.set_active_item("silver_key")
	inst.get_node("MirrorRoom/DrawerSlot")._on_interact()
	await process_frame
	if not inv.has_item("curtain_cord") or not inv.has_item("eye_paper"):
		print("FAIL: drawer reward missing"); quit(1); return

	# Mở rèm
	inv.set_active_item("curtain_cord")
	inst.get_node("MirrorRoom/CurtainSlot")._on_interact()
	await process_frame
	if not inst.get_node("MirrorRoom/Pickups/Shard2Pickup").visible:
		print("FAIL: shard2 not visible"); quit(1); return
	if not inst.get_node("MirrorRoom/TilePuzzleChest").enabled:
		print("FAIL: chest not enabled"); quit(1); return

	# Skip sliding: trigger _on_solved manually
	inst.get_node("MirrorRoom/TilePuzzleChest")._on_solved()
	await process_frame
	if not inst.get_node("MirrorRoom/Pickups/ChestShardPickup").visible:
		print("FAIL: shard3 not visible"); quit(1); return

	# Eye rotators
	var eyes := [
		inst.get_node("MirrorRoom/EyeRotators/E1"),
		inst.get_node("MirrorRoom/EyeRotators/E2"),
		inst.get_node("MirrorRoom/EyeRotators/E3"),
		inst.get_node("MirrorRoom/EyeRotators/E4"),
	]
	var targets := [0, 1, 2, 3]
	for i in range(4):
		while eyes[i].dir_index != targets[i]:
			eyes[i]._on_interact()
		await process_frame
	if not inst.get_node("MirrorRoom/Pickups/WallShardPickup").visible:
		print("FAIL: shard4 not visible"); quit(1); return

	# Ghép 4 mảnh
	for sid in ["mirror_shard_1", "mirror_shard_2", "mirror_shard_3", "mirror_shard_4"]:
		inv.add_item(sid)
	for slot_name in ["SlotN", "SlotE", "SlotS", "SlotW"]:
		inst.get_node("MirrorRoom/MirrorAssemble/" + slot_name)._on_interact()
		await process_frame
	if not gs.has_flag("mira_mirror_repaired"):
		print("FAIL: mirror not repaired"); quit(1); return
	# Drain dialogue (cinematic awarded mirror_real)
	while dlg.is_active():
		dlg.next()
	await process_frame
	if not inv.has_item("mirror_real"):
		print("FAIL: mirror_real missing"); quit(1); return

	# Đặt vào khe trung tâm 1
	inv.set_active_item("mirror_real")
	inst.get_node("CentralRoom/CentralDoor/SlotMirror")._on_interact()
	await process_frame
	if not gs.has_flag("mira_door_slot1"):
		print("FAIL: slot1 flag"); quit(1); return

	# 2) Hành Lang Mặt Nạ
	inst.get_node("MaskHall/ReflectionMirror")._on_interact()
	await process_frame
	while dlg.is_active(): dlg.next()
	await process_frame
	if not inst.get_node("MaskHall/HiddenMaskPickup").visible:
		print("FAIL: hidden mask should be visible"); quit(1); return

	for mid in ["mask_smile", "mask_quiet", "mask_obedient", "mask_tired", "mask_angry", "mask_fear"]:
		inv.add_item(mid)
	var assignments = [
		["MaskHall/Wall/Outer1", "mask_smile"],
		["MaskHall/Wall/Outer2", "mask_obedient"],
		["MaskHall/Wall/Outer3", "mask_quiet"],
		["MaskHall/Wall/Inner1", "mask_fear"],
		["MaskHall/Wall/Inner2", "mask_tired"],
		["MaskHall/Wall/Inner3", "mask_angry"],
	]
	for a in assignments:
		inv.set_active_item(a[1])
		inst.get_node(a[0])._on_interact()
		await process_frame
	if not gs.has_flag("mira_mask_arranged"):
		print("FAIL: mask_arranged"); quit(1); return
	while dlg.is_active(): dlg.next()
	await process_frame
	if not inst.get_node("MaskHall/MaskCrackedPickup").visible:
		print("FAIL: mask cracked not visible"); quit(1); return

	inst.get_node("MaskHall/MaskCrackedPickup")._on_interact()
	await process_frame
	inv.set_active_item("mask_cracked")
	inst.get_node("CentralRoom/CentralDoor/SlotMask")._on_interact()
	await process_frame
	if not gs.has_flag("mira_door_slot2"):
		print("FAIL: slot2 flag"); quit(1); return

	# 3) Ritual
	inst.get_node("MaskHall/MaskPerfectPickup")._on_interact()
	await process_frame
	# Sau khi placed slot trung tâm, mirror_real đã được trả lại tự động.
	if not inv.has_item("mirror_real"):
		print("FAIL: mirror_real should be returned after central slot")
		quit(1); return
	inv.set_active_item("mirror_real")
	inst.get_node("Ritual/RitualMirrorSlot")._on_interact()
	await process_frame
	if not gs.has_flag("mira_ritual_mirror_placed"):
		print("FAIL: ritual mirror placed"); quit(1); return
	if not inst.get_node("Ritual/MiraSmall").visible:
		print("FAIL: mira small visible"); quit(1); return

	inv.set_active_item("mask_perfect")
	inst.get_node("Ritual/RitualMaskFloor")._on_interact()
	await process_frame
	if not gs.has_flag("mira_mask_floor_placed"):
		print("FAIL: mask floor"); quit(1); return

	if not inst.can_shatter_mask():
		print("FAIL: can_shatter_mask false")
		print("  mira_mirror_repaired =", gs.has_flag("mira_mirror_repaired"))
		print("  mira_mask_arranged   =", gs.has_flag("mira_mask_arranged"))
		print("  mira_ritual_mirror_placed =", gs.has_flag("mira_ritual_mirror_placed"))
		print("  mira_mask_floor_placed    =", gs.has_flag("mira_mask_floor_placed"))
		quit(1); return

	print("=== Mira flow smoke test PASSED ===")
	quit(0)

func _dummy() -> void:
	pass
