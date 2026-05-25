class_name PickupItem extends Interactable
##
## PickupItem — Interactable cho item nhặt được vào inventory.
##

@export var item_id: String = ""
@export var consumed_on_pickup: bool = true

func _on_interact() -> void:
	if item_id == "":
		return
	if InventoryManager.add_item(item_id):
		AudioManager.play_sfx("interact")
		if consumed_on_pickup:
			queue_free()
