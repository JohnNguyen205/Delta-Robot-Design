# KẾT QUẢ MÔ PHỎNG ĐỘNG HỌC DELTA ROBOT (MATLAB R2025a)

Tổng hợp cho thuyết minh. Nguồn: `KinematicsSimulation/`. Thông số: R=347, r=120,6, R−r=226,4, L1=407,5, L2=1000 mm; 3 cánh tay φ=[−90°,30°,150°].

## 1. Động học nghịch (Inverse Kinematics)
Với mỗi cánh tay i (phương vi φᵢ), khớp bàn máy Pᵢ = P + r·[cosφᵢ, sinφᵢ, 0]. Đặt

&nbsp;&nbsp;(1)&nbsp; uᵢ = x·cosφᵢ + y·sinφᵢ − (R−r)  
&nbsp;&nbsp;(2)&nbsp; wᵢ = −x·sinφᵢ + y·cosφᵢ

Ràng buộc |Eᵢ − Pᵢ| = L2 rút về phương trình lượng giác chuẩn:

&nbsp;&nbsp;(3)&nbsp; Eᵢ·sinθᵢ + Fᵢ·cosθᵢ + Gᵢ = 0  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Eᵢ = 2·L1·z ; Fᵢ = −2·L1·uᵢ ; Gᵢ = L1² + uᵢ² + wᵢ² + z² − L2²

Nghiệm: θᵢ = arcsin(−Gᵢ/ρᵢ) − ψᵢ, với ρᵢ = √(Eᵢ²+Fᵢ²), ψᵢ = atan2(Fᵢ,Eᵢ); chọn nhánh trong giới hạn góc. Có nghiệm thực khi |Gᵢ| ≤ ρᵢ. (Hàm `delta_ik.m`)

## 2. Động học thuận (Forward Kinematics)
Khuỷu: Eᵢ = Bᵢ + L1·[cosθᵢcosφᵢ, cosθᵢsinφᵢ, −sinθᵢ], Bᵢ = R·[cosφᵢ,sinφᵢ,0].  
Thu khớp bàn máy về tâm: Cᵢ = Eᵢ − r·[cosφᵢ,sinφᵢ,0]. Tâm bàn máy P là **giao 3 mặt cầu** bán kính L2 tâm Cᵢ (lấy nghiệm z thấp hơn). (Hàm `delta_fk.m`)

## 3. Jacobian & điểm kỳ dị
A·ẋ = B·θ̇, với hàng i của A = vector thanh truyền Lᵢ = Eᵢ − Pᵢ; B = diag(L1·Lᵢ·v̂ᵢ). Jacobian thuận J = A⁻¹B (ẋ = J·θ̇). Kỳ dị: det A = 0 (song song, Type II — mất cứng vững); det B = 0 (biên, Type I). (Hàm `delta_jacobian.m`)

## 4. Bảng kết quả
| Chỉ tiêu | Kết quả | Ghi chú |
|---|---|---|
| Sai số kiểm chứng FK(IK(P)) | **max 6,2·10⁻¹³ mm** / 3000 điểm | độ chính xác máy |
| Vùng làm việc | trụ Ø800×250 **nằm gọn** | bán kính với-tới tại z=−925 là 650 mm (cần 400) |
| Khoảng z với-tới trên trục | [−1350; −570] mm | |
| Điểm kỳ dị trong vùng | **0** / 34 372 điểm | |
| Số điều kiện Jacobian | max **2,75**, tb 2,13 | càng gần 1 càng tốt |
| Góc truyền (forearm–bicep) min | 49,8° | > 30° an toàn |
| Quỹ đạo pick&place (chu kỳ 1,2 s) | 100% với-tới | pick(300,0,−1000)→place(−300,0,−1000) |
| Tốc độ khớp đỉnh | 30 rpm (180 deg/s) | dữ liệu chọn động cơ |
| Gia tốc khớp đỉnh | 1761 deg/s² | |
| Tốc độ / gia tốc TCP đỉnh | 1875 mm/s / 1,18 g | |

## 5. Hình (trong `figs/`)
- `p2_roundtrip_hist.png` — phân bố sai số kiểm chứng IK/FK.
- `p3_workspace_xz.png` — vùng làm việc (mặt cắt y=0) + trụ mục tiêu.
- `p3_slice_z.png` — mặt cắt ngang tại z=−925.
- `p4_cond_map.png` — bản đồ số điều kiện Jacobian.
- `p5_path.png` — quỹ đạo pick-and-place.
- `p5_joint_profiles.png` — θ, ω, α theo thời gian.
- `p6_animation.gif` — hoạt hình 3D robot chạy quỹ đạo.

## 6. Kết luận
Động học thuận/nghịch được kiểm chứng chặt (round-trip ~10⁻¹³ mm). Vùng làm việc mục tiêu Ø800×250 đạt với dư địa lớn, không điểm kỳ dị, số điều kiện tốt (≤2,75). Bộ thông số động lực học đỉnh (tốc độ/gia tốc khớp) sẵn sàng cho bước chọn động cơ–hộp số và mô phỏng bền.

## 7. Vùng làm việc + quỹ đạo theo phương pháp mật độ điểm (STT07) + thí nghiệm trực giao L9

Script: `p_STT07_workspace_quydao.m`. Phương pháp: (A) quét lưới 3 góc chủ động θ₁,θ₂,θ₃ (N=45/trục → 91 125 tổ hợp, N=25 cho khảo sát L9 → 15 625 tổ hợp), chạy FK **vector hoá** (không lặp for từng điểm; tách biến Cᵢ(θᵢ) rồi ghép tổ hợp bằng `ndgrid`, giải giao 3 mặt cầu dạng đóng bằng nghịch đảo Gram 2×2/Cramer thay cho `pinv`) cho toàn lưới để tạo đám mây điểm với-tới; (B) thể tích vùng làm việc = số voxel (cạnh 10 mm) có điểm với-tới × thể tích 1 voxel ("mật độ điểm với-tới", không phải convex hull); (C) quét z (bước 15 mm, dải dày ±7,5 mm) tìm mặt cắt ngang diện tích lớn nhất, xấp xỉ biên bằng convex hull của lát cắt; (D) chồng hình chữ nhật quỹ đạo "cổng" pick-and-place (X:[−300,300], Z:[−1000,−820], Y=0, đúng 4 waypoint của `p5_trajectory.m`) lên mặt cắt Y=0 để kiểm tra bao phủ; (E) thí nghiệm trực giao L9(3⁴) trên 4 tham số kết cấu (L1, L2, R, r — mỗi tham số 3 mức quanh giá trị thiết kế thật), phân tích phạm vi (range analysis) để xếp hạng mức ảnh hưởng.

Tự kiểm tra: FK vector hoá so với `delta_fk.m` trên 25 điểm ngẫu nhiên lấy từ đám mây — sai số lệch tối đa **3,411×10⁻¹³ mm** (khớp máy).

| Chỉ tiêu (thiết kế thật, `params()`) | Kết quả |
|---|---|
| Số điểm với-tới (Bước A, N=45, lưới 91 125 tổ hợp) | **91 125 / 91 125 (100,0%)** |
| Thể tích vùng làm việc (Bước B, voxel 10 mm) | **90 812 000 mm³ = 0,0908 m³** |
| Mặt cắt ngang lớn nhất (Bước C) | tại **z = −639,12 mm**, diện tích **2 211 551,8 mm²**, đường kính tương đương **1 678,05 mm** |
| Bao phủ quỹ đạo cổng — 4 đỉnh hình chữ nhật (Bước D) | **4/4** với-tới |
| Bao phủ quỹ đạo cổng — toàn đường quintic 601 điểm (Bước D) | **601/601 (100,00%)** với-tới |
| Kết luận Bước D | **Thiết kế thật bao phủ đầy đủ quỹ đạo pick-and-place cổng** |

Bảng L9(3⁴) (Row 0 = thiết kế thật ở cùng độ phân giải N=25 để so sánh ngang hàng; Run 1–9 = L9, voxel 12 mm, quét z bước 20 mm) — xem đầy đủ `out/l9_results.csv`:

| Run | L1 | L2 | R | r | Thể tích (mm³) | Mặt cắt lớn nhất (mm²) | z (mm) | Đỉnh quỹ đạo (0–4) |
|---|---|---|---|---|---|---|---|---|
| 0 (thật) | 407,5 | 1000 | 347 | 120,6 | 26 989 632 | 2 193 215,7 | −649,12 | 4 |
| 1 | 350 | 850 | 300 | 90 | 26 961 984 | 1 514 675,5 | −561,48 | 4 |
| 2 | 350 | 1000 | 347 | 120,6 | 26 987 904 | 2 024 153,1 | −670,87 | 4 |
| 3 | 350 | 1150 | 394 | 150 | 26 987 904 | 2 534 170,6 | −799,99 | 2 |
| 4 | 407,5 | 850 | 347 | 150 | 26 946 432 | 1 701 858,8 | −501,88 | 4 |
| 5 | 407,5 | 1000 | 394 | 90 | 26 944 704 | 1 790 204,2 | −693,73 | 4 |
| 6 | 407,5 | 1150 | 300 | 120,6 | 26 946 432 | 3 235 064,6 | −706,54 | 2 |
| 7 | 465 | 850 | 394 | 120,6 | 26 148 096 | 1 464 720,2 | −505,82 | 4 |
| 8 | 465 | 1000 | 300 | 150 | 26 965 440 | 2 747 990,9 | −536,92 | 4 |
| 9 | 465 | 1150 | 347 | 90 | 26 987 904 | 2 914 022,0 | −734,35 | 4 |

Phân tích phạm vi (range analysis, 9 hàng L9, không tính Row 0) — trung bình thể tích theo từng mức, phạm vi = max−min:

| Tham số | Mức 1 → 2 → 3 (mm) | TB thể tích 3 mức (mm³) | Phạm vi (mm³) |
|---|---|---|---|
| L2 (thanh truyền) | 850 → 1000 → 1150 | 26 685 504 / 26 966 016 / 26 974 080 | **288 576** |
| R (bán kính đế) | 300 → 347 → 394 | 26 957 952 / 26 974 080 / 26 693 568 | 280 512 |
| L1 (cánh tay trên) | 350 → 407,5 → 465 | 26 979 264 / 26 945 856 / 26 700 480 | 278 784 |
| r (bán kính bàn máy) | 90 → 120,6 → 150 | 26 964 864 / 26 694 144 / 26 966 592 | 272 448 |

**Xếp hạng ảnh hưởng tới thể tích vùng làm việc (phạm vi giảm dần): L2 > R > L1 > r** (bộ số liệu này của riêng robot HCMUTE, không suy ra từ bài báo tham khảo). Lưu ý 4 phạm vi rất gần nhau (272 448–288 576 mm³, chênh lệch <6%) trên nền thể tích ~2,7×10⁷ mm³ — vì L2=1000 mm rất lớn so với L1+Rr nên với mọi mức khảo sát 3 mặt cầu bán kính L2 gần như luôn giao nhau (xem tỉ lệ với-tới Bước A = 100%), do đó thể tích vùng làm việc trong dải khảo sát này bị chặn chủ yếu bởi **giới hạn góc khớp** (θ∈[−45°,100°]) chứ không phải bởi động học tam giác cầu — hợp lý vì L2 được chọn dư dả so với yêu cầu (xem mục 4). Khảo sát L9 này là **kiểm chứng độ nhạy quanh thiết kế đã chốt** (từ các bước động học/lực/FEA trước), không phải đề xuất đổi kích thước thật.

Hình mới (`figs/`):
- `pSTT07_workspace_cloud.png` — đám mây điểm với-tới 4 góc nhìn (trước Y-Z, trên X-Y, cạnh X-Z, isometric), N=45.
- `pSTT07_max_crosssection.png` — mặt cắt ngang diện tích lớn nhất (z=−639,12 mm) + trụ mục tiêu Ø800 tham chiếu.
- `pSTT07_gate_coverage.png` — mặt cắt Y=0 + hình chữ nhật quỹ đạo cổng + đường quỹ đạo quintic thực tế, xác nhận bao phủ 100%.

File số liệu: `out/l9_results.csv` (10 hàng), `out/pSTT07_results.mat`, log đầy đủ `out/pSTT07_log.txt`.
