class_name MiraSavePoint extends Area2D
##
## MiraSavePoint — touching it stores player position for collapse-restore.
##

signal activated(point: MiraSavePoint)

@export var point_id: String = ""
var _used: bool = false

func _ready() -> void:
	collision_layer = 0
	collision_mask = 2
	monitoring = true
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player") and not _used:
		_used = true
		activated.emit(self)
		var lbl: Label = get_node_or_null("Label")
		if lbl:
			lbl.text = "✓ Đã ghi nhớ"
			lbl.modulate = Color(0.7, 1.0, 0.7, 1.0)
		LucidityManager.recover(30.0)
