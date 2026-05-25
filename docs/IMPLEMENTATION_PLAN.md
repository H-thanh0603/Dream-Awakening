# NGƯỜI DỊCH GIẤC MƠ — Implementation Plan

> **Companion file của GDD_V3_Clean.md.** GDD nói *làm CÁI GÌ*. Plan này nói *làm THẾ NÀO*, từng task 2-15 phút.

**Goal:** Triển khai prototype 30-60 phút chơi của "Người Dịch Giấc Mơ" trên Godot 4.3, target Windows x64.

**Architecture:** Top-down 2D pixel + 8 autoload manager + JSON-driven data + 5 puzzle component tái sử dụng. Mọi state qua `GameState`, mọi UI qua signal.

**Tech Stack:** Godot 4.3 stable, GDScript thuần, NotoSans Mono CJK font, Windows binary embed PCK.

**Tổng task:** 87 task chia 5 phase. Ước tính: 18-22 ngày làm việc full-time, 35-45 ngày part-time.

---

## CÁCH ĐỌC PLAN NÀY

Mỗi task có format:

```
### TaskID: Tên task
**Time:** ước tính phút | **Phase:** N | **Depends on:** TaskID khác

**Files:**
- Create: path/đến/file/mới.gd
- Modify: path/đến/file/cũ.tscn

**Step 1:** ...
**Step 2:** ...

**Verify:** Cách kiểm tra task xong
**Commit:** message git
```

**Nguyên tắc:**
- Mỗi task xong → 1 commit. Không gộp.
- Nếu task >15 phút → tách nhỏ hơn.
- Mỗi task có "Verify" cụ thể, đo được.
- Bám test scenario ở GDD §D — cứ task xong thì pass test tương ứng.

**Khi bị block:**
1. Dừng ngay, không patch tiếp.
2. Ghi ra Daily Log: "Block ở task X.Y vì lý do Z".
3. Đọc lại GDD §C (System Contracts) — đa số block do hiểu sai contract.
4. Nếu vẫn block sau 30 phút → hỏi anh Thanh, không tự ý mở rộng scope.

---

## PHASE 0 — SETUP MÔI TRƯỜNG (1 ngày)

> Mục tiêu: từ máy trống → có Godot, có project rỗng chạy được, có git repo.

### T0.1: Cài Godot 4.3 stable
**Time:** 10p | **Phase:** 0 | **Depends on:** —

**Files:** không.

**Step 1:** Tải Godot 4.3 stable (Standard, không .NET) từ <https://godotengine.org/download/archive/4.3-stable/>.
**Step 2:** Giải nén `Godot_v4.3-stable_win64.exe` vào `D:\tools\godot\`.
**Step 3:** Tạo shortcut Desktop trỏ đến exe.

**Verify:** Mở exe → hiện Project Manager.
**Commit:** không (chưa có repo).

---

### T0.2: Tạo project rỗng
**Time:** 10p | **Phase:** 0 | **Depends on:** T0.1

**Files:**
- Create: `D:\NguoiDichGiacMo\project.godot` (Godot tự sinh)

**Step 1:** Project Manager → New Project.
**Step 2:** Project Path: `D:\NguoiDichGiacMo`. Renderer: **Forward+** (default OK cho 2D pixel).
**Step 3:** Click Create & Edit.

**Verify:** Editor mở thành công, không lỗi import.
**Commit:** chưa.

---

### T0.3: Init git repo + .gitignore
**Time:** 5p | **Phase:** 0 | **Depends on:** T0.2

**Files:**
- Create: `D:\NguoiDichGiacMo\.gitignore`
- Create: `D:\NguoiDichGiacMo\README.md`

**Step 1:** Tạo `.gitignore`:
```
.godot/
.import/
*.tmp
build/
builds/
*.exe
*.pck
.DS_Store
Thumbs.db
```

**Step 2:** Tạo `README.md` ngắn:
```markdown
# Người Dịch Giấc Mơ
Game pixel 2D giải đố narrative, đồ án — Godot 4.3.

## Run
Mở `project.godot` bằng Godot 4.3.

## Build
Project → Export → Windows Desktop.
```

**Step 3:** Terminal:
```
cd /d D:\NguoiDichGiacMo
git init
git add .
git commit -m "chore: init project"
```

**Verify:** `git log` có 1 commit "chore: init project".
**Commit:** đã làm ở Step 3.

---

### T0.4: Cấu hình Project Settings (resolution, pixel)
**Time:** 10p | **Phase:** 0 | **Depends on:** T0.3

**Files:**
- Modify: `project.godot`

**Step 1:** Project → Project Settings → Display → Window:
- Viewport Width: 480
- Viewport Height: 270
- Window Width Override: 1440
- Window Height Override: 810
- Stretch → Mode: `viewport`
- Stretch → Aspect: `keep`

**Step 2:** Rendering → Textures → Default Texture Filter: `Nearest`.
**Step 3:** Rendering → 2D → Snap → Snap 2D Transforms To Pixel: `On`.
**Step 4:** Save & close settings.

**Verify:** Mở `project.godot` bằng Notepad → có dòng `viewport_width=480`, `viewport_height=270`.
**Commit:**
```
git add project.godot
git commit -m "chore: configure 480x270 pixel-perfect viewport"
```

---

### T0.5: Tạo folder structure theo §A.7
**Time:** 5p | **Phase:** 0 | **Depends on:** T0.4

**Files:** chỉ tạo folder rỗng.

**Step 1:** Trong File System dock của Godot, tạo các folder:
```
assets/{fonts,sprites,tilesets,audio/sfx,audio/music}
data/{npcs,dialogues,puzzles,dreams,memories}
scenes/{main,world,dreams,ui,cutscenes}
scripts/{autoload,player,interaction,puzzle,ritual,ui}
```

**Step 2:** Trong mỗi folder con, tạo file `.gdignore` rỗng (để Godot không scan import folder rỗng) — chỉ với folder `assets/sprites`, `assets/tilesets` lúc chưa có asset.

**Verify:** File System dock thấy đầy đủ tree.
**Commit:**
```
git add .
git commit -m "chore: create folder skeleton per GDD §A.7"
```

---

### T0.6: Add font NotoSans Mono CJK
**Time:** 10p | **Phase:** 0 | **Depends on:** T0.5

**Files:**
- Create: `assets/fonts/NotoSansMono_VN.ttf`
- Create: `assets/fonts/NotoSansMono_VN.tres` (FontFile resource)

**Step 1:** Tải `NotoSansMono-Regular.ttf` từ <https://fonts.google.com/noto/specimen/Noto+Sans+Mono>. Đổi tên thành `NotoSansMono_VN.ttf`. Copy vào `assets/fonts/`.
**Step 2:** Trong Godot, click vào font → Inspector → Import:
- Antialiasing: None
- Subpixel Positioning: Disabled
- Hinting: None
**Step 3:** Re-import.

**Verify:** Tạo Label test, set font = file vừa add, type "Em không muốn trốn nữa." → render đúng dấu.
**Commit:**
```
git add assets/fonts/
git commit -m "chore: add NotoSansMono font for Vietnamese"
```

---

### T0.7: Tạo Input Map theo §A.6
**Time:** 5p | **Phase:** 0 | **Depends on:** T0.4

**Files:**
- Modify: `project.godot`

**Step 1:** Project Settings → Input Map. Add các action:
- `move_up` ← W, Up arrow
- `move_down` ← S, Down arrow
- `move_left` ← A, Left arrow
- `move_right` ← D, Right arrow
- `interact` ← E, Space, Enter
- `notebook` ← Q, Tab
- `pause` ← Escape
- `cancel` ← Escape, Backspace

**Verify:** `project.godot` có section `[input]` với 8 action trên.
**Commit:**
```
git add project.godot
git commit -m "chore: add input map per GDD §A.6"
```

---

### T0.8: Tạo file template autoload (8 file rỗng)
**Time:** 10p | **Phase:** 0 | **Depends on:** T0.5

**Files:**
- Create: `scripts/autoload/GameState.gd`
- Create: `scripts/autoload/SceneLoader.gd`
- Create: `scripts/autoload/DialogueManager.gd`
- Create: `scripts/autoload/NotebookManager.gd`
- Create: `scripts/autoload/InventoryManager.gd`
- Create: `scripts/autoload/DreamStateManager.gd`
- Create: `scripts/autoload/SaveManager.gd`
- Create: `scripts/autoload/AudioManager.gd`

**Step 1:** Mỗi file là Node script rỗng:
```gdscript
extends Node

func _ready() -> void:
	print("[%s] ready" % name)
```

**Step 2:** Project Settings → Autoload, add từng file:
| Path | Node Name |
| - | - |
| `res://scripts/autoload/GameState.gd` | `GameState` |
| `res://scripts/autoload/SceneLoader.gd` | `SceneLoader` |
| `res://scripts/autoload/DialogueManager.gd` | `DialogueManager` |
| `res://scripts/autoload/NotebookManager.gd` | `NotebookManager` |
| `res://scripts/autoload/InventoryManager.gd` | `InventoryManager` |
| `res://scripts/autoload/DreamStateManager.gd` | `DreamStateManager` |
| `res://scripts/autoload/SaveManager.gd` | `SaveManager` |
| `res://scripts/autoload/AudioManager.gd` | `AudioManager` |

**Verify:** Run game (F5) — Output panel in 8 dòng "[GameState] ready", "[SceneLoader] ready", ...
**Commit:**
```
git add scripts/ project.godot
git commit -m "feat: skeleton 8 autoload managers"
```

---

### T0.9: Boot scene + Main Menu skeleton
**Time:** 15p | **Phase:** 0 | **Depends on:** T0.8

**Files:**
- Create: `scenes/main/Boot.tscn`
- Create: `scenes/main/MainMenu.tscn`
- Create: `scripts/ui/MainMenu.gd`

**Step 1:** Tạo `Boot.tscn`:
- Node: `Node2D` (root)
- Script gắn vào: gọi `SceneLoader.fade_to(...)` — nhưng vì SceneLoader chưa có method, tạm thời dùng `get_tree().change_scene_to_file("res://scenes/main/MainMenu.tscn")` trong `_ready()`.

**Step 2:** Tạo `MainMenu.tscn`:
- Root: `Control`
- Child: `Label` "Người Dịch Giấc Mơ"
- 3 Button: "Bắt đầu", "Tiếp tục", "Thoát"
- Set anchor center.

**Step 3:** Script `MainMenu.gd`:
```gdscript
extends Control

func _on_start_pressed() -> void:
	print("Start pressed (chưa có Village)")

func _on_continue_pressed() -> void:
	print("Continue pressed (chưa có save)")

func _on_quit_pressed() -> void:
	get_tree().quit()
```

**Step 4:** Set `Boot.tscn` làm Main Scene (Project Settings → Application → Run → Main Scene).

**Verify:** F5 → vào Boot → tự nhảy MainMenu → click Quit thoát game.
**Commit:**
```
git add scenes/ scripts/ project.godot
git commit -m "feat(M0.9): boot + main menu skeleton"
```

---

## PHASE 1 — KHUNG GAME PLAYABLE (3 ngày)

> Mục tiêu: chơi được Village với 4 NPC, dialogue hiện đúng, fade transition, pause OK.
> Điều kiện hoàn thành: tất cả test §D.2 (M1) pass.

### T1.1: GameState API tối thiểu (set_flag/get_flag/has_flag)
**Time:** 15p | **Phase:** 1 | **Depends on:** T0.8

**Files:**
- Modify: `scripts/autoload/GameState.gd`

**Step 1:** Test trước (manual). Tạo file `scripts/autoload/_test_gamestate.gd`:
```gdscript
extends SceneTree

func _init() -> void:
	GameState.set_flag("foo", true)
	assert(GameState.get_flag("foo") == true)
	assert(GameState.has_flag("foo") == true)
	assert(GameState.has_flag("bar") == false)
	print("✓ T1.1 tests pass")
	quit()
```

**Step 2:** Implement trong `GameState.gd`:
```gdscript
extends Node

signal flag_changed(flag_name: String, value: bool)

var flags: Dictionary = {}

func set_flag(name: String, value: bool = true) -> void:
	var old: bool = flags.get(name, false)
	flags[name] = value
	if old != value:
		flag_changed.emit(name, value)

func get_flag(name: String) -> bool:
	return flags.get(name, false)

func has_flag(name: String) -> bool:
	return flags.has(name) and flags[name]

func has_all_flags(names: Array) -> bool:
	for n in names:
		if not has_flag(n):
			return false
	return true

func has_any_flag(names: Array) -> bool:
	for n in names:
		if has_flag(n):
			return true
	return false

func clear_flag(name: String) -> void:
	if flags.has(name):
		flags.erase(name)
		flag_changed.emit(name, false)
```

**Step 3:** Run test: `godot --script scripts/autoload/_test_gamestate.gd --headless`. Expected: in `✓ T1.1 tests pass`.

**Verify:** Test pass, signal `flag_changed` emit khi set khác giá trị cũ.
**Commit:**
```
git add scripts/autoload/GameState.gd
git commit -m "feat(M1.1): GameState flag API + signal"
```

---

### T1.2: GameState boolean expression evaluator
**Time:** 15p | **Phase:** 1 | **Depends on:** T1.1

**Files:**
- Modify: `scripts/autoload/GameState.gd`

**Step 1:** Add method `evaluate(expr: String) -> bool`:
```gdscript
# Evaluate condition expression. Hỗ trợ:
#   "flag_a"           → has_flag("flag_a")
#   "!flag_a"          → not has_flag("flag_a")
#   "a && b && c"      → has_all_flags(...)
#   "a || b || c"      → has_any_flag(...)
# Không hỗ trợ ngoặc lồng (flat only).
func evaluate(expr: String) -> bool:
	if expr == null or expr.strip_edges() == "":
		return true
	expr = expr.strip_edges()

	# OR có ưu tiên thấp hơn AND — split OR trước
	if "||" in expr:
		for part in expr.split("||"):
			if evaluate(part.strip_edges()):
				return true
		return false

	if "&&" in expr:
		for part in expr.split("&&"):
			if not evaluate(part.strip_edges()):
				return false
		return true

	# Single token
	if expr.begins_with("!"):
		return not has_flag(expr.substr(1).strip_edges())
	return has_flag(expr)
```

**Step 2:** Bổ sung test case vào `_test_gamestate.gd`:
```gdscript
GameState.set_flag("a", true)
GameState.set_flag("b", false)
GameState.set_flag("c", true)
assert(GameState.evaluate("a && c") == true)
assert(GameState.evaluate("!b") == true)
assert(GameState.evaluate("a || b") == true)
assert(GameState.evaluate("b && c") == false)
assert(GameState.evaluate("") == true)
print("✓ T1.2 evaluate tests pass")
```

**Step 3:** Chạy test.

**Verify:** Match TEST_M2.1.3 ở GDD §D.3.
**Commit:**
```
git add scripts/autoload/GameState.gd scripts/autoload/_test_gamestate.gd
git commit -m "feat(M1.1): GameState.evaluate() boolean expr parser"
```

---

### T1.3: GameState state machine
**Time:** 10p | **Phase:** 1 | **Depends on:** T1.2

**Files:**
- Modify: `scripts/autoload/GameState.gd`

**Step 1:** Thêm:
```gdscript
signal state_changed(old_state: String, new_state: String)
signal case_changed(old_case: String, new_case: String)

const STATES := [
	"EXPLORE_VILLAGE", "ENTER_DREAM", "DREAM_EXPLORE",
	"PUZZLE_SOLVING", "MEMORY_REFLECTION", "RITUAL_READY",
	"WAKE_UP", "DIALOGUE_ACTIVE", "PAUSED"
]

var current_state: String = "EXPLORE_VILLAGE"
var current_case: String = ""
var current_dream_id: String = ""

func set_state(new_state: String) -> void:
	assert(new_state in STATES, "Unknown state: " + new_state)
	if current_state == new_state:
		return
	var old: String = current_state
	current_state = new_state
	state_changed.emit(old, new_state)

func set_case(new_case: String) -> void:
	if current_case == new_case:
		return
	var old: String = current_case
	current_case = new_case
	case_changed.emit(old, new_case)
```

**Verify:** Test trong `_test_gamestate.gd`:
```gdscript
var got_signal := false
GameState.state_changed.connect(func(o, n): got_signal = true)
GameState.set_state("PUZZLE_SOLVING")
assert(got_signal)
assert(GameState.current_state == "PUZZLE_SOLVING")
```

**Commit:**
```
git add scripts/autoload/GameState.gd scripts/autoload/_test_gamestate.gd
git commit -m "feat(M1.1): GameState state machine + case tracking"
```

---

### T1.4: PlayerController — di chuyển 4 hướng
**Time:** 15p | **Phase:** 1 | **Depends on:** T0.7

**Files:**
- Create: `scripts/player/PlayerController.gd`
- Create: `scenes/player/Player.tscn`

**Step 1:** Tạo `Player.tscn`:
- Root: `CharacterBody2D`
- Child: `Sprite2D` (placeholder ColorRect 12×16 vàng)
- Child: `CollisionShape2D` (RectangleShape2D 12×8, anchor chân)
- Gắn script `PlayerController.gd`

**Step 2:** `PlayerController.gd`:
```gdscript
extends CharacterBody2D

const SPEED := 80.0  # px/s

var facing: String = "down"  # "up" | "down" | "left" | "right"

func _physics_process(delta: float) -> void:
	if GameState.current_state in ["DIALOGUE_ACTIVE", "PAUSED"]:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	var input_vec := Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_up", "move_down")
	)
	if input_vec.length() > 1.0:
		input_vec = input_vec.normalized()

	velocity = input_vec * SPEED
	move_and_slide()

	# Update facing
	if abs(input_vec.x) > abs(input_vec.y):
		facing = "right" if input_vec.x > 0 else "left"
	elif abs(input_vec.y) > 0.01:
		facing = "down" if input_vec.y > 0 else "up"
```

**Verify:** Tạo TestRoom.tscn có Player + 4 tường — chạy, đi 4 hướng, không xuyên tường, diagonal không nhanh hơn.
**Commit:**
```
git add scripts/player/ scenes/player/
git commit -m "feat(M1.3): PlayerController 4-way movement"
```

---

### T1.5: Interactable base class
**Time:** 12p | **Phase:** 1 | **Depends on:** T1.4

**Files:**
- Create: `scripts/interaction/Interactable.gd`
- Create: `scenes/interaction/Interactable.tscn`

**Step 1:** `Interactable.gd`:
```gdscript
class_name Interactable extends Area2D

signal interacted(by_node: Node)

@export var prompt_text: String = "E để tương tác"
@export var enabled: bool = true

func _ready() -> void:
	collision_layer = 0
	collision_mask = 2  # layer "player"
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

var _player_in_range: bool = false

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player") and enabled:
		_player_in_range = true
		_show_prompt()

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		_player_in_range = false
		_hide_prompt()

func _process(_delta: float) -> void:
	if _player_in_range and enabled and Input.is_action_just_pressed("interact"):
		if GameState.current_state == "EXPLORE_VILLAGE" or GameState.current_state == "DREAM_EXPLORE":
			_hide_prompt()
			interacted.emit(get_tree().current_scene)
			_on_interact()

func _show_prompt() -> void:
	# placeholder — child node "Prompt" Label
	var p = get_node_or_null("Prompt")
	if p:
		p.visible = true
		p.text = prompt_text

func _hide_prompt() -> void:
	var p = get_node_or_null("Prompt")
	if p:
		p.visible = false

func _on_interact() -> void:
	pass  # subclass override
```

**Step 2:** `Interactable.tscn`:
- Root: `Area2D` (script Interactable.gd)
- Child: `CollisionShape2D` (RectangleShape2D 24×24)
- Child: `Label` name="Prompt", text="E", visible=false, position trên đầu

**Step 3:** Player thêm vào group "player": trong Player.tscn, Inspector → Node → Groups → add "player".

**Verify:** Test scene có Player + 1 Interactable. Đi gần → prompt hiện. Đi xa → prompt ẩn. Nhấn E → signal emit (print debug).
**Commit:**
```
git add scripts/interaction/ scenes/interaction/ scenes/player/
git commit -m "feat(M1.4): Interactable base class + prompt"
```

---

### T1.6: SceneLoader fade transition
**Time:** 15p | **Phase:** 1 | **Depends on:** T0.8

**Files:**
- Modify: `scripts/autoload/SceneLoader.gd`
- Create: `scenes/ui/FadeOverlay.tscn`

**Step 1:** `FadeOverlay.tscn`:
- Root: `CanvasLayer` (layer=128, top of all)
- Child: `ColorRect` full screen, color=black, modulate.a=0.

**Step 2:** `SceneLoader.gd`:
```gdscript
extends Node

signal scene_changed(old_path: String, new_path: String)

var _overlay: ColorRect

func _ready() -> void:
	var fade_scene := preload("res://scenes/ui/FadeOverlay.tscn").instantiate()
	get_tree().root.call_deferred("add_child", fade_scene)
	await get_tree().process_frame
	_overlay = fade_scene.get_node("ColorRect")

func fade_to(scene_path: String, duration: float = 0.5) -> void:
	var old: String = get_tree().current_scene.scene_file_path
	# fade out
	var t := create_tween()
	t.tween_property(_overlay, "modulate:a", 1.0, duration)
	await t.finished

	get_tree().change_scene_to_file(scene_path)
	await get_tree().process_frame

	# fade in
	t = create_tween()
	t.tween_property(_overlay, "modulate:a", 0.0, duration)
	await t.finished
	scene_changed.emit(old, scene_path)
```

**Verify:** Trong MainMenu, click Start → gọi `SceneLoader.fade_to("res://scenes/world/Village.tscn")` (Village tạm là scene rỗng) → fade đen → đổi scene → fade in.
**Commit:**
```
git add scripts/autoload/SceneLoader.gd scenes/ui/FadeOverlay.tscn
git commit -m "feat(M1.5): SceneLoader fade transition 0.5s"
```

---

### T1.7: DialogueBox UI scene
**Time:** 12p | **Phase:** 1 | **Depends on:** T0.6

**Files:**
- Create: `scenes/ui/DialogueBox.tscn`
- Create: `scripts/ui/DialogueBox.gd`

**Step 1:** `DialogueBox.tscn`:
- Root: `CanvasLayer` (layer=64)
- Child: `Panel` (anchor bottom, height 60 px)
- Sub: `Label` name="SpeakerName" (top-left, font 11px)
- Sub: `RichTextLabel` name="DialogueText" (font 12px)
- Sub: `Label` name="NextHint" text="▶" (bottom-right, blink)
- Set visible=false ban đầu, font = NotoSansMono_VN.

**Step 2:** `DialogueBox.gd`:
```gdscript
extends CanvasLayer

@onready var speaker: Label = $Panel/SpeakerName
@onready var dialogue_text: RichTextLabel = $Panel/DialogueText
@onready var next_hint: Label = $Panel/NextHint

const TYPE_SPEED := 0.025  # giây/ký tự

var _full_text: String = ""
var _is_typing: bool = false
var _typing_complete: bool = false

func _ready() -> void:
	visible = false
	DialogueManager.dialogue_started.connect(_on_dialogue_started)
	DialogueManager.dialogue_line_shown.connect(_on_line_shown)
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)

func _on_dialogue_started(_id: String) -> void:
	visible = true

func _on_line_shown(speaker_name: String, text: String) -> void:
	speaker.text = speaker_name
	_full_text = text
	dialogue_text.text = ""
	_is_typing = true
	_typing_complete = false
	next_hint.visible = false

	var i := 0
	while i < _full_text.length() and _is_typing:
		dialogue_text.text = _full_text.substr(0, i + 1)
		await get_tree().create_timer(TYPE_SPEED).timeout
		i += 1
	dialogue_text.text = _full_text
	_typing_complete = true
	next_hint.visible = true

func _on_dialogue_ended(_id: String) -> void:
	visible = false

func _input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("interact"):
		if not _typing_complete:
			# Skip typing
			_is_typing = false
		else:
			DialogueManager.next()
```

**Step 3:** Add `DialogueBox` autoload **hoặc** instantiate trong Boot scene (chọn 1 — em recommend instantiate trong Boot để dễ debug).

**Verify:** Sẽ test ở T1.9 sau khi có DialogueManager.
**Commit:**
```
git add scenes/ui/DialogueBox.tscn scripts/ui/DialogueBox.gd
git commit -m "feat(M1.6): DialogueBox UI with typing effect"
```

---

### T1.8: DialogueManager (đọc inline data, chưa cần JSON)
**Time:** 15p | **Phase:** 1 | **Depends on:** T1.7

**Files:**
- Modify: `scripts/autoload/DialogueManager.gd`

**Step 1:** Implement contract §C.4:
```gdscript
extends Node

signal dialogue_started(dialogue_id: String)
signal dialogue_line_shown(speaker: String, text: String)
signal dialogue_ended(dialogue_id: String)

var _queue: Array = []  # Array of {id, lines}
var _current_lines: Array = []
var _current_index: int = 0
var _current_id: String = ""
var _active: bool = false

# Inline dialogue store (M1 chỉ test, M2 sẽ load từ JSON)
var _inline_dialogues: Dictionary = {}

func register(dialogue_id: String, lines: Array) -> void:
	_inline_dialogues[dialogue_id] = lines

func play(dialogue_id: String) -> void:
	if not _inline_dialogues.has(dialogue_id):
		push_warning("Dialogue not found: " + dialogue_id)
		return
	if _active:
		_queue.append(dialogue_id)
		return
	_start(dialogue_id)

func _start(dialogue_id: String) -> void:
	_current_id = dialogue_id
	_current_lines = _inline_dialogues[dialogue_id].duplicate()
	_current_index = 0
	_active = true
	GameState.set_state("DIALOGUE_ACTIVE")
	dialogue_started.emit(dialogue_id)
	_show_current()

func _show_current() -> void:
	if _current_index >= _current_lines.size():
		_end()
		return
	var line: Dictionary = _current_lines[_current_index]
	# Skip nếu condition không match
	var cond: String = line.get("condition", "")
	if cond != "" and not GameState.evaluate(cond):
		_current_index += 1
		_show_current()
		return
	dialogue_line_shown.emit(line.get("speaker", ""), line.get("text", ""))

func next() -> void:
	if not _active:
		return
	_current_index += 1
	_show_current()

func cancel() -> void:
	if _active:
		_end()

func _end() -> void:
	var ended_id: String = _current_id
	_active = false
	_current_id = ""
	_current_lines.clear()
	GameState.set_state("EXPLORE_VILLAGE")  # tạm thời, M2 sẽ restore previous state
	dialogue_ended.emit(ended_id)
	if _queue.size() > 0:
		var next_id: String = _queue.pop_front()
		_start(next_id)

func is_active() -> bool:
	return _active
```

**Step 2:** Test scene `TestDialogue.tscn`:
- Add Player + Interactable + DialogueBox
- Script trên Interactable:
```gdscript
func _ready() -> void:
	DialogueManager.register("test1", [
		{"speaker": "Mira", "text": "Đừng nhìn em lâu quá... em không quen."},
		{"speaker": "Player", "text": "Dạo này em ngủ không ngon sao?"},
		{"speaker": "Mira", "text": "Trong mơ có rất nhiều gương."}
	])
	interacted.connect(func(_n): DialogueManager.play("test1"))
```

**Verify:** TEST_M1.6.1, TEST_M1.6.2, TEST_M1.6.3 (§D.2). 3 line tuần tự, skip typing OK, dấu tiếng Việt đúng.
**Commit:**
```
git add scripts/autoload/DialogueManager.gd
git commit -m "feat(M1.6): DialogueManager play/next/cancel + queue + condition skip"
```

---

### T1.9: Village scene placeholder + 4 NPC
**Time:** 20p | **Phase:** 1 | **Depends on:** T1.8

**Files:**
- Create: `scenes/world/Village.tscn`
- Create: `scripts/interaction/NPC.gd`

**Step 1:** `NPC.gd` extends Interactable:
```gdscript
class_name NPC extends Interactable

@export var npc_id: String = ""        # mira | theo | rell | lina
@export var intro_dialogue_id: String = ""

func _on_interact() -> void:
	if intro_dialogue_id != "":
		DialogueManager.play(intro_dialogue_id)
```

**Step 2:** `Village.tscn`:
- Root: `Node2D`
- Child: `TileMap` (placeholder — vẽ vài tile xám tạo hình ngôi làng đơn giản)
- Child: `Player` instance
- Child: 4 NPC instance (Sprite2D ColorRect đặt 4 vị trí khác nhau, mỗi cái script NPC.gd, npc_id khác nhau, intro_dialogue_id khác nhau)
- Camera2D follow Player với deadzone 32×32, lerp 0.15.

**Step 3:** Trong `_ready()` của Village hoặc 1 autoload nào đó, register intro dialogue cho 4 NPC (placeholder text).

**Verify:** Run từ MainMenu → click Start → fade vào Village. Đi quanh, gần NPC hiện prompt, nhấn E → dialogue chạy.
**Commit:**
```
git add scenes/world/ scripts/interaction/NPC.gd
git commit -m "feat(M1.7): Village scene + 4 NPC with intro dialogues"
```

---

### T1.10: PauseMenu (Esc)
**Time:** 12p | **Phase:** 1 | **Depends on:** T0.8

**Files:**
- Create: `scenes/ui/PauseMenu.tscn`
- Create: `scripts/ui/PauseMenu.gd`

**Step 1:** `PauseMenu.tscn`:
- Root: `CanvasLayer` (layer=96, process_mode=Always)
- Child: `Panel` semi-transparent fullscreen
- 3 Button: "Tiếp tục", "Lưu game" (placeholder M2), "Thoát"

**Step 2:** `PauseMenu.gd`:
```gdscript
extends CanvasLayer

func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		toggle()

func toggle() -> void:
	visible = not visible
	get_tree().paused = visible
	if visible:
		GameState.set_state("PAUSED")

func _on_resume_pressed() -> void:
	toggle()

func _on_quit_pressed() -> void:
	get_tree().quit()
```

**Step 3:** Instantiate PauseMenu trong Boot.tscn (làm autoload-style, không vào group, persistent).

**Verify:** TEST_M1.8.1 + M1.8.2 (§D.2).
**Commit:**
```
git add scenes/ui/PauseMenu.tscn scripts/ui/PauseMenu.gd
git commit -m "feat(M1.8): PauseMenu Esc toggle + resume/quit"
```

---

### T1.11: Smoke test Phase 1
**Time:** 15p | **Phase:** 1 | **Depends on:** T1.1-T1.10

**Files:** không tạo file mới, chỉ chạy & log.

**Step 1:** Mở `tests/manual_qa/M1_checklist.md`:
```markdown
# M1 Smoke Test
- [ ] Boot → MainMenu hiện
- [ ] Click Start → fade → Village
- [ ] Đi 4 hướng OK, không xuyên tường
- [ ] Diagonal không nhanh hơn
- [ ] Đứng cạnh NPC → prompt "E"
- [ ] Nhấn E → dialogue chạy đầy đủ 3 line
- [ ] Tiếng Việt có dấu hiển thị đúng
- [ ] Esc → pause, click Tiếp tục → resume
- [ ] Esc → pause, click Thoát → game thoát
- [ ] Quay lại từng NPC → đều dialogue được
```

**Step 2:** Chơi từ đầu, tick từng item.

**Verify:** Tất cả ✓. Nếu có ✗ → tạo issue, sửa, commit.
**Commit:**
```
git add tests/manual_qa/
git commit -m "test(M1): smoke test checklist + results"
```

---

> **Hết Phase 1.** Tổng 11 task ≈ 2.5 ngày làm việc. Tag git: `git tag v0.1.0-m1`.

---

## PHASE 2 — SYSTEMS NỘI DUNG (4 ngày)

> Mục tiêu: 5 puzzle component, notebook, inventory, save/load, dialogue đọc JSON, dream state machine, tutorial.

### T2.1: JSON loader utility
**Time:** 10p | **Phase:** 2 | **Depends on:** T1.1

**Files:**
- Create: `scripts/util/JsonLoader.gd`

**Step 1:**
```gdscript
class_name JsonLoader extends RefCounted

static func load_file(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		push_error("JSON file not found: " + path)
		return {}
	var f := FileAccess.open(path, FileAccess.READ)
	var text := f.get_as_text()
	f.close()
	var result = JSON.parse_string(text)
	if result == null:
		push_error("JSON parse failed: " + path)
		return {}
	return result

static func load_dir(dir_path: String) -> Dictionary:
	var out: Dictionary = {}
	var dir := DirAccess.open(dir_path)
	if dir == null:
		push_error("Dir not found: " + dir_path)
		return out
	dir.list_dir_begin()
	var f := dir.get_next()
	while f != "":
		if f.ends_with(".json"):
			var data := load_file(dir_path + "/" + f)
			if data.has("id"):
				out[data["id"]] = data
		f = dir.get_next()
	return out
```

**Verify:** Tạo `data/test.json` với `{"id":"foo","x":1}` → `JsonLoader.load_file("res://data/test.json")` trả về dict đúng.
**Commit:**
```
git add scripts/util/JsonLoader.gd
git commit -m "feat: JsonLoader utility for data files"
```

---

### T2.2: NotebookManager + Notebook UI
**Time:** 25p | **Phase:** 2 | **Depends on:** T1.1, T0.6

**Files:**
- Modify: `scripts/autoload/NotebookManager.gd`
- Create: `scenes/ui/Notebook.tscn`
- Create: `scripts/ui/Notebook.gd`

**Step 1:** `NotebookManager.gd`:
```gdscript
extends Node

signal entry_added(category: String, entry_id: String)
signal objective_changed(new_text: String)

const CATEGORIES := ["OBJECTIVE", "SYMBOL", "MEMORY", "NPC_STATE", "HINT"]

var _entries: Dictionary = {
	"OBJECTIVE": {}, "SYMBOL": {}, "MEMORY": {},
	"NPC_STATE": {}, "HINT": {}
}
var _objective: String = ""

func add_entry(category: String, entry_id: String, data: Dictionary) -> void:
	assert(category in CATEGORIES)
	_entries[category][entry_id] = data
	entry_added.emit(category, entry_id)

func has_entry(category: String, entry_id: String) -> bool:
	return _entries.get(category, {}).has(entry_id)

func get_entries(category: String) -> Dictionary:
	return _entries.get(category, {}).duplicate(true)

func set_objective(text: String) -> void:
	_objective = text
	objective_changed.emit(text)

func get_objective() -> String:
	return _objective
```

**Step 2:** `Notebook.tscn` — UI 5 tab dạng `TabContainer`, mỗi tab `ItemList`. Open/close bằng action `notebook`.

**Step 3:** `Notebook.gd`:
```gdscript
extends CanvasLayer

@onready var tabs: TabContainer = $TabContainer

func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	NotebookManager.entry_added.connect(_refresh)
	NotebookManager.objective_changed.connect(_refresh.bind("", ""))

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("notebook"):
		toggle()

func toggle() -> void:
	visible = not visible
	get_tree().paused = visible
	_refresh("", "")

func _refresh(_cat: String, _id: String) -> void:
	# Iterate categories, populate ItemList
	pass  # implementation: dump entries to ItemList trong từng tab
```

**Verify:** Q mở notebook, thấy objective + entry. Add entry runtime → tab cập nhật.
**Commit:**
```
git add scripts/autoload/NotebookManager.gd scenes/ui/Notebook.tscn scripts/ui/Notebook.gd
git commit -m "feat(M2.2): Notebook system with 5-tab UI"
```

---

### T2.3: InventoryManager + InventoryBar UI
**Time:** 20p | **Phase:** 2 | **Depends on:** T1.1

**Files:**
- Modify: `scripts/autoload/InventoryManager.gd`
- Create: `scenes/ui/InventoryBar.tscn`
- Create: `scripts/ui/InventoryBar.gd`

**Step 1:** `InventoryManager.gd`:
```gdscript
extends Node

signal item_added(item_id: String)
signal item_removed(item_id: String)
signal active_item_changed(old_id: String, new_id: String)

const MAX_SLOTS := 8

var _items: Array = []  # Array[String]
var _active: String = ""

func add_item(item_id: String) -> bool:
	if _items.size() >= MAX_SLOTS:
		return false
	if item_id in _items:
		return false
	_items.append(item_id)
	item_added.emit(item_id)
	if _active == "":
		set_active_item(item_id)
	return true

func remove_item(item_id: String) -> bool:
	if not item_id in _items:
		return false
	_items.erase(item_id)
	item_removed.emit(item_id)
	if _active == item_id:
		set_active_item(_items[0] if _items.size() > 0 else "")
	return true

func has_item(item_id: String) -> bool:
	return item_id in _items

func get_all_items() -> Array:
	return _items.duplicate()

func set_active_item(item_id: String) -> void:
	if _active == item_id:
		return
	var old: String = _active
	_active = item_id
	active_item_changed.emit(old, item_id)

func get_active_item() -> String:
	return _active
```

**Step 2:** `InventoryBar.tscn` — `HBoxContainer` 8 slot (`TextureRect` 16×16 mỗi slot) đặt bottom-center.

**Verify:** Pick 3 item, đổi active bằng phím 1/2/3 (sẽ thêm input sau), inventory bar update.
**Commit:**
```
git add scripts/autoload/InventoryManager.gd scenes/ui/InventoryBar.tscn scripts/ui/InventoryBar.gd
git commit -m "feat(M2.3): Inventory system with active item slot"
```

---

### T2.4: BasePuzzle abstract class
**Time:** 15p | **Phase:** 2 | **Depends on:** T2.1

**Files:**
- Create: `scripts/puzzle/BasePuzzle.gd`

**Step 1:**
```gdscript
class_name BasePuzzle extends Node

signal puzzle_started(puzzle_id: String)
signal puzzle_completed(puzzle_id: String)
signal puzzle_failed(puzzle_id: String, reason: String)

@export var puzzle_id: String = ""
@export var auto_start: bool = true

var _data: Dictionary = {}
var _started: bool = false
var _completed: bool = false

func _ready() -> void:
	if puzzle_id == "":
		push_error("BasePuzzle: puzzle_id chưa set")
		return
	_data = JsonLoader.load_file("res://data/puzzles/%s.json" % puzzle_id)
	if _data.is_empty():
		push_error("Puzzle data not found: " + puzzle_id)
		return
	if auto_start and can_start():
		start()

func can_start() -> bool:
	var req: Array = _data.get("required_flags", [])
	return GameState.has_all_flags(req)

func start() -> void:
	if _started:
		return
	_started = true
	puzzle_started.emit(puzzle_id)
	_on_start()

# Subclass override
func _on_start() -> void: pass
func check_solution() -> bool:
	push_error("check_solution() must be overridden")
	return false

func complete() -> void:
	if _completed:
		return
	_completed = true
	for f in _data.get("reward_flags", []):
		GameState.set_flag(f, true)
	var dial: String = _data.get("on_complete_dialogue", "")
	if dial != "":
		DialogueManager.play(dial)
	puzzle_completed.emit(puzzle_id)
```

**Verify:** Tạo `data/puzzles/test_puzzle.json` đơn giản, instance BasePuzzle (subclass test) → `_data` load đúng.
**Commit:**
```
git add scripts/puzzle/BasePuzzle.gd
git commit -m "feat(M2.4): BasePuzzle abstract class with JSON loader"
```

---

### T2.5: Puzzle type 1 — CollectAndPlace
**Time:** 25p | **Phase:** 2 | **Depends on:** T2.4, T2.3

**Files:**
- Create: `scripts/puzzle/CollectAndPlacePuzzle.gd`
- Create: `scripts/interaction/PlaceSlot.gd`
- Create: `data/puzzles/test_collect.json`

**Step 1:** `data/puzzles/test_collect.json`:
```json
{
  "id": "test_collect",
  "type": "collect_and_place",
  "scene": "TestRoom",
  "required_items": ["item_a", "item_b"],
  "target_object": "TargetSlot",
  "order_matters": false,
  "reward_flags": ["test_collect_done"]
}
```

**Step 2:** `PlaceSlot.gd` extends Interactable:
```gdscript
class_name PlaceSlot extends Interactable

signal item_placed(item_id: String)

@export var slot_id: String = ""
@export var accepts_items: Array[String] = []  # rỗng = chấp nhận tất cả

var placed_item: String = ""

func _on_interact() -> void:
	var active: String = InventoryManager.get_active_item()
	if active == "":
		return
	if accepts_items.size() > 0 and not active in accepts_items:
		return
	placed_item = active
	InventoryManager.remove_item(active)
	item_placed.emit(active)
	enabled = false  # tắt sau khi đặt
```

**Step 3:** `CollectAndPlacePuzzle.gd`:
```gdscript
class_name CollectAndPlacePuzzle extends BasePuzzle

@export var slot_paths: Array[NodePath] = []  # path tới các PlaceSlot

var _placed: Array = []  # Array[String]

func _on_start() -> void:
	for p in slot_paths:
		var slot: PlaceSlot = get_node(p)
		slot.item_placed.connect(_on_item_placed.bind(slot.slot_id))

func _on_item_placed(item_id: String, slot_id: String) -> void:
	_placed.append({"slot": slot_id, "item": item_id})
	if check_solution():
		complete()

func check_solution() -> bool:
	var required: Array = _data.get("required_items", [])
	var placed_ids: Array = []
	for entry in _placed:
		placed_ids.append(entry["item"])
	# Order check
	if _data.get("order_matters", false):
		var order: Array = _data.get("correct_order", [])
		return placed_ids == order
	# Set check
	for r in required:
		if not r in placed_ids:
			return false
	return true
```

**Step 4:** Test scene `TestPuzzleCollect.tscn`:
- 2 PickupItem (item_a, item_b)
- 2 PlaceSlot
- 1 CollectAndPlacePuzzle node
- Player

**Verify:** TEST_M2.4.1 (§D.3). Nhặt 2 item, đặt 2 slot → flag `test_collect_done` = true, signal emit.
**Commit:**
```
git add scripts/puzzle/CollectAndPlacePuzzle.gd scripts/interaction/PlaceSlot.gd data/puzzles/test_collect.json
git commit -m "feat(M2.4): CollectAndPlace puzzle type"
```

---

### T2.6: Puzzle type 2 — OrderedSlots
**Time:** 15p | **Phase:** 2 | **Depends on:** T2.5

**Files:**
- Create: `scripts/puzzle/OrderedSlotsPuzzle.gd`
- Create: `data/puzzles/test_ordered.json`

**Step 1:** `data/puzzles/test_ordered.json`:
```json
{
  "id": "test_ordered",
  "type": "ordered_slots",
  "scene": "TestRoom",
  "slots": [
    {"slot_id": "slot_1", "expected_item": "memory_a"},
    {"slot_id": "slot_2", "expected_item": "memory_b"},
    {"slot_id": "slot_3", "expected_item": "memory_c"}
  ],
  "reward_flags": ["test_ordered_done"]
}
```

**Step 2:** `OrderedSlotsPuzzle.gd`:
```gdscript
class_name OrderedSlotsPuzzle extends BasePuzzle

@export var slot_paths: Array[NodePath] = []

func _on_start() -> void:
	for p in slot_paths:
		var slot: PlaceSlot = get_node(p)
		slot.item_placed.connect(_check.bind(slot.slot_id))

func _check(_item: String, _slot: String) -> void:
	if check_solution():
		complete()

func check_solution() -> bool:
	for slot_def in _data.get("slots", []):
		var slot: PlaceSlot = _find_slot_by_id(slot_def["slot_id"])
		if slot == null or slot.placed_item != slot_def["expected_item"]:
			return false
	return true

func _find_slot_by_id(sid: String) -> PlaceSlot:
	for p in slot_paths:
		var s: PlaceSlot = get_node(p)
		if s.slot_id == sid:
			return s
	return null
```

**Verify:** Đặt sai slot → fail. Đặt đúng cả 3 → complete.
**Commit:**
```
git add scripts/puzzle/OrderedSlotsPuzzle.gd data/puzzles/test_ordered.json
git commit -m "feat(M2.4): OrderedSlots puzzle type"
```

---

### T2.7: Puzzle type 3 — RotateReflect
**Time:** 20p | **Phase:** 2 | **Depends on:** T2.4

**Files:**
- Create: `scripts/puzzle/RotateReflectPuzzle.gd`
- Create: `scripts/interaction/Rotator.gd`
- Create: `data/puzzles/test_rotate.json`

**Step 1:** `data/puzzles/test_rotate.json`:
```json
{
  "id": "test_rotate",
  "type": "rotate_reflect",
  "scene": "TestRoom",
  "rotators": [
    {"node_path": "Mirror1", "correct_angle_deg": 45},
    {"node_path": "Mirror2", "correct_angle_deg": 135}
  ],
  "tolerance_deg": 5,
  "reward_flags": ["test_rotate_done"]
}
```

**Step 2:** `Rotator.gd` extends Interactable:
```gdscript
class_name Rotator extends Interactable

signal rotated(new_angle: float)

@export var step_deg: float = 15.0
var current_angle: float = 0.0

func _on_interact() -> void:
	current_angle = fposmod(current_angle + step_deg, 360.0)
	rotation_degrees = current_angle
	rotated.emit(current_angle)
```

**Step 3:** `RotateReflectPuzzle.gd`:
```gdscript
class_name RotateReflectPuzzle extends BasePuzzle

func _on_start() -> void:
	for r in _data.get("rotators", []):
		var rot: Rotator = get_node(r["node_path"])
		rot.rotated.connect(_check)

func _check(_angle: float) -> void:
	if check_solution():
		complete()

func check_solution() -> bool:
	var tol: float = _data.get("tolerance_deg", 5.0)
	for r in _data.get("rotators", []):
		var rot: Rotator = get_node(r["node_path"])
		var diff: float = abs(fposmod(rot.current_angle - r["correct_angle_deg"] + 180.0, 360.0) - 180.0)
		if diff > tol:
			return false
	return true
```

**Verify:** TEST_M2.4.4 (tolerance 5°). 47° pass, 51° fail.
**Commit:**
```
git add scripts/puzzle/RotateReflectPuzzle.gd scripts/interaction/Rotator.gd data/puzzles/test_rotate.json
git commit -m "feat(M2.4): RotateReflect puzzle type with tolerance"
```

---

### T2.8: Puzzle type 4 — GridPush (Sokoban)
**Time:** 30p | **Phase:** 2 | **Depends on:** T2.4, T1.4

**Files:**
- Create: `scripts/puzzle/GridPushPuzzle.gd`
- Create: `scripts/interaction/PushBlock.gd`
- Create: `data/puzzles/test_push.json`

**Step 1:** `data/puzzles/test_push.json`:
```json
{
  "id": "test_push",
  "type": "grid_push",
  "scene": "TestRoom",
  "grid_size": {"w": 8, "h": 6},
  "pushable_blocks": ["block_a", "block_b"],
  "target_cells": [
    {"block_id": "block_a", "cell": [3, 4]},
    {"block_id": "block_b", "cell": [5, 2]}
  ],
  "reward_flags": ["test_push_done"]
}
```

**Step 2:** `PushBlock.gd`:
```gdscript
class_name PushBlock extends StaticBody2D

@export var block_id: String = ""
const TILE := 16

signal moved(new_cell: Vector2i)

func try_push(direction: Vector2i, grid_w: int, grid_h: int, blockers: Array) -> bool:
	var current_cell := Vector2i(position) / TILE
	var target := current_cell + direction
	if target.x < 0 or target.x >= grid_w or target.y < 0 or target.y >= grid_h:
		return false
	for b in blockers:
		if b == target:
			return false
	position = Vector2(target * TILE)
	moved.emit(target)
	return true
```

**Step 3:** `GridPushPuzzle.gd`:
```gdscript
class_name GridPushPuzzle extends BasePuzzle

@export var block_paths: Array[NodePath] = []

func _on_start() -> void:
	for p in block_paths:
		var b: PushBlock = get_node(p)
		b.moved.connect(_check.bind(b.block_id))

func _check(_cell: Vector2i, _bid: String) -> void:
	if check_solution():
		complete()

func check_solution() -> bool:
	for tc in _data.get("target_cells", []):
		var b: PushBlock = _find_block(tc["block_id"])
		if b == null:
			return false
		var cell := Vector2i(b.position) / 16
		var target := Vector2i(tc["cell"][0], tc["cell"][1])
		if cell != target:
			return false
	return true

func _find_block(bid: String) -> PushBlock:
	for p in block_paths:
		var b: PushBlock = get_node(p)
		if b.block_id == bid:
			return b
	return null
```

**Step 4:** Player phải có logic "push": khi va chạm PushBlock theo hướng đi, gọi `try_push`. Modify `PlayerController.gd`:
```gdscript
# Sau move_and_slide()
for i in get_slide_collision_count():
	var col := get_slide_collision(i)
	var collider = col.get_collider()
	if collider is PushBlock:
		var dir := Vector2i(round(velocity.normalized()))
		collider.try_push(dir, 8, 6, [])  # TODO: tính blockers thật
```

**Verify:** TEST_M2.4.3. Đẩy 2 block vào target cells → flag set.
**Commit:**
```
git add scripts/puzzle/GridPushPuzzle.gd scripts/interaction/PushBlock.gd data/puzzles/test_push.json scripts/player/PlayerController.gd
git commit -m "feat(M2.4): GridPush Sokoban puzzle type"
```

---

### T2.9: Puzzle type 5 — AreaHold
**Time:** 15p | **Phase:** 2 | **Depends on:** T2.4

**Files:**
- Create: `scripts/puzzle/AreaHoldPuzzle.gd`
- Create: `data/puzzles/test_hold.json`

**Step 1:** `data/puzzles/test_hold.json`:
```json
{
  "id": "test_hold",
  "type": "area_hold",
  "scene": "TestRoom",
  "hold_area": "HoldArea",
  "hold_duration_sec": 5.0,
  "interrupt_resets": true,
  "reward_flags": ["test_hold_done"]
}
```

**Step 2:** `AreaHoldPuzzle.gd`:
```gdscript
class_name AreaHoldPuzzle extends BasePuzzle

@export var area_path: NodePath
var _player_inside: bool = false
var _elapsed: float = 0.0

func _on_start() -> void:
	var area: Area2D = get_node(area_path)
	area.body_entered.connect(_on_enter)
	area.body_exited.connect(_on_exit)

func _on_enter(body: Node) -> void:
	if body.is_in_group("player"):
		_player_inside = true

func _on_exit(body: Node) -> void:
	if body.is_in_group("player"):
		_player_inside = false
		if _data.get("interrupt_resets", true):
			_elapsed = 0.0

func _process(delta: float) -> void:
	if not _started or _completed:
		return
	if _player_inside:
		_elapsed += delta
		if _elapsed >= _data.get("hold_duration_sec", 5.0):
			complete()

func check_solution() -> bool:
	return _elapsed >= _data.get("hold_duration_sec", 5.0)
```

**Verify:** TEST_M2.4.5. Vào area giữ 3s, ra, vào lại 3s → KHÔNG complete. Vào giữ 5s liên tục → complete.
**Commit:**
```
git add scripts/puzzle/AreaHoldPuzzle.gd data/puzzles/test_hold.json
git commit -m "feat(M2.4): AreaHold puzzle type"
```

---

### T2.10: DialogueManager đọc JSON
**Time:** 15p | **Phase:** 2 | **Depends on:** T1.8, T2.1

**Files:**
- Modify: `scripts/autoload/DialogueManager.gd`

**Step 1:** Thay `_inline_dialogues` bằng load từ JSON ở `_ready()`:
```gdscript
func _ready() -> void:
	_inline_dialogues = JsonLoader.load_dir("res://data/dialogues")
```

**Step 2:** Format file `data/dialogues/<id>.json` theo §B.3.

**Step 3:** Tạo `data/dialogues/mira_intro.json`:
```json
{
  "id": "mira_intro",
  "lines": [
    {"speaker": "Mira", "text": "Đừng nhìn em lâu quá... em không quen."},
    {"speaker": "Player", "text": "Dạo này em ngủ không ngon sao?"},
    {"speaker": "Mira", "text": "Trong mơ có rất nhiều gương. Gương nào cũng nói cùng một điều."}
  ]
}
```

**Verify:** Mira NPC trigger dialogue → đọc đúng từ file.
**Commit:**
```
git add scripts/autoload/DialogueManager.gd data/dialogues/
git commit -m "feat(M2.5): DialogueManager loads JSON, supports condition"
```

---

### T2.11: SaveManager — save/load round-trip
**Time:** 25p | **Phase:** 2 | **Depends on:** T1.1, T2.2, T2.3

**Files:**
- Modify: `scripts/autoload/SaveManager.gd`

**Step 1:**
```gdscript
extends Node

const SAVE_PATH := "user://save.json"
const CURRENT_VERSION := 1

signal save_completed()
signal load_completed()

func save_game() -> bool:
	var data: Dictionary = {
		"version": CURRENT_VERSION,
		"saved_at_iso": Time.get_datetime_string_from_system(true),
		"current_scene": GameState.current_state,
		"current_case": GameState.current_case,
		"flags": GameState.flags.duplicate(),
		"inventory": InventoryManager.get_all_items(),
		"notebook_entries": _serialize_notebook(),
		"npc_states": _serialize_npc_states()
	}
	var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if f == null:
		push_error("Cannot open save file")
		return false
	f.store_string(JSON.stringify(data, "\t"))
	f.close()
	save_completed.emit()
	return true

func load_game() -> bool:
	if not has_save():
		return false
	var f := FileAccess.open(SAVE_PATH, FileAccess.READ)
	var data = JSON.parse_string(f.get_as_text())
	f.close()
	if data == null:
		return false
	data = _migrate(data)
	# Restore state
	GameState.flags = data.get("flags", {})
	GameState.set_case(data.get("current_case", ""))
	for item in data.get("inventory", []):
		InventoryManager.add_item(item)
	# TODO: restore notebook + npc_states
	load_completed.emit()
	return true

func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)

func delete_save() -> void:
	if has_save():
		DirAccess.remove_absolute(SAVE_PATH)

func _migrate(data: Dictionary) -> Dictionary:
	var v: int = data.get("version", 0)
	if v < CURRENT_VERSION:
		# placeholder migration logic
		data["version"] = CURRENT_VERSION
	return data

func _serialize_notebook() -> Dictionary:
	var out: Dictionary = {}
	for cat in NotebookManager.CATEGORIES:
		out[cat] = NotebookManager.get_entries(cat).keys()
	return out

func _serialize_npc_states() -> Dictionary:
	# TODO sau khi có DreamStateManager
	return {}
```

**Verify:** TEST_M2.6.1, TEST_M2.6.2. Save → thoát game → mở lại → load → flags/items khôi phục.
**Commit:**
```
git add scripts/autoload/SaveManager.gd
git commit -m "feat(M2.6): SaveManager save/load with versioning"
```

---

### T2.12: DreamStateManager + auto state transition
**Time:** 20p | **Phase:** 2 | **Depends on:** T1.1, T2.11

**Files:**
- Modify: `scripts/autoload/DreamStateManager.gd`
- Create: `data/npcs/mira.json`, `data/npcs/theo.json`, `data/npcs/rell.json`, `data/npcs/lina.json`

**Step 1:** `DreamStateManager.gd`:
```gdscript
extends Node

signal npc_state_changed(npc_id: String, old: String, new: String)

const STATES := ["LOCKED", "INTRODUCED", "DENY", "DISTURBED",
                 "CONFRONTING", "RITUAL_READY", "REALIZATION", "AWAKE_CHANGED"]

var _states: Dictionary ={}  # npc_id -> state
var _npc_data: Dictionary = {}  # npc_id -> data

func _ready() -> void:
	_npc_data = JsonLoader.load_dir("res://data/npcs")
	for nid in _npc_data:
		_states[nid] = "LOCKED"
	GameState.flag_changed.connect(_on_flag_changed)

func get_npc_state(npc_id: String) -> String:
	return _states.get(npc_id, "LOCKED")

func set_npc_state(npc_id: String, new_state: String) -> void:
	assert(new_state in STATES)
	var old: String = get_npc_state(npc_id)
	if old == new_state:
		return
	_states[npc_id] = new_state
	npc_state_changed.emit(npc_id, old, new_state)

func _on_flag_changed(_name: String, _val: bool) -> void:
	for nid in _npc_data:
		evaluate_state_for_npc(nid)

func evaluate_state_for_npc(npc_id: String) -> void:
	var data: Dictionary = _npc_data.get(npc_id, {})
	if data.is_empty():
		return
	var current: String = get_npc_state(npc_id)
	if current in ["LOCKED", "AWAKE_CHANGED"]:
		return
	var memories: Array = data.get("required_memories", [])
	var restored: int = 0
	for m in memories:
		if GameState.has_flag("%s_memory_%s_restored" % [npc_id, m.replace(npc_id + "_", "")]):
			restored += 1
	var ritual_done: bool = GameState.has_flag("%s_realized" % npc_id)
	if ritual_done:
		set_npc_state(npc_id, "REALIZATION")
	elif restored >= memories.size():
		set_npc_state(npc_id, "CONFRONTING")
	elif restored >= 1:
		set_npc_state(npc_id, "DISTURBED")
```

**Step 2:** Tạo 4 file NPC JSON theo schema §B.2 (placeholder data, sẽ refine ở Phase 3+).

**Verify:** TEST_M2.7.1. Set 1 flag memory → state DISTURBED. Set đủ 3 → CONFRONTING.
**Commit:**
```
git add scripts/autoload/DreamStateManager.gd data/npcs/
git commit -m "feat(M2.7): DreamStateManager auto state transition"
```

---

### T2.13: Tutorial scene
**Time:** 30p | **Phase:** 2 | **Depends on:** T2.5, T2.10, T2.11

**Files:**
- Create: `scenes/dreams/Dream_Tutorial.tscn`
- Create: `data/dialogues/tutorial_intro.json`, `tutorial_done.json`
- Create: `data/puzzles/tutorial_paper.json`

**Step 1:** `data/puzzles/tutorial_paper.json`:
```json
{
  "id": "tutorial_paper",
  "type": "collect_and_place",
  "scene": "Dream_Tutorial",
  "required_items": ["paper_clue"],
  "target_object": "EmptyFrame",
  "reward_flags": ["tutorial_completed"],
  "on_complete_dialogue": "tutorial_done"
}
```

**Step 2:** `Dream_Tutorial.tscn`:
- Phòng tối (TileMap).
- 1 Lamp (Interactable, on_interact → set flag `tutorial_lamp_on`, đổi sprite, hiện hint Q).
- 1 PickupItem `paper_clue` (chỉ spawn khi `tutorial_lamp_on`).
- 1 PlaceSlot tên `EmptyFrame`.
- 1 Door (Interactable, enabled khi `tutorial_completed` = true → SceneLoader.fade_to Village).
- HUD hint hiện theo từng bước: "WASD đi", "E tương tác", "Q mở Sổ Mộng".

**Step 3:** `data/dialogues/tutorial_intro.json` — 1-2 câu kích hoạt khi vào scene.

**Verify:** TEST_M2.8.1. Chơi xong tutorial → flag `tutorial_completed = true`, vào Village.
**Commit:**
```
git add scenes/dreams/Dream_Tutorial.tscn data/dialogues/ data/puzzles/tutorial_paper.json
git commit -m "feat(M2.8): tutorial dream scene"
```

---

### T2.14: HUD objective + notebook icon
**Time:** 15p | **Phase:** 2 | **Depends on:** T2.2

**Files:**
- Create: `scenes/ui/HUD.tscn`
- Create: `scripts/ui/HUD.gd`

**Step 1:** `HUD.tscn`:
- CanvasLayer (layer=32)
- Top-left: Label "Objective" (subscribe NotebookManager.objective_changed)
- Top-right: TextureRect notebook icon + counter "0/3" memories.
- Bottom-center: ColorRect inventory active item (subscribe InventoryManager.active_item_changed).

**Step 2:** `HUD.gd` connect signals, update UI mỗi khi event.

**Step 3:** Instantiate HUD trong Boot.tscn (persistent layer).

**Verify:** Set objective runtime → HUD update. Pick item → bottom slot đổi.
**Commit:**
```
git add scenes/ui/HUD.tscn scripts/ui/HUD.gd
git commit -m "feat(M2.x): HUD with objective + counter"
```

---

### T2.15: Smoke test Phase 2
**Time:** 20p | **Phase:** 2 | **Depends on:** T2.1-T2.14

**Files:**
- Create: `tests/manual_qa/M2_checklist.md`

**Step 1:** Checklist:
```markdown
# M2 Smoke Test
- [ ] Boot → MainMenu → click Continue (nếu có save) → load đúng state
- [ ] Tutorial scene chơi từ đầu đến cuối, set flag tutorial_completed
- [ ] Notebook (Q) mở/đóng đúng, hiển thị objective
- [ ] HUD top-right hiện counter memory
- [ ] Inventory: nhặt 3 item, chuyển active OK
- [ ] 5 puzzle type: tạo test scene cho mỗi type, complete flag set
- [ ] Save → thoát → load: flags + inventory + notebook khôi phục
- [ ] Set 1 flag memory cho Mira → state DISTURBED
- [ ] Tiếng Việt mọi UI hiển thị đúng dấu
```

**Step 2:** Chơi từng item, fix bug.
**Commit:**
```
git add tests/manual_qa/M2_checklist.md
git tag v0.2.0-m2
git commit -m "test(M2): smoke test Phase 2 + tag v0.2.0"
```

---

> **Hết Phase 2.** Tổng 15 task ≈ 4-5 ngày làm việc. Tag git: `v0.2.0-m2`.

---

## PHASE 3 — MÀN MIRA HOÀN CHỈNH (3-4 ngày)

> Mục tiêu: chơi trọn màn Mira từ Village → Dream → 3 puzzle → Ritual → Wake → Village state đổi.

### T3.1: Mira NPC dialogue ngoài đời
**Time:** 15p | **Phase:** 3 | **Depends on:** T2.10, T2.12

**Files:**
- Create: `data/dialogues/mira_intro.json` (đã có ở T2.10, refine ở đây)
- Create: `data/dialogues/mira_after_wake.json`
- Modify: `scenes/world/Village.tscn`

**Step 1:** Refine `mira_intro.json` theo §12.4 GDD V3.

**Step 2:** `mira_after_wake.json`:
```json
{
  "id": "mira_after_wake",
  "lines": [
    {"speaker": "Mira", "text": "Hôm nay em mở cửa sổ rồi. Có nắng quá."},
    {"speaker": "Mira", "text": "Em vẫn còn ngại... nhưng em thấy hoa nở thật đẹp."}
  ]
}
```

**Step 3:** Mira NPC trong Village:
- Khi state = LOCKED → enabled = false (không tương tác).
- Khi state = INTRODUCED → dialogue = `mira_intro`.
- Khi state = AWAKE_CHANGED → dialogue = `mira_after_wake`, sprite đổi (không che mặt).

**Verify:** Đầu game Mira chỉ nói intro. Sau ritual, dialogue khác hẳn.
**Commit:**
```
git add data/dialogues/mira_*.json scenes/world/Village.tscn
git commit -m "feat(M3.1): Mira village dialogues + state-aware sprite"
```

---

### T3.2: Vào giấc mơ Mira (DreamPortal)
**Time:** 15p | **Phase:** 3 | **Depends on:** T1.6, T2.12

**Files:**
- Create: `scripts/interaction/DreamPortal.gd`

**Step 1:**
```gdscript
class_name DreamPortal extends Interactable

@export var npc_id: String = ""

func _on_interact() -> void:
	var data: Dictionary = DreamStateManager._npc_data.get(npc_id, {})
	if data.is_empty():
		return
	GameState.set_case(npc_id)
	GameState.current_dream_id = npc_id
	GameState.set_state("ENTER_DREAM")
	SceneLoader.fade_to(data.get("dream_scene", ""))
```

**Step 2:** Trong Village, sau khi Mira intro xong (set flag `mira_intro_done`), 1 portal (chiếc khăn rơi cạnh nhà Mira) xuất hiện. Tương tác → vào dream.

**Verify:** Click khăn → fade → load Dream_Mira_MirrorRoom.
**Commit:**
```
git add scripts/interaction/DreamPortal.gd
git commit -m "feat(M3.2): DreamPortal interaction triggers dream scene"
```

---

### T3.3: Scene Dream_Mira_MirrorRoom layout
**Time:** 30p | **Phase:** 3 | **Depends on:** T3.2

**Files:**
- Create: `scenes/dreams/Dream_Mira_MirrorRoom.tscn`

**Step 1:** Layout phòng (TileMap placeholder):
- Khu vực 1: 3 mảnh gương rơi rải rác (PickupItem id `mirror_shard_1/2/3`).
- Khu vực 2: Khung gương trung tâm có 3 PlaceSlot.
- Khu vực 3: Bức tranh rách có 3 PlaceSlot (mở khoá khi gương xong).
- Khu vực 4: Chậu hoa héo + 2 Rotator (mirror nhỏ).
- Khu vực 5: Mira Mộng (NPC) đứng giữa.
- Khu vực 6: Item mặt nạ + vùng ritual (Area2D).

**Step 2:** Player spawn point ở cửa vào.

**Step 3:** Camera2D bám Player.

**Verify:** Vào scene → đi quanh, thấy đủ 6 khu vực, không kẹt.
**Commit:**
```
git add scenes/dreams/Dream_Mira_MirrorRoom.tscn
git commit -m "feat(M3.3): Dream_Mira_MirrorRoom layout placeholder"
```

---

### T3.4: Puzzle 1 — Sửa gương thật (CollectAndPlace, có order)
**Time:** 20p | **Phase:** 3 | **Depends on:** T2.5, T3.3

**Files:**
- Create: `data/puzzles/mira_repair_true_mirror.json`

**Step 1:**
```json
{
  "id": "mira_repair_true_mirror",
  "type": "collect_and_place",
  "scene": "Dream_Mira_MirrorRoom",
  "required_items": ["mirror_shard_1", "mirror_shard_2", "mirror_shard_3"],
  "target_object": "TrueMirror",
  "order_matters": true,
  "correct_order": ["mirror_shard_1", "mirror_shard_2", "mirror_shard_3"],
  "reward_flags": ["mira_true_mirror_repaired"],
  "on_complete_dialogue": "mira_mirror_repaired_reaction"
}
```

**Step 2:** Trong scene, gắn `CollectAndPlacePuzzle` node, set `puzzle_id = "mira_repair_true_mirror"`, link 3 PlaceSlot.

**Step 3:** Khi flag `mira_true_mirror_repaired` = true → đổi sprite gương méo → gương thật + mở vùng tranh ký ức.

**Verify:** Nhặt + đặt 3 mảnh đúng thứ tự → gương sáng + tranh xuất hiện.
**Commit:**
```
git add data/puzzles/mira_repair_true_mirror.json scenes/dreams/Dream_Mira_MirrorRoom.tscn
git commit -m "feat(M3.4): Mira puzzle 1 (true mirror)"
```

---

### T3.5: Puzzle 2 — Ghép tranh ký ức (OrderedSlots)
**Time:** 25p | **Phase:** 3 | **Depends on:** T2.6, T3.4

**Files:**
- Create: `data/puzzles/mira_painting_memories.json`
- Create: `data/memories/mira_cat.json`, `mira_flower.json`, `mira_friend.json`
- Create: `data/dialogues/mira_after_memory_*.json`

**Step 1:** 3 memory file:
```json
// data/memories/mira_cat.json
{
  "id": "mira_cat",
  "owner_npc": "mira",
  "title_vi": "Cứu chú mèo bị thương",
  "description_vi": "Mira ngồi xổm bên hông nhà, băng vết thương cho con mèo nhỏ.",
  "icon": "res://assets/sprites/ui/icon_memory.png",
  "found_in_dream": "Dream_Mira_MirrorRoom",
  "is_counter_evidence": true
}
```

**Step 2:** Puzzle file:
```json
{
  "id": "mira_painting_memories",
  "type": "ordered_slots",
  "scene": "Dream_Mira_MirrorRoom",
  "required_flags": ["mira_true_mirror_repaired"],
  "slots": [
    {"slot_id": "painting_slot_1", "expected_item": "mira_cat"},
    {"slot_id": "painting_slot_2", "expected_item": "mira_flower"},
    {"slot_id": "painting_slot_3", "expected_item": "mira_friend"}
  ],
  "reward_flags": ["mira_painting_restored"],
  "on_complete_dialogue": "mira_painting_complete"
}
```

**Step 3:** Khi pick từng memory item → set flag `mira_memory_<id>_restored` (DreamStateManager nghe → cập nhật state Mira). Khi đặt vào slot đúng → puzzle complete.

**Verify:** TEST_M2.4.1. Đặt sai slot → fail. Đủ 3 đúng → complete + Mira state CONFRONTING.
**Commit:**
```
git add data/puzzles/mira_painting_memories.json data/memories/mira_*.json data/dialogues/mira_after_memory_*.json
git commit -m "feat(M3.5): Mira puzzle 2 (painting memories) + 3 memory entries"
```

---

### T3.6: Puzzle 3 — Hoa nở (RotateReflect)
**Time:** 20p | **Phase:** 3 | **Depends on:** T2.7, T3.5

**Files:**
- Create: `data/puzzles/mira_flower_bloom.json`

**Step 1:**
```json
{
  "id": "mira_flower_bloom",
  "type": "rotate_reflect",
  "scene": "Dream_Mira_MirrorRoom",
  "required_flags": ["mira_painting_restored"],
  "rotators": [
    {"node_path": "MirrorSmall_1", "correct_angle_deg": 45},
    {"node_path": "MirrorSmall_2", "correct_angle_deg": 135}
  ],
  "tolerance_deg": 5,
  "reward_flags": ["mira_flower_bloomed"],
  "on_complete_dialogue": "mira_flower_reaction"
}
```

**Step 2:** Visual: tia sáng (Line2D) đi từ TrueMirror qua 2 gương xoay đến chậu hoa. Khi đúng góc → tia sáng chạm hoa → sprite hoa đổi héo → nở.

**Verify:** Xoay 2 gương đúng → flag set + sprite hoa đổi.
**Commit:**
```
git add data/puzzles/mira_flower_bloom.json
git commit -m "feat(M3.6): Mira puzzle 3 (flower bloom rotate)"
```

---

### T3.7: Ritual mặt nạ + cutscene
**Time:** 30p | **Phase:** 3 | **Depends on:** T3.6

**Files:**
- Create: `scripts/ritual/RitualController.gd`
- Create: `scenes/cutscenes/MiraRitualCutscene.tscn`
- Create: `data/dialogues/mira_realization.json`

**Step 1:** `RitualController.gd`:
```gdscript
class_name RitualController extends Node

@export var npc_id: String = ""
@export var required_flags: Array[String] = []
@export var ritual_dialogue: String = ""
@export var ritual_action: String = ""  # "place_mask" | "fold_paper" | etc.

func _on_player_in_ritual_zone() -> void:
	if not GameState.has_all_flags(required_flags):
		return
	if InventoryManager.get_active_item() != "%s_mask" % npc_id:
		return
	GameState.set_state("RITUAL_READY")
	_run_cutscene()

func _run_cutscene() -> void:
	# Disable player movement, play cutscene scene
	var cs := preload("res://scenes/cutscenes/MiraRitualCutscene.tscn").instantiate()
	get_tree().current_scene.add_child(cs)
	await cs.finished
	GameState.set_flag("%s_realized" % npc_id, true)
	DreamStateManager.set_npc_state(npc_id, "AWAKE_CHANGED")
	SaveManager.save_game()
	SceneLoader.fade_to("res://scenes/world/Village.tscn", 1.5)
```

**Step 2:** `MiraRitualCutscene.tscn` — sequence:
- Đặt mặt nạ xuống (animation drop).
- Gương phản chiếu nhiều layer hình ảnh Mira (cứu mèo, tặng hoa, khóc, run...).
- Dialogue `mira_realization` chạy 3 dòng.
- Fade trắng → emit `finished`.

**Step 3:** Trong `Dream_Mira_MirrorRoom.tscn`, thêm Area2D vùng ritual + RitualController.

**Verify:** TEST_M3.X.1 (§D.4). End-to-end Mira chơi xong → flag mira_realized = true → AWAKE_CHANGED → Village state đổi.
**Commit:**
```
git add scripts/ritual/ scenes/cutscenes/ data/dialogues/mira_realization.json
git commit -m "feat(M3.7): Mira ritual cutscene + realization flag"
```

---

### T3.8: Mira ngoài đời thay đổi sau tỉnh
**Time:** 15p | **Phase:** 3 | **Depends on:** T3.7

**Files:**
- Modify: `scenes/world/Village.tscn`

**Step 1:** Trong Village, NPC Mira lắng nghe `DreamStateManager.npc_state_changed`:
- Khi state Mira chuyển AWAKE_CHANGED → đổi sprite (mở rèm, không khăn che mặt), đổi vị trí (ra trước cửa tưới hoa), đổi `intro_dialogue_id` thành `mira_after_wake`.

**Step 2:** Mở khoá Theo: NPC Theo enabled = true, set objective "Tìm hiểu Theo ở thư viện".

**Verify:** TEST_M3.X.2. Quay về Village sau Mira → sprite/dialogue Mira đổi, Theo unlock.
**Commit:**
```
git add scenes/world/Village.tscn
git commit -m "feat(M3.8): Mira village state change + unlock Theo"
```

---

### T3.9: Smoke test Phase 3
**Time:** 25p | **Phase:** 3 | **Depends on:** T3.1-T3.8

**Files:**
- Create: `tests/manual_qa/M3_checklist.md`

**Checklist:** chơi Mira end-to-end 3 lần (3 save khác nhau), không stuck, mọi flag set đúng, dialogue đổi đúng.

**Commit:**
```
git tag v0.3.0-m3
git commit -m "test(M3): smoke test Mira complete + tag v0.3.0"
```

> **Hết Phase 3.** Tổng 9 task ≈ 3-4 ngày. Tag: `v0.3.0-m3`.

---

## PHASE 4 — THEO, RELL, LINA (5-7 ngày)

> Pattern lặp Phase 3 cho 3 NPC còn lại. Mỗi màn ~1.5-2 ngày.

### MÀN THEO (T4.1 - T4.8)

| Task | Tên | Time | Reuse từ |
| :- | :- | :- | :- |
| T4.1 | Theo NPC dialogue ngoài đời + portal | 20p | T3.1 + T3.2 |
| T4.2 | Scene Dream_Theo_EndlessClass layout | 30p | T3.3 |
| T4.3 | Puzzle 1: mê cung bàn học (GridPush) | 35p | T2.8 |
| T4.4 | Puzzle 2: bảng lỗi (interact_correct_hotspot — viết puzzle type mới hoặc dùng Interactable đặc biệt) | 25p | new |
| T4.5 | Puzzle 3: thứ tự bài làm (OrderedSlots) | 20p | T2.6 |
| T4.6 | Ritual: máy bay giấy + cutscene | 30p | T3.7 |
| T4.7 | Theo ngoài đời thay đổi + unlock Rell | 15p | T3.8 |
| T4.8 | Smoke test màn Theo | 20p | T3.9 |

**Total:** 195p ≈ 1.5 ngày + iterate.

### MÀN RELL (T4.9 - T4.16)

| Task | Tên | Time |
| :- | :- | :- |
| T4.9 | Rell NPC + portal | 20p |
| T4.10 | Scene Dream_Rell_ClockTower (3 tầng) | 40p |
| T4.11 | Puzzle 1: nối bánh răng (RotateReflect) | 25p |
| T4.12 | Puzzle 2: trình tự ký ức (OrderedSlots) | 20p |
| T4.13 | Puzzle 3: tìm kim phút + anti-pattern (kéo kim ngược) | 30p |
| T4.14 | Ritual: lắp kim chạy tiếp + cutscene | 30p |
| T4.15 | Rell ngoài đời thay đổi + unlock Lina | 15p |
| T4.16 | Smoke test Rell | 20p |

**Total:** 200p ≈ 1.5-2 ngày.

### MÀN LINA (T4.17 - T4.24)

| Task | Tên | Time |
| :- | :- | :- |
| T4.17 | Lina NPC + portal | 20p |
| T4.18 | Scene Dream_Lina_DoorlessRoom | 30p |
| T4.19 | Puzzle 1: tranh cảm xúc (OrderedSlots) | 20p |
| T4.20 | Puzzle 2: tiếng gõ cửa (interact_hotspot) | 25p |
| T4.21 | Puzzle 3: sợi chỉ kết nối (CollectAndPlace) | 25p |
| T4.22 | Ritual: giữ ánh sáng (AreaHold) + cutscene | 30p |
| T4.23 | Lina ngoài đời thay đổi → trigger ending | 15p |
| T4.24 | Smoke test Lina | 20p |

**Total:** 185p ≈ 1.5-2 ngày.

> **Hết Phase 4.** Tag: `v0.4.0-m4`.

---

## PHASE 5 — POLISH & BUILD (2-3 ngày)

### T5.1: Ending cutscene
**Time:** 45p | **Phase:** 5 | **Depends on:** T4.24

**Files:**
- Create: `scenes/cutscenes/EndingCutscene.tscn`
- Create: `data/dialogues/ending.json`

**Step 1:** Trigger: khi Lina AWAKE_CHANGED + quay về Village → cutscene tự chạy.

**Step 2:** Camera pan qua quảng trường, mỗi NPC làm 1 hành động nhỏ (Mira tưới hoa, Theo học cùng bạn, Rell viết thư, Lina nói "hôm nay mình không ổn..."). Text ending § GDD V3 §22.

**Step 3:** Sau cutscene → màn hình "Cảm ơn anh/chị đã chơi" + credit.

**Verify:** TEST_M5.1.1.
**Commit:**
```
git commit -m "feat(M5.1): ending cutscene with 4 NPC reunion"
```

---

### T5.2: Audio polish
**Time:** 60p | **Phase:** 5 | **Depends on:** all puzzles

**Files:**
- Add: `assets/audio/sfx/*.wav` (10 SFX), `assets/audio/music/*.ogg` (3 track)
- Modify: `scripts/autoload/AudioManager.gd`

**SFX cần:**
- `interact.wav` — nhặt item.
- `clue_found.wav` — clue mới vào notebook.
- `puzzle_solved.wav` — puzzle complete.
- `dream_shift.wav` — môi trường mơ đổi.
- `door_open.wav` — cửa mở.
- `glass_break.wav` — gương vỡ (placeholder).
- `paper_fold.wav` — Theo gấp giấy.
- `gear_click.wav` — Rell bánh răng.
- `lock_click.wav` — Lina cửa mở.
- `ui_click.wav` — UI button.

**Music:**
- `bgm_village.ogg` — nhẹ, ấm.
- `bgm_dream_ambient.ogg` — mơ hồ, không melody mạnh.
- `bgm_ritual.ogg` — tăng dần emotion.

**Tip:** dùng <https://freesound.org> + <https://freemusicarchive.org> (CC0/CC-BY). Nhớ ghi credit trong README.

**Commit:**
```
git commit -m "polish(M5.2): audio SFX + 3 BGM tracks"
```

---

### T5.3: Bug pass — playtest đầy đủ
**Time:** 90p | **Phase:** 5

**Files:**
- Create: `tests/manual_qa/SMOKE_FULL.md`

**Checklist:** §D.6 GDD — chơi từ đầu đến cuối 30-60 phút, ghi lại bug, fix. Lặp 2 lần.

**Commit:** mỗi fix 1 commit, message format: `fix: <bug description>`.

---

### T5.4: Build Windows .exe
**Time:** 20p | **Phase:** 5

**Step 1:** Project → Export → Add Windows Desktop preset.
**Step 2:** Setting:
- Embed PCK: ON
- Custom icon: `res://assets/icon.png`
- Output: `D:\NguoiDichGiacMo\builds\windows\NguoiDichGiacMo.exe`

**Step 3:** Export → test trên máy sạch (TEST_M5.4.1, TEST_M5.4.2).

**Commit:**
```
git tag v1.0.0-mvp
git commit -m "build(M5.4): Windows MVP build v1.0.0"
```

---

### T5.5 (optional): Build Web HTML5
**Time:** 30p | **Phase:** 5

Add Web preset, export, test trên Chrome/Firefox.

---

> **Hết Phase 5.** Total project ≈ 18-22 ngày. Tag cuối: `v1.0.0-mvp`.

---

# DAILY LOG TEMPLATE

Mỗi ngày làm việc, ghi 1 entry vào `tests/daily_log/YYYY-MM-DD.md`:

```markdown
# YYYY-MM-DD

## Task hoàn thành
- [x] T1.4 — PlayerController 4-way (15p)
- [x] T1.5 — Interactable base (12p)

## Block / khó khăn
- T1.5 lúc đầu signal `body_entered` không emit — sửa do quên set collision_layer.

## Học được
- Godot 4.3 dùng `is_in_group()` chứ không phải `in_group()`.

## Hôm sau làm gì
- T1.6: SceneLoader fade
```

---

# RISK REGISTER

| Risk | Severity | Trigger | Mitigation |
| :- | :- | :- | :- |
| Scope phình to | High | Thêm puzzle/NPC ngoài MVP | Khoá MVP ở 4 NPC + 5 puzzle type. Mọi feature mới → defer. |
| Không xong đúng deadline | High | Phase trượt >2 ngày | Cắt Phase 5.5 (Web build), polish ít hơn, asset placeholder. |
| Bug save/load corrupt | Medium | Schema version đổi | Migration test bắt buộc, backup user://save.json.bak. |
| Tiếng Việt vỡ font | Medium | Build target khác máy dev | Embed font, test máy sạch. |
| AI Coding lạc đề | Medium | Subagent code khác spec | Mỗi task có Verify step + commit nhỏ → revert dễ. |
| Asset miss license | Low | Dùng asset không CC0/CC-BY | Ghi credit, ưu tiên Kenney/Itch.io free assets. |

---

# BLOCKER PROTOCOL

Khi gặp block (>30p không tiến):

1. **Dừng tool calls.** Không patch lung tung.
2. **Đọc lại GDD §C** (System Contracts) — 70% block do hiểu sai contract.
3. **Đọc lại task này trong Plan** — kiểm tra Step bỏ qua.
4. **Search Godot docs** <https://docs.godotengine.org/en/4.3/>
5. Nếu vẫn block → ghi vào Daily Log, hỏi anh Thanh, KHÔNG mở rộng scope.

---

# QUICK REFERENCE — PROMPT CHO SUBAGENT

Khi giao 1 task cho AI Coding:

```
TASK: T<X.Y> — <tên task>

Đọc trước:
- IMPLEMENTATION_PLAN.md mục T<X.Y>
- GDD_V3_Clean.md §C (System Contracts) cho manager liên quan
- GDD_V3_Clean.md §D test scenario tương ứng

Quy tắc:
- Chỉ làm Step 1-N của T<X.Y>, không chạm task khác.
- Bám đúng file path đã ghi (Create / Modify).
- Code đúng signature trong §C.
- Test phải pass trước khi commit.
- Commit message dùng format đã ghi trong task.

KHI XONG: gửi (1) git diff, (2) screenshot Godot Editor / output console, (3) verify result đã pass.
KHI BẾ TẮC: dừng, báo lý do, KHÔNG tự mở rộng scope.
```

---

# SIGN-OFF

**Tổng task:** 87 (Phase 0: 9, Phase 1: 11, Phase 2: 15, Phase 3: 9, Phase 4: 24, Phase 5: 5)
**Tổng thời gian dự kiến:** 18-22 ngày full-time / 35-45 ngày part-time
**Tổng commit dự kiến:** ~90-100
**Tổng tag git:** 6 (v0.1, v0.2, v0.3, v0.4, v1.0-mvp, +1 dự phòng)

Phiên bản Plan: 1.0 — 2026-05-25 — Asia/Saigon

Cặp file giao đầy đủ:
- `D:\Nguoi_Dich_Giac_Mo_GDD_V2_AI_Coding\GDD_V3_Clean.md` (75 KB, spec)
- `D:\Nguoi_Dich_Giac_Mo_GDD_V2_AI_Coding\IMPLEMENTATION_PLAN.md` (this file, ~70 KB, plan)

— Hết —
