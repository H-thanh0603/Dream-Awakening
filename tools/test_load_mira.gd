extends SceneTree

func _initialize() -> void:
	print("=== TEST: load Mira scene ===")
	var s: PackedScene = load("res://scenes/dreams/Dream_Mira_MirrorRoom.tscn")
	if s == null:
		print("FAIL: Cannot load packed scene")
		quit(1)
		return
	var inst = s.instantiate()
	if inst == null:
		print("FAIL: Cannot instantiate")
		quit(1)
		return
	print("Instantiated root: ", inst.name, " type=", inst.get_class())
	# Print children sanity
	for ch in inst.get_children():
		print(" - ", ch.name, " (", ch.get_class(), ")")
	inst.queue_free()
	print("=== TEST: PASS ===")
	quit(0)
