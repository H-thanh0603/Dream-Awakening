Người Dịch Giấc Mơ - GDD V2 cho AI Coding

**NGƯỜI DỊCH GIẤC MƠ**

**Game Design Document V2 - Bản chi tiết cho AI Coding**

*Thể loại: Pixel 2D - Giải đố - Suy luận - Narrative Puzzle*

|<p>**Mục tiêu của bản V2**</p><p>Tài liệu này được viết để có thể đưa cho AI coding/agent triển khai thành prototype. Nội dung không chỉ mô tả ý tưởng, mà còn đặc tả gameplay, kịch bản màn chơi, cấu trúc dữ liệu, kiến trúc scene, các bài toán kỹ thuật dễ gặp và cách giải theo hướng thực tế.</p>|
| :- |

|**Mục**|**Nội dung chính**|
| :- | :- |
|Tầm nhìn sản phẩm|Game pixel nhỏ, tập trung vào giải đố trong giấc mơ và giúp NPC tự nhận ra nỗi đau.|
|MVP|1 làng nhỏ, 4 NPC chính, 4 giấc mơ, hệ thống notebook, puzzle, dream ritual, save/load.|
|Công nghệ đề xuất|Godot 4.x, 2D top-down pixel, dữ liệu JSON/Resource cho NPC, dream, clue, puzzle.|
|Đầu ra mong muốn|Prototype chơi được 30-60 phút, có tutorial, 4 màn, UI cơ bản, âm thanh nhẹ, có thể mở rộng.|


# **1. Tóm tắt ý tưởng**
Người Dịch Giấc Mơ là game pixel 2D góc nhìn top-down. Người chơi vào vai một nhân vật có khả năng bước vào giấc mơ của người khác. Mỗi NPC trong làng đang mắc kẹt trong một nỗi đau tâm lý nhưng không nhận ra hoặc không dám đối mặt. Nỗi đau đó xuất hiện trong giấc mơ dưới dạng biểu tượng, không gian méo mó, câu đố và ký ức bị vỡ.

Người chơi không đánh quái và không chọn đáp án trắc nghiệm để “chữa lành”. Thay vào đó, người chơi quan sát, giải đố, thu thập ký ức, biến đổi các biểu tượng trong mơ và thực hiện một hành động cuối gọi là Nghi Thức Tỉnh Mộng. Khi đủ điều kiện, NPC tự nhìn thấy sự thật về bản thân và tự nói ra điều họ cần đối mặt.

|<p>**Trụ cột thiết kế**</p><p>Không giảng đạo. Không ép NPC hiểu. Không biến chữa lành thành một câu trả lời đúng. Người chơi chỉ tạo điều kiện để NPC tự nhìn thấy bản thân qua ký ức và biểu tượng.</p>|
| :- |

# **2. Pillars - những nguyên tắc không được phá**

|**Pillar**|**Ý nghĩa**|**Khi triển khai cần nhớ**|
| :- | :- | :- |
|Giải đố bằng biểu tượng|Puzzle không chỉ là mở khóa, mà phải liên quan đến nỗi đau của NPC.|Mỗi puzzle phải làm rõ thêm một biểu tượng hoặc ký ức.|
|NPC tự nhận ra|Người chơi không chọn câu trả lời thay NPC.|Cần có cảnh phản chiếu để NPC tự thay đổi lời thoại.|
|Nhỏ nhưng sâu|Không làm map quá lớn, không thêm combat phức tạp.|Tập trung 4 màn tốt hơn 10 màn nông.|
|Hành động thay lời nói|Bước cuối là hành động trong thế giới mơ.|Ví dụ: đặt mặt nạ xuống, lắp kim đồng hồ, mở cửa từ bên trong.|
|Thay đổi vừa đủ|NPC không hết đau ngay lập tức.|Sau khi tỉnh, NPC có một thay đổi nhỏ nhưng thật.|

# **3. Đối tượng trải nghiệm và thời lượng**
- Người chơi thích game pixel nhẹ, có câu chuyện, có suy luận, không cần phản xạ nhanh.
- Thời lượng bản MVP: khoảng 30-60 phút.
- Một màn giấc mơ: 8-15 phút.
- Độ khó puzzle: dễ đến trung bình, ưu tiên logic quan sát hơn là toán học.
- Mood: nhẹ nhàng, bí ẩn, cảm xúc, không kinh dị nặng.
# **4. Gameplay loop tổng quát**
Ngoài đời: đi trong làng, nói chuyện với NPC\
↓\
Nhận thấy NPC có triệu chứng/giấc mơ lặp lại\
↓\
Vào giấc mơ của NPC\
↓\
Quan sát biểu tượng và không gian bất thường\
↓\
Giải puzzle để mở khóa mảnh ký ức\
↓\
Đưa ký ức về đúng vị trí trong giấc mơ\
↓\
NPC trong mơ dao động, lời thoại thay đổi\
↓\
Tìm biểu tượng trung tâm/lõi mộng\
↓\
Thực hiện Nghi Thức Tỉnh Mộng bằng hành động\
↓\
NPC tự nhận ra nỗi đau và tỉnh dậy\
↓\
Ngoài đời thay đổi một chi tiết nhỏ\
↓\
Mở khóa NPC/màn tiếp theo
# **5. Điều khiển và camera**

|**Thao tác**|**PC**|**Mobile nếu cần**|**Ghi chú triển khai**|
| :- | :- | :- | :- |
|Di chuyển|WASD / phím mũi tên|Joystick ảo|Top-down 4 hướng hoặc 8 hướng.|
|Tương tác|E / Space|Nút Interact|Kiểm tra vật thể, nói chuyện, nhặt item.|
|Mở Sổ Mộng|Q / Tab|Nút Notebook|Hiện clue, memory, symbol, objective.|
|Kéo/đặt vật phẩm|Click + drag hoặc chọn item rồi E|Chạm giữ/kéo|Nên hỗ trợ cả kiểu chọn item để dễ code.|
|Tạm dừng|Esc|Nút Pause|Có resume, settings, quit.|

# **6. Core systems cần làm**

|**System**|**Mục đích**|**MVP cần có**|
| :- | :- | :- |
|Player Controller|Di chuyển, tương tác vật thể, chuyển scene.|Đi 4 hướng, interact ray/area, animation idle/walk.|
|Dialogue System|Hiển thị lời thoại phân nhánh nhẹ.|Text box, tên NPC, next, condition theo state.|
|Notebook System|Lưu clue, memory, symbol, objective.|Danh sách item đã tìm, mô tả, trạng thái.|
|Dream State Manager|Theo dõi tiến trình từng giấc mơ.|Flags: puzzle solved, memory restored, ritual ready.|
|Puzzle System|Quản lý điều kiện hoàn thành puzzle.|Trigger + condition + result.|
|Inventory/Key Item|Lưu vật phẩm biểu tượng.|Nhặt, hiển thị, dùng tại điểm đặt.|
|Ritual System|Hành động cuối để tỉnh mộng.|Kiểm tra đủ điều kiện và chạy cutscene.|
|Save/Load|Lưu tiến trình.|Lưu chapter, NPC state, collected clues, solved puzzles.|

# **7. Cấu trúc dữ liệu đề xuất cho AI coding**
Nên tách dữ liệu nội dung ra khỏi code càng nhiều càng tốt. Với Godot, có thể dùng JSON, Resource (.tres), hoặc Dictionary trong script. Bản MVP có thể dùng JSON để AI coding dễ sinh dữ liệu.

// npc\_mira.json\
{\
`  `"id": "mira",\
`  `"display\_name": "Mira",\
`  `"real\_world\_state": "hiding",\
`  `"issue\_core": "self\_image\_shame",\
`  `"wrong\_belief": "Mình chỉ có giá trị nếu mình đẹp.",\
`  `"dream\_scene": "res://scenes/dreams/dream\_mira\_mirror\_room.tscn",\
`  `"intro\_dialogue": "dialogue\_mira\_intro",\
`  `"after\_wake\_dialogue": "dialogue\_mira\_after\_wake",\
`  `"required\_memories": ["mira\_cat", "mira\_flower", "mira\_friend"],\
`  `"ritual\_id": "mira\_put\_mask\_down"\
}

// puzzle\_mira\_mirror.json\
{\
`  `"id": "mira\_repair\_true\_mirror",\
`  `"scene": "dream\_mira\_mirror\_room",\
`  `"type": "collect\_and\_place",\
`  `"required\_items": ["mirror\_shard\_1", "mirror\_shard\_2", "mirror\_shard\_3"],\
`  `"target\_object": "true\_mirror",\
`  `"on\_complete\_flags": ["mira\_true\_mirror\_repaired"],\
`  `"on\_complete\_dialogue": "mira\_mirror\_repaired\_reaction"\
}
# **8. Kiến trúc scene Godot đề xuất**
res://\
`  `scenes/\
`    `main/MainMenu.tscn\
`    `world/Village.tscn\
`    `dreams/Dream\_Mira\_MirrorRoom.tscn\
`    `dreams/Dream\_Theo\_EndlessClass.tscn\
`    `dreams/Dream\_Rell\_ClockTower.tscn\
`    `dreams/Dream\_Lina\_DoorlessRoom.tscn\
`    `ui/DialogueBox.tscn\
`    `ui/Notebook.tscn\
`    `ui/InventoryBar.tscn\
`    `cutscenes/DreamRitualCutscene.tscn\
`  `scripts/\
`    `core/GameState.gd\
`    `core/SceneLoader.gd\
`    `player/PlayerController.gd\
`    `interaction/Interactable.gd\
`    `dialogue/DialogueManager.gd\
`    `notebook/NotebookManager.gd\
`    `dream/DreamStateManager.gd\
`    `puzzle/PuzzleController.gd\
`    `puzzle/PlaceItemPuzzle.gd\
`    `save/SaveManager.gd\
`  `data/\
`    `npcs/\*.json\
`    `dialogues/\*.json\
`    `puzzles/\*.json\
`    `dreams/\*.json\
`  `assets/\
`    `sprites/\
`    `tilesets/\
`    `audio/\
`    `fonts/
# **9. Cách chơi chi tiết theo trạng thái**

|**State**|**Người chơi làm gì**|**Game cần xử lý**|
| :- | :- | :- |
|ExploreVillage|Đi quanh làng, nói chuyện NPC, chọn vào giấc mơ.|Load Village, NPC interact, objective marker.|
|EnterDream|Tương tác giường/biểu tượng để vào mơ.|Fade out, set current\_dream\_id, load dream scene.|
|DreamExplore|Khám phá, nhặt clue, đọc ký hiệu.|Interactables, notebook update, ambient changes.|
|PuzzleSolving|Đặt vật phẩm, chỉnh thứ tự, kéo biểu tượng.|Validate condition, play feedback, set flags.|
|MemoryReflection|Đưa ký ức về đúng chỗ, xem phản ứng NPC.|Dialogue đổi theo số memory restored.|
|RitualReady|Thực hiện hành động cuối.|Check đủ flags, disable free movement, run cutscene.|
|WakeUp|NPC tỉnh dậy, ngoài đời thay đổi.|Update NPC state, unlock next case.|

# **10. Tutorial - Màn mở đầu ngắn**
Tutorial không nên là bảng hướng dẫn dài. Nên là một giấc mơ rất nhỏ của nhân vật chính hoặc một NPC phụ để dạy cách tương tác, notebook và hành động biểu tượng.

|**Bước**|**Nội dung tutorial**|**Mục tiêu dạy người chơi**|
| :- | :- | :- |
|1|Người chơi tỉnh dậy trong căn phòng mờ, nghe tiếng chuông nhỏ.|Dạy di chuyển.|
|2|Có một chiếc đèn tắt. Người chơi nhấn E để bật.|Dạy tương tác.|
|3|Ánh sáng lộ ra một mảnh giấy: “Ký ức không mất, chỉ bị đặt sai chỗ.”|Dạy thu thập clue.|
|4|Mở Sổ Mộng, clue vừa nhặt xuất hiện.|Dạy notebook.|
|5|Đặt mảnh giấy vào khung tranh trống, căn phòng mở cửa.|Dạy collect-and-place puzzle.|
|6|Nhân vật bước qua cửa và tỉnh dậy ở làng.|Dạy logic vào/ra giấc mơ.|

# **11. Danh sách màn MVP**

|**Màn**|**NPC**|**Nỗi đau**|**Không gian mơ**|**Nghi thức tỉnh mộng**|
| :- | :- | :- | :- | :- |
|1|Mira|Tự ti ngoại hình, nghĩ mình chỉ có giá trị nếu đẹp.|Phòng gương méo và mặt nạ.|Đặt mặt nạ xuống trước gương thật.|
|2|Theo|Sợ thất bại, bị ám ảnh bởi điểm số.|Lớp học vô tận.|Gấp bài kiểm tra đỏ thành máy bay giấy và thả ra cửa sổ.|
|3|Rell|Hối tiếc vì quá khứ, muốn quay ngược thời gian.|Tháp đồng hồ đứng yên.|Lắp kim đồng hồ để nó chạy tiếp về phía trước.|
|4|Lina|Cô đơn nhưng luôn nói mình ổn.|Căn phòng không cửa.|Mở cửa từ bên trong bằng những ký ức kết nối.|

# **12. Màn 1 chi tiết - Mira: Chiếc mặt nạ trước gương**
## **12.1. Tóm tắt màn**

|**Mục**|**Nội dung**|
| :- | :- |
|NPC|Mira - cô gái ít ra ngoài, luôn che mặt bằng khăn.|
|Vấn đề ngoài đời|Mira tự ti ngoại hình, né gương và tránh gặp người khác.|
|Niềm tin sai|“Mình chỉ có giá trị nếu mình đẹp.”|
|Nguồn gốc|Từng bị chê bai trước đám đông, lâu dần tin rằng người khác chỉ nhìn ngoại hình.|
|Thông điệp|Ngoại hình là một phần, nhưng không phải toàn bộ giá trị con người.|
|Không gian mơ|Căn phòng gương méo, sân khấu mặt nạ, vườn hoa héo.|

## **12.2. Flow nhiệm vụ**
1. Nói chuyện với Mira trước nhà. Mira từ chối ra ngoài và nói mình chỉ hơi mệt.
1. Người chơi nhận objective: “Tìm nguyên nhân giấc mơ gương vỡ của Mira.”
1. Vào giấc mơ qua chiếc khăn che mặt rơi ở cửa.
1. Khám phá phòng gương méo, nhặt 3 mảnh gương thật.
1. Lắp mảnh gương vào gương trung tâm để hiện phản chiếu không bóp méo.
1. Tìm 3 mảnh ký ức tốt: cứu mèo, tặng hoa, lắng nghe bạn khóc.
1. Ghép các ký ức vào bức tranh bị xé.
1. Làm hoa héo nở bằng ánh sáng từ gương thật và ký ức tốt.
1. Dẫn Mira Mộng đến trước gương thật.
1. Thực hiện nghi thức: đặt mặt nạ xuống trước gương.
1. Xem cảnh phản chiếu: Mira thấy nhiều phần của bản thân ngoài ngoại hình.
1. Tỉnh dậy: ngoài đời Mira mở rèm cửa và không che mặt kín như trước.
## **12.3. Puzzle chi tiết**

|**Puzzle**|**Input của người chơi**|**Điều kiện đúng**|**Kết quả**|
| :- | :- | :- | :- |
|Sửa gương thật|Nhặt 3 mảnh gương và đặt vào khung.|Đủ 3 mảnh, đúng thứ tự trái-giữa-phải.|Gương không còn méo, mở khóa vùng tranh ký ức.|
|Ghép tranh ký ức|Kéo 3 mảnh tranh vào bức tranh rách.|Mỗi mảnh đúng vị trí theo hình bóng.|Bức tranh hiện các hành động tốt của Mira.|
|Làm hoa nở|Đưa ánh sáng từ gương vào chậu hoa bằng cách xoay 2 gương nhỏ.|Tia sáng chạm chậu hoa sau khi đã ghép tranh.|Hoa nở, Mira bắt đầu dao động.|
|Nghi thức mặt nạ|Đặt bức tranh, chậu hoa, mặt nạ quanh gương.|Đã hoàn thành 3 puzzle trước, Mira đứng trong vùng ritual.|Cutscene tự nhận ra và tỉnh mộng.|

## **12.4. Lời thoại mẫu**
Ngoài đời - trước khi vào mơ:\
Mira: Đừng nhìn em lâu quá... em không quen.\
Người chơi: Dạo này em ngủ không ngon sao?\
Mira: Trong mơ có rất nhiều gương. Gương nào cũng nói cùng một điều.\
\
Trong mơ - giai đoạn phủ nhận:\
Mira Mộng: Gương không nói dối. Chỉ có em là khó nhìn thôi.\
\
Sau ký ức cứu mèo:\
Mira Mộng: Con mèo đó... vẫn nhớ em sao? Không, chắc chỉ là tình cờ.\
\
Sau hoa nở:\
Mira Mộng: Tại sao những bông hoa lại nở khi em không thay đổi khuôn mặt này?\
\
Cảnh tự nhận ra:\
Mira Mộng: Em cứ nghĩ mình chỉ là thứ phản chiếu trong gương.\
Mira Mộng: Nhưng những điều em đã làm... cũng là em.\
Mira Mộng: Em vẫn sợ bị nhìn thấy. Nhưng em không muốn biến mất sau chiếc mặt nạ nữa.
# **13. Màn 2 chi tiết - Theo: Lớp học vô tận**
## **13.1. Tóm tắt màn**

|**Mục**|**Nội dung**|
| :- | :- |
|NPC|Theo - học sinh luôn mang sách, sợ bị hỏi bài.|
|Vấn đề ngoài đời|Sợ thất bại, đồng nhất giá trị bản thân với điểm số.|
|Niềm tin sai|“Nếu mình làm sai, mình là đồ vô dụng.”|
|Không gian mơ|Lớp học kéo dài vô tận, bảng điểm đỏ, đồng hồ kiểm tra không dừng.|
|Nghi thức|Gấp bài kiểm tra đỏ thành máy bay giấy và thả ra cửa sổ.|

## **13.2. Flow nhiệm vụ**
1. Gặp Theo ở thư viện. Theo nói đang ôn bài nhưng tay run, ngủ gục nhiều lần.
1. Vào giấc mơ qua cuốn vở đầy dấu gạch đỏ.
1. Trong lớp học vô tận, các bàn học chặn đường như mê cung.
1. Puzzle 1: sắp xếp bàn học để tạo lối đi đến bảng đen.
1. Puzzle 2: lau bảng nhưng không xóa hết lỗi; chỉ khoanh lại lỗi đầu tiên Theo từng bị mắng.
1. Puzzle 3: tìm 3 bài làm cũ: một bài sai, một bài sửa lại, một bài có lời khen nhỏ của bạn.
1. Đặt 3 bài làm lên bảng theo thứ tự: sai → học lại → tiến bộ.
1. Cửa sổ lớp học mở ra, nhưng bài kiểm tra đỏ vẫn đè trên bàn.
1. Nghi thức: gấp bài kiểm tra thành máy bay giấy, đưa cho Theo tự thả.
1. Theo thấy điểm số không biến mất, nhưng nó không còn nhốt mình trong lớp nữa.
## **13.3. Puzzle chi tiết**

|**Puzzle**|**Thiết kế**|**Cách giải**|**Bài toán code**|
| :- | :- | :- | :- |
|Mê cung bàn học|Bàn học là tile/block có thể đẩy.|Đẩy 3 bàn vào ô đánh dấu để mở lối.|Grid-based push box đơn giản kiểu Sokoban.|
|Bảng lỗi|Bảng có nhiều dấu X đỏ.|Không xóa hết. Chọn dấu X đầu tiên để mở ký ức gốc.|Interact từng hotspot, đúng hotspot set flag.|
|Thứ tự tiến bộ|3 bài làm nằm rải rác.|Đặt đúng thứ tự sai → sửa → tiến bộ.|Place slots kiểm tra item\_id theo thứ tự.|
|Máy bay giấy|Item bài kiểm tra đỏ.|Interact bàn gấp giấy rồi cửa sổ.|State machine: paper\_raw → paper\_folded → released.|

## **13.4. Lời thoại mẫu**
Theo Mộng: Đừng nộp bài. Nếu nộp, mọi người sẽ thấy mình sai.\
Sau khi tìm bài sửa lại:\
Theo Mộng: Mình từng sửa được sao? Mình cứ nhớ mỗi dấu X đỏ.\
Trước nghi thức:\
Theo Mộng: Nếu thả nó đi, điểm số có biến mất không?\
Sau nghi thức:\
Theo Mộng: Nó vẫn là một phần của mình... nhưng không phải là cả con người mình.
# **14. Màn 3 chi tiết - Rell: Tháp đồng hồ đứng yên**
## **14.1. Tóm tắt màn**

|**Mục**|**Nội dung**|
| :- | :- |
|NPC|Ông Rell - thợ đồng hồ già.|
|Vấn đề ngoài đời|Hối tiếc vì không kịp nói lời xin lỗi với con trước khi con rời làng.|
|Niềm tin sai|“Nếu không quay lại quá khứ được, mọi thứ đã kết thúc.”|
|Không gian mơ|Tháp đồng hồ khổng lồ, kim đồng hồ rơi, các cửa quá khứ lặp lại.|
|Nghi thức|Không quay ngược đồng hồ; lắp kim để đồng hồ chạy tiếp về phía trước.|

## **14.2. Flow nhiệm vụ**
1. Gặp Rell trong tiệm đồng hồ. Đồng hồ nào cũng dừng cùng một giờ.
1. Vào giấc mơ qua chiếc đồng hồ bỏ túi không có kim.
1. Khám phá tháp đồng hồ với 3 tầng: Bánh răng, Ký ức, Mặt đồng hồ.
1. Puzzle 1: nối bánh răng để mở thang máy lên tầng ký ức.
1. Puzzle 2: chọn đúng 3 cảnh ký ức theo trình tự ngày con rời đi.
1. Puzzle 3: tìm kim phút bị kẹt trong cánh cửa quá khứ.
1. Người chơi có thể thử kéo kim quay ngược nhưng tháp rung và reset nhẹ.
1. Đưa kim lên mặt đồng hồ.
1. Nghi thức: lắp kim theo hướng đi tới, không quay về mốc cũ.
1. Rell tự nhận ra lời xin lỗi có thể bắt đầu từ hiện tại.
## **14.3. Puzzle chi tiết**

|**Puzzle**|**Mục tiêu**|**Cách giải**|**Feedback sai**|
| :- | :- | :- | :- |
|Nối bánh răng|Làm thang máy hoạt động.|Xoay 4 bánh răng để các răng chạm đúng hướng.|Bánh răng kẹt, phát tiếng cạch.|
|Trình tự ký ức|Hiểu câu chuyện quá khứ.|Sắp xếp: cãi nhau → con rời đi → lá thư chưa gửi.|Ký ức mờ lại nếu sai thứ tự.|
|Kim phút|Lấy vật phẩm ritual.|Mở cửa quá khứ bằng lá thư chưa gửi.|Cửa đóng nếu thiếu memory.|
|Không quay ngược|Dạy thông điệp.|Nếu kéo kim ngược 3 lần, Rell nói “Càng kéo, nó càng đau.”|Không game over, chỉ nhắc qua biểu tượng.|

## **14.4. Lời thoại mẫu**
Rell Mộng: Chỉ cần quay lại ngày đó. Chỉ cần một phút thôi.\
Sau khi thấy lá thư chưa gửi:\
Rell Mộng: Ta đã viết... nhưng không đủ can đảm gửi đi.\
Khi người chơi kéo kim ngược:\
Rell Mộng: Không, không đúng... càng quay lại, căn phòng càng lạnh.\
Sau nghi thức:\
Rell Mộng: Đồng hồ không đưa ta về hôm qua. Nó chỉ nhắc ta rằng hôm nay vẫn còn chạy.
# **15. Màn 4 chi tiết - Lina: Căn phòng không cửa**
## **15.1. Tóm tắt màn**

|**Mục**|**Nội dung**|
| :- | :- |
|NPC|Lina - luôn nói “mình ổn”, cười với mọi người nhưng sống khép kín.|
|Vấn đề ngoài đời|Cô đơn, không dám nhờ giúp đỡ vì sợ làm phiền.|
|Niềm tin sai|“Nếu mình nói mình buồn, mọi người sẽ rời đi.”|
|Không gian mơ|Căn phòng không cửa, tranh cười giống nhau, tiếng gõ cửa không thấy nguồn.|
|Nghi thức|Mở cửa từ bên trong bằng ký ức kết nối, không phải phá tường.|

## **15.2. Flow nhiệm vụ**
1. Gặp Lina ở quảng trường. Cô cười và nói mình ổn dù rõ ràng mệt.
1. Vào giấc mơ qua chiếc hộp nhạc phát giai điệu vui lặp lại.
1. Trong phòng không cửa có nhiều tranh Lina đang cười giống nhau.
1. Puzzle 1: chỉnh các bức tranh theo cảm xúc thật: vui → lo → buồn → khóc → bình yên.
1. Puzzle 2: tìm nguồn tiếng gõ cửa bằng cách áp tai vào 4 bức tường.
1. Puzzle 3: nhặt các sợi chỉ kết nối từ ký ức bạn bè từng quan tâm Lina.
1. Dùng sợi chỉ nối tranh Lina thật với các ký ức ngoài phòng.
1. Cửa hiện ra, nhưng tay nắm nằm ở phía trong.
1. Nghi thức: để Lina tự mở cửa từ bên trong, người chơi chỉ giữ ánh sáng không tắt.
1. Lina tỉnh dậy và lần đầu nói: “Hôm nay mình không ổn lắm, nhưng mình muốn thử nói ra.”
## **15.3. Puzzle chi tiết**

|**Puzzle**|**Thiết kế**|**Cách giải**|**Ý nghĩa**|
| :- | :- | :- | :- |
|Tranh cảm xúc|5 tranh giống nhau nhưng chi tiết mắt/miệng khác nhỏ.|Sắp đúng thứ tự cảm xúc.|Cho phép nhiều cảm xúc cùng tồn tại.|
|Tiếng gõ cửa|Âm thanh mạnh/yếu tùy tường.|Tìm tường có âm thanh thật, không phải tiếng hộp nhạc.|Nỗi cô đơn vẫn đang gọi từ bên ngoài.|
|Sợi chỉ kết nối|3 ký ức nằm sau tranh.|Nối chỉ từ Lina đến từng ký ức.|Mối quan hệ không biến mất dù cô tự khép mình.|
|Giữ ánh sáng|Trong ritual, đèn tắt dần nếu người chơi đứng xa.|Đứng gần đèn và giữ tương tác cho đến khi Lina mở cửa.|Người chơi hỗ trợ, không làm thay.|

# **16. Cơ chế NPC tự nhận ra nỗi đau**
Đây là phần quan trọng nhất của game. NPC không tự nhiên hiểu ra sau khi puzzle xong. Cần một tiến trình cảm xúc có thể code thành state.

|**Giai đoạn**|**Trạng thái NPC**|**Điều kiện chuyển trạng thái**|**Biểu hiện trong game**|
| :- | :- | :- | :- |
|Deny|Phủ nhận|Khi mới vào mơ.|Lời thoại né tránh, không nhìn biểu tượng chính.|
|Disturbed|Dao động|Khôi phục 1 ký ức phản chứng.|NPC đặt câu hỏi, môi trường bớt méo.|
|Confronting|Đối mặt|Khôi phục đủ ký ức chính.|NPC đứng gần lõi mộng, lời thoại thật hơn.|
|RitualReady|Sẵn sàng tỉnh mộng|Puzzle trung tâm hoàn thành.|Biểu tượng cuối phát sáng.|
|Realization|Tự nhận ra|Nghi thức hoàn tất.|Cutscene phản chiếu, NPC tự nói ra sự thật.|
|AwakeChanged|Tỉnh dậy|Load lại làng.|NPC ngoài đời thay đổi hành vi nhỏ.|

enum DreamEmotionalState {\
`  `DENY,\
`  `DISTURBED,\
`  `CONFRONTING,\
`  `RITUAL\_READY,\
`  `REALIZATION,\
`  `AWAKE\_CHANGED\
}
# **17. Sổ Mộng - Notebook System**
Sổ Mộng là UI quan trọng giúp người chơi không bị lạc. Nó không đưa đáp án trực tiếp, nhưng ghi lại clue để người chơi tự suy luận.

|**Tab**|**Nội dung**|**Ví dụ**|
| :- | :- | :- |
|Mục tiêu|Nhiệm vụ hiện tại.|“Tìm 3 mảnh gương thật.”|
|Biểu tượng|Các vật thể có ý nghĩa trong mơ.|Gương méo: cách Mira nhìn bản thân.|
|Ký ức|Các memory đã khôi phục.|Mira từng cứu một con mèo bị thương.|
|Trạng thái NPC|Lời thoại hoặc cảm xúc hiện tại.|Mira đang dao động, chưa dám nhìn gương.|
|Gợi ý nhẹ|Hint mở dần nếu người chơi kẹt.|“Có lẽ ánh sáng từ gương thật có thể giúp hoa.”|

|<p>**Quy tắc hint**</p><p>Hint không được nói thẳng đáp án. Hint nên nhắc lại biểu tượng hoặc mục tiêu. Ví dụ không viết “xoay gương trái 2 lần”, mà viết “ánh sáng thật cần đi qua những thứ không bóp méo”.</p>|
| :- |

# **18. UI cần có cho MVP**

|**UI**|**Thành phần**|**Ghi chú**|
| :- | :- | :- |
|HUD tối giản|Objective hiện tại, icon Sổ Mộng, icon vật phẩm đang cầm.|Không làm quá nhiều số liệu.|
|Dialogue Box|Tên NPC, portrait nhỏ, text, nút next.|Có typing effect nhưng cho skip.|
|Notebook|Tab trái, nội dung phải, clue dạng card.|Dễ đọc, font pixel hoặc sans rõ.|
|Inventory Bar|3-5 key items.|Chỉ chứa vật phẩm puzzle, không cần item RPG.|
|Ritual Prompt|Thông báo khi đủ điều kiện nghi thức.|Ví dụ: “Gương đã sẵn sàng phản chiếu.”|
|Pause Menu|Resume, Save, Load, Settings, Quit.|MVP có thể chỉ Resume/Quit.|

# **19. Asset list cho AI coding / artist**

|**Nhóm asset**|**Cần cho MVP**|**Gợi ý số lượng**|
| :- | :- | :- |
|Player|Idle/walk 4 hướng, interact pose.|4 hướng x 3 frame, 1 interact.|
|NPC ngoài đời|Mira, Theo, Rell, Lina, NPC phụ.|5-8 nhân vật.|
|NPC trong mơ|Phiên bản mộng của từng NPC.|4 nhân vật, có biến thể cảm xúc.|
|Village tileset|Đường làng, nhà, cây, quảng trường.|1 tileset 16x16 hoặc 32x32.|
|Dream Mira|Gương, mặt nạ, hoa héo/nở, tranh rách.|20-30 sprite/object.|
|Dream Theo|Bàn học, bảng, bài kiểm tra, cửa sổ.|15-25 sprite/object.|
|Dream Rell|Bánh răng, đồng hồ, kim, cửa ký ức.|20-30 sprite/object.|
|Dream Lina|Tranh cảm xúc, hộp nhạc, sợi chỉ, cửa.|20-30 sprite/object.|
|UI icons|Notebook, clue, memory, symbol, key item.|15-20 icon.|
|SFX|Interact, clue found, puzzle solved, dream shift.|10-15 âm thanh ngắn.|
|Music|Village theme, dream ambient, ritual theme.|3-5 track ngắn loop.|

# **20. Các bài toán khi làm và cách giải**
## **20.1. Bài toán: scope dễ bị phình quá lớn**

|**Vấn đề**|**Dấu hiệu**|**Cách giải**|
| :- | :- | :- |
|Thêm quá nhiều NPC/màn chơi.|Code chưa xong nhưng nội dung liên tục tăng.|Khóa MVP ở 4 NPC, mỗi NPC 3 puzzle + 1 ritual.|
|Puzzle quá phức tạp.|Mỗi puzzle cần script riêng quá nhiều.|Chuẩn hóa 4 loại puzzle: collect-place, order, rotate, escort/hold.|
|Map quá lớn.|Người chơi đi nhiều hơn giải đố.|Làng chỉ 1 map, mỗi dream 1-3 phòng nhỏ.|

## **20.2. Bài toán: puzzle khó code vì mỗi màn quá riêng**
Giải pháp là tạo các puzzle component tái sử dụng. Mỗi puzzle chỉ khác dữ liệu.

|**Puzzle type**|**Dùng cho màn**|**Component gợi ý**|
| :- | :- | :- |
|CollectAndPlace|Mira mảnh gương, tranh ký ức.|PlaceItemPuzzle.gd|
|OrderedSlots|Theo thứ tự bài làm, Lina tranh cảm xúc.|OrderPuzzle.gd|
|RotateReflect|Mira xoay gương, Rell bánh răng.|RotatingNodePuzzle.gd|
|PushBlock/Grid|Theo bàn học.|GridPushPuzzle.gd|
|Escort/HoldLight|Lina giữ ánh sáng.|AreaHoldPuzzle.gd|

class\_name PuzzleController\
extends Node\
\
@export var puzzle\_id: String\
@export var required\_flags: Array[String]\
@export var reward\_flags: Array[String]\
@export var on\_complete\_dialogue\_id: String\
\
func can\_start() -> bool:\
`    `return GameState.has\_all\_flags(required\_flags)\
\
func complete\_puzzle():\
`    `for f in reward\_flags:\
`        `GameState.set\_flag(f, true)\
`    `NotebookManager.add\_entry("puzzle\_solved", puzzle\_id)\
`    `DialogueManager.play(on\_complete\_dialogue\_id)
## **20.3. Bài toán: NPC tự nhận ra bị giả**

|**Nguy cơ**|**Cách tránh**|
| :- | :- |
|NPC đổi suy nghĩ quá nhanh.|Chia thành state Deny → Disturbed → Confronting → Realization.|
|Người chơi giảng đạo qua lựa chọn text.|Dùng hành động biểu tượng và cutscene phản chiếu.|
|Thông điệp quá lộ.|Thể hiện qua môi trường: gương đổi phản chiếu, hoa nở, cửa hiện ra.|
|NPC hết buồn ngay.|Sau tỉnh chỉ thay đổi nhỏ, ví dụ mở rèm, ra ngoài tưới hoa.|

## **20.4. Bài toán: người chơi không hiểu phải làm gì**

|**Vấn đề**|**Giải pháp UI/UX**|
| :- | :- |
|Không biết objective tiếp theo.|HUD hiện objective ngắn và Notebook có tab Mục tiêu.|
|Không biết item đặt ở đâu.|Khi cầm item đúng, vị trí tương tác phát sáng nhẹ.|
|Không hiểu puzzle liên quan gì.|Sau mỗi clue có lời thoại phản ứng của NPC.|
|Bị kẹt lâu.|Hint mở theo thời gian hoặc số lần tương tác sai.|

## **20.5. Bài toán: lưu tiến trình phức tạp**
Không lưu toàn bộ scene. Chỉ lưu state quan trọng: scene hiện tại, flags, inventory, notebook, NPC states.

{\
`  `"current\_scene": "village",\
`  `"current\_case": "mira",\
`  `"flags": {\
`    `"mira\_intro\_done": true,\
`    `"mira\_true\_mirror\_repaired": true,\
`    `"mira\_memory\_cat\_restored": true\
`  `},\
`  `"inventory": ["mira\_mask"],\
`  `"notebook\_entries": ["symbol\_mirror", "memory\_mira\_cat"],\
`  `"npc\_states": {\
`    `"mira": "disturbed",\
`    `"theo": "locked"\
`  `}\
}
## **20.6. Bài toán: nội dung hội thoại nhiều, dễ rối**

|**Giải pháp**|**Mô tả**|
| :- | :- |
|Dialogue ID rõ ràng|mira\_intro\_01, mira\_dream\_deny\_01, mira\_after\_memory\_cat.|
|Condition theo flag|NPC nói câu khác khi puzzle đã hoàn thành.|
|Không hard-code text trong scene|Lưu dialogue trong JSON hoặc Resource.|
|Giới hạn mỗi đoạn|Mỗi box 1-2 câu, tránh dài.|

// dialogue\_mira.json\
{\
`  `"mira\_dream\_idle": [\
`    `{\
`      `"condition": "!mira\_memory\_cat\_restored",\
`      `"speaker": "Mira Mộng",\
`      `"text": "Đừng nhìn em. Gương đã nói đủ rồi."\
`    `},\
`    `{\
`      `"condition": "mira\_memory\_cat\_restored && !mira\_flower\_bloomed",\
`      `"speaker": "Mira Mộng",\
`      `"text": "Con mèo đó... vẫn nhớ em sao?"\
`    `}\
`  `]\
}
## **20.7. Bài toán: AI coding dễ làm sai “mood” game**

|<p>**Prompt nhắc AI coding**</p><p>Khi giao task cho AI coding, luôn nhắc: game không có combat, không có jump scare, không chữa lành bằng câu trả lời đúng. Mọi tiến triển cảm xúc phải thông qua tương tác với biểu tượng, ký ức và môi trường.</p>|
| :- |

# **21. Task breakdown cho AI coding**
## **21.1. Milestone 1 - Khung game playable**

|**Task**|**Mô tả**|**Acceptance criteria**|
| :- | :- | :- |
|Tạo project Godot|Setup resolution pixel, input map, folder structure.|Chạy được scene main menu và village.|
|Player Controller|Di chuyển top-down, collision, animation placeholder.|Đi không xuyên tường, tương tác bằng E.|
|Scene Loader|Chuyển Village ↔ Dream scene có fade.|Load không lỗi, giữ state.|
|Dialogue Box|Hiện tên, text, next.|NPC nói được 3 đoạn liên tiếp.|
|Interactable Base|Object có thể tương tác gọi callback.|Item/door/NPC dùng chung base.|

## **21.2. Milestone 2 - Systems nội dung**

|**Task**|**Mô tả**|**Acceptance criteria**|
| :- | :- | :- |
|GameState flags|Set/get flags toàn cục.|Puzzle có thể mở khóa dựa trên flag.|
|Notebook UI|Lưu và hiển thị clue/memory/symbol.|Nhặt clue thì notebook cập nhật.|
|Inventory key item|Nhặt và dùng vật phẩm puzzle.|Cầm item đặt vào slot đúng.|
|Puzzle components|CollectPlace, Order, Rotate.|Tạo được 3 puzzle demo không hard-code quá nhiều.|
|Save/Load|Lưu JSON local.|Thoát game vào lại giữ case state.|

## **21.3. Milestone 3 - Màn Mira hoàn chỉnh**

|**Task**|**Mô tả**|**Acceptance criteria**|
| :- | :- | :- |
|Scene Dream Mira|Phòng gương, vùng tranh, vùng hoa.|Người chơi khám phá được toàn màn.|
|Puzzle gương|Nhặt 3 mảnh và lắp.|Hoàn thành mở vùng tranh.|
|Puzzle tranh ký ức|Ghép 3 ký ức.|Notebook thêm 3 memory, Mira đổi thoại.|
|Puzzle hoa nở|Xoay gương đưa ánh sáng.|Hoa đổi sprite héo → nở.|
|Ritual mặt nạ|Đặt mặt nạ xuống, cutscene.|Mira tỉnh, village state thay đổi.|

## **21.4. Milestone 4 - Thêm 3 màn còn lại**

|**Màn**|**Tasks chính**|**Acceptance criteria**|
| :- | :- | :- |
|Theo|Mê cung bàn học, thứ tự bài làm, máy bay giấy.|Chơi trọn màn và unlock Rell.|
|Rell|Bánh răng, trình tự ký ức, kim đồng hồ.|Chơi trọn màn và unlock Lina.|
|Lina|Tranh cảm xúc, sợi chỉ, giữ ánh sáng.|Chơi trọn màn và mở ending MVP.|

# **22. Prompt mẫu để đưa cho AI coding**
Có thể copy prompt này cho AI coding/agent để bắt đầu triển khai. Nên chia theo milestone, không giao toàn bộ một lần nếu dùng agent dễ lạc scope.

Bạn là AI coding phụ trách triển khai prototype game Godot 4.x tên "Người Dịch Giấc Mơ".\
Hãy đọc GDD này và triển khai theo nguyên tắc:\
\- Pixel 2D top-down, không combat.\
\- Gameplay tập trung vào khám phá, dialogue, notebook, key-item puzzle, dream ritual.\
\- Không dùng lựa chọn trắc nghiệm để chữa lành NPC; tiến triển cảm xúc phải thông qua hành động biểu tượng.\
\- Code cần chia module: GameState, DialogueManager, NotebookManager, PuzzleController, SaveManager.\
\- Làm từng milestone. Trước tiên tạo project structure, player controller, village scene, dialogue box, interactable base.\
\- Dùng placeholder sprites hình chữ nhật nếu chưa có asset thật.\
\- Mỗi task phải có acceptance criteria rõ ràng và có thể test trong game.
# **23. Checklist MVP hoàn thành**

|**Hạng mục**|**Done?**|
| :- | :- |
|Main menu vào được game|☐|
|Player di chuyển và tương tác ổn|☐|
|Village có 4 NPC chính|☐|
|Dialogue system hoạt động theo flag|☐|
|Notebook lưu clue/memory/symbol|☐|
|Inventory key item hoạt động|☐|
|Màn tutorial hoàn thành|☐|
|Màn Mira hoàn chỉnh|☐|
|Màn Theo hoàn chỉnh|☐|
|Màn Rell hoàn chỉnh|☐|
|Màn Lina hoàn chỉnh|☐|
|Save/load cơ bản|☐|
|Có âm thanh interact/puzzle/cutscene|☐|
|Có ending MVP sau màn Lina|☐|

# **24. Ending MVP**
Sau khi giúp 4 NPC tỉnh mộng, người chơi phát hiện giấc mơ của họ đều có một chi tiết chung: một cánh cửa trắng ở rìa ký ức. Đây là hook để phát triển bản full game. Bản MVP kết thúc bằng cảnh cả 4 NPC xuất hiện ở quảng trường, mỗi người có thay đổi nhỏ: Mira mở rèm và tưới hoa, Theo học cùng bạn thay vì một mình, Rell viết lá thư đầu tiên, Lina nói thật rằng hôm nay cô không ổn nhưng muốn ở lại với mọi người.

|<p>**Thông điệp kết thúc MVP**</p><p>Tỉnh mộng không phải là hết đau. Tỉnh mộng là khoảnh khắc một người bắt đầu dám nhìn vào nỗi đau của mình mà không còn ở một mình.</p>|
| :- |

# **25. Những thứ không làm trong MVP**
- Không làm combat, máu, level, chỉ số RPG.
- Không làm hệ thống relationship lớn như Stardew Valley.
- Không làm nhiều ending phức tạp ở MVP.
- Không làm procedurally generated dream. Mỗi dream nên thiết kế thủ công.
- Không làm quá 4 NPC chính trong bản đầu.
- Không cần pixel art hoàn chỉnh ngay; dùng placeholder trước, polish sau.
- Không cần voice acting.
# **26. Rủi ro và phương án giảm rủi ro**

|**Rủi ro**|**Mức độ**|**Cách giảm**|
| :- | :- | :- |
|Nội dung cảm xúc bị sến/giảng đạo.|Cao|Dùng hình ảnh và hành động thay vì lời khuyên trực tiếp.|
|AI coding làm code rối.|Cao|Bắt buộc milestone nhỏ, module rõ, acceptance criteria.|
|Puzzle không vui.|Trung bình|Playtest từng puzzle sớm bằng placeholder.|
|Người chơi không hiểu biểu tượng.|Trung bình|Notebook + lời thoại phản ứng + hint nhẹ.|
|Thiếu asset pixel.|Trung bình|Dùng placeholder và tileset miễn phí trước.|
|Save/load lỗi state.|Trung bình|Lưu flag, không lưu object scene phức tạp.|

Hành Động Tỉnh Mộng

Tức là người chơi không nói đáp án đúng cho NPC, mà thay đổi thế giới trong mơ bằng hành động, để NPC tự hiểu ra.

Cốt lõi là:

Người chơi không “giảng đạo” cho người mơ.

Người chơi tạo ra một trải nghiệm trong giấc mơ khiến họ tự nhận ra điều cần đối mặt.

1\. Cơ chế mới: “Hành Động Tỉnh Mộng”

Sau khi giải puzzle, người chơi sẽ tìm ra:

Nỗi đau thật sự của NPC

↓

Biểu tượng trung tâm trong giấc mơ

↓

Hành động cần làm để biến đổi biểu tượng đó

↓

NPC tự nhận ra sự thật

↓

Cánh cửa tỉnh giấc mở ra

Ví dụ thay vì chọn câu:

“Ngoại hình không phải tất cả.”

Người chơi phải làm một chuỗi hành động trong mơ để NPC nhìn thấy rằng họ còn có nhiều giá trị khác ngoài ngoại hình.

2\. Ví dụ hoàn chỉnh: NPC tự ti về ngoại hình

NPC ngoài đời

Tên: Mira

Mira là một cô gái rất ít ra ngoài. Cô luôn che mặt bằng khăn, né tránh gương và không muốn gặp ai.

Cô nói:

“Em không thích ai nhìn thấy em.”

Giấc mơ của Mira

Người chơi bước vào một căn phòng lớn toàn gương.

Nhưng các gương đều méo mó, chỉ phản chiếu những hình ảnh xấu xí, phóng đại khuyết điểm của Mira.

Trong mơ có các biểu tượng:

Biểu tượng	Ý nghĩa

Gương méo	Cách Mira nhìn bản thân bị sai lệch

Mặt nạ đẹp	Cô nghĩ phải hoàn hảo mới được yêu quý

Bức tranh bị xé	Cô phủ nhận những phần khác của mình

Hoa héo	Lòng tốt/tâm hồn bị cô bỏ quên

Những bóng người thì thầm	Lời chê bai trong quá khứ

3\. Thử thách trong giấc mơ

Người chơi không cần đánh quái. Người chơi sẽ giải các puzzle nhỏ.

Puzzle 1: Sửa lại những tấm gương

Người chơi tìm các mảnh gương thật bị giấu trong phòng.

Khi lắp đúng, gương không còn bóp méo ngoại hình nữa. Nhưng Mira vẫn không dám nhìn vào.

Điều này cho thấy:

Chỉ sửa cách nhìn ngoại hình là chưa đủ.

Puzzle 2: Tìm những phần bị xé của bức tranh

Người chơi tìm các mảnh tranh rơi trong giấc mơ.

Mỗi mảnh tranh không vẽ khuôn mặt của Mira, mà vẽ những điều cô từng làm:

Mảnh 1: Mira giúp một đứa bé bị lạc.

Mảnh 2: Mira chăm sóc một con mèo bị thương.

Mảnh 3: Mira tặng hoa cho bà cụ sống một mình.

Mảnh 4: Mira ngồi nghe bạn mình khóc.

Khi ghép lại, bức tranh hoàn chỉnh không phải là chân dung khuôn mặt, mà là những hành động tốt đẹp của Mira.

Puzzle 3: Làm hoa nở lại

Ở giữa phòng có một chậu hoa héo. Người chơi không thể tưới bằng nước thường.

Phải dùng 3 thứ đã tìm được:

Mảnh ký ức về lòng tốt

Ánh sáng từ gương thật

Tiếng cười của người từng được Mira giúp

Khi đặt đủ 3 thứ vào, hoa nở.

Lúc này căn phòng gương thay đổi. Các tấm gương không chỉ phản chiếu gương mặt Mira nữa, mà phản chiếu:

cách cô giúp người khác,

sự dịu dàng của cô,

lòng tốt của cô,

sự kiên nhẫn của cô,

những người từng biết ơn cô.

4\. Hành động đánh thức cuối cùng

Đây là phần quan trọng nhất.

Không chọn đáp án. Không chọn câu nói.

Người chơi phải thực hiện một hành động:

Đặt chiếc mặt nạ xuống trước gương thật

Trong suốt màn chơi, Mira luôn giữ một chiếc mặt nạ đẹp trong tay. Cô nghĩ nếu không có nó, cô không xứng đáng được nhìn nhận.

Người chơi cần:

1\. Dẫn Mira đến gương thật.

2\. Đặt bức tranh ký ức bên cạnh gương.

3\. Đặt chậu hoa đã nở trước mặt cô.

4\. Nhẹ nhàng lấy chiếc mặt nạ ra khỏi tay Mira.

5\. Đặt mặt nạ xuống đất.

Khi làm đúng, Mira không lập tức “thấy mình đẹp”. Thay vào đó, cô thấy trong gương có rất nhiều hình ảnh của bản thân:

Mira đang cười.

Mira đang khóc.

Mira đang giúp người khác.

Mira đang sợ hãi.

Mira đang chăm sóc một bông hoa.

Mira đang đứng một mình.

Mira đang được người khác nắm tay.

Thông điệp không phải là:

“Bạn đẹp mà.”

Mà là:

“Bạn không chỉ là ngoại hình. Bạn là toàn bộ những điều bạn đã sống, đã cảm nhận, đã trao đi.”

Sau đó cánh cửa tỉnh giấc mở ra.

5\. Vì sao cách này hay hơn chọn đáp án?

Vì người chơi trực tiếp tạo ra sự thay đổi.

Thay vì:

Chọn câu đúng → NPC tỉnh

Ta đổi thành:

Hiểu biểu tượng → tìm ký ức → biến đổi không gian → thực hiện hành động cuối → NPC tự nhận ra

Nó làm game cảm xúc hơn rất nhiều.

6\. Công thức thiết kế “Hành Động Tỉnh Mộng”

Mỗi NPC nên có một công thức riêng:

Nỗi đau

↓

Biểu tượng sai lệch

↓

Ký ức bị che giấu

↓

Vật phẩm biểu tượng

↓

Hành động đánh thức

↓

Biến đổi giấc mơ

Ví dụ:

Nỗi đau	Biểu tượng	Hành động đánh thức

Tự ti ngoại hình	Gương méo, mặt nạ	Đặt mặt nạ xuống trước gương thật

Sợ thất bại	Bài kiểm tra vô tận	Xé tờ điểm giả và mở cửa lớp học

Cô đơn	Căn phòng không cửa	Mở cửa từ bên trong bằng những ký ức kết nối

Hối tiếc	Đồng hồ đứng yên	Không quay ngược đồng hồ, mà lắp kim để nó chạy tiếp

Tội lỗi	Vết mực lan rộng	Không lau sạch vết mực, mà viết tiếp trang thư xin lỗi

Áp lực hoàn hảo	Sân khấu không khán giả	Tắt đèn sân khấu và ngồi xuống cạnh NPC

Né tránh quá khứ	Hộp khóa nhiều lớp	Không phá hộp, mà trao chìa khóa cho chính NPC

7\. Một vài ví dụ “hành động tỉnh mộng” khác

A. NPC sợ thất bại

Giấc mơ: lớp học vô tận, bảng điểm đỏ, bài kiểm tra không bao giờ kết thúc.

Người chơi giải puzzle để tìm ra rằng NPC từng bị mắng vì điểm kém.

Hành động cuối:

Người chơi gom các tờ điểm đỏ, gấp chúng thành máy bay giấy, rồi thả bay ra ngoài cửa sổ.

Ý nghĩa:

Điểm số không phải toàn bộ giá trị của một con người.

NPC tỉnh dậy không phải vì được nói “đừng sợ”, mà vì chính họ nhìn thấy bài kiểm tra biến thành thứ có thể bay đi.

B. NPC luôn cố làm hài lòng người khác

Giấc mơ: NPC bị buộc bằng rất nhiều sợi dây nối đến những chiếc chuông. Mỗi khi ai đó cần gì, chuông lại reo và kéo NPC đi.

Hành động cuối:

Người chơi không cắt hết dây.

Người chơi chỉ tháo những sợi dây đang siết cổ tay NPC, rồi đưa cho NPC tự chọn giữ lại sợi dây nào.

Ý nghĩa:

Quan tâm người khác là tốt, nhưng không có nghĩa là đánh mất chính mình.

C. NPC hối tiếc vì quá khứ

Giấc mơ: một chiếc đồng hồ khổng lồ bị kẹt, xung quanh là những cánh cửa dẫn về cùng một ngày cũ.

Hành động cuối:

Người chơi không kéo kim đồng hồ quay ngược.

Người chơi tìm kim phút bị rơi, lắp lại vào đồng hồ, rồi mở cánh cửa phía trước thay vì cánh cửa quá khứ.

Ý nghĩa:

Không thể sửa quá khứ, nhưng có thể tiếp tục bước đi.

D. NPC mất niềm tin vào lòng tốt

Giấc mơ: khu vườn toàn cây gai, mọi bông hoa đều đóng lại khi NPC đến gần.

Hành động cuối:

Người chơi đặt những ký ức tốt nhỏ xung quanh khu vườn, sau đó không ép hoa nở. Chỉ ngồi yên cùng NPC cho đến khi bông hoa đầu tiên tự mở.

Ý nghĩa:

Niềm tin không thể bị ép buộc, nó cần thời gian.

8\. Cách biến thành gameplay cụ thể

Để không quá khó code, mỗi “Hành Động Tỉnh Mộng” có thể là một chuỗi thao tác đơn giản:

Kéo vật phẩm đến đúng vị trí

Kích hoạt đúng thứ tự

Dẫn NPC đi qua một con đường đã mở

Đặt biểu tượng vào đúng nơi

Trao vật phẩm cho NPC

Sửa một vật thể trung tâm

Thay đổi ánh sáng/cảnh vật

Ví dụ với Mira:

Kéo “bức tranh ký ức” đến cạnh gương

Kéo “chậu hoa đã nở” đến trước gương

Tương tác với “mặt nạ”

Đặt “mặt nạ” xuống đất

Dẫn Mira chạm vào gương thật

Tức là vẫn dễ làm trong Godot/Unity, không cần hệ thống phức tạp.

9\. Cơ chế hay: “Không có nút nói đạo lý”

Một luật thiết kế rất hay cho game này:

Người chơi không được trực tiếp nói bài học cho NPC.

Người chơi chỉ được thay đổi biểu tượng trong giấc mơ.

Điều này giúp game tinh tế hơn.

Ví dụ với NPC tự ti ngoại hình, game không hiện câu:

“Vẻ đẹp tâm hồn mới quan trọng.”

Mà cho người chơi tự thấy qua hành động:

Gương chỉ phản chiếu mặt → gương phản chiếu ký ức tốt đẹp → NPC đặt mặt nạ xuống.

Người chơi hiểu thông điệp qua hình ảnh, không cần game giảng.

10\. Tên mới cho cơ chế này

Thay vì “Gỡ Nút Mộng” chỉ nghe như giải đố, ta có thể gọi là:

Nghi Thức Tỉnh Mộng

Mỗi màn có một nghi thức riêng.

Ví dụ:

NPC	Nghi thức

Mira tự ti ngoại hình	Đặt mặt nạ xuống

Cậu bé sợ thất bại	Thả máy bay giấy điểm số

Ông lão hối tiếc	Cho đồng hồ chạy tiếp

Người chăm sóc quá mức	Tháo dây chuông

Cô gái cô đơn	Mở cửa từ bên trong

Nhạc công mất tự tin	Chơi bản nhạc thiếu nốt cuối

11\. Cấu trúc màn chơi sau khi sửa

Một màn hoàn chỉnh sẽ là:

1\. Gặp NPC ngoài đời

2\. NPC kể triệu chứng mơ hồ

3\. Vào giấc mơ

4\. Quan sát thế giới biểu tượng

5\. Giải puzzle để mở ký ức

6\. Hiểu nguyên nhân thật

7\. Tìm vật phẩm biểu tượng

8\. Biến đổi không gian mơ

9\. Thực hiện Nghi Thức Tỉnh Mộng

10\. NPC tự nhận ra điều cần thay đổi

11\. NPC thức dậy

12\. Ngoài đời có thay đổi nhỏ

12\. Thay đổi ngoài đời sau khi tỉnh

Sau khi tỉnh, NPC không nên “hết vấn đề 100%” ngay. Như vậy sẽ giả tạo.

Nên để họ có một thay đổi nhỏ nhưng thật:

Ví dụ Mira sau khi tỉnh:

Trước:

Mira luôn che mặt, không ra khỏi nhà.

Sau:

Mira vẫn còn ngại, nhưng lần đầu tiên cô mở rèm cửa.

Hôm sau, cô ra ngoài tưới hoa trước nhà.

Sau vài màn khác, cô có thể nói chuyện với người dân.

Điều này làm game chân thật hơn:

Tỉnh mộng không phải là hết đau ngay.

Tỉnh mộng là bắt đầu dám đối mặt.

13\. Tóm tắt cơ chế mới

Bạn có thể định nghĩa game như sau:

Người Dịch Giấc Mơ là game pixel giải đố - suy luận, nơi người chơi bước vào giấc mơ của NPC, giải mã biểu tượng và thực hiện một Nghi Thức Tỉnh Mộng bằng hành động. Người chơi không chọn đáp án hay nói đạo lý, mà thay đổi các biểu tượng trong giấc mơ để NPC tự nhận ra nỗi đau của mình và thức dậy với một góc nhìn mới.


Cơ chế “Phản Chiếu Ký Ức”

NPC không tự nhận ra chỉ vì người chơi giải puzzle. NPC tự nhận ra khi họ nhìn thấy lại chính mình qua ký ức, biểu tượng và hậu quả của hành động trong mơ.

Nói đơn giản:

Người chơi không nói cho NPC biết họ đau vì điều gì.

Người chơi tạo điều kiện để NPC nhìn thấy sự thật mà họ đang né tránh.

1\. NPC tự nhận ra bằng 4 bước

Một màn giấc mơ nên có quá trình như sau:

1\. NPC phủ nhận

↓

2\. Người chơi tìm ký ức thật

↓

3\. Ký ức được phản chiếu thành hình ảnh trong mơ

↓

4\. NPC đối mặt với hình ảnh đó và tự nói ra sự thật

Ví dụ NPC tự ti ngoại hình:

Ban đầu NPC nói:

“Tôi xấu xí nên không ai thích tôi.”

Sau khi người chơi sửa gương, ghép tranh ký ức, làm hoa nở, NPC bắt đầu thấy:

có người từng cảm ơn mình,

có người từng nhớ lòng tốt của mình,

có người từng buồn khi mình biến mất,

có những khoảnh khắc mình không đẹp hoàn hảo nhưng vẫn đáng quý.

Lúc đó NPC tự nói:

“Mình cứ nghĩ mọi người chỉ nhìn thấy khuôn mặt mình… nhưng hình như có những điều khác ở mình mà họ vẫn nhớ.”

Đó là tự nhận ra, không phải bị người chơi giảng.

2\. Thêm nhân vật “Bản Thể Trong Mơ”

Để NPC tự nhận ra tự nhiên hơn, mỗi NPC nên có một phiên bản trong mơ gọi là:

Bản Thể Mộng

Đây không phải NPC thật hoàn toàn, mà là phần cảm xúc bị kẹt trong họ.

Ví dụ với Mira tự ti ngoại hình, trong mơ có thể có 3 phiên bản:

Bản thể	Ý nghĩa

Mira Đeo Mặt Nạ	Phần muốn che giấu bản thân

Mira Nhỏ Bé	Ký ức từng bị chê bai

Mira Thật	Phần vẫn muốn được chấp nhận

Người chơi không “thuyết phục” Mira thật ngay. Người chơi phải giúp các bản thể này gặp nhau.

Ví dụ:

Mira Nhỏ Bé đang trốn sau gương vỡ.

Mira Đeo Mặt Nạ đứng trước sân khấu.

Mira Thật bị nhốt trong bức tranh chưa hoàn chỉnh.

Khi người chơi hoàn thành puzzle, 3 phần này xuất hiện cùng một nơi. NPC tự thấy rằng:

“Mình không chỉ là người đang sợ. Mình cũng từng tổn thương, từng cố gắng, và vẫn muốn được sống thật.”

Cách này rất hay vì nó biến “tự nhận thức” thành một cảnh trong game.

3\. Dùng “ký ức phản chứng”

NPC thường mắc kẹt vì họ tin vào một suy nghĩ sai.

Ví dụ:

“Mình xấu nên không ai yêu quý mình.”

Để họ tự nhận ra, người chơi cần tìm các ký ức phản chứng.

Tức là những ký ức chứng minh niềm tin đó không hoàn toàn đúng.

Với Mira:

Niềm tin sai	Ký ức phản chứng

“Không ai thích mình.”	Một đứa trẻ vẫn chạy đến ôm Mira dù cô che mặt

“Mình chẳng có gì tốt đẹp.”	Mira từng cứu con mèo bị thương

“Mọi người chỉ quan tâm ngoại hình.”	Bà cụ nhớ Mira vì cô hay để hoa trước cửa

“Mình phải hoàn hảo mới được chấp nhận.”	Một người bạn từng nói thích nghe Mira kể chuyện

Người chơi không nói “bạn sai rồi”. Người chơi đưa các ký ức này trở lại đúng chỗ trong giấc mơ.

Khi đủ ký ức phản chứng xuất hiện, NPC tự phát hiện:

“Niềm tin của mình không phải toàn bộ sự thật.”

4\. Cơ chế hay: “Câu nói của NPC thay đổi dần”

Để thể hiện NPC đang tự nhận ra, đừng để họ thay đổi ngay lập tức. Hãy cho lời thoại của họ biến đổi từng bước.

Ví dụ Mira:

Giai đoạn 1: Phủ nhận

“Đừng nhìn tôi.”

“Gương chỉ nói sự thật thôi.”

“Không có gì khác đáng nhìn ở tôi cả.”

Giai đoạn 2: Dao động

Sau khi người chơi ghép ký ức đầu tiên:

“Khoan đã… người đó nhớ chuyện này sao?”

“Tôi tưởng chẳng ai để ý.”

“Tại sao bông hoa đó lại nở?”

Giai đoạn 3: Đối mặt

Sau khi người chơi đưa Mira đến gương thật:

“Đây cũng là tôi sao?”

“Không chỉ là khuôn mặt này…”

“Những điều tôi đã làm… cũng là một phần của tôi.”

Giai đoạn 4: Tỉnh mộng

Sau nghi thức đặt mặt nạ xuống:

“Tôi vẫn chưa thể yêu bản thân ngay… nhưng tôi không muốn trốn nữa.”

Câu cuối này rất quan trọng. Nó chân thật hơn kiểu:

“Tôi hiểu rồi, tôi đẹp từ bên trong.”

Vì ngoài đời, con người không hết tự ti ngay. Họ chỉ bắt đầu thay đổi.

5\. Tạo “khoảnh khắc tự nhận ra” bằng gameplay

Bạn có thể thiết kế một cơ chế gọi là:

Khoảnh Khắc Phản Chiếu

Đây là đoạn cuối trước khi tỉnh mộng.

Người chơi đặt đủ các biểu tượng đúng chỗ, sau đó giấc mơ tự diễn ra một cảnh ngắn.

Ví dụ với Mira:

Người chơi đặt:

Bức tranh ký ức → bên trái gương

Chậu hoa đã nở → trước gương

Mặt nạ → dưới đất

Mira nhỏ bé → đứng cạnh Mira hiện tại

Sau đó gương phản chiếu không chỉ một hình ảnh, mà nhiều lớp:

Mira lúc bị chê

Mira lúc khóc

Mira lúc giúp người khác

Mira lúc được người khác cảm ơn

Mira hiện tại đang sợ

Mira tương lai đang mở cửa bước ra ngoài

NPC nhìn thấy toàn bộ. Rồi cô ấy tự nói ra nhận thức mới.

Như vậy, việc NPC nhận ra không đến từ lời giải thích, mà đến từ trải nghiệm trực quan.

6\. Công thức để NPC tự nhận ra nỗi đau

Với mỗi nhân vật, bạn có thể dùng công thức này:

Niềm tin sai của NPC

↓

Nguồn gốc của niềm tin đó

↓

Biểu tượng trong giấc mơ

↓

Ký ức bị che giấu

↓

Ký ức phản chứng

↓

Hành động của người chơi

↓

NPC tự nói ra sự thật mới

Ví dụ:

NPC tự ti ngoại hình

Niềm tin sai:

“Mình chỉ có giá trị nếu mình đẹp.”

Nguồn gốc:

Từng bị chê bai, so sánh, bỏ rơi.

Biểu tượng:

Gương méo, mặt nạ, tranh bị xé.

Ký ức bị che giấu:

Ngày bị chê trước đám đông.

Ký ức phản chứng:

Những lần cô được yêu quý vì lòng tốt, sự dịu dàng, sự kiên nhẫn.

Hành động của người chơi:

Ghép lại bức tranh ký ức, làm hoa nở, đặt mặt nạ xuống.

NPC tự nhận ra:

“Ngoại hình là một phần của mình, nhưng không phải toàn bộ con người mình.”

7\. Không nên để NPC nhận ra quá dễ

Để cảm xúc thật hơn, NPC nên có kháng cự.

Ví dụ khi người chơi đưa ký ức tốt đến, Mira có thể nói:

“Không, chuyện đó không tính.”

“Họ chỉ lịch sự thôi.”

“Một việc tốt không thay đổi được gì.”

Sau đó người chơi phải tìm thêm ký ức khác.

Điều này rất giống tâm lý thật: khi một người đã tin điều tiêu cực về bản thân quá lâu, họ không đổi suy nghĩ chỉ bằng một bằng chứng.

Vì vậy, game nên yêu cầu nhiều mảnh phản chiếu, không phải một mảnh.

1 ký ức tốt → NPC nghi ngờ

2 ký ức tốt → NPC dao động

3 ký ức tốt → NPC bắt đầu đối mặt

4 ký ức tốt + hành động cuối → NPC tự nhận ra

8\. Dùng “hậu quả trong mơ” để NPC hiểu

Một cách nữa rất hay: để NPC thấy niềm tin sai của họ đang làm hại chính họ.

Ví dụ Mira tin:

“Nếu mình đeo mặt nạ, mọi người sẽ thích mình hơn.”

Trong giấc mơ, mỗi lần cô đeo mặt nạ:

gương đẹp hơn,

nhưng hoa héo đi,

bức tranh ký ức bị mờ,

giọng nói của cô nhỏ lại,

người thân trong mơ không nhận ra cô.

Người chơi không cần nói “mặt nạ không tốt”. NPC tự thấy:

“Mỗi lần mình cố trở thành người khác, những phần thật của mình biến mất.”

Đây là cách rất mạnh: cho NPC thấy hậu quả của cơ chế phòng vệ.

9\. Vậy người chơi thực sự làm gì?

Người chơi không chọn đáp án. Người chơi làm 5 loại hành động:

1\. Khôi phục ký ức

Tìm mảnh ký ức và đặt lại đúng nơi.

2\. Đưa biểu tượng về đúng hình dạng

Sửa gương méo, nối cầu gãy, làm đồng hồ chạy tiếp.

3\. Kết nối các bản thể của NPC

Dẫn “NPC nhỏ bé”, “NPC đeo mặt nạ”, “NPC thật” gặp nhau.

4\. Tạo phản chứng cho niềm tin sai

Đặt các ký ức tốt quanh biểu tượng trung tâm.

5\. Thực hiện nghi thức tỉnh mộng

Một hành động cuối có ý nghĩa, ví dụ đặt mặt nạ xuống, mở cửa từ bên trong, thả bài kiểm tra bay đi, lắp kim đồng hồ chạy tiếp.

10\. Ví dụ cảnh tự nhận ra của Mira

Cảnh cuối có thể diễn ra như này:

Người chơi đặt mặt nạ xuống trước gương thật.

Gương ban đầu phản chiếu khuôn mặt Mira.

Mira lùi lại.

Sau đó gương chuyển cảnh:

Mira đang cứu con mèo.

Mira đang nghe bạn mình khóc.

Mira đang tặng hoa cho bà cụ.

Mira đang run rẩy sau lời chê bai cũ.

Mira nhỏ bé đứng cạnh Mira hiện tại.

Mira nhỏ bé hỏi:

“Vậy… chúng ta chỉ là khuôn mặt này thôi sao?”

Mira hiện tại im lặng.

Những bông hoa trong phòng nở dần.

Mira hiện tại nói:

“Không… hình như mình đã quên mất những phần khác của mình.”

Cánh cửa tỉnh giấc mở ra.

Đoạn này khiến NPC tự nhận ra vì chính cô ấy nhìn thấy toàn bộ bản thân, không chỉ ngoại hình.

11\. Kết luận thiết kế

Để NPC tự nhận ra nỗi đau của mình, game cần 3 thứ:

Một là: ký ức gốc

Cho biết vì sao NPC bị tổn thương.

Hai là: ký ức phản chứng

Cho thấy niềm tin tiêu cực của NPC không phải toàn bộ sự thật.

Ba là: hành động biểu tượng

Người chơi thay đổi giấc mơ để NPC tự nhìn thấy sự thật.

Công thức ngắn gọn:

Không giảng giải.

Không chọn đáp án.

Không ép NPC hiểu.

Hãy để người chơi khôi phục ký ức,

biến đổi biểu tượng,

và tạo ra một cảnh phản chiếu

để NPC tự nói ra điều họ đã né tránh.
# **27. Kết luận**
Bản V2 này chuyển ý tưởng Người Dịch Giấc Mơ từ concept thành một kế hoạch triển khai thực tế cho AI coding. Trọng tâm không phải làm game thật lớn, mà làm một prototype nhỏ nhưng có chất riêng: giải đố bằng biểu tượng, suy luận qua ký ức, và giúp NPC tự nhận ra nỗi đau thông qua hành động trong giấc mơ.

Nếu triển khai đúng scope MVP, game có thể trở thành một đồ án rất khác biệt: không cần hệ thống quá phức tạp, nhưng có chiều sâu cảm xúc, gameplay rõ ràng và khả năng mở rộng thành nhiều chương sau này.
Tài liệu thiết kế game - bản chi tiết triển khai prototype
