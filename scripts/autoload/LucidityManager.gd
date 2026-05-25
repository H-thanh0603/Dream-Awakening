extends Node
##
## LucidityManager — Mira's lucidity meter (0..100).
## Drained by Whisper Shadows / negative thoughts.
## At 0: emit collapsed → reset to last save point.
##

signal lucidity_changed(value: float)
signal collapsed()

const MAX_LUCIDITY: float = 100.0

var lucidity: float = MAX_LUCIDITY
var _drain_sources: int = 0   # count of active drainers
var _drain_per_source: float = 6.0  # per second
var _enabled: bool = false

func _ready() -> void:
	print("[LucidityManager] ready")

func enable() -> void:
	_enabled = true
	lucidity = MAX_LUCIDITY
	_drain_sources = 0
	lucidity_changed.emit(lucidity)

func disable() -> void:
	_enabled = false
	lucidity = MAX_LUCIDITY
	_drain_sources = 0
	lucidity_changed.emit(lucidity)

func add_drain_source() -> void:
	_drain_sources += 1

func remove_drain_source() -> void:
	_drain_sources = max(0, _drain_sources - 1)

func recover(amount: float) -> void:
	lucidity = clamp(lucidity + amount, 0.0, MAX_LUCIDITY)
	lucidity_changed.emit(lucidity)

func damage(amount: float) -> void:
	if not _enabled:
		return
	lucidity = clamp(lucidity - amount, 0.0, MAX_LUCIDITY)
	lucidity_changed.emit(lucidity)
	if lucidity <= 0.0:
		collapsed.emit()

func _process(delta: float) -> void:
	if not _enabled or _drain_sources == 0:
		return
	damage(_drain_per_source * _drain_sources * delta)

func get_pct() -> float:
	return lucidity / MAX_LUCIDITY
