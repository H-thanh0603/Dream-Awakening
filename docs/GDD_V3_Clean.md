# NGƯỜI DỊCH GIẤC MƠ — Game Design Document V3

> **Bản chi tiết để giao cho AI Coding triển khai prototype**
> Thể loại: Pixel 2D · Giải đố · Suy luận · Narrative Puzzle
> Engine: Godot 4.3 · Target: Windows x64 (MVP), Web (stretch)
> Phiên bản: V3.0 · Ngày: 2026-05-25

## Mục tiêu của bản V3

V3 kế thừa toàn bộ ý tưởng từ V2, **clean lại** để:

1. Markdown chuẩn (không escape lỗi từ Word export).
2. Loại bỏ trùng lặp giữa "phần chính" và "phần lý thuyết cuối".
3. **Bổ sung 4 phụ lục** mà V2 thiếu — cần để AI Coding làm được:
   - Phụ lục A: Tech Spec (resolution, FPS, font, build target).
   - Phụ lục B: Data Schema chính thức (JSON Schema cho mọi loại file).
   - Phụ lục C: System Contracts (manager nào gọi manager nào, signal nào emit).
   - Phụ lục D: Test Scenarios cho mọi acceptance criteria.

| Mục | Nội dung chính |
| :- | :- |
| Tầm nhìn sản phẩm | Game pixel nhỏ, tập trung vào giải đố trong giấc mơ và giúp NPC tự nhận ra nỗi đau. |
| MVP | 1 làng nhỏ, 4 NPC chính, 4 giấc mơ, hệ thống notebook, puzzle, dream ritual, save/load. |
| Công nghệ | Godot 4.3, 2D top-down pixel, dữ liệu JSON cho NPC, dream, clue, puzzle. |
| Đầu ra | Prototype chơi được 30-60 phút, có tutorial, 4 màn, UI cơ bản, âm thanh nhẹ. |

---

## 1. Tóm tắt ý tưởng

**Người Dịch Giấc Mơ** là game pixel 2D góc nhìn top-down. Người chơi vào vai một nhân vật có khả năng bước vào giấc mơ của người khác. Mỗi NPC trong làng đang mắc kẹt trong một nỗi đau tâm lý nhưng không nhận ra hoặc không dám đối mặt. Nỗi đau đó xuất hiện trong giấc mơ dưới dạng biểu tượng, không gian méo mó, câu đố và ký ức bị vỡ.

Người chơi không đánh quái và không chọn đáp án trắc nghiệm để "chữa lành". Thay vào đó, người chơi quan sát, giải đố, thu thập ký ức, biến đổi các biểu tượng trong mơ và thực hiện một hành động cuối gọi là **Nghi Thức Tỉnh Mộng**. Khi đủ điều kiện, NPC tự nhìn thấy sự thật về bản thân và tự nói ra điều họ cần đối mặt.

> **Trụ cột thiết kế:** Không giảng đạo. Không ép NPC hiểu. Không biến chữa lành thành một câu trả lời đúng. Người chơi chỉ tạo điều kiện để NPC tự nhìn thấy bản thân qua ký ức và biểu tượng.

---

## 2. Pillars — những nguyên tắc không được phá

| Pillar | Ý nghĩa | Khi triển khai cần nhớ |
| :- | :- | :- |
| Giải đố bằng biểu tượng | Puzzle không chỉ là mở khóa, mà phải liên quan đến nỗi đau của NPC. | Mỗi puzzle phải làm rõ thêm một biểu tượng hoặc ký ức. |
| NPC tự nhận ra | Người chơi không chọn câu trả lời thay NPC. | Cần có cảnh phản chiếu để NPC tự thay đổi lời thoại. |
| Nhỏ nhưng sâu | Không làm map quá lớn, không thêm combat phức tạp. | Tập trung 4 màn tốt hơn 10 màn nông. |
| Hành động thay lời nói | Bước cuối là hành động trong thế giới mơ. | Ví dụ: đặt mặt nạ xuống, lắp kim đồng hồ, mở cửa từ bên trong. |
| Thay đổi vừa đủ | NPC không hết đau ngay lập tức. | Sau khi tỉnh, NPC có một thay đổi nhỏ nhưng thật. |

---

## 3. Đối tượng trải nghiệm và thời lượng

- Người chơi thích game pixel nhẹ, có câu chuyện, có suy luận, không cần phản xạ nhanh.
- Thời lượng bản MVP: **30-60 phút**.
- Một màn giấc mơ: **8-15 phút**.
- Độ khó puzzle: dễ đến trung bình, ưu tiên logic quan sát hơn là toán học.
- Mood: nhẹ nhàng, bí ẩn, cảm xúc, không kinh dị nặng.

---

## 4. Gameplay loop tổng quát

```
Ngoài đời: đi trong làng, nói chuyện với NPC
        ↓
Nhận thấy NPC có triệu chứng/giấc mơ lặp lại
        ↓
Vào giấc mơ của NPC
        ↓
Quan sát biểu tượng và không gian bất thường
        ↓
Giải puzzle để mở khóa mảnh ký ức
        ↓
Đưa ký ức về đúng vị trí trong giấc mơ
        ↓
NPC trong mơ dao động, lời thoại thay đổi
        ↓
Tìm biểu tượng trung tâm/lõi mộng
        ↓
Thực hiện Nghi Thức Tỉnh Mộng bằng hành động
        ↓
NPC tự nhận ra nỗi đau và tỉnh dậy
        ↓
Ngoài đời thay đổi một chi tiết nhỏ
        ↓
Mở khóa NPC/màn tiếp theo
```

---

## 5. Điều khiển và camera

| Thao tác | PC | Mobile (stretch) | Ghi chú triển khai |
| :- | :- | :- | :- |
| Di chuyển | WASD / phím mũi tên | Joystick ảo | Top-down 4 hướng. |
| Tương tác | E hoặc Space | Nút Interact | Kiểm tra vật thể, nói chuyện, nhặt item. |
| Mở Sổ Mộng | Q hoặc Tab | Nút Notebook | Hiện clue, memory, symbol, objective. |
| Kéo/đặt vật phẩm | Click + drag hoặc chọn item rồi E | Chạm giữ/kéo | Hỗ trợ cả kiểu chọn item để dễ code. |
| Tạm dừng | Esc | Nút Pause | Có resume, settings, quit. |

**Camera:** follow player với deadzone 32×32 px ở giữa màn hình. Smooth lerp 0.15. Trong cutscene → camera target chuyển sang điểm cố định.

---

## 6. Core systems cần làm

| System | Mục đích | MVP cần có |
| :- | :- | :- |
| **PlayerController** | Di chuyển, tương tác vật thể, chuyển scene. | Đi 4 hướng, interact area, animation idle/walk. |
| **DialogueManager** | Hiển thị lời thoại phân nhánh nhẹ. | Text box, tên NPC, next, condition theo flag. |
| **NotebookManager** | Lưu clue, memory, symbol, objective. | Danh sách item đã tìm, mô tả, trạng thái. |
| **DreamStateManager** | Theo dõi tiến trình từng giấc mơ. | Flags: puzzle solved, memory restored, ritual ready. |
| **PuzzleController** (base) | Quản lý điều kiện hoàn thành puzzle. | Trigger + condition + reward flag. |
| **InventoryManager** | Lưu vật phẩm biểu tượng. | Nhặt, hiển thị, dùng tại điểm đặt. |
| **RitualSystem** | Hành động cuối để tỉnh mộng. | Kiểm tra đủ điều kiện và chạy cutscene. |
| **SaveManager** | Lưu tiến trình. | Lưu chapter, NPC state, collected clues, solved puzzles. |
| **GameState** (autoload) | Flags toàn cục, current case, current scene. | Set/get flag, has_flag, has_all_flags. |
| **SceneLoader** | Chuyển scene có fade. | fade_to(scene_path, transition_data). |

> Chi tiết signal/method của từng manager nằm ở **Phụ lục C — System Contracts**.

---

## 7. Cấu trúc dữ liệu — overview

Nguyên tắc: **tách dữ liệu nội dung khỏi code**. Tất cả NPC, dialogue, puzzle, dream lưu dưới dạng JSON trong `res://data/`.

> Schema chi tiết (kèm field bắt buộc, validation rules) → **Phụ lục B**.

### NPC (`data/npcs/<id>.json`)

```json
{
  "id": "mira",
  "display_name": "Mira",
  "real_world_state": "hiding",
  "issue_core": "self_image_shame",
  "wrong_belief": "Mình chỉ có giá trị nếu mình đẹp.",
  "dream_scene": "res://scenes/dreams/Dream_Mira_MirrorRoom.tscn",
  "intro_dialogue": "mira_intro",
  "after_wake_dialogue": "mira_after_wake",
  "required_memories": ["mira_cat", "mira_flower", "mira_friend"],
  "ritual_id": "mira_put_mask_down",
  "unlock_flag": "tutorial_completed",
  "next_npc": "theo"
}
```

### Puzzle (`data/puzzles/<id>.json`)

```json
{
  "id": "mira_repair_true_mirror",
  "type": "collect_and_place",
  "scene": "Dream_Mira_MirrorRoom",
  "required_items": ["mirror_shard_1", "mirror_shard_2", "mirror_shard_3"],
  "target_object": "true_mirror",
  "order_matters": true,
  "correct_order": ["mirror_shard_1", "mirror_shard_2", "mirror_shard_3"],
  "reward_flags": ["mira_true_mirror_repaired"],
  "on_complete_dialogue": "mira_mirror_repaired_reaction"
}
```

### Dialogue (`data/dialogues/<id>.json`)

```json
{
  "id": "mira_dream_idle",
  "lines": [
    {
      "condition": "!mira_memory_cat_restored",
      "speaker": "Mira Mộng",
      "text": "Đừng nhìn em. Gương đã nói đủ rồi."
    },
    {
      "condition": "mira_memory_cat_restored && !mira_flower_bloomed",
      "speaker": "Mira Mộng",
      "text": "Con mèo đó... vẫn nhớ em sao?"
    }
  ]
}
```

---

## 8. Kiến trúc scene Godot

```
res://
├── scenes/
│   ├── main/
│   │   ├── MainMenu.tscn
│   │   └── Boot.tscn
│   ├── world/
│   │   └── Village.tscn
│   ├── dreams/
│   │   ├── Dream_Mira_MirrorRoom.tscn
│   │   ├── Dream_Theo_EndlessClass.tscn
│   │   ├── Dream_Rell_ClockTower.tscn
│   │   └── Dream_Lina_DoorlessRoom.tscn
│   ├── ui/
│   │   ├── DialogueBox.tscn
│   │   ├── Notebook.tscn
│   │   ├── InventoryBar.tscn
│   │   ├── PauseMenu.tscn
│   │   └── HUD.tscn
│   └── cutscenes/
│       └── DreamRitualCutscene.tscn
├── scripts/
│   ├── autoload/
│   │   ├── GameState.gd          # singleton
│   │   ├── SceneLoader.gd        # singleton
│   │   ├── DialogueManager.gd    # singleton
│   │   ├── NotebookManager.gd    # singleton
│   │   ├── InventoryManager.gd   # singleton
│   │   ├── DreamStateManager.gd  # singleton
│   │   ├── SaveManager.gd        # singleton
│   │   └── AudioManager.gd       # singleton
│   ├── player/
│   │   └── PlayerController.gd
│   ├── interaction/
│   │   ├── Interactable.gd       # base class
│   │   ├── NPC.gd
│   │   ├── PickupItem.gd
│   │   └── PlaceSlot.gd
│   ├── puzzle/
│   │   ├── BasePuzzle.gd         # abstract
│   │   ├── CollectAndPlacePuzzle.gd
│   │   ├── OrderedSlotsPuzzle.gd
│   │   ├── RotateReflectPuzzle.gd
│   │   ├── GridPushPuzzle.gd
│   │   └── AreaHoldPuzzle.gd
│   ├── ritual/
│   │   └── RitualController.gd
│   └── ui/
│       ├── DialogueBox.gd
│       ├── Notebook.gd
│       └── HUD.gd
├── data/
│   ├── npcs/*.json
│   ├── dialogues/*.json
│   ├── puzzles/*.json
│   ├── dreams/*.json
│   └── memories/*.json
└── assets/
    ├── sprites/
    ├── tilesets/
    ├── audio/
    │   ├── sfx/
    │   └── music/
    └── fonts/
        └── NotoSansMono_VN.ttf  # Unicode font hỗ trợ tiếng Việt
```

**Quy tắc autoload:** mọi manager đều là autoload singleton — script khác truy cập qua tên trực tiếp (`GameState.set_flag(...)`).

---

## 9. Cách chơi chi tiết theo trạng thái

| State | Người chơi làm gì | Game cần xử lý |
| :- | :- | :- |
| `EXPLORE_VILLAGE` | Đi quanh làng, nói chuyện NPC, chọn vào giấc mơ. | Load Village, NPC interact, objective marker. |
| `ENTER_DREAM` | Tương tác giường/biểu tượng để vào mơ. | Fade out, set current_dream_id, load dream scene. |
| `DREAM_EXPLORE` | Khám phá, nhặt clue, đọc ký hiệu. | Interactables, notebook update, ambient changes. |
| `PUZZLE_SOLVING` | Đặt vật phẩm, chỉnh thứ tự, kéo biểu tượng. | Validate condition, play feedback, set flags. |
| `MEMORY_REFLECTION` | Đưa ký ức về đúng chỗ, xem phản ứng NPC. | Dialogue đổi theo số memory restored. |
| `RITUAL_READY` | Thực hiện hành động cuối. | Check đủ flags, disable free movement, run cutscene. |
| `WAKE_UP` | NPC tỉnh dậy, ngoài đời thay đổi. | Update NPC state, unlock next case. |
| `DIALOGUE_ACTIVE` | Đọc thoại, nhấn next. | Player input lock di chuyển; chỉ E/Space hoạt động. |
| `PAUSED` | Đang ở pause menu. | Engine pause; UI vẫn xử lý input. |

**Rule cứng:** chỉ 1 state global tại 1 thời điểm. State chuyển qua `GameState.set_state(new_state)` và emit signal `state_changed(old, new)`.

---

## 10. Tutorial — màn mở đầu

Tutorial là một **giấc mơ rất nhỏ của nhân vật chính**, không dùng popup hướng dẫn dài. Người chơi học cách tương tác bằng việc tự làm.

### Flow tutorial

| Bước | Nội dung | Mục tiêu dạy |
| :- | :- | :- |
| 1 | Nhân vật chính tỉnh dậy trong căn phòng tối, có tiếng chuông nhỏ. | Onboarding mood. |
| 2 | Có chiếc đèn tắt. HUD hint: "WASD để đi". | Dạy di chuyển. |
| 3 | Đến gần đèn, HUD hint: "E để tương tác". Nhấn E → đèn sáng. | Dạy interact. |
| 4 | Ánh sáng lộ ra mảnh giấy: "Ký ức không mất, chỉ bị đặt sai chỗ." | Dạy thu thập clue. |
| 5 | HUD hint: "Q để mở Sổ Mộng". Mở notebook, clue vừa nhặt xuất hiện. | Dạy notebook. |
| 6 | Có khung tranh trống. Cầm mảnh giấy, đứng trước khung, nhấn E → đặt vào. | Dạy collect-and-place puzzle. |
| 7 | Cánh cửa mở. Bước qua → tỉnh dậy ở làng. | Dạy logic vào/ra giấc mơ. |
| 8 | Ở làng, NPC đầu làng giới thiệu Mira. Objective marker hiện trên Mira. | Dạy objective. |

**Acceptance:** sau tutorial, player có thể (1) di chuyển, (2) interact, (3) mở notebook, (4) làm 1 puzzle collect-and-place đơn giản, (5) chuyển scene Dream → Village.

> Test scenarios chi tiết → **Phụ lục D**.

---

## 11. Danh sách màn MVP

| Màn | NPC | Nỗi đau | Không gian mơ | Nghi thức tỉnh mộng |
| :- | :- | :- | :- | :- |
| 0 | (chính) | — (tutorial) | Phòng tối có đèn | Đặt mảnh giấy vào khung tranh |
| 1 | Mira | Tự ti ngoại hình | Phòng gương méo và mặt nạ | Đặt mặt nạ xuống trước gương thật |
| 2 | Theo | Sợ thất bại, ám ảnh điểm số | Lớp học vô tận | Gấp bài kiểm tra đỏ thành máy bay giấy và thả ra cửa sổ |
| 3 | Rell | Hối tiếc quá khứ | Tháp đồng hồ đứng yên | Lắp kim đồng hồ để nó chạy tiếp về phía trước |
| 4 | Lina | Cô đơn nhưng nói mình ổn | Căn phòng không cửa | Mở cửa từ bên trong bằng những ký ức kết nối |

**Thứ tự bắt buộc:** tutorial → Mira → Theo → Rell → Lina → Ending. Người chơi không thể nhảy màn — flag `prev_npc_completed` mới mở khóa NPC kế tiếp.

---

## 12. Màn 1 — Mira: Chiếc mặt nạ trước gương

### 12.1. Tóm tắt

| Mục | Nội dung |
| :- | :- |
| NPC | Mira — cô gái ít ra ngoài, luôn che mặt bằng khăn. |
| Vấn đề ngoài đời | Mira tự ti ngoại hình, né gương và tránh gặp người khác. |
| Niềm tin sai | "Mình chỉ có giá trị nếu mình đẹp." |
| Nguồn gốc | Từng bị chê bai trước đám đông, lâu dần tin rằng người khác chỉ nhìn ngoại hình. |
| Thông điệp | Ngoại hình là một phần, nhưng không phải toàn bộ giá trị con người. |
| Không gian mơ | Căn phòng gương méo, sân khấu mặt nạ, vườn hoa héo. |

### 12.2. Flow nhiệm vụ

1. Nói chuyện với Mira trước nhà. Mira từ chối ra ngoài và nói mình chỉ hơi mệt.
2. Người chơi nhận objective: "Tìm nguyên nhân giấc mơ gương vỡ của Mira."
3. Vào giấc mơ qua chiếc khăn che mặt rơi ở cửa.
4. Khám phá phòng gương méo, nhặt 3 mảnh gương thật.
5. Lắp mảnh gương vào gương trung tâm để hiện phản chiếu không bóp méo.
6. Tìm 3 mảnh ký ức tốt: cứu mèo, tặng hoa, lắng nghe bạn khóc.
7. Ghép các ký ức vào bức tranh bị xé.
8. Làm hoa héo nở bằng ánh sáng từ gương thật và ký ức tốt.
9. Dẫn Mira Mộng đến trước gương thật.
10. Thực hiện nghi thức: đặt mặt nạ xuống trước gương.
11. Xem cảnh phản chiếu: Mira thấy nhiều phần của bản thân ngoài ngoại hình.
12. Tỉnh dậy: ngoài đời Mira mở rèm cửa và không che mặt kín như trước.

### 12.3. Puzzle chi tiết

| Puzzle | Type | Input | Điều kiện đúng | Reward flag |
| :- | :- | :- | :- | :- |
| Sửa gương thật | `collect_and_place` | Nhặt 3 mảnh gương + đặt vào khung. | 3 mảnh, đúng thứ tự trái→giữa→phải. | `mira_true_mirror_repaired` |
| Ghép tranh ký ức | `ordered_slots` | Kéo 3 mảnh tranh vào bức tranh rách. | Mỗi mảnh đúng vị trí theo hình bóng. | `mira_painting_restored` |
| Làm hoa nở | `rotate_reflect` | Xoay 2 gương nhỏ để tia sáng chạm chậu hoa. | Đã hoàn thành puzzle ghép tranh. | `mira_flower_bloomed` |
| Nghi thức mặt nạ | `ritual` | Đặt mặt nạ xuống trước gương. | Đủ 3 reward flag trên + Mira ở vùng ritual. | `mira_realized` |

### 12.4. Lời thoại mẫu

**Ngoài đời — trước khi vào mơ:**
> Mira: Đừng nhìn em lâu quá... em không quen.
> Player: Dạo này em ngủ không ngon sao?
> Mira: Trong mơ có rất nhiều gương. Gương nào cũng nói cùng một điều.

**Trong mơ — phủ nhận:**
> Mira Mộng: Gương không nói dối. Chỉ có em là khó nhìn thôi.

**Sau ký ức cứu mèo:**
> Mira Mộng: Con mèo đó... vẫn nhớ em sao? Không, chắc chỉ là tình cờ.

**Sau hoa nở:**
> Mira Mộng: Tại sao những bông hoa lại nở khi em không thay đổi khuôn mặt này?

**Cảnh tự nhận ra:**
> Mira Mộng: Em cứ nghĩ mình chỉ là thứ phản chiếu trong gương.
> Mira Mộng: Nhưng những điều em đã làm... cũng là em.
> Mira Mộng: Em vẫn sợ bị nhìn thấy. Nhưng em không muốn biến mất sau chiếc mặt nạ nữa.

---

## 13. Màn 2 — Theo: Lớp học vô tận

### 13.1. Tóm tắt

| Mục | Nội dung |
| :- | :- |
| NPC | Theo — học sinh luôn mang sách, sợ bị hỏi bài. |
| Vấn đề ngoài đời | Sợ thất bại, đồng nhất giá trị bản thân với điểm số. |
| Niềm tin sai | "Nếu mình làm sai, mình là đồ vô dụng." |
| Không gian mơ | Lớp học kéo dài vô tận, bảng điểm đỏ, đồng hồ kiểm tra không dừng. |
| Nghi thức | Gấp bài kiểm tra đỏ thành máy bay giấy và thả ra cửa sổ. |

### 13.2. Flow nhiệm vụ

1. Gặp Theo ở thư viện. Theo nói đang ôn bài nhưng tay run, ngủ gục nhiều lần.
2. Vào giấc mơ qua cuốn vở đầy dấu gạch đỏ.
3. Trong lớp học vô tận, các bàn học chặn đường như mê cung.
4. Puzzle 1: đẩy bàn học để tạo lối đi đến bảng đen.
5. Puzzle 2: tương tác bảng — không xóa hết lỗi, chỉ khoanh lỗi đầu tiên Theo từng bị mắng.
6. Puzzle 3: tìm 3 bài làm cũ — sai, sửa lại, lời khen của bạn.
7. Đặt 3 bài làm lên bảng theo thứ tự: sai → học lại → tiến bộ.
8. Cửa sổ lớp học mở ra, nhưng bài kiểm tra đỏ vẫn đè trên bàn.
9. Nghi thức: gấp bài kiểm tra thành máy bay giấy, đưa cho Theo tự thả.
10. Theo thấy điểm số không biến mất, nhưng nó không còn nhốt mình trong lớp nữa.

### 13.3. Puzzle chi tiết

| Puzzle | Type | Cách giải | Reward flag |
| :- | :- | :- | :- |
| Mê cung bàn học | `grid_push` | Đẩy 3 bàn vào ô đánh dấu để mở lối. | `theo_path_opened` |
| Bảng lỗi | `interact_correct_hotspot` | Chọn dấu X đầu tiên (không xóa hết). | `theo_first_mistake_marked` |
| Thứ tự tiến bộ | `ordered_slots` | Đặt sai → sửa → tiến bộ. | `theo_progress_shown` |
| Máy bay giấy | `ritual` | Interact bàn gấp giấy → cửa sổ. | `theo_realized` |

### 13.4. Lời thoại mẫu

> Theo Mộng: Đừng nộp bài. Nếu nộp, mọi người sẽ thấy mình sai.
>
> *(Sau khi tìm bài sửa lại)*
> Theo Mộng: Mình từng sửa được sao? Mình cứ nhớ mỗi dấu X đỏ.
>
> *(Trước nghi thức)*
> Theo Mộng: Nếu thả nó đi, điểm số có biến mất không?
>
> *(Sau nghi thức)*
> Theo Mộng: Nó vẫn là một phần của mình... nhưng không phải là cả con người mình.

---

## 14. Màn 3 — Rell: Tháp đồng hồ đứng yên

### 14.1. Tóm tắt

| Mục | Nội dung |
| :- | :- |
| NPC | Ông Rell — thợ đồng hồ già. |
| Vấn đề ngoài đời | Hối tiếc vì không kịp nói lời xin lỗi với con trước khi con rời làng. |
| Niềm tin sai | "Nếu không quay lại quá khứ được, mọi thứ đã kết thúc." |
| Không gian mơ | Tháp đồng hồ khổng lồ, kim đồng hồ rơi, các cửa quá khứ lặp lại. |
| Nghi thức | Không quay ngược đồng hồ; lắp kim để đồng hồ chạy tiếp về phía trước. |

### 14.2. Flow nhiệm vụ

1. Gặp Rell trong tiệm đồng hồ. Đồng hồ nào cũng dừng cùng một giờ.
2. Vào giấc mơ qua chiếc đồng hồ bỏ túi không có kim.
3. Khám phá tháp đồng hồ với 3 tầng: Bánh răng, Ký ức, Mặt đồng hồ.
4. Puzzle 1: nối bánh răng để mở thang máy lên tầng ký ức.
5. Puzzle 2: chọn đúng 3 cảnh ký ức theo trình tự ngày con rời đi.
6. Puzzle 3: tìm kim phút bị kẹt trong cánh cửa quá khứ.
7. Người chơi có thể thử kéo kim quay ngược nhưng tháp rung và reset nhẹ.
8. Đưa kim lên mặt đồng hồ.
9. Nghi thức: lắp kim theo hướng đi tới, không quay về mốc cũ.
10. Rell tự nhận ra lời xin lỗi có thể bắt đầu từ hiện tại.

### 14.3. Puzzle chi tiết

| Puzzle | Type | Mục tiêu | Feedback sai |
| :- | :- | :- | :- |
| Nối bánh răng | `rotate_reflect` | Xoay 4 bánh răng để răng chạm đúng hướng. | Bánh răng kẹt, phát tiếng cạch. |
| Trình tự ký ức | `ordered_slots` | Sắp: cãi nhau → con rời đi → lá thư chưa gửi. | Ký ức mờ lại nếu sai thứ tự. |
| Kim phút | `collect_and_place` | Mở cửa quá khứ bằng lá thư chưa gửi. | Cửa đóng nếu thiếu memory. |
| Không quay ngược | (anti-pattern) | Nếu kéo kim ngược 3 lần, Rell nói "Càng kéo, nó càng đau." | Không game over, chỉ nhắc qua biểu tượng. |

### 14.4. Lời thoại mẫu

> Rell Mộng: Chỉ cần quay lại ngày đó. Chỉ cần một phút thôi.
>
> *(Sau khi thấy lá thư chưa gửi)*
> Rell Mộng: Ta đã viết... nhưng không đủ can đảm gửi đi.
>
> *(Khi người chơi kéo kim ngược)*
> Rell Mộng: Không, không đúng... càng quay lại, căn phòng càng lạnh.
>
> *(Sau nghi thức)*
> Rell Mộng: Đồng hồ không đưa ta về hôm qua. Nó chỉ nhắc ta rằng hôm nay vẫn còn chạy.

---

## 15. Màn 4 — Lina: Căn phòng không cửa

### 15.1. Tóm tắt

| Mục | Nội dung |
| :- | :- |
| NPC | Lina — luôn nói "mình ổn", cười với mọi người nhưng sống khép kín. |
| Vấn đề ngoài đời | Cô đơn, không dám nhờ giúp đỡ vì sợ làm phiền. |
| Niềm tin sai | "Nếu mình nói mình buồn, mọi người sẽ rời đi." |
| Không gian mơ | Căn phòng không cửa, tranh cười giống nhau, tiếng gõ cửa không thấy nguồn. |
| Nghi thức | Mở cửa từ bên trong bằng ký ức kết nối, không phải phá tường. |

### 15.2. Flow nhiệm vụ

1. Gặp Lina ở quảng trường. Cô cười và nói mình ổn dù rõ ràng mệt.
2. Vào giấc mơ qua chiếc hộp nhạc phát giai điệu vui lặp lại.
3. Trong phòng không cửa có nhiều tranh Lina đang cười giống nhau.
4. Puzzle 1: chỉnh các bức tranh theo cảm xúc thật: vui → lo → buồn → khóc → bình yên.
5. Puzzle 2: tìm nguồn tiếng gõ cửa bằng cách áp tai vào 4 bức tường.
6. Puzzle 3: nhặt các sợi chỉ kết nối từ ký ức bạn bè từng quan tâm Lina.
7. Dùng sợi chỉ nối tranh Lina thật với các ký ức ngoài phòng.
8. Cửa hiện ra, nhưng tay nắm nằm ở phía trong.
9. Nghi thức: để Lina tự mở cửa từ bên trong, người chơi chỉ giữ ánh sáng không tắt.
10. Lina tỉnh dậy và lần đầu nói: "Hôm nay mình không ổn lắm, nhưng mình muốn thử nói ra."

### 15.3. Puzzle chi tiết

| Puzzle | Type | Cách giải | Ý nghĩa |
| :- | :- | :- | :- |
| Tranh cảm xúc | `ordered_slots` | 5 tranh — sắp đúng thứ tự cảm xúc. | Cho phép nhiều cảm xúc cùng tồn tại. |
| Tiếng gõ cửa | `interact_correct_hotspot` | Tìm tường có âm thanh thật, không phải tiếng hộp nhạc. | Nỗi cô đơn vẫn đang gọi từ bên ngoài. |
| Sợi chỉ kết nối | `collect_and_place` | Nối chỉ từ Lina đến từng ký ức. | Mối quan hệ không biến mất dù cô tự khép mình. |
| Giữ ánh sáng | `area_hold` | Đứng gần đèn, giữ tương tác cho đến khi Lina mở cửa. | Người chơi hỗ trợ, không làm thay. |

---

## 16. Cơ chế NPC tự nhận ra nỗi đau

Đây là phần quan trọng nhất của game. NPC không tự nhiên hiểu ra sau khi puzzle xong. Tiến trình cảm xúc được code thành **state machine**.

### 16.1. State của NPC trong giấc mơ

| State | Trạng thái | Điều kiện chuyển | Biểu hiện trong game |
| :- | :- | :- | :- |
| `DENY` | Phủ nhận | Khi mới vào mơ. | Lời thoại né tránh, không nhìn biểu tượng chính. |
| `DISTURBED` | Dao động | Khôi phục 1 ký ức phản chứng. | NPC đặt câu hỏi, môi trường bớt méo. |
| `CONFRONTING` | Đối mặt | Khôi phục đủ ký ức chính. | NPC đứng gần lõi mộng, lời thoại thật hơn. |
| `RITUAL_READY` | Sẵn sàng tỉnh mộng | Puzzle trung tâm hoàn thành. | Biểu tượng cuối phát sáng. |
| `REALIZATION` | Tự nhận ra | Nghi thức hoàn tất. | Cutscene phản chiếu, NPC tự nói ra sự thật. |
| `AWAKE_CHANGED` | Tỉnh dậy | Load lại làng. | NPC ngoài đời thay đổi hành vi nhỏ. |

### 16.2. Code skeleton

```gdscript
# scripts/dream/DreamEmotionalState.gd
class_name DreamEmotionalState

enum State {
    DENY,
    DISTURBED,
    CONFRONTING,
    RITUAL_READY,
    REALIZATION,
    AWAKE_CHANGED
}
```

### 16.3. Quy tắc kháng cự

NPC **không thay đổi suy nghĩ chỉ bằng 1 bằng chứng**. Phải có nhiều mảnh ký ức phản chứng:

- 1 ký ức tốt → NPC nghi ngờ (trong state `DENY`)
- 2 ký ức tốt → NPC dao động (chuyển sang `DISTURBED`)
- 3 ký ức tốt → NPC bắt đầu đối mặt (chuyển sang `CONFRONTING`)
- 3 ký ức tốt + nghi thức → NPC tự nhận ra (chuyển sang `REALIZATION`)

---

## 17. Sổ Mộng — Notebook System

Sổ Mộng là UI quan trọng giúp người chơi không bị lạc. **Không đưa đáp án trực tiếp**, chỉ ghi lại clue để người chơi tự suy luận.

### 17.1. Tab và nội dung

| Tab | Nội dung | Ví dụ |
| :- | :- | :- |
| Mục tiêu | Nhiệm vụ hiện tại. | "Tìm 3 mảnh gương thật." |
| Biểu tượng | Các vật thể có ý nghĩa trong mơ. | "Gương méo: cách Mira nhìn bản thân." |
| Ký ức | Các memory đã khôi phục. | "Mira từng cứu một con mèo bị thương." |
| Trạng thái NPC | Lời thoại hoặc cảm xúc hiện tại. | "Mira đang dao động, chưa dám nhìn gương." |
| Gợi ý nhẹ | Hint mở dần nếu người chơi kẹt. | "Có lẽ ánh sáng từ gương thật có thể giúp hoa." |

### 17.2. Quy tắc hint

> Hint **không được nói thẳng đáp án**. Hint nên nhắc lại biểu tượng hoặc mục tiêu.
>
> Ví dụ KHÔNG viết: "Xoay gương trái 2 lần."
> Mà viết: "Ánh sáng thật cần đi qua những thứ không bóp méo."

### 17.3. Trigger hint

- Sau 60 giây người chơi không tương tác đúng → mở hint level 1.
- Sau 180 giây → mở hint level 2 (nhẹ hơn).
- Người chơi có thể tự xem hint trong notebook bất kỳ lúc nào.

---

## 18. UI cần có cho MVP

| UI | Thành phần | Ghi chú |
| :- | :- | :- |
| HUD tối giản | Objective hiện tại, icon Sổ Mộng, icon vật phẩm đang cầm. | Không hiện số liệu thừa. |
| Dialogue Box | Tên NPC, portrait nhỏ, text, nút next. | Có typing effect, cho skip bằng E. |
| Notebook | Tab trái, nội dung phải, clue dạng card. | Dễ đọc, font pixel rõ. |
| Inventory Bar | 3-5 key items. | Chỉ chứa vật phẩm puzzle, không cần item RPG. |
| Ritual Prompt | Thông báo khi đủ điều kiện nghi thức. | Ví dụ: "Gương đã sẵn sàng phản chiếu." |
| Pause Menu | Resume, Save, Load, Settings, Quit. | MVP có thể chỉ Resume / Save / Quit. |
| Fade Overlay | Black/white fade khi chuyển scene. | Component dùng cho mọi scene transition. |

**Layout HUD:**
- Top-left: objective text (max 60 ký tự).
- Top-right: notebook icon + counter "3/4 ký ức".
- Bottom-center: inventory slot đang cầm.
- Bottom-right: hint icon (nhấp nháy nếu có hint mới).

---

## 19. Asset list cho MVP

| Nhóm asset | Cần cho MVP | Số lượng gợi ý |
| :- | :- | :- |
| Player | Idle/walk 4 hướng, interact pose. | 4 hướng × 3 frame, 1 interact. |
| NPC ngoài đời | Mira, Theo, Rell, Lina, NPC phụ. | 5-8 nhân vật. |
| NPC trong mơ | Phiên bản mộng của từng NPC. | 4 nhân vật, có biến thể cảm xúc. |
| Village tileset | Đường làng, nhà, cây, quảng trường. | 1 tileset 16×16. |
| Dream Mira | Gương, mặt nạ, hoa héo/nở, tranh rách. | 20-30 sprite. |
| Dream Theo | Bàn học, bảng, bài kiểm tra, cửa sổ. | 15-25 sprite. |
| Dream Rell | Bánh răng, đồng hồ, kim, cửa ký ức. | 20-30 sprite. |
| Dream Lina | Tranh cảm xúc, hộp nhạc, sợi chỉ, cửa. | 20-30 sprite. |
| UI icons | Notebook, clue, memory, symbol, key item. | 15-20 icon. |
| SFX | Interact, clue found, puzzle solved, dream shift. | 10-15 âm thanh ngắn. |
| Music | Village theme, dream ambient, ritual theme. | 3-5 track ngắn loop. |

**Quy ước tên file:**
- Sprite: `<scope>_<entity>_<state>.png` → `dream_mira_idle.png`
- Tileset: `tileset_<location>.png` → `tileset_village.png`
- SFX: `sfx_<event>.ogg` → `sfx_clue_found.ogg`
- Music: `bgm_<location>.ogg` → `bgm_village.ogg`

---

## 20. Rủi ro và phương án giảm rủi ro

| Rủi ro | Mức độ | Cách giảm |
| :- | :- | :- |
| Nội dung cảm xúc bị sến / giảng đạo. | Cao | Dùng hình ảnh và hành động thay vì lời khuyên trực tiếp. |
| AI coding làm code rối. | Cao | Bắt buộc milestone nhỏ, module rõ, acceptance criteria cụ thể. |
| Puzzle không vui. | Trung bình | Playtest từng puzzle sớm bằng placeholder. |
| Người chơi không hiểu biểu tượng. | Trung bình | Notebook + lời thoại phản ứng + hint nhẹ. |
| Thiếu asset pixel. | Trung bình | Dùng placeholder hình chữ nhật và tileset miễn phí. |
| Save/load lỗi state. | Trung bình | Lưu flag, không lưu object scene phức tạp. |
| Font tiếng Việt hiển thị sai dấu. | Trung bình | Chốt font NotoSans Mono CJK ngay từ đầu, test với chuỗi dài có dấu nặng/ngã. |
| Scope phình to. | Cao | Khóa MVP ở 4 NPC. Mọi feature ngoài checklist phải defer. |

---

## 21. Những thứ KHÔNG làm trong MVP

- Không combat, không máu, không level, không chỉ số RPG.
- Không hệ thống relationship lớn như Stardew Valley.
- Không nhiều ending phức tạp ở MVP (chỉ 1 ending).
- Không procedurally generated dream — mỗi dream thiết kế thủ công.
- Không quá 4 NPC chính.
- Không cần pixel art hoàn chỉnh ngay — dùng placeholder trước, polish sau.
- Không voice acting.
- Không co-op / multiplayer.
- Không lưu cloud — chỉ lưu local `user://save.json`.

---

## 22. Ending MVP

Sau khi giúp 4 NPC tỉnh mộng, người chơi phát hiện giấc mơ của họ đều có một chi tiết chung: **một cánh cửa trắng ở rìa ký ức**. Đây là hook để phát triển bản full game.

Bản MVP kết thúc bằng cảnh cả 4 NPC xuất hiện ở quảng trường, mỗi người có thay đổi nhỏ:
- **Mira** mở rèm và tưới hoa.
- **Theo** học cùng bạn thay vì một mình.
- **Rell** viết lá thư đầu tiên.
- **Lina** nói thật rằng hôm nay cô không ổn nhưng muốn ở lại với mọi người.

> **Thông điệp kết thúc MVP:** Tỉnh mộng không phải là hết đau. Tỉnh mộng là khoảnh khắc một người bắt đầu dám nhìn vào nỗi đau của mình mà không còn ở một mình.

---

## 23. Task breakdown cho AI Coding

### 23.1. Milestone 1 — Khung game playable (2-3 ngày)

| Task | Mô tả | Acceptance | File |
| :- | :- | :- | :- |
| M1.1 | Setup project Godot 4.3, resolution 480×270, input map. | Chạy được Boot.tscn → MainMenu.tscn. | `project.godot` |
| M1.2 | Tạo 8 autoload singleton (rỗng, chỉ class skeleton). | Tất cả load không lỗi khi chạy game. | `scripts/autoload/*.gd` |
| M1.3 | PlayerController: di chuyển 4 hướng, collision. | Đi không xuyên tường, animation idle/walk placeholder. | `scripts/player/PlayerController.gd` |
| M1.4 | Interactable base class + InteractArea. | NPC/door/item dùng chung base, hiện prompt "E to interact". | `scripts/interaction/Interactable.gd` |
| M1.5 | SceneLoader với fade transition. | Chuyển Village ↔ Dream có fade 0.5s. | `scripts/autoload/SceneLoader.gd` |
| M1.6 | DialogueBox UI + DialogueManager. | NPC nói được 3 đoạn liên tiếp, có typing effect, skip bằng E. | `scripts/ui/DialogueBox.gd` |
| M1.7 | Village scene placeholder với 4 NPC. | Đi đến gần NPC, nhấn E ra dialogue. | `scenes/world/Village.tscn` |
| M1.8 | Pause menu (Esc). | Resume / Quit hoạt động. | `scenes/ui/PauseMenu.tscn` |

### 23.2. Milestone 2 — Systems nội dung (3-4 ngày)

| Task | Mô tả | Acceptance |
| :- | :- | :- |
| M2.1 | GameState flags: set/get/has_all_flags. | Puzzle có thể mở khóa dựa trên flag. |
| M2.2 | Notebook UI + NotebookManager. | Nhặt clue → notebook tự cập nhật, có 5 tab. |
| M2.3 | InventoryManager + InventoryBar UI. | Cầm item, đặt vào slot đúng → consume. |
| M2.4 | BasePuzzle + 5 puzzle types (collect_and_place, ordered_slots, rotate_reflect, grid_push, area_hold). | Mỗi type có demo scene chạy được. |
| M2.5 | DialogueManager đọc JSON, evaluate condition. | Cùng 1 dialogue ID hiển thị câu khác nhau theo flag. |
| M2.6 | SaveManager: save/load JSON `user://save.json`. | Thoát game vào lại giữ flags + inventory + notebook. |
| M2.7 | DreamStateManager: track state mỗi NPC. | NPC đổi dialogue theo state DENY → DISTURBED → ... |
| M2.8 | Tutorial scene hoàn chỉnh. | Player làm xong tutorial, unlock Mira. |

### 23.3. Milestone 3 — Màn Mira hoàn chỉnh (3-4 ngày)

| Task | Mô tả | Acceptance |
| :- | :- | :- |
| M3.1 | Scene Dream_Mira_MirrorRoom. | Player khám phá được toàn màn. |
| M3.2 | Puzzle gương (collect_and_place). | Hoàn thành mở vùng tranh ký ức. |
| M3.3 | Puzzle tranh ký ức (ordered_slots). | Notebook thêm 3 memory, Mira đổi thoại. |
| M3.4 | Puzzle hoa nở (rotate_reflect). | Hoa đổi sprite héo → nở. |
| M3.5 | Ritual mặt nạ + cutscene. | Mira tỉnh, village state thay đổi. |
| M3.6 | Mira ngoài đời thay đổi sau tỉnh. | Mira mở rèm, có dialogue mới. |

### 23.4. Milestone 4 — Theo, Rell, Lina (5-7 ngày)

| Màn | Tasks chính | Acceptance |
| :- | :- | :- |
| Theo | Mê cung bàn học (grid_push), thứ tự bài làm, máy bay giấy. | Chơi trọn màn và unlock Rell. |
| Rell | Bánh răng (rotate_reflect), trình tự ký ức, kim đồng hồ. | Chơi trọn màn và unlock Lina. |
| Lina | Tranh cảm xúc, sợi chỉ, giữ ánh sáng (area_hold). | Chơi trọn màn và mở ending MVP. |

### 23.5. Milestone 5 — Polish & Ending (2 ngày)

| Task | Mô tả |
| :- | :- |
| M5.1 | Ending cutscene: 4 NPC ở quảng trường, thay đổi nhỏ. |
| M5.2 | Audio polish: thêm SFX/music cho mọi puzzle event. |
| M5.3 | Bug pass: chơi từ đầu đến cuối, fix bug. |
| M5.4 | Build Windows .exe, test trên máy sạch. |

**Tổng thời lượng dự kiến:** 15-20 ngày làm việc.

---

## 24. Prompt mẫu để giao cho AI Coding

### 24.1. Prompt khởi tạo

```
Bạn là AI coding triển khai prototype game Godot 4.3 tên "Người Dịch Giấc Mơ".

CONTEXT:
- Đọc full GDD_V3_Clean.md trước khi code.
- Đọc Phụ lục A (Tech Spec) để biết resolution, FPS, font.
- Đọc Phụ lục B (Data Schema) để biết format JSON.
- Đọc Phụ lục C (System Contracts) để biết signal/method giữa các manager.

NGUYÊN TẮC:
- Pixel 2D top-down, KHÔNG combat, KHÔNG jump scare.
- Gameplay: khám phá, dialogue, notebook, key-item puzzle, dream ritual.
- KHÔNG dùng lựa chọn trắc nghiệm để chữa lành NPC.
- Tiến triển cảm xúc PHẢI thông qua hành động biểu tượng.
- Code chia module: GameState, DialogueManager, NotebookManager, PuzzleController, SaveManager.
- Mỗi puzzle type là 1 class extends BasePuzzle.
- Dùng placeholder sprite hình chữ nhật nếu chưa có asset thật.

TASK HIỆN TẠI: Làm Milestone 1 (M1.1 → M1.8).
Mỗi task khi xong gửi diff + screenshot Godot Editor.

KHI BẾ TẮC: hỏi lại tôi, KHÔNG tự ý mở rộng scope.
```

### 24.2. Prompt cho từng milestone

Khi giao milestone tiếp theo, copy nguyên prompt khởi tạo + thêm:

```
TASK HIỆN TẠI: Milestone <N>.
- Đọc lại Phụ lục C cho contract của manager bạn sắp đụng vào.
- Đọc Phụ lục D (Test Scenarios) cho task này.
- Sau khi code, chạy test và báo cáo từng test pass/fail.
```

---

## 25. Checklist MVP hoàn thành

| Hạng mục | Done? |
| :- | :- |
| Main menu vào được game | ☐ |
| Player di chuyển và tương tác ổn | ☐ |
| Village có 4 NPC chính | ☐ |
| Dialogue system hoạt động theo flag | ☐ |
| Notebook lưu clue/memory/symbol | ☐ |
| Inventory key item hoạt động | ☐ |
| 5 puzzle component (collect_and_place, ordered_slots, rotate_reflect, grid_push, area_hold) đều test pass | ☐ |
| Màn tutorial hoàn thành | ☐ |
| Màn Mira hoàn chỉnh | ☐ |
| Màn Theo hoàn chỉnh | ☐ |
| Màn Rell hoàn chỉnh | ☐ |
| Màn Lina hoàn chỉnh | ☐ |
| Save/load cơ bản | ☐ |
| Có âm thanh interact/puzzle/cutscene | ☐ |
| Có ending MVP sau màn Lina | ☐ |
| Build Windows .exe chạy trên máy sạch | ☐ |

---

## 26. Phụ chương — Lý thuyết thiết kế (giữ riêng)

> Phần này là tài liệu *triết lý thiết kế*, không phải spec triển khai. AI Coding KHÔNG cần đọc phần này để code MVP. Giữ lại để tham khảo khi viết script/dialogue mới.

### 26.1. Công thức "Hành Động Tỉnh Mộng"

```
Nỗi đau → Biểu tượng sai lệch → Ký ức bị che giấu →
Vật phẩm biểu tượng → Hành động đánh thức → Biến đổi giấc mơ
```

### 26.2. Bảng tham chiếu nỗi đau ↔ nghi thức

| Nỗi đau | Biểu tượng | Hành động đánh thức |
| :- | :- | :- |
| Tự ti ngoại hình | Gương méo, mặt nạ | Đặt mặt nạ xuống trước gương thật. |
| Sợ thất bại | Bài kiểm tra vô tận | Gấp tờ điểm thành máy bay giấy, thả ra cửa sổ. |
| Cô đơn | Căn phòng không cửa | Mở cửa từ bên trong bằng ký ức kết nối. |
| Hối tiếc | Đồng hồ đứng yên | Lắp kim chạy tiếp, không quay ngược. |
| Tội lỗi | Vết mực lan rộng | Viết tiếp trang thư xin lỗi, không lau sạch. |
| Áp lực hoàn hảo | Sân khấu không khán giả | Tắt đèn sân khấu, ngồi xuống cạnh NPC. |
| Né tránh quá khứ | Hộp khóa nhiều lớp | Trao chìa khóa cho chính NPC, không phá hộp. |
| Mất niềm tin | Vườn cây gai | Đặt ký ức tốt quanh vườn, ngồi yên đợi hoa nở. |

### 26.3. 4 bước NPC tự nhận ra

1. **NPC phủ nhận** → 2. **Người chơi tìm ký ức thật** → 3. **Ký ức được phản chiếu thành hình ảnh trong mơ** → 4. **NPC đối mặt và tự nói ra sự thật**

### 26.4. Bản Thể Mộng — character variant

Mỗi NPC nên có 2-3 phiên bản trong mơ:
- **NPC Đeo Mặt Nạ** — phần muốn che giấu bản thân.
- **NPC Nhỏ Bé** — ký ức từng bị tổn thương.
- **NPC Thật** — phần vẫn muốn được chấp nhận.

Người chơi không thuyết phục NPC thật ngay; phải giúp các bản thể này gặp nhau trong cảnh phản chiếu cuối.

### 26.5. Câu nói NPC thay đổi 4 giai đoạn

| Giai đoạn | Đặc điểm | Ví dụ Mira |
| :- | :- | :- |
| 1. Phủ nhận | Né tránh, đổ lỗi cho người khác. | "Đừng nhìn tôi. Gương chỉ nói sự thật." |
| 2. Dao động | Đặt câu hỏi, ngạc nhiên. | "Người đó nhớ chuyện này sao? Tôi tưởng chẳng ai để ý." |
| 3. Đối mặt | Bắt đầu thừa nhận. | "Đây cũng là tôi sao? Không chỉ là khuôn mặt này..." |
| 4. Tỉnh mộng | Thay đổi nhỏ, không tuyệt đối. | "Tôi vẫn chưa thể yêu bản thân ngay... nhưng tôi không muốn trốn nữa." |

> **Quan trọng:** câu giai đoạn 4 KHÔNG được kiểu "Tôi hiểu rồi, tôi đẹp từ bên trong." Phải chân thật, để ngỏ.

---

---

# PHỤ LỤC A — TECH SPEC

## A.1. Engine & Build target

| Mục | Giá trị | Lý do |
| :- | :- | :- |
| Engine | **Godot 4.3.stable** | Stable mới nhất, tốt cho 2D pixel, có Tilemap V2. |
| Ngôn ngữ | GDScript (chính), GDShader cho dream visual | Dễ đọc, nhanh prototype. |
| Build target chính | Windows x64 | Đa số máy đồ án sinh viên VN. |
| Build target stretch | HTML5 (Web) | Demo online cho hội đồng. |
| Build target loại trừ | Linux/macOS/Mobile | Out of scope MVP. |

## A.2. Display & Rendering

| Setting | Value |
| :- | :- |
| Base resolution | **480 × 270** (16:9 internal) |
| Window display | 1440 × 810 (3× upscale) |
| Stretch mode | `viewport` |
| Stretch aspect | `keep` |
| Frame rate cap | 60 FPS lock |
| V-Sync | Enabled |
| Pixel snap | Enabled |
| Filter mode | Nearest neighbor (sprite không blur) |

## A.3. Tile size & Coordinate

| Mục | Value |
| :- | :- |
| Tile size | **16 × 16 px** |
| Player collision box | 12 × 8 (chân nhân vật) |
| Interact range | 24 px (đứng cạnh object) |
| Camera deadzone | 32 × 32 ở giữa |
| Camera lerp | 0.15 |
| Grid step (push puzzle) | 16 (1 tile/lần đẩy) |

## A.4. Font tiếng Việt

| Setting | Value |
| :- | :- |
| Font chính | **Noto Sans Mono CJK** (free, hỗ trợ đầy đủ dấu tiếng Việt) |
| Font path | `res://assets/fonts/NotoSansMono_VN.ttf` |
| Dialogue size | 12 px |
| Notebook size | 11 px |
| HUD size | 10 px |
| Title size | 24 px |
| Antialiasing | OFF (giữ pixel-feel) |
| Subpixel positioning | OFF |

> **Test bắt buộc:** chuỗi `"Người chơi đã nhặt được mảnh ký ức quá khứ — đặt vào khung tranh để tiếp tục."` phải hiển thị đầy đủ dấu, không vỡ ô.

## A.5. Audio

| Setting | Value |
| :- | :- |
| Format | OGG Vorbis (loop), WAV (SFX ngắn) |
| Sample rate | 44.1 kHz |
| Bus | Master → Music / SFX / UI (3 bus riêng) |
| Volume default | Music 0.6, SFX 0.8, UI 0.7 |
| Music loop | Bật `loop` flag trong import |

## A.6. Input map (chốt)

| Action ID | Bind PC | Mô tả |
| :- | :- | :- |
| `move_up` | W, ↑ | Đi lên |
| `move_down` | S, ↓ | Đi xuống |
| `move_left` | A, ← | Đi trái |
| `move_right` | D, → | Đi phải |
| `interact` | E, Space, Enter | Tương tác / next dialogue |
| `notebook` | Q, Tab | Mở Sổ Mộng |
| `pause` | Esc | Tạm dừng |
| `cancel` | Esc, Backspace | Đóng menu |

## A.7. Project structure (chốt)

```
project.godot
addons/                 (rỗng — không dùng plugin ngoài cho MVP)
assets/
  fonts/NotoSansMono_VN.ttf
  sprites/{player,npcs,dreams,ui,items}/
  tilesets/{village,dream_*}/
  audio/{sfx,music}/
data/
  npcs/*.json
  dialogues/*.json
  puzzles/*.json
  dreams/*.json
  memories/*.json
scenes/
  main/
  world/
  dreams/
  ui/
  cutscenes/
scripts/
  autoload/
  player/
  interaction/
  puzzle/
  ritual/
  ui/
```

## A.8. Dependencies & Plugin

**MVP KHÔNG dùng addon ngoài.** Tất cả viết bằng GDScript thuần.

Lý do: tránh dependency hell khi build, dễ maintain cho đồ án.

Nếu cần (post-MVP):
- `Dialogic 2.x` — nếu dialogue system tự viết quá rối.
- `Aseprite Wizard` — nếu artist xuất từ Aseprite.

## A.9. Performance budget

| Metric | Target |
| :- | :- |
| Memory RAM | < 200 MB |
| Build size (Windows) | < 80 MB |
| Build size (Web) | < 30 MB |
| Loading time scene | < 1.5s |
| FPS Village (ngày bình thường) | 60 stable |
| FPS Dream (có shader) | ≥ 50 |

## A.10. Build & Distribution

| Mục | Cấu hình |
| :- | :- |
| Output dir | `builds/windows/` (relative) |
| Windows binary | `NguoiDichGiacMo.exe` |
| Embed PCK | Yes (1 file duy nhất) |
| Icon | `assets/icon.png` (256×256) |
| Versioning | `0.1.0` (major.minor.patch) |
| README đi kèm | Cách chạy, hệ thống yêu cầu, credit. |

---

# PHỤ LỤC B — DATA SCHEMA (JSON Schema chính thức)

Mọi file dữ liệu trong `res://data/` PHẢI tuân thủ schema dưới đây. AI Coding nên implement validator load dữ liệu — nếu file thiếu field bắt buộc, **fail-fast**, không silent.

## B.1. Naming convention (chốt)

| Loại | Format | Ví dụ |
| :- | :- | :- |
| Flag ID | `<npc>_<event>` snake_case | `mira_true_mirror_repaired` |
| NPC ID | snake_case | `mira`, `theo`, `rell`, `lina` |
| Dialogue ID | `<npc>_<scope>_<n>` | `mira_intro_01`, `mira_dream_deny_01` |
| Puzzle ID | `<npc>_<action>_<noun>` | `mira_repair_true_mirror` |
| Memory ID | `<npc>_<keyword>` | `mira_cat`, `mira_flower` |
| Symbol ID | `<scope>_<thing>` | `mirror_distorted`, `mask_pretty` |
| Item ID | `<npc>_<item>` | `mirror_shard_1`, `mira_mask` |
| Scene file | PascalCase, `.tscn` | `Dream_Mira_MirrorRoom.tscn` |
| Script file | PascalCase, `.gd` | `PlayerController.gd` |
| Sprite | `<scope>_<entity>_<state>.png` | `dream_mira_idle.png` |

## B.2. NPC schema

```json
{
  "$schema": "npc.v1",
  "id": "string (required, unique, snake_case)",
  "display_name": "string (required, hiển thị ngoài đời)",
  "real_world_state": "enum: hiding | normal | changed (required)",
  "issue_core": "string (required, mã nỗi đau)",
  "wrong_belief": "string (required, niềm tin sai bằng tiếng Việt)",
  "dream_scene": "string (required, res:// path)",
  "intro_dialogue": "string (required, dialogue_id)",
  "after_wake_dialogue": "string (required, dialogue_id)",
  "required_memories": ["array of memory_id", "min 3"],
  "ritual_id": "string (required, ritual_id)",
  "unlock_flag": "string (required, flag bật mới mở khoá NPC này)",
  "next_npc": "string | null (NPC kế tiếp sau khi tỉnh)"
}
```

**Validation:**
- `id` không được trùng
- `dream_scene` phải tồn tại
- `required_memories` ≥ 3 phần tử

## B.3. Dialogue schema

```json
{
  "$schema": "dialogue.v1",
  "id": "string (required)",
  "lines": [
    {
      "condition": "string | null (boolean expression với flag)",
      "speaker": "string (required, tên hiển thị)",
      "text": "string (required, nội dung tiếng Việt, max 200 ký tự)",
      "portrait": "string | null (path sprite)",
      "side_effect": {
        "set_flags": ["array of flag"],
        "give_items": ["array of item_id"],
        "play_sfx": "string | null"
      }
    }
  ]
}
```

**Condition syntax:**
- `flag_a` — flag đó = true
- `!flag_a` — flag đó = false hoặc chưa set
- `flag_a && flag_b` — cả hai
- `flag_a || flag_b` — một trong hai
- Không hỗ trợ ngoặc lồng — flat expression only.

## B.4. Puzzle schema (5 type)

### B.4.1. `collect_and_place`

```json
{
  "$schema": "puzzle.v1",
  "id": "string (required)",
  "type": "collect_and_place",
  "scene": "string (required)",
  "required_items": ["array of item_id (min 1)"],
  "target_object": "string (required, tên Node trong scene)",
  "order_matters": "boolean (default: false)",
  "correct_order": "array | null (chỉ có nếu order_matters=true)",
  "reward_flags": ["array of flag (min 1)"],
  "on_complete_dialogue": "string | null"
}
```

### B.4.2. `ordered_slots`

```json
{
  "$schema": "puzzle.v1",
  "id": "string",
  "type": "ordered_slots",
  "scene": "string",
  "slots": [
    {"slot_id": "slot_1", "expected_item": "memory_cat"},
    {"slot_id": "slot_2", "expected_item": "memory_flower"},
    {"slot_id": "slot_3", "expected_item": "memory_friend"}
  ],
  "reward_flags": ["array"],
  "on_complete_dialogue": "string | null"
}
```

### B.4.3. `rotate_reflect`

```json
{
  "$schema": "puzzle.v1",
  "id": "string",
  "type": "rotate_reflect",
  "scene": "string",
  "rotators": [
    {"node_path": "Mirror1", "correct_angle_deg": 45},
    {"node_path": "Mirror2", "correct_angle_deg": 135}
  ],
  "tolerance_deg": 5,
  "reward_flags": ["array"]
}
```

### B.4.4. `grid_push`

```json
{
  "$schema": "puzzle.v1",
  "id": "string",
  "type": "grid_push",
  "scene": "string",
  "grid_size": {"w": 8, "h": 6},
  "pushable_blocks": ["block_a", "block_b", "block_c"],
  "target_cells": [
    {"block_id": "block_a", "cell":[3,4]},
    {"block_id": "block_b", "cell": [5, 2]},
    {"block_id": "block_c", "cell": [6, 4]}
  ],
  "reward_flags": ["array"]
}
```

### B.4.5. `area_hold`

```json
{
  "$schema": "puzzle.v1",
  "id": "string",
  "type": "area_hold",
  "scene": "string",
  "hold_area": "string (Area2D node path)",
  "hold_duration_sec": 5.0,
  "interrupt_resets": true,
  "reward_flags": ["array"]
}
```

## B.5. Memory schema

```json
{
  "$schema": "memory.v1",
  "id": "string (required)",
  "owner_npc": "string (required, npc_id)",
  "title_vi": "string (required, hiển thị notebook)",
  "description_vi": "string (required, mô tả ngắn 1-2 câu)",
  "icon": "string (path icon)",
  "found_in_dream": "string (dream scene id)",
  "is_counter_evidence": "boolean (true nếu là ký ức phản chứng)"
}
```

## B.6. Save file schema

```json
{
  "$schema": "save.v1",
  "version": 1,
  "saved_at_iso": "2026-05-25T10:30:00Z",
  "current_scene": "village",
  "current_case": "mira",
  "player_position": {"x": 240, "y": 135, "scene": "village"},
  "flags": {
    "tutorial_completed": true,
    "mira_intro_done": true,
    "mira_true_mirror_repaired": false
  },
  "inventory": ["mira_mask", "mirror_shard_1"],
  "notebook_entries": ["symbol_mirror", "memory_mira_cat"],
  "npc_states": {
    "mira": "disturbed",
    "theo": "locked",
    "rell": "locked",
    "lina": "locked"
  },
  "settings": {
    "music_volume": 0.6,
    "sfx_volume": 0.8
  }
}
```

**Migration:** khi tăng `version`, SaveManager phải có method `migrate_v1_to_v2(data)` chuyển dữ liệu, không xóa save cũ.

---

# PHỤ LỤC C — SYSTEM CONTRACTS

Phụ lục này định nghĩa **interface chính thức** giữa các module. AI Coding PHẢI tuân thủ contract — không tự ý thêm/bỏ method, signal.

## C.1. Sơ đồ tổng quan

```
                ┌──────────────────┐
                │   GameState      │ (autoload — single source of truth)
                │   - flags        │
                │   - current_state│
                │   - current_case │
                └─────────┬────────┘
                          │ set_flag, get_state, ...
       ┌──────────────────┼──────────────────────────┐
       ▼                  ▼                          ▼
┌─────────────┐   ┌────────────────┐   ┌──────────────────┐
│ DialogueMgr │   │ NotebookMgr    │   │ DreamStateMgr    │
└──────┬──────┘   └────────┬───────┘   └─────────┬────────┘
       │                   │                     │
       ▼                   ▼                     ▼
┌─────────────┐   ┌────────────────┐   ┌──────────────────┐
│ DialogueBox │   │ Notebook UI    │   │ NPC node (scene) │
└─────────────┘   └────────────────┘   └──────────────────┘

┌──────────────┐    ┌──────────────────┐    ┌─────────────────┐
│ InventoryMgr │    │ PuzzleController │    │ RitualController│
└──────────────┘    └──────────────────┘    └─────────────────┘
       all autoloads connect to GameState; UI listens via signal.

┌──────────────┐    ┌─────────────┐
│ SaveManager  │←───│ AudioManager│
└──────────────┘    └─────────────┘
```

## C.2. GameState (autoload)

```gdscript
# scripts/autoload/GameState.gd
class_name GameStateAutoload extends Node

signal flag_changed(flag_name: String, value: bool)
signal state_changed(old_state: String, new_state: String)
signal case_changed(old_case: String, new_case: String)

var flags: Dictionary = {}          # String -> bool
var current_state: String = "EXPLORE_VILLAGE"
var current_case: String = ""       # "mira" | "theo" | "rell" | "lina" | ""
var current_dream_id: String = ""

# === API ===
func set_flag(name: String, value: bool = true) -> void
func get_flag(name: String) -> bool          # default false nếu chưa set
func has_flag(name: String) -> bool
func has_all_flags(names: Array[String]) -> bool
func has_any_flag(names: Array[String]) -> bool
func clear_flag(name: String) -> void

func set_state(new_state: String) -> void    # emit state_changed
func set_case(new_case: String) -> void      # emit case_changed

# Boolean expression evaluator cho dialogue.condition
func evaluate(expr: String) -> bool
# Hỗ trợ: "flag_a", "!flag_a", "a && b", "a || b" (flat, no parens)
```

## C.3. SceneLoader (autoload)

```gdscript
class_name SceneLoaderAutoload extends Node

signal scene_changed(old_path: String, new_path: String)

# Fade out → load → fade in. Mặc định 0.5s mỗi chiều.
func fade_to(scene_path: String, fade_duration: float = 0.5) -> void
func reload_current() -> void
func get_current_scene_path() -> String
```

## C.4. DialogueManager (autoload)

```gdscript
class_name DialogueManagerAutoload extends Node

signal dialogue_started(dialogue_id: String)
signal dialogue_line_shown(line_index: int, total: int)
signal dialogue_ended(dialogue_id: String)

# Bắt đầu dialogue theo ID. Block player movement đến khi end.
# Nếu đang chạy dialogue khác → queue, không interrupt.
func play(dialogue_id: String) -> void

# Skip line hiện tại, sang line tiếp theo.
func next() -> void

# Force end (dùng khi player ESC).
func cancel() -> void

func is_active() -> bool
```

**Quy ước với UI:**
- `DialogueBox.tscn` listen `dialogue_started` → show.
- Listen `dialogue_line_shown` → update text.
- Listen `dialogue_ended` → hide.

## C.5. NotebookManager (autoload)

```gdscript
class_name NotebookManagerAutoload extends Node

signal entry_added(category: String, entry_id: String)
signal objective_changed(new_text: String)

enum Category {
    OBJECTIVE,
    SYMBOL,
    MEMORY,
    NPC_STATE,
    HINT
}

# === API ===
func add_entry(category: int, entry_id: String, data: Dictionary) -> void
func has_entry(category: int, entry_id: String) -> bool
func get_entries(category: int) -> Array

func set_objective(text: String) -> void
func get_objective() -> String

# Hint trigger sau N giây inactive
func register_hint(hint_id: String, after_seconds: float, text: String) -> void
```

## C.6. InventoryManager (autoload)

```gdscript
class_name InventoryManagerAutoload extends Node

signal item_added(item_id: String)
signal item_removed(item_id: String)
signal active_item_changed(old_id: String, new_id: String)

# Inventory tối đa 8 slot ở MVP
const MAX_SLOTS := 8

func add_item(item_id: String) -> bool      # false nếu full
func remove_item(item_id: String) -> bool
func has_item(item_id: String) -> bool
func get_all_items() -> Array[String]
func set_active_item(item_id: String) -> void
func get_active_item() -> String
```

---

## C.7. DreamStateManager (autoload)

```gdscript
class_name DreamStateManagerAutoload extends Node

signal npc_state_changed(npc_id: String, old: String, new: String)

# State enum cho mỗi NPC
const STATES := ["LOCKED", "INTRODUCED", "DENY", "DISTURBED", "CONFRONTING",
                 "RITUAL_READY", "REALIZATION", "AWAKE_CHANGED"]

func get_npc_state(npc_id: String) -> String
func set_npc_state(npc_id: String, new_state: String) -> void

# Tự động chuyển state dựa trên flag pattern.
# Ví dụ: nếu mira_memory_*_restored count >= 3 → CONFRONTING.
func evaluate_state_for_npc(npc_id: String) -> void

# Gọi mỗi khi flag thay đổi (auto-connect tới GameState.flag_changed).
```

## C.8. BasePuzzle (abstract)

```gdscript
# scripts/puzzle/BasePuzzle.gd
class_name BasePuzzle extends Node

signal puzzle_started(puzzle_id: String)
signal puzzle_completed(puzzle_id: String)
signal puzzle_failed(puzzle_id: String, reason: String)

@export var puzzle_id: String                 # require, match data/puzzles/<id>.json
@export var required_flags: Array[String]     # flag để puzzle có thể start
@export var auto_start: bool = true           # tự start khi enter scene

var _data: Dictionary ={}           # loaded từ JSON

func _ready() -> void:
    _data = _load_data()
    if auto_start and can_start():
        start()

func _load_data() -> Dictionary:
    var path := "res://data/puzzles/%s.json" % puzzle_id
    var f := FileAccess.open(path, FileAccess.READ)
    return JSON.parse_string(f.get_as_text())

func can_start() -> bool:
    return GameState.has_all_flags(required_flags)

func start() -> void:
    puzzle_started.emit(puzzle_id)

# Subclass MUST implement
func check_solution() -> bool:
    push_error("check_solution() must be overridden")
    return false

func complete() -> void:
    var rewards: Array = _data.get("reward_flags", [])
    for f in rewards:
        GameState.set_flag(f, true)
    var dialogue: String = _data.get("on_complete_dialogue", "")
    if dialogue != "":
        DialogueManager.play(dialogue)
    puzzle_completed.emit(puzzle_id)
```

## C.9. SaveManager (autoload)

```gdscript
class_name SaveManagerAutoload extends Node

const SAVE_PATH := "user://save.json"
const CURRENT_VERSION := 1

signal save_completed()
signal load_completed()

func save_game() -> bool                   # serialize toàn state, ghi file
func load_game() -> bool                   # đọc file, dispatch về các manager
func has_save() -> bool
func delete_save() -> void

# Migration cho version cũ
func _migrate(data: Dictionary) -> Dictionary
```

**Lưu khi nào:**
- Tự động: scene transition xong, ritual hoàn thành.
- Thủ công: từ Pause Menu → Save.
- KHÔNG autosave mỗi giây.

## C.10. AudioManager (autoload)

```gdscript
class_name AudioManagerAutoload extends Node

func play_sfx(sfx_id: String) -> void           # one-shot
func play_music(music_id: String, fade_in: float = 1.0) -> void
func stop_music(fade_out: float = 1.0) -> void
func set_volume(bus: String, value: float) -> void
```

## C.11. Quy tắc giao tiếp giữa Manager

| Quy tắc | Mô tả |
| :- | :- |
| Single source of truth | Mọi state dùng chung lưu ở `GameState`. Manager khác đọc, không cache lâu. |
| Communicate by signal | Manager KHÔNG gọi method UI trực tiếp. UI listen signal. |
| No circular call | DialogueManager KHÔNG được gọi NotebookManager rồi NotebookManager gọi lại DialogueManager trong cùng frame. |
| Idempotent set_flag | Set flag đã true → vẫn an toàn, emit signal nhưng không gây side effect. |
| One state at a time | `GameState.current_state` chỉ có 1 giá trị. Push/pop nếu cần stack. |

## C.12. Lifecycle scene Dream

```
Player tương tác item "vào mơ"
        │
        ▼
GameState.set_state("ENTER_DREAM")
GameState.current_dream_id = "mira"
        │
        ▼
SceneLoader.fade_to("res://scenes/dreams/Dream_Mira_MirrorRoom.tscn")
        │
        ▼ (fade_in done)
DreamScene._ready():
  - Load NPC state từ DreamStateManager
  - Spawn puzzle nodes có required_flags pass
  - Set initial dialogue
        │
        ▼
GameState.set_state("DREAM_EXPLORE")
        │
        ▼
[player giải puzzle, set flag, dialogue đổi, state NPC chuyển]
        │
        ▼ (đủ điều kiện ritual)
GameState.set_state("RITUAL_READY")
        │
        ▼
RitualController.start()  → cutscene
        │
        ▼
GameState.set_flag("<npc>_realized")
DreamStateManager.set_npc_state("<npc>", "AWAKE_CHANGED")
        │
        ▼
SceneLoader.fade_to("res://scenes/world/Village.tscn")
GameState.set_state("EXPLORE_VILLAGE")
SaveManager.save_game()
```

---

# PHỤ LỤC D — TEST SCENARIOS

Mỗi acceptance criteria trong Milestone 1-5 cần ít nhất 1 test scenario cụ thể. AI Coding chạy được test bằng tay (manual QA) hoặc viết unit test với GUT framework (post-MVP).

## D.1. Format chuẩn

```
TEST_ID: <Milestone>.<Task>.<TestNumber>
GIVEN: <điều kiện ban đầu>
WHEN: <hành động>
THEN: <kết quả mong đợi>
```

## D.2. Milestone 1 — Test Scenarios

### M1.3 PlayerController

**TEST_M1.3.1: Đi cơ bản 4 hướng**
- GIVEN: Player ở giữa Village.tscn (vị trí 240,135), không có obstacle.
- WHEN: Giữ phím D 1 giây.
- THEN: Player di chuyển sang phải ≥ 60 px, animation chuyển sang `walk_right`, idle về `idle_right` khi nhả phím.

**TEST_M1.3.2: Collision tường**
- GIVEN: Player đứng cạnh tường tile.
- WHEN: Giữ phím di chuyển vào tường 2 giây.
- THEN: Player KHÔNG xuyên tường. Animation vẫn chạy `walk_*` (đang cố đi). Position không đổi.

**TEST_M1.3.3: Diagonal**
- GIVEN: Player ở khoảng trống.
- WHEN: Giữ W + D cùng lúc.
- THEN: Di chuyển diagonal với tốc độ chuẩn hoá (không nhanh hơn 1 chiều). Animation theo hướng dominant.

### M1.4 Interactable

**TEST_M1.4.1: Hiện prompt**
- GIVEN: Player đứng cách NPC ≤ 24 px.
- WHEN: (chỉ đứng yên, không nhấn gì)
- THEN: Hiện UI prompt "E để tương tác" trên đầu NPC.

**TEST_M1.4.2: Trigger interact**
- GIVEN: Player ở range NPC, prompt đang hiện.
- WHEN: Nhấn E.
- THEN: Prompt biến mất. DialogueManager.is_active() = true. Player không di chuyển được.

**TEST_M1.4.3: Out of range**
- GIVEN: Player vừa ở range, prompt hiện.
- WHEN: Đi ra xa > 24 px.
- THEN: Prompt biến mất ngay frame tiếp theo.

### M1.5 SceneLoader

**TEST_M1.5.1: Fade transition**
- GIVEN: Đang ở Village.tscn.
- WHEN: Gọi `SceneLoader.fade_to("res://scenes/dreams/Dream_Mira_MirrorRoom.tscn")`.
- THEN: Màn hình fade đen 0.5s, scene đổi, fade in 0.5s. Tổng 1s. Signal `scene_changed` emit đúng 1 lần.

**TEST_M1.5.2: GameState giữ nguyên**
- GIVEN: GameState.current_case = "mira", có flag `tutorial_completed`.
- WHEN: Chuyển scene Village → Dream.
- THEN: Sau khi scene mới load, GameState vẫn giữ `current_case = "mira"` và flag.

### M1.6 DialogueBox

**TEST_M1.6.1: Hiển thị 3 line**
- GIVEN: Có dialogue ID `test_dialog_3lines` với 3 line, không condition.
- WHEN: `DialogueManager.play("test_dialog_3lines")`, nhấn E 3 lần.
- THEN: 3 line hiển thị tuần tự. Sau line thứ 3 + nhấn E → box biến mất, signal `dialogue_ended` emit.

**TEST_M1.6.2: Typing effect skip**
- GIVEN: Đang typing 1 line dài 100 ký tự.
- WHEN: Nhấn E khi mới hiện 30 ký tự.
- THEN: Hiện đầy đủ 100 ký tự ngay lập tức (skip typing). Nhấn E lần 2 → sang line tiếp.

**TEST_M1.6.3: Tiếng Việt có dấu**
- GIVEN: Line: "Em vẫn sợ bị nhìn thấy. Nhưng em không muốn biến mất sau chiếc mặt nạ nữa."
- WHEN: Hiển thị.
- THEN: Tất cả dấu nặng (sợ, mặt), dấu ngã (nữa, vẫn), dấu hỏi hiển thị đúng. Không có ô vuông □.

### M1.8 PauseMenu

**TEST_M1.8.1: Esc pause**
- GIVEN: Đang chơi Village.tscn.
- WHEN: Nhấn Esc.
- THEN: Engine pause (`get_tree().paused = true`). PauseMenu hiện. Player không di chuyển.

**TEST_M1.8.2: Resume**
- GIVEN: Pause Menu đang hiện.
- WHEN: Click Resume hoặc nhấn Esc.
- THEN: Engine resume. PauseMenu ẩn. Player input hoạt động lại.

---

## D.3. Milestone 2 — Test Scenarios

### M2.1 GameState flags

**TEST_M2.1.1: Set / get / has_flag**
- GIVEN: GameState mới khởi tạo, không có flag.
- WHEN: `GameState.set_flag("foo", true)`, sau đó `GameState.get_flag("foo")`.
- THEN: Trả về `true`. `has_flag("foo")` = true. `has_flag("bar")` = false.

**TEST_M2.1.2: has_all_flags**
- GIVEN: Set 3 flag: `a=true, b=true, c=false`.
- WHEN: `has_all_flags(["a","b"])` và `has_all_flags(["a","b","c"])`.
- THEN: Lần 1 = true, lần 2 = false.

**TEST_M2.1.3: Boolean expression evaluator**
- GIVEN: `a=true, b=false, c=true`.
- WHEN: `evaluate("a && c")`, `evaluate("!b")`, `evaluate("a || b")`, `evaluate("b && c")`.
- THEN: Lần lượt: true, true, true, false.

### M2.2 NotebookManager

**TEST_M2.2.1: Add entry & signal**
- GIVEN: Notebook rỗng.
- WHEN: `add_entry(MEMORY, "mira_cat", {...})`.
- THEN: Signal `entry_added("MEMORY", "mira_cat")` emit. `has_entry(MEMORY, "mira_cat")` = true.

**TEST_M2.2.2: Objective update HUD**
- GIVEN: HUD đang hiện objective cũ "Tìm Mira".
- WHEN: `set_objective("Sửa gương trong giấc mơ Mira.")`.
- THEN: Signal `objective_changed` emit. HUD hiện text mới sau ≤ 1 frame.

### M2.4 Puzzle types

**TEST_M2.4.1: collect_and_place hoàn thành**
- GIVEN: Puzzle `mira_repair_true_mirror` cần 3 mảnh gương theo thứ tự.
- WHEN: Player nhặt + đặt 3 mảnh đúng thứ tự.
- THEN: Signal `puzzle_completed` emit. Flag `mira_true_mirror_repaired` = true. Dialogue `mira_mirror_repaired_reaction` chạy.

**TEST_M2.4.2: collect_and_place sai thứ tự**
- GIVEN: Puzzle order_matters=true, correct_order=[s1,s2,s3].
- WHEN: Đặt s1, s3, s2.
- THEN: Signal `puzzle_failed` emit, các slot trả lại item về inventory, không set flag.

**TEST_M2.4.3: grid_push Sokoban-like**
- GIVEN: 3 block, 3 target cell. 1 block đã đúng cell.
- WHEN: Đẩy 2 block còn lại đúng vị trí.
- THEN: Signal `puzzle_completed` emit khi block cuối vào target.

**TEST_M2.4.4: rotate_reflect tolerance**
- GIVEN: Mirror1 cần 45°, tolerance 5°.
- WHEN: Xoay Mirror1 đến 47°.
- THEN: Tính là đúng (47 trong [40,50]). Nếu xoay đến 51° → không đúng.

**TEST_M2.4.5: area_hold gián đoạn**
- GIVEN: hold_duration=5s, interrupt_resets=true.
- WHEN: Player vào area giữ 3s, ra khỏi area, vào lại 3s.
- THEN: KHÔNG complete. Phải vào và giữ liên tục 5s.

### M2.5 DialogueManager condition

**TEST_M2.5.1: Skip line không match condition**
- GIVEN: Dialogue có 3 line:
  - line 1: condition `!mira_memory_cat_restored` → "Đừng nhìn em."
  - line 2: condition `mira_memory_cat_restored` → "Con mèo đó..."
  - line 3: condition null → "Cảm ơn anh."
- Set flag `mira_memory_cat_restored = true`.
- WHEN: `play(dialogue_id)`, nhấn E.
- THEN: line 1 skip, hiện line 2, nhấn E → line 3, nhấn E → end.

### M2.6 SaveManager

**TEST_M2.6.1: Save & Load round-trip**
- GIVEN: Game đang chạy, có 5 flag, 3 item, 4 notebook entry, NPC mira ở state DISTURBED.
- WHEN: `save_game()`, thoát game, mở lại, `load_game()`.
- THEN: Tất cả 5 flag + 3 item + 4 entry + state Mira = DISTURBED đều khôi phục đúng.

**TEST_M2.6.2: File path & format**
- GIVEN: Vừa save xong.
- WHEN: Đọc `user://save.json` raw.
- THEN: Là JSON valid, có field `version: 1`, `saved_at_iso`, `flags`, `inventory`, `notebook_entries`, `npc_states`.

**TEST_M2.6.3: Migration safe**
- GIVEN: Save file version cũ (version=0, missing field `npc_states`).
- WHEN: `load_game()`.
- THEN: Migration chạy, gán default npc_states tất cả LOCKED, KHÔNG crash.

### M2.7 DreamStateManager

**TEST_M2.7.1: Auto state transition**
- GIVEN: Mira đang ở state DENY, có `mira_required_memories = ["mira_cat","mira_flower","mira_friend"]`.
- WHEN: Set flag `mira_memory_cat_restored = true`.
- THEN: Mira state → DISTURBED (1 ký ức).
- WHEN tiếp: Set flag `mira_memory_flower_restored, mira_memory_friend_restored = true`.
- THEN: Mira state → CONFRONTING (đủ 3 ký ức).

### M2.8 Tutorial

**TEST_M2.8.1: Hoàn thành tutorial unlock Mira**
- GIVEN: Game mới, chưa có flag.
- WHEN: Chơi xong tutorial (làm 6 bước theo §10).
- THEN: Flag `tutorial_completed = true`. Mira ngoài đời có objective marker. NPC khác (Theo, Rell, Lina) còn locked.

---

## D.4. Milestone 3-4 — Test Scenarios mẫu (mỗi màn)

### Mira

**TEST_M3.X.1: Hoàn thành màn Mira end-to-end**
- GIVEN: Vừa hoàn thành tutorial, Mira mở khoá.
- WHEN: Chơi đầy đủ flow §12.2 từ đầu đến cuối.
- THEN: Đạt được tất cả các flag sau:
  - `mira_intro_done`
  - `mira_true_mirror_repaired`
  - `mira_painting_restored`
  - `mira_flower_bloomed`
  - `mira_realized`
- Mira state = AWAKE_CHANGED. Theo unlock. Save game tự động chạy.

**TEST_M3.X.2: Mira ngoài đời thay đổi**
- GIVEN: Mira vừa AWAKE_CHANGED.
- WHEN: Quay về Village.
- THEN: Mira sprite đổi (mở rèm, không che mặt). Dialogue mới: "Em vẫn còn ngại... nhưng hôm nay em mở cửa sổ rồi."

### Theo, Rell, Lina

Lặp pattern tương tự — mỗi màn có 1 test "end-to-end" và 1 test "ngoài đời thay đổi".

---

## D.5. Milestone 5 — Test Scenarios

### Ending

**TEST_M5.1.1: Ending trigger**
- GIVEN: 4 NPC đều AWAKE_CHANGED.
- WHEN: Quay về Village sau Lina.
- THEN: Cutscene ending tự chạy: 4 NPC ở quảng trường, mỗi người có thay đổi nhỏ. Sau cutscene → credit / "Cảm ơn bạn đã chơi."

### Build

**TEST_M5.4.1: Windows .exe chạy được**
- GIVEN: Build xong `NguoiDichGiacMo.exe` đặt vào USB.
- WHEN: Cắm vào máy Windows 10/11 SẠCH (chưa cài Godot).
- THEN: Game chạy bình thường, đầy đủ tính năng, không crash.

**TEST_M5.4.2: Tiếng Việt trên máy không có font**
- GIVEN: Máy sạch không có font Việt cài sẵn.
- WHEN: Mở dialogue tiếng Việt có dấu.
- THEN: Dấu hiển thị đúng (font đã embed vào build).

---

## D.6. Smoke test toàn bộ MVP (chốt cuối cùng)

| ID | Tên | Pass criteria |
| :- | :- | :- |
| SMOKE.1 | Chơi từ đầu đến cuối | 30-60 phút, không crash, không stuck. |
| SMOKE.2 | Save/Load mọi save point | Mọi flag, item, state khôi phục đúng. |
| SMOKE.3 | Tiếng Việt mọi UI | Không ô vuông, không vỡ ô. |
| SMOKE.4 | Performance | FPS ≥ 50 trên máy 8GB RAM. |
| SMOKE.5 | Build Web | HTML5 build chạy trên Chrome/Firefox. |

---

# CHANGELOG so với V2

| Mục | V2 | V3 |
| :- | :- | :- |
| Format | Word export, escape ký tự lỗi (`\\_`, backtick filler) | Markdown chuẩn, code block fenced |
| Trùng lặp | Phần 1-26 + "Hành Động Tỉnh Mộng" + "Phản Chiếu Ký Ức" lặp ý | Hợp nhất: spec ở §1-25, lý thuyết ở §26 |
| Tech spec | Mơ hồ ("pixel 2D", "Godot 4.x") | Chốt: Godot 4.3, 480×270, 16×16 tile, 60 FPS, NotoSans Mono CJK |
| Data schema | 2 ví dụ JSON | Schema chính thức 6 loại file (NPC, Dialogue, 5 Puzzle types, Memory, Save) + naming convention |
| System contracts | Class skeleton 1 đoạn | Interface chính thức 10 manager + lifecycle scene Dream |
| Acceptance criteria | "đi không xuyên tường" (mơ hồ) | 30+ test scenarios cụ thể (GIVEN/WHEN/THEN) |
| Tutorial | 6 bước ngắn | Thêm acceptance + test M2.8 |
| Save/Load | Có ví dụ JSON | Thêm versioning + migration policy |
| Tiếng Việt | Không nhắc | Test bắt buộc dấu nặng/ngã, font embed vào build |

# QUICK REFERENCE — đọc trước khi code

| Câu hỏi | Câu trả lời | Nơi tra |
| :- | :- | :- |
| Resolution? | 480×270 internal, 1440×810 window | §A.2 |
| Tile size? | 16×16 | §A.3 |
| Engine? | Godot 4.3.stable | §A.1 |
| Font Việt? | `res://assets/fonts/NotoSansMono_VN.ttf` | §A.4 |
| Save path? | `user://save.json`, version=1 | §B.6 + §C.9 |
| 5 puzzle types? | collect_and_place, ordered_slots, rotate_reflect, grid_push, area_hold | §B.4 |
| Manager nào emit signal nào? | §C.2-C.10 |
| Khi nào auto save? | Sau ritual + scene transition | §C.9 |
| Lifecycle scene Dream? | §C.12 |
| Test cho task X.Y? | §D.<milestone>.<task> |

# SIGN-OFF

Tài liệu này đã đủ để giao cho AI Coding (Claude/GPT/Codex) triển khai prototype.

**Khi giao task lần đầu:**
1. Gửi 1 bản full GDD_V3_Clean.md.
2. Bắt đầu Milestone 1 với prompt §24.1.
3. Kiểm tra acceptance qua test §D.2.
4. Khi M1 pass → giao M2, lặp lại.

**Tổng dòng GDD V3:** ~1500 dòng markdown chuẩn.
**Tổng acceptance test:** 30+ test scenarios.
**Tổng manager + interface:** 10 (+ BasePuzzle abstract).

Phiên bản: 3.0 — 2026-05-25 — Asia/Saigon

— Hết —
