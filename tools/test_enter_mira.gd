extends SceneTree

func _initialize() -> void:
	print("=== TEST: Enter Mira level ===")
	var s: PackedScene = load("res://scenes/dreams/Dream_Mira_MirrorRoom.tscn")
	var inst := s.instantiate()
	root.add_child(inst)
	# Tick a few frames so _ready async signals settle
	await process_frame
	await process_frame
	await process_frame
	# Sanity: did level controller get its onready refs?
	var step_label = inst.get_node_or_null("HintHUD/StepBox/StepLabel")
	if step_label and "text" in step_label:
		print("StepLabel text =", step_label.text)
	# Check a few wired signals exist
	var slot_mirror = inst.get_node_or_null("CentralRoom/CentralDoor/SlotMirror")
	print("SlotMirror node:", slot_mirror)
	var stuck_switch = inst.get_node_or_null("MirrorRoom/StuckSwitch")
	print("StuckSwitch node:", stuck_switch)
	var mira_follower = inst.get_node_or_null("Ritual/Mira")
	print("MiraFollower node:", mira_follower)
	var mira_talk = inst.get_node_or_null("Ritual/Mira/MiraTalk")
	print("MiraTalk node:", mira_talk)
	print("=== TEST: DONE ===")
	quit(0)
