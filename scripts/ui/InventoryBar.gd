extends CanvasLayer
##
## InventoryBar — UI hiển thị 8 slot inventory + active item label.
## GDD §C.6, IMPLEMENTATION_PLAN T2.3
##

const SLOT_SIZE := Vector2(20, 20)

@onready var hbox: HBoxContainer = $HBox
@onready var active_label: Label = $ActiveLabel

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	InventoryManager.item_added.connect(_refresh)
	InventoryManager.item_removed.connect(_refresh)
	InventoryManager.active_item_changed.connect(_on_active_changed)
	for i in InventoryManager.MAX_SLOTS:
		var slot := ColorRect.new()
		slot.custom_minimum_size = SLOT_SIZE
		slot.color = Color(0.15, 0.15, 0.2, 0.7)
		hbox.add_child(slot)

func _refresh(_item_id: String = "") -> void:
	var items: Array = InventoryManager.get_all_items()
	for i in InventoryManager.MAX_SLOTS:
		var slot: ColorRect = hbox.get_child(i)
		if i < items.size():
			slot.color = Color(0.7, 0.6, 0.3, 1)
		else:
			slot.color = Color(0.15, 0.15, 0.2, 0.7)

func _on_active_changed(_old: String, new_id: String) -> void:
	if new_id == "":
		active_label.text = ""
	else:
		active_label.text = "▶ " + new_id
	_refresh()
