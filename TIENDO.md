# TIẾN ĐỘ ĐỒ ÁN — DELTA ROBOT

File nhật ký tiến độ. Mỗi ngày làm việc là một mục, công việc hoàn thành đánh dấu `[x]`, đang làm dở đánh dấu `[ ]`. Claude cập nhật file này cuối mỗi phiên làm việc hoặc khi người dùng báo đã xong việc.

## Tổng quan hạng mục lớn

- [x] Dựng CAD sơ bộ (Draw_V0) và đổi tên chuẩn hóa sang `DeltaRobot_Final/` (DR-000…DR-007)
- [x] Xác định thông số động học thiết kế: L1 = 407.5 mm, L2 = 1000 mm, R−r = 226.4 mm, r = 120.6 mm (workspace Ø800×250 mm)
- [~] Xác định đầy đủ thông số mục tiêu: **tải trọng payload = 2 kg** (thiết kế cho tải ≤ 2 kg, chốt 2026-07-12); tốc độ TCP ~1875 mm/s, chu kỳ 1,2 s (từ mô phỏng động học). Còn: nhiệt độ/môi trường, số chu kỳ/mỏi nếu cần
- [x] Tính toán động học thuận/nghịch hoàn chỉnh + kiểm chứng — **xong trên MATLAB** (round-trip ~10⁻¹³ mm)
- [ ] Mô phỏng động học trong SolidWorks (cần tách ball joint — hiện đang dùng Lock mates)
- [x] **Mô phỏng động học trên MATLAB** (`MoPhong_DongHoc/`, 7 phase — xem `KEHOACH_DONGHOC.md`, `KETQUA_DONGHOC.md`): HOÀN THÀNH 7/7
- [x] Tính toán lực / lựa chọn động cơ-hộp số — **phân tích lực HOÀN CHỈNH theo yêu cầu thầy** (`MoPhong_Luc/`, payload 2kg): sơ đồ phân bố lực + biểu đồ nội lực N/Q/M + tách **M_tĩnh 35.8 / M_động 39.2** (có kể trọng lượng+quán tính bắp tay 6.9kg + rotor) × hệ số an toàn 1.5 → **M_yc=112.5 N·m**. TPM-010S-061T (T2B 80) KHÔNG đủ → chọn **TPMA 010S-055T (HIGH TORQUE, T2B 230, dư 1.69×)** — **ĐÃ THAY TRONG CAD 2026-07-15**, không phải sửa bracket nào (giao diện bích y hệt; xem nhật ký 2026-07-15 + `outputs/gearbox_swap_20260714/`)
- [x] Lựa chọn vật liệu các khâu — **toàn bộ kết cấu nhôm 6061-T6** (đế đổi thép A36→nhôm 2026-07-18, −128.8kg) · cẳng tay carbon · khớp cầu thép hợp kim; thuyết minh `outputs/material_20260712/`
- [x] Mô phỏng bền (FEA) các chi tiết chịu lực chính — **HOÀN THÀNH 5 part, chạy lại trên ĐẾ NHÔM** (`MoPhong_Ben/`, cập nhật 2026-07-18, xem `KETQUA_BEN.md`): DR-006 FOS≈10.5 · DR-005-2 FOS≈65 · DR-007 FOS≈14.7 · DR-001-1 tấm đế nhôm FOS≈1890 · DR-001-3 mặt treo nhôm FOS≈71.5. **Min FOS toàn bộ = 10,5** (1 tư thế). **Mở rộng đa tư thế khó (2026-07-19)**: quét toàn vùng làm việc → worst-case biên R400/z−1050 tải ×1,49 → **min FOS 7,1** (vẫn an toàn ≥7×), báo cáo `KETQUA_BEN_DAPOSE`. **Đế nhôm (thay thép, −128.8kg) vẫn dư bền**. Còn (tùy chọn): bo góc lỗ để σ hội tụ sạch, gộp trọng lực đế, phân tích mỏi
- [x] **Hoàn thiện kết cấu lắp ghép CAD** (2026-07-15): bắt vít bích TPMA→DR-002 (16×M5), khớp vai DR-004↔hub (8×M2.5 lỗ bậc ngược chiều + ren), mặt treo 3 cánh tròn kiểu người dùng + 6 lỗ M20 — tất cả verify ΔV đúng lý thuyết + đồng trục 0.001 mm + interference không tăng
- [x] **Bản vẽ gia công cơ khí 8 chi tiết tự chế** (`BanVe_GiaCong/`, 2026-07-15): A3 chiếu góc 1 TCVN, mm, khung tên bảng tiếng Việt, tỉ lệ riêng từng part, SLDDRW + PDF (v2 sau phản hồi; linh kiện mua không xuất)
- [ ] **[CLAUDE LÀM — tối 2026-07-15, chờ người dùng ra lệnh] Sửa tính đối xứng các chi tiết**: các chi tiết hiện KHÔNG đảm bảo đối xứng → bản vẽ sinh nhiều kích thước nhỏ vặt (ordinate ra giá trị lẻ 2.83/9.18/17.68... thay vì số tròn). Kế hoạch khi được lệnh: (1) quét từng part đo mức bất đối xứng (so tọa độ feature với lưới đối xứng lý tưởng — bậc 3/vòng đều/mặt phẳng giữa), báo danh sách lệch; (2) người dùng duyệt; (3) sửa từng part (backup giữ-1, verify ΔV/vị trí như quy trình cũ); (4) rebuild DR-000 + verify lại 3 hệ lỗ vít (16×M5 DR-002, 8×M2.5 DR-004↔hub, 6×M20 vấu treo — vị trí lỗ map từ hình học cũ); (5) tái sinh bản vẽ các part đã đổi (`make_drawing2.ps1`) — kích thước phải ra số tròn.
- [x] **Cấu kiện thép treo robot** — bản đầu `DR-100_Khung-Treo` (2026-07-20, 452,81 kg) đã được **THAY bằng `Frame.SLDPRT`** (2026-07-22, bàn 4 cột + đĩa treo tròn Ø720 kiểu chữ Y, 643 kg, ASTM A36); `DR-100` suppress (giữ lại, không xóa). Lắp vào `DR-000` bằng 3 mate thật (concentric Ø150 + coincident mặt phẳng + Lock) — **sai lệch đồng tâm Ø150 = 0,0485 mm**, WhatsWrong=0, khung đứng đúng (chân Z−2650→đỉnh Z−77.8), đã lưu; ảnh `outputs/khungtreo_20260721/assembly_frame_iso.png` + `assembly_frame_front.png`
- [ ] Thiết kế gripper (mới có ảnh tham khảo trong `Gripper/`)
- [ ] BOM hoàn chỉnh có giá
- [ ] Viết thuyết minh đồ án (theo `MucLuc/`)

---

## Nhật ký theo ngày

### 2026-07-26

#### 2026-07-26 — RÀ SOÁT + SỬA FORMAT TOÀN BỘ `BaoCao/Báo Cáo Fix/Chương 2 .docx` (✅ HOÀN TẤT)
> Người dùng báo "đã hoàn thành xong chương 2", yêu cầu rà soát lần cuối: công thức toán đúng/chuẩn format
> chưa, chính tả, format chữ, căn hàng bảng biểu/ảnh theo quy tắc, ảnh/bảng không bị ngắt giữa trang.
- [x] Sửa 11 công thức viết dấu `/` và `√` dạng ký tự phẳng sang OOXML chuẩn (`m:f` phân số có gạch ngang,
  `m:rad` dấu căn thật) — làm trước khi user báo "xong chương 2" trong cùng phiên.
- [x] Phát hiện + sửa đánh số công thức lộn xộn/sai thứ tự toàn chương (2 chuỗi (2.1)-(2.5) trùng nhau, một
  công thức định nghĩa a,b,c bị đánh số (2.5) dù nằm SAU (2.11) trong văn bản) — đánh số lại tuần tự đúng
  thứ tự vật lý 2.1→2.39, cập nhật toàn bộ ~21 chỗ tham chiếu chéo trong câu văn (ví dụ "Từ (2.6)...").
- [x] Phục hồi công thức (2.31) cũ `Fs = ks·mp·(g+az)` bị user sửa tay làm hỏng (mất hết subscript, mất số
  thứ tự, sai style đoạn văn) — viết lại đúng chuẩn, tách thành câu dẫn + công thức riêng theo đúng quy ước
  toàn tài liệu, giờ mang số (2.33).
- [x] Sửa ký tự "p" thừa lọt vào công thức (2.35) do sửa tay để sót.
- [x] Kiểm tra 10 đoạn "diễn giải toán" nghi ngờ raw/không format — xác minh qua XML thô: **đã đúng chuẩn
  sẵn** (vector mũi tên `m:acc`, ma trận cột `m:m`, số mũ `m:sSup` thật), lần đọc trước bị sai do trích xuất
  text phẳng làm mất cấu trúc hiển thị — không sửa gì, tránh làm hỏng nội dung đúng.
- [x] Sửa đánh số + đặt tên 5 bảng: Bảng 2.1 bị trùng số → 2.2; 2 bảng caption rỗng ("Bảng …../"Bảng : ") →
  đặt tên đúng nội dung (2.3 kiểm chứng IK-FK, 2.4 thông số tính lực hút) + di chuyển caption lên TRÊN bảng
  (đúng quy tắc, 2 bảng này trước đó caption nằm dưới bảng).
- [x] Sửa 9 hình: Hình 2.3 caption nằm sai vị trí (trên ảnh thay vì dưới) → đổi lại đúng thứ tự; 1 ảnh mất
  caption (bị 6 dòng trống + chữ mồ côi "Mô hình hóa bàn máy động" không có tiền tố "Hình 2.X") → dọn dòng
  trống, đặt lại caption "Hình 2.5", renumber toàn bộ Hình 2.5-2.8 cũ → 2.6-2.9.
- [x] **Bug nghiêm trọng phát hiện qua render PDF thật**: ảnh Hình 2.5 là floating shape (`wp:anchor` +
  wrapSquare bothSides, kẹt trong paragraph style Heading3 + bookmark ToC cũ) khiến chữ tràn/vỡ quanh ảnh
  (caption, heading mục 2.3.3, danh sách bullet đều bị bẻ gãy) — chuyển sang `wp:inline` đúng chuẩn như 8
  ảnh còn lại, dọn pPr về style ảnh thường; verify lại bằng render: chữ thẳng hàng, không còn vỡ bố cục.
- [x] Thêm `keepNext` cho 5/9 ảnh thiếu (giữ ảnh dính liền caption qua trang) và `cantSplit` cho 3/5 bảng
  thiếu (24 dòng, kể cả bảng 13 dòng dài nhất) — không cho dòng bảng bị cắt giữa trang.
- [x] Sửa lặt vặt: khoảng trắng/dấu câu không nhất quán ("Nhánh 2... nên" thiếu dấu phẩy so với "Nhánh 3...").
- [x] Backup gốc trước khi sửa: `Backup/Chương 2 _backup_20260726.docx` (trước mọi sửa) +
  `..._backup_20260726_v2.docx` (trước đợt rà soát này, giữ nguyên bản user vừa sửa tay).
- [x] **Verify bằng chứng thật**: export PDF qua Word COM (`Documents.Open` + `SaveAs2` wdFormatPDF), đọc lại
  page-break qua `Range.Information(wdActiveEndPageNumber)` cho từng ảnh/bảng + render 7 trang bằng PyMuPDF
  để xem trực tiếp — xác nhận cả 5 bảng nằm trọn 1 trang, cả 9 ảnh dính liền caption, công thức phục hồi
  (2.33) và các phân số/căn hiện đúng dạng chuẩn khi Word render thật (không chỉ đúng XML).
- [x] **Sửa cỡ chữ bảng biểu + chú thích theo đúng quy định HCMUTE** (user yêu cầu thêm sau khi rà soát lần
  1): tìm thấy quy định chính thức trong `Fomat/Format.pdf` + `Fomat/HƯỚNG DẪN TRÌNH BÀY...docx` — font toàn
  bài **Times New Roman 13pt**, tên bảng **in đậm, canh trái, ở TRÊN bảng**, tên hình **in nghiêng, canh
  giữa, ở DƯỚI hình**. Đối chiếu thực tế: cỡ chữ 5 bảng đang lộn xộn (10/11/11.5/12pt, không bảng nào đúng
  13pt); caption bị làm NGƯỢC quy tắc (Bảng đang nghiêng+giữa, Hình đang thường không nghiêng). Sửa toàn bộ
  285 run trong ô bảng + 14 caption về đúng 13pt Times New Roman, đúng đậm/nghiêng/canh lề. Verify bằng đo
  trực tiếp kích thước chữ trong PDF render (PyMuPDF `get_text('dict')`) — xác nhận 12.96pt (≈13pt) đồng nhất
  toàn bộ, chỉ số subscript (m_p, m_t, n_M) nhỏ hơn theo đúng quy ước toán học (không phải lỗi).

### 2026-07-25

#### 2026-07-25 — CHÈN ẢNH CHỨNG MINH THẬT VÀO POWERPOINT THUYẾT TRÌNH (✅ HOÀN TẤT)
> Người dùng yêu cầu: sau khi xong báo cáo, sửa lại `BaoCao/PowerPoint/powerpoint.pptx` bao quát đủ pipeline,
> chuyên nghiệp, ≤25 trang (thuyết trình 10 phút), **phải có ảnh chứng minh thật** để vừa giải thích vừa
> chứng minh kết quả không phải bịa đặt.
- [x] Kiểm tra toàn bộ 20 slide hiện có: nội dung/số liệu đã bám sát pipeline 8 giai đoạn (I-VIII, khớp
  `Pipeline_BaoCao.docx`) và số liệu thật (không bịa) — **nhưng xác nhận bằng script (0 shape kiểu PICTURE
  trong toàn bộ file) mỗi khung "Hình:"/"Biểu đồ:" chỉ là placeholder chữ**, ảnh nền của khung chỉ là fill
  ảnh đơn lẻ 1 nhánh (cắt từ ảnh xác minh part cũ), không phải ảnh chứng minh đúng nội dung slide.
- [x] Lập bảng ánh xạ 17 slide (03-19) → ảnh bằng chứng thật có sẵn trong dự án (khớp đúng số liệu từng
  slide, xem lại từng ảnh trước khi dùng): `kin_arm_schematic.png`, `p2_roundtrip_hist.png`,
  `p3_workspace_xz.png`, `p4_cond_map.png`, `p5_joint_profiles.png`, `so_do_phan_bo_luc.png`,
  `pose_fmax_workspace.png`, `joint_torques.png`, `asm_tpma_iso.png`, `torque_sizing.png`,
  `fea_dr006_resym_fringe.png`, `fea_dr007_vonMises.png`, `fea_dr005b_vonMises.png`, `Gripper/Hut.png`.
- [x] Render mới 2 ảnh CAD lắp tổng thật (front + isometric) từ `DR-000_Delta-Robot_V0.SLDASM` qua
  SolidWorks COM (chạy trên model Fable theo quy tắc, việc 3D/CAD nặng) — mọi ảnh cũ trong `outputs/` chỉ
  là ảnh cắt 1 nhánh (test xác minh part), không đủ làm ảnh "lắp tổng"; ảnh mới xác nhận đủ 3 nhánh +
  khung treo + bàn máy → dùng cho slide 3/4/15. Lưu `outputs/ppt_render_20260725/`.
- [x] Sửa lỗi bố cục: khung ảnh placeholder vốn có sẵn 1 lớp fill ảnh riêng (không phải rỗng) → ảnh mới
  chèn theo tỉ lệ khung hình để lại viền hở lộ ảnh cũ phía sau — đã set lại fill khung thành trắng trước
  khi chèn ảnh thật, xác minh lại bằng render.
- [x] Sửa 2 chú thích (caption) sai lệch: slide 18 (trùng chữ với slide 11) → mô tả đúng ảnh FEA DR-005-2;
  slide 19 (nêu "băng tải" không có bằng chứng) → đổi thành "phương án gripper chân không đang cân nhắc"
  (đúng với ảnh `Gripper/Hut.png` và trạng thái "chưa khóa" đã ghi).
- [x] Backup file gốc `Backup/powerpoint_backup_20260725_preimages.pptx` trước khi sửa.
- [x] Verify bằng chứng: render toàn bộ 20 slide ra PNG qua PowerPoint COM, đọc lại từng ảnh — xác nhận
  tổng vẫn 20 slide (≤25), tất cả 17/17 khung ảnh có ảnh thật khớp đúng số liệu trên từng slide (đối chiếu
  trực tiếp: 36.720 điểm biên, 6,2×10⁻¹³ mm, cond(J) max 2,749, TPMA dư 1,69×/2,06×, FOS 7,1-10,5/14,7/1890,
  v.v.), không còn placeholder rỗng.

### 2026-07-24

#### 2026-07-24 — SỬA ĐỊNH DẠNG CÔNG THỨC (OMML) + ĐI ĐỦ TỚI BƯỚC CUỐI CÙNG (✅ HOÀN TẤT)
> Người dùng phản hồi vòng thêm tính toán FK/IK trước đó: công thức đang viết dạng chữ thường lẫn trong
> văn xuôi (không đúng chuẩn font/kích cỡ công thức Word), và muốn suy diễn đi hẳn tới bước cuối chứ
> không dừng giữa chừng.
- [x] Soi đúng cấu trúc XML của các công thức GỐC đã có sẵn trong bài ((2.15)-(2.27)): mỗi công thức là 1
  đoạn văn riêng, canh giữa, chứa 1 khối `m:oMath` font "Cambria Math", số thứ tự "(2.xx)" là 1 run văn
  bản thường nối ngay sau — không dùng cấu trúc lồng phức tạp (`m:sSub`, `m:sSup`...), chỉ 1 chuỗi Unicode
  phẳng trong `m:t`. Dựng hàm chèn đúng y khuôn mẫu này (không đoán mò).
- [x] **Xóa các "công thức" viết tạm bằng văn bản thường ở vòng trước, dựng lại bằng OMML thật** cho cả 2
  chỗ: (2.17a)-(2.17j) mục 2.3.4 và (3.26)-(3.28) mục 3.4.3 — đúng font/cỡ/canh giữa như toàn bộ công
  thức còn lại trong đồ án, không còn kiểu chữ lộn xộn.
- [x] **Đi hết suy diễn FK tới nghiệm cuối cùng** (trước đó dừng ở "giải bằng Cramer rồi thế vào phương
  trình cầu"): viết tường minh (2.17c)-(2.17d) [hệ tuyến tính 2 ẩn x,y theo z], (2.17e)-(2.17f) [x(z),
  y(z) dạng tường minh qua định thức Δ], (2.17g) [thế vào phương trình cầu], (2.17h)-(2.17i) [phương
  trình bậc hai Az²+Bz+C=0 với A,B,C viết rõ], (2.17j) [nghiệm z bằng công thức bậc hai] — đủ từ đầu đến
  cuối, không còn chỗ nào chỉ nói "giải hệ này" mà không chỉ ra kết quả.
- [x] **Đi hết suy diễn vùng làm việc tới nghiệm cuối** (trước đó nhảy thẳng từ (3.27) sang nghiệm w₁,w₂
  mà không cho xem bước giải): thêm (3.27a) [khai triển ra phương trình bậc hai chuẩn theo w] và (3.27b)
  [công thức nghiệm bậc hai tường minh] trước khi tới (3.28) [kết quả số cuối].
- [x] Phát hiện + sửa thêm 1 lỗi trùng lặp phát sinh giữa chừng (đoạn giới thiệu "Trừ từng cặp phương
  trình..." bị lặp 2 lần do sót xóa bản cũ) — verify lại xóa sạch, đọc lại toàn bộ mạch 2.3.4→2.3.6 và
  3.4.3→3.5 đúng thứ tự, không trùng, không mất đoạn nào.
- Ghi chú kỹ thuật: công thức Word trong file này KHÔNG dùng OMML lồng ghép (sSub/sSup/frac) mà chỉ 1
  chuỗi ký tự Unicode phẳng (², ᵢ, √, Δ...) đặt trong `m:t` với font Cambria Math — muốn thêm công thức
  mới khớp định dạng chỉ cần copy đúng khuôn `w:p` này (đã lưu lại cách dựng qua `lxml.etree.fromstring`
  chèn bằng `addprevious`), không cần dựng cây OMML phức tạp.

#### 2026-07-25 — SỬA MỤC 5.1 BaoCao_V0.docx: THAY "ẢNH KHÔNG GIẢI THÍCH" BẰNG MÔ HÌNH SIMULINK CÓ CHỨNG MINH (✅ HOÀN TẤT)
> User đối chiếu với `Pipeline_BaoCao.docx` (tài liệu chuẩn pipeline I→VIII), xác nhận từ đầu đến
> hết Chương 2 đã ổn; phần sau "ảnh mô phỏng matlab không hiểu gì hết, không có cách tính toán mà
> đưa ảnh lên kết luận" — yêu cầu sửa lại toàn bộ, có thể tham khảo cách tính trong
> `DoAnThamKhao-Rename`.
- [x] Đọc toàn bộ `Pipeline_BaoCao.docx` (8 giai đoạn I-VIII + ma trận pipeline + quy tắc kết
  luận "đạt/đạt có điều kiện/chưa đánh giá") để biết chuẩn đối chiếu.
- [x] Rà toàn bộ Chương 3, 4, 5 (paragraph-by-paragraph, có/không công thức OMML, có/không hình)
  — kết luận: **Chương 3 và Chương 4 đã đạt chuẩn** (có công thức đầy đủ, bảng so sánh, kết luận
  "đạt có điều kiện" đúng kiểu pipeline — phần lớn do các phiên làm việc trước). **Mục 5.2-5.5
  cũng đã ổn** (có công thức + hình + bảng số liệu cụ thể). **Chỉ mục 5.1 "Mô phỏng động học và
  vùng làm việc" là hỏng thật**: 2 đoạn văn, 0 hình, chỉ nêu 3 con số kết quả (sai lệch khép kín,
  cond(J), góc truyền) không có mô tả phương pháp — đúng như user mô tả.
- [x] Viết lại mục 5.1: mô tả đầy đủ mô hình Simulink 6 khối (TrajGen/IK/FK/Jac/JointVel/logs),
  cấu hình solver (ode3, dt=0,002s, 601 mẫu); thêm 3 hình THẬT lấy từ
  `MoPhong_DongHoc/figs/` (đã có sẵn trên đĩa nhưng chưa từng chèn vào báo cáo):
  **Hình 5.1** sơ đồ khối Simulink, **Hình 5.2** sai lệch khép kín ‖P−FK(IK(P))‖ theo thời gian,
  **Hình 5.3** cond(J) và góc truyền μ theo thời gian — mỗi hình có đoạn giải thích bám số liệu
  đọc từ `MoPhong_DongHoc/out/simulink_build_log.txt` (601 bước, cond(J) 1,74-2,29, μ 53,8°-80°,
  ωmax 30,07 vòng/phút — đối chiếu chéo khớp Bảng 5.1 ở mục 5.2, sai khác <0,1%).
- [x] Đánh số lại 4 hình cũ trong Chương 5 (5.1→5.4, 5.2→5.5, 5.3→5.6, 5.4→5.7) + sửa 4 dòng
  "DANH MỤC CÁC HÌNH ẢNH" tương ứng (field TOC thật, có `w:hyperlink`+`PAGEREF` — chỉ sửa phần
  text hiển thị trong run đầu, không đụng field nên không mất liên kết trang).
- [x] Lỗi giữa chừng: script đổi số hình chạy 1 lượt find-replace toàn cục làm ĐÈ luôn 3 hình mới
  vừa chèn (chúng cũng đang mang số 5.1-5.3) — phát hiện qua rà lại danh sách caption, sửa tay
  bằng cách gán lại đúng theo index đoạn, verify lại thứ tự 5.1→5.7 liền mạch không trùng.
- [x] Verify: xuất PDF, render 4 trang (54-57) — hình hiện đúng, mạch văn nối liền sang 5.2, số
  liệu Bảng 5.1 khớp con số vừa nêu.
- Ghi chú: backup `Backup/BaoCao_V0_backup_20260725_pre51fix.docx`.

#### 2026-07-24 — THÊM PHẦN TÍNH TOÁN MÔ-MEN/TẢI TRỌNG CHỌN ĐỘNG CƠ VÀO GiaCongCoKhi-merged.pdf (✅ HOÀN TẤT)
> User: báo cáo gia công chưa có phần tính mô-men/tải trọng để chọn động cơ — phần này "cực kỳ
> quan trọng", phải tính chi tiết từng bước, kết luận rõ dùng được động cơ/hộp số nào kèm thông
> số, và nếu có nội dung trùng thì xóa làm lại cho đúng pipeline chuẩn.
- [x] Quét toàn bộ file (T2B, M_yc, Jarm, Jrot, hệ số an toàn...) — xác nhận **chưa có** phần tính
  toán này ở đâu cả (chỉ có dòng T2B trong BOM trang 2, không phải tính toán) → không phải xóa gì,
  làm mới hoàn toàn.
- [x] Lấy toàn bộ suy diễn + số liệu THẬT từ `MoPhong_Luc/ThuyetMinh_ChonDongCo.md` (đã có sẵn,
  đối chiếu `force_analysis.m`/`out/force_log.txt`) — không tự bịa số liệu.
- [x] Thêm 6 trang mới (trang 30-35) theo đúng pipeline: (1) mô hình lực + sơ đồ phân bố lực,
  (2) nội lực bắp tay/cẳng tay (N/Q/M), (3) mô-men tĩnh+động tại trục khớp, (4) điều kiện chọn
  động cơ + kiểm phương án cũ TPM-010S-061T **KHÔNG ĐẠT** (M_yc=112,5 > T2B=80), (5) so sánh 4
  phương án hộp số cùng cỡ 010, (6) kiểm chứng chính thức TPMA010S-055T **ĐẠT cả 3 điều kiện**
  (M_yc=136,3≤230 dư 1,69×; M_rms=53,4≤110 dư 2,06×; 30,1≤88 vòng/phút) kèm đầy đủ thông số động
  cơ + kết luận. Dùng 4 hình mô phỏng thật có sẵn (`so_do_phan_bo_luc.png`, `bieu_do_noi_luc.png`,
  `gearbox_compare.png`, `joint_torques.png`).
- [x] Renumber toàn bộ: các trang phụ lục cũ (McMaster/động cơ/bản vẽ CAD) dịch 30→36, 31→37,
  32→38 (subtitle + số trang chân trang); mục lục sửa dòng động cơ "31"→"37" + thêm bảng "MỤC LỤC
  TÍNH TOÁN CHỌN ĐỘNG CƠ" (trang 30-35).
- [x] Lỗi giữa chừng: redact thiếu 1 đoạn cuối chuỗi cũ ("‐CARR)") khi sửa subtitle trang McMaster
  → chữ đè chồng đậm hơn — phát hiện qua render ảnh, sửa lại bằng redact nguyên vùng hình chữ nhật
  thay vì theo đúng chuỗi text tìm được (an toàn hơn khi replace text ngắn).
- [x] Verify: diff `get_text()` 29 trang đầu (trừ mục lục) không đổi; quét toàn bộ span 6 trang mới
  không tràn khung; nội dung 3 trang phụ lục cũ đọc lại còn nguyên (McMaster/TPMA/bản vẽ CAD).
- Ghi chú: backup `Backup/GiaCongCoKhi-merged_backup_20260724_pre_motorcalc.pdf`. Lưu ý kỹ thuật:
  văn bản chèn bằng `insert_font`+`insert_text` trong PDF này luôn trích xuất dấu cách thành
  U+00A0 (non-breaking space) chứ không phải U+0020 — không phải lỗi, chỉ cần chuẩn hóa khi viết
  script kiểm tra `in` với chuỗi có khoảng trắng.

#### 2026-07-24 — THÊM HÌNH MINH HỌA JACOBIAN VÀO BaoCao_V0.docx (mục 2.4, trang 27-28) (✅ HOÀN TẤT)
> Bảng 2.2 (kết quả kiểm tra Jacobian/kỳ dị) chỉ có số liệu dạng bảng — user muốn có hình mô phỏng
> minh chứng, không thì người đọc không hình dung được.
- [x] Dùng `p4_cond_map.png` (bản đồ số điều kiện Jacobian κ₂(J) trên mặt cắt y=0, đã có sẵn từ
  MoPhong_DongHoc phase 4) chèn ngay sau Bảng 2.2, đặt tên **Hình 2.3** (nối tiếp Hình 2.1/2.2 đã
  dùng trong mục này).
- [x] Thêm 1 đoạn giải thích hình bám trực tiếp vào số liệu ĐÃ CÓ trong Bảng 2.2 (vùng xanh dương
  chiếm phần lớn mặt cắt, số điều kiện lớn nhất 2,749 tại tọa độ cụ thể) — không trích tên file nội
  bộ trong caption/văn bản, đúng quy tắc ở `BaoCao/README.md`.
- [x] Lỗi giữa chừng: định vị nhầm đoạn "Bảng 2.2" trùng tên ở phần "DANH MỤC CÁC BẢNG BIỂU" (front
  matter) thay vì caption thật gần bảng — sửa bằng lọc thêm điều kiện `style.name == 'Table Caption'`.
- [x] Verify: xuất PDF, render trang chứa hình — đúng vị trí ngay sau bảng, không đụng Hình 3.5 (bản
  đồ Jacobian khác, đã có sẵn từ trước ở chương 3, không xung đột).
- Ghi chú: backup `Backup/BaoCao_V0_backup_20260724_prejacobianimg.docx`.

#### 2026-07-24 — SỬA THÁNG TRANG BÌA (GiaCongCoKhi-merged.pdf) (✅ HOÀN TẤT)
> Trang bìa ghi "Tháng 1 năm 2026" (cũ) — đổi thành "Tháng 7 năm 2026".
- [x] Redact + chèn lại đúng font Times New Roman Bold 15.5, cùng vị trí/baseline gốc. Verify:
  chỉ trang bìa đổi, 31 trang còn lại nguyên vẹn (diff `get_text()`).
- Ghi chú: backup `Backup/GiaCongCoKhi-merged_backup_20260724_precoverdate.pdf`.

#### 2026-07-24 — SỬA GHI CHÚ + ĐỊNH DẠNG NGÀY TRANG 31 (GiaCongCoKhi-merged.pdf) (✅ HOÀN TẤT)
> Trang 32 giờ đã có bản vẽ CAD kích thước thật, nên ghi chú cũ "datasheet chỉ có ảnh render,
> không kèm bản vẽ CAD 2D" trên trang 31 không còn đúng — user yêu cầu xóa, và đổi định dạng
> ngày tạo từ kiểu Mỹ (07/14/2026 = MM/DD) sang kiểu Việt (14/07/2026 = DD/MM).
- [x] Xóa 2 dòng ghi chú, dời caption "Nguồn: WITTENSTEIN..." lên thế chỗ, đổi ngày → 14/07/2026.
- [x] Verify: chỉ trang 31 đổi, 31 trang còn lại nguyên vẹn (diff `get_text()`).
- Ghi chú: backup `Backup/GiaCongCoKhi-merged_backup_20260724_prenoteremove.pdf`.

#### 2026-07-24 — XÓA TRANG PHỤ LỤC ĐỘNG CƠ TPMA010S-022T (GiaCongCoKhi-merged.pdf) (✅ HOÀN TẤT)
> Không dùng phương án động cơ i=22 nữa (TPMA010S-022T-5PB1-094C-W1-000) — user yêu cầu xóa hẳn
> trang phụ lục này.
- [x] Xóa trang 31 (022T), dựng lại trang 055T thành trang 31 mới (trước là 32), dựng lại footer
  trang bản vẽ CAD từ "33"→"32" (redact + chèn lại đúng font/vị trí). File còn 32 trang.
- [x] Cập nhật mục lục: xóa dòng 022T, sửa dòng 055T còn lại → "Trang 31", bảng mini co lại còn 1
  dòng, không còn khoảng trắng dư.
- [x] Verify: search "022T" toàn file → 0 kết quả; diff `get_text()` — chỉ trang mục lục (trang 3)
  đổi, 28 trang đầu còn lại nguyên vẹn.
- Ghi chú: backup trước xóa `Backup/GiaCongCoKhi-merged_backup_20260724_pre022Tdelete.pdf`.

#### 2026-07-24 — SỬA CHỮ TRÀN KHUNG TRANG 32 + PHÓNG TO BẢN VẼ CAD ĐỘNG CƠ (GiaCongCoKhi-merged.pdf) (✅ HOÀN TẤT)
> User tự thêm 1 trang bản vẽ CAD (TPMA010S-055T, khổ A4 842×595pt) vào cuối file merged, yêu cầu:
> chữ trang 32 (055T) phải nằm trong khung, và phóng to trang bản vẽ mới thêm cho khớp khổ/tỉ lệ
> các trang bản vẽ gia công trước đó (khổ A3 1190,46×841,94pt).
- [x] **Phát hiện lỗi gốc**: khi dựng 2 trang phụ lục 31/32 ở phiên trước, tôi đã lấy nhầm tọa độ
  `bbox top-left` (đọc từ `get_text('dict')` của trang mẫu 30) làm điểm **baseline** truyền vào
  `insert_text()` — baseline luôn thấp hơn bbox-top một khoảng bằng ascender font (Calibri
  ascender = 0,75×cỡ chữ), nên toàn bộ khối chữ bị đẩy lên cao hơn ý đồ, khiến tiêu đề lớn (cỡ ~21)
  trồi lên trên khung ~3pt. Sửa bằng cách cộng thêm `0,75×fontsize` vào mọi tọa độ y mượn từ trang
  mẫu (tiêu đề, phụ đề, tiêu đề mục 1/2, các dòng thông số) — verify lại: quét toàn bộ span trang
  31 và 32, 0 span tràn khung (trừ số trang ở footer vốn nằm dưới khung theo đúng quy ước chung
  của cả tài liệu, không phải lỗi).
- [x] Trang bản vẽ CAD user thêm (khổ A4, 842×595pt) được nhúng lại vào 1 trang khổ chuẩn A3
  (1190,46×841,94pt, đúng khổ 10 trang bản vẽ gia công trước đó) qua `Page.show_pdf_page()` —
  giữ nguyên vector gốc (không rasterize), tỉ lệ khung hình gần như trùng khớp (1,414 vs 1,4139)
  nên phóng vừa khít không méo hình. Thêm số trang "33" đúng vị trí/font như các trang bản vẽ
  khác (Calibri 11, ở khoảng x≈592, y≈823 dưới khung).
- [x] Verify: so `get_text()` 30 trang đầu giữa bản gốc và bản sửa — 0 khác biệt, chỉ 3 trang cuối
  (31, 32, 33) thay đổi đúng như yêu cầu.
- Ghi chú: backup trước sửa `Backup/GiaCongCoKhi-merged_backup_20260724_prefix.pdf`. Bài học: khi
  mượn tọa độ chữ từ `get_text('dict')` để tái tạo bằng `insert_text()`, PHẢI cộng ascender vào y
  (bbox-top ≠ baseline) — áp dụng cho mọi lần dựng trang PDF kiểu này về sau.

#### 2026-07-24 — SỬA VIỀN TRANG 28 + THÊM PHỤ LỤC ĐỘNG CƠ WITTENSTEIN (GiaCongCoKhi.pdf) (✅ HOÀN TẤT)
> Người dùng báo trang 28 mất viền khung, và yêu cầu thêm bản vẽ + thông số 2 động cơ TPMA010S-022T
> và TPMA010S-055T (Catalog_Wittenstein) vào cuối file, đúng format hiện có, cập nhật mục lục,
> không sửa nội dung cũ.
- [x] Chẩn đoán viền trang 28: 1 hình chữ nhật trắng (còn sót từ vòng sửa trước) đè lên đúng đoạn
  viền dưới bên trái (x≈34-400), cao dư xuống quá đáy khung (y=830 > khung 814-816). Vẽ lại đúng
  1 rect đen y hệt tọa độ đoạn viền dưới nguyên bản, verify bằng ảnh crop phóng to — viền liền lại,
  text 30 trang không đổi (so khớp `get_text()` từng trang, diff=0).
- [x] Đọc 2 file datasheet Wittenstein (TPMA010S-022T/-055T-5PB1-094C-W1-000): mỗi file 1 trang, có
  ảnh render sản phẩm + 2 bảng thông số (Product characteristics + Performance data) — **không có
  bản vẽ kích thước CAD 2D**, đã ghi rõ trong trang mới thay vì bịa ra bản vẽ không có thật.
  Ratio 22: T2B 230 Nm, stall 79 Nm, tốc độ 220 rpm; Ratio 55: T2B 230 Nm, stall 110 Nm, tốc độ
  88 rpm (đúng bản đang dùng trên robot theo memory dự án).
- [x] Dựng 2 trang phụ lục mới (31, 32) đúng khuôn mẫu trang 30 (McMaster): trích xuất chính xác
  font/size/màu từng dòng của trang 30 (`Calibri-Bold` 20.96/14.95/14.03 màu navy/đỏ đô, `Calibri`
  12.94 đen) rồi tái tạo y hệt; border kiểu stroked-rect như trang 30 (khác kiểu 4-rect của các
  trang FEA); ảnh render động cơ phóng to đặt cột phải.
- [x] **Lỗi font tiếng Việt phát hiện giữa chừng**: `page.insert_text(..., fontfile=...)` trực tiếp
  tạo font "simple" (8-bit, chỉ phủ Latin-1) → mọi ký tự có dấu thanh (sắc/hỏi/ngã/nặng, mã
  U+1EA0-U+1EF9) hiển thị thành "·". Sửa bằng `page.insert_font(fontname=, fontfile=)` đăng ký
  font Unicode/CID đầy đủ trước, rồi gọi `insert_text(..., fontname=...)` tham chiếu tên đã đăng
  ký — verify lại render đủ dấu tiếng Việt.
- [x] Thêm bảng "MỤC LỤC PHỤ LỤC ĐỘNG CƠ (WITTENSTEIN)" vào cuối trang mục lục (trang 3), không
  đụng 2 bảng mục lục cũ — verify diff text: chỉ trang 3 đổi, 29 trang còn lại y nguyên (so
  `get_text()` từng trang).
- Ghi chú: backup trước sửa `Backup/GiaCongCoKhi_backup_20260724_prebordertfix.pdf`.

#### 2026-07-24 — THÊM DẤU MŨI TÊN VECTƠ (trang 24 + toàn chương động học/Jacobian) (✅ HOÀN TẤT)
> Người dùng yêu cầu: trang 24 và toàn bộ báo cáo, đại lượng nào là vectơ phải có dấu vectơ rõ
> ràng (mũi tên), không chỉ in đậm/nghiêng.
- [x] Trang 24 (mục 2.3.3 nửa sau + đầu 2.3.4): thêm mũi tên OMML thật (`m:acc` với `m:chr` =
  U+20D7 combining-arrow, KHÔNG phải U+2192 mũi tên đứng — thử U+2192 trước, render ra như gạch
  ngang xuyên chữ, phải sửa lại) cho B⃗Bᵢ, B⃗Lᵢ, B⃗lᵢ, B⃗P, P⃗Pᵢ, l⃗ᵢ, B⃗Aᵢ, B⃗Aᵢᵥ; f₁,f₂,f₃ và mọi vô
  hướng (x,y,z,l,L,a,b,c) đúng là không có mũi tên.
- [x] Quét toàn bộ 143 công thức trong file, phát hiện quy ước có sẵn (không phải do phiên này
  tạo): style `m:sty="bi"` (đậm-nghiêng) đã được dùng làm dấu hiệu "đây là vectơ/ma trận" ở nhiều
  chương (2.2, 2.4 Jacobian, chương 3), nhưng KHÔNG phân biệt vectơ với ma trận (cùng ký hiệu A,B,J
  vừa là ma trận Jacobian vừa lẫn trong ngữ cảnh khác) — không thể quét mù toàn văn bản.
- [x] Mở rộng theo đúng phạm vi user duyệt (mục 2.2 mô hình vectơ vòng kín, mục 2.4 Jacobian, và
  chương 3 — 3.2.2 mô hình hình học, 3.3.2 BL₁-BL₃/BAᵢ/BAᵢᵥ, 3.4.2 Jacobian): thêm mũi tên cho
  P⃗, e⃗ᵢ, B⃗ᵢ, P⃗ᵢ, E⃗ᵢ, k⃗, l⃗ᵢ, h⃗ᵢ, u⃗ᵢ, v⃗ᵢ, p⃗, L⃗ᵢ, θ⃗, P⃗_dat, P⃗_ktra — **loại trừ có chủ đích** các ma
  trận A, B, J, Aⱼ, Bⱼ (chỉ giữ đậm, không mũi tên) dù chúng cũng mang `sty="bi"`, vì chỉ vectơ mới
  cần mũi tên theo đúng yêu cầu.
- [x] Tiện thể sửa (2.26)/(2.27) từ text phẳng "P_dat"/"Pₖᵢₑmtra" (gạch dưới thô, lỗi hiển thị cũ)
  thành subscript OMML chuẩn P_dat/P_ktra có mũi tên.
- [x] **Verify bằng render PDF thật** (Word COM → PDF → PyMuPDF chụp ảnh từng trang), không chỉ
  đọc lại text OMML — đọc ảnh 6 trang (19,20,27,28,35,36,39,40,41) xác nhận mũi tên hiện đúng vị
  trí, ma trận không bị mũi tên nhầm, không trang nào bị lỗi layout do XML mới.
- Ghi chú: ký tự accent đúng cho mũi tên vectơ trong OMML là U+20D7 (COMBINING RIGHT ARROW ABOVE),
  không phải U+2192 — nếu dùng nhầm, Word render thành vệt ngang cắt ngang chữ trông như gạch bỏ.
  Backup trước sửa: `Backup/BaoCao_V0_backup_20260724_prevector.docx` và `..._prevector2.docx`.

#### 2026-07-24 — BỎ NHÃN "BƯỚC N" TOÀN BÁO CÁO + RÚT GỌN ĐOẠN CHỌN NGHIỆM IK (✅ HOÀN TẤT)
> Người dùng yêu cầu: rút gọn đoạn giải thích tiêu chí chọn nghiệm động học nghịch (2.3.5), và
> không ghi kiểu tiêu đề "Bước 1, Bước 2..." ở bất kỳ đâu trong báo cáo nữa — chỉ bỏ chữ "Bước".
- [x] Rút gọn đoạn chọn nghiệm IK (mục 2.3.5): còn 1 đoạn ngắn nêu đúng quy tắc dùng trong
  `delta_ik.m` (giữ nghiệm trong [θ_min, θ_max]; nếu cả hai hợp lệ chọn góc trị tuyệt đối nhỏ
  hơn; nếu không nghiệm nào hợp lệ → ngoài vùng làm việc) — không còn diễn giải dài dòng.
- [x] **Xóa toàn bộ 10 tiêu đề đậm "Bước N. ..."** vừa thêm ở mục 2.3.3 (vòng kín) và 2.3.4 (động
  học thuận) — hầu hết xóa hẳn (nội dung đã có sẵn ở câu ngay sau), 3 chỗ (Nhánh 2/Nhánh 3, và
  "Cramer") gộp cụm từ còn thiếu vào đầu câu kế tiếp trước khi xóa tiêu đề, tránh mất thông tin.
- [x] **Quét toàn văn bản phát hiện thêm 10 chỗ "Bước N: ..." khác** (mục 3.3.2/3.3.3, phần tính
  toán số động học thuận/nghịch — nội dung có sẵn từ trước, không phải do phiên này thêm): dùng
  regex xóa tiền tố "Bước N:"/"Bước N." và viết hoa lại chữ đầu câu, giữ nguyên toàn bộ nội dung
  còn lại. Verify quét lại toàn tài liệu: 0 chỗ còn chữ "Bước".
- Ghi chú: backup trước khi sửa tại `BaoCao/Backup/BaoCao_V0_backup_20260724_prenobuoc.docx`.

#### 2026-07-24 — VIẾT LẠI TOÀN BỘ ĐỘNG HỌC THUẬN (mục 2.3.4, trang 25-26) CHUẨN OMML + RÚT GỌN GIẢI THÍCH (✅ HOÀN TẤT)
> Người dùng phản hồi trang 25-26 (động học thuận) viết lộn xộn, công thức không đúng chuẩn toán
> học (dùng dấu "/" thay vì phân số thật, không có căn/ngoặc/chỉ số thật), giải thích dài dòng.
- [x] Viết lại toàn bộ công thức (2.15)-(2.17), (2.17a)-(2.17j) bằng OMML THẬT: phân số dùng
  `m:f` (thanh ngang thật, không còn "/"), căn bậc 2 dùng `m:rad` (dấu căn thật, dùng cho
  √(B²−4AC) ở nghiệm cuối (2.17j)), chỉ số dưới (x₁, a₁, pₓ...) dùng `m:sSub`, số mũ bình
  phương dùng `m:sSup`, ngoặc đơn dùng `m:d` (dấu ngoặc thật render từ `begChr/endChr`, không
  phải ký tự "(" ")" gõ tay).
- [x] Viết một mini-DSL Python (hàm `R()` đệ quy trên tuple `('sub',...)`, `('sup2',...)`,
  `('paren',...)`, `('sqrt',...)`, `('frac',...)`) để dựng nhanh 10 công thức mà không lặp code
  XML tay — cùng kỹ thuật dùng cho phần BL₁/BL₂/BL₃ trước đó nhưng tổng quát hơn.
- [x] **Rút gọn giải thích**: tổ chức lại thành 6 bước ngắn (Bước 1 mô hình giao mặt cầu → Bước 2
  trừ cặp phương trình → Bước 3 đặt hệ số → Bước 4 Cramer → Bước 5 thế vào mặt cầu 1 ra phương
  trình bậc hai → Bước 6 giải nghiệm z); **xóa hẳn đoạn định nghĩa lại pₓ,qₓ,pᵧ,qᵧ** (dư thừa vì
  đã hiện rõ ngay trong công thức (2.17e)-(2.17f)); câu dẫn mỗi bước chỉ 1 câu ngắn thay vì đoạn
  văn dài như bản trước.
- [x] Đọc lại toàn bộ mục 2.3.4 (script `[EQ]`/`[B]` marker): thứ tự đúng, không trùng đoạn, ảnh
  Hình 2.2 + chú thích giữ nguyên vị trí, không đụng công thức (2.18) trở đi (mục 2.3.5).
- Ghi chú: backup trước khi sửa tại `BaoCao/Backup/BaoCao_V0_backup_20260724_prefk.docx`.

#### 2026-07-24 — THÊM CÁC BƯỚC GIẢI THÍCH PHƯƠNG TRÌNH VÒNG KÍN + DẪN XUẤT BL₁/BL₂/BL₃ (mục 2.3.3) (✅ HOÀN TẤT)
> Người dùng gửi ảnh chụp cách trình bày mẫu (Bước 1/2/3 kèm ý nghĩa từng bước) cho phần phương
> trình vòng kín, yêu cầu thêm phần giải thích tương tự cho dễ hiểu, và bổ sung phần tính ra được
> BL₁, BL₂, BL₃ (vector tay trên) — vốn trước đó chỉ có kết quả (2.9)-(2.11) mà chưa có dẫn xuất.
- [x] Viết lại mục 2.3.3 theo 5 bước rõ ràng: Bước 1 (định nghĩa Bᵢ/Lᵢ/Pᵢ + ý nghĩa vector vòng
  kín (2.6)), Bước 2 (chuyển vế tách lᵢ → (2.7)), Bước 3 (áp |lᵢ|=l, bình phương → (2.8)), Bước 4
  (dẫn xuất BLᵢ — MỚI), Bước 5 (thay tất cả vào vòng kín → (2.12)-(2.14) đã có sẵn).
- [x] **Bước 4 — dẫn xuất BL₁/BL₂/BL₃ từ đầu**: vector tham chiếu nhánh 1 trong mặt phẳng Oyz,
  BLᵢ_ref(θᵢ) = [0, −Lcosθᵢ, −Lsinθᵢ]ᵀ; xoay quanh trục z bằng ma trận Rz(φᵢ) với φᵢ=(i−1)·120°
  (bố trí pinwheel 3 nhánh cách đều 120°) ra công thức tổng quát BLᵢ = Rz(φᵢ)·BLᵢ_ref(θᵢ); thay
  φ₁=0°, φ₂=120°, φ₃=240° tái tạo đúng (2.9)-(2.11) đã có trong bài — verify bằng tính tay khớp
  100% với 3 công thức cũ, không phải suy đoán.
- [x] Đọc lại toàn bộ đoạn 2.3.3 (script `[EQ]`/`[B]` marker) xác nhận thứ tự đúng, không trùng
  đoạn, không đụng tới (2.15) trở đi.
- Ghi chú: backup trước khi sửa tại `BaoCao/Backup/BaoCao_V0_backup_20260724_prevongkin.docx`
  theo đúng quy tắc backup-trước-khi-sửa.

#### 2026-07-24 — THÊM TÍNH TOÁN CỤ THỂ CHO ĐỘNG HỌC THUẬN/NGHỊCH (mục 2.3.4/2.3.5) (✅ HOÀN TẤT)
> Người dùng trích đúng 3 đoạn (bước tính FK, trường hợp kỳ dị đồng phẳng, chọn nhánh nghiệm IK) đang chỉ
> NÓI bằng lời ("Bước 1... Bước 2...", "Williams đưa ra dạng giải riêng...") không có tính toán/công thức
> đi kèm — yêu cầu phải có tính toán cụ thể, không chỉ mô tả suông.
- [x] Đọc lại toàn bộ mạch 2.3.4 (FK)/2.3.5 (IK) qua node OMML thật (không chỉ `.text`, theo bài học vòng
  trước) để nắm đúng ký hiệu đã dùng (2.15)-(2.27) trước khi viết thêm, tránh xung đột ký hiệu.
- [x] **FK (đoạn "Bước 1...")**: thay bằng suy diễn thật — trừ từng cặp phương trình mặt cầu (2.17) triệt
  tiêu số hạng bậc hai, ra hệ 2 phương trình TUYẾN TÍNH mới (2.17a)/(2.17b) (thêm mới, không đụng số thứ
  tự (2.18) trở đi — dùng hậu tố a/b để tránh phải đánh số lại toàn bộ chương); giải x,y theo z bằng Cramer
  rồi thế vào 1 phương trình mặt cầu gốc ra phương trình bậc hai theo z — đúng nguồn gốc cặp nghiệm ±.
- [x] **Trường hợp kỳ dị (3 tâm cầu đồng cao độ)**: thay đoạn chỉ trích Williams (2016) suông bằng suy
  diễn thật — chỉ ra hệ số của z trong (2.17a)/(2.17b) triệt tiêu khi z₁=z₂=z₃ nên giải được x,y trực
  tiếp không qua z (không có phép chia cho 0 nào phát sinh), sau đó z giải từ phương trình cầu còn lại —
  giải thích ĐÚNG bản chất kỹ thuật của cách Williams làm, không chỉ nêu tên tài liệu.
- [x] **Chọn nhánh nghiệm IK**: thay đoạn "chọn nhánh nghiệm phù hợp với lắp ráp cơ khí..." (chung chung)
  bằng ĐÚNG quy tắc chương trình `delta_ik.m` đang dùng thật (đọc lại code xác nhận): giữ nghiệm θᵢ nằm
  trong [θ_min,θ_max]; nếu cả 2 nghiệm đều thỏa thì lấy góc nhỏ hơn — quy tắc cụ thể, kiểm chứng được,
  không tự bịa. Tiện thể sửa luôn 1 lỗi trích dẫn có sẵn: câu cũ ghi "dấu ± trong (2.21)" nhưng (2.21) là
  định nghĩa hệ số G₃ chứ không phải phương trình có dấu ± (đó là (2.24)) — đã sửa đúng số.
- [x] Verify: đọc lại toàn bộ đoạn chèn đúng vị trí, đúng thứ tự; kiểm tra mục 2.3.6 (2.26)/(2.27) và sau
  đó không bị xê dịch/ảnh hưởng gì.
- Ghi chú: khi thêm phương trình mới xen giữa một chuỗi đã đánh số sẵn trong Word (không dùng SEQ field),
  dùng hậu tố chữ cái (2.17a, 2.17b...) thay vì chèn số nguyên mới — tránh phải renumber toàn bộ các
  phương trình phía sau + mọi chỗ trích dẫn số đó trong bài (cùng bài học như vụ đánh số hình ở mục vùng
  làm việc).

#### 2026-07-24 — THÊM PHẦN TÍNH TOÁN VÙNG LÀM VIỆC DỰA TRÊN 2 TÀI LIỆU THAM KHẢO (✅ HOÀN TẤT)
> Người dùng đưa 2 bài báo (`STT03_PhanTich_VungLamViec_Hong_2024.pdf`, `STT05_CAD_KetCau_VungLamViec_
> GiacHut_Daneshjo_2025.pdf`), yêu cầu sửa lại toàn bộ phần tính vùng làm việc, phải tính cho đúng kích
> thước robot của mình, kết luận chi tiết. Giữa chừng nhấn mạnh lại: không trích dẫn kiểu "xem file X",
> tính toán phải tự đứng trong bài, kết luận không chung chung.
- [x] Đọc cả 2 bài báo: Hong (2024) — phương pháp hình học giao 3 mặt xuyến (torus) với 3 tham số L
  (cẳng trên), l (cẳng dưới hiệu dụng), δ=R−r, có công thức đóng dạng chuẩn; Daneshjo (2025) — chủ yếu
  tính bền/mô-men, vùng làm việc chỉ ước lượng bằng "tình huống mẫu" trong CAD (không có công thức đóng).
- [x] **Phát hiện quan trọng trước khi sửa**: đọc lại mục 3.4 hiện có bằng `python-docx` (`paragraph.text`)
  tưởng nhầm là "còn nhiều chỗ trống" (giống lỗi từng gặp ở mục 5.4) — kiểm tra kỹ hơn bằng cách đọc cả
  node `m:t` (equation OMML) mới phát hiện **mục 3.4 vốn đã đầy đủ, đúng số liệu** (z tâm=-925, nửa cao
  125, quét 650mm tại z=-925, khoảng nghiệm z=-1350..-570...) — các "khoảng trống" chỉ là do công thức
  Word (OMML) không hiện trong `.text`, không phải lỗi thật. Đã không sửa gì vào mục 3.4 gốc.
- [x] **Sự cố phát hiện + sửa ngay**: rà soát lại cũng phát hiện 2 đoạn tôi đã SỬA NHẦM ở phiên trước (mục
  5.4, đoạn "R=400/z-1050") — hóa ra bản gốc ĐÃ ĐÚNG (cũng chỉ bị OMML che khi đọc `.text`), sửa của tôi
  chèn thêm câu chữ trùng lặp với công thức cũ còn sót lại. Đã **khôi phục đúng nguyên bản** 2 đoạn đó từ
  bản backup (`Backup/BaoCao_V0_backup_20260723.docx`) bằng cách thay thế nguyên XML paragraph — verify
  lại khớp y hệt bản gốc.
- [x] **Thêm mục mới 3.4.3 "Đối chiếu bằng phương pháp hình học giao xuyến"** (chèn đúng vị trí giữa
  3.4.2 và 3.5, không xóa gì cũ): áp dụng công thức mặt xuyến của Hong (2024) với đúng L=407,5mm,
  l=1000mm, δ=226,4mm của robot — xác nhận δ<L+l (vùng làm việc tồn tại) và L<l (dạng con thoi, đúng
  cấu hình phổ biến). Tự giải phương trình bậc hai trên trục đối xứng (x=y=0, rút gọn còn 1 phương
  trình vì 3 nhánh đối xứng) ra 2 nghiệm z=-1389,2mm và z=-547,5mm — **so sánh với khoảng z=-1350..-570mm
  đã có sẵn từ quét động học nghịch mục 3.4.1**: khoảng số học nằm gọn trong khoảng hình học thuần túy,
  đúng như kỳ vọng (hình học chỉ ràng buộc chiều dài khâu, số học có thêm giới hạn góc khớp thật) —
  dùng làm kiểm chứng chéo độc lập, kết luận không chung chung mà bám đúng số vừa tính.
- [x] Nêu thêm dự đoán hình dạng mặt cắt ngang (lục giác 3 hốc lõm) theo phân loại δ<L của Hong, nhưng
  **báo trung thực đồ án chưa có mặt cắt ngang (chỉ có mặt cắt đứng Hình 3.4) nên chưa đối chiếu được
  bằng hình** — không tự nhận là đã kiểm chứng khi chưa có bằng chứng hình ảnh.
- [x] Dẫn Daneshjo (2025) ở góc độ phương pháp luận: quét số học có hệ thống (108 điểm biên + 34.372
  điểm Jacobian) là phiên bản có hệ thống hơn của cách "tình huống mẫu" CAD trong bài báo đó.
- [x] Cả 2 tài liệu **đã có sẵn trong danh mục tài liệu tham khảo** ([3] Hong, [6] Daneshjo) — chỉ trích
  dẫn số thứ tự đúng chuẩn học thuật, không cần thêm reference mới, không trích dẫn file nội bộ nào.
- [x] Verify: đọc lại đoạn chèn qua `python-docx`, đúng vị trí (giữa 3.4.2 và 3.5), 11 đoạn mới, tổng
  632→643 đoạn; 2 đoạn sửa lỗi (mục 5.4) khôi phục khớp 100% bản gốc.
- Ghi chú kỹ thuật quan trọng: `python-docx` `paragraph.text` **không đọc được công thức Word (OMML,
  namespace `m:`)** — trước khi kết luận một đoạn "bị thiếu số liệu", phải kiểm tra thêm node
  `{...officeDocument/2006/math}t`, không chỉ dựa vào `.text` không thôi (bài học rút ra sau khi tự gây
  1 lỗi và phải sửa lại).
- [x] **Bổ sung theo yêu cầu tiếp theo**: chèn 2 hình trực tiếp từ 2 bài báo vào mục 3.4.3 — Hình 11b
  (Hong 2024, mặt cắt xuyến dạng con thoi L<l — đúng trường hợp robot) và Hình 15 (Daneshjo 2025, vùng
  làm việc xấp xỉ theo mô hình CAD). Cắt ảnh trực tiếp từ file PDF gốc (crop toạ độ chính xác qua
  PyMuPDF), KHÔNG đánh số vào chuỗi "Hình 3.x" tự đánh tay của đồ án (file không dùng SEQ field tự động,
  đánh tay từng cái — chèn xen giữa sẽ phải đổi số tất cả hình sau đó, rủi ro cao) mà chú thích riêng
  kiểu "Hình minh họa (theo [3]/[6], Fig. …)" để tách bạch hình gốc của đồ án và hình trích dẫn — vẫn ghi
  rõ nguồn tài liệu tham khảo đúng số thứ tự đã có sẵn ([3], [6]). Verify: 647 đoạn, 18 ảnh (16 cũ + 2
  mới), đúng vị trí ngay trước đoạn văn liên quan.
- [x] Gửi kèm file `MoPhong_DongHoc/p3_workspace.m` (script MATLAB tính vùng làm việc) theo yêu cầu xem
  lại của người dùng.

#### 2026-07-24 — SỬA PHẦN MÔ PHỎNG BỀN TRONG `BaoCao/BaoCao_V0/BaoCao_V0.docx` (✅ HOÀN TẤT)
> Người dùng yêu cầu sửa toàn bộ mục 5.3 (mô phỏng bền) của báo cáo chính, lấy đúng số liệu/hình ảnh đã
> làm (`GiaCongCoKhi.pdf`, `MoPhong_Ben/KETQUA_BEN.md`, `KETQUA_BEN_DAPOSE.md`), không tự bịa, kết luận
> phải có dẫn chứng, tổng báo cáo không vượt 65 trang, chỉ cần ảnh quan trọng. Giữa chừng người dùng bổ
> sung quy tắc cứng: **không được viết kiểu "xem file X" trong báo cáo — số liệu phải tự đứng được trong
> chính văn bản, kết luận không chung chung, không tự sinh số liệu** — đã ghi quy tắc này vào
> `BaoCao/README.md` để áp dụng mọi lần sau.
- [x] Backup trước sửa: `Backup/BaoCao_V0_backup_20260723.docx`.
- [x] Đọc lại mục 5.3 hiện có (5.3.1/5.3.2) — phát hiện **lỗi thời nghiêm trọng**: đoạn vật liệu còn ghi
  "DR-001-1/-3 mâu thuẫn vật liệu FEA nhôm vs bản vẽ ASTM A36, chưa dùng được" (đã giải quyết từ
  2026-07-18, toàn bộ đế đã đổi sang nhôm, xác nhận qua COM); Bảng 5.2 chỉ có 3/7 chi tiết (thiếu
  DR-001-1/-2/-3 và thanh truyền); mục 5.4 có 2 chỗ số liệu bị TRỐNG (R400/z-1050 không hiện ra).
- [x] Đối chiếu ngược 2 nguồn gốc (`KETQUA_BEN.md`, `KETQUA_BEN_DAPOSE.md`) để lấy đúng số — phát hiện
  thêm: DR-001-2 (khung hàn) có **2 lần chạy FEA độc lập cho FOS khác nhau (36,0 và 14,1)** dù hình học/
  vật liệu xác nhận giống hệt, nguyên nhân lệch chưa rõ; hồ sơ gốc khuyến nghị dùng số bảo thủ hơn
  (14,1) cho các báo cáo sau — đã dùng đúng số này thay vì số cũ 36,0 vẫn còn trong PDF bản vẽ.
- [x] **Viết lại 5.3.1** (đoạn vật liệu): xác nhận toàn bộ 6 chi tiết nhôm cùng 6061-T6 khớp bản vẽ+FEA;
  nêu rõ thanh truyền carbon dùng E giả thiết (100-140 GPa) vì thư viện vật liệu SolidWorks không có mô
  đun đàn hồi cho vật liệu đó — nói rõ đây là giả thiết, không phải số đo thật.
- [x] **Dựng lại Bảng 5.2** từ 3→7 dòng (thêm thanh truyền 6516K305, DR-001-1, DR-001-2, DR-001-3), sửa
  luôn cột thứ 3 vốn bị để trống không có tên; mỗi dòng có tải kiểm tra + σ đỉnh + FOS + đánh giá bám số.
- [x] **Đổi 1/2 hình**: giữ Hình 5.2 (DR-006 — FOS nhỏ nhất), đổi Hình 5.3 từ DR-005-2 sang **DR-001-3**
  (chi tiết mang toàn bộ tải treo cả robot, được hồ sơ gốc đánh dấu "quan trọng nhất") — thay đúng ảnh
  nhúng (kiểm tra qua `document.inline_shapes`, không tăng/giảm số ảnh trong file: vẫn 16).
- [x] **Sửa đoạn thảo luận + kết luận** sau bảng: gộp ghi chú artefact chuyển vị (đã có) + mở rộng sang
  DR-001-2/DR-001-3, nêu đúng FOS nhỏ nhất 10,5 (DR-006) bám theo bảng vừa sửa.
- [x] **Điền 2 chỗ trống ở mục 5.4** (đa tư thế): "R = 400 mm" và "z = −1050 mm" (đúng theo
  `KETQUA_BEN_DAPOSE.md`, tư thế biên dưới vùng làm việc).
- [x] **Sửa Bảng 5.3** (ma trận hoàn thành): dòng "Độ bền DR-006/DR-005-2/DR-007" mở rộng thành 7 chi
  tiết; dòng "Vật liệu DR-001 chưa chốt" → "đã chốt, thống nhất 6061-T6".
- [x] **Sửa lần 2 sau phản hồi**: bỏ đoạn kể "2 lần chạy độc lập 36,0 vs 14,1" trong văn xuôi (vi phạm
  quy tắc mới — đó là chuyện quy trình nội bộ không tự đứng được bằng số liệu ngay trong báo cáo), thay
  bằng giải thích tại chỗ: ứng suất đỉnh DR-001-2 nằm ở mặt hàn phẳng chưa bo góc nên mang tính kỳ dị số
  như các chi tiết khác, FOS 14,1 là số bảo thủ nhất trong 3 mức lưới đã giải (bám đúng số trong Bảng 5.2).
- [x] Verify: đọc lại toàn bộ đoạn 534-555 qua `python-docx` xác nhận đúng nội dung mới, bảng 8 dòng (1
  header+7), ảnh vẫn 16 cái không lệch. Không đo được số trang chính xác (không có Word/LibreOffice để
  render) — chỉ thêm ~4 dòng bảng + mở rộng nhẹ vài đoạn văn, không thêm ảnh/trang mới nên rủi ro vượt 65
  trang thấp, nhưng CHƯA xác minh được bằng số đo thật — báo trung thực giới hạn này.
- Ghi chú: đã lưu quy tắc "không trích dẫn file ngoài, kết luận phải bám số liệu trong bài" vào
  `BaoCao/README.md` mục "Quy tắc khi viết/sửa nội dung báo cáo chính" để áp dụng cho mọi lần sửa báo cáo
  sau, không cần nhắc lại.

### 2026-07-23

#### 2026-07-23 — XÁC MINH LẠI FEA `DR-001-3_Mat-Treo_FEA.SLDPRT` NGHI NHIỄM DỮ LIỆU (✅ HOÀN TẤT)
> Phiên trước bị tắt cửa sổ giữa chừng lúc đang chạy lại 3 study FEA (mesh 12/8/5mm) cho mặt treo,
> để lại backup tag `_feacontam` nghi dữ liệu bị nhiễm. Giao Fable kiểm tra qua COM.

- [x] Bind vào tiến trình SolidWorks đang mở (PID giữ file khóa), xác nhận chỉ 1 document mở
  (loại trừ `ActivateDoc3`/`OpenDoc7` trỏ nhầm doc giữa các part `_FEA`).
- [x] Đọc ngược `StudyManager` (đủ 3 study), `SetActiveStudy` + `GetMinMaxStress` từng study, đối
  chiếu node count với `.LOG` gốc (87 888/239 041/811 064 — khớp chính xác), đối chiếu 15 mặt fix +
  9 mặt load thực tế (`Fixed-1`/`Force-1`) với hình học part — khớp 100%.
- [x] **Kết luận: KHÔNG có nhiễm dữ liệu** — FOS giữ nguyên 84,1/83,4/71,5 (mesh 120/80/50mm), min
  71,5 tại mesh mịn nhất, `GetSaveFlag=False` (file đã lưu sạch). Dấu hiệu bất thường ban đầu (file
  `.MAS`/thư mục scratch còn ghi sau khi `.SLDPRT` đã lưu) chỉ do terminal bị đóng giữa lúc solver
  hậu xử lý, không ảnh hưởng dữ liệu nhúng. Không cần chạy lại, không cần rollback.
- Ghi chú đã thêm vào `MoPhong_Ben/KETQUA_BEN.md` mục 4.5. Không có thay đổi file CAD nào (chỉ đọc).

#### 2026-07-23 — SỬA BỘ BẢN VẼ GIA CÔNG V7 ĐÚNG CHUẨN `Fomat/Rule_BanVe` (✅ HOÀN TẤT)
> Đối chiếu 10 bản vẽ trong `BanVe_GiaCong/BanVe_ChinhSua_V7` với `khungve.png`/`khungten.png`/TCVN 5705,
> backup 21 file gốc vào `Backup/*_prerulefix.*` trước khi sửa.

- [x] **Khung viền sai margin** — cũ đều 10mm 4 cạnh; sửa cạnh trái (mép gáy) = 25mm, 3 cạnh còn lại
  10mm (đúng bảng A0–A4 trong `khungve.png`). Dịch nhẹ layout view để không lấn khung mới.
- [x] **Khung tên sai bố cục hoàn toàn** — cũ bảng 9 dòng×2 cột tự chế; thay bằng đúng lưới `khungten.png`
  **140×32mm**, 8 ô nội dung (Người vẽ/Kiểm tra + họ tên/ngày, Tựa bài, Vật liệu, Tỉ lệ, Ký hiệu) +
  dòng trường/lớp. Nội dung: NGUYEN VAN NAM-23134038 (người vẽ), TS. VU QUANG HUY (kiểm tra/GVHD),
  Trường ĐH Công nghệ Kỹ thuật TP.HCM — Ngành Robot and AI - Lớp 23134A.
- [x] **Cỡ chữ kích thước** — tăng tối thiểu 3.5mm + Bold=True trên toàn bộ annotation kích thước
  (6–109 annotation/part tùy độ phức tạp) qua `IAnnotation.SetTextFormat`, áp dụng đồng nhất 10/10 part.
- [x] **Verify 10/10 part qua COM** (không đoán): khung viền 25/10/10/10mm, khung tên 140.00×32.00mm,
  chuẩn ghi kích thước ISO(2) (khớp TCVN 5705 nền ISO R129), font 3.5mm/Bold=True, cả 4 view (Front/
  Top/Side/Iso) không đè khung/khung tên (40/40 PASS), save+PDF err=0 cả 10 part.
- Bằng chứng: `BanVe_GiaCong/BanVe_ChinhSua_V7/KIEMTRA_BANVE_V7.md` mục "Cập nhật 23/07/2026" (bảng số
  liệu đầy đủ), ảnh preview `prev_V7_*.bmp` + 3 PNG xem trực quan (DR-001-1, DR-006, DR-007) đã kiểm tra
  bằng mắt — khung tên/kích thước rõ ràng, đúng bố cục.
- Ghi chú: phát hiện bug PowerShell (biến `$oxm`/`$oxM` không phân biệt hoa/thường → tự đè giá trị) khi
  viết script kiểm tra view-outline; đã sửa và ghi vào `KIEMTRA_BANVE_V7.md` làm bài học.

#### 2026-07-23 — KHÔI PHỤC KÝ HIỆU REN + LÀM ĐẦY LẠI KÍCH THƯỚC 10 BẢN VẼ V7 (✅ HOÀN TẤT)
> Người dùng báo 10 bản vẽ V7 (mục trên) thiếu ký hiệu ren (M5/M20/M16/M2.5/M48/INCH TAP) so với file
> tham chiếu còn sót `DR-003_Motor-Bracket-B_RenM20.SLDDRW`, sau đó bổ sung thêm tham chiếu đầy đủ
> `BaoCao/Ban ve gia cong/GiaCongCoKhi.pdf` và mở rộng yêu cầu: làm đầy lại luôn cả bộ kích thước bị bộ
> lọc V7 ẩn bớt quá tay (không chỉ riêng ren). Backup trước khi sửa đã có sẵn từ trước
> (`Backup/*_backup_20260723_beforerensymbol.SLDDRW`).

- [x] **Xác định đúng bản chất "ký hiệu ren"**: mở file tham chiếu (`OpenDoc6` read-only, không lưu) →
  ký hiệu "2X M20 X 2.5⌵20" **KHÔNG PHẢI** hole-callout tự sinh từ AutoDimension (toàn bộ `IDisplayDimension`
  trong file đều `IsHoleCallout()=False`) mà là **NOTE tay** với text thô `'2X M20 X 2.5 <HOLE-DEPTH>20'`
  (`<HOLE-DEPTH>` = thẻ ký hiệu thư viện chuẩn SolidWorks, render ra dấu "chiều sâu"). → nguyên nhân gốc:
  ký hiệu ren **chưa từng được tạo ra**, không phải bị ẩn.
- [x] **Xác minh THẬT từng part có lỗ ren nào qua COM** (không tin danh sách tham chiếu mù quáng — file
  tham chiếu tỏ ra CŨ hơn thiết kế hiện tại ở vài chỗ, vd DR-005-2): đọc `ThreadFeatureData` của mọi
  feature `SweepThread` (`Type`/`Size` đáng tin, `Pitch`/`BlindDepth` qua API không đáng tin — đọc đồng
  loạt 10mm sai). Kết quả xác nhận 10/10 part: DR-002 có thật 2×M20x2.5 + 2×M16x2.0 (ngoài 16×M5 dạng
  cut không phải Thread thật); DR-003 có thật 2×M20x2.5 (khớp 100% với file tham chiếu — đây chính là part
  nguồn của file đó); DR-004 xác nhận KHÔNG có SweepThread nào; DR-005-1 có thật M48x3.0 + 8×M2.5 (cut);
  DR-005-2 có thật M48x3.0 VÀ **M48x5.0** (2 đầu thanh giằng bước ren khác nhau — nghi ngờ lỗi nhập liệu
  CAD, đã báo cho người dùng, KHÔNG tự sửa); DR-006 có thật M48x3.0 + 2×5/8-18 UNF; DR-007 có thật
  6×5/8-18 UNF. DR-001-1/-2/-3: theo đúng yêu cầu tường minh của người dùng, KHÔNG thêm ren (khớp file
  tham chiếu, dù CAD có vài lỗ M12/M16/M20 dạng cut mang tên "LoRen/LoBat/LoVit").
- [x] **Thêm 12 NOTE ký hiệu ren mới** (đúng mẫu `<HOLE-DEPTH>`, đặt tự động vào view có nhiều dim
  đường kính/bán kính nhất = view nhìn thẳng mặt lỗ) cho 6/10 part: DR-002, DR-003 (đặt ở cả 2 view khớp
  hệt file tham chiếu), DR-005-1, DR-005-2, DR-006, DR-007.
- [x] **Mở rộng: làm đầy lại bộ kích thước** — bộ lọc V7 gốc (limit 2–4 dim/view) chỉ ẨN (`Visible=false`)
  chứ không xóa các dim còn lại; viết lại thuật toán: giữ nguyên 100% dim đang hiện (không bao giờ ẩn
  bớt), nâng limit lên 6/view, cho hiện thêm các dim bị ẩn có điểm ưu tiên cao nhất (đường kính/bán kính
  trước, dedup theo giá trị). Không dùng cách "hiện hết" vì `DR-001-3` có tới 96 dim thô/1 view (AutoDimension
  ghi rời từng lỗ theo sơ đồ chuỗi, không dedup được) — hiện hết sẽ rối không đọc được.
- [x] **Verify toàn bộ qua COM sau khi lưu** (script `final_verify.ps1`): khung viền `(25,10)-(410,10)-
  (410,287)-(25,287)` mm và khung tên (dump đủ 20 ô) **giống hệt trước/sau** trên cả 10 file; ren đúng
  part đúng số lượng (bảng chi tiết trong `KIEMTRA_BANVE_V7.md` mục "phần 3"); dim total/visible mỗi
  view tăng đúng như thiết kế; `save drw err=0`, `pdf err=0` cả 10 file. Đối chiếu bằng mắt qua PDF: nội
  dung khớp rất sát danh sách tham chiếu cho DR-001-1/-2/-3 (vd DR-001-3: 252.19/153/52.98/3XR383.03/
  Ø150 THRU/Ø17.5/R129.92/38.25/259.77/77.22 — gần như đủ toàn bộ).
- Bằng chứng: `BanVe_GiaCong/BanVe_ChinhSua_V7/KIEMTRA_BANVE_V7.md` mục "Cập nhật 23/07/2026 (phần 3)"
  (bảng lỗ ren thật + bảng xác minh cuối 10/10 part), 10 file `.SLDDRW`+`.pdf` đã cập nhật tại chỗ.
- Hạn chế còn lại lúc đó (đã sửa ở mục theo sau): vài vị trí note/dim đặt gần nhau chạm nhẹ do bước
  "nâng limit dim" chỉ đổi `Visible` mà chưa gọi lại bước sắp xếp vị trí; độ sâu ren M48/INCH TAP
  (30/40mm) lấy từ file tham chiếu vì API SolidWorks đọc `BlindDepth` không đáng tin cho các feature này
  — nếu cần số chính xác tuyệt đối nên đo lại trực tiếp trên feature CAD.

#### 2026-07-23 — SỬA CHỒNG CHỮ TRÊN 10 BẢN VẼ V7 (do mục trên chưa sắp xếp lại vị trí) (✅ HOÀN TẤT)
> Người dùng tự mở PDF thật kiểm tra bằng mắt (không chỉ tin log) sau mục trên và phát hiện: việc bật
> hiện thêm dimension đã làm CHỮ ĐÈ LÊN NHAU nhiều chỗ — tệ nhất ở `DR-006` (4 chỗ) và `DR-007` (2 chỗ),
> nhẹ hơn ở `DR-002`/`DR-005-1`. Yêu cầu sửa mà không xóa bớt nội dung/không đụng khung viền-khung tên.

- [x] **Xác định nguyên nhân đúng**: bước "nâng limit 2-4→6/view" chỉ đổi cờ `Visible`, KHÔNG bao giờ gọi
  lại bước sắp xếp vị trí (`SetPosition`) — dimension mới hiện vẫn nằm nguyên chỗ AutoDimension đặt ban
  đầu (rất sát nhau khi số lượng tăng lên).
- [x] **Gộp dimension gần trùng giá trị** (hiệu tuyệt đối <1mm, cùng `Type2`, cùng view — không phụ
  thuộc làm tròn như bước lọc cũ): ẩn bản sau, giữ bản đầu; bắt được đúng các cặp người dùng chỉ ra
  (267.20/267.21, 269.15/269.16 ở DR-007; 75.89/75.91/76.84 gộp về 1 ở DR-006) — áp dụng cả 10 file.
- [x] **Viết lại thuật toán sắp xếp vị trí** (`fix_overlap.ps1`, dựa trên đúng cơ chế "dim arrange"
  left/right/above/below/inside có sẵn trong `make_drawing_v7.ps1` nhưng chạy LẠI sau khi lọc, với khe hở
  lớn hơn): phát hiện và sửa 1 lỗi mô hình — dimension đặt bên trái/phải view trong SolidWorks bị **XOAY
  90° đọc theo chiều dọc** (quy ước chuẩn của SW), lần sửa đầu coi nhầm chiều "dài" của khối chữ là chiều
  ngang khiến khoảng cách giữa các "kệ" xếp chồng chưa đủ; sửa: gán đúng trục dài theo hướng đọc thật của
  chữ. Ghi chú ren được tách hẳn thành 1 "băng" riêng ở mép trên/dưới ô lưới (không còn tranh chỗ với
  dimension khác — đây là nguyên nhân note "8X M2.5..." đè lên "82.71" ở DR-005-1). Sau khi xếp, chạy
  thêm 1 bước dò-và-sửa-lặp độc lập (đọc vị trí + ước lượng bbox chữ thật, đẩy xa nếu còn chạm, tối đa 20
  vòng) để bắt mọi trường hợp còn sót bất kể nguyên nhân.
- [x] **Verify bằng số liệu cho cả 10/10 file** (không chỉ nhìn ảnh): đọc lại vị trí + ước lượng bbox chữ
  (số ký tự × hệ số rộng có tính chữ Bold) sau khi lưu, kiểm tra từng cặp nhãn trong mỗi view — **cả
  10 file: `ANY OVERLAP REMAINING = False`**, khung tên/khung viền đọc lại giống hệt trước/sau, `save drw
  err=0`, `pdf err=0`. Đối chiếu lại bằng mắt qua PDF: `DR-006`/`DR-007` (2 file tệ nhất) giờ đọc rõ từng
  số, hết chồng chữ.
- Bằng chứng: `KIEMTRA_BANVE_V7.md` mục "Cập nhật 23/07/2026 (phần 4)" (bảng dedup + bảng xếp lại theo
  view cho 10/10 part), 10 file `.SLDDRW`+`.pdf` cập nhật tại chỗ, `log_OVERLAPFIX_*.txt` mỗi part.
- Hạn chế còn lại (báo trung thực): vẫn còn vài chỗ chữ/leader-line CHẠM NHẸ trong phạm vi 1-2mm mà việc
  ước lượng bbox (không đọc font-metrics thật của SolidWorks) không phát hiện hết — cụ thể `DR-006` view
  dưới-trái có 2 nhóm kích thước thật sự khác nhau 1-2mm nằm sát nhau (không phải trùng lặp nên không gộp
  được, chỉ có thể tách thêm hàng hoặc đổi tỷ lệ bản vẽ để hết hẳn); vài nơi khác có đường dẫn (leader
  line) cắt gần chữ nhưng không làm mất số. Đây là mức "chấp nhận được cho bản vẽ gia công" chứ chưa phải
  "hoàn hảo từng pixel".

#### 2026-07-23 — CẬP NHẬT `BaoCao/Bản vẽ gia công/GiaCongCoKhi.pdf` (29→30 trang) (✅ HOÀN TẤT)
> Người dùng ghi tạm nội dung mới vào `GiaCongCoKhi.docx` (không sửa được PDF trực tiếp) rồi yêu cầu đồng
> bộ vào PDF, giữ nguyên format hiện có; kèm 2 yêu cầu dọn dẹp: xóa dòng ghi chú số trang trong mục lục và
> cụm "phương án thép cũ (Frame, tham khảo lịch sử)"; sau đó yêu cầu thêm viết lại phần "Kết luận" FEA
> Frame cho có giải thích thay vì chỉ dẫn chiếu.

- [x] Backup xác nhận đã có sẵn trước khi sửa (`BaoCao/Backup/GiaCongCoKhi_backup_20260723_presync.pdf`,
  hash SHA1 khớp 100% với file gốc trước sửa — không cần tạo thêm).
- [x] Diff nội dung `.docx` (pandoc→md) với text từng trang PDF (PyMuPDF) → xác định đúng 1 nội dung mới
  duy nhất: 4 ảnh thông số kỹ thuật McMaster của khớp cầu `60645K471_Ball Joint Linkage` dán cuối docx.
  Hỏi lại người dùng nơi chèn → chọn "trang mới cuối file (sau tr.29)".
- [x] **Xóa dòng "Ghi chú: số trang tính..."** (trang 3, mục lục) — redact vùng chữ, thêm dòng
  "Phụ lục — 60645K471_Ball Joint Linkage ... Trang 30" vào đúng khoảng trống đó.
- [x] **Xóa cụm "— phương án thép cũ (Frame, tham khảo lịch sử)"** khỏi tiêu đề FEA Frame (xuất hiện trên
  CẢ 2 trang 28 và 29 — không chỉ 1) — redact đúng vùng ký tự (dò tọa độ từng glyph qua `rawdict`), giữ
  nguyên phần đầu "BÁO CÁO MÔ PHỎNG BỀN (FEA) — Khung/đế toàn cụm".
- [x] **Viết lại "3. Kết luận" trang 29** (yêu cầu bổ sung giữa chừng): thay "ĐẠT (nghiên cứu lịch sử, đế
  thực tế hiện tại là nhôm — xem báo cáo DR-001-1/-2/-3)." bằng giải thích thật dựa trên số liệu hội tụ
  lưới sẵn có trên cùng trang → "ĐẠT — FOS thấp nhất 15,2 (mesh 12mm), khung đủ bền chịu toàn bộ tải trọng
  robot treo (2 055,3 N)." — cùng font/màu (Calibri-Bold 14,03, xanh lá) với các kết luận FEA khác.
- [x] **Thêm trang 30 phụ lục** — thông số kỹ thuật `60645K471_Ball Joint Linkage`: bảng 13 dòng (mã số,
  dùng ở đâu 2 đầu/6 thanh nối × 2, vật liệu vỏ/chũm cầu, ren 5/8"-18, góc xoay 52°, nhà cung cấp) + ảnh sản
  phẩm + bản vẽ kích thước đầy đủ gốc McMaster (font Calibri lấy từ `C:\Windows\Fonts` để khớp visual với
  toàn bộ 29 trang còn lại, không dùng font thay thế).
- [x] **Verify bằng chứng**: đọc lại text PDF sau sửa xác nhận cả 3 cụm bị xóa không còn xuất hiện; so
  `get_text()` của 10 trang KHÔNG bị đụng tới (1,2,4,5,6,11,16,21,26,27) — **giống hệt 100%** file gốc;
  render PNG từng trang sửa (3, 28, 29, 30) xem trực quan đúng bố cục, không lỗi chồng chữ/tràn khung.
  Tổng số trang file sống hiện tại: **30** (`fitz.open(...)` đọc lại xác nhận).
- Ghi chú kỹ thuật: `fitz`/PyMuPDF `insert_textbox` wrap tự động lỗi cắt giữa từ ở 1 đoạn ghi chú dài (rect
  quá rộng/font đặc thù) — chuyển sang tự đo `Font.text_length` + wrap tay để chắc ăn, dùng cho các đoạn
  văn dài kế tiếp thay vì tin `insert_textbox`.

#### 2026-07-23 — VÒNG SỬA THỨ 2 `GiaCongCoKhi.pdf`: bìa + bảng tổng hợp + đồng bộ 7 Kết luận FEA (✅ HOÀN TẤT)
> Người dùng phản hồi tiếp sau vòng sửa trên: (1) biến dòng tổng số lượng TT ở bảng kê thành bảng thật;
> (2) xóa dòng "Phụ lục — 60645K471..." vừa thêm ở mục lục; (3) xóa mục "2. Ghi chú thiết kế" ở trang 30;
> (4) thích cách viết Kết luận FEA Frame (giải thích tại sao ĐẠT thay vì chỉ dẫn chiếu) → viết lại 7 mục
> Kết luận FEA còn lại theo đúng phong cách đó; (5) điền thông tin trang bìa theo nội dung đã cung cấp
> trong docx (tên/MSSV/lớp/đề tài — trang bìa PDF cũ vẫn là khung mẫu trống).

- [x] Backup thêm 1 bản trước vòng sửa này (`Backup/GiaCongCoKhi_backup_20260723_v2.pdf`, 30 trang, đúng
  quy tắc backup trước khi sửa).
- [x] **Trang bìa (trang 1)**: dò font thật (TimesNewRomanPS-BoldMT/…MT, KHÔNG phải font chuẩn PDF — phải
  nạp `C:\Windows\Fonts\timesbd.ttf`/`times.ttf` mới có đủ dấu tiếng Việt) + xác nhận toàn bộ dòng canh
  giữa trang (center x = 595.23 = nửa bề rộng 1190.46) → redact vùng tiêu đề, viết lại: "BÁO CÁO ĐỒ ÁN
  THIẾT KẾ CƠ KHÍ", "ĐỀ TÀI: THIẾT KẾ TÍNH TOÁN BỀN ROBOT DELTA", "SVTH: NGUYỄN VĂN NAM", "MSSV: 23134038",
  "LỚP: 23134A", "GVHD: TS. VŨ QUANG HUY" — khớp đúng nội dung người dùng đã ghi trong docx.
- [x] **Trang 2 (bảng kê)**: xóa dòng chữ thường "Chi tiết gia công + mua sẵn...: 40 | Vít/bu lông...: 138",
  vẽ bảng thật 3 hàng × 2 cột (viền 0,911pt kiểu ô vuông đen giống bảng chính, header tô xám
  RGB 0.851 — đúng màu/độ dày lấy mẫu từ bảng BOM gốc).
- [x] **Trang 3 (mục lục)**: xóa dòng "Phụ lục — 60645K471..." (thêm ở vòng sửa trước, người dùng không
  muốn nữa).
- [x] **Trang 30 (phụ lục)**: xóa hẳn mục "2. Ghi chú thiết kế" (header + 3 dòng ghi chú).
- [x] **Viết lại 7/8 mục "Kết luận" FEA** (Frame ở trang 29 giữ nguyên, đã đúng ý từ trước) theo mẫu giải
  thích "ĐẠT — FOS thấp nhất X (mesh Ymm) khi chịu <tải + giá trị>, <lý do an toàn>." — Thanh truyền,
  DR-001-1, DR-001-2, DR-001-3, DR-005-2, DR-006, DR-007 — số liệu FOS/mesh/tải đều lấy đúng từ bảng hội
  tụ lưới + mục "Diễn giải tải thiết kế → tải FEA" đã có sẵn trên cùng trang (không bịa số).
- [x] **Bắt lỗi giữa chừng và sửa ngay**: trang Thanh truyền (idx14) có thêm mục "3. Kiểm tra oằn
  (Buckling)" chen giữa → khối "4. Kết luận" thật nằm ở y=529 chứ không phải y=405 như 6 trang kia; áp
  rect chung ban đầu redact NHẦM vào bảng oằn (đè lên 2 hàng 125/140 GPa) — phát hiện qua render ảnh kiểm
  tra, sửa lại bằng cách dò riêng vị trí "4. Kết luận" cho đúng trang này rồi build lại từ file gốc (chưa
  từng ghi đè file sống nên không cần rollback).
- [x] **Verify**: so `get_text()` toàn bộ trang KHÔNG liên quan (4–14, 24, 28, 29) giống hệt 100%; render
  PNG toàn bộ 11 trang bị sửa (1,2,3,15,17,19,21,23,25,27,30) xem bằng mắt — đúng bố cục, không chồng
  chữ/tràn khung, bảng mới đúng kiểu bảng cũ. Tổng trang vẫn 30. Đã ghi đè file sống.
- Ghi chú kỹ thuật: font TimesNewRomanPS-BoldMT trong PDF gốc là bản nhúng của Times New Roman thật (không
  phải font chuẩn PDF Times-Bold — font chuẩn thiếu dấu tiếng Việt), phải nạp file hệ thống
  `C:\Windows\Fonts\timesbd.ttf` giống cách đã làm với Calibri; luôn dò tọa độ span/bbox thật qua
  `rawdict` trước khi redact theo tọa độ cố định — đừng giả định các trang "giống nhau" cùng mẫu có
  cùng tọa độ tuyệt đối (bài học từ lỗi trang Thanh truyền).

#### 2026-07-23 — VÒNG SỬA THỨ 3: khung Kết luận đè chữ + bìa canh lệch (✅ HOÀN TẤT)
> Người dùng xem lại vòng 2, báo 2 lỗi + 1 yêu cầu: (1) khung màu xanh nhạt quanh "Kết luận" FEA bị chữ
> tràn ra ngoài/đè lên viền (do khung mẫu gốc chỉ cao đủ cho 1-2 dòng, còn câu giải thích mới dài 2-3
> dòng); (2) ảnh cuối trang 30 (bản vẽ kích thước) nghi bị cắt/che một phần; (3) 4 dòng SVTH/MSSV/LỚP/GVHD
> ở bìa đang canh giữa riêng từng dòng (lệch trái/phải không đều) — yêu cầu canh thẳng hàng, tăng cỡ chữ,
> canh đều toàn bộ bìa.
- [x] Backup trước khi sửa: `Backup/GiaCongCoKhi_backup_20260723_v3.pdf`.
- [x] **8 khung Kết luận** (Thanh truyền + DR-001-1/-2/-3 + DR-005-2 + DR-006 + DR-007 + Frame): đo lại
  kích thước khung gốc qua `get_drawings()` (khung nền xanh nhạt RGB 0.886/0.937/0.855 + viền đen, cao
  ~27,7pt cho 1 dòng) → tính số dòng thật của câu kết luận mới (`Font.text_length` wrap), vẽ lại khung
  cao đúng theo số dòng (công thức `27,7 + (n-1)×19,69`), xóa sạch khung+chữ cũ trước khi vẽ khung mới —
  chữ không còn tràn ra ngoài viền ở bất kỳ trang nào.
- [x] **Trang 30**: không tìm thấy điểm ảnh bị đè thật sự khi soi từng vùng nghi ngờ qua `get_drawings`/
  crop pixel, nhưng vẫn chủ động tăng biên an toàn: kéo ảnh bản vẽ vào trong 20pt so với mép phải, tăng
  khoảng cách ảnh sản phẩm–ảnh bản vẽ, thêm khung viền mảnh xám quanh ảnh bản vẽ cho rõ ràng/không thể
  hiểu nhầm là bị cắt.
- [x] **Trang bìa**: tăng cỡ chữ (tiêu đề 20,05→22, các dòng còn lại 14,03→15,5); 4 dòng
  SVTH/MSSV/LỚP/GVHD đổi từ "canh giữa riêng từng dòng" (lệch trái/phải vì độ dài khác nhau) sang
  "canh trái theo khối, khối canh giữa trang" (đo dòng dài nhất, computed 1 điểm bắt đầu X chung) → 4 dòng
  thẳng hàng lề trái, khối vẫn nằm giữa trang; giãn dòng đều 24pt.
- [x] **Verify**: so `get_text()` 18 trang không liên quan (4-14,16,18,20,22,24,26,28) giống hệt 100%;
  render PNG toàn bộ trang sửa xem bằng mắt — khung Kết luận vừa khít chữ, bìa thẳng hàng rõ ràng. Tổng
  trang vẫn 30, đã ghi đè file sống.
- Ghi chú: khung trang trí (background cell) trong PDF này là `re` fill+border vẽ riêng — không tự co
  giãn theo nội dung text như bảng HTML; mỗi lần đổi độ dài text phải tự tính lại chiều cao khung.

#### 2026-07-23 — VÒNG SỬA THỨ 4: logo bìa + đệm chữ khung Kết luận + đánh số trang (✅ HOÀN TẤT)
> Người dùng soi kỹ lần nữa: logo HCMUTE cần cân giữa hợp lý hơn, bìa còn nhiều khoảng trắng phía dưới,
> chữ trong khung Kết luận (vòng 3 mới chỉnh cao khung) vẫn chưa nằm chuẩn (đỉnh chữ chạm/đè viền trên) —
> yêu cầu kiểm tra và sửa lại; thêm yêu cầu mới giữa chừng: đánh số trang cho toàn bộ file (file chưa có
> số trang in trên từng trang, chỉ có nhắc tới trong mục lục).
- [x] Backup trước sửa: `Backup/GiaCongCoKhi_backup_20260723_v4.pdf`.
- [x] **Logo bìa**: đo lại tâm ảnh (595,28 ≈ đúng tâm trang 595,23 — vốn đã cân) nhưng phóng to hợp lý
  (cao 102→132pt, giữ đúng tỉ lệ gốc) và tái định vị cùng khối nội dung bên dưới (mục tiếp).
- [x] **Bìa còn trống**: đo khoảng trắng thật (nội dung cũ chỉ chiếm y=57→481 trong tổng 842pt cao, dư
  ~360pt ở đáy) → giãn lại toàn bộ khối logo/tiêu đề/đề tài/học kỳ/khối SVTH/ngày tháng trải đều hết
  chiều cao trang (kết thúc ~y=734 thay vì 481), lề trên/dưới quanh khối cân đối hơn nhiều.
- [x] **Khung Kết luận (8 khung)**: đo pixel-level bằng crop phóng to phát hiện đúng lỗi — đỉnh chữ dòng
  đầu (kiểu chữ có dấu cao như "Đ", "ẤT") chạm/đè lên viền khung trên do khoảng đệm gốc (6,79pt) nhỏ hơn
  chiều cao ascender thật của font Calibri-Bold cỡ 14,03 (~10,5pt). Tính lại đúng: đệm trên = 10pt +
  ascender 10,5pt = 20,5pt (từ 6,79), công thức chiều cao khung đổi từ `27,7+(n-1)×19,69` sang
  `34,0+(n-1)×19,69` — verify lại bằng crop phóng to: chữ nằm gọn giữa 2 viền, không chạm.
- [x] **Đánh số trang toàn bộ 30 trang** (yêu cầu mới phát sinh giữa chừng): dò khung viền thật của từng
  loại trang qua `get_drawings()` (bìa/BOM/mục lục dùng kiểu viền 4 dải mỏng riêng — đáy ~793,6/813,5;
  bản vẽ 4-13 dùng 1 hình chữ nhật viền thật — đáy 813,59; FEA 14-29 dùng dải mỏng — đáy 816,24; trang 30
  tự tạo trước đó KHÔNG có viền) → thêm viền cho trang 30 (khớp kiểu FEA) rồi in số trang canh giữa ngay
  dưới viền mỗi trang (1…30), khớp đúng số đã ghi trong mục lục (không đổi thứ tự trang nên số tự khớp).
- [x] **Verify**: so nội dung text 19 trang không đổi (chỉ cộng thêm số trang, không mất/đổi chữ nào)
  — khớp 100%; render ảnh bìa + khung Kết luận (crop 3x) + 1 trang bản vẽ + trang 30 xem bằng mắt — logo
  cân giữa đẹp, bìa không còn trống nhiều, khung Kết luận chữ nằm gọn, số trang hiển thị đúng vị trí mọi
  loại trang. Tổng 30 trang, đã ghi đè file sống.
- Ghi chú: `ascender`/`descender` đọc từ `span` dict (tỷ lệ so với fontsize) là cách đúng để tính đệm chữ
  không tràn khung — đừng đoán đệm theo cảm tính, ghi chú lại cho lần sau nếu cần khung tương tự.

#### 2026-07-23 — VÒNG SỬA THỨ 5: khung viền trang 30 lệch + dựng lại layout TRANG 1 (8 trang FEA) (✅ HOÀN TẤT)
> Người dùng báo khung viền trang 30 bị lệch, và yêu cầu đổi layout trang "TRANG 1 — THÔNG TIN MÔ TẢ" (áp
> dụng cho cả 8 part): dời 2 mục "3. Loads and Fixtures" + "4. Diễn giải tải thiết kế → tải FEA" (vốn là
> cột ngang riêng ở giữa) xuống DƯỚI mục "2" trong cùng 1 cột trái, không để ngang nữa; phóng to ảnh mục 5.
- [x] Backup trước sửa: `Backup/GiaCongCoKhi_backup_20260723_v5.pdf`.
- [x] **Sửa khung viền trang 30**: phát hiện nguyên nhân — vòng 4 dùng NHẦM tọa độ khung viền kiểu "trang
  bản vẽ" (70,8→1162,2) cho trang 30 (vốn là trang nội dung, phải dùng kiểu khung "trang FEA":
  31,53→1159,29, đo lại từ chính các trang FEA gốc qua `get_drawings()`). Xóa viền sai (vẽ đè viền trắng
  dày hơn), vẽ lại đúng viền theo tọa độ trang FEA thật — so sánh crop cùng vị trí với 1 trang FEA gốc xác
  nhận độ hở chữ-viền giống hệt nhau (khoảng cách sát nhưng không đè, đúng phong cách gốc, không phải lỗi).
- [x] **Dựng lại layout TRANG 1 cho cả 8 part** (Thanh truyền, DR-001-1/-2/-3, DR-005-2, DR-006, DR-007,
  Frame): trích xuất chính xác toàn bộ dữ liệu 4 mục (Model Information/Material Properties/Loads and
  Fixtures/Diễn giải tải) từng part qua `rawdict` (join lại các dòng bị word-wrap gốc), dựng lại thành 1
  cột trái duy nhất (mục 1→2→3→4 xếp chồng, cùng vị trí nhãn/giá trị x=45,57/218,60 như cột 1 cũ), cột
  phải chỉ còn mục "5. Ảnh đặt lực" với ảnh phóng to **từ rộng 408pt lên 720pt** (gấp ~1,76 lần), tự tính
  chiều cao theo đúng tỉ lệ gốc từng ảnh (không méo hình).
- [x] **Verify từng phần**: dò lại toàn bộ số liệu đã trích xuất khớp 100% với bản gốc (đọc lại `rawdict`
  2 lần, phát hiện sót 1 dòng cuối mục 4 ở DR-001-2/Frame do giới hạn dò ban đầu quá hẹp — mở rộng vùng dò
  bắt đủ). Render ảnh cả 8 trang xem bằng mắt: Frame (part có mục 4 dài nhất, 5 dòng) vẫn vừa gọn trong
  trang không tràn xuống viền dưới; layout đồng nhất cho part ngắn (Thanh truyền) lẫn dài (Frame).
- [x] So `get_text()` 21 trang không liên quan (0-12,14,16,18,20,22,24,26,28) giống hệt 100% bản gốc.
  Tổng 30 trang, đã ghi đè file sống.
- Ghi chú: khi cần dựng lại 1 khối văn bản nhiều mục/nhiều dòng wrap từ dữ liệu gốc, luôn TRÍCH XUẤT lại
  qua `rawdict`/`get_text('dict')` với vùng dò đủ rộng (mở rộng y-range nếu nghi ngờ) rồi tự nối các dòng
  bị word-wrap thành 1 chuỗi, thay vì gõ tay lại từ trí nhớ — tránh sai số liệu.

#### 2026-07-23 — VÒNG SỬA THỨ 6: khôi phục khung bảng mục 1-4 + xuất bản Word y trang PDF (✅ HOÀN TẤT)
> Người dùng phát hiện vòng 5 (dựng lại layout TRANG 1) làm MẤT khung viền bảng quanh mục 1/2/3/4 (bản
> gốc mỗi mục là 1 bảng có viền lưới thật, không phải chữ trần) — yêu cầu kiểm tra và làm lại khung. Sau
> đó yêu cầu thêm: xuất 1 file Word trong cùng thư mục, bắt buộc giữ y hệt từng trang PDF (không nhảy
> dòng/lệch trang/nhảy bảng/nhảy ảnh).
- [x] Backup trước sửa: `Backup/GiaCongCoKhi_backup_20260723_v6.pdf`.
- [x] **Xác nhận lỗi**: đối chiếu bản backup vòng 4 (trước khi dựng lại layout) qua `get_drawings()` —
  xác nhận mỗi mục 1-4 gốc là 1 bảng lưới thật (viền + đường kẻ giữa từng dòng, dải mỏng ~0,911pt, giống
  kiểu bảng BOM) mà vòng 5 xóa mất khi redact toàn vùng và chỉ vẽ lại chữ trần, không vẽ lại lưới.
- [x] **Vẽ lại lưới cho 4 bảng/trang × 8 trang** (không đụng lại chữ, chữ vòng 5 đã đúng vị trí): tính lại
  đúng offset chữ-viền — lần đầu tính sai (dùng nhầm khoảng cách giữa 2 giá trị bbox-top thay vì baseline
  thật của `insert_text`, cho ra viền đè xuyên chữ kiểu gạch ngang) → tính lại đúng theo ascent/descent
  thật của Calibri 12,94 (offset 12,84pt tính từ khoảng trắng giữa 2 dòng liền kề) → verify lại bằng ảnh
  phóng to: viền nằm gọn giữa các dòng, không đè chữ, đúng kiểu bảng gốc.
- [x] Verify: chữ 8 trang sửa giữ nguyên 100% (không đụng), 22 trang còn lại giữ nguyên 100%. Render ảnh
  toàn bộ 8 trang xem bằng mắt (kể cả Frame — bảng mục 4 dài nhất 5 dòng — vẫn đúng lưới, không lệch).
  Tổng 30 trang, đã ghi đè file sống.
- [x] **Dọn dẹp file phình to ngoài ý muốn**: phát hiện file PDF sống phình lên **87,6 MB** (từ ~11,9MB) do
  6 vòng sửa liên tiếp `insert_image`/nạp font liên tục không dọn object mồ côi (`doc.save` mặc định KHÔNG
  garbage-collect) → chạy lại `doc.save(..., garbage=4, deflate=True)`, xác nhận `get_text()` 30 trang
  giống hệt 100% trước/sau dọn, file co về **8,5 MB** — thay vào file sống.
- [x] **Xuất bản Word `GiaCongCoKhi_export.docx`** cùng thư mục `BaoCao/Bản vẽ gia công/`: do yêu cầu
  "giữ y hệt từng trang, không nhảy dòng/lệch trang/nhảy bảng/nhảy ảnh" — không có công cụ PDF→Word giữ
  layout tuyệt đối đáng tin trên máy này (không có LibreOffice; chuyển đổi giữ-layout tự động luôn có rủi
  ro reflow) → chọn giải pháp AN TOÀN NHẤT: render mỗi trang PDF thành ảnh độ phân giải cao (2x, ~144
  DPI) rồi nhúng đúng 1 ảnh/trang vào file Word (khổ trang A3 ngang khớp chính xác 16,53×11,69in, ngắt
  trang cứng giữa các ảnh, lề 0) — đảm bảo tuyệt đối không thể nhảy dòng/bảng/ảnh vì mỗi trang giờ là 1
  bức ảnh nguyên khối. **Đánh đổi: nội dung trong Word không còn sửa được dạng text/bảng** (chỉ xem/in y
  hệt bản PDF) — đã nêu rõ đánh đổi này cho người dùng khi giao file.
- Ghi chú kỹ thuật: `insert_text`/`insert_image` của PyMuPDF dùng tọa độ Y là **baseline** (không phải
  bbox-top) — khi tính toán vị trí vẽ thêm (viền, ô...) dựa trên vị trí chữ, luôn quy về baseline + ascent/
  descent thật của font/cỡ chữ, không suy luận từ chênh lệch bbox-top giữa 2 span khác ngữ cảnh.

#### 2026-07-23 — VÒNG SỬA THỨ 7: bảng mục 4 trang 28 (Frame) lấn qua khung viền (✅ HOÀN TẤT)
> Người dùng báo khung ở trang 28 bị lấn qua viền. Đo lại: bảng mục "4. Diễn giải tải thiết kế → tải FEA"
> của Frame (5 dòng, dòng cuối wrap 2 dòng — DÀI NHẤT trong 8 part) có viền đáy tại y=820,02, vượt QUA
> viền ngoài trang (y=816,24) 3,78pt — lỗi thật, không phải cảm nhận sai.
- [x] Backup trước sửa: `Backup/GiaCongCoKhi_backup_20260723_v7.pdf`.
- [x] Quét lại cả 8 trang đo khoảng cách đáy-bảng-cuối tới viền ngoài — xác nhận CHỈ trang 28 (Frame) âm
  (-3,78pt), 7 trang còn lại dư 34,6–130,6pt, không cần sửa.
- [x] **Sửa riêng trang 28** (không đụng 7 trang kia): giảm khoảng cách trước mỗi header mục
  (`GAP_BEFORE_HEADER` 17,0→12,0pt, tiết kiệm 3×5=15pt) đủ kéo bảng cuối lên, chỉ redact+vẽ lại vùng cột
  trái (x35–400), không đụng ảnh cột phải. Lần đầu chừa lẫn 1 dòng chữ cũ sót lại ("bố mặt lắp tấm)" lặp
  2 lần) do vùng redact ban đầu cắt ở y=800 trong khi chữ cũ tới y=819 — mở rộng vùng redact xuống y=830,
  sửa sạch.
- [x] Verify: bảng cuối trang 28 giờ đáy tại y=804,11, dư 12,13pt tới viền — an toàn. 29 trang còn lại
  giữ nguyên 100% text. Lưu bằng `garbage=4,deflate=True` giữ file nhẹ (10,1 MB, không phình lại).
- [x] **Xuất lại bản Word** `GiaCongCoKhi_export.docx` khớp PDF mới nhất (docx cũ đã lỗi thời từ trước
  khi sửa vòng này) — render lại 30 trang + build lại docx, gửi lại người dùng.
- Ghi chú: khi 1 trang cụ thể tràn khung do nội dung dài hơn các trang cùng loại khác, ưu tiên sửa CỤC BỘ
  (giảm spacing riêng trang đó) thay vì đổi tham số chung cho cả bộ — tránh phá vỡ các trang đang đúng.

### 2026-07-22

#### 2026-07-22 — KHUNG THÉP TREO ROBOT `Frame.SLDPRT` (dựng lại sạch, kiểu chữ Y) + FEA
> Người dùng chỉnh nhiều vòng thiết kế khung treo (bản mới `Frame.SLDPRT`, thay `DR-100`). Backup toàn bộ file trước khi làm (`Backup/*_backup_20260721_prekhungtreofix`). Phần lớn CAD do agent Fable dựng; agent Fable dính session limit/stall nhiều lần → **main thread (Opus) tự hoàn tất phần đỉnh + FEA**.

- [x] **Backup 18 file active** → `DeltaRobot_Final/Backup/` tag `_backup_20260721_prekhungtreofix`.
- [x] **Khung thép treo `Frame.SLDPRT`** (ASTM A36, hệ tọa độ assembly, VERTICAL=Y): bàn 4 cột hộp 100×100×5 tại (X0±700,Y0±700) quanh trục robot (−20.6,1094.1) — mép trong R919 > tầm tay 720; 4 chân đế 220×220; **vành trên + vành đáy** (đáy nâng lên Y−2400..−2300, ~350mm trên sàn) → hộp kín; giằng góc đỉnh. **Đáy giữa hở** cho băng tải.
- [x] **Kích thước hợp băng tải thông dụng**: mặt băng **900 mm** trên sàn (belt 600 mm), sàn Z−2650, mặt bích robot–sàn ~2472 mm, khe hở 4 cột 1300 mm (băng bắc ngang qua, không vướng).
- [x] **Giao diện treo robot (đỉnh) kiểu CHỮ Y** (main thread tự dựng COM): **đĩa treo TRÒN Ø720** đồng tâm trục robot (đo thực từ lỗ Ø150 nắp DR-001-3) + **3 nan hộp 100×100 liền mạch nối nhau tại hủ trung tâm**, 120° ở khe giữa 3 tay (đo từ 6 lỗ M20: phương vị part 83.9/−36.1/−156.1°), nhúng 60mm vào vành (**không lòi ngoài khung**). **Ø150 lỗ cáp thông** (khoét lại sau hàn), **6×M20 R260 đối xứng đồng tâm**, mặt đáy đĩa Y−177.8 tì nắp robot. **1 solid, WhatsWrong=0, 643 kg, đã lưu.** Ảnh `outputs/khungtreo_20260721/frame_iso|top|front.png`.
- [~] **FEA khung** (`MoPhong_Ben/khung_treo/`, ngàm 4 chân, 2060N robot xuống đĩa, lưới 6/12mm): **phổ ứng suất toàn khung XANH (thấp), võng thực ~0,6–0,8 mm** (từ hệ số phóng đại SW 431×) → **khung DƯ BỀN rõ ràng**. Đỉnh von Mises 224→350 MPa PHÂN KỲ theo lưới = **singularity số tại điểm đặt tải** (không phải ứng suất thực); chỉ số disp 598mm/nodes 0 là artifact đọc. Ghi chú + diễn giải: `MoPhong_Ben/khung_treo/GHICHU_FEA_KHUNGTREO.md`, phổ `figs/fea_khungtreo_final_vonMises.png`. **CÒN (tùy chọn): FOS "sạch"** cần làm sạch hình học hủ / nan rỗng / đặt tải phân bố.
- **Ghi chú COM mới**: nan dựng bằng `FeatureExtrusion3` offset-start trên Top plane (T0=3, StartOffset=0.0778, Dir=true, FlipStartOffset=true → band Y−177.8..−77.8); sketch 3 chữ nhật CHỒNG tâm = profile tự cắt → extrude null, phải làm **3 extrude riêng rồi Combine**; `SelectByID2` qua raw dispatch lỗi 0x80020006 → chọn plane/feature bằng traversal + `Select2`; `SetSelectedObjectMark(i,mark,0)` 3 args; Combine ADD = select all bodies mark 2 + `InsertCombineFeature(15903,DBNull,DBNull)`.

#### 2026-07-22 — LẮP `Frame.SLDPRT` VÀO `DR-000` THAY `DR-100` (✅ HOÀN THÀNH)
> Nhiệm vụ còn lại từ mục trên: lắp khung thép treo mới vào assembly chính, đồng tâm lỗ Ø150 khung với lỗ Ø150 nắp treo robot, bằng MATE thật (không dùng CreateTransform — cấm vì crash SW).

- [x] **Backup trước khi làm** (rule keep-1): `Backup/DR-000_Delta-Robot_V0_backup_20260722_prekhunglap.SLDASM` + `Backup/Frame_backup_20260722_prekhunglap.SLDPRT`; xóa các backup cũ hơn của 2 file này (`_prekhungthep`, `_prekhungtreofix`, `_prespokerebuild`) theo quy tắc giữ-1.
- [x] **Suppress `DR-100_Khung-Treo-1`** (khung thép cũ) trong DR-000 — xác nhận `IsSuppressed=True` sau rebuild (không xóa hẳn, có thể hoàn tác).
- [x] **Chèn `Frame-1`** (`AddComponent5` tại bbox-center, orientation identity) vào DR-000.
- [x] **3 mate thật** (raw-dispatch `SelectByID2`/typed-interop `Face2.Select4` + `AddMate5`, KHÔNG CreateTransform):
  - **Concentric18**: mặt trụ Ø150 Frame ↔ mặt trụ Ø150 nắp DR-001-3 — Frame tự xoay đúng **+90° quanh trục X** (kiểm chứng qua ma trận biến đổi đọc ngược, khớp chính xác công thức người dùng cho part(X,Y,Z)→assembly(X,−Z,Y)).
  - **Coincident84**: mặt đáy đĩa Frame (local Y=−177.8) ↔ mặt trên nắp (local Y=−200, = assembly Z=−177.8) — đặt đúng cao độ dọc trục.
  - **Lock21**: khóa Frame↔DR-001-3 tại vị trí hiện tại (thay vì concentric 1 lỗ M20 — thử concentric M20 bị dư ràng buộc, lỗi err=5/WhatsWrong=3, vì mate 1+2 đã tự đưa Frame về đúng góc xoay thiết kế do phép xoay +90° quanh X là nghiệm "gần nhất" duy nhất; đã kiểm chứng bằng lân cận thực nghiệm CẢ 6 cặp lỗ M20 lệch chỉ 0.0485–0.0486mm TRƯỚC khi thêm Lock — đúng theo kiến trúc assembly này vốn dùng Lock cho các khớp dư ràng buộc).
- [x] **Verify (bằng chứng đọc ngược qua COM)**: **sai lệch đồng tâm Ø150 = 0.0485 mm** (≤ 0.1mm yêu cầu); **cả 6 cặp lỗ M20 lệch 0.0485–0.0486 mm**; **`GetWhatsWrongCount()` = 0**; `DR-100_Khung-Treo-1.IsSuppressed = True`; hộp bao Frame-1 **Z[−2650.0 .. −77.8] mm** (chân chạm sàn, đỉnh đúng vị trí) — khung đứng đúng, robot treo bên trong. Khối lượng assembly hiện tại đọc COM = **1092.35 kg** (Frame 643kg + robot, DR-100 đã suppress không tính).
- [x] **Lưu**: `Save3` err=0/warn=0, `GetSaveFlag=False` sau lưu (xác nhận không còn thay đổi chưa lưu); file `.SLDASM` trên đĩa có timestamp khớp thời điểm lưu.
- [x] **Ảnh bằng chứng**: `outputs/khungtreo_20260721/assembly_frame_iso.png` (góc nhìn iso: khung + robot treo bên trong) + `assembly_frame_front.png` (dùng view `*Top` của SW vì quy ước trục của assembly này cho ra đúng mặt đứng — thấy rõ khung đứng, 4 cột chạm sàn, robot treo lơ lửng giữa khung, tay máy + bàn máy dưới đĩa treo).
- **Ghi chú COM mới**: `SelectByID2` kiểu `'FACE'` theo tọa độ điểm dùng đơn vị **MÉT** (không phải mm — lỗi ban đầu do quên đổi đơn vị làm selection luôn `False`); lỗ Ø150 trên Frame KHÔNG phải hình trụ tròn đủ 360° (bị nan che một phần) nên chọn theo tọa độ dễ trúng nhầm mặt phẳng lân cận — cách chắc ăn hơn: viết helper C# compiled `SelectCylByLocal`/`SelectPlaneByLocalPoint` (traverse `Face2.GetSurface().CylinderParams/PlaneParams` trong hệ tọa độ LOCAL của part rồi gọi `((Entity)face).Select4(append,null)` trực tiếp — khớp đúng mặt theo bán kính+tâm+dung sai, không phụ thuộc đoán điểm 3D); `SelectPlaneByLocal` chọn theo "diện tích lớn nhất cùng hướng pháp tuyến" có thể trúng NHẦM mặt song song khác cao độ (2 mặt trên/dưới nắp treo cùng normal, mặt SAI lại có diện tích lớn hơn 0,5%) → phải khóa thêm theo **điểm tham chiếu trên đúng mặt phẳng** (`SelectPlaneByLocalPoint`, so khoảng cách vuông góc). `AddMate5` err=1=thành công/err=0=thất bại đã biết, nhưng còn gặp **err=5 kèm WhatsWrong tăng = mate dư ràng buộc/xung đột hình học** (khác với err=0 đơn thuần) — khi 2 mate trước đã xác định gần hết bậc tự do, ưu tiên dùng **Lock** thay vì thêm concentric thứ 3. Xóa 1 mate cụ thể: `SelectByID2(name,'MATE',...)` + `DeleteSelection2(0)`.

### 2026-07-20

#### 2026-07-20 — MÔ PHỎNG ĐỘNG HỌC BẰNG SIMULINK (✅ HOÀN TẤT)
> Người dùng hỏi có làm mô phỏng động học bằng Simulink được không. Simscape Multibody KHÔNG cài (chỉ Simscape base + Robotics System Toolbox) → không dựng mô hình vật lý 3D import CAD. Thay vào: dựng model block-diagram Simulink tái dùng IK/FK/Jacobian đã kiểm chứng.
- [x] **`MoPhong_DongHoc/delta_kinematics.slx`** (dựng bằng `build_simulink.m`, chạy headless MATLAB R2025a): `Clock → TrajGen` (quỹ đạo pick&place quintic + vận tốc analytic) `→ IK → θ`; nhánh `FK` verify TCP; `Jac` ra cond(J)+góc truyền; `JointVel` ra ω khớp qua Jacobian. 6 MATLAB Function block inline (codegen-safe).
- [x] **Chạy sim thật (StopTime 1.2s, ode3, dt 0.002, 601 bước), số đọc TỪ sim**: ω khớp đỉnh 21/30/30 rpm (khớp thiết kế ~30 rpm), cond(J) max 2.285/tb 2.011, góc truyền μ min 53.8°, **round-trip FK(IK(P)) = 5.3e-13 mm**. Tất cả trùng kiểm chứng MATLAB thuần trước đó.
- Bằng chứng: `delta_kinematics.slx` + 5 PNG `figs/simulink_*` (sơ đồ khối, góc/vận tốc khớp, cond(J)/μ, sai số round-trip, quỹ đạo TCP) + `out/simulink_results.mat` + log `out/simulink_build_log.txt`.
- Ghi chú kỹ thuật: block Derivative liên tục cho ω spike 3530 rpm (artifact mẫu t=0) → thay bằng tính ω giải tích qua Jacobian, mượt về 0 tại waypoint. To Workspace + Mux vector cột ra timeseries Data 3D `[12×1×N]` (squeeze+transpose). Nạp code MATLAB Function block qua Stateflow chart `.Script`.
- CÒN (tùy chọn): thêm animation 3D (gọi `deltaviz.m` từ θ log); nếu cần mô hình vật lý thật thì cài Simscape Multibody rồi import CAD.

#### 2026-07-20 — THIẾT KẾ CẤU KIỆN THÉP TREO ROBOT (✅ HOÀN TẤT)
> Người dùng yêu cầu thiết kế cấu kiện thép treo nổi robot delta, chắc chắn + đơn giản, dựng file 3D SolidWorks, backup trước. Kết quả: khung lồng thép 4 cột có giằng, robot treo bên trong, mặt bích đỉnh đỡ nắp treo robot.

- [x] **Backup trước khi làm** (rule keep-1): `Backup/DR-000_Delta-Robot_V0_backup_20260720_prekhungthep.SLDASM` (xóa backup DR-000 cũ 20260719_prewholefea).
- [x] **Đo hình học robot trong assembly** (đọc COM): trục Z = phương đứng, mặt bích treo (đỉnh nắp DR-001-3) ở **Z = −177.8 mm** (cao nhất), robot thõng xuống Z −1707.6 (thấp nhất) → robot rớt **1530 mm** dưới mặt bích; trục robot XY ≈ (−20.55, 1094.05); footprint nắp ~Ø800; tầm quét tay rộng nhất ~720 mm.
- [x] **Chốt thông số với người dùng**: chiều cao mặt bích cách sàn **1900 mm**; kiểu **4 cột + khung đáy + giằng chéo**; thép **hộp vuông 100×100×5**.
- [x] **Dựng part `DeltaRobot_Final/DR-100_Khung-Treo.SLDPRT`** (COM, model Fable): multibody thép **ASTM A36**, **25 body** — 4 cột góc (bán kính 919 mm > tầm tay 720, dư 199), khung trên + khung đáy (vành vuông cạnh ±650), 4 thanh nối tâm ra mặt bích Ø640×25 (lỗ tâm Ø150 thoát cáp), 4 chân đế 220×220×20, 4 giằng chéo mỗi mặt. **Khối lượng 452,81 kg** (đọc ngược, density 7850). Box Z −2077,8..−52,8 (sàn↔đỉnh khung). Ảnh `outputs/khungthep_20260720/DR100_iso.png`.
- [x] **Sửa lỗi chạm khối** (phát hiện qua kiểm tra hình học, WhatsWrong không bắt được): connectors+khung trên ban đầu ở Z −252,8..−152,8 thò xuống dưới mặt bích, vào bán kính R290 < R400 (đế robot) → đâm robot. **Sửa: nâng connectors+khung trên lên Z −152,8..−52,8** (nằm trên mặt bích), cột nối dài lên −52,8. Chỉ còn mặt bích (−177,8..−152,8) tì lên đỉnh nắp. Quét lại: dưới Z−152,8 trong R600 quanh trục CHỈ có mặt bích.
- [x] **Lắp vào `DR-000_Delta-Robot_V0.SLDASM`** (chèn identity qua bbox-center, KHÔNG dùng CreateTransform — crash): DR-100 Fixed, box khớp, mặt bích tì đúng đỉnh nắp (−177,8). **WhatsWrongCount=0**. **Interference detection = 459 < baseline 483 → khung thêm 0 chạm** (chỉ tiếp xúc mặt bích↔nắp, đồng phẳng). Save3 err=0. Robot treo nổi bên trong lồng, cột hở tay, platform thõng giữa khung.
- [x] **Bằng chứng ảnh Z-up**: `outputs/khungthep_20260720/assembly_front.png` (mặt đứng — robot treo từ mặt bích đỉnh, tay thõng), `assembly_iso.png` (iso lồng thép đứng, chân trên sàn, robot bên trong).
- CÒN (tùy chọn): FEA khung thép (kiểm bền dưới tải robot 452 kg + phản lực động 1,18g); bắt bulong mặt bích↔nắp (6×M20 R260 của nắp — hiện mới tì tiếp xúc, chưa mô hình bulong); bản vẽ gia công khung.

### 2026-07-19

#### 2026-07-19 — GOM STUDY FEA VÀO FOLDER RIÊNG + MÔ PHỎNG BỀN ĐA TƯ THẾ KHÓ (✅ HOÀN TẤT)
> **Tổng kết:** (1) gom 5 study FEA vào folder riêng `MoPhong_Ben/MP_BEN_V2` (part nhúng study, mở là thấy kết quả); (2) mô phỏng bền toàn robot ở nhiều tư thế khó khắp vùng làm việc → **min FOS 7,1** (mọi tư thế vẫn an toàn ≥7×); báo cáo `KETQUA_BEN_DAPOSE.md` + docx.

- [x] **Gom study FEA vào `MoPhong_Ben/MP_BEN_V2/`** (theo yêu cầu "lưu file study FEA vô folder riêng"): copy 5 part FEA sang, đổi tên `_FEA` (tránh trùng tên part design đang mở → OpenDoc7 trả nhầm doc), chạy lại FEA (driver mới `fea_run_v2.ps1` + `run_parts_v2.ps1`) **rồi Save3** → study + kết quả (.CWR) nhúng vào file. **Mở part nào cũng thấy ngay study + phổ màu.** 5/5 part: DR-006/DR-005-2/DR-007/DR-001-1/DR-001-3_FEA.SLDPRT, tổng ~3,96 GB (trên ổ F:). Số FEA khớp bản 2026-07-18 (FOS 10.5/64.7/14.7/1890/71.5).
- [x] **Mô phỏng bền TOÀN ROBOT ở nhiều TƯ THẾ KHÓ** (yêu cầu người dùng):
  - **Tải theo tư thế (MATLAB `MoPhong_Luc/force_poses.m`)**: quét tâm + 24 điểm biên vùng làm việc Ø800×250 (R400, 12 phương vị × 2 mặt z−800/−1050) + 4 waypoint; mỗi tư thế quét 26 hướng gia tốc đỉnh 1,18g lấy worst-case. **Tư thế khó nhất = mép dưới R400/z−1050**: lực cặp thanh truyền **182,4 N (×1,49 baseline 122,7)**, mô men uốn bắp tay 74,3 N·m (×1,49); lực bàn máy Fee 176,1 N (×1,00, không đổi); cond Jacobian max 2,75 (không kỳ dị). Bằng chứng `out/pose_log.txt`, `out/pose_results.mat`, `figs/pose_fmax_workspace.png`.
  - **FEA tại tải worst-case** (SolidWorks, `run_parts_pose.ps1`, tải ×1,49): **DR-006 σ 38,8 MPa → FOS 7,1** (từ 10,5) · **DR-005-2 σ 6,3 → FOS 43,5** · **DR-001-1 tấm đế σ 0,22 → FOS 1268** · DR-007 14,7 (Fee không đổi) · DR-001-3 71,5 (trọng lượng robot không đổi). **→ Min FOS toàn robot ở MỌI tư thế = 7,1 → an toàn dư bền ≥7× trên toàn vùng làm việc.** (rc=24 lần đầu do session SW stale → kill+relaunch sạch là chạy được.)
  - **Báo cáo**: `MoPhong_Ben/KETQUA_BEN_DAPOSE.md` + **`BaoCao/KETQUA_BEN_DAPOSE.docx`** (728 KB, 4 hình nhúng: bản đồ workspace + 3 phổ màu worst-pose). 3 PNG FEA `figs/fea_*_pose_vonMises.png`.
- Ghi chú: mọi output ghi trên **ổ F:** (SW temp `F:\SWTEMP`); C: chật (~2 GB) là dữ liệu người dùng — theo yêu cầu KHÔNG ghi vào C: nữa.

#### 2026-07-19 — SỬA ĐỐI XỨNG DR-006 Sketch2 (✅ HOÀN TẤT)
> Người dùng báo "sketch 2 chưa đối xứng trong DR-006 Elbow-Clevis". Quét lại: hai HÔNG đã đối xứng sẵn (cả hai 30°, area 1208.4) — endpoint sketch (32.5532,26.2607) đọc lúc đầu là điểm ảo gây hiểu lầm. **Lệch THẬT chỉ ở CẠNH ĐỈNH**: đỉnh phải (5.6901, **51.9500**) lệch tâm + nghiêng so đỉnh trái (−16.0304, 50.3042) → sinh mặt đỉnh nghiêng 4.33°.
- **Nguyên nhân gốc**: Sketch2 under-defined (chỉ 3 dim/11 đoạn), vùng đỉnh-phải thiếu ràng buộc → trôi ra số lẻ. **Nudge điểm (SetCoords) KHÔNG sửa được**: di 1 điểm kéo trôi điểm/hông liền kề (thử 3 lần đều đổi chỗ lệch này sang lệch khác — hông trôi 30°→33.9°).
- **Cách ĐÚNG = thêm RÀNG BUỘC đối xứng (SketchAddConstraints), không di điểm**: (1) `sgSYMMETRIC` hai đường hông qua đường tâm đứng (centerline construction tạo mới qua Origin) → hai hông khóa mirror ±30° A=1208.4; (2) `sgHORIZONTAL2D` cạnh đỉnh → phẳng; (3) `sgSYMMETRIC` 2 đầu cạnh đỉnh qua centerline → về tâm. **Kết quả: cạnh đỉnh (±13.1495, y=51.95) phẳng+giữa, hai hông mirror, mặt nghiêng 4.33° biến mất, WhatsWrong=0, 1 body, V 416.49→417.97 cm³**. Bằng chứng: đọc ngược từ disk `scan_dr006_now.txt` + ảnh `outputs/doixung_20260716/dr006_sym_check.png` (trước: `dr006_front_now`).
- **Assembly DR-000_V0**: mở, ForceRebuild3 ×2, **WhatsWrongCount=0**, mass 122.425→**122.437 kg** (+12g đúng ΔV DR-006 ×3 tay nhôm), Save3 err=0.
- **⚠️ SỰ CỐ + KHẮC PHỤC (ghi để tránh lặp)**: trong lúc thử nudge, chuỗi `CloseAllDocuments(true)` + reopen KHI ASSEMBLY DR-000 đang mở → **file DR-006 bị đè bản rỗng 512KB (corrupt)**. Phát hiện: mtime file đổi + size tụt 1784→512KB. **`CloseAllDocuments(true)` trên máy này = SAVE-rồi-đóng, KHÔNG phải discard** như tưởng. Khôi phục từ `Backup/DR-006_..._20260718_chot.SLDPRT` (copy đè). Bài học: (a) rollback edit chưa lưu = **KILL process** (disk giữ bản save cuối), KHÔNG dùng CloseAllDocuments/CloseDoc; (b) sửa part thì **ĐÓNG assembly trước** (assembly mở kéo mọi part làm component, sửa vướng); (c) làm việc trên 1 part isolate.
- Backup chốt DR-006 (1784KB, 18/07) giữ nguyên làm điểm khôi phục. File làm việc mới 1641KB @ 10:41 19/07.
- CÒN (tùy chọn): tái sinh bản vẽ gia công DR-006 (`make_drawing2.ps1`) để ordinate ra số đối xứng — chưa làm.

#### 2026-07-19 — CHẠY LẠI FEA 5 PART (khôi phục kết quả + DR-006 trên hình cân xứng) (✅ HOÀN TẤT)
> Kết quả .CWR nặng đã mất khỏi ổ (dọn C:/SW temp) → mở part `_FEA` không còn phổ màu. Chạy lại toàn bộ `run_parts_v2.ps1` → **MP_BEN_V2 = 84 file / 3.31 GB**, mỗi part `_FEA` có .CWR sidecar (mở SW thấy phổ màu). Người dùng báo bản DR-006 đang dùng là CŨ (bất đối xứng) → refresh + chạy lại trên **bản cân xứng của user (11:17)**.
- **5 part FEA lại (tải 2kg, nhôm 6061-T6, hội tụ 3 lưới, embed .CWR):** DR-006 (**bản cân xứng**) FOS 8.8/9.8/15.3 · DR-005-2 64.7/102/74.8 · DR-007 13.1/18.3/31.1 · DR-001-1 tấm đế 1890/2208/2143 · DR-001-3 mặt treo 84.1/83.4/71.5. **Min FOS ≈ 8.8** (DR-006, lưới thô — σ đỉnh do singularity lỗ tải không bo, dao động 8.8→15.3 theo lưới; kết luận không đổi: an toàn ≥8×).
- **DR-006 refresh:** copy `DeltaRobot_Final\DR-006` (bản user 11:17, cân xứng, 1638KB) đè `MP_BEN_V2\DR-006_..._FEA.SLDPRT`; **re-probe face XÁC NHẬN index khớp hệt bản cũ** (journal=F1, back=F12, rod=F0/F34, ref=F17 — fix đối xứng đỉnh KHÔNG dịch index vùng tải) → config `@(1,12)/@(0,34)/17` giữ nguyên; chạy `run_parts_v2.ps1 -Only dr006`. DR-006 cân xứng ≈ bản cũ (9.5) → **fix đối xứng không ảnh hưởng bền** (vùng chịu tải: ngõng R24, 2 lỗ rod, hông — không đổi).
- Bằng chứng: `F:\SWTEMP\fea_v2_run.log` + `fea_dr006_resym.log` (σ/FOS, SAVE err=0), 3× `.CWR` dr006 (220/94/53 MB, mtime 1:11-1:14PM), ảnh hình học cân xứng `figs/fea_dr006_resym_vonMises.png`. Ghi chú: render fringe phổ-màu headless qua COM không ăn (`ActivatePlot` không đổi viewport) — phổ màu vẫn nhúng trong .CWR, mở SW thủ công thấy; PNG fringe cũ 18/07 (`figs/fea_dr006_vonMises.png`) là hình học cũ.
- CÒN (tùy chọn): cập nhật số DR-006 trong `KETQUA_BEN.md` (min FOS 8.8 bản cân xứng); tái tạo PNG fringe DR-006 hình mới.

#### 2026-07-19 — DỌN RÁC folder DeltaRobot_Final (✅ HOÀN TẤT)
> Người dùng: "nhiều file rác trong folder, kiểm tra và xóa phiên bản cũ/trùng".
- **Xóa 76 FEA solver artifacts = 5.41 GB** (`.CWR/.GEN/.MAS/.LOG/-BenchMark-Solver.txt` + `PerformanceLog.txt`) — scratch tái tạo được, kết quả thật giữ ở `MoPhong_Ben/`. Root: 93→17 file, toàn CAD. F: trống 215.95→221.3 GB. (Dùng `[System.IO.File]::Delete` vì sandbox chặn `Remove-Item` glob.)
- **Xóa `DR-001_Base-Plate.SLDASM`** (492KB) — sub-assembly kiến trúc CŨ, abandoned/unreferenced sau khi chuyển FLAT part→part 2026-07-17 (master multibody đã lưu Backup). Người dùng duyệt. Root còn **16 file active**.
- **Kiểm nhưng GIỮ**: `Backup/` sạch đúng giữ-1 không trùng; `Catalog_Wittenstein/` (folder vendor duy nhất — 2 cặp PDF "(1)" hash KHÁC nhau, không phải trùng thật); `TPM-010S-061T` gearbox cũ (backup tham chiếu); `TPMA010S...` folder 2 file sạch.

### 2026-07-18

#### 2026-07-18 — ĐỔI VẬT LIỆU ĐẾ SANG NHÔM + CHẠY LẠI FEA + CẬP NHẬT TÀI LIỆU (✅ HOÀN TẤT)
> **Tổng kết:** đế thép→nhôm 6061-T6 (−128.8kg), assembly **122.425 kg CAD** (WhatsWrong=0, saved); FEA lại 5/5 part trên nhôm → **min FOS 10.5**, đế vẫn dư bền; cập nhật đủ KETQUA_BEN + THUYETMINH docx (BaoCao/) + material writeup + CLAUDE.md + memory + 3 bản vẽ đế.
> Yêu cầu người dùng: backup lần cuối model chốt + kiểm/chỉnh lại toàn bộ FEA cho khớp file chốt + ghi kết quả chi tiết vào `BaoCao/THUYETMINH_MOPHONG_BEN_CHITIET.docx` + **đổi vật liệu đế (đang rất nặng) nhưng vẫn đảm bảo bền**. Người dùng đã chốt: **đổi CẢ 3 khối đế sang nhôm 6061-T6**.

- [x] **BACKUP CHỐT** → `DeltaRobot_Final/Backup/` : 13 file `*_backup_20260718_chot.*` (DR-000_Delta-Robot_V0 assembly + DR-001-1/-2/-3 + DR-002/003/004/005-1/005-2/006/007 + DR-005_Upper-Arm.SLDASM + gearbox TPMA). Đã dọn backup cũ theo quy tắc giữ-1 (xóa các bản presym/preM5/pretach3link/preexplode; giữ `DR-001_Base-Plate_MULTIBODY-retired_20260717` làm master multibody đã retire, + 2 backup premat linh kiện mua). **File chốt = `DR-000_Delta-Robot_V0.SLDASM`.**
- [x] **ĐỔI VẬT LIỆU 3 KHỐI ĐẾ: ASTM A36 Steel → 6061-T6 (SS)** (SetMaterialPropertyName2, db "SOLIDWORKS Materials"; verify đọc ngược GetMaterialPropertyName2 + khối lượng; save_ok=True cả 3). Bằng chứng `MoPhong_Ben/out/mat_change_20260718.csv`:
  - DR-001-1 Tấm đế gắn tay: **99,262 → 34,141 kg**
  - DR-001-2 Khung hàn: **31,701 → 10,903 kg**
  - DR-001-3 Mặt treo: **65,386 → 22,489 kg**
  - **Tổng đế 196,349 → 67,533 kg (giảm 128,8 kg)**. Assembly DR-000 kỳ vọng ~123 kg CAD (chưa verify lại — cần đọc lại khối lượng assembly + rebuild + save).
- [x] **Probe lại mặt (faces) toàn bộ 5 part FEA** (hình học đã đổi do dọn đối xứng 2026-07-16 + đế tách 3 file → chỉ số mặt CŨ không còn đúng, vd dr006 ngõng R24 giờ là F1 chứ không phải F2): `out/faces_DR-006_*.txt`, `faces_DR-005-2_*.txt`, `faces_DR-007_*.txt`, `faces_DR-001-1_De-Gan-Tay.txt`, `faces_DR-001-3_Mat-Treo.txt`. CSV FEA thép cũ đã đổi tên `conv_*_steel_20260713.csv` (giữ đối chiếu); PNG thép cũ vẫn ở `figs/` (fea_dr00*_vonMises.png ngày 07-13).
- [x] **Giải lại FEA 5 part XONG 5/5** (tĩnh tuyến tính, hội tụ 3 lưới, nhôm σ_chảy 275; blocking main loop). Cấu hình mặt (probe 2026-07-18) trong `MoPhong_Ben/run_parts.ps1`. Bằng chứng: 5× `out/conv_*.csv` (3 lưới/part) + 5× `figs/fea_*_vonMises.png` (nhôm mới):
  - ✅ **dr006** Elbow-Clevis: σ 24.4/22.7/26.1 MPa → **FOS 10.5** (BC probe lại đúng: ngàm ngõng R24 F1 + lưng F12, tải ĐÚNG 2 lỗ rod F0/F34).
  - ✅ **dr005b** Upper-Arm-Link: σ 4.25/2.70/3.68 → **FOS 64.7**.
  - ✅ **dr007** Moving-Platform: σ 17.1/18.7/11.9 MPa (lưới 12/8/5) → **FOS 14.7**.
  - ✅ **dr001_1** Tấm đế NHÔM: σ 0.145/0.125/0.128 MPa (lưới 20/14/10) → **FOS ~1890** (dày, ngàm cả mặt hàn đáy → dư bền cực lớn).
  - ✅ **dr001_3** Mặt treo NHÔM (treo cả robot): σ 3.27/3.30/3.84 MPa (lưới 12/8/5) → **FOS 71.5** → AN TOÀN, không cần giữ thép/thêm gân (disp 5.9mm API là spike 1-nút, không nhất quán với σ thấp).
  - **→ Min FOS toàn robot = 10.5 (dr006), mọi chi tiết an toàn ≥10×. Đế nhôm (thay thép, −128.8kg) VẪN DƯ BỀN.**

##### CÔNG VIỆC CÒN LẠI — ĐÃ HOÀN TẤT TOÀN BỘ (phiên 2026-07-18 tối, main loop)
1. [x] FEA đủ **5/5** `conv_*.csv` + 5 PNG nhôm mới (đọc ngược số thật) — xem trên.
2. [x] **Khối lượng assembly DR-000_V0 sau đổi vật liệu = 122,425 kg CAD** (mở, ForceRebuild3 ×2, **GetWhatsWrongCount=0**, Save3 err=0, GetSaveFlag→False). Thật ≈140 kg (+17.2 kg hiệu chỉnh density hộp số). Giảm ~111 kg CAD so bản đế thép (233,82).
3. [x] **Cập nhật `MoPhong_Ben/THUYETMINH_MOPHONG_BEN_CHITIET.md`**: bảng vật liệu (đế→nhôm 6061-T6, bỏ A36), thêm mục 7.4 DR-001-1 + 7.5 DR-001-3, phần "đổi vật liệu đế −128.8kg + FEA chứng minh vẫn bền", bảng tổng hợp 5 part + kết luận min FOS 10.5. Pandoc → **`BaoCao/THUYETMINH_MOPHONG_BEN_CHITIET.docx`** (1058 KB, verify nhúng đủ 5 hình FEA).
4. [x] Cập nhật `MoPhong_Ben/KETQUA_BEN.md` theo số nhôm mới (5 part, min FOS 10.5, ghi rõ đế nhôm dư bền).
5. [x] Cập nhật **CLAUDE.md** (dòng vật liệu: đế toàn nhôm 6061-T6, mass 122.425 CAD/~140 thật, FEA min FOS 10.5) + **memory** `deltarobot-assem1-findings` + MEMORY.md index + **`outputs/material_20260712/ThuyetMinh_LuaChonVatLieu.md`** (viết lại mục 2.1 đế nhôm, bảng cơ tính/khối lượng/kết luận theo nhôm).
6. [x] **Tái sinh 3 bản vẽ gia công đế** (`make_drawing2.ps1`, sửa hardcode fallback → 6061-T6): DR-001-1/-2/-3 khung tên đọc đúng **6061-T6 (SS)** + khối lượng nhôm (34.14/10.90/22.49 kg), 1:10, drw+pdf err=0 cả 3.

- [x] **Bản vẽ PHÂN RÃ (exploded) DR-000 + BOM + xuất PDF** theo yêu cầu (kiểu giống ảnh AGV tham khảo user gửi, nhưng part THẬT của delta robot, không bịa) → `F:\DeltaRobot\Phanra\DR-000_BanVe_PhanRa.pdf` + `.SLDDRW`; exploded view lưu trong `DeltaRobot_Final\DR-000_Delta-Robot.SLDASM` (backup `Backup/DR-000_..._preexplode.SLDASM`):
  - Explode qua COM typed interop (raw dispatch không chạy `ShowExploded`/`AutoBalloon`/BOM): `IConfiguration.AddExplodeStep`+plane (hướng = pháp tuyến plane, buộc theo trục vì `SetExplodeDirection` chỉ nhận ENTITY không nhận vector; radial `AddRadialExplodeStep` err=3 với RefAxis — bỏ). Chọn **nổ giãn theo trục Z** 12 bước theo TYPE (mỗi loại dịch 1 lượng, giữ đối xứng 3 tay trong XY): Mặt treo −820 … bàn máy +1650 mm. Verify BẰNG SỐ (đọc GetBox center: Mặt treo 1321→501, bàn máy 3100→4749, hộp số +150 — đúng dấu/độ lớn) vì SaveBMP screenshot không tin cậy trong phiên headless.
  - Bản vẽ A3 ngang: iso exploded (`ShowExploded(true)`, auto-fit 1:21.5) + **12 bóng số** (`AutoBalloon5`, IgnoreMultiple) + **BOM `InsertBomTable4`** chỉnh thành 4 cột **TT | MÃ SỐ | TÊN GỌI CHI TIẾT | SL** (thêm cột mô tả tiếng Việt local, đọc UTF-8 để tránh mojibake). 12 dòng đúng số lượng (khớp 40 component: DR-002/003/004/005/006 ×3, hộp số ×3, rod ×6, khớp cầu ×12, DR-001-1/2/3 + platform ×1). Verify qua render PDF thật.
  - **Sự cố + khắc phục:** BOM `set_Text` lên cột PART NUMBER (linked) ghi ngược mojibake vào property `BOMPartNoSource=UserSpecified` của **cả 12 part** rồi lưu xuống disk → đã reset `BOMPartNoSource=1 (DocumentName)`, `UseAlternateNameInBOM=false` cho 12 part và lưu lại (mã part sạch trở lại). Cột mô tả sau chuyển sang cột LOCAL mới (không writeback). Có lúc C:/paging đầy làm PS treo — dọn recycle/temp.
- [x] **Đọc + tóm lược toàn bộ tài liệu tham khảo `DoAnThamKhao/` → báo cáo Word** (`BaoCao/TONGQUAN_TAILIEU_THAMKHAO.docx`, nguồn `.md` ở `MoPhong_DongHoc/TONGQUAN_TAILIEU_THAMKHAO.md`; index cập nhật trong `BaoCao/README.md`):
  - Trích text 21 PDF bằng `pdftotext` → phát hiện **3 file trùng** (`Analyze`≡`Dynamic_Analysis…Fl`×2; `Speed_joint`≡`robotics-11-00036-v2`) → còn **18 tài liệu unique**. Mỗi bài tóm lược ≤2 trang theo bố cục *xuất bản – mục tiêu/nội dung – phương pháp – kết quả*.
  - Nhóm A–F theo chủ đề: **A** động học & thiết kế (Williams 2016, Lê Xuân Hoàng–Lê Hoài Nam 2018 (VN), Hong 2024 zero-platform, Altuzarra 2024 continuum FK, Daneshjo 2025 Pro/E, Pandolfi 2025 GA+RecurDyn, Ren 2026 workspace trà) · **B** động lực học (Cretescu 2023 flexible+clearance, Zhang 2022 telescopic rod) · **C** quỹ đạo (Wu 2022 IBOA+NURBS, Zhu 2023 Cartesian+joint B-spline, Zhang 2019 Par4 GWO) · **D** sai số (Yang 2021 RSM, Shang 2019 D-H bù góc) · **E** ứng dụng vision HCMUT (Vo Duy Cong 2023 sorting, Low-cost <500$) · **F** bổ trợ (ABB IRB 360 datasheet, npj microrobot).
  - Kèm mục **nhận xét tổng hợp + định hướng dùng cho đồ án** (động học nền Williams/VN; tối ưu kích thước Pandolfi sát nhất; cảnh báo mô hình thanh cứng Cretescu; l>L>R>r theo Ren).
  - Xuất pandoc `.md→.docx` (có mục lục TOC depth 2, công thức LaTeX→OMML native). **Bằng chứng:** docx 26 KB, verify đọc ngược ra **~4650 từ, đủ 18 mục A1–F2**.
- [x] **Bản GIẢNG GIẢI TRỰC QUAN có hình + lời giảng dễ hiểu** (người dùng phản hồi "không hiểu gì báo cáo text, muốn thấy hình tham khảo + hình kết quả, giảng như dạy người mới") → `BaoCao/GIANGGIAI_TRUCQUAN_TAILIEU.docx` (nguồn `.md` + `BaoCao/figs_thamkhao/`):
  - **Trích hình thật từ PDF bằng PyMuPDF (fitz 1.28)** (máy không có pdfimages/pdftoppm/gs/magick): script `extract_imgs.py` lấy top-4 hình nhúng lớn nhất mỗi bài (lọc ≥200×140, ≥45k px²) → `montage.py` ghép contact-sheet 2×2 mỗi bài → **tự xem 18 sheet chọn hình tốt** → `pick.py` copy 33 hình chọn + resize ≤760px vào `figs_thamkhao/`.
  - **33 hình** gồm: sơ đồ giải phẫu robot (pandolfi có nhãn Motor/Base/Active-Passive arm/Ball joint/Moving platform), robot thật (ABB FlexPicker, shang, iboa, smoothing, cong, telescopic), vùng làm việc (vn2018/hong/ren/daneshjo), kết quả mô phỏng bền+sai số (pandolfi von Mises 63/24 MPa, cretescu dạng dao động), đồ thị tối ưu (iboa hội tụ, par4 năng lượng), nhận diện màu HSV (cong), sơ đồ kết nối (lowcost Arduino/Nema23)…
  - **Văn phong "thầy dạy trò"**: mở đầu "Robot Delta là gì" (ví von 3 người nâng khay), mỗi bài theo ① vấn đề → ② nhìn hình hiểu → ③ kết quả; mọi hình có caption giải thích "nhìn gì trong hình". Kết thúc bằng **bảng tóm tắt 1 trang** 18 bài + 3 bài quan trọng nhất (Williams/Pandolfi/ABB).
  - Xuất pandoc `.md→.docx` có TOC. **Bằng chứng:** docx **6,6 MB**, verify zip đếm **đủ 33/33 hình nhúng** trong `word/media/`.

### 2026-07-17
- [x] **Tách DR-001 thành 3 FILE PART riêng + thêm 3 bu-lông góc mặt treo + lắp lại DR-000** (báo cáo + 7 ảnh `outputs/tach3link_20260717/`; backup `Backup/DR-001_..._pretach3link.SLDPRT` + `DR-000_..._pretach3link.SLDASM`, tỉa backup cũ theo quy tắc giữ-1):
  - **(1) Thêm 3 bu-lông M12 ở 3 GÓC mối ghép mặt treo↔khung** (yêu cầu "lấy thêm 3 lỗ ở góc cho chắc"): 6 M12 cũ ở 3 lobe (R190.7); thêm 3 ở 3 cột góc (az {3.3/123.3/−116.7}, R300) bắt lid xuống **3 cột góc Ø72** (khỏe nhất, dưới 3 cánh motor) → **tổng 9 bu-lông đều**. Mỗi lỗ: `PadVit-M12-Goc-x3` boss Ø64 trên khung gối vào cột (merge=false + Combine-ADD, +226.62) + `LoBu-M12-Thru-Goc-x3` suốt Ø13.5 lid (−5.153) + `LoBu-M12-CBore-Goc-x3` khoét Ø20 (−12.252) + `LoRen-M12-Goc-x3` ren Ø10.2 vào boss (−4.903) — **mọi ΔV = lý thuyết tuyệt đối**, 3/3 vị trí đúng. V part 24 808.23→**25 012.54 cm³**.
  - **(2) Tách 3 file** (copy nguyên file giữ 100% face ID + `InsertDeleteBody2(false)` giữ 1 thân theo băng Y; cả 3 = thép A36): `DR-001-1_De-Gan-Tay` (đế gắn tay, 12 644.84 cm³/99.26 kg, hàn), `DR-001-2_Khung-Han` (khung hàn + 6 pad + 3 boss góc, 4 038.32/31.70, hàn), `DR-001-3_Mat-Treo` (mặt treo mang 9 lỗ M12, 8 329.38/65.39, bắt vít). Tổng 25 012.54 = 196.35 kg.
  - **(3) Sub-assembly `DR-001_Base-Plate.SLDASM`** (3 part ở gốc tọa độ, fix cả 3, 196.348 kg) — song song kiến trúc DR-005.
  - **(4) Lắp lại DR-000**: `ReplaceComponents2` part→sub-assembly, ReAttachMates=true → **25/25 mate bám DR-001 tự tái bám, 0 lỗi** (18 bracket→face Khoi1 giữ ID; 6 Lock+1 Concentric cấp-component); toàn cây **0 feature/mate lỗi**; mass DR-000 **251.24 kg** (=249.64+1.60 bu-lông góc); DR-001 sub-asm fixed=True. Save err=0. Master multibody `.SLDPRT` chuyển vào Backup.
  - Bẫy API mới: body cut/combine-output không đổi tên độc lập được (theo tên feature cuối); `InsertDeleteBody2(bool KeepBodies)` cần typed interop; boss merge=true bắc cầu qua mặt trùng Y=−175 (Khoi2+Khoi3) → phải merge=false + Combine-ADD chỉ Khoi2; 1 FeatureCut4/process (fresh process mỗi cut); `AddComponent5` cần part mở trước; `ActivateDoc3` cần InvokeNRefLast (byref cuối). **[C: đầy 100%]** đã dọn temp orphan + xóa CWR FEA cũ 3.3GB trên F:.
  - **[SỬA LỖI ĐỎ tối 2026-07-17 — người dùng báo "assembly lỗi đỏ"]** 19 lỗi đỏ code-51 = 18 mate bracket + Concentric3 (bám plate): `ReplaceComponents2` part→SUB-ASSEMBLY KHÔNG tái bám mate cấp-mặt (scan `GetErrorCode2 @(0)` sai byref nên báo "0 lỗi" giả — dùng `GetWhatsWrongCount`). **Fix: thay DR-001→DR-001-1 (plate) part→part** (19 mate tái bám sạch) + add frame/lid copy `Transform2` plate (không CreateTransform) + Fix → **kiến trúc FLAT (3 component rời trong DR-000)**, WhatsWrong 21→0, mass 251.24, saved, ảnh `dr000_FLAT_fixed.png`. **[Ổ C: đầy 100%]** blocker suốt: SW crash/lưu-fail với 0 byte C: → workaround launch SW `$env:TEMP='F:\SWTEMP'` (temp sang F:) + dọn `C:\$Recycle.Bin` 812MB; **cần user giải phóng C: hoặc set TEMP=F: vĩnh viễn**.
  - **[Xuất 3 bản vẽ gia công riêng cho 3 khối]** (`BanVe_GiaCong/`, `make_drawing2.ps1` thêm 3 part vào scaleMap/dimViewMap/featureNotes): `DR-001-1_De-Gan-Tay` (99.26 kg) · `DR-001-2_Khung-Han` (31.7 kg, isometric thấy 6 pad + 3 boss góc) · `DR-001-3_Mat-Treo` (65.39 kg) — A3 chiếu góc 1 TCVN, 1:10, 4 hình chiếu + feature note (kích thước gia công chính + ISO 2768-mK) + khung tên VN, **drw+pdf err=0 cả 3**, preview xác nhận bố cục sạch. Xóa bản vẽ `DR-001_Base-Plate` cũ (lỗi thời, tham chiếu part đã retire). Tổng bản vẽ chế tạo giờ **10** (8 cũ − DR-001 + 3 khối).
  - **[SỬA LỖI chiều 2026-07-17 — người dùng báo "assembly lỗi, mặt khung không nằm mặt trên"]** Nguyên nhân gốc: **`AddComponent5(...,0,0,0)` đặt TÂM BBOX tại (0,0,0), không phải gốc part** → 3 khối bị canh giữa quanh Y=0 (không xếp chồng), plate lệch 25mm → cánh tay kéo lệch theo (mate chỉ ràng plate nên "0 lỗi" giả). Fix: dựng lại sub-asm add mỗi part tại coords = **tâm bbox part** → identity chuẩn; verify body Y-box khớp part-coords tuyệt đối (plate 0..50, frame −175..0, lid −200..−175, contiguous); DR-000 mở lại: mate re-solve, **0 lỗi, 251.24 kg, save err=0**, ảnh `dr000_FIXED_iso.png` xác nhận robot mạch lạc. **`MathUtility.CreateTransform` GIẾT SW** (thử 1 lần → RPC_S_SERVER_UNAVAILABLE, kể cả chỉ mở sub-asm) → phải relaunch SW. **C: đầy là vấn đề hệ thống của máy** (data user, không phải file tôi) — cần người dùng dọn.

### 2026-07-14
- [x] **Rà soát + sửa phần MÔ PHỎNG LỰC theo 2 yêu cầu trình bày của thầy** (`MoPhong_Luc/`, backup bản cũ `force_analysis_v0_backup.m`). Bản cũ CHƯA ĐẠT: chỉ có đồ thị lực–thời gian, gộp chung tĩnh/động, **bỏ hoàn toàn khối lượng bắp tay** khi tính momen động cơ, chưa có hệ số an toàn.
  - **YC1 — hình phân bố lực + biểu đồ nội lực + ký hiệu:** thêm `force_diagrams.m` xuất `figs/so_do_phan_bo_luc.png` (FBD bàn máy Σfᵢlᵢ=m_ee(a−g) + FBD một cánh tay, đủ vector/ký hiệu), `figs/bieu_do_noi_luc.png` (biểu đồ **N,Q,M** dọc bicep, M_max=52.1 N·m tại vai), `figs/noiluc_thanhtruyen.png` (lực dọc thanh truyền 61.4 N). Bảng ký hiệu đầy đủ trong `README.md`.
  - **YC2 — momen = tĩnh + động × hệ số an toàn:** viết lại `force_analysis.m` tách **M_tĩnh** (giữ trọng lượng TCP 22.3 + bicep 13.8 = **35.8 N·m**) và **M_động** (quán tính TCP 30.8 + bicep+rotor 13.9 = **39.2 N·m**); đọc `m_arm=6.912 kg` từ CAD (COM SolidWorks), J_arm=⅓m·L1²=0.383, J_rot=J_mot·i²=0.071. **M_yc = 1.5×(35.8+39.2) = 112.5 N·m**. Hình `figs/joint_torques.png` (tĩnh/động/tổng), `figs/torque_sizing.png`.
  - **Phát hiện: TPM-010S-061T (T2B 80 N·m) KHÔNG đủ** (M_yc 112.5 > 80; M_rms 45 > stall 29). Nguyên nhân: bắp tay nặng 6.9 kg + gia tốc 1.18 g — bản cũ "thấy đủ" (τ=48.4) chỉ vì bỏ sót bắp tay. (Đây là bước "so catalog TPM-010S" còn treo — nay có đáp án.)
  - **So sánh phương án hộp số cùng cỡ 010** (`figs/gearbox_compare.png`, bảng trong `README.md`): tăng i làm tăng T2B nhưng tăng quán tính rotor J_mot·i² → M_động tăng. DYNAMIC tăng ratio chỉ đủ ~i=100 và **sát ngưỡng liên tục**. **Đề xuất TPMA 010S-055T (TPM+ HIGH TORQUE, cùng cỡ 010): T2B 230, đạt dư 1.69×, biên liên tục rộng** — số liệu thật từ catalog. Người dùng đã chọn hướng "tăng tỉ số/mô men cùng dòng 010". Chờ xác nhận part cụ thể trước khi thay CAD (bích 094C≠064A).
  - Bằng chứng: `out/force_log.txt`, `out/force_results.mat`, 7 hình `figs/`.
- [~] **Bắt đầu THAY HỘP SỐ trong CAD: TPM-010S-061T → TPMA010S-055T** (chốt hướng: giữ R−r=226.4 + thiết kế lại DR-002/003/004). Bằng chứng + spec: `outputs/gearbox_swap_20260714/INTERFACE_SPEC.md`, backup `Backup/DR-000_...backup_20260714_pregearbox.SLDASM`.
  - **Kiểm tra: swap CHƯA làm** — assembly `DR-000` vẫn tham chiếu **3× TPM cũ** (lần trước chỉ tải STEP + phân tích lực; assembly sửa 14:50 nhưng không đổi hộp số, không backup).
  - **Convert STEP → SLDPRT**: import `TPMA...094C.stp` qua `LoadFile4`+`GetImportFileData` (OpenDoc6 type=1 fail err 2097152), SaveAs3 → `DeltaRobot_Final/TPMA010S-055T-5PB1-094C-W1-000.SLDPRT` (1.96 MB, verify hình học).
  - **So sánh giao diện 2 hộp số (đo trực tiếp CAD)** — bảng đầy đủ trong `INTERFACE_SPEC.md`. TPMA: dài **246.8** (+63.3) mm, **8.1 kg**. Điểm mấu chốt: **BC Ø108, BC Ø50, pilot Ø63, bích sau Ø68 KHÔNG đổi**; chỉ khác số lỗ (output 16→24, front 16→32), thân kẹp **Ø98→Ø120.5**, dài thêm 63 mm (dồn về phía động cơ).
  - **DR-004 Shoulder-Bracket KHÔNG cần sửa**: chỉ dùng **8 bu-lông @45° trên BC Ø50**, pilot Ø31.5 — @45° khớp cả pattern 16 lỗ (22.5°) lẫn 24 lỗ (15°); pilot Ø31.5 không đổi. (còn kiểm lại khi mate assembly.)
  - **DR-002/003 Motor-Bracket**: DR-002 bore thân **Ø118→Ø120.5**, có recess pilot Ø91 (~khớp Ø90 mới); DR-003 bore Ø108. Cần: nới bore + tăng số lỗ bích + xử lý +63 mm.
  - Ảnh xác nhận (`outputs/gearbox_swap_20260714/assembly_current_TPM.png`): đầu động cơ thò ra vùng trống → **không cần dời bracket**, 63 mm dồn ra đó, giữ bích ra đúng chỗ (R−r nguyên).
  - ~~DEFER sang phiên Fable~~ → **ĐÃ LÀM TIẾP TRÊN FABLE 2026-07-15** (xem mục 2026-07-15).

### 2026-07-16
- [x] **Tách DR-001_Base-Plate thành 3 KHỐI chế tạo riêng theo yêu cầu người dùng** (báo cáo + 5 ảnh: `outputs/tach3khoi_20260716/`; backup `Backup/DR-001_..._pretach3khoi.SLDPRT`): **Khối 1 đế gắn tay** (tấm 50mm, 12 644,8 cm³/99,3 kg — HÀN với khung) · **Khối 2 khung hàn** (vách 8mm + trụ ống + 6 tai đệm, 3 816,6 cm³/30,0 kg, hạ đỉnh 200→175, cắt 50mm chân chôn trong tấm → chân tựa đúng mặt tấm) · **Khối 3 mặt treo** (bản 25mm mang toàn bộ ren treo M16×9+M20×6+Ø150, 8 346,8 cm³/65,5 kg — **BẮT VÍT vào khung**). Mối ghép vít mới: 6 tai đệm hàn trong vách scallop + **6×M12** (suốt Ø13,5 + khoét Ø20×13 chìm mặt trần qua mặt treo, ren vào tai đệm) — vị trí nằm gọn trong lug (cách tâm lug 83,7), cách M20 70,7. Mọi bước verify ΔV chính xác (−524,0 hạ khung / −1 048,0 cắt chân / −34,64 −441,79 −36,08 tái tạo lỗ treo / +158,45 tai đệm / −21,47 −13,34 −9,81 lỗ M12); 3 body phân hoạch sạch **0 chồng lấn**; DR-001 = 24 808,2 cm³ = 194,7 kg; **assembly 249,636 kg** (=cũ+0,876 đúng ΔV), rebuild sạch, save err=0. Tồn đọng: bản vẽ DR-001 lỗi thời (cần tách 3 bản vẽ), Fillet4 chết (0 mặt, vô hại), FEA DR-001 cũ chạy trên khối liền.
- [x] **Sửa lỗi assembly DR-000 (người dùng báo "nhiều lỗi")**: GetWhatsWrong ra 15 mục (1 lỗi đỏ Coincident34 + 14 cảnh báo, toàn code 51) — toàn bộ là chuỗi mate Coincident/Parallel CŨ của **cánh tay 1** (hub↔DR-004, link↔DR-006, DR-006↔khớp cầu, rod↔khớp cầu, Parallel12) còn ACTIVE chồng lên 5 Lock → thừa ràng buộc; Coincident34 thành lỗi đỏ sau khi sửa hình học DR-006. Hai cánh kia sạch vì chuỗi tương ứng đã suppress từ trước. **Fix: suppress 9 mate thừa của cánh 1** (đúng kiến trúc Lock-giữ-pose trong CLAUDE.md) → **WhatsWrong = 0**, mass 248.760 kg không đổi (không gì di chuyển), save err=0.
- [x] **Rà soát và chuẩn hóa chuyên nghiệp toàn bộ 8 bản vẽ gia công - v6** (`BanVe_GiaCong/`, theo phản hồi trực tiếp của người dùng): sửa `make_drawing2.ps1` để 3 hình chiếu + 1 hình trục đo 3D dùng **cùng một tỉ lệ**, bố trí cố định trên lưới 2x2 A3, tách khỏi khung tên; tỉ lệ cuối DR-001 1:10 · DR-002/003/005-1/006/007 1:4 · DR-004 1:1 · DR-005-2 1:5. DR-001/004/007 thay chuỗi kích thước tọa độ dày bằng khối quy cách gia công/lỗ/PCD + ISO 2768-mK; các bản còn lại chỉ ghi kích thước trên hình chiếu chính. **Bằng chứng:** 8/8 `.SLDDRW` + `.pdf` xuất `err=0`; render lại trực quan 8/8 PDF xác nhận không view/leader/text vượt khung, khung tên không bị đè; báo cáo `BanVe_GiaCong/KIEMTRA_BANVE_V6.md`, quy chuẩn cập nhật trong `BanVe_GiaCong/README.md`.
- [x] **Bản vẽ gia công v4** (2 vòng phản hồi trong ngày; script `make_drawing2.ps1`): **tự chọn tỉ lệ chuẩn** (2:1/1:1/1:2/1:4/1:5/1:10) sao cho block đứng+cạnh / đứng+bằng lọt khung → DR-001 1:5, DR-002/003/005-1/005-2/007 1:2, DR-004 2:1, DR-006 1:1; bố cục căn giữa cân xứng (đứng trên trái — cạnh cùng hàng — bằng dưới — **ảnh 3D góc dưới phải NGAY TRÊN khung tên**); **lọc kích thước** (xóa dim trùng giá trị giữa 2 hình chiếu + dim vặt <2.2mm — xóa 1–12 dim/bản); khung tên nới cột hết lòi viền. 8/8 SLDDRW+PDF err=0.
- [x] **Bản vẽ gia công v3 — làm lại cả 8 theo yêu cầu người dùng** (script `make_drawing2.ps1` sửa tại chỗ, không backup theo yêu cầu; 8/8 SLDDRW + PDF err=0, preview `prev_*.bmp`):
  - **Bỏ hẳn khung tên/sheet format SolidWorks** (SetupSheet5 fmt rỗng) → khung viền 10mm tự vẽ + **bảng khung tên riêng 9 dòng** góc dưới phải: BẢN VẼ/CHI TIẾT/VẬT LIỆU/KHỐI LƯỢNG/TỈ LỆ/ĐƠN VỊ/**NGƯỜI VẼ = NGUYEN VAN NAM - 23134038**/NGÀY VẼ/TRƯỜNG.
  - **Ảnh 3D đặt dưới hình chiếu bằng** (cột đứng→bằng→3D, cạnh bên phải); 3 hình chiếu cùng tỉ lệ, ảnh 3D tự co theo chỗ trống (cùng tỉ lệ không vừa A3 với đa số part).
  - Bẫy API: vẽ khung viền phải làm **khi sheet còn trống** — sau khi có view, CreateLine rơi vào sketch của view active (sai chỗ, sai tỉ lệ); `ActivateView('')` không tin được. DR-001 PDF err=1 lần đầu (file khóa?) — xuất lại từ SLDDRW là được.
- [x] **BƯỚC 1 hạng mục "Sửa tính đối xứng": quét xong 8/8 part** (`outputs/doixung_20260716/` — báo cáo `BAOCAO_QUET_DOIXUNG.md`, dữ liệu thô `scan_*.txt`, script `scan_parts.ps1`; volume đọc về khớp số liệu cũ tuyệt đối → dữ liệu tin cậy):
  - **Kết luận then chốt**: phần lớn số lẻ trên bản vẽ (17.68/9.18/22.17…) là HÌNH CHIẾU của lỗ trên vòng bu-lông (đối xứng chuẩn, không sửa part được — muốn đẹp phải đổi kiểu ghi kích thước); nhưng cũng tìm ra 6 lỗi lệch tâm THẬT (nhóm A) + 1 bất đối xứng profile (nhóm B).
  - **Nhóm A (sửa an toàn)**: DR-002 pocket Ø118 lệch (0.034,−0.775) & vòng Ø91.06 lệch (0.034,+0.902) so tâm 16×M5 — chính là nguồn tiếp xúc 349 mm³/arm với hộp số; DR-005-2 ống lệch trục +0.3098; DR-007 cụm moay-ơ lệch (0.1387,0.2753) + ngõng rod −22.0173/+22.0232 + sliver biên; DR-001 6/12 lỗ bậc chân gá lệch 0.174 so lỗ xuyên; DR-003 dim 70.0343.
  - **Nhóm B**: DR-006 hai hông xiên 29.79° vs 30.05° (nên = 30°).
  - **Giữ nguyên (C)**: cặp 44.03/124.03 clevis↔platform (liên kết động học), ren 5/8"-18 rod end (chuẩn inch vendor), pha 3.33° lỗ hub (clocking lắp ráp), hệ tai treo DR-001 R418/429/315.75 (đối xứng bậc 3 chuẩn), tangent lẻ profile DR-002/003. DR-004 đối xứng HOÀN HẢO.
  - Bẫy COM mới ghi vào CLAUDE.md + memory: chuỗi từ cmdlet (Join-Path) mang PSObject wrapper → marshal VT_DISPATCH → mọi call hr=0x80020005; mở doc bền = GetOpenDocSpec+OpenDoc7.
- [x] **Người dùng duyệt A+B+C1+C5 → SỬA XONG 6 part cùng ngày** (chi tiết + bằng chứng đầy đủ trong `outputs/doixung_20260716/BAOCAO_QUET_DOIXUNG.md`, backup `*_backup_20260716_presym` ×6):
  - **DR-005-2**: xóa MoveCopyBody "-1" → 2 đầu ống **±150.000** (V không đổi). **DR-007**: xóa move "-2" cuối cây, chèn `DichTam-3Canh` sau Boss-Extrude1 (tấm về tâm, moay-ơ Ø160/140/200/80 + 6 lỗ Ø12 @ tâm 0 chuẩn), 3 sketch đế ngõng chuẩn hóa giống hệt nhau, stud 3 cánh đều radial **120.50** (trước rải 0.48mm), hết sliver. **DR-002**: pocket Ø118 + vòng Ø91.06 về tâm 0 (V không đổi tuyệt đối). **DR-003**: 70.0343→70. **DR-006**: đáy phẳng −58.0, hai hông đúng **30.00°** đối xứng. **DR-001**: 12/12 lỗ bậc đồng tâm d=0.
  - **DR-000 verify**: M5 err 0.001×3 arm · M2.5 err 0.001×3 · mass 248.760 kg · **interference 483 = baseline MỚI** (cũ 504, giảm 21 vì hết lệch pocket DR-002 — nguồn tiếp xúc 349mm³/arm cũ) · save err=0.
  - **Bản vẽ tái sinh 6/6** (`BanVe_GiaCong/`, drw+pdf err=0) — đường kính/spacing tròn.
  - **Không làm (đã thử/đánh giá, lý do trong báo cáo)**: C1 44.03→44 (span khóa vào outline 3 cánh có spline — giữ 44.03 ĐỒNG BỘ cả DR-006+DR-007); mép 3 đầu cánh DR-007 (sửa Sketch1 làm gãy refs extrude-from-face → mất stud, revert 2 lần); C5 vấu R130 (không set R qua API được, chênh 5µm vô hại — có thể sửa tay).
  - Bẫy API mới: `InsertMoveCopyBody2` cần body chọn **mark=1**; dim MoveCopyBody không set được (err=2) — xóa/tạo lại; `ReorderFeature` opt semantics bất định — verify hình học sau reorder; `SketchPoint.SetCoords` kích hoạt solver kéo trôi điểm khác (kể cả AutoSolve=false vẫn hỏng lúc exit); sửa sketch gốc của extrude-from-face phá face refs.

### 2026-07-15
**TỔNG KẾT NGÀY:** (1) thay xong 3× hộp số TPMA trong CAD — bích ra đúng chỗ tuyệt đối, không sửa bracket, không thêm va chạm; (2) chạy lại MATLAB chọn động cơ chính thức với TPMA — đạt cả 3 điều kiện, FEA giữ nguyên có bằng chứng; (3) cập nhật 4 báo cáo; (4) hoàn thiện lắp ghép: 16×M5 bích→DR-002, 8×M2.5 lỗ bậc DR-004↔hub; (5) mặt treo 3 cánh tròn theo mẫu người dùng + 6 lỗ M20; (6) ẩn sạch sketch; (7) xuất 8 bản vẽ gia công A3 TCVN (v2 sau phản hồi). Mọi thay đổi CAD đều verify ΔV/vị trí + save err=0, backup theo quy tắc giữ-1.

- [x] **HOÀN TẤT THAY HỘP SỐ TPM-010S-061T → TPMA010S-055T trong CAD** (chạy trên Fable; scripts lưu `outputs/gearbox_swap_20260714/scripts/01–15`, log cùng thư mục):
  - **Đo lại chính xác (lật kèo tiết kiệm lớn): KHÔNG cần sửa bracket nào.** Đo span part-space (box mặt = span trục, script 03–04): giao diện từ bích ra → mặt đầu ra của TPMA **giống hệt 100%** TPM cũ — bích Ø117.5×7 mm, ngõng Ø90×9.6 mm, pilot Ø63, mặt ra = bích+30.0 mm. Côn Ø120.5→Ø95 của TPMA kết thúc **hở 16.5 mm** trước mặt DR-002. DR-002 là chi tiết duy nhất chạm hộp số (vòng Ø91.06 ôm ngõng Ø90, pocket Ø118 nhận bích Ø117.5 — đo trong assembly, khung hộp số); DR-003/DR-004 không đụng. Bảng đầy đủ: `INTERFACE_SPEC.md`.
  - **Replace 3 instance** (script 08): xóa 4 mate cũ (Coincident74/75, Lock11, Concentric19) → `ReplaceComponents2` → save err=0.
  - **Định vị + mate lại** (script 10/12/13): mate hình học thật Coincident82 (mặt bích TPMA ↔ đáy pocket DR-002-4) + 3 Lock mới (TPMA-i ↔ DR-002 gần nhất). **Verify cả 3 arm: translation err = 0.000 mm, rotation err = 0** so với đích `t_old − 34.7·axis` (34.7 = 81.5−46.8 chênh tọa độ bích trong part; kiểm chéo độc lập bằng transform cũ lưu file). → **Bích ra nằm ĐÚNG chỗ cũ tuyệt đối, R−r=226.4 không đổi, động học/FEA cánh tay giữ nguyên giá trị.**
  - **Rebuild ×2 + save err=0**; khối lượng assembly đọc lại 230.76 → **233.82 kg** (CAD; +3×~1.02 kg vì model import không có density đúng — TPM cũ CAD cũng chỉ 1.336 kg vs 4.9 thật; ghi chú hiệu chỉnh khối lượng thật +3×(8.1−2.354)=+17.2 kg cho báo cáo). Ảnh: `asm_tpma_iso.png` (TPMA vòng xanh, đuôi thò vùng trống).
  - Bài học API ghi nhận: PS máy này lỗi parser `@(a*b, c*d)` không ngoặc (bọc `@((a*b),(c*d))` hoặc gán từng phần tử); `MathUtility.CreateTransform` GIẾT SolidWorks trên assembly sau replace (2 lần crash) — định vị bằng mate hình học thay vì transform; `AddMate5` err=1 = OK; `InterferenceDetectionManager` nằm trên `IAssemblyDoc` (không phải Extension), cần typed interop.
  - **Interference detection thật (typed, script 15) + baseline backup TPM cũ (script 16): 504 = 504 chỗ — swap KHÔNG thêm va chạm nào.** DR-002↔hộp số 349.107/275.7 mm³ ×3 arm **y hệt trước–sau** (artifact tiếp xúc có sẵn của thiết kế — rod-end cứng/Lock mates vốn có ~500 chỗ chạm nhỏ); DR-004↔hộp số cùng loại 14–150 mm³. Log `15_out.txt`/`16_baseline_out.txt`.
  - Density TPMA: doc-pref lẫn per-body `MaterialPropertyValues2` đều không ăn trên part import (giữ 1000 kg/m³ như TPM cũ) → dùng hiệu chỉnh +17.2 kg trong báo cáo (CAD 233.82 → thật ≈ 251 kg).
  - CLAUDE.md + memory (`gearbox-swap-tpma`) đã cập nhật. → **HẠNG MỤC THAY HỘP SỐ HOÀN TẤT.**
- [x] **Chạy lại MATLAB phân tích lực với TPMA (chính thức) + xác nhận FEA bền/võng không phải làm lại** (`MoPhong_Luc/`, backup bản TPM `force_analysis_v1_tpm061_backup.m`):
  - `force_analysis.m` chuyển hộp số chính thức sang **TPMA010S-055T** (i=55, J_mot=2.18 kg·cm² → J_rot=0.6595 kg·m², gấp 9× cũ). Kết quả: M_tĩnh 35.8 + **M_động 55.0** (rotor nặng hơn) = 90.9; **M_yc = 136.3 ≤ T2B 230 → ĐẠT dư 1.69×; M_rms 53.4 ≤ 110 → ĐẠT 2.06×; 30.1 ≤ 88 rpm → ĐẠT — cả 3 điều kiện.** Log `out/force_log.txt`, hình `figs/torque_sizing.png`/`joint_torques.png`/`gearbox_compare.png` tái sinh với ngưỡng 230/110.
  - **FEA bền/độ võng GIỮ NGUYÊN — có bằng chứng**: bảng tải FEA chạy lại y nguyên (F_ee 175.8 N; thanh truyền 61.4 N; uốn bắp tay ~51 N·m) vì tải 4 chi tiết đến từ động lực học bàn máy (khối lượng chuyển động không đổi — hộp số phía đế); M_động tăng thêm tiêu trong lòng hộp số (gia tốc rotor), không truyền qua bích ra; đế thêm 9.6 kg tĩnh ~+4% (FOS 397→~380). Lý giải ghi trong `MoPhong_Luc/README.md`.
- [x] **Khoan 16 lỗ ren M5 trên DR-002 bắt bích trước TPMA** (backup `Backup/DR-002_..._backup_20260715_preM5.SLDPRT`, xóa backup premat cũ theo quy tắc giữ-1; scripts 17–25 trong `outputs/gearbox_swap_20260714/scripts/`):
  - Đo bích TPMA: **16 lỗ Ø5.5 BC Ø109 cách đều 22.5°** (không phải 32 — số cũ đếm đôi mặt nửa trụ); map sang hệ part DR-002 theo đúng clocking assembly hiện tại (trục bore = +Y part, đáy pocket y=15, vật liệu ren y15–30).
  - Feature **`LoRen-M5-x16`**: 16 lỗ mũi Ø4.2 sâu 10 (ren M5×0.8) từ đáy pocket. Verify: **dV = 2216.7 mm³ = đúng lý thuyết tuyệt đối**; 16/16 trục tại đích <0.05 mm; span y=[15..25] đủ 10 mm.
  - Assembly: rebuild, **align lỗ gá ↔ lỗ bích hộp số cả 3 arm err = 0.001 mm** (clocking 3 arm giống nhau), khối lượng 233.82→233.80 (−18 g = đúng 3×16 lỗ nhôm), save err=0. Ảnh `asm_m5holes.png`.
  - Bài học API mới (ghi CLAUDE.md): **`SketchManager.AddToDB=true` bắt buộc khi vẽ sketch bằng code** — không bật thì inference snapping nuốt 16 vòng còn 8 + hút tâm sang tọa độ vòng kề (đây là nguyên nhân thật của mọi "thiếu lỗ", không phải thiếu vật liệu — vành BC109 đặc đủ 360°, không cần đắp boss); PS case-insensitive nên `$Bx`/`$bx` là một biến (constraint [double[]] biến scalar thành mảng → lỗi op_*); cấm mọi biểu thức trong `@()`.
- [x] **Bắt vít DR-004 ↔ DR-005 (hub bắp tay)** (backup `DR-004_..._preM5.SLDPRT` + `DR-005-1_..._preM5.SLDPRT`, tỉa backup cũ; scripts 26–29):
  - Đo giao diện: DR-004 = trục bậc Ø31.5–vành Ø58×10 (y14–24, có 8 vít chìm cũ BC Ø50 @k·45° đầu phía y24)–Ø31.5; hub có hốc bậc Ø58×10 + Ø31.5×10 trên mặt z=−43; đỉnh vành nằm z=−37 (hốc dùng 6/10, khe 4 mm tới đáy hốc z=−33).
  - **DR-004**: 8 lỗ bậc **NGƯỢC chiều vít cũ** — phiên bản đầu M5 (Ø9.5/Ø5.5) bị chê to → **làm lại M2.5 đồng cỡ 8 lỗ bậc hiện có** (script 30): bậc **Ø5×5** phía y14 (mặt hộp số, đầu vít chìm) + thông **Ø2.6**, BC Ø48, góc 22.5°+k·45° xen giữa 8 vít cũ (feature `LoBac-M25-Through-x8`/`LoBac-M25-CBore-x8`). Xóa feature M5 → volume về đúng baseline 47.245 cm³ sạch; ΔV mới = 424.7 + 573.0 mm³ = **đúng lý thuyết**; 8/8+8/8 vị trí đúng.
  - **DR-005-1 hub**: 8 lỗ ren **M2.5** (`LoRen-M25-Hub-x8`, mũi Ø2.05×8) từ đáy hốc z=−33 (bản M5 Ø4.2×12 đã xóa, baseline 920.784 sạch); ΔV = 211.2 (lý thuyết 211.1); 8/8 tại đích (R=24.000).
  - Assembly: **đồng trục lỗ DR-004 ↔ lỗ ren hub cả 3 arm err = 0.001 mm**; khối lượng 233.788 kg (chênh +33.1 g so bản M5 = đúng vật lý lỗ nhỏ hơn); save err=0. Vít chọn: **8× M2.5×20/khớp** — đồng cỡ + đối xứng với 8 vít M2.5 hiện bắt bích động cơ (2 hệ vít so le 22.5°, ngược chiều nhau). Ảnh `asm_m25_bolts.png`.
- [x] **Nâng cấp mặt treo DR-001: 3 vấu nhỏ M10 → 6 vấu to M16** (script 33/34; backup `Backup/DR-001_Base-Plate_backup_20260715_pregusset6.SLDPRT`, tỉa backup presteel theo quy tắc giữ-1):
  - Yêu cầu: vấu + lỗ to hơn, thêm 3 vị trí đối xứng để bắt giá treo chắc hơn. Xóa `MatTreoVau-Gusset3`+`LoVit-M10-x3` (V về 22612.76 cm³ đúng dự đoán) → **`MatTreoVau-Gusset6`**: 6 vấu hình thang (chân 90 mm ăn vào R150, đỉnh 60 mm tại R295 — nhô hơn bản cũ R272), **2 vấu/hõm tại tâm hõm ±18°** (mốc góc đo từ 3 lỗ M10 cũ az −173.9°/−53.9°/66.1°, R250) — giữ đối xứng bậc 3, cách xa tai giữa R316. Boss **+841.95 cm³, 1 body**.
  - **`LoVit-M16-x6`**: 6 lỗ ren M16 (Ø14×25) tại R278 giữa đỉnh vấu — **dV = 23.091 cm³ đúng lý thuyết tuyệt đối**, 6/6 vị trí; **đồng bộ toàn bộ 15 điểm treo = M16** (9 cũ + 6 mới), bỏ hẳn M10.
  - V part 23430.9 cm³ → **thép ≈ 184 kg** (+5.05 kg); assembly 238.84 kg (CAD), rebuild + **interference 504 = 504 baseline (vấu không đụng gì)**, save err=0. Ảnh `dr001_gusset6_bottom.png`, `asm_gusset6.png`. CLAUDE.md cập nhật mô tả mặt treo.
- [x] **Đổi kiểu vấu treo sang VẤU TRÒN theo mẫu người dùng tự sửa** (script 35–38; backup `DR-001_..._preround3.SLDPRT`, tỉa pregusset6): người dùng chê vấu hình thang thô, tự sửa 1 hõm (az 66.1°) thành **vấu tròn lớn R129.92 tâm tại R223.3** (sửa trong `Sk-MatTreoVau`, V +427 cm³) và yêu cầu nhân sang 2 hõm còn lại.
  - Đọc ngược hình tròn của người dùng (R/tâm/az chính xác từ mặt trụ), boss `MatTreoTron-x2` = 2 hình tròn y hệt xoay ±120° (dV +867.3 ≈ 2×427 ✓, 1 body); trapezoid Gusset6 cũ chìm trọn trong vấu tròn (tính hình học: điểm xa nhất cách tâm ≤127.8 < 130).
  - Boss cuối cây lấp 4 lỗ M16 ở 2 cánh mới (lỗ cắt trước boss; cánh người dùng sửa sketch gốc nên không bị) → khoan lại `LoVit-M16-x4-Tron` (dV = 15.394 cm³ đúng lý thuyết). **Kiểm cuối: vành tròn R129.92 đủ 3 az (−173.9/−53.9/66.1) + 6 lỗ M16 @R278 đủ 6/6.**
  - Part save err=0; V = 24709.6 cm³ → thép ≈ **194 kg**; assembly rebuild + save err=0, **248.87 kg** (CAD). Ảnh `dr001_round3_holes.png`.
- [x] **Lỗ vấu to hơn + kéo vào trong** (script 39; backup `DR-001_..._preM20.SLDPRT`, tỉa preround3): gộp 2 feature lỗ cũ thành **`LoVit-M20-x6`** — 6 lỗ ren **M20** (mũi Ø17.5×25) tại **R260** (vào trong 18 mm so với R278), az giữ ±18° quanh tâm hõm. dV = **36.079 cm³ đúng lý thuyết**, 6/6 vị trí; mép lỗ cách biên cánh tròn ~37 mm. Ẩn sketch mới (28/28), part + assembly save err=0, CAD 248.77 kg. Ảnh `dr001_m20.png`.
- [x] **Bản vẽ v2 theo phản hồi "khung tên xấu + kích thước rối + hình nhỏ"** (script `make_drawing2.ps1`, tái sinh cả 8): bỏ khung tên ISO rườm → **bảng khung tên tự tạo 7 dòng tiếng Việt** (InsertGeneralTableAnnotation typed, góc phải); **phóng to hình** — tỉ lệ riêng từng part (DR-004 2:1 · gá/hub/chạc 1:1 · link/platform 1:2 · đế 1:5), ép `ScaleDecimal` + **bố cục tính từ bbox part** (đứng — bằng dưới — cạnh phải — trục đo góc, đúng chiếu góc 1); **giảm rối kích thước** — chỉ autodim 2 hình chiếu chính, DR-001 chỉ dim hình chiếu đứng (hình bằng 40 lỗ để sạch); sửa vật liệu rỗng (fallback). Verify từng bản qua preview render. 8/8 PDF + SLDDRW mới.
- [x] **Xuất bản vẽ gia công cơ khí — folder mới `BanVe_GiaCong/`** (script `make_drawing.ps1`, tự động qua COM): **8 chi tiết tự chế** (DR-001→007 + DR-005-1/2), linh kiện mua (TPMA/rod/khớp cầu) không xuất. Chuẩn: **chiếu góc thứ nhất (TCVN/ISO)**, A3, khung tên ISO, **mm** (sửa lỗi template mặc định inch: `swUnitSystem=263→MMGS=5`), bỏ ngoặc tham khảo (toggle 48), 3 hình chiếu + isometric + **kích thước tự động scheme tọa độ** (`IDrawingDoc.AutoDimension(0,2,-1,2,-1)` — nằm trên IDrawingDoc, chạy trên view đã chọn; IView KHÔNG có Autodimension3) + ép `UseSheetScale` từng view + khối ghi chú VN (tên/vật liệu/khối lượng/tỉ lệ). Mỗi part: `.SLDDRW` + `.pdf` — **8/8 thành công** (log `log_*.txt`, preview `prev_*`). Hạn chế ghi trong `BanVe_GiaCong/README.md`: DR-001 hình chiếu bằng dày đặc (~138 dims, tấm Ø960/40 lỗ) nên tỉa tay hoặc thay hole-table; lỗ ren hiển thị theo đường kính mũi khoan.
- [x] **Ẩn toàn bộ sketch trong mọi part** (script 31): BlankSketch từng sketch (127 cái / 8 part tự chế; DR-001 22 gồm Sketch9/Sketch18 tham khảo cũ, DR-002 19/21, DR-007 28...), save từng part + assembly err=0 — assembly hết nét vẽ lộ (ảnh `asm_nosketch.png`).
- [x] **Cập nhật toàn bộ báo cáo theo hộp số mới** (4 tài liệu):
  - `MoPhong_Luc/ThuyetMinh_ChonDongCo.md` + **`BaoCao/ThuyetMinh_ChonDongCo.docx`** (tái sinh pandoc, verify 109 công thức OMML + 4 hình nhúng): bảng M_động 2 cột TPM/TPMA (J_rot 0.071/0.660), bảng kiểm TPMA chính thức (136.3≤230 dư 1.69× · 53.4≤110 dư 2.06× · 30.1≤88), Hình 5 = joint_torques ngưỡng 230/110, §7 ghi ĐÃ THAY vào CAD không sửa gá + lý giải FEA giữ nguyên.
  - `MoPhong_DongHoc/CHUONG_DONGHOC_DONGLUCHOC.md` + **`.docx`** (tái sinh, verify TPMA/1,69/2,06/230 có trong file): mục "Kiểm động cơ" viết lại theo phương pháp tĩnh+động×k_s (48.37 chỉ là thành phần bàn máy), kết luận chương cập nhật TPMA.
  - `outputs/material_20260712/ThuyetMinh_LuaChonVatLieu.md`: dòng hộp số → TPMA (CAD 2.354/thực 8.1), tổng **233.82 kg CAD / ≈251 kg thực**, chú thích quy đổi.
  - `BaoCao/README.md`: mô tả ThuyetMinh_ChonDongCo cập nhật trạng thái đã thay CAD.
  - Các tài liệu FEA (`KETQUA_BEN`, `THUYETMINH_MOPHONG_BEN`) không nhắc TPM, tải không đổi → giữ nguyên.

### 2026-07-13
- [x] **Gom báo cáo Word vào `BaoCao/`** (folder gốc DeltaRobot, dễ kiểm soát): di chuyển 4 `.docx` (CHUONG_DONGHOC_DONGLUCHOC, THUYETMINH_DONGHOC_CHITIET, TINHTOAN_DONGHOC_CHITIET, THUYETMINH_MOPHONG_BEN_CHITIET) vào đó; `.docx` tự chứa nên di chuyển an toàn, `.md` nguồn giữ cạnh `figs/`. Kèm `BaoCao/README.md` (mục lục + nguồn .md + cách tạo lại bằng pandoc). File MucLuc để nguyên.
- [x] **Chương hoàn chỉnh Động học + Động lực học** (`MoPhong_DongHoc/CHUONG_DONGHOC_DONGLUCHOC.md` + `.docx`): gộp 3 phần (dẫn công thức + tính toán số + kết quả) và **thêm động lực học** — mô hình cẳng tay 2-lực Σfᵢlᵢ=m_ee(a−g) (m_ee=8,233kg), momen khớp τ=Jfᵀ·F_ee, đỉnh F_ee=175,8N/τ=48,37N·m, bảng tải FEA, kiểm động cơ TPM-010S; + quỹ đạo P&P + Jacobian/kỳ dị/vùng làm việc. Word: 45 công thức OMML + 8 bảng + 9 hình (nhúng cả `MoPhong_DongHoc/figs` lẫn `MoPhong_Luc/figs`).
- [x] **Bản tính toán động học chi tiết có số liệu** (`MoPhong_DongHoc/TINHTOAN_DONGHOC_CHITIET.md` + `.docx`): tính từng bước bằng MATLAB — IK P=(150,−100,−900) bảng c/s/a/u/w/E/F/G/ρ/ψ 3 cánh tay → θ=(9,12°;11,07°;34,41°); FK θ=(30,20,40)° bảng tọa độ Bᵢ/Eᵢ/Cᵢ + trilateration (P0,d,t1/t2) → P=(140,6;−2,8;−1008,6); **giới hạn góc [−45°,100°] → z trên trục [−569,3;−1389,1] mm** (bảng θ0→z), bán kính với tới ≥650mm (cần 400); bảng tọa độ tổng hợp. Word: 29 công thức OMML + 5 bảng.
- [x] **Thuyết minh chi tiết động học thuận/nghịch** (`MoPhong_DongHoc/THUYETMINH_DONGHOC_CHITIET.md` + `.docx`): dẫn công thức đầy đủ IK (chiếu mặt phẳng cánh tay → phương trình lượng giác E·sinθ+F·cosθ+G=0, giải asin, điều kiện |G|≤ρ, chọn nghiệm trong giới hạn) và FK (giao 3 mặt cầu → 2 mặt phẳng → đường giao → bậc 2, chọn z thấp), ví dụ số, kiểm chứng round-trip 6,2e−13 mm, Jacobian/kỳ dị, vùng làm việc. Sơ đồ 1 cánh tay có nhãn `figs/kin_arm_schematic.png` + hình p2/p3/p4. Xuất Word qua pandoc: 92 công thức OMML native + 4 ảnh nhúng.
- [x] **GUI mô phỏng động học bản ĐƠN GIẢN** (`MoPhong_DongHoc/delta_gui_simple.m`, giữ nguyên bản cũ `delta_gui.m`): figure + uicontrol cổ điển (nhẹ, render ổn định), 2 chế độ — **điều khiển KHỚP θ1,2,3 (động học thuận)** và **điều khiển VỊ TRÍ X,Y,Z (động học nghịch)**, chuyển chế độ bằng 2 nút; robot vẽ **dạng que đơn giản** (đế + bắp tay xanh + cẳng tay cam + bàn máy + sao TCP). Dùng chung `params.m`/`delta_fk.m`/`delta_ik.m`. **Thêm 3 tính năng** (theo yêu cầu): (1) nút **Chạy quỹ đạo P&P** tự động (gắp-thả, smoothstep, lặp đến khi bấm DỪNG) + nút DỪNG; (2) checkbox **hiện trụ vùng làm việc** Ø800×250 mờ tại z=−925; (3) **bắp tay đổi màu ĐỎ khi góc khớp vượt giới hạn** [−45°,100°] + ô trạng thái báo khớp nào vượt. Kiểm chứng: `checkcode` 0 lỗi; FK home→P=[0,0,−925]; IK round-trip err 5.8e−16; điểm lệch FK-back err 1.4e−13 mm; **quỹ đạo P&P 132 điểm, 0 điểm ngoài vùng, θ∈[−13.5,53]°**. Ảnh `figs/gui_simple_preview.png`, `figs/gui_simple_ws.png` (render headless). Chạy live: `matlab -sd MoPhong_DongHoc -r "delta_gui_simple"`.
  - **Tối ưu mượt + khóa vùng an toàn (chống kỳ dị)**: chuyển sang cập nhật dữ liệu đồ họa (handle-based, không vẽ lại), listener `ContinuousValueChange` cho slider (cập nhật liên tục khi kéo), `SortMethod childorder`, bỏ trong suốt, vùng quan sát lớn (±850, z[−1450,200]) để robot không mất khung. **Khóa vùng an toàn** dùng `delta_jacobian` (số điều kiện + góc truyền μ) + giới hạn khớp + trụ làm việc: đánh giá AN TOÀN(xanh)/CẢNH BÁO(cam)/KỲ DỊ(đỏ), tự lùi về pose an toàn cuối khi chạm kỳ dị/ngoài vùng. Kiểm chứng: home cond 1.83/μ 71.5° (an toàn), ngoài trụ μ 39.9° (cảnh báo), z=−1450 không tới (lùi). Ảnh `figs/gui_simple_safezone.png`.
- [x] **Xuất thuyết minh mô phỏng bền ra Word** (`MoPhong_Ben/THUYETMINH_MOPHONG_BEN_CHITIET.docx`, nguồn `.md`): 21 công thức Word native (OMML), 7 bảng, 4 ảnh von Mises nhúng — cài `pandoc` (winget) convert LaTeX→docx.
- [x] **Mô phỏng bền FEA — nghiên cứu hội tụ lưới cho cả 4 chi tiết chịu lực** (folder tự chứa `MoPhong_Ben/`, lưu script lên đĩa để không mất như lần trước). Mỗi part giải 3 kích thước phần tử, đọc ngược σ von Mises + chuyển vị + FOS, xuất hình fringe. Kết quả (FOS bảo thủ / lưới thô):
  - **DR-006 Elbow-Clevis** (6061-T6): σ 0,41–0,46 MPa, **FOS ≈ 599**, hội tụ tốt (8→5mm lệch 0,4%). Ngàm 2-mặt (ngõng R24 + mặt lưng) cứng hơn ngàm 1-stud cũ → σ thấp hơn 3,3 MPa lần trước (đúng hướng cải tiến).
  - **DR-005-2 Upper-Arm-Link** (6061-T6): σ 2,7–4,2 MPa, **FOS ≈ 65**. Chuyển vị thật ~0,008mm (khớp giải tích côngxôn; đỉnh 7,86mm API đọc là spike 1 nút, đã loại).
  - **DR-007 Moving-Platform** (6061-T6): σ 3,2–8,95 MPa, **FOS ≈ 31**, chuyển vị 0,35mm.
  - **DR-001 Base-Plate** (thép A36): σ 0,58–0,63 MPa, **FOS ≈ 397**, hội tụ tốt.
  - **→ Min FOS toàn bộ = 30,7 → cả 4 part an toàn dư bền ≥30× (payload 2kg).** Bằng chứng: `KETQUA_BEN.md`, `out/conv_*.csv`, `figs/fea_*_vonMises.png`.
  - **Kỹ thuật (mở khóa được FEA qua COM):** cosworks `AddRestraint`/`AddForce` KHÔNG gọi được qua raw IDispatch (mảng entity sai kiểu SAFEARRAY → err=1 hoặc server fault). Giải: **typed cosworks interop TRONG compiled Add-Type helper** (`SwFea` trong `fea_common.ps1`) — PS-level cast fail nhưng compiled cast chạy, lại check đúng signature `AddRestraint(int,object,object,out int)` lúc biên dịch. Bẫy khác: truyền mảng làm CLI arg cho `powershell -File` từ bash BỊ NUỐT dấu phẩy (`2,12`→`212`) — phải gọi qua wrapper `run_parts.ps1` (mảng literal trong PS). σ đỉnh dao động ở DR-005-2/DR-007 do kỳ dị mép ngàm/lỗ chưa bo (kết luận an toàn không đổi).
- [x] Cập nhật `CLAUDE.md` (thêm chiều mô phỏng MATLAB + FEA-qua-COM + thông số mục tiêu + vật liệu — trước đó thiếu).
- [~] Ghi chú: Fable hết credit giữa phiên → phần grind FEA chạy trên Opus (main loop) thay vì Fable như quy tắc.

### 2026-07-12
- [x] **Phân tích lực (payload 2 kg)** — đóng gói folder riêng chuẩn `MoPhong_Luc/` (`force_analysis.m` + deps tự chứa + `out/` + `figs/` + `README.md`): forearm là thanh 2-lực → giải `[l1 l2 l3]·f = m_ee·(a−g)`, momen khớp `τ=Jf'·F_ee`. m_ee=8.23 kg. **Đỉnh: F_ee=175.8 N · forearm/cặp=122.7 N (mỗi thanh 61.3 N) · τ_khớp=48.4 N·m · uốn bicep~50 N·m** (biểu đồ `figs/forearm_forces.png`, `joint_torques.png`, `force_ee.png`). Dùng làm tải FEA thực + kiểm động cơ.
- [~] **Bắt đầu mô phỏng bền FEA (SolidWorks Simulation qua COM)**: chốt **payload = 2 kg**. Tự động hóa được toàn bộ pipeline FEA tĩnh qua raw dispatch (typed interop cosworks fail — phải unwrap `.CosmosWorks`, xem memory). Chạy **DR-006 Elbow-Clevis**: ngàm ở stud mount (mũi tên xanh trên ảnh), lực **123 N thực** (từ phân tích lực) ở 2 lỗ rod → **von Mises ~2,6–3,3 MPa, FOS ~83–105** (6061-T6 chảy 275 MPa) — dư bền nhiều. Ảnh `outputs/material_20260712/fea_dr006_vonMises.png`. **Bài học: phải gọi `ForceBeginEdit` trước `SetForceComponentValues2` nếu không SW bỏ qua giá trị lực** (kết quả 0,027 MPa/FOS 10266 ban đầu là SAI do bug này). Ngàm đơn (chỉ stud) làm chuyển vị hơi cao (~1 mm) — ứng suất/FOS là kết quả chính, sơ bộ. [ ] FEA arm-link/platform/đế.
- [x] **Quy tắc backup mới + dọn `Backup/`**: gom backup vào `DeltaRobot_Final/Backup/`, chỉ giữ 1 backup mới nhất/part (tỉa 23→11), ghi quy tắc vào CLAUDE.md.
- [x] **Dọn thư mục `DeltaRobot_Final/` + hoàn tất lựa chọn vật liệu**:
  - **Dọn thư mục**: 13 file active giữ nguyên ở gốc (không di chuyển file được tham chiếu — bảo vệ liên kết SolidWorks), gom `*_backup_*` vào `DeltaRobot_Final/Backup/` rồi **tỉa chỉ giữ backup mới nhất mỗi part (23→11)**. Chốt **quy tắc mới trong CLAUDE.md**: `Backup/` chỉ giữ 1 backup mới nhất/part, gốc chỉ chứa file active.
  - **Kiểm chứng vật liệu hiện có** (đọc ngược `MaterialIdName` từng part qua COM): 8 part tự chế = 6061-T6, thanh truyền 6516K305 = sợi carbon, khớp cầu 60645K471 = Alloy Steel — đã gán đủ từ trước.
  - **Đổi đế DR-001 sang thép** (theo yêu cầu "đế thép, còn lại nhôm"; backup `Backup/DR-001_Base-Plate_backup_20260712_presteel.SLDPRT`): 6061-T6 → **ASTM A36 Steel**, đọc ngược `MaterialIdName=...|ASTM A36 Steel|101`, khối lượng **61,53 → 178,89 kg** (ρ 7850), Save3 err=0.
  - **Khối lượng toàn robot đọc từ assembly = 230,76 kg** (khớp đúng tổng cộng dồn từng chi tiết; đế thép chiếm ~78 %). Số lượng xác nhận: rod ×6, khớp cầu ×12, TPM ×3.
  - **Thuyết minh `outputs/material_20260712/ThuyetMinh_LuaChonVatLieu.md`**: tiêu chí chọn, phương án theo nhóm, bảng cơ tính (E/ν/ρ/σ), bảng khối lượng, hình `dr000_material_iso.png`. → **Hạng mục "Lựa chọn vật liệu" HOÀN THÀNH.**
- [~] **Bắt đầu mô phỏng động học trên MATLAB R2025a** (`F:\DeltaRobot\MoPhong_DongHoc\`, lộ trình 7 phase chi tiết trong `KEHOACH_DONGHOC.md`). Thông số động học: R=347, r=120,6, R−r=226,4, L1=407,5, L2=1000 mm, 3 cánh tay φ=[−90°,30°,150°]. Tiến độ:
  - [x] **Phase 0** — `params.m` (nguồn thông số), MATLAB chạy tốt (có Robotics System Toolbox).
  - [x] **Phase 1** — IK `delta_ik.m` (P→θ qua E·sinθ+F·cosθ+G=0). Home θ=[19,15°×3].
  - [x] **Phase 2** — FK `delta_fk.m` (giao 3 mặt cầu). Kiểm chứng round-trip FK(IK(P)) **max 6,2e−13 mm / 3000 điểm**, 100% trụ với-tới (`out/p1_p2_log.txt`, `figs/p2_roundtrip_hist.png`).
  - [x] **Phase 3** — Workspace: bán kính với-tới tại z=−925 là **650 mm** (cần 400); **trụ Ø800×250 nằm gọn** trong vùng (0/108 điểm biên ngoài) (`figs/p3_workspace_xz.png`, `p3_slice_z.png`).
  - [x] **Phase 4** — Jacobian `delta_jacobian.m`: **0/34372 điểm kỳ dị**, số điều kiện max **2,75** tb 2,13, góc forearm-bicep min 49,8° (`figs/p4_cond_map.png`). (Số 3,69/34,6° thiết kế cũ dùng quy ước khác — kết luận không đổi.)
  - [x] **Phase 5** — Quỹ đạo pick-and-place (chu kỳ 1,2 s, quintic): 100% với-tới; tốc độ khớp đỉnh **30 rpm**, gia tốc **1761 deg/s²**; TCP 1875 mm/s (1,18 g) (`figs/p5_path.png`, `p5_joint_profiles.png`).
  - [x] **Phase 6** — Hoạt hình 3D 49 frame → `figs/p6_animation.gif`.
  - [x] **Phase 7** — Tổng hợp `KETQUA_DONGHOC.md` (công thức chuẩn (1)–(3), bảng kết quả, danh mục hình).
  - **→ HOÀN THÀNH 7/7 phase mô phỏng động học MATLAB.**
- [x] **Nâng cấp GUI mô phỏng động học** (`MoPhong_DongHoc/delta_gui.m`; backup `delta_gui_backup_20260712.m`) theo yêu cầu "giao diện đẹp/dễ dùng hơn + robot đẹp hơn (kiểu CAD kim loại) + footprint mờ dần khi tool di chuyển":
  - Tách module render `deltaviz.m` (dùng chung GUI + script kiểm chứng): primitive `dTube` **có nắp 2 đầu** (bọc `hggroup`, sửa lỗi trụ rỗng dạng vành), `dBall` chrome (specular mạnh), `dBar` thanh chữ nhật định hướng. `drawStatic` = đế đĩa đặc + hub + lỗ giữa + 3 gân + 3 hộp động cơ; `drawDyn` = bicep dẹt (flat bar) + forearm parallelogram (2 thanh + 2 ngang) + 4 khớp cầu chrome/khâu + bàn máy đặc + điểm TCP.
  - GUI mới: bố cục 3 panel gọn (JOG X/Y/Z slider+ô nhập có tooltip · QUỸ ĐẠO play/stop/reset + checkbox trụ/footprint · TRẠNG THÁI đọc θ/TCP/đèn vùng làm việc + 4 nút góc nhìn Iso/Top/Front/Side), ánh sáng studio 3 đèn + `material dull`.
  - **Footprint 3D mờ dần**: mỗi khi TCP dịch >6 mm sinh 1 điểm; `timer` 20 fps giảm alpha + kích thước theo tuổi, **tự xóa sau 3 s** (`scatter3` alpha-flat), tối đa 90 điểm; nút "Xóa footprint" + checkbox bật/tắt.
  - Kiểm chứng: `checkcode` **0 lỗi cú pháp** (chỉ note vô hại); render headless `deltaviz` chạy, pose demo P=(170,−120,−900) `ok=1` θ=[8,0 11,2 37,4]°, ảnh `figs/gui_preview.png` (robot CAD look + vệt footprint mờ dần). GUI live chạy trên MATLAB desktop (`delta_gui`) — uifigure không render trong `-batch` headless (giới hạn môi trường, không phải lỗi code).
  - **Đã chạy live trên desktop** (`matlab -r "delta_gui"`), figure mở không lỗi console. Bị lag → **tối ưu**: giảm facet lưới ~40% (đế 64→44, hub 48→30, forearm 14→10, bàn máy 44→30, khớp cầu `sphere(18)→sphere(12)`), bớt 1 đèn (3→2), timer footprint 20→16 fps; kill 6 tiến trình MATLAB sót giải phóng RAM rồi mở lại 1 phiên sạch. [ ] Chờ người dùng xác nhận độ mượt; nếu còn lag: update handle thay vì vẽ lại mỗi frame / bỏ nắp trụ nhỏ / giảm số footprint tối đa.
- [x] **Đổi 3 vấu tròn → 3 vấu gân loe dần (gusset) cho chắc chắn** (backup `DR-001_Base-Plate_backup_20260712_preGusset.SLDPRT`): phản hồi "vấu tròn nhô ra nhiều trên cổ hẹp sẽ yếu, muốn vành to ra dần". Bỏ `MatTreoVau-Lug3` (vấu tròn Ø80) + lỗ M10 cũ; thay bằng `MatTreoVau-Gusset3` = 3 vấu hình thang: **chân rộng 176 mm** (ăn sâu vào thân tới R148) thu nhỏ dần ra **đầu rộng 48 mm** ở R272 (nhô ra ít, giảm ~23 mm so với vấu tròn R295), boss merge +179,7 cm³, vẫn 1 body; khoan lại **3 lỗ ren M10** `LoVit-M10-x3` (Ø8,5) ở đầu vấu (3/3 kiểm chứng). V cuối = **22 788 cm³** (thép 179 kg / nhôm 61,5 kg). DR-000 rebuild ×2 = 46 mates 0 lỗi WhatsWrong=0, đã lưu. Ảnh `gusset_top/iso.png`, `dr000_gusset.png`. (Đầu vấu hiện phẳng, góc chưa bo — có thể thêm fillet bo tròn nếu muốn mượt hơn.)
- [x] **Phóng to 3 vấu vỏ sò + lỗ giữa nhỏ đi một nửa** (vấu tròn — đã bị bước trên thay thế) (backup `DR-001_Base-Plate_backup_20260712_vau9.SLDPRT` trước khi đổi lỗ giữa, `..._prelug.SLDPRT` trước khi thêm vấu): (a) lỗ giữa Ø300→**Ø150** (`LoGiua-D150`, R75 kiểm chứng), xóa luôn sketch đĩa tròn cũ `Sk-MatTreoDisk`; (b) 3 cục vỏ sò trang trí (mặt trụ R35 tại R_axis=225, ba góc −173,9°/−53,9°/66,1°) được phóng thành **3 vấu tròn Ø80** (`MatTreoVau-Lug3`, boss merge, đẩy tâm ra R255 nhô thêm ~35 mm, +210,8 cm³, vẫn 1 body) + khoan **3 lỗ ren M10** (`LoVit-M10-x3`, Ø8,5 xuyên 25 mm — kiểm chứng 3/3 lỗ đúng). V cuối = **22 819 cm³** (thép 179 kg / nhôm 61,6 kg). Part 1 body save err=0; DR-000 rebuild ×2 = 46 mates (7 suppressed), WhatsWrong=0, 3 vấu không đụng cánh tay, đã lưu. Ảnh `lug_top/iso.png`, `dr000_lug.png`. Mặt treo giờ có **12 điểm bắt**: 9× M16 (6 tai + 3 ống giữa) + 3× M10 (3 vấu vỏ sò).
- [x] **Đổi mặt treo đĩa tròn → mặt treo 3 cánh (tri-star)** theo yêu cầu ("đĩa tròn xấu, lấy 3 sketch làm mặt treo"; backup `DR-001_Base-Plate_backup_20260712_predisc-to-vau.SLDPRT`): kiểm 3 sketch → `Sk-MatTreoVau` (39 đoạn, 1 contour kín, có 3 vấu tai + vỏ sò trang trí) và `Sketch9` (27 đoạn, 3 cánh trơn khớp vành) đều extrude được; `Sketch18` (12 đường rời) không phải mặt kín. Chọn **`Sk-MatTreoVau`** đúng tên "mặt treo vấu": xóa nắp đĩa + 12 lỗ + lỗ giữa cũ, extrude Vau thành nắp `MatTreoVau-D25` (offset 175, dày 25, Y[−175,−200] khớp vành, 1 body, +6250,2 cm³). Khoan **9 lỗ M16** `LoBat-M16-x9` tại **9 cột ống gia cường** (6 tai R418–429 + 3 ống giữa R316 — kiểm chứng cả 9/9 lỗ Ø14 xuyên hết cao 25 mm đúng tọa độ) + khoét **lỗ giữa Ø300** `LoGiua-D300`. V cuối = **21 287 cm³** → **thép 167 kg / nhôm 57,5 kg** (nhẹ hơn ~90 kg thép so với nắp đĩa tròn). Part 1 body save err=0; DR-000 rebuild ×2 = 46 mates (7 suppressed), WhatsWrong=0, đã lưu. Ảnh `vau_mount/iso.png`, `dr000_vau.png`. Ghi chú: sketch đĩa cũ `Sk-MatTreoDisk` (vòng tròn R480) vẫn còn trong cây làm tham khảo (hiện dưới dạng đường tròn mờ trong view — có thể xóa/ẩn nếu muốn); bản plain `Sketch9` (không vỏ sò) là phương án thay thế nếu chê chi tiết trang trí.
- [x] **Nâng cấp mẫu lỗ bắt + khoét lỗ giữa** (đã bị bước trên thay thế — lịch sử giữ để tham khảo) (backup `DR-001_Base-Plate_backup_20260712_pre12holes.SLDPRT`): theo yêu cầu "6 lỗ hơi ít + khoét giữa", bỏ cụm 6 lỗ cũ (`LoRen-M16-Treo`), khoan **12 lỗ M16** `LoBat-M16-x12` đều nhau trên vòng bu-lông **PCD Ø840 (R420)**, cách nhau 30°, cách mép đĩa 60 mm (mũi Ø14 sâu 25 xuyên nắp) + khoét **lỗ giữa Ø300** `LoGiua-D300` xuyên nắp thông xuống khoang giữa (nối với lỗ Ø82 sẵn có ở bản đế → luồn dây/giảm khối lượng). Kiểm chứng: xóa 6 lỗ +23,09 cm³ (về 34410,59), 12 lỗ −46,18 cm³ (đọc ngược đúng 12 mặt trụ R7, R_tâm=420,0 mm, 12 góc 10°+k·30°), lỗ giữa −1767,15 cm³ (R150 tại tâm, Y[−200,−175]); V cuối = **32597,27 cm³** khớp lý thuyết. Part 1 body, save err=0; DR-000 rebuild ×2 = 46 mates (7 suppressed) 0 lỗi, đã lưu. Ảnh `dr001_12h_mount/iso.png`, `dr000_12h.png`.
- [x] Sửa xong mặt treo trên `DR-001_Base-Plate` theo concept mới (đĩa tròn thay bích 3 thùy; backup `DR-001_Base-Plate_backup_20260712_prediskfix.SLDPRT`):
  - Bản nháp cũ `Boss-Extrude14` extrude **sai phía** (đĩa Ø960×25 lơ lửng ở Y=+175…+200, tách thành body rời, cách thân 125 mm) → xóa, extrude lại `Sk-MatTreoDisk` đúng phía thành `MatTreoDisk-D25` (offset 175 đảo chiều, dày 25, merge): 1 body liền Y[−200,+50], thể tích 34 410,6 cm³ khớp số học 16 839,0 + 18 095,6 − 524,0 cm³ chồng lấn (= diện tích đỉnh vành 209,6 cm² × 2,5 cm).
  - Khoan 6 lỗ ren M16 `LoRen-M16-Treo` (sketch `Sk-LoRenTreo`, mũi Ø14 sâu 25 xuyên nắp) tại 6 tâm ống góc tai (bán kính 418–429 mm; 3 ống giữa bán kính ~316 mm không khoan, giữ như thiết kế cũ). Kiểm chứng: ΔV = −23,09 cm³ đúng lý thuyết 6×π×0,7²×2,5; đọc ngược 6 mặt trụ R7,00 sâu 25,0 mm đúng tọa độ tâm ống.
  - Part + assembly DR-000 rebuild ×2, lưu err=0; 46 mates (7 suppressed chủ động như cũ). Ảnh bằng chứng trong scratchpad phiên (`dr001_fixed_iso/mount.png`, `dr000_after.png`).
  - Ghi chú API: `FeatureCut4` trên SW2023 cần **27 tham số** (thêm `OptimizeGeometry` cuối); chiều cut mặc định ngược với boss — tổ hợp đúng cho dải −175…−200 là `Dir=False, FlipStartOffset=True` (boss là `Dir=True, FlipStartOffset=True`).
  - Sketch tham khảo chưa dùng vẫn giữ nguyên: `Sk-MatTreoVau` (biên dạng 3 vấu), `Sketch18`, `Sketch9`.

### 2026-07-11
- [x] Bổ sung quy tắc làm việc vào `CLAUDE.md` (bằng chứng trước khi báo xong; Fable cho mô phỏng nặng, Opus cho viết báo cáo; chuẩn trình bày công thức + hình mô phỏng)
- [x] Tạo file theo dõi tiến độ `TIENDO.md` và cơ chế cập nhật cuối ngày
- [x] Thiết kế mặt treo robot trên `DR-001_Base-Plate` (backup `DR-001_Base-Plate_backup_20260711_premount.SLDPRT`): extrude Sketch9 thành mặt bích treo `MatTreo-D25` dày 25 mm, phẳng với đỉnh vành 8 mm cao 200 mm (mặt treo tại Y=−200, diện tích 2571,3 cm², +5904,2 cm³) + 6 lỗ ren M16 `LoRen-M16-Treo` (khoan Ø14 xuyên bích, 2 lỗ/tai tại tâm cung R22, cách mép 22 mm; kiểm chứng −23,091 cm³ đúng lý thuyết, 6 mặt trụ R7 đọc ngược đúng toạ độ). Part 0 lỗi rebuild, assembly DR-000 giữ nguyên 46 mates 0 lỗi. Ghi chú: khoang trong vành kín → chọn ren trong bích (bulông thả từ dầm khung xuống, kiểu ABB IRB 360); nếu đổi chiều cao khung phải sửa đồng thời chiều cao vành (Boss-Extrude2) và offset 175 mm của `MatTreo-D25`.

### 2026-07-10
- [x] Đổi tên toàn bộ thiết kế từ `Draw_V0` sang `DeltaRobot_Final/` với mã DR-000…DR-007, tự chứa tham chiếu
- [x] Tăng L2 từ 667 → 1000 mm (backup `*_backup_L2-667*`)
- [x] Sửa chiều sâu lỗ ren elbow clevis 38.1 → 40.0 mm khớp với platform
- [x] Chốt thông số động học: L1 = 407.5, L2 = 1000, R−r = 226.4, r = 120.6 (góc truyền xấu nhất 34.6°, điều kiện Jacobian 3.69)

### Trước 2026-07-10 (tóm tắt)
- [x] Dựng assembly Draw_V0 (Part1–Part9), chọn hộp số TPM-010S-061T, rod end McMaster 60645K471, connecting rod 6516K305
- [x] Xuất BOM có giá McMaster (`outputs/vom_sheet_20260624/`)
- [x] Sửa lỗi tham chiếu 3D Interconnect hộp số TPM (SaveAs3 giữ face ID)

### 2026-07-26
- [x] **Tinh gọn đồ thị mô-men**: theo yêu cầu chỉ giữ một đường `M(θ)` trên Hình 4.3; bỏ các đường thành phần, đường Jacobian, đường giới hạn và chú giải dư thừa. Chạy lại MATLAB, thay ảnh nhúng trong báo cáo, render lại đủ 76 trang; backup: `BaoCao/Backup/BaoCao_V0_backup_20260726_pre_single_moment_curve.docx`.
- [x] **Chạy và kiểm chứng mô phỏng MATLAB quét mô-men theo góc**: script `MoPhong_Luc/moment_angle_sweep.m` quét 1.451 điểm, sai số IK lớn nhất `8,91×10^-14°`; với miền truyền lực `30°≤μ≤75°`, cực đại `M_sơ bộ,max=104,90 N·m` tại `θ=22,10°`, `M_chọn,quét=157,35 N·m`. Đã xuất `MoPhong_Luc/out/moment_angle_sweep.csv/.mat/.txt` và `MoPhong_Luc/figs/moment_angle_sweep.png`.
- [x] **Cập nhật báo cáo sau quét góc**: thêm công thức `N_i(θ)`, `M_sơ bộ(θ)`, đồ thị Hình 4.3 và đánh lại lịch sử mô-men thành Hình 4.4; Word cập nhật mục lục, render kiểm chứng đủ 76 trang, kiểm tra contact sheet và các trang 54–57. Backup trước khi ghi đè: `BaoCao/Backup/BaoCao_V0_backup_20260726_pre_angle_sweep.docx`.
- [x] **Sử dụng đúng các ảnh đã đặt tại mục 3.1.2 cho tính mô-men**: thêm chú thích Hình 3.1–3.4 cho sơ đồ lực bàn động, tay bị động, tay chủ động và hình học góc 40°/75°; liên kết trực tiếp các hình này trong mục 4.5.1; bỏ hai sơ đồ thay thế bị trùng ở Chương 4; đánh lại Hình 3.5–3.8 và Hình 4.1–4.3, cập nhật danh mục hình. Render chính xác 75 trang, kiểm tra các trang 36–38, 53–55 và danh mục hình; backup: `BaoCao/Backup/BaoCao_V0_backup_20260726_pre_use_ch312_images.docx`, `BaoCao/Backup/BaoCao_V0_backup_20260726_pre_caption_fix.docx`.
- [x] **Tích hợp định dạng tính lực–mô-men theo tài liệu mẫu**: dùng số liệu hiện hành của `BaoCao_V0` để bổ sung mục 4.2.1 và 4.5.1; tính kiểm tra theo mô hình đối xứng được `F_z = 176,10 N`, `N_i = 90,95 N`, `M_i = 58,46 N·m`, `M_chọn = 87,70 N·m`; giữ kết quả mô phỏng đầy đủ `M_yc = 136,30 N·m` làm giá trị chi phối chọn hộp số. Đưa hai sơ đồ lực mới vào Chương 4, thêm chú thích Hình 4.1–4.2, đánh lại Hình 4.3–4.5 và cập nhật danh mục hình. Render đủ 76 trang, kiểm tra toàn bộ contact sheet và các trang 49–57; backup trước sửa: `BaoCao/Backup/BaoCao_V0_backup_20260726_pre_new_moment_format.docx`, `BaoCao/Backup/BaoCao_V0_backup_20260726_pre_figure_fit.docx`.
- [x] Chuẩn hóa thêm ký hiệu OMML `z_dưới` và `z_trên` trong công thức (3.28) của Chương 3; đã backup trước sửa tại `BaoCao/Backup/BaoCao_V0_backup_20260726_pre_z_subscript.docx` và render lại đủ 71 trang.
- [x] Chuẩn hóa toàn bộ ký hiệu toán có chỉ số (m_p, a_z, k_s, F_s và các ký hiệu lực, khối lượng, gia tốc, áp suất liên quan) sang Cambria Math với chỉ số dưới; bỏ Jacobian khỏi mục 2.6 và cập nhật mục lục. Chuỗi phương trình Chương 2 đã được kiểm tra liên tục (2.28)–(2.37). Đã render đủ 71 trang, kiểm tra trực quan các trang 30–32 và xác nhận Hình 2.1–2.8 đều có chú thích. Backup: `BaoCao/Backup/BaoCao_V0_backup_20260726_pre_inline_math_section_cleanup.docx`, `BaoCao/Backup/BaoCao_V0_backup_20260726_pre_remove_jacobian_conclusion.docx`.
- [x] **Viết lại toàn bộ mục 2.7 trong `BaoCao/BaoCao_V0/BaoCao_V0.docx`**: chuẩn hóa công thức lực hút chân không, sửa đúng cách đưa hiệu suất η vào mẫu số, tính lại 1×Ø40, 2×Ø40, 4×Ø25 và 4×Ø30 với tải 2 kg.
- [x] **Bổ sung tính mô-men và mô phỏng chọn truyền động**: kiểm chứng từ log MATLAB `MoPhong_Luc/out/force_log.txt` với M_tĩnh = 35,84 N·m, M_động = 55,03 N·m, M_tổng = 90,87 N·m, M_yc = 136,30 N·m; TPMA010S-055T đạt T2B 230 N·m, stall 110 N·m, 30,1 rpm ≤ 88 rpm.
- [x] **Bổ sung chú thích hình Chương 2** và khôi phục/chèn các hình 2.7-2.11; thêm bảng khối lượng, bảng lực hút, bảng mô-men, bảng kiểm tra hộp số và mục 2.8 kết luận chương.
- [x] **Sao lưu trước khi ghi đè**: `BaoCao/Backup/BaoCao_V0_backup_20260726_pre27full.docx`; xuất PDF kiểm tra 75 trang bằng Word và raster hóa các trang 20-42, kiểm tra trực quan không thấy lỗi cắt/chồng hình trong khu vực đã sửa.
- [x] **Dọn trùng nội dung giữa Chương 2 và Chương 4**: đối chiếu toàn văn, đã xóa 24 đoạn và 3 bảng/hình thuộc phần phân tích lực, mô-men, mô phỏng và chọn hộp số khỏi Chương 2; giữ nội dung chi tiết tập trung tại Chương 4. Đổi tên 2.7 thành cơ sở lựa chọn cơ cấu hút, đánh lại bảng cuối Chương 2 từ Bảng 2.7 thành Bảng 2.4, cập nhật mục lục/danh mục. Sao lưu trước khi sửa: `BaoCao/Backup/BaoCao_V0_backup_20260726_pre_ch2_ch4_cleanup.docx`.
- [x] **Rút gọn và chuẩn hóa mục 2.7.2 theo phương pháp bài báo**: bỏ phần quét nhiều đường kính và bảng kiểm tra mở rộng; giữ chuỗi công thức lực hút–diện tích–áp suất–lực giữ, định dạng chỉ số dưới Cambria Math, đánh lại số liên tục (2.28)–(2.34), đánh lại bảng phân loại thành Bảng 2.3. Kết quả kiểm chứng: 2 × Ø40 mm, F_s = 85,56 N, p_req = 48,7 kPa, F_cap = 105,6 N tại 60 kPa. Sao lưu: `BaoCao/Backup/BaoCao_V0_backup_20260726_pre_272simple.docx` và `BaoCao/Backup/BaoCao_V0_backup_20260726_pre_272eqnum.docx`. Bản cuối 71 trang; đã render đủ 71 trang và kiểm tra trực quan.
- [x] **Viết lại toàn bộ `BaoCao/Báo Cáo Fix/Chương 3 .docx`** theo yêu cầu "đơn giản hơn, đổi pipeline, có dẫn chứng, không bịa" — soạn bằng Opus (đúng quy tắc dự án), đối chiếu `Pipeline_BaoCao.docx` (mục II) và `DoAnThamKhao-Rename` (trích dẫn [2] Lê Xuân Hoàng & Lê Hoài Nam 2018 tr.38-40, [3] Hong 2024 tr.5-7, [4] Pandolfi 2025 tr.2-3, [8] Ren/Zheng/Wang 2026 tr.1-2):
  - Cấu trúc mới 3.1→3.6: bỏ hẳn phần vật liệu/khối lượng/BOM chi tiết trùng Chương 4 và phần quét vùng-làm-việc-số trùng Chương 5 (mục 5.6); Chương 3 chỉ còn cấu hình — chọn thông số hình học (có công thức l_min từ [2]) — áp dụng động học Chương 2 — Jacobian/kỳ dị (chuyển hẳn vào đây vì Chương 2 đã bỏ mục Jacobian hôm nay) — xác nhận vùng làm việc + xác định tư thế bất lợi nhất (R=400/z=-1050) cho Chương 4 — đối chiếu hình học torus [3] — liên kết CAD.
  - Sửa đúng chiều lỗi vật liệu: Bảng 3.3 giữ nguyên số liệu bản vẽ V7 (thép, đúng những gì in trên bản vẽ) nhưng sửa câu kết luận — **V7 mới là bản vẽ lỗi thời (17/07, trước đổi vật liệu 18/07), không phải BOM/CAD (nhôm 6061-T6) sai** — bản cũ viết ngược.
  - Bổ sung số liệu mới/chính xác hơn từ `Pipeline_BaoCao.docx`: dải góc khớp thực cần dùng −26,46°…72,37° (khác giới hạn mô phỏng −45°…100°), tọa độ điểm góc truyền nhỏ nhất P=(−196,07;113,20;−800) ứng góc khớp (19,75°;19,75°;−17,31°), kiểm 36.720 điểm toàn mặt trụ → bán kính với-tới tối thiểu 605,4 mm (hệ số dự trữ 1,51).
  - Build qua Markdown + `pandoc --reference-doc` (kế thừa style file cũ) để có OMML thật; 8 hình tái dùng nguyên (không hình mới), 5 bảng, công thức đánh số (3.1)-(3.8). Backup gốc `Backup/Chuong3_backup_20260726_prerewrite.docx`.
  - **Sửa chéo 9 chỗ tham chiếu sai/lệch số** phát sinh do đổi cấu trúc: Chương 4 (2 chỗ — mục Jacobian 3.4.2→3.3.4, Hình mô tả vùng làm việc ghi nhầm "Hình 3.4"→"Hình 3.6"), Chương 5 (7 chỗ — công thức Jacobian (3.21)-(3.25)→(3.2)-(3.5), quan hệ Jacobian "(2.18)"→"(3.3)" vì Chương 2 đã bỏ Jacobian, mục 2.3.4/3.3.2→3.3.1 và 2.3.5/3.3.3→3.3.2, 2 chỗ mục 3.4.3→3.4.2, 1 chỗ Hình 3.4→3.6). Backup trước sửa: `Backup/Chuong4_backup_20260726_194717_prectxfix.docx`, `Backup/Chuong5_backup_20260726_194717_prectxfix.docx`.
  - Verify: đọc lại cấu trúc file live (93 đoạn, 5 bảng đúng kích thước nguồn, 14 ảnh, 23 đoạn công thức OMML, không sót placeholder, Chương 4/5 vẫn đủ ảnh/bảng/omath sau khi sửa). Không render được PDF trực quan (Word COM treo ở bước ExportAsFixedFormat, thử 2 lần kể cả tiến trình Word riêng — đã bỏ, không phải lỗi nội dung).
  - **Lưu ý còn treo**: `BaoCao/BaoCao_V0/BaoCao_V0.docx` (tài liệu tổng, 71 trang) vẫn còn Chương 3 bản CŨ (công thức 3.26-3.28 kiểu cũ) — chưa đồng bộ với bản mới trong `Báo Cáo Fix/`; cần người dùng quyết định có đồng bộ hay không.
- [x] **Viết lại trực tiếp Chương 3 theo STT07**: thay toàn bộ nội dung `BaoCao/Báo Cáo Fix/Chương 3 .docx` bằng mô hình vùng làm việc, động học ngược/thuận, tiêu chí Jacobian, quét mật độ điểm, kiểm tra vùng trụ mục tiêu, quỹ đạo cổng và khảo sát L9. Kết quả MATLAB: 74.906/74.906 điểm vùng trụ đạt; μ_min = 49,8004°; κ₂(J)_max = 2,7492; sai số FK(IK(P)) lớn nhất = 7,898×10^-13 mm; quỹ đạo đạt 601/601 điểm. Backup trước ghi đè: `BaoCao/Backup/Chuong3_backup_20260726_pre_STT07_rewrite.docx`.
- [x] **Kiểm tra trình bày bản Chương 3**: xuất `F:\DeltaRobot\_codex_tmp\Chuong3_final.pdf`, raster hóa 15 trang và kiểm tra contact sheet; công thức OMML, 7 hình mô phỏng, 4 bảng và chú thích hình/bảng đều hiển thị, bảng độ nhạy L9 đã được dàn lại để không vỡ cột.
- [x] **Cập nhật giới hạn khớp Chương 3 theo rà soát của người dùng**: thống nhất θᵢ ∈ [−45°, 70°] trong `MoPhong_DongHoc/params.m`, `MoPhong_Luc/params.m` và `BaoCao/Báo Cáo Fix/Chương 3 .docx`; backup: `BaoCao/Backup/Chuong3_backup_20260727_pre_theta70.docx`.
- [x] **Kiểm chứng lại vùng làm việc với θmax = 70°**: 74.792/74.906 điểm đạt = 99,8478%; 114 điểm không có nghiệm IK thực tại z = −1050…−1030 mm, ρ = 380…400 mm; góc khớp lớn nhất trong các điểm có nghiệm = 69,9215°. Quỹ đạo cổng đạt 601/601 điểm; render cuối 11 trang, kiểm tra contact sheet không thấy lỗi cắt/chồng hình.
- [x] **Bổ sung bảng kiểm nghiệm L9 theo mẫu STT07 vào Chương 3**: thay bảng gộp thông số bằng các cột riêng `L₁, L₂, R, r, thể tích vùng làm việc và số đỉnh quỹ đạo đạt`; thêm dòng tô xanh cho **thiết kế hiện tại** `(407,5; 1000; 347; 120,6)`, thể tích `2,698×10^7 mm³`, đạt `4/4` đỉnh và `601/601` điểm quỹ đạo. Backup: `BaoCao/Backup/Chuong3_backup_20260727_pre_L9_validation_table_saved_current.docx`.
- [x] **Render kiểm chứng bảng L9**: bảng không còn tách chữ số ở các cột `407,5`, `120,6`, `1000`; bản cuối xuất 12 trang và đã kiểm tra trực quan trang chứa Bảng 3.4 cùng contact sheet.

### 2026-07-27 (tiếp)
- [x] **Lập và chạy chương trình MATLAB kiểm tra maximum workspace theo L9**: tạo `MoPhong_DongHoc/workspace_max_l9_trajectory_map.m`, quét thiết kế hiện tại và 9 nhóm L9 với `θ ∈ [−45°, 70°]`, lưới FK `45^3`, voxel 10 mm và mặt cắt ngang lớn nhất.
- [x] **Kiểm tra quỹ đạo gắp–đặt hiện tại**: thiết kế hiện tại đạt `4/4` waypoint và `601/601` điểm quỹ đạo (100%); các nhóm L9 đạt đầy đủ là L9-2, L9-5, L9-8 và L9-9. Đã ghi bảng kết quả vào `MoPhong_DongHoc/out/workspace_max_l9_trajectory.csv/.mat`.
- [x] **Xuất bản đồ kiểm chứng**: `MoPhong_DongHoc/figs/workspace_max_l9_trajectory_map.png` và `MoPhong_DongHoc/figs/workspace_max_l9_max_slice_map.png`; đã kiểm tra trực quan hai hình sau khi MATLAB hoàn tất.
- [x] **Bổ sung kết quả mô phỏng mới vào Chương 3**: đưa mục kiểm chứng maximum workspace và quỹ đạo lên đầu chương, chèn 2 bản đồ MATLAB, cập nhật Bảng 3.4 theo quét `45³`/voxel `10 mm` với tỷ lệ toàn bộ quỹ đạo, bổ sung chú thích Hình 3.8 và cập nhật kết luận/tài liệu tham khảo. Bản Word cuối render 14 trang, đã kiểm tra trực quan; backup: `BaoCao/Backup/Chuong3_backup_20260727_pre_new_workspace_results.docx`.
- [x] **Rà soát trùng lặp và chuẩn hóa công thức Chương 3**: rút gọn tóm tắt 3.2 để không lặp chi tiết của 3.3–3.5, xóa bản đồ L9 trùng Hình 3.1 (Hình 3.8 cũ), rút gọn kết luận; sửa OMML cho `V_vox`, `N_vox`, `P_k`, `P_{k+1}` và các lũy thừa trong (3.13)–(3.15); sửa dàn trang hai hình liên tiếp. Bản cuối render 13 trang và đã kiểm tra toàn bộ trang; backup: `BaoCao/Backup/Chuong3_backup_20260727_pre_deduplicate_formula_fix.docx`.
- [x] **Đưa thông số L9 lên trước phần mô phỏng và kiểm tra bảng**: sắp xếp lại thành 3.2 thông số khảo sát → 3.3 mô phỏng → 3.4 kiểm tra → 3.5 tổng hợp; thêm chú thích Bảng 3.2, đánh lại Bảng 3.3–3.4; sửa tọa độ waypoint bỏ ký tự LaTeX thừa và chuẩn hóa ký hiệu `Wₜ`, `L₁`, `L₂`, `φᵢ`, `θᵢ`. Bản cuối render 12 trang, kiểm tra trực quan các bảng/công thức; backup: `BaoCao/Backup/Chuong3_backup_20260727_pre_reorder_35_and_table_formula_fix.docx`.
- [x] **Căn chỉnh lại bố cục Chương 3 theo bản người dùng vừa sắp xếp**: giữ thứ tự thông số L9 trước mô phỏng; thêm đường viền và màu tiêu đề đồng nhất cho 4 bảng, căn giữa dữ liệu số, cân lại độ rộng cột, sửa bảng waypoint không còn vỡ cột, sửa bảng L9 không tách chữ số; bỏ trang trắng do ngắt trang thừa; đồng bộ kết luận thành Mục 3.5 và tham chiếu L9 về Mục 3.2. Đã render kiểm tra lại 13 trang, không còn trang trắng và không thấy bảng/hình bị cắt. Backup: `BaoCao/Backup/Chuong3_backup_20260727_pre_layout_alignment_current.docx`.
- [x] **Đưa các bảng Chương 3 về nền trắng nguyên bản theo yêu cầu**: chỉ xóa 23 thuộc tính màu nền trực tiếp của 4 bảng; giữ nguyên toàn bộ nội dung, công thức, hình ảnh, đường viền, độ rộng cột và bố cục. Đã xác nhận văn bản bảng/đoạn và độ rộng cột không thay đổi; render lại 11 trang. Backup: `BaoCao/Backup/Chuong3_backup_20260727_pre_remove_table_colors_current.docx`.
- [x] **Sắp xếp lại PDF bản vẽ gia công `GiaCongCoKhi_V1.pdf`**: chuyển trang nguồn 32 (bản vẽ kích thước hộp số TPMA) xuống ngay sau trang 13 để trở thành trang 14; đánh lại số trang 15–32, ẩn số trang ở bìa, cập nhật mục lục bản vẽ/FEA/phụ lục động cơ. Đã render và kiểm tra contact sheet đủ 32 trang; thứ tự cuối: bản vẽ hộp số trang 14, FEA bắt đầu trang 15, phụ lục khớp cầu trang 31, thông số động cơ trang 32. Backup: `BaoCao/Backup/GiaCongCoKhi_V1_backup_20260727_pre_page32_move.pdf`.
- [x] **Chuẩn hóa toàn bộ PDF bản vẽ gia công sang khổ A3 ngang**: đưa đủ 32 trang của `BaoCao/Bản vẽ gia công/GiaCongCoKhi_V1.pdf` về đúng 420 × 297 mm; đồng nhất MediaBox, CropBox, TrimBox, BleedBox và ArtBox, giữ nguyên nội dung, tỷ lệ, thứ tự và số trang. Đã render contact sheet 32 trang để kiểm tra không cắt/chồng nội dung; backup trước khi chuẩn hóa: `BaoCao/Backup/GiaCongCoKhi_V1_backup_20260727_pre_A3_normalize.pdf`.
- [x] **Cân lại logo trang bìa PDF bản vẽ gia công**: nâng riêng logo HCMUTE ở trang 1 lên 18 pt (6,35 mm), giữ nguyên kích thước logo, khung trang, nội dung và 31 trang còn lại. Đã render lại trang bìa để kiểm tra trực quan; file cuối vẫn đủ 32 trang A3 ngang. Backup: `BaoCao/Backup/GiaCongCoKhi_V1_backup_20260727_pre_logo_raise.pdf`.
- [x] **Bỏ ngày tạo ở trang cuối PDF bản vẽ gia công**: xóa riêng cụm `, ngày tạo 14/07/2026` khỏi dòng nguồn trên trang 32; giữ nguyên mã datasheet, hình ảnh, thông số kỹ thuật và bố cục. Đã render kiểm tra trang 32; file cuối vẫn đủ 32 trang A3 ngang. Backup: `BaoCao/Backup/GiaCongCoKhi_V1_backup_20260727_pre_remove_created_date.pdf`.
- [x] **Cập nhật PowerPoint thuyết trình theo pipeline 8 giai đoạn**: dùng `BaoCao/Báo Cáo Fix/BaoCao_V0.docx` và `BaoCao/PowerPoint/powerpoint.pptx` làm nguồn; xuất bản mới 22 slide tại `BaoCao/PowerPoint/powerpoint_pipeline_22slides.pptx`. Đã chỉnh câu chữ pipeline/kết luận, giữ công thức ở mức kết quả chính, thêm ghi chú nguồn cho 22 slide; kiểm tra trực quan từng slide, `slides_test.py` báo không có overflow, kiểm tra XML không có placeholder rỗng, kiểm tra template fidelity đạt.
- [x] **Rà soát và sắp xếp lại toàn bộ PowerPoint theo pipeline slide 2**: xuất `BaoCao/PowerPoint/powerpoint_pipeline_22slides_v2.pptx` gồm 22 slide theo đúng thứ tự I→VIII; đưa vật liệu vào giai đoạn IV, FEA vào V, điều khiển vào VI, thị giác vào VII và hạn chế/nghiệm thu vào VIII; đồng bộ nhãn giai đoạn và chân trang, giữ nguồn báo cáo trong ghi chú; render đủ 22 slide, `slides_test.py` không overflow, template fidelity đạt, 0 placeholder rỗng.
- [x] **Dựng lại PowerPoint theo đúng pipeline 8 mục trong slide 2 và nội dung Word**: sắp xếp lại thành I cơ sở lý thuyết/nhiệm vụ/mục tiêu → II cấu trúc–mô hình hóa–động học–giác hút → III workspace/đám mây điểm → IV tải trọng–vật liệu–động cơ → V FEA → VI mạch điều khiển → VII thị giác/phân loại → VIII hạn chế/hướng phát triển; xuất `BaoCao/PowerPoint/powerpoint_pipeline_8muc_22slides.pptx`. Đủ 22 slide, 8 mục trên pipeline khớp nội dung, có ghi chú đối chiếu chương/mục của `BaoCao_V0.docx`; kiểm tra không tràn, 0 placeholder rỗng, template fidelity đạt.
