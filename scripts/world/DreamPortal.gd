class_name DreamPortal extends Interactable
##
## DreamPortal — Cửa Mộng. Khi player nhấn E gần đây, fade vào dream scene.
##

@export var target_scene: String = ""

func _on_interact() -> void:
	if target_scene == "":
		push_warning("DreamPortal: target_scene empty")
		return
	GameState.set_state("ENTER_DREAM")
	GameState.current_dream_id = "mira"
	SceneLoader.fade_to(target_scene, 1.2)
