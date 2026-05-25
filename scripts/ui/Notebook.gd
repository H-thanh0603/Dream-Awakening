extends CanvasLayer
##
## Notebook UI — 5 tab hiển thị nội dung từ NotebookManager.
## GDD §17, §C.5, IMPLEMENTATION_PLAN T2.2
##

@onready var tabs: TabContainer = $TabContainer

const TAB_BY_CATEGORY := {
	"OBJECTIVE": "Mục tiêu",
	"SYMBOL": "Biểu tượng",
	"MEMORY": "Ký ức",
	"NPC_STATE": "Trạng thái",
	"HINT": "Gợi ý"
}

func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	NotebookManager.entry_added.connect(_on_entry_added)
	NotebookManager.objective_changed.connect(_on_objective_changed)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("notebook"):
		toggle()
	elif visible and event.is_action_pressed("cancel"):
		toggle()

func toggle() -> void:
	visible = not visible
	get_tree().paused = visible
	if visible:
		_refresh_all()

func _refresh_all() -> void:
	for cat in TAB_BY_CATEGORY:
		_refresh_tab(cat)

func _refresh_tab(category: String) -> void:
	var tab_name: String = TAB_BY_CATEGORY.get(category, "")
	if tab_name == "":
		return
	var lst: ItemList = tabs.get_node_or_null(tab_name)
	if lst == null:
		return
	lst.clear()
	if category == "OBJECTIVE":
		var obj: String = NotebookManager.get_objective()
		if obj != "":
			lst.add_item("➤ " + obj)
		return
	var entries: Dictionary = NotebookManager.get_entries(category)
	for entry_id in entries:
		var data: Dictionary = entries[entry_id]
		var title: String = data.get("title_vi", entry_id)
		var desc: String = data.get("description_vi", "")
		var line: String = title
		if desc != "":
			line += " — " + desc
		lst.add_item(line)

func _on_entry_added(category: String, _entry_id: String) -> void:
	if visible:
		_refresh_tab(category)

func _on_objective_changed(_text: String) -> void:
	if visible:
		_refresh_tab("OBJECTIVE")
