extends Node2D
##
## Boot — entry point. Mount persistent UI rồi chuyển sang MainMenu.
##

func _ready() -> void:
	print("[Boot] starting...")
	var ui_scenes := [
		"res://scenes/ui/DialogueBox.tscn",
		"res://scenes/ui/PauseMenu.tscn",
		"res://scenes/ui/Notebook.tscn",
		"res://scenes/ui/InventoryBar.tscn",
		"res://scenes/ui/HUD.tscn"
	]
	for s in ui_scenes:
		var packed: PackedScene = load(s)
		if packed == null:
			push_error("[Boot] cannot load " + s)
			continue
		var inst: Node = packed.instantiate()
		get_tree().root.call_deferred("add_child", inst)
	await get_tree().process_frame
	await get_tree().process_frame
	print("[Boot] UI mounted, going to MainMenu")
	SceneLoader.fade_to("res://scenes/main/MainMenu.tscn", 0.4)
