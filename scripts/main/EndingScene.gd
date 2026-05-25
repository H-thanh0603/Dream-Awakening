extends Node2D
##
## EndingScene — phát khi cả 4 NPC đã realized.
## GDD §4.6, IMPLEMENTATION_PLAN T5.1
##

func _ready() -> void:
	GameState.set_state("DIALOGUE_ACTIVE")
	await get_tree().create_timer(1.0).timeout
	DialogueManager.play("ending_finale")
	DialogueManager.dialogue_ended.connect(_on_done)

func _on_done(_id: String) -> void:
	await get_tree().create_timer(2.0).timeout
	SceneLoader.fade_to("res://scenes/main/MainMenu.tscn", 2.0)
