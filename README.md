# Người Dịch Giấc Mơ — Dream Awakening

> Game pixel 2D giải đố narrative — đồ án sinh viên · Godot 4.3

Người chơi vào vai một nhân vật có khả năng bước vào giấc mơ của người khác để giúp họ tự nhận ra nỗi đau tâm lý qua các puzzle biểu tượng và **Nghi Thức Tỉnh Mộng**.

## Tech Stack

- **Engine:** Godot 4.3 stable
- **Language:** GDScript (thuần, không addon)
- **Target:** Windows x64 (MVP), HTML5 Web (stretch)
- **Resolution:** 480×270 internal (pixel-perfect 3× upscale → 1440×810)
- **Font:** NotoSans Mono CJK (hỗ trợ tiếng Việt đầy đủ dấu)

## Quy mô MVP

- 1 làng nhỏ + 4 NPC chính (Mira, Theo, Rell, Lina)
- 4 giấc mơ + 1 tutorial
- 5 loại puzzle component tái sử dụng
- Notebook system (Sổ Mộng) + Inventory + Save/Load
- Thời lượng chơi: 30-60 phút

## Tài liệu

- `GDD_V3_Clean.md` — Game Design Document (spec + 4 phụ lục A/B/C/D)
- `IMPLEMENTATION_PLAN.md` — 87 task chia 6 phase, ước tính 18-22 ngày full-time
- `tests/manual_qa/` — Test scenarios cho mỗi milestone
- `tests/daily_log/` — Nhật ký phát triển

## Run dự án

1. Cài Godot 4.3 stable (Standard, không cần .NET): https://godotengine.org/download/archive/4.3-stable/
2. Trong Godot Project Manager → Import → chọn `project.godot` ở thư mục này.
3. F5 để chạy game.

## Build Windows

Project → Export → Windows Desktop preset → Export Project.

Output: `builds/windows/NguoiDichGiacMo.exe`

## Cấu trúc thư mục

```
.
├── project.godot              # Godot project config
├── assets/                    # Sprite, font, audio, tileset
├── data/                      # JSON data (NPC, dialogue, puzzle, dream, memory)
├── scenes/                    # Godot scene files
│   ├── main/                  # Boot, MainMenu
│   ├── world/                 # Village
│   ├── dreams/                # Dream scenes (4 NPC + tutorial)
│   ├── ui/                    # Dialogue, Notebook, HUD, PauseMenu
│   ├── cutscenes/             # Ritual cutscenes
│   ├── player/                # Player.tscn
│   └── interaction/           # Interactable base, NPC, items
├── scripts/                   # GDScript source
│   ├── autoload/              # 8 singleton manager
│   ├── player/                # PlayerController
│   ├── interaction/           # NPC, PickupItem, PlaceSlot, etc.
│   ├── puzzle/                # 5 puzzle types
│   ├── ritual/                # RitualController
│   ├── ui/                    # UI scripts
│   └── util/                  # Helper (JsonLoader)
├── tests/
│   ├── manual_qa/             # Smoke test checklists
│   └── daily_log/             # Daily progress log
├── builds/                    # Output binaries (gitignored)
├── GDD_V3_Clean.md
├── IMPLEMENTATION_PLAN.md
└── README.md
```

## Trạng thái phát triển

- [x] **Phase 0** — Setup môi trường (project, autoload skeleton, MainMenu, Boot)
- [ ] **Phase 1** — Khung game playable (PlayerController, Interactable, Dialogue, Village)
- [ ] **Phase 2** — Systems nội dung (Notebook, Inventory, 5 puzzle types, Save, Tutorial)
- [ ] **Phase 3** — Màn Mira hoàn chỉnh
- [ ] **Phase 4** — Màn Theo, Rell, Lina
-[]**Phase 5** — Polish, audio, build

## License

Mã nguồn: MIT (sẽ thêm `LICENSE` file).
Asset bên thứ ba sẽ ghi credit chi tiết khi import.

## Tác giả

Đồ án sinh viên — H-thanh0603 (HCMUAF).


## Build .exe Windows

1. Mở Godot Editor 4.6.2 → Editor → Manage Export Templates → Download & Install
2. Đóng Editor
3. Mở Command Prompt tại thư mục project → chạy:
```
build.bat
```
4. File `builds\NguoiDichGiacMo.exe` sẽ được tạo

## Cấu trúc

```
scenes/
  main/         Boot, MainMenu, Ending
  world/        Village (4 NPC, 4 nhà, dream portal)
  player/       Player.tscn (16x32 sprite)
  dreams/       5 màn dream:
                  Dream_Tutorial          (3 phút - dạy điều khiển)
                  Dream_Mira_MirrorRoom   (10 phút - sửa gương + 4 ký ức + ritual)
                  Dream_Theo_EndlessClass (8 phút - xoá dấu = + tìm bài + cửa sổ)
                  Dream_Rell_ClockTower   (10 phút - bánh răng + thư + 2 cửa)
                  Dream_Lina_DoorlessRoom (8 phút - hộp nhạc + 4 khung + chìa khoá)
  ui/           DialogueBox, PauseMenu, Notebook, InventoryBar, HUD
scripts/        autoload (8) + interaction + puzzle + dreams + ui + util + world
data/           dialogues (29 JSON), npcs (4), memories (4), puzzles (4)
assets/
  sprites/      tự vẽ programmatic (60+ PNG)
  portraits/    5 portrait 64x64 (Mira, Theo, Rell, Lina, Player)
  kenney/       Tiny Town + Tiny Dungeon CC0 (264 tile)
docs/           GDD V3, IMPLEMENTATION_PLAN, refs
tests/          M1/M2 checklist + daily log
```

## Flow chơi

```
MainMenu
  ↓ Bắt đầu
Tutorial (đèn → giấy → khung → cửa)
  ↓
Village (gặp Mira → đề nghị vào mơ)
  ↓
Dream Mira (3 puzzle + ritual mặt nạ) → unlock Theo
  ↓
Dream Theo (3 puzzle + ritual máy bay giấy) → unlock Rell
  ↓
Dream Rell (3 puzzle + ritual cửa phía trước) → unlock Lina
  ↓
Dream Lina (3 puzzle + ritual chìa khoá) → all realized
  ↓
Ending — 4 NPC nói lời cuối + bông hoa
```
