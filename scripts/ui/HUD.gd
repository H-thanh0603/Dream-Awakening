extends CanvasLayer
##
## HUD — Top bar với objective + hint Notebook.
## GDD §18, IMPLEMENTATION_PLAN T2.14
##

@onready var objective_label: Label = $ObjectiveLabel

func _ready() -> void:
	NotebookManager.objective_changed.connect(_on_objective_changed)

func _on_objective_changed(text: String) -> void:
	objective_label.text = "➤ " + text if text != "" else ""
