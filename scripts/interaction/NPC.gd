class_name NPC extends Interactable
##
## NPC — Interactable trong Village/Dream. Trigger dialogue.
## GDD §C, IMPLEMENTATION_PLAN T1.9
##

@export var npc_id: String = ""           # mira | theo | rell | lina
@export var intro_dialogue_id: String = ""  # dialogue ID to play

func _on_interact() -> void:
	if intro_dialogue_id != "":
		DialogueManager.play(intro_dialogue_id)
	else:
		push_warning("NPC %s has no intro_dialogue_id" % npc_id)

# Override parent _show_prompt to display NPC name above
func _show_prompt() -> void:
	super()
	# Optional: show speaker name in prompt
