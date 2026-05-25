# Màn Mira — "Chiếc Mặt Nạ Trước Gương"

Áp dụng nguyên bản thiết kế từ `D:\màn chơi mira.docx`.
Hiện đã hiện thực hoá **toàn bộ MVP-1 + MVP-2 + MVP-3**.

- ✅ Phòng Trung Tâm (hub, cửa 4 khe)
- ✅ Phòng Gương Vỡ
- ✅ Hành Lang Mặt Nạ
- ✅ Thư Viện Ký Ức Lộn Xộn
- ✅ Vườn Hình Học
- ✅ Xưởng Chân Dung Trừu Tượng
- ✅ Nghi Thức Cuối: Gỡ Mặt Nạ

## 1. Sơ đồ khu vực

```
                              [Thư Viện Ký Ức]    (locked – MVP-2)
                                     |
[Phòng Gương Vỡ] -- [Phòng Trung Tâm] -- [Hành Lang Mặt Nạ]
                                     |
                               [Vườn Hình Học]    (locked – MVP-2)
                                     |
                          [Xưởng Chân Dung]       (locked – MVP-3)
                                     |
                          [Cánh Cửa Tỉnh Mộng]
```

Người chơi spawn ở **Phòng Trung Tâm**. Cánh cửa tỉnh mộng có 4 khe —
mỗi khe nhận 1 vật phẩm thu được từ 1 khu. MVP-1 chỉ mở 2 khe đầu
(Mảnh Gương + Mảnh Mặt Nạ), 2 khe còn lại đang khoá xám và sẽ mở khi triển khai
MVP-2/3.

## 2. Nhân vật

| ID                 | Vai trò                                                     | Sprite                                       |
|--------------------|-------------------------------------------------------------|----------------------------------------------|
| `mira`             | NPC trung tâm, ban đầu đeo mặt nạ                           | `dream_mira/mirror_clone.png`                |
| `mira_small`       | "Mira Nhỏ" — phiên bản tuổi thơ, theo người chơi sau đoạn ký ức | `dream_mira/child_npc.png`               |
| `whisper_crowd`    | Bóng đám đông trong Phòng Gương Vỡ và Hành Lang Mặt Nạ      | `dream_mira/whisper_shadow.png`              |
| `mirror_face`      | Khuôn mặt trong Gương Thật, hiện ký ức quá khứ              | `dream_mira/mirror_warped.png` → real        |
| `mask_face`        | "Gương mặt trừu tượng" cuối Hành Lang Mặt Nạ                | tổ hợp 6 mặt nạ                              |

## 3. Vật phẩm

Inventory IDs mới được giới thiệu (đăng ký với InventoryManager):

| ID                  | Mô tả                                | Nguồn                                  |
|---------------------|--------------------------------------|----------------------------------------|
| `hairpin`           | Kẹp tóc cong                         | Bàn trang điểm                         |
| `silver_key`        | Chìa khóa bạc                        | Bàn trang điểm                         |
| `curtain_cord`      | Dây kéo rèm                          | Ngăn kéo (mở bằng silver_key)          |
| `eye_paper`         | Mảnh giấy 4 con mắt                  | Ngăn kéo                               |
| `mirror_shard_1..4` | 4 mảnh gương                         | Đèn / Sau rèm / Rương / Tường khe      |
| `cat_memory`        | Ký ức "Con mèo dưới mưa"             | Rương sau khi giải tranh trượt         |
| `mirror_real`       | Mảnh phản chiếu (nhỏ)                | Sau khi ghép Gương Thật                |
| `mask_smile`        | Mặt nạ cười                          | Hành Lang Mặt Nạ                       |
| `mask_quiet`        | Mặt nạ im lặng                       | Hành Lang Mặt Nạ                       |
| `mask_obedient`     | Mặt nạ ngoan ngoãn                   | Hành Lang Mặt Nạ                       |
| `mask_angry`        | Mặt nạ giận dữ (bị buộc dây)         | Hành Lang Mặt Nạ                       |
| `mask_tired`        | Mặt nạ mệt mỏi                       | Hành Lang Mặt Nạ                       |
| `mask_fear`         | Mặt nạ sợ hãi                        | Sau cột (chỉ hiện qua phản chiếu)      |
| `mask_cracked`      | Mảnh mặt nạ nứt                      | Phần thưởng cuối Hành Lang             |
| `mask_perfect`      | Mặt nạ cười hoàn hảo                 | Trung tâm hành lang, dùng ở Nghi Thức  |

## 4. Puzzle chính (MVP-1)

### 4.1. Phòng Gương Vỡ — chuỗi 4 puzzle

1. **Bật đèn**: Nhặt `hairpin` ở bàn trang điểm → tương tác với `StuckSwitch`. Mở khoá: `mirror_shard_1`.
2. **Mở rèm**: Dùng `silver_key` mở ngăn kéo → lấy `curtain_cord` + `eye_paper` → kéo rèm. Mở khoá: `mirror_shard_2`.
3. **Tranh mèo trượt**: 3x3 sliding tile puzzle hiện qua UI panel khi tương tác với rương. Khi đúng → rương mở → `mirror_shard_3` + `cat_memory`.
4. **Ký hiệu con mắt**: 4 `Rotator` mỗi cái 4 hướng — phải khớp `eye_paper` (Lên/Phải/Xuống/Trái). Mở ô tường: `mirror_shard_4`.
5. **Ghép Gương Thật**: 4 `PlaceSlot` quanh khung gương lớn. Khi đủ 4 mảnh → cinematic "Che lại đi" + cập nhật Sổ Mộng + nhận `mirror_real`.

### 4.2. Hành Lang Mặt Nạ

1. **Tìm mặt nạ thiếu**: Có 1 tấm gương phản chiếu ngược (chỉ hiện vật ở phía sau). Người chơi phải đứng trước nó để thấy `mask_fear` nằm sau cột — quay lại nhặt.
2. **Xếp mặt nạ theo 2 hàng**: 6 `MaskSlot` thành lưới 3 cột × 2 hàng.
   - Hàng trên (mặt người khác thấy): cần các mặt nạ thuộc nhóm "outer"
     `{mask_smile, mask_obedient, mask_quiet}`
   - Hàng dưới (cảm xúc bị che): `{mask_fear, mask_tired, mask_angry}`
   - Sai → tiếng thì thầm + giảm Lucidity nhẹ.
   - Đúng → 6 mặt nạ glow, gương mặt trừu tượng "mở miệng" rơi ra `mask_cracked`.

### 4.3. Phòng Trung Tâm — Cánh cửa 4 khe

- Khe 1 nhận `mirror_real` → phát sáng → mở cửa Hành Lang Mặt Nạ (đã sẵn mở từ đầu nhưng visual)
- Khe 2 nhận `mask_cracked` → phát sáng → mở Nghi Thức Cuối
- Khe 3 / Khe 4: xám, kẹp ô vuông `?`. Hover hiện `"Khoá — chương sau"`.

### 4.4. Nghi Thức Cuối: Gỡ Mặt Nạ

Sau khi đặt đủ 2 vật ở Phòng Trung Tâm, Mira xuất hiện ở giữa phòng (vẫn đeo mặt nạ trắng). Gameplay:

1. Tương tác với Mira → lệnh "Dẫn Mira đến Gương Thật". Mira đi theo người chơi.
2. Đặt Gương Thật vào trục giữa (slot ritual_mirror).
3. Dùng item `mirror_real` (Mảnh phản chiếu) → spawn Mira Nhỏ đứng cạnh.
4. Quay lại Hành Lang Mặt Nạ — `mask_perfect` xuất hiện ở giữa tường (sau khi puzzle 4.2 đã giải). Nhặt về.
5. Đặt `mask_perfect` xuống slot ritual_mask trước gương.
6. Phím tắt `E` để **đập vỡ mặt nạ**:
   - Nếu `Gương Thật` chưa sáng / chưa có Mira Nhỏ / chưa có mask_perfect → text cảnh báo "Không thể gỡ một lớp phòng vệ nếu chưa có gì thay thế".
   - Đủ điều kiện → animation: mặt nạ vỡ thành nhiều mảnh, các mảnh bay vào khung gương (particles), Mira tháo mặt nạ trắng. Phát `mira_ritual` dialogue. Set flag `mira_realized`. Cửa tỉnh mộng mở. Fade về Village.

## 5. Hiệu ứng & cảm xúc

| Hiệu ứng                  | Trigger                                  | Thực hiện                                                     |
|---------------------------|------------------------------------------|---------------------------------------------------------------|
| Vignette tím              | Vào Phòng Gương Vỡ chưa bật đèn          | `CanvasModulate` tối → tween về 1.0 khi bật đèn               |
| Tia sáng cửa sổ           | Sau khi mở rèm                           | `Light2D` energy 0 → 1 trong 0.6s                             |
| Tiếng thì thầm "Che lại"  | Khi soi Gương Thật + mỗi lần ghép sai mask | Audio sfx `whisper` + Label fade in/out                       |
| Rung camera               | Đập vỡ mặt nạ                            | Camera `shake_intensity` qua tween 0.4s                       |
| Particles mảnh mặt nạ     | Đập vỡ mặt nạ                            | `CPUParticles2D` burst 24 hạt, hướng vào gương                |
| Glow lan trên mặt nạ đúng | Hành lang xếp đúng                       | `Sprite2D.modulate` trắng → vàng, tween 0.5s                  |
| Mira Nhỏ idle bob         | Khi xuất hiện cạnh Mira                  | Tween position.y ±2px loop                                    |

## 6. Sổ Mộng (notebook entries)

Categories sử dụng:
- `SYMBOL` — `mira_statue_no_face`, `mira_mask_cracked_inside`
- `MEMORY` — `mira_cat`, `mira_crowd_laugh`, `mira_smile_for_others`
- `HINT` — `eye_order`, `mask_two_rows`, `ritual_steps`
- `OBJECTIVE` — set qua `NotebookManager.set_objective()`

## 7. Test playthrough

Đường đi tối thiểu:
```
Spawn Trung Tâm → đọc Tượng + Mặt nạ → Phòng Gương Vỡ
→ nhặt hairpin → bật đèn → mảnh 1
→ nhặt silver_key → mở ngăn kéo → curtain_cord + eye_paper → mở rèm → mảnh 2
→ giải sliding cat → mảnh 3 + cat_memory
→ xoay 4 con mắt theo eye_paper → mảnh 4
→ ghép gương → mirror_real
→ về Trung Tâm đặt vào khe 1
→ Hành Lang Mặt Nạ → tìm mask_fear sau cột (qua phản chiếu) → xếp 2 hàng → mask_cracked
→ về Trung Tâm đặt vào khe 2 → Nghi Thức Cuối mở
→ dẫn Mira → đặt mặt nạ → đập vỡ → mira_realized → cửa tỉnh mộng
```


## 8. MVP-2/3 — 3 khu mở rộng

### 8.1. Sơ đồ map (mở rộng)

Thay vì chỉ 2×2 quadrant, world giờ là 3×3 (tổng 1440 × 810 px). 3 khu mới
được kết nối từ Phòng Trung Tâm bằng **Portal** (`scripts/dreams/Portal.gd`).
Portal tự khoá/mở theo flag.

```
[Central] [MirrorRoom] [Library]      ← row 0 (y 0..270)
[MaskHall]  [Ritual]   [    -    ]    ← row 1 (y 270..540)
[Garden ]  [Studio ]   [    -    ]    ← row 2 (y 540..810)
```

Camera quadrant logic trong `MiraLevel._update_camera_for_room()` đã được
mở rộng để hỗ trợ grid 3×3.

### 8.2. Thư Viện Ký Ức (`Library`)

Có 4 puzzle phụ + 1 hộp khoá tổng hợp:

| Puzzle              | Script                  | Reward                             |
|---------------------|-------------------------|------------------------------------|
| Lịch sử Việt Nam    | `LibraryOrderShelf.gd`  | flag `mira_library_history_done`   |
| Ghép văn học        | `LiteratureMatch.gd`    | flag `mira_library_lit_done`       |
| Sắp nhật ký         | `LibraryOrderShelf.gd`  | flag `mira_library_diary_done`     |
| Soi tranh "Mira cười" | `MirrorRealReveal.gd` | flag `mira_library_portrait_revealed` |
| Hộp 4 ký hiệu       | `CodeBox.gd`            | item `dried_flower`, flag `mira_library_solved` |

Yêu cầu kiến thức: thứ tự lịch sử Việt Nam (Hai Bà Trưng → Bạch Đằng → Tuyên ngôn → Điện Biên Phủ → Đổi mới), liên kết biểu tượng - chủ đề văn học, logic cảm xúc nhật ký A→B→C→D.

`MirrorRealReveal` yêu cầu người chơi mang `mirror_real` từ Phòng Gương Vỡ — củng cố ý: "phải có công cụ phản chiếu mới thấy thật".

### 8.3. Vườn Hình Học (`Garden`)

Script: `GeometryGarden.gd` + 4 `GardenPlot.gd`.

Diện tích 4 luống:
- Tròn r=3 → S ≈ 28.27
- Vuông a=5 → S = 25
- Chữ nhật 6×4 → S = 24
- Tam giác đáy 8, cao 3 → S = 12

Người chơi phải tưới theo thứ tự **giảm dần**: Tròn → Vuông → CN → TG.
Có **bảng giả** đánh lừa người chơi với câu "Bông hoa đẹp nhất cần nước trước".

Mỗi luống cũng đại diện cho một cảm xúc (Lòng tốt, Ổn định, Mệt mỏi, Giận dữ) — củng cố thông điệp **không thể chỉ nuôi phần đẹp**.

Reward: item `balanced_flower`, flag `mira_garden_solved`.

### 8.4. Xưởng Chân Dung (`Studio`)

Script: `PortraitStudio.gd`.

UI overlay với 10 mảnh:
- Positive: smile, flower, help_hand, light, eyes_open
- Negative: tear, crack, ask_hand, dark
- Neutral: mask

Người chơi chọn 6 mảnh. 3 đường:
- **Chỉ tích cực (≥5 positive, 0 negative)**: từ chối — "Đây là hình ảnh Mira muốn người khác thấy."
- **Chỉ tiêu cực (≥5 negative, 0 positive)**: từ chối — "Đây là nỗi đau, nhưng chưa phải toàn bộ Mira."
- **Cân bằng**: phải có đủ **3 cặp đối xứng** mới đúng:
  - smile ↔ tear
  - flower ↔ crack
  - help_hand ↔ ask_hand

Reward: `true_portrait`, flag `mira_studio_solved`.

### 8.5. Cửa 4 khe — central door

| Khe         | Vật phẩm           | Mở khu                                  |
|-------------|--------------------|-----------------------------------------|
| SlotMirror  | `mirror_real`      | Đánh dấu sang Hành Lang Mặt Nạ          |
| SlotMask    | `mask_cracked`     | Mở Nghi Thức Cuối                       |
| SlotFlower2 | `balanced_flower`  | Đặt làm cảnh báo "không chỉ nuôi đẹp"   |
| SlotPortrait2 | `true_portrait`  | Hoàn thiện cánh cửa tỉnh mộng           |

Khi đặt `mirror_real` vào SlotMirror, vật phẩm được **trả lại tay** vì còn dùng ở Nghi Thức.

### 8.6. Test playthrough mở rộng

`tools/test_mira_full.gd` mô phỏng:
1. Soi tranh chân dung bằng `mirror_real` → reveal flag.
2. CodeBox mở khi đủ 4 flag → cho `dried_flower`.
3. Tưới 4 luống đúng thứ tự → cho `balanced_flower`.
4. Tưới sai thứ tự → reset (verify reset behavior).
5. Studio: chọn chỉ tích cực → bị reject (verify rejection).
6. Studio: chọn cân bằng đủ 3 cặp đối → cho `true_portrait`.
7. Đặt `balanced_flower` + `true_portrait` vào 2 khe mới → flag slot3, slot4 set.

Tất cả ✅ PASS.
