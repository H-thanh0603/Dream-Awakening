# M2 Smoke Test (Phase 2)

- [ ] MainMenu → "Bắt đầu" → Tutorial scene chạy
- [ ] Tutorial: nói chuyện đầu tiên hiện đúng
- [ ] Tương tác Lamp → đèn sáng, background chuyển sáng, paper xuất hiện
- [ ] Nhặt paper_clue → InventoryBar hiển thị 1 ô vàng + label "▶ paper_clue"
- [ ] Đứng trước EmptyFrame, nhấn E → đặt paper, slot đổi màu xanh, dialogue tutorial_done chạy
- [ ] Flag tutorial_completed = true (xem console)
- [ ] Door enabled → tương tác → fade → Village
- [ ] Q → Notebook mở 5 tab: Mục tiêu, Biểu tượng, Ký ức, Trạng thái, Gợi ý
- [ ] Notebook hiện đúng objective + symbol "Đèn cũ" + memory "Mảnh giấy đầu tiên"
- [ ] Q hoặc Esc → đóng Notebook
- [ ] Village: HUD top-left hiện objective, top-right hiện "Q: Sổ Mộng"
- [ ] Mira ngoài đời prompt OK, dialogue chạy
- [ ] Theo, Rell, Lina mờ + không tương tác được
- [ ] Esc → PauseMenu → "Lưu game" → save (xem console "[SaveManager] saved")
- [ ] Thoát game → mở lại → MainMenu "Tiếp tục" enabled → click → load đúng state
- [ ] DreamStateManager hiển thị mira: "INTRODUCED" hoặc "DENY" (xem console)
