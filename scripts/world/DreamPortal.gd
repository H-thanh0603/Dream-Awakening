class_name DreamPortal extends Interactable
##
## DreamPortal — Cửa Mộng. Khi player nhấn E gần đây, fade vào dream scene.
##

@export var target_scene: String = ""

var _t: float = 0.0

func _ready() -> void:
	super()
	monitoring = true
	monitorable = true

func _process(delta: float) -> void:
	super(delta)
	if not visible:
		return
	_t += delta
	var pulse: float = 0.65 + 0.35 * abs(sin(_t * 2.5))
	var glow: ColorRect = get_node_or_null("GlowSprite")
	if glow:
		glow.modulate = Color(pulse, pulse * 0.85, 1.0, pulse)

func _on_interact() -> void:
	if target_scene == "":
		push_warning("DreamPortal: target_scene empty")
		return
	GameState.set_state("ENTER_DREAM")
	SceneLoader.fade_to(target_scene, 1.2)
