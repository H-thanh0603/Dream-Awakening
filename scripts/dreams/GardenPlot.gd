class_name GardenPlot extends Interactable
##
## GardenPlot — một luống hoa hình học. Khi tương tác → emit `watered`.
## Hiển thị diện tích trên label cho dễ tính.
##

signal watered

@export var shape_kind: String = "circle"   ## "circle" | "square" | "rectangle" | "triangle"
@export var area_label_text: String = "S = ?"
@export var emotion_label: String = ""
@export var wilted_path: NodePath
@export var bloomed_path: NodePath

var _watered: bool = false

func _ready() -> void:
	super._ready()
	prompt_text = "E - Tưới luống"

func _on_interact() -> void:
	if _watered:
		return
	_watered = true
	AudioManager.play_sfx("interact")
	_set_visual(true)
	watered.emit()

func reset_water() -> void:
	_watered = false
	_set_visual(false)

func _set_visual(bloom: bool) -> void:
	var w = get_node_or_null(wilted_path)
	var b = get_node_or_null(bloomed_path)
	if w and "visible" in w: w.visible = not bloom
	if b and "visible" in b: b.visible = bloom
