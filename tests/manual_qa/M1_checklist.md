# M1 Smoke Test (Phase 1)

Run game (F5) → tick từng item:

- [ ] Boot scene → fade transition → MainMenu hiện
- [ ] MainMenu hiện 3 nút: "Bắt đầu", "Tiếp tục", "Thoát"
- [ ] "Tiếp tục" disabled (chưa có save)
- [ ] Click "Bắt đầu" → fade → Tutorial scene (Phase 2 có) hoặc Village
- [ ] Player di chuyển 4 hướng (WASD/arrow), không xuyên tường
- [ ] Diagonal không nhanh hơn (normalized)
- [ ] Đứng cạnh NPC → prompt "E" hiện trên đầu NPC
- []Nhấn E → DialogueBox hiện đáy màn hình
- [ ] Speaker name + text hiện đúng, có typing effect
- [ ] Nhấn E khi đang typing → skip, hiện full text
- [ ] Nhấn E khi đã full text → sang line tiếp
- [ ] Nhấn E sau line cuối → DialogueBox biến mất
- [ ] Tiếng Việt có dấu hiển thị đúng (không ô vuông)
- [ ] Esc → PauseMenu hiện, game pause
- [ ] PauseMenu nhấn "Tiếp tục" → resume
- [ ] PauseMenu nhấn "Thoát" → game thoát
- [ ] 3 NPC còn lại (Theo, Rell, Lina) bị disable (mờ), không prompt khi đứng gần
