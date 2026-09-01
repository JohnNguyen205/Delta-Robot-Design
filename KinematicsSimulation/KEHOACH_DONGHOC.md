# KẾ HOẠCH MÔ PHỎNG ĐỘNG HỌC DELTA ROBOT (MATLAB)

Môi trường: MATLAB R2025a (`E:\Mathlab\bin\matlab.exe`) — có Robotics System Toolbox, Control System, Statistics, Simulink.
Thư mục dự án: `F:\DeltaRobot\KinematicsSimulation\`. Chạy: `matlab -batch "cd('F:/DeltaRobot/KinematicsSimulation'); <script>"`.

## Thông số động học (chốt từ thiết kế CAD)
| Ký hiệu | Giá trị | Ý nghĩa |
|---|---|---|
| R | 347,0 mm | bán kính vòng khớp đế (R = (R−r)+r = 226,4+120,6) |
| r | 120,6 mm | bán kính vòng khớp bàn máy |
| R−r | 226,4 mm | tham số rút gọn (thu bàn máy về 1 điểm) |
| L1 | 407,5 mm | cánh tay trên (bicep) |
| L2 | 1000,0 mm | thanh truyền (forearm, ball-to-ball) |
| φᵢ | −90°, 30°, 150° | phương vị 3 cánh tay (120° cách đều) |
| Vùng làm việc mục tiêu | Ø800 × 250 mm | trụ đồng trục, tâm ~925 mm dưới mặt vai |

Mô hình: khớp đế Bᵢ nằm trên vòng R, bicep L1 quay trong mặt phẳng đứng-hướng kính quanh trục ngang tiếp tuyến; forearm L2 nối khuỷu tới khớp bàn máy Pᵢ = P + r·[cosφᵢ, sinφᵢ, 0]. Quy ước góc θᵢ = góc bicep chúc xuống dưới mặt ngang.

## Lộ trình 7 phase (mỗi phase phải có bằng chứng mới đánh [x])

- **Phase 0 — Chuẩn bị & thông số.** `params.m` (nguồn thông số duy nhất), cấu trúc thư mục, xác nhận MATLAB.
  - *Bằng chứng:* in thông số, MATLAB chạy được.
- **Phase 1 — Động học nghịch (IK).** `delta_ik.m`: P=(x,y,z) → (θ1,θ2,θ3) kèm cờ với-tới.
  - *Bằng chứng:* tính được góc tại vị trí home + vài điểm mẫu, giá trị hợp lý.
- **Phase 2 — Động học thuận (FK) + kiểm chứng.** `delta_fk.m`: (θ1,θ2,θ3) → P (giao 3 mặt cầu). Kiểm chứng vòng lặp FK(IK(P))=P.
  - *Bằng chứng:* sai số round-trip ≤ 1e-6 mm trên ≥ 2000 điểm ngẫu nhiên; log + biểu đồ.
- **Phase 3 — Vùng làm việc (Workspace).** Quét IK trên lưới 3D, lọc theo nghiệm thực + giới hạn góc + góc truyền. Kiểm tra trụ Ø800×250 nằm trong vùng với-tới.
  - *Bằng chứng:* hình đám mây workspace + mặt cắt + trụ mục tiêu chồng lên; xác nhận trụ nằm gọn.
- **Phase 4 — Jacobian, vận tốc, điểm kỳ dị.** `delta_jacobian.m` (Jx·v = Jθ·ω). Bản đồ số điều kiện / định thức + góc truyền trên vùng làm việc.
  - *Bằng chứng:* bản đồ điều kiện, xác nhận không kỳ dị trong vùng, số điều kiện xấu nhất (đối chiếu ~3,69 thiết kế).
- **Phase 5 — Quỹ đạo pick-and-place.** Sinh quỹ đạo (đa thức bậc 5 / hình cổng adept). Tính θ(t), ω(t), α(t) theo IK + Jacobian.
  - *Bằng chứng:* đồ thị θ/ω/α theo thời gian; tốc độ/gia tốc khớp đỉnh (dữ liệu chọn động cơ-hộp số).
- **Phase 6 — Hoạt hình 3D.** Vẽ robot (đế, bicep, forearm, bàn máy) chạy theo quỹ đạo, xuất GIF + khung hình.
  - *Bằng chứng:* file hoạt hình + ảnh khung hình.
- **Phase 7 — Tổng hợp & xuất cho thuyết minh.** Gom hình có chú thích, bảng kết quả, công thức chuẩn.
  - *Bằng chứng:* thư mục `figs/` + tài liệu tóm tắt kết quả.

## Tệp
`params.m`, `delta_ik.m`, `delta_fk.m`, `delta_jacobian.m`, `test_p1_ik_fk.m`, `p3_workspace.m`, `p4_singularity.m`, `p5_trajectory.m`, `p6_animate.m`; kết quả trong `figs/`, `out/`.

## Trạng thái (đồng bộ với TIENDO.md)
- [x] Phase 0  - [x] Phase 1  - [x] Phase 2  - [x] Phase 3  - [x] Phase 4  - [x] Phase 5  - [x] Phase 6  - [x] Phase 7 — **HOÀN THÀNH TẤT CẢ**

### Kết quả đã kiểm chứng (2026-07-12)
- P0: MATLAB R2025a, `params.m` chạy tốt.
- P1+P2: home θ=[19,15°×3]; round-trip FK(IK(P)) **max 6,2e−13 mm** / 3000 điểm; **100%** trụ với-tới. (`out/p1_p2_log.txt`, `figs/p2_roundtrip_hist.png`)
- P3: bán kính với-tới tại z=−925 là **650 mm** (cần 400); z-truc [−1350,−570]; **trụ Ø800×250 nằm gọn** (0/108 biên ngoài). (`figs/p3_workspace_xz.png`, `p3_slice_z.png`)
- P4: **0 điểm kỳ dị** / 34372; số điều kiện Jacobian max **2,75** tb 2,13; góc forearm-bicep min **49,8°**. (`figs/p4_cond_map.png`)
  - *Lưu ý quy ước:* số 3,69 và 34,6° trong ghi chú thiết kế cũ dùng định nghĩa khác (Jacobian chuẩn hóa / định nghĩa góc truyền khác); kết luận (không kỳ dị, điều kiện tốt) không đổi.
- P5: quỹ đạo pick&place (chu kỳ 1,2 s) 100% với-tới; tốc độ khớp đỉnh **30 rpm**, gia tốc **1761 deg/s²**; TCP 1875 mm/s (1,18 g). (`figs/p5_path.png`, `p5_joint_profiles.png`, `out/p5_traj.mat`)
- P6: hoạt hình 3D 49 frame → `figs/p6_animation.gif`.
- P7: tổng hợp `KETQUA_DONGHOC.md` (công thức chuẩn (1)–(3), bảng kết quả, danh mục hình).
