class_name BossTrigger extends Area2D
##
## BossTrigger — Area2D at room 4 entrance. When player enters, calls start_fight() on BossMask.
##

@export var boss_path: NodePath
var _fired: bool = false

func _ready() -> void:
	collision_layer = 0
	collision_mask = 2
	monitoring = true
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if _fired:
		return
	if not body.is_in_group("player"):
		return
	_fired = true
	var boss = get_node_or_null(boss_path)
	if boss and boss.has_method("start_fight"):
		boss.start_fight(body)
