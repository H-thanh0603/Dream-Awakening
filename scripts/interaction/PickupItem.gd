class_name PickupItem extends Interactable
##
## PickupItem — Interactable cho item nhặt được vào inventory.
##

@export var item_id: String = ""
@export var consumed_on_pickup: bool = true
@export var add_to_inventory: bool = true  # false → chỉ emit signal, không vào kho

func _on_interact() -> void:
	if item_id == "":
		return
	if add_to_inventory:
		if not InventoryManager.add_item(item_id):
			return
	AudioManager.play_sfx("interact")
	if consumed_on_pickup:
		queue_free()
