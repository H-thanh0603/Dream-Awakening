class_name PushBox extends StaticBody2D
##
## PushBox — sokoban-style box, snaps to grid.
## Player's PlayerController calls try_push(dir) on collision.
##

const TILE: int = 16

@export var pushable: bool = true
var _pushing: bool = false

func _ready() -> void:
	collision_layer = 1
	collision_mask = 1
	add_to_group("pushbox")
	# Snap to grid
	position = Vector2(round(position.x / TILE) * TILE, round(position.y / TILE) * TILE)

func try_push(dir: Vector2i) -> void:
	if not pushable or _pushing:
		return
	# Cast forward TILE px to see if blocked
	var new_pos: Vector2 = position + Vector2(dir) * TILE
	var space := get_world_2d().direct_space_state
	var query := PhysicsPointQueryParameters2D.new()
	query.position = new_pos
	query.collision_mask = 1
	query.exclude = [self]
	var hits := space.intersect_point(query, 4)
	for h in hits:
		if h.collider != self and h.collider is StaticBody2D:
			return  # blocked
	_pushing = true
	var tween := create_tween()
	tween.tween_property(self, "position", new_pos, 0.18)
	tween.tween_callback(_on_settled)
	# Notify pressure plates / triggers
	call_deferred("_check_pressure_plate_at", new_pos)

func _check_pressure_plate_at(pos: Vector2) -> void:
	for n in get_tree().get_nodes_in_group("pressure_plate"):
		if n.position.distance_to(pos) < 8.0 and n.has_method("set_pressed"):
			n.set_pressed(true, self)

func _on_settled() -> void:
	_pushing = false
