extends CanvasLayer
##
## LucidityHUD — top-left bar showing Mira's lucidity.
## Shows red vignette overlay when low.
##

@onready var bar: ColorRect = $BarBg/BarFill
@onready var label: Label = $BarBg/Label
@onready var vignette: ColorRect = $Vignette

func _ready() -> void:
	layer = 16
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	LucidityManager.lucidity_changed.connect(_on_changed)
	LucidityManager.collapsed.connect(_on_collapsed)

func _process(_delta: float) -> void:
	# Show only when LucidityManager active
	if visible != LucidityManager._enabled:
		visible = LucidityManager._enabled

func _on_changed(value: float) -> void:
	var pct: float = value / LucidityManager.MAX_LUCIDITY
	bar.size.x = max(0.0, pct * 80.0)
	label.text = "Tỉnh táo: %d%%" % int(pct * 100.0)
	# Vignette intensity
	var veil: float = 1.0 - pct
	vignette.color = Color(0.5, 0.0, 0.0, veil * 0.45)
	if pct < 0.3:
		label.modulate = Color(1.0, 0.4, 0.4, 1.0)
	else:
		label.modulate = Color(1.0, 0.95, 0.7, 1.0)

func _on_collapsed() -> void:
	label.text = "Tỉnh táo: 0% — Mira ngã trong mơ..."
	vignette.color = Color(0.7, 0.0, 0.0, 0.7)
