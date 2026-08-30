# Delta Robot Design — Thiết kế cơ khí robot Delta 3 bậc tự do

> Đồ án tốt nghiệp — Trường Đại học Sư phạm Kỹ thuật TP.HCM (HCMUTE)
> Thiết kế cơ khí hoàn chỉnh cho một robot song song kiểu Delta treo trần, ứng dụng gắp – đặt tốc độ cao (tham chiếu ABB IRB 360 FlexPicker).

Repository gồm mô hình CAD SolidWorks, chương trình tính toán – mô phỏng MATLAB, kết quả mô phỏng bền (FEA), bản vẽ gia công và bộ thuyết minh đồ án. Mọi kết luận trong báo cáo đều được chứng minh bằng số liệu đọc lại từ mô hình / kết quả solver, không dùng giá trị giả định.

---

## 1. Thông số mục tiêu

| Đại lượng | Giá trị |
|---|---|
| Tải trọng công tác (payload) | **2 kg** |
| Vùng làm việc | trụ **Ø800 × 250 mm**, tâm cách mặt phẳng vai ~925 mm |
| Chu kỳ gắp – đặt | 1,2 s (quỹ đạo bậc 5) |
| Vận tốc TCP đỉnh | ~1875 mm/s (~1,18 g) |
| Vận tốc khớp đỉnh | ~30 vòng/phút |
| Kiểu lắp | treo trần (hang-from-frame) |

## 2. Thông số động học (đã chốt)

| Ký hiệu | Ý nghĩa | Giá trị |
|---|---|---|
| L1 | cánh tay trên (trục vai → đường tâm cầu khuỷu) | 407,5 mm |
| L2 | cẳng tay (tâm cầu ↔ tâm cầu) | 1000,0 mm |
| R − r | bán kính đế − bán kính bàn máy động | 226,4 mm |
| r | bán kính bàn máy động | 120,6 mm |

**Kiểm chứng (MATLAB R2025a):** round-trip FK(IK(P)) sai số lớn nhất 6,2·10⁻¹³ mm trên 3000 điểm; Jacobian **không có điểm kỳ dị** trong vùng làm việc, số điều kiện lớn nhất 2,75 / trung bình 2,13; góc truyền cẳng tay – cánh tay nhỏ nhất 49,8°.

## 3. Kết cấu & vật liệu

- **Toàn bộ chi tiết gia công: nhôm 6061-T6.** Đế robot ban đầu thiết kế bằng thép ASTM A36 nhưng quá nặng nên đã chuyển sang nhôm (giảm 128,8 kg).
- Thanh nối (cẳng tay): sợi carbon. Khớp cầu (rod end `60645K471`): thép hợp kim.
- Hộp số – động cơ: **Wittenstein TPMA010S-055T** (dòng TPM⁺ high-torque, tỉ số truyền i = 55).
- Khối lượng toàn robot: **122,4 kg** (mô hình CAD); ≈ 140 kg thực tế sau khi hiệu chỉnh khối lượng hộp số nhập khẩu.

## 4. Kết quả phân tích lực & mô phỏng bền

| Hạng mục | Kết quả |
|---|---|
| Lực đầu công tác F_ee | 175,8 N |
| Lực cặp cẳng tay (một tư thế) | 122,7 N — đa tư thế xấu nhất **182,4 N** (biên dưới R400 / z−1050) |
| Mô-men uốn cánh tay | ~50 N·m — đa tư thế xấu nhất **74,3 N·m** |
| Mô-men yêu cầu tại trục khớp M_yc | 136,3 N·m ≤ T2B 230 N·m → **dư 1,69×** |
| Mô-men hiệu dụng M_rms | 53,4 N·m ≤ 110 N·m → **dư 2,06×** |
| Tốc độ khớp | 30,1 ≤ 88 vòng/phút |
| **FEA — hệ số an toàn nhỏ nhất toàn robot** | **7,1** (chi tiết DR-006), quét toàn bộ vùng làm việc |

Phương pháp M_yc = (M_tĩnh + M_động) × hệ số an toàn 1,5, có kể trọng lượng và quán tính cánh tay trên (6,9 kg từ CAD) cùng quán tính rotor quy đổi J_mot·i² — theo yêu cầu giảng viên hướng dẫn.

---

## 5. Quy trình thiết kế (pipeline 8 giai đoạn)

Toàn bộ đồ án — bao gồm bố cục báo cáo (`BaoCao/`) và bộ bản vẽ gia công (`BanVe_GiaCong/`) — bám theo pipeline tuyến tính sau; mỗi giai đoạn nhận đầu ra của giai đoạn trước và kết luận theo mức **đạt / đạt có điều kiện / chưa đánh giá**.

| # | Giai đoạn | Nội dung | Sản phẩm |
|---|---|---|---|
| **I** | Cơ sở lý thuyết – nhiệm vụ – mục tiêu | tổng quan robot Delta, phát biểu bài toán, chốt thông số mục tiêu | Chương 1 báo cáo |
| **II** | Thiết kế hình học & thông số động học | chọn L1, L2, R−r, r theo vùng làm việc Ø800×250; kiểm góc truyền / số điều kiện | `MoPhong_DongHoc/params.m`, Chương 2 |
| **III** | Động học thuận / nghịch & Jacobian | dựng và kiểm chứng IK/FK (round-trip ~10⁻¹³ mm), phân tích kỳ dị | `delta_ik.m`, `delta_fk.m`, `delta_jacobian.m`, `p4_singularity.m` |
| **IV** | Mô phỏng động học & quỹ đạo | vùng làm việc, quỹ đạo bậc 5, mô hình Simulink 6 khối, hoạt ảnh | `p3_workspace.m`, `p5_trajectory.m`, `p6_animate.m`, `delta_kinematics.slx` |
| **V** | Phân tích lực & động lực học | sơ đồ phân bố lực, biểu đồ nội lực N/Q/M, quét tải đa tư thế toàn vùng làm việc | `MoPhong_Luc/force_analysis.m`, `force_diagrams.m`, `force_poses.m` |
| **VI** | Lựa chọn động cơ – hộp số | điều kiện M_yc / M_rms / tốc độ; loại phương án TPM-010S-061T (không đạt), chốt TPMA010S-055T | `MoPhong_Luc/ThuyetMinh_ChonDongCo.md` |
| **VII** | Lựa chọn vật liệu & mô phỏng bền FEA | chọn nhôm 6061-T6; FEA 5 chi tiết chịu lực chính + hội tụ lưới + quét đa tư thế | `MoPhong_Ben/KETQUA_BEN.md`, `KETQUA_BEN_DAPOSE.md` |
| **VIII** | CAD lắp ráp, bản vẽ gia công & BOM | hoàn thiện `DR-000`, xuất bản vẽ A3 chiếu góc thứ nhất (TCVN) cho 8 chi tiết tự chế, lập BOM | `DeltaRobot_Final/`, `BanVe_GiaCong/` |

---

## 6. Cấu trúc repository

```
DeltaRobot_Final/      Mô hình CAD đang hoạt động (SolidWorks 2023)
                       DR-000_Delta-Robot_V0.SLDASM — lắp tổng
                       DR-001…DR-007 — chi tiết tự chế (DR-001 tách 3 file)
                       Frame.SLDPRT — khung thép treo robot
                       + hộp số TPMA, thanh nối, khớp cầu

MoPhong_DongHoc/       Mô phỏng động học (MATLAB R2025a + Robotics System Toolbox)
                       params.m • delta_ik/fk/jacobian.m • p3…p6 • delta_gui.m
                       delta_kinematics.slx (Simulink) • figs/ • KETQUA_DONGHOC.md

MoPhong_Luc/           Phân tích lực & lựa chọn động cơ (MATLAB)
                       force_analysis.m • force_poses.m • force_diagrams.m
                       ThuyetMinh_ChonDongCo.md

MoPhong_Ben/           Mô phỏng bền FEA (SolidWorks Simulation qua COM)
                       fea_run*.ps1 • figs/ • KETQUA_BEN.md • KETQUA_BEN_DAPOSE.md
                       THUYETMINH_MOPHONG_BEN_CHITIET.md
                       (file .CWR/.LOG solver không đưa lên — tái sinh được)

BanVe_GiaCong/         Bản vẽ gia công 8 chi tiết tự chế
                       BanVe_ChinhSua_V7/ — .SLDDRW + .pdf (A3, chiếu góc 1, TCVN)
                       make_drawing*.ps1 — script tái sinh bản vẽ

TIENDO.md            Nhật ký tiến độ theo ngày
CLAUDE.md           Ghi chú quy trình & công cụ automation
```

> Quyển thuyết minh đồ án (`BaoCao/` — DOCX/PDF/PPTX) **không** đưa lên repo; nội dung cốt lõi đã tóm tắt trong README này.

## 7. Công cụ

| Việc | Công cụ |
|---|---|
| CAD & lắp ráp | SolidWorks 2023 SP3 (tự động hóa qua COM / PowerShell) |
| FEA | SolidWorks Simulation (COM) — hội tụ lưới, quét đa tư thế |
| Động học / lực / quỹ đạo | MATLAB R2025a (+ Robotics System Toolbox), Simulink |
| Xuất tài liệu | pandoc (Markdown → OMML/DOCX), PyMuPDF (ghép & hiệu chỉnh PDF) |

## 8. Không bao gồm trong repo

Vì lý do bản quyền và dung lượng, các nội dung sau **không** được đưa lên (xem `.gitignore`):

- Quyển thuyết minh đồ án (`BaoCao/` — báo cáo DOCX/PDF, slide PPTX).
- Papers nghiên cứu tham khảo, catalog ABB IRB 360 (`DeltaRobot_Document/`).
- CAD & catalog hãng Wittenstein (`Catalog_Wittenstein/`), CAD linh kiện mua sẵn McMaster-Carr (`LinhKien/`).
- File kết quả solver FEA `.CWR` / `.LOG` (~13 GB, tái sinh được từ script trong `MoPhong_Ben/`).
- Cache dựng Simulink (`slprj/`), ảnh preview `.bmp`, các bản backup `*_backup_*`.

## 9. Bản quyền & sử dụng

Đây là công trình học thuật (đồ án tốt nghiệp). Mã nguồn tính toán và mô hình do tác giả thực hiện; giữ toàn bộ quyền. Được phép tham khảo cho mục đích học tập, nghiên cứu phi thương mại; vui lòng trích dẫn khi sử dụng lại. Tên thương mại và CAD của các hãng thứ ba thuộc về chủ sở hữu tương ứng.

**Tác giả:** JohnNguyen205 — HCMUTE.
