class_name BossAnchor extends Area2D
##
## BossAnchor — glowing pad in boss room. Player stands on it to channel capture.
## Burns out (active=false) after one use.
##

@export var anchor_id: String = ""
var active: bool = true
@onready var sprite: Sprite2D = $Sprite

func _ready() -> void:
	collision_layer = 0
	collision_mask = 2
	monitoring = true

func consume() -> void:
	active = false
	if sprite:
		sprite.modulate = Color(0.4, 0.4, 0.4, 0.6)

func refresh() -> void:
	active = true
	if sprite:
		sprite.modulate = Color(1, 1, 1, 1)
