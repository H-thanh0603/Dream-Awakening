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
