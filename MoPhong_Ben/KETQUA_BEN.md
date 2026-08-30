# KẾT QUẢ MÔ PHỎNG BỀN (FEA) — DELTA ROBOT

**Ngày:** 2026-07-13 (bản thép) · **cập nhật 2026-07-18** (đế đổi sang **nhôm 6061-T6**, tách 3 khối, probe lại mặt)
**Phần mềm:** SolidWorks Simulation 2023 SP3 (bài toán tĩnh tuyến tính)
**Tải trọng thiết kế:** payload = 2 kg · **Nguồn tải:** phân tích lực `MoPhong_Luc/force_analysis.m`
**Tự động hóa:** COM (`MoPhong_Ben/fea_run.ps1` + `fea_common.ps1` + `run_parts.ps1`), lưới hội tụ 3 kích thước/chi tiết.

---

## 1. Mục tiêu

Kiểm bền **5 chi tiết chịu lực chính** của robot dưới **tải đỉnh động** (chu kỳ pick-and-place 1,2 s,
gia tốc TCP ~1,18 g), theo phương pháp **nghiên cứu hội tụ lưới** (mesh convergence): mỗi chi tiết
giải với 3 kích thước phần tử từ thô đến mịn, đọc ngược ứng suất von Mises lớn nhất và chuyển vị,
tính **hệ số an toàn** FOS = σ_chảy / σ_vonMises.

> **Thay đổi vật liệu đế (2026-07-18):** đế robot trước đây bằng thép ASTM A36 rất nặng
> (196,3 kg cho 3 khối). Theo yêu cầu giảm khối lượng, **cả 3 khối đế đổi sang nhôm 6061-T6**
> (σ_chảy 275 MPa): DR-001-1 tấm đế 99,3→34,1 kg · DR-001-2 khung hàn 31,7→10,9 kg ·
> DR-001-3 mặt treo 65,4→22,5 kg — **giảm 128,8 kg**. FEA dưới đây **chứng minh đế nhôm vẫn dư bền**.
> Đế nay tách thành 3 file (xem `outputs/tach3link_20260717/`): FEA chạy trên 2 khối chịu lực
> chính là **DR-001-1 (tấm đế gắn tay)** và **DR-001-3 (mặt treo — treo cả robot)**; khối
> **DR-001-2 (khung hàn)** nằm giữa hai khối trên trên đường truyền lực gián tiếp, ứng suất thấp,
> không giải riêng ở lần chạy này. **Cập nhật 2026-07-22: DR-001-2 đã được giải riêng — xem mục 8.**

## 2. Tải trọng đỉnh (từ phân tích lực, payload 2 kg)

| Đại lượng | Ký hiệu | Giá trị |
|---|---|---|
| Lực đầu công tác | F_ee | 175,8 N |
| Lực cặp cẳng tay (2 thanh) | F_forearm | 122,7 N (61,3 N/thanh) |
| Momen khớp vai | τ | 48,4 N·m |
| Uốn bắp tay (bicep) | M_bicep | ~50 N·m |
| Tải treo trần (mặt treo) | — | ~2097 N = trọng lượng robot ~140 kg × 9,81 × hệ số 1,5 |

## 3. Điều kiện biên đặt cho từng chi tiết

Ngàm và tải đặt lên **mặt** đã nhận diện qua hình học thực (bán kính trụ / pháp tuyến mặt phẳng /
tọa độ tâm — xem `out/faces_*.txt` ngày 2026-07-18; chỉ số mặt đã probe lại sau khi tách 3 khối đế
+ dọn đối xứng nên khác bản 07-13). Lực đặt hướng theo mặt tham chiếu.

| Chi tiết | Vật liệu (σ_chảy) | Ngàm | Tải đặt | Độ lớn |
|---|---|---|---|---|
| **DR-006** Elbow-Clevis | 6061-T6 (275 MPa) | trụ ngõng R24 + mặt lưng z=−12,5 | 2 lỗ rod R7,94 | 122,7 N (−Y) |
| **DR-005-2** Upper-Arm-Link | 6061-T6 (275 MPa) | bore vai R22,5 + mặt đầu y=+150 | bore khuỷu R22,5 y=−135 | 185 N (≈ uốn 50 N·m) |
| **DR-007** Moving-Platform | 6061-T6 (275 MPa) | 6 lỗ khớp cầu R7,94 | 6 lỗ bắt tool R6 | 175,8 N (−Y) |
| **DR-001-1** Tấm đế gắn tay | 6061-T6 (275 MPa) | mặt hàn đáy Y=0 | 6 lỗ bắt bracket R8,75 | 600 N (+Y) |
| **DR-001-3** Mặt treo | 6061-T6 (275 MPa) | 9 lỗ M16 + 6 lỗ M20 (ren trần) | 9 lỗ M12 xuyên | ~2097 N |

Lưới: phần tử khối tứ diện bậc 2 (solid parabolic), dung sai = kích thước/20.

## 4. Kết quả hội tụ lưới

### 4.1 DR-006 — Elbow-Clevis (ngàm ngõng R24 + mặt lưng; tải 2 lỗ rod)

| Phần tử (mm) | σ von Mises (MPa) | Chuyển vị (mm) | FOS |
|---|---|---|---|
| 8 | 24,415 | 0,065 | 11,3 |
| 5 | 22,653 | 0,065 | 12,1 |
| 3 | 26,085 | 0,066 | 10,5 |

Điều kiện biên probe lại đúng hơn bản 07-13 (chỉ tải **đúng 2 lỗ rod**, không tải nhầm cả mặt ngõng)
→ ứng suất cao hơn nhưng vẫn rất an toàn. **FOS bảo thủ ≈ 10,5.** Hình: `figs/fea_dr006_vonMises.png`.

### 4.2 DR-005-2 — Upper-Arm-Link (bắp tay, ngàm đầu vai — tải uốn đầu khuỷu)

| Phần tử (mm) | σ von Mises (MPa) | Chuyển vị (mm) | FOS |
|---|---|---|---|
| 12 | 4,248 | (xem ghi chú) | 64,7 |
| 8 | 2,696 | — | 102,0 |
| 5 | 3,679 | — | 74,8 |

σ đỉnh dao động (kỳ dị cục bộ ở mép bore ngàm). **FOS bảo thủ ≈ 65.** Hình: `figs/fea_dr005b_vonMises.png`.
Chuyển vị thật ≈ **0,008 mm** (khớp giải tích dầm côngxôn 0,007 mm; giá trị 7,86 mm API đọc là
**spike một nút số**, đã loại).

### 4.3 DR-007 — Moving-Platform (ngàm 6 khớp cầu — tải payload ở tâm)

| Phần tử (mm) | σ von Mises (MPa) | Chuyển vị (mm) | FOS |
|---|---|---|---|
| 12 | 17,082 | 0,350 | 16,1 |
| 8 | 18,710 | 0,352 | 14,7 |
| 5 | 11,889 | 0,354 | 23,1 |

σ đỉnh ở mép lỗ chịu tải chưa bo (số học). Chuyển vị hội tụ tốt ~0,35 mm. **FOS bảo thủ ≈ 14,7.**
Hình: `figs/fea_dr007_vonMises.png`.

### 4.4 DR-001-1 — Tấm đế gắn tay (NHÔM, ngàm mặt hàn đáy — tải 6 lỗ bracket)

| Phần tử (mm) | σ von Mises (MPa) | Chuyển vị (mm) | FOS |
|---|---|---|---|
| 20 | 0,145 | 0,034 | 1890 |
| 14 | 0,125 | 0,034 | 2208 |
| 10 | 0,128 | 0,034 | 2144 |

Tấm đế 50 mm rất dày, ngàm dọc toàn bộ mặt hàn đáy → ứng suất cực nhỏ. **FOS ≈ 1900.**
Đế nhôm thay thép hoàn toàn thừa bền ở khối này. Hình: `figs/fea_dr001_1_vonMises.png`.

### 4.5 DR-001-3 — Mặt treo (NHÔM, khối treo cả robot — QUAN TRỌNG NHẤT)

| Phần tử (mm) | σ von Mises (MPa) | Chuyển vị (mm) | FOS |
|---|---|---|---|
| 12 | 3,270 | (spike, xem ghi chú) | 84,1 |
| 8 | 3,298 | — | 83,4 |
| 5 | 3,844 | — | 71,5 |

Ngàm 15 lỗ ren trần (9×M16 + 6×M20), tải toàn bộ trọng lượng robot ~140 kg × 1,5 phân bố vào 9 lỗ
M12. Dù mang toàn bộ tải treo, ứng suất chỉ ~3,3–3,8 MPa. **FOS bảo thủ ≈ 71,5 → đế treo nhôm AN
TOÀN, không cần giữ thép hay thêm gân.** Hình: `figs/fea_dr001_3_vonMises.png` (deform scale 13 248×
→ chuyển vị thật rất nhỏ; giá trị URES ~5,9 mm API đọc là spike một nút số ở mép ngàm — không nhất
quán với ứng suất 3,8 MPa nên là nhiễu, ưu tiên σ/FOS).

> **Xác minh lại 2026-07-23** (phiên trước bị tắt cửa sổ giữa chừng lúc đang chạy lại 3 study,
> nghi ngờ dữ liệu FEA bị nhiễm — backup `Backup/DR-001-3_Mat-Treo_FEA_backup_20260723_feacontam.SLDPRT`).
> Đọc ngược qua COM (bind vào tiến trình SolidWorks đang mở, `SetActiveStudy` từng study rồi đọc
> `GetMinMaxStress`, đối chiếu node count với `.LOG` gốc, đối chiếu 15 mặt fix + 9 mặt load thực tế
> trong `Fixed-1`/`Force-1` với hình học part): **cả 3 study sạch, không nhiễm document/study khác**
> — node count khớp chính xác log (87 888/239 041/811 064), mặt fix/load khớp 100% hình học
> `DR-001-3`, FOS 84,1/83,4/71,5 giữ nguyên như bảng trên. Nguyên nhân các dấu hiệu bất thường ban đầu
> (file `.MAS` + thư mục scratch còn ghi sau khi `.SLDPRT` đã lưu) chỉ là hậu xử lý solver bị cắt
> ngang do đóng terminal, KHÔNG ảnh hưởng dữ liệu đã nhúng. `GetSaveFlag=False` — file trên đĩa sạch,
> không cần chạy lại.

## 5. Tổng hợp hệ số an toàn

| Chi tiết | Vật liệu | σ von Mises đỉnh (MPa) | σ_chảy (MPa) | **FOS (bảo thủ)** |
|---|---|---|---|---|
| DR-006 Elbow-Clevis | 6061-T6 | 26,09 | 275 | **10,5** |
| DR-005-2 Upper-Arm-Link | 6061-T6 | 4,25 | 275 | **65** |
| DR-007 Moving-Platform | 6061-T6 | 18,71 | 275 | **14,7** |
| DR-001-1 Tấm đế gắn tay | 6061-T6 | 0,145 | 275 | **1890** |
| DR-001-3 Mặt treo | 6061-T6 | 3,84 | 275 | **71,5** |

> **Kết luận:** lấy kết quả **bảo thủ nhất** (lưới cho FOS nhỏ nhất) cho từng chi tiết,
> **hệ số an toàn nhỏ nhất toàn bộ = 10,5** (khuỷu DR-006). Cả 5 chi tiết chịu lực chính đều
> **an toàn dư bền lớn (FOS ≥ 10×)** dưới tải đỉnh động với payload 2 kg. **Việc đổi đế từ thép A36
> sang nhôm 6061-T6 (giảm 128,8 kg) vẫn giữ đế thừa bền:** tấm đế FOS ~1900, mặt treo mang cả robot
> FOS ~72. Ứng suất làm việc (0,1–26 MPa) thấp hơn giới hạn chảy (275 MPa) hàng chục đến hàng nghìn
> lần → kích thước hiện tại và **toàn bộ khung nhôm 6061-T6** là phương án nhẹ mà vẫn an toàn.

## 6. Hạn chế & hướng hoàn thiện

- **Kỳ dị ứng suất:** đỉnh von Mises tại mép mặt ngàm phẳng và mép lỗ chịu tải chưa bo là **kỳ dị
  số học** (không hội tụ đơn điệu khi mịn lưới). Kết luận an toàn không đổi vì FOS ở mọi lưới đều ≫ 1.
  Vòng sau: bo góc các lỗ, dùng mesh control cục bộ, đọc ứng suất ở vùng cách xa điểm kỳ dị.
- **Chuyển vị URES đỉnh** ở DR-005-2 và DR-001-3 do API đọc là nhiễu một nút (không nhất quán với
  ứng suất thấp); chuyển vị thật lấy từ tỉ lệ biến dạng của hình. Ưu tiên dùng ứng suất/FOS.
- **Ngàm lý tưởng hóa:** ngàm cứng tại mặt lắp; mô hình rời từng chi tiết (chưa mô phỏng lắp ghép).
- **Khối DR-001-2 (khung hàn)** đã giải riêng ngày 2026-07-22 — xem mục 8 (FOS ≈ 36, dư bền lớn).
  Chưa gộp trọng lực bản thân của từng chi tiết trong tất cả các study trên; chưa phân tích mỏi.

## 7. Tệp bằng chứng

- Bảng hội tụ (nhôm 2026-07-18): `out/conv_dr006.csv`, `conv_dr005b.csv`, `conv_dr007.csv`, `conv_dr001_1.csv`, `conv_dr001_3.csv`
  (bản thép cũ lưu đối chiếu: `conv_*_steel_20260713.csv`)
- Hình von Mises: `figs/fea_dr006_vonMises.png`, `fea_dr005b_vonMises.png`, `fea_dr007_vonMises.png`, `fea_dr001_1_vonMises.png`, `fea_dr001_3_vonMises.png`
- Đổi vật liệu: `out/mat_change_20260718.csv` · Nhận diện mặt: `out/faces_*.txt`
- Script: `fea_common.ps1`, `fea_run.ps1`, `run_parts.ps1`

## 8. Cập nhật 2026-07-22: kiểm lỗi assembly DR-000 + FEA riêng DR-001-2 (Khung-Han)

### 8.1 Kiểm tra lỗi assembly `DR-000_Delta-Robot_V0.SLDASM`

Mở file, `EditRebuild3` 3 lần liên tiếp, đọc lại qua COM (typed interop `IModelDocExtension.GetWhatsWrongCount`/
`GetWhatsWrong`, quét riêng 48 mate sub-feature bằng `IFeature.GetErrorCode2`):

| Chỉ tiêu | Kết quả |
|---|---|
| `GetWhatsWrongCount()` (lần 1, sau rebuild ×2) | **0** |
| `GetWhatsWrongCount()` (lần 2, sau rebuild ×3, phiên riêng) | **0** |
| `GetWhatsWrong()` Features/Warnings | 0 / 0 |
| Mate sub-feature lỗi | **0 / 48** |
| Component | 41/41 `swComponentFullyResolved` (không suppress/lightweight) |
| Khối lượng đọc lại (`CreateMassProperty`) | 922,340 kg = tổng khối lượng cộng dồn từng component (922,339 kg, khớp) |

**Kết luận: assembly HIỆN TẠI không có lỗi, không cần sửa gì** (thỏa bước 4 của Nhiệm vụ 1 — báo cáo
bằng chứng, không "sửa" khi không có lỗi thật). Log đầy đủ: `out/dr000_whatswrong_before.txt`,
`out/dr000_whatswrong_after.txt` (giống nhau, vì không có gì để sửa).

**Ghi chú quan trọng phát hiện được (không phải lỗi, nhưng chưa có trong CLAUDE.md):** assembly hiện
có thêm 1 component **"Frame-1"** (file `Frame.SLDPRT`, liên quan `DR-100_Khung-Treo.SLDPRT`, thêm vào
2026-07-21/22 bởi phiên làm việc trước, mate 0 lỗi) — một **khung giá đỡ đứng riêng ~800 kg** (thép,
4 cột), KHÔNG phải một phần của robot Delta (DR-001…DR-007). Đây là lý do khối lượng assembly tổng đọc
được (922,3 kg) cao hơn nhiều so với con số "122,4 kg" trong CLAUDE.md — con số đó là khối lượng
**riêng robot Delta**, không gồm khung giá đỡ này. Không có xung đột/lỗi mate giữa Frame-1 và phần còn
lại. FEA sơ bộ trên Frame.SLDPRT/khung treo (không thuộc phạm vi nhiệm vụ này) đã có ghi chú riêng ở
`khung_treo/GHICHU_FEA_KHUNGTREO.md` — kết quả đó gặp kỳ dị số (đỉnh ứng suất phân kỳ theo lưới), khác
hẳn với FEA sạch (hội tụ tốt) ở mục 8.2 dưới đây.

### 8.2 FEA riêng DR-001-2 (Khung-Han) — khung hàn nhôm giữa mặt treo và tấm đế

**Mô hình vật lý:** chuỗi truyền lực là trần nhà → **DR-001-3** (Mặt treo, bắt cứng vào trần, coi là
neo cố định) → 9 bulông M12 (Y=−175) → **DR-001-2** (khung hàn, chi tiết đang kiểm) → mối hàn toàn mặt
(Y=0) → **DR-001-1** (tấm đế gắn tay) → 3 tay máy + gearbox + động cơ + bàn di động + payload 2 kg.

- **Ngàm (Fix):** 9 lỗ ren M12 tại mặt Y=−175 (khớp bulông với DR-001-3) — mặt F80,82,84,86,88,90,98,100,102
  (trụ R=5,10 mm, trục (0,−1,0)), xem `out/faces_DR-001-2_Khung-Han.txt`.
- **Tải (Load):** toàn bộ mặt hàn F55 (Y=0, pháp tuyến (0,1,0), A=20 959,8 mm²) — mối hàn liên tục với
  DR-001-1 nên không có lỗ bulông rời rạc để tải (khác DR-001-3), đặt tải phân bố trên cả mặt, cùng quy
  ước với ngàm mặt Y=0 mà `fea_run.ps1` đã dùng cho DR-001-1 (chỉ đổi vai trò ngàm↔tải).
- **Độ lớn lực:** F = m_dưới × g × k.
  - m_dưới (khối lượng mọi thứ treo DƯỚI mối hàn Y=0, đọc lại từng component từ
    `DR-000_Delta-Robot_V0.SLDASM`: DR-001-1 + 3×(TPMA gearbox + DR-002/003/004/005/006 + rod-end) +
    DR-007, KHÔNG gồm DR-001-2 và DR-001-3) = **89,04 kg** (CAD).
  - Hiệu chỉnh khối lượng thật: gearbox TPMA nhập STEP giữ mật độ mặc định trong CAD (CLAUDE.md) —
    CAD 2,354 kg/cái vs thật 8,1 kg/cái ×3 = **+17,24 kg** (hiệu chỉnh duy nhất có bằng chứng trong dự
    án). m_dưới,thật = 89,04 + 17,24 = **106,28 kg**.
  - k = **1,5** — hệ số an toàn/động tĩnh đã dùng cho chính khớp treo trần DR-001-3 (mục 4.5,
    KETQUA_BEN.md gốc: "trọng lượng robot ~140 kg × 9,81 × hệ số 1,5"), dùng lại cho nhất quán vì
    DR-001-2 cùng loại — chi tiết kết cấu tĩnh trong đường treo, không phải tay máy chuyển động (loại
    đó dùng hệ số gia tốc TCP 1,18g riêng).
  - **F = 106,28 × 9,81 × 1,5 = 1563,9 N**, hướng +Y (chiều bị kéo ra xa 9 lỗ ngàm, đúng chiều trọng
    lượng kéo khung xuống khỏi neo trần).
- **Vật liệu:** Al 6061-T6, σ_chảy = 275 MPa (đọc lại từ model: `SOLIDWORKS Materials|6061-T6 (SS)|164`).
- **Lưới:** tứ diện bậc 2 (solid), 3 mức 15 → 10 → 6 mm, dung sai = kích thước/20.

**Kết quả hội tụ lưới (đọc lại từ solver, `out/conv_dr001_2.csv`):**

| Phần tử (mm) | σ von Mises (MPa) | Chuyển vị URES (mm, API) | FOS = 275/σ |
|---|---|---|---|
| 15 | 7,079 | 41,25 (xem ghi chú) | 38,8 |
| 10 | 7,420 | 41,97 (xem ghi chú) | 37,1 |
| 6  | 7,633 | 42,74 (xem ghi chú) | **36,0** |

- **σ hội tụ tốt, tăng đơn điệu nhẹ (+7,8% từ lưới thô→mịn)** — không có dấu hiệu kỳ dị số phân kỳ
  mạnh (khác hẳn kiểu 350→224 MPa phân kỳ ở `khung_treo/GHICHU_FEA_KHUNGTREO.md`). **FOS bảo thủ
  (lưới mịn nhất) = 36,0** → khung hàn rất dư bền dưới tải treo.
- **Chuyển vị URES đọc từ API (41–43 mm) là NHIỄU/ARTIFACT, không dùng được**, vì hai bằng chứng độc
  lập đều mâu thuẫn với con số này: (1) hệ số phóng đại biến dạng SW **tự đặt trong plot = 1 856,9×**
  — nếu chuyển vị thật là 42 mm thì hình vẽ biến dạng phải vượt xa kích thước khung (~700–800 mm),
  nhưng ảnh xuất ra khung biến dạng rất nhẹ, chứng tỏ chuyển vị thật rất nhỏ; (2) ước lượng tay theo
  độ cứng dọc trục ống (tải gần như dọc trục các ống Y, trục ống trùng phương lực): δ ≈ FL/(AE) với
  F≈1564 N, L=175 mm, A (1 ống R36 dày ~8mm) ≈1810 mm², E=69 000 MPa → **δ ≈ 0,002 mm** — cỡ mm chứ
  không phải chục mm. Kết luận này khớp đúng ghi chú đã có trong CLAUDE.md ("Peak von Mises là số
  chính, chuyển vị là phụ") và tiền lệ DR-005-2/DR-001-3 trong mục 4.2/4.5 ở trên. **Dùng σ/FOS làm
  chỉ tiêu chính, không dùng số URES của API.**
- Ảnh von Mises (lưới mịn nhất 6 mm): `figs/fea_dr001_2_vonMises.png` (toàn khung màu xanh dương đậm —
  ứng suất thấp đồng đều, không có điểm nóng lan rộng).

**Bổ sung vào bảng tổng hợp FOS (mục 5):**

| Chi tiết | Vật liệu | σ von Mises đỉnh (MPa) | σ_chảy (MPa) | **FOS (bảo thủ)** |
|---|---|---|---|---|
| DR-001-2 Khung-Han | 6061-T6 | 7,63 | 275 | **36,0** |

→ **FOS nhỏ nhất toàn robot vẫn là 10,5 (DR-006)**; DR-001-2 (36,0) không phải điểm yếu.

**Trap kỹ thuật gặp phải (ghi lại cho lần sau):**
- `AddForce` báo lỗi tạo `err=10` khi chọn **RefFace trùng chính mặt Load** (F55 làm cả Load và Ref) —
  fix: dùng mặt khác cùng phương pháp tuyến làm Ref (F54, cũng Y, n=(0,1,0)).
- Lần chạy đầu (khi assembly `DR-000` VẪN đang mở song song) báo `RunAnalysis rc=13`
  (`swsRunAnalysisErrorEXMaterialPropertyNotDefined`) dù vật liệu đã gán đúng trong part — dựng lại
  vật liệu tường minh qua `CWMaterial.SetPropertyByName` không sửa được và **SolidWorks bị crash**
  (`GetAddInObject` hr=0x800706BE, process biến mất) ở lần thử tiếp theo. **Khởi động lại SW sạch,
  KHÔNG mở `DR-000` song song, chạy `fea_run.ps1` gốc (không sửa)** → thành công ngay lần đầu. Xác
  nhận thêm quy tắc CLAUDE.md "đóng assembly trước khi làm việc với part" áp dụng cả cho Simulation,
  không chỉ chỉnh sửa hình học.

**Tệp bằng chứng mục 8:** `out/dr000_whatswrong_before.txt`, `out/dr000_whatswrong_after.txt`,
`out/faces_DR-001-2_Khung-Han.txt`, `out/conv_dr001_2.csv`, `figs/fea_dr001_2_vonMises.png`
(+ `.bmp` gốc).

## 9. Cập nhật 2026-07-23: kiểm oằn Euler + FEA thanh truyền 6516K305 (chưa từng có trước đây)

### 9.1 Bối cảnh

`force_analysis.m` dòng ~219 chỉ IN RA dòng chữ "kiểm oằn Euler" như một ghi chú việc-cần-làm,
**chưa từng tính** (xác nhận qua rà soát file, xem `MoPhong_Luc/out/fea_load_params.csv` dòng
"6516K305 Rod"). Thanh truyền carbon composite (cẳng tay) là thanh 2 lực mảnh dài, khả năng phá
hủy chủ đạo là **oằn** (buckling) chứ không phải chảy dẻo — đây là lỗ hổng kiểm tra thực sự, được
đóng lại trong mục này bằng cả công thức Euler và FEA kéo/nén dọc trục.

**Phát hiện quan trọng về nguồn part:** nhiệm vụ ban đầu chỉ định part `LinhKien/6516K305_Connecting
Rod.SLDPRT`, nhưng đây là **bản gốc nhà cung cấp (McMaster) chưa cắt**, dài 609,6 mm — KHÔNG khớp
với chiều dài thật dùng trong thiết kế (`Length@Sketch1` = 942,85 mm, theo CLAUDE.md/memory). Bản
part ĐÚNG với thiết kế là `DeltaRobot_Final/6516K305_Connecting Rod.SLDPRT` (đã có trong assembly
DR-000): đo lại qua COM cho khối lượng 0,3479 kg — khớp CHÍNH XÁC với bảng khối lượng
`ThuyetMinh_LuaChonVatLieu.md` mục 4 ("0,348 kg/cái") → xác nhận đây mới là part đúng. Đã dùng bản
này để tính toán/FEA (bake vào MP_BEN_V2 với tên `6516K305_Connecting-Rod_FEA.SLDPRT`).

### 9.2 Thông số hình học & vật liệu (đọc lại từ CAD, không đoán)

| Đại lượng | Ký hiệu | Giá trị | Nguồn |
|---|---|---|---|
| Bán kính trục (đặc, tròn) | R | 7,94 mm | `SwGeom.DumpFaces` mặt trụ F0, cả 2 bản part |
| Diện tích tiết diện | A = πR² | 198,06 mm² | tính từ R đo CAD |
| Mô men quán tính | I = πR⁴/4 | 3121,6 mm⁴ | tính từ R đo CAD |
| Chiều dài thanh (vật lý, CAD) | L_rod | 942,85 mm | `GetBox` 2 mặt đầu F2/F7 (±471,4 mm), khớp `Length@Sketch1` đã ghi trong CLAUDE.md |
| Chiều dài tâm khớp cầu-khớp cầu | L2 | 1000,0 mm | giá trị thiết kế đã chốt (CLAUDE.md, "R−r=226.4... L2=1000.0mm") — dùng làm chiều dài oằn hiệu dụng, BẢO THỦ hơn L_rod |
| Lực dọc trục thiết kế | F | 61,36 N | `MoPhong_Luc/out/force_results.mat` fMax/2, khớp `fea_load_params.csv` |

**Vật liệu — lỗ hổng dữ liệu phát hiện được:** vật liệu gán trong CAD là `SOLIDWORKS
Materials|Thornel VCB-20 Carbon Cloth|66` (đúng carbon composite theo thiết kế), nhưng tra trực
tiếp trong thư viện vật liệu SolidWorks (`solidworks materials.sldmat`) thì entry này **CHỈ có
Density = 1880 kg/m³, KHÔNG có Elastic Modulus / Tensile / Yield strength nào** — không đủ dữ liệu
để chạy FEA hay tính oằn. `ThuyetMinh_LuaChonVatLieu.md` mục 3 cũng chỉ ghi ρ, không có E số
("một chiều — dùng thông số nhà cung cấp"). Do đó:
- **E dùng cho tính toán = GIẢ THIẾT từ tài liệu kỹ thuật phổ biến** cho thanh carbon/epoxy pultruded
  đơn hướng (loại vật liệu điển hình cho thanh nối robot công nghiệp): khoảng **100–140 GPa**. Trình
  bày cả dải để thấy kết luận không đổi theo E giả thiết.
- Đã tạo material tùy chỉnh **"Carbon Fiber UD Rod (gia thiet tai lieu)"** trong
  `Custom Materials.sldmat` (đã backup bản gốc vào `MP_BEN_V2/Backup/Custom_Materials_backup_20260723.sldmat`
  trước khi sửa) với EX=100 GPa, ν=0,30, ρ=1880 kg/m³ (khớp thư viện), SIGXT (kéo)=600 MPa, SIGYLD
  dùng làm proxy nén=400 MPa — **các giá trị bền này chỉ để có FOS tham khảo qua FEA, KHÔNG phải số
  liệu nhà sản xuất**, ghi rõ giả thiết trong report.

### 9.3 Kiểm oằn Euler (công thức tay — theo đúng chỉ dẫn nhiệm vụ)

$$P_{cr} = \dfrac{\pi^2 E I}{(KL)^2} \quad (9.1)$$

Giả thiết **K = 1** (2 đầu khớp cầu → coi gần đúng ngàm khớp-khớp/pin-pin, không truyền mô men).
Dùng **L = L2 = 1000 mm** (khoảng cách tâm khớp cầu, BẢO THỦ hơn vì dài hơn L_rod → P_cr nhỏ hơn).

| E giả thiết | P_cr (N) | FOS_oằn = P_cr / F |
|---:|---:|---:|
| 100 GPa (biên dưới) | 3080,9 | **50,2** |
| 125 GPa (giữa) | 3851,1 | 62,8 |
| 140 GPa (biên trên) | 4313,2 | 70,3 |

(Đối chiếu dùng L_rod=942,85 mm thay vì L2: P_cr=3465,7–4851,9 N, FOS=56,5–79,1 — cao hơn, tức
L2=1000mm là lựa chọn bảo thủ hơn, đã dùng làm kết quả chính.)

**Kết luận oằn: FOS_oằn ≥ 50 trên toàn dải E giả thiết** — thanh truyền KHÔNG có nguy cơ oằn dưới
tải thiết kế 61,36 N, dư bền rất lớn ngay cả với giả thiết E thấp nhất. Đóng lỗ hổng "kiểm oằn Euler
chưa từng tính" nêu trong `force_analysis.m`.

**Kiểm ứng suất dọc trục (bổ sung, tầm thường nhưng đối chiếu):**
σ = F/A = 61,36/198,06 = **0,310 MPa** → FOS_kéo(600 MPa giả thiết) ≈ 1937, FOS_nén-proxy(400 MPa
giả thiết) ≈ 1291 — ứng suất dọc trục không phải yếu tố quyết định (đúng như dự đoán: thanh 2 lực
mảnh, oằn luôn chi phối trước chảy/bền vật liệu).

### 9.4 FEA kéo/nén dọc trục (SolidWorks Simulation, static)

Không dùng study "Buckling" của Simulation (rủi ro/không chắc chắn set up qua COM cao hơn lợi ích —
đúng theo hướng dẫn nhiệm vụ ưu tiên chắc chắn hơn đẹp) — chạy **static tuyến tính** để kiểm chứng
độc lập ứng suất dọc trục bằng số, đối chiếu công thức tay ở mục 9.3.

- **Ngàm:** mặt vai nhỏ đầu thanh F2 (z=−471,4 mm, A=133,8 mm²).
- **Tải:** mặt vai nhỏ đầu kia F7 (z=+471,4 mm, A=133,8 mm²), lực dọc trục 61,36 N (+Z).
- **Vật liệu:** custom "Carbon Fiber UD Rod (gia thiet tai lieu)" — xem mục 9.2.
- **Lưới:** tứ diện bậc 2, 3 mức 8 → 5 → 3 mm.

| Phần tử (mm) | σ von Mises (MPa) | FOS (so 400 MPa giả thiết) |
|---|---|---|
| 8 | 1,005 | 398,0 |
| 5 | 0,869 | 460,1 |
| 3 | 0,771 | **519,1** |

σ hội tụ tốt (giảm đơn điệu khi mịn lưới, không phân kỳ), cùng bậc độ lớn với σ=0,310 MPa tính tay
(chênh lệch do tập trung ứng suất số tại mặt ngàm/tải chưa bo — hiện tượng đã ghi nhận ở các chi
tiết khác trong mục 6). **FOS FEA ≫ FOS oằn (519 vs 50)** → xác nhận đúng dự đoán: oằn là mode phá
hủy chi phối, không phải ứng suất/chảy vật liệu.

### 9.5 Kết luận mục 9

**Thanh truyền 6516K305 AN TOÀN dưới tải thiết kế, oằn là mode kiểm tra chi phối, FOS_oằn bảo thủ
nhất ≈ 50 (dùng E giả thiết thấp nhất 100 GPa)** — dư bền lớn dù có bất định về E thật của vật liệu
(do thư viện SolidWorks không có số liệu cơ tính, chỉ có ρ). Khuyến nghị: nếu cần số liệu chính xác
hơn cho báo cáo chính thức, nên lấy datasheet thật của McMaster 6516K305 (E, σ_kéo, σ_nén) thay giả
thiết văn liệu ở đây.

**Tệp bằng chứng mục 9:** `MoPhong_Ben/MP_BEN_V2/6516K305_Connecting-Rod_FEA.SLDPRT` (study bake
sẵn), `out/faces_6516K305_Rod_FEA.txt` (bản đúng, dài 942,85mm) + `out/faces_6516K305_Rod_REAL.txt`,
`out/conv_rod.csv`, `figs/fea_rod_vonMises.png`, `out/run_rod_v2.log`,
`MP_BEN_V2/Backup/Custom_Materials_backup_20260723.sldmat`.

## 10. Cập nhật 2026-07-23: FEA lại Frame.SLDPRT (khung treo trần) — sửa phân kỳ số

### 10.1 Bối cảnh — vấn đề hội tụ cũ

Lần chạy trước (`khung_treo/GHICHU_FEA_KHUNGTREO.md`, 2026-07-22) tải tập trung trên "3 mảng đỉnh
đĩa Ø720" cho kết quả **PHÂN KỲ mạnh theo lưới**: σ=224 MPa (lưới 12mm) → σ=350 MPa (lưới 6mm), tăng
56% khi mịn lưới hơn — dấu hiệu kinh điển của **kỳ dị ứng suất số** tại vùng đặt tải tập trung, ghi
chú đó tự nhận không dùng được làm FOS và đề xuất 3 hướng khắc phục, ưu tiên thấp-rủi-ro nhất là
"đặt tải phân bố trên toàn mặt đĩa treo" — đây là cách đã áp dụng dưới đây.

**Dọn dẹp phát hiện được:** file thiết kế `DeltaRobot_Final/Frame.SLDPRT` (đang HOẠT ĐỘNG, không
phải bản lưu trữ) chứa SẴN 3 study Simulation nhúng (`Static`, `conv_khungtreo_60`,
`conv_khungtreo_120` — đúng là kết quả phân kỳ nói trên) từ lần chạy trước, vi phạm quy tắc mới "mọi
file mô phỏng bền phải nằm ở MP_BEN_V2". Đã: (1) backup file gốc vào
`DeltaRobot_Final/Backup/Frame_backup_20260723_feacontam.SLDPRT` (xóa bản backup cũ hơn
`_preconcentricfix` theo quy tắc chỉ giữ 1 bản mới nhất/part), (2) xóa cả 3 study nhúng qua COM
(`StudyManager.DeleteStudy`), rebuild + save lại — `DeltaRobot_Final/Frame.SLDPRT` hiện **sạch, 0
study**, đúng quy ước dự án.

### 10.2 Tải trọng — số chính xác thay ước lượng "~140 kg"

Nhiệm vụ yêu cầu đọc khối lượng ROBOT (không gồm Frame) chính xác qua COM thay vì ước lượng. Đã mở
`DR-000_Delta-Robot_V0.SLDASM`, rebuild ×2, `GetWhatsWrongCount()=0` (khớp mục 8.1), rồi đọc:

| Đại lượng | Giá trị (đọc qua COM) |
|---|---|
| Khối lượng TOÀN assembly (`CreateMassProperty`, không chọn gì) | 922,3401 kg |
| Khối lượng riêng component `Frame-1` (đo lại `Frame_FEA.SLDPRT` độc lập, cùng file) | 799,9027 kg |
| **Khối lượng ROBOT (= tổng − Frame) — CAD** | **122,4374 kg** |

Số 122,4374 kg khớp gần như tuyệt đối với con số đã công bố trong CLAUDE.md/`ThuyetMinh_LuaChonVatLieu.md`
("Whole-robot mass = 122,437 kg CAD") — xác nhận chéo độc lập, sai lệch chỉ 0,0004 kg (làm tròn).

Hiệu chỉnh khối lượng thật (mật độ mặc định của 3 gearbox TPMA nhập STEP, +3×(8,1−2,354) kg — số
đã có sẵn, không tính lại):

$$m_{robot,thuc} = 122{,}4374 + 17{,}238 = 139{,}6754\ kg$$

$$F = m_{robot,thuc}\cdot g \cdot k_s = 139{,}6754 \times 9{,}81 \times 1{,}5 = \mathbf{2055{,}32\ N}$$

**So với số cũ:** ước lượng "~140 kg×9,81×1,5≈2060 N" trong ghi chú cũ lệch +4,8 N (0,2%, trùng hợp
gần đúng); số "2097 N" đã dùng cho DR-001-3 (mục 4.5/7, vốn đã bị gắn cờ "CHƯA XÁC MINH ĐƯỢC NGUỒN
CHÍNH XÁC" trong `MoPhong_Luc/fea_load_params.m`) lệch +41,7 N (2,0%) so với con số đọc CAD chính
xác mới này. **Dùng F = 2055,32 N (số mới, đọc CAD trực tiếp) cho Frame** — không sửa lại số 2097N
đã dùng cho DR-001-3 ở mục 4.5/7 (nằm ngoài phạm vi nhiệm vụ này, đã có cờ cảnh báo riêng).

### 10.3 Mô hình FEA (tải phân bố — khắc phục kỳ dị)

- **Ngàm:** 4 mặt đáy chân đế, Y=−2650 mm (F21, F40, F46, F57, mỗi mặt A=48400 mm², 4 góc chữ nhật
  chân đế) — giữ nguyên như bản cũ.
- **Tải (THAY ĐỔI — khắc phục kỳ dị):** thay vì "3 mảng đỉnh đĩa Ø720" nhỏ tập trung, đặt **TOÀN BỘ
  2055,32 N phân bố trên mặt đáy nguyên khối của tấm lắp** F3 (Y=−177,8 mm, A=883 494,9 mm² — lớn
  hơn vùng tải cũ hàng trăm lần) → áp suất tương đương chỉ ≈0,0023 MPa, loại bỏ hoàn toàn kỳ dị điểm
  tải tập trung. Hướng lực: −Y (xuống, đúng chiều trọng lượng robot kéo khung xuống khỏi 4 chân).
- **Ref face:** F4 (Y=−77,8 mm, mặt trên tấm lắp, cùng phương pháp tuyến (0,±1,0), khác mặt tải).
- **Vật liệu:** ASTM A36 Steel (thư viện SW), σ_chảy = 250 MPa, đúng vật liệu đã gán trong CAD.
- **Lưới:** tứ diện bậc 2, 3 mức 30 → 20 → 12 mm.

### 10.4 Kết quả — ĐÃ HỘI TỤ (so với phân kỳ trước)

| Phần tử (mm) | σ von Mises (MPa) | FOS = 250/σ |
|---|---|---|
| 30 | 11,327 | 22,1 |
| 20 | 12,939 | 19,3 |
| 12 | 16,438 | **15,2** |

**So sánh với lần chạy cũ (tải tập trung):** cũ 12mm→6mm tăng 224→350 MPa (**+56%**, không đơn
điệu về mức độ, đặc trưng kỳ dị số thô bạo). Mới 30mm→12mm tăng 11,3→16,4 MPa (**+45% qua 2 bước
mịn hơn, nhưng TĂNG ĐỀU/ĐƠN ĐIỆU, không có bước nhảy vọt kiểu kỳ dị**, và bản thân trị số tuyệt đối
thấp hơn nhiều lần). Đây là cải thiện rõ rệt nhưng **CHƯA HOÀN TOÀN PHẲNG (chưa hội tụ tuyệt đối)** —
báo cáo trung thực: xu hướng tăng vẫn còn ở mức lưới đã thử, có thể do lưới 12mm vẫn còn thô so với
độ dày vách hộp thép (khung hộp thép mỏng, ~5mm theo hồ sơ thiết kế) nên cục bộ vẫn hơi nhạy lưới,
KHÔNG phải mức phân kỳ nghiêm trọng như trước. **Dùng lưới mịn nhất đã thử (12mm) làm số bảo thủ:
FOS = 15,2** — vẫn rất an toàn (>>1), thấp hơn DR-006 (10,5) KHÔNG, tức Frame (15,2) vẫn > FOS nhỏ
nhất toàn robot (10,5, mục 5) → **không phải điểm yếu, không đổi kết luận tổng thể.**

**Trả lời câu hỏi trung thực (theo yêu cầu nhiệm vụ):** tải phân bố **ĐÃ hội tụ đủ tốt để dùng làm
FOS** (không còn phân kỳ kiểu kỳ dị số thô như trước, mức tăng giữa các lưới đã giảm mạnh và đều
đặn), nhưng **chưa đạt trạng thái phẳng tuyệt đối** ở 3 mức lưới đã thử — khuyến nghị nếu cần số
liệu "sạch" hơn nữa cho báo cáo chính thức thì thử thêm 1-2 mức lưới mịn hơn (8mm, 5mm) để xác nhận
hội tụ tiệm cận, nằm ngoài ngân sách thời gian của lần chạy này.

**Tệp bằng chứng mục 10:** `MoPhong_Ben/MP_BEN_V2/Frame_FEA.SLDPRT` (study bake sẵn, 3 study mới +
3 study cũ dữ nguyên để đối chiếu), `out/faces_Frame_FEA.txt`, `out/conv_frame_v2.csv`,
`figs/fea_frame_v2_vonMises.png`, `out/run_frame_v2_a.log` + `_b.log`,
`out/robot_mass_excl_frame.log`, `DeltaRobot_Final/Backup/Frame_backup_20260723_feacontam.SLDPRT`.

## 11. Cập nhật 2026-07-23: bake DR-001-2 (Khung-Han) vào MP_BEN_V2 — phát hiện lệch số với mục 8.2

### 11.1 Việc đã làm

Bake study DR-001-2 (mô hình vật lý GIỮ NGUYÊN như mục 8.2: ngàm 9 lỗ M12 tại Y=−175, tải F=1563,9 N
+Y trên mặt hàn F55, ref F54, lưới 15→10→6mm) vào file riêng
`MP_BEN_V2/DR-001-2_Khung-Han_FEA.SLDPRT`, cùng chuẩn với 5 part đã bake trước.

**Dọn dẹp phát hiện được (giống mục 10.1):** file `DeltaRobot_Final/DR-001-2_Khung-Han.SLDPRT` đang
hoạt động chứa SẴN 7 study Simulation nhúng — trong đó có các study TÊN LẠ/HỎNG
(`conv_dr006_8530`, `conv_dr001_250/180/120` — không khớp bất kỳ quy ước đặt tên nào của dự án, khả
năng từ 1 lần chạy lỗi/nhầm part trước đó) lẫn với 3 study đúng của mục 8.2
(`conv_dr001_2_150/100/60`) và có cả rác solver (`DR-001-2_Khung-Han-conv_dr001_2_60/` folder +
`.MFC`) nằm ngay trong `DeltaRobot_Final/`. Đã: (1) backup vào
`DeltaRobot_Final/Backup/DR-001-2_Khung-Han_backup_20260723_feacontam.SLDPRT` (xóa bản
`_preconcentricfix` cũ hơn theo quy tắc), (2) xóa cả 7 study nhúng qua COM, rebuild+save lại — file
sạch, (3) xóa rác solver trong `DeltaRobot_Final/`. `DeltaRobot_Final/DR-001-2_Khung-Han.SLDPRT` hiện
sạch, 0 study.

### 11.2 Kết quả bake — LỆCH so với mục 8.2 đã công bố (báo cáo trung thực, KHÔNG tự sửa số cũ)

Bake lại TRÊN FILE ĐÃ DỌN SẠCH (loại trừ khả năng do study cũ lẫn lộn), dùng chính xác cùng tham số
(Fix/Load/Ref/lực/lưới) như mục 8.2:

| Phần tử (mm) | σ (MPa) — mục 8.2 (2026-07-22) | σ (MPa) — bake lại (2026-07-23) | FOS mới |
|---|---|---|---|
| 15 | 7,079 | 17,501 | 15,7 |
| 10 | 7,420 | 18,693 | 14,7 |
| 6  | 7,633 | 19,495 | **14,1** |

**Đã kiểm tra để loại trừ nguyên nhân:** (a) hình học — so `out/faces_DR-001-2_Khung-Han.txt` (probe
mục 8.2) với `out/faces_DR-001-2_Khung-Han_FEA.txt` (probe hôm nay) → **BYTE-IDENTICAL** cho toàn bộ
mặt liên quan (F49–F103, gồm F54/F55 tải/ref và 9 mặt trụ F80…F102 ngàm) — hình học KHÔNG đổi; (b)
vật liệu — cùng `6061-T6 (SS)`; (c) study cũ lẫn lộn — đã loại trừ bằng cách bake trên file đã dọn
sạch (StudyCount=0 trước khi chạy). **Nguyên nhân gốc chưa xác định được** trong phạm vi thời gian
phiên này (có thể liên quan thiết lập mesh/contact mặc định toàn cục của Simulation khác nhau giữa 2
phiên làm việc — chưa kiểm chứng được).

**Theo đúng chỉ dẫn nhiệm vụ ("nếu lệch nhiều thì báo, đừng tự sửa số cũ")**: KHÔNG sửa bảng mục 8.2
ở trên. Ghi nhận CẢ HAI kết quả tại đây; khuyến nghị dùng con số MỚI (tái lập được, kiểm soát đầy đủ
trong phiên này, σ=19,495 MPa / **FOS=14,1**) làm số bảo thủ cho các báo cáo tiếp theo cho đến khi
điều tra được nguyên nhân lệch. Dù dùng số nào, **kết luận an toàn không đổi** (FOS 14,1–38,8 đều
≫1); FOS nhỏ nhất toàn robot vẫn là DR-006 = 10,5 (mục 5), DR-001-2 vẫn không phải điểm yếu.

**Tệp bằng chứng mục 11:** `MP_BEN_V2/DR-001-2_Khung-Han_FEA.SLDPRT` (study bake sẵn),
`out/conv_dr001_2_v2.csv`, `figs/fea_dr001_2_v2_vonMises.png`, `out/run_dr001_2_v2.log` (chạy đầu,
trên file còn lẫn study cũ) + `_v2b.log` (chạy lại trên file đã dọn sạch — 2 log cho cùng kết quả,
xác nhận không phải do lẫn study cũ), `DeltaRobot_Final/Backup/DR-001-2_Khung-Han_backup_20260723_feacontam.SLDPRT`.
