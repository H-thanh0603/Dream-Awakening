class_name PressurePlate extends Area2D
##
## PressurePlate — fires pressed signal when a PushBox or player is on it.
##

signal pressed(by_node: Node)
signal released(by_node: Node)

@export var requires_box: bool = true  # if true, only PushBox triggers
@export var plate_id: String = ""

var _on_plate: Array = []

func _ready() -> void:
	collision_layer = 0
	collision_mask = 1
	monitoring = true
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	add_to_group("pressure_plate")

func _on_body_entered(body: Node) -> void:
	if requires_box and not body.is_in_group("pushbox"):
		return
	if not body in _on_plate:
		_on_plate.append(body)
		pressed.emit(body)
		_set_visual(true)

func _on_body_exited(body: Node) -> void:
	if body in _on_plate:
		_on_plate.erase(body)
		released.emit(body)
		if _on_plate.is_empty():
			_set_visual(false)

func is_pressed() -> bool:
	return _on_plate.size() > 0

func set_pressed(_v: bool, _by) -> void:
	# called from PushBox.call_deferred (alt path)
	pass

func _set_visual(active: bool) -> void:
	var s: Sprite2D = get_node_or_null("Sprite")
	if s == null:
		return
	var tex_path: String = "res://assets/sprites/dream_mira/anchor_active.png" if active else "res://assets/sprites/dream_mira/anchor_inactive.png"
	if ResourceLoader.exists(tex_path):
		s.texture = load(tex_path)
