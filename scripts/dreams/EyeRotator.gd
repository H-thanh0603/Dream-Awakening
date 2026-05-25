class_name EyeRotator extends Interactable
##
## EyeRotator — biểu tượng con mắt 4 hướng. Mỗi lần E xoay 90°.
## Hướng: 0 = lên, 1 = phải, 2 = xuống, 3 = trái.
##

signal direction_changed(eye_id: String, dir_index: int)

@export var eye_id: String = "eye"
@export var initial_dir: int = 0  ## 0..3
## Sprite con mắt (con của node này).
@export var eye_sprite_path: NodePath = ^"Sprite"

var dir_index: int = 0

const DIR_NAMES := ["up", "right", "down", "left"]

func _ready() -> void:
	super._ready()
	prompt_text = "E - Xoay con mắt"
	dir_index = initial_dir
	_apply_visual()

func _on_interact() -> void:
	dir_index = (dir_index + 1) % 4
	_apply_visual()
	AudioManager.play_sfx("interact")
	direction_changed.emit(eye_id, dir_index)

func _apply_visual() -> void:
	var spr: Sprite2D = get_node_or_null(eye_sprite_path)
	if spr == null:
		return
	# Xoay sprite. Giả định texture mặc định nhìn lên.
	spr.rotation_degrees = dir_index * 90.0

func get_dir_name() -> String:
	return DIR_NAMES[dir_index]
