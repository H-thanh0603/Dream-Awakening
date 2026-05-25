class_name Rotator extends Interactable
##
## Rotator — Interactable xoay node theo step.
##

signal rotated(new_angle: float)

@export var step_deg: float = 15.0
var current_angle: float = 0.0

func _on_interact() -> void:
	current_angle = fposmod(current_angle + step_deg, 360.0)
	rotation_degrees = current_angle
	AudioManager.play_sfx("interact")
	rotated.emit(current_angle)
