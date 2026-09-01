# Mô phỏng / Phân tích lực & Chọn động cơ — Delta Robot (payload 2 kg)

Phân tích lực học để (1) xác định **tải trọng thực** làm đầu vào mô phỏng bền (FEA) và
(2) **kiểm tra chọn động cơ – hộp số** theo phương pháp mô men **tĩnh + động × hệ số an toàn**.

> Cập nhật 2026-07-14: bổ sung đúng yêu cầu trình bày (sơ đồ phân bố lực, biểu đồ nội lực,
> ký hiệu đầy đủ) và tách **mô men tĩnh / mô men động**, thêm **quán tính + trọng lượng bắp tay**
> và **hệ số an toàn**. Bản cũ chỉ tính lực quy về bàn máy, bỏ khối lượng bắp tay → thiếu.

## Nội dung thư mục

```
ForceAnalysis/
├── moment_angle_sweep.m   # MATLAB quét mô-men theo góc, xuất CSV/MAT và đồ thị cực đại
├── force_analysis.m       # (1) lực forearm + (2) mô men khớp tĩnh/động + kiểm chọn động cơ
├── force_diagrams.m       # sơ đồ phân bố lực (FBD) + biểu đồ nội lực N,Q,M
├── params.m, delta_ik.m, delta_jacobian.m
├── force_analysis_v0_backup.m   # bản cũ (lưu để đối chiếu)
├── out/  force_log.txt, force_results.mat
└── figs/ forearm_forces · force_ee · joint_torques · torque_sizing
         · so_do_phan_bo_luc · bieu_do_noi_luc · noiluc_thanhtruyen  (.png)
```

## Cách chạy
```
E:\Mathlab\bin\matlab.exe -batch "cd('F:/DeltaRobot/ForceAnalysis'); force_analysis"
E:\Mathlab\bin\matlab.exe -batch "cd('F:/DeltaRobot/ForceAnalysis'); moment_angle_sweep"
E:\Mathlab\bin\matlab.exe -batch "cd('F:/DeltaRobot/ForceAnalysis'); force_diagrams"
```

## Ký hiệu (định nghĩa đầy đủ)

| KH | Đơn vị | Ý nghĩa |
|---|---|---|
| `P, a` | mm, m/s² | vị trí & gia tốc đầu công tác (TCP) |
| `θ_i, θ̈_i` | rad, rad/s² | góc & gia tốc góc khớp i (i=1..3) |
| `l_i` | – | vector đơn vị dọc thanh truyền i |
| `f_i` | N | lực dọc mỗi **cặp** thanh truyền i |
| `F_ee` | N | lực quán tính+trọng lượng tại TCP |
| `m_ee` | kg | khối lượng quy về TCP = bàn máy+payload+½ forearm = **8.233** |
| `m_arm` | kg | khối lượng 1 bắp tay DR-005 = **6.912** (đọc CAD) |
| `J_arm` | kg·m² | quán tính bắp tay quanh trục vai = ⅓·m_arm·L1² = **0.383** |
| `J_rot` | kg·m² | quán tính rotor+hộp số quy về trục ra = J_mot·i² = **0.071** |
| `Jv` | mm/rad | Jacobian vận tốc: Ṗ = Jv·θ̇ |
| `k_s` | – | hệ số an toàn chọn động cơ = **1.5** |

## Mô hình lực

- **Thanh truyền = thanh 2 lực** (ball joint 2 đầu) → chỉ chịu lực **dọc trục** `l_i`.
- Cân bằng lực bàn máy:  **Σ f_i·l_i = m_ee·(a − g) = F_ee**  *(xem `figs/so_do_phan_bo_luc.png`)*
- **Mô men khớp = mô men TĨNH + mô men ĐỘNG:**
  - τ_tĩnh,i = [Jvᵀ·(−m_ee·g)]_i  +  m_arm·g·(L1/2)·cosθ_i   *(giữ trọng lượng TCP + bắp tay)*
  - τ_động,i = [Jvᵀ·(m_ee·a)]_i  +  (J_arm+J_rot)·θ̈_i          *(quán tính TCP + bắp tay + rotor)*
- **Điều kiện chọn động cơ:**  M_yc = k_s·(M_tĩnh + M_động) ≤ T2B  ;  M_rms ≤ T_stall  ;  ω_khớp ≤ n2max.

## Kết quả đỉnh (payload 2 kg — đọc từ `out/force_log.txt`)

| Đại lượng | Giá trị |
|---|---:|
| Lực đầu công tác \|F_ee\| | **175.8 N** |
| Lực dọc mỗi cặp forearm \|f_i\| | **122.7 N** (mỗi thanh / ball-joint 61.4 N) |
| Mô men uốn bicep M_max = f·L1 | **~51 N·m** (tại vai) |
| **M_tĩnh** (TCP 22.3 + bắp tay 13.8) | **35.8 N·m** |
| **M_động với TPMA i=55** (TCP 30.8 + bắp tay+rotor 32.0; J_rot=0.6595) | **55.0 N·m** |
| **M_tổng = M_tĩnh + M_động** | **90.9 N·m** |
| **M_yc = k_s·M_tổng** (k_s=1.5) | **136.3 N·m** |

## Kiểm chọn động cơ – hộp số TPMA010S-055T (ĐÃ CHỌN, chạy chính thức 2026-07-15)

Rating (catalog): **T2B = 230 N·m**, stall 110 N·m (≈ liên tục), brake 248 N·m, i = 55,
n2max = 88 rpm, J_mot = 2.18 kg·cm², nặng 8.1 kg. **Đã thay vào CAD DR-000 (2026-07-15,
không phải sửa bracket — giao diện bích y hệt; xem `outputs/gearbox_swap_20260714/`).**

| Điều kiện | Yêu cầu | Rating | Kết quả |
|---|---:|---:|:--|
| Đỉnh: M_yc ≤ T2B | 136.3 | 230 | ✅ **ĐẠT (dư 1.69×)** |
| Liên tục: M_rms ≤ stall | 53.4 | 110 | ✅ **ĐẠT (dư 2.06×)** |
| Tốc độ: ω ≤ n2max | 30.1 rpm | 88 | ✅ ĐẠT |

**Kết luận: TPMA010S-055T đạt cả 3 điều kiện** (log `out/force_log.txt`). Lưu ý M_động tăng
39.2→55.0 N·m so với TPM cũ vì quán tính rotor J_mot·i² lớn hơn 9× — đã nằm trong kiểm tra.

### Vì sao FEA bền/độ võng KHÔNG phải chạy lại sau khi đổi hộp số
1. Tải lên 4 chi tiết FEA đến từ động lực học bàn máy `m_ee(a−g)` — quỹ đạo và khối lượng
   **chuyển động** không đổi (hộp số gắn phía đế). Chạy lại xác nhận: F_ee 175.8 N, thanh
   truyền 61.4 N, uốn bắp tay ~51 N·m — **y nguyên bảng tải FEA cũ**.
2. Phần M_động tăng thêm do rotor tiêu trong lòng hộp số (gia tốc chính rotor), không truyền
   qua bích ra / cánh tay.
3. Đế DR-001 nhận thêm 3×3.2=9.6 kg tĩnh (~+4% tải) — FOS 397 → vẫn ~380, không đáng kể.

### Kiểm chọn TPM-010S-061T CŨ (lý do phải thay — giữ làm bằng chứng)

| Điều kiện | Yêu cầu | Rating | Kết quả |
|---|---:|---:|:--|
| Đỉnh: M_yc ≤ T2B | 112.5 | 80 | **❌ KHÔNG ĐẠT** (0.71×) |
| Liên tục: M_rms ≤ stall | 45.4 | 29 | **❌ KHÔNG ĐẠT** |
| Tốc độ: ω ≤ n2max | 30.1 rpm | 98 | ✅ ĐẠT |

Với đúng phương pháp (tĩnh + động × hệ số an toàn) và **có kể trọng lượng/quán tính bắp tay
6.9 kg**, TPM-010S-061T không đủ; bỏ cả hệ số an toàn (M_tổng 75 ≈ 80) biên vẫn quá mỏng.
Bản chạy cũ lưu `force_analysis_v1_tpm061_backup.m`.

### So sánh phương án hộp số cùng cỡ 010 (`figs/gearbox_compare.png`)

Tăng tỉ số truyền i làm **tăng T2B** nhưng cũng **tăng quán tính rotor quy đổi J_mot·i²** → M_động
tăng theo. Kiểm lại từng phương án (i=61 & i=55 là số **thật** từ catalog; i=91/100 là **ước lượng
tuyến tính**, cần xác nhận datasheet cymex):

| Phương án | i | M_động | M_yc | T2B | M_rms | stall | Kết luận |
|---|--:|--:|--:|--:|--:|--:|:--|
| TPM 010S-061T DYNAMIC (cũ) | 61 | 39.2 | 112.5 | 80 | 45.4 | 29 | ❌ KHÔNG ĐẠT |
| TPM 010S i=91 DYNAMIC* | 91 | 40.8 | 115.0 | 119 | 46.5 | 43 | ❌ (thiếu liên tục) |
| TPM 010S i=100 DYNAMIC* | 100 | 41.7 | 116.3 | 131 | 47.0 | 48 | ✅ (sát, ước lượng) |
| **TPMA 010S-055T HIGH TORQUE (ĐÃ CHỌN)** | 55 | 55.0 | **136.3** | **230** | 53.4 | 110 | ✅ **ĐẠT dư 1.69×** |

**Đã chọn và thay vào CAD: TPMA 010S-055T** (dòng TPM+ HIGH TORQUE, **cùng cỡ 010**) — số liệu
thật, đạt cả 3 điều kiện với biên đỉnh 1.69× và biên liên tục 2.06×. Đường DYNAMIC tăng ratio
thuần chỉ đủ ở ~i=100 và **sát ngưỡng liên tục**, lại phụ thuộc ratio có trong catalog.
Tích hợp thực tế (đo CAD 2026-07-15): mã bích 094C hoá ra **y hệt 064A từ mặt bích ra**
(Ø117.5×7 / ngõng Ø90 / pilot Ø63 / BC Ø50) → **không phải sửa bracket nào**; dài thêm 63 mm
dồn về đuôi động cơ (vùng trống), nặng hơn 8.1 vs 4.9 kg (về phía đế).

*Ghi chú độ bảo thủ:* J_arm dùng mô hình thanh mảnh đều (hub nặng gần trục ⇒ J thật nhỏ hơn);
M_tổng cộng đỉnh tĩnh+động (không xảy ra đồng thời). Số thật thấp hơn đôi chút nhưng **không đổi
kết luận** vì đã vượt ngưỡng khá nhiều.

## Bảng tải dùng cho FEA (không đổi — vẫn hợp lệ)

| Chi tiết | Tải áp dụng |
|---|---|
| DR-006 Elbow-Clevis | 123 N (1 cặp forearm, chia 2 lỗ rod) |
| 6516K305 Rod (carbon) | 61.4 N dọc trục (nén/kéo — kiểm oằn Euler) |
| DR-007 Moving-Platform | 61.4 N mỗi điểm bắt (6 điểm) |
| DR-005-2 Upper-Arm-Link | mô men uốn ~52 N·m tại vai (xem `bieu_do_noi_luc.png`) |
