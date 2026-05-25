class_name PushBlock extends StaticBody2D
##
## PushBlock — block đẩy được trong GridPushPuzzle.
## Tile size 16. Player có thể đẩy nếu hướng hợp lệ và ô trống.
##

const TILE := 16

signal moved(new_cell: Vector2i)

@export var block_id: String = ""

func get_cell() -> Vector2i:
	return Vector2i(round(position.x / TILE), round(position.y / TILE))

func try_push(direction: Vector2i) -> bool:
	if direction == Vector2i.ZERO:
		return false
	var cur := get_cell()
	var target := cur + direction
	# Check raycast for blockers
	var space := get_world_2d().direct_space_state
	var query := PhysicsRayQueryParameters2D.create(
		position, Vector2(target * TILE), 1, [self]
	)
	var result := space.intersect_ray(query)
	if result.size() > 0:
		return false
	position = Vector2(target * TILE)
	moved.emit(target)
	AudioManager.play_sfx("interact")
	return true
