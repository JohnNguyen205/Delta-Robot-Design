# TÍNH TOÁN CHI TIẾT ĐỘNG HỌC DELTA ROBOT (THUẬN – NGHỊCH – GIỚI HẠN GÓC)

> Bản tính toán số cụ thể cho robot delta HCMUTE: dẫn công thức rõ ràng, tính từng bước động học
> nghịch và thuận với số liệu thực, xác định giới hạn góc quay và vùng tọa độ với tới. Mọi con số
> trung gian được tính bằng MATLAB (`delta_ik.m`, `delta_fk.m`) — không làm tròn tùy tiện.

**Thông số hình học:** R = 347 mm; r = 120,6 mm; R−r = 226,4 mm; L1 = 407,5 mm; L2 = 1000 mm;
phương vị 3 cánh tay φ = [−90°; 30°; 150°]; giới hạn góc khớp θ ∈ [−45°; 100°].

---

## 1. Hệ tọa độ và tọa độ khớp đế

Gốc tọa độ đặt tại tâm mặt vai (mặt phẳng chứa 3 trục động cơ), trục z hướng xuống dưới (âm).
Ba **khớp đế** Bᵢ (trục quay động cơ) cố định trên vòng bán kính R:

$$\mathbf{B}_i = R\,[\cos\varphi_i,\ \sin\varphi_i,\ 0]^\mathsf{T} \quad (1)$$

| Khớp đế | φᵢ | Bᵢ = (x, y, z) mm |
|---|---|---|
| B₁ | −90° | (0; −347,0; 0) |
| B₂ | 30° | (300,5; 173,5; 0) |
| B₃ | 150° | (−300,5; 173,5; 0) |

Các điểm khác: **khuỷu** Eᵢ, **khớp bàn máy** Pᵢ:
$$\mathbf{E}_i = \mathbf{B}_i + L_1\,[\cos\theta_i\cos\varphi_i,\ \cos\theta_i\sin\varphi_i,\ -\sin\theta_i]^\mathsf{T} \quad (2)$$
$$\mathbf{P}_i = \mathbf{P} + r\,[\cos\varphi_i,\ \sin\varphi_i,\ 0]^\mathsf{T} \quad (3)$$

Ràng buộc chiều dài cẳng tay dùng cho cả hai bài toán:
$$\lVert \mathbf{E}_i - \mathbf{P}_i \rVert = L_2 \qquad (i = 1,2,3) \quad (4)$$

---

## 2. Công thức động học (tóm tắt để tra cứu)

**Động học nghịch (P → θ):** với mỗi cánh tay đặt
$$u_i = x\cos\varphi_i + y\sin\varphi_i - (R-r),\qquad w_i = -x\sin\varphi_i + y\cos\varphi_i \quad (5)$$
$$E_i = 2L_1 z,\quad F_i = -2L_1 u_i,\quad G_i = L_1^2 + u_i^2 + w_i^2 + z^2 - L_2^2 \quad (6)$$
$$\rho_i = \sqrt{E_i^2 + F_i^2},\quad \psi_i = \operatorname{atan2}(F_i, E_i),\quad \theta_i = \arcsin\left(\frac{-G_i}{\rho_i}\right) - \psi_i \quad (7)$$
Điều kiện với tới: $\lvert G_i \rvert \le \rho_i$. Chọn nghiệm trong [−45°; 100°], lấy góc nhỏ hơn.

**Động học thuận (θ → P):** tâm cầu ảo $\mathbf{C}_i = \mathbf{E}_i - r[\cos\varphi_i, \sin\varphi_i, 0]^\mathsf{T}$;
P là giao 3 mặt cầu bán kính L2 tâm Cᵢ (chọn nghiệm z thấp hơn).

---

## 3. Tính toán động học NGHỊCH chi tiết

**Đề bài:** cho vị trí bàn máy P = (150; −100; −900) mm, tìm 3 góc khớp.

Áp dụng (5)–(7) cho từng cánh tay, các bước trung gian:

| Đại lượng | Cánh tay 1 (φ=−90°) | Cánh tay 2 (φ=30°) | Cánh tay 3 (φ=150°) |
|---|---|---|---|
| cosφ, sinφ | 0 ; −1 | 0,866 ; 0,5 | −0,866 ; 0,5 |
| a = x·cosφ + y·sinφ | 100,0 | 79,9 | −179,9 |
| **uᵢ** = a − (R−r) | −126,4 | −146,5 | −406,3 |
| **wᵢ** = −x·sinφ + y·cosφ | 150,0 | −161,6 | 11,6 |
| Eᵢ = 2·L1·z | −733 500 | −733 500 | −733 500 |
| Fᵢ = −2·L1·uᵢ | 103 016 | 119 394 | 331 138 |
| Gᵢ | 14 533 | 23 633 | 141 274 |
| ρᵢ = √(Eᵢ²+Fᵢ²) | 740 699 | 743 154 | 804 782 |
| −Gᵢ/ρᵢ | −0,0196 | −0,0318 | −0,1755 |
| ψᵢ = atan2(Fᵢ,Eᵢ) | 172,01° | 170,75° | 155,70° |
| 2 nghiệm ứng viên | −173,1° ; **9,12°** | −172,6° ; **11,07°** | −165,8° ; **34,41°** |
| **θᵢ** (trong giới hạn) | **9,12°** | **11,07°** | **34,41°** |

**Kết quả:** θ = (9,12°; 11,07°; 34,41°). Cả 3 góc nằm trong [−45°; 100°] và thỏa
|Gᵢ| ≤ ρᵢ → điểm **với tới được**, cấu hình hợp lệ.

*Ví dụ chi tiết cánh tay 1:* u₁ = 150·0 + (−100)·(−1) − 226,4 = 100 − 226,4 = −126,4 mm;
w₁ = −150·(−1) + (−100)·0 = 150 mm; G₁ = 407,5² + 126,4² + 150² + 900² − 1000² = 14 533;
ρ₁ = 740 699; θ₁ = arcsin(0,0196·(−1)) − 172,01° = wrap(−173,13° ; 9,12°) → chọn **9,12°**.

---

## 4. Tính toán động học THUẬN chi tiết

**Đề bài:** cho 3 góc khớp θ = (30°; 20°; 40°), tìm vị trí bàn máy P.

**Bước 1 — tọa độ khuỷu Eᵢ và tâm cầu ảo Cᵢ** (theo (2) và Cᵢ = Eᵢ − r·[cosφ,sinφ,0]):

| Cánh tay | Bᵢ (mm) | Eᵢ (mm) | Cᵢ (mm) |
|---|---|---|---|
| 1 (φ=−90°, θ=30°) | (0; −347,0; 0) | (0; −699,9; −203,7) | (0; −579,3; −203,7) |
| 2 (φ=30°, θ=20°) | (300,5; 173,5; 0) | (632,1; 365,0; −139,4) | (527,7; 304,7; −139,4) |
| 3 (φ=150°, θ=40°) | (−300,5; 173,5; 0) | (−570,9; 329,6; −261,9) | (−466,4; 269,3; −261,9) |

**Bước 2 — giao 3 mặt cầu** (bán kính L2 = 1000, tâm Cᵢ). Trừ cặp phương trình để tuyến tính hóa:
$$2(\mathbf{C}_2 - \mathbf{C}_1)\cdot\mathbf{P} = \lVert \mathbf{C}_2 \rVert^2 - \lVert \mathbf{C}_1 \rVert^2,\qquad
  2(\mathbf{C}_3 - \mathbf{C}_1)\cdot\mathbf{P} = \lVert \mathbf{C}_3 \rVert^2 - \lVert \mathbf{C}_1 \rVert^2 \quad (8)$$

Giao 2 mặt phẳng cho đường thẳng **P = P₀ + t·d**:
- P₀ = (15,9; −2,0; 2,0) mm (nghiệm min-norm)
- d = (C₂−C₁) × (C₃−C₁) = (−424 255; 2 713; 3 440 329)

**Bước 3 — thế vào mặt cầu 1**, được phương trình bậc hai theo t (a·t² + b·t + c = 0):
- a = d·d = 1,202×10¹³ ; b = 2·d·(P₀−C₁) = 1,405×10⁹ ; c = |P₀−C₁|² − L2² = −6,241×10⁵
- Biệt thức Δ = b² − 4ac = 3,197×10¹⁹ > 0 → hai nghiệm:
- t₁ = +0,0002 → Pₐ = (−59,1; −1,5; **+610,3**) ; t₂ = −0,0003 → P_b = (140,6; −2,8; **−1008,6**)

**Bước 4 — chọn nghiệm z thấp hơn** (bàn máy nằm dưới đế):
$$\boxed{\ \mathbf{P} = (140{,}6;\ -2{,}8;\ -1008{,}6)\ \text{mm}\ }$$

Nghiệm Pₐ (z = +610) bị loại vì nằm phía trên mặt vai (không khả thi cơ khí).

---

## 5. Tính toán GIỚI HẠN GÓC QUAY và vùng tọa độ với tới

**Giới hạn góc khớp:** θᵢ ∈ [θ_min; θ_max] = [−45°; 100°]. Đây là giới hạn cơ cấu/hộp số; ngoài
khoảng này động cơ không quay tới hoặc cánh tay va chạm.

**Ánh xạ giới hạn góc → tọa độ z trên trục (x = y = 0):** đặt 3 góc bằng nhau θ₀ rồi giải động học
thuận, thu được vị trí bàn máy trên trục z:

| θ₀ (3 khớp bằng nhau) | z bàn máy (mm) | Ghi chú |
|---|---|---|
| −45° | −569,3 | **cao nhất** (cánh tay nâng hết) |
| −20° | −653,5 | |
| 0° | −773,4 | bicep nằm ngang |
| **19,15°** | **−925,0** | **tư thế HOME** (tâm vùng làm việc) |
| 50° | −1184,8 | |
| 80° | −1356,1 | |
| 100° | −1389,1 | **thấp nhất** (cánh tay hạ hết) |

→ Trên trục, giới hạn góc [−45°; 100°] cho **khoảng z với tới [−569,3; −1389,1] mm**. Trụ làm việc
mục tiêu (z ∈ [−1050; −800]) **nằm gọn** trong khoảng này.

**Bán kính với tới theo phương ngang tại z = −925 mm:** quét động học nghịch theo bán kính, điểm còn
nghiệm hợp lệ tới **bán kính ≥ 650 mm**, trong khi yêu cầu chỉ 400 mm (bán kính trụ Ø800). → dư địa lớn.

**Kết luận vùng làm việc:** trụ mục tiêu **Ø800 × 250 mm** tại z = −925 nằm gọn trong vùng với tới,
không chạm giới hạn góc, không có điểm kỳ dị (số điều kiện Jacobian ≤ 2,75; góc truyền ≥ 49,8°).

---

## 6. Bảng tọa độ tổng hợp một số tư thế

| Tư thế | θ = (θ₁,θ₂,θ₃) | Vị trí bàn máy P (mm) |
|---|---|---|
| HOME (đối xứng) | (19,15°; 19,15°; 19,15°) | (0; 0; −925,0) |
| Ví dụ IK (§3) | (9,12°; 11,07°; 34,41°) | (150; −100; −900) |
| Ví dụ FK (§4) | (30°; 20°; 40°) | (140,6; −2,8; −1008,6) |
| Cao nhất trên trục | (−45°; −45°; −45°) | (0; 0; −569,3) |
| Thấp nhất trên trục | (100°; 100°; 100°) | (0; 0; −1389,1) |

---

## 7. Kiểm chứng và kết luận

- **Kiểm chứng khép kín** FK(IK(P)) trên 3000 điểm: sai số lớn nhất **6,2×10⁻¹³ mm** (cỡ độ chính xác
  máy) → công thức và tính toán **chính xác, nhất quán**.
- Động học **nghịch** giải bằng công thức đóng (5)–(7); động học **thuận** giải bằng giao ba mặt cầu (8).
- Giới hạn góc [−45°; 100°] cho vùng với tới bao trọn trụ làm việc Ø800 × 250, dư địa lớn, không kỳ dị.

**Tệp nguồn:** `delta_ik.m`, `delta_fk.m`, `delta_jacobian.m` (MATLAB); giao diện `delta_gui_simple.m`;
bản dẫn công thức đầy đủ `THUYETMINH_DONGHOC_CHITIET.md`; tóm tắt kết quả `KETQUA_DONGHOC.md`.
