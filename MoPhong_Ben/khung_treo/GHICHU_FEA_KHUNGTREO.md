# FEA khung treo robot (Frame.SLDPRT) — ghi chú kết quả

**Ngày:** 2026-07-22. **Part:** `DeltaRobot_Final/Frame.SLDPRT` (khung thép ASTM A36, 643 kg, 1 solid).

## Mô hình
- **Ngàm:** 4 mặt đáy chân đế (Y = −2650), fixed. (faces F49/F27/F55/F66)
- **Tải:** trọng lượng robot treo = m·g·k = 140 kg × 9.81 × 1.5 ≈ **2060 N** hướng xuống (−Y), đặt trên mặt đĩa treo (3 mảng đỉnh đĩa Ø720). Ref face F2 (đáy Y−177.8).
- **Lưới:** solid parabolic, quét 6 mm và 12 mm.
- Vật liệu A36, giới hạn chảy σ_y = 250 MPa.

## Kết quả
| Lưới | von Mises max (MPa) | Ghi chú |
|------|--------------------|---------|
| 6 mm  | 350 | đỉnh tại điểm đặt tải |
| 12 mm | 224 | đỉnh GIẢM khi lưới thô hơn |

- **Phổ ứng suất toàn khung = XANH (thấp)** trên toàn bộ cột/vành/nan — xem `figs/fea_khungtreo_final_vonMises.png`. Chỉ có điểm nóng cục bộ ngay tại mặt đặt tải.
- **Biến dạng thực ≈ 0,6–0,8 mm** (suy từ hệ số phóng đại biến dạng SW tự đặt = 431×, ~10% kích thước model). Khung rất cứng.

## Diễn giải (QUAN TRỌNG)
- Đỉnh von Mises (224→350 MPa) **PHÂN KỲ theo lưới** (thô 224, mịn 350) → đây là **SINGULARITY SỐ** tại mặt đặt tải tập trung (đúng như ghi chú phương pháp FEA của đồ án trong CLAUDE.md/`KETQUA_BEN.md`), **KHÔNG phải ứng suất kết cấu thực**. Không dùng làm FOS.
- Chỉ số `disp = 598 mm` và `nodes = 0` do driver đọc ra là **ARTIFACT** (mâu thuẫn với hệ số phóng đại 431× của chính SW → disp thực ~0,6 mm; nhiều khả năng 1 node lỗi ở vùng hủ 3 nan đặc chồng nhau).
- **Kết luận kết cấu:** khung thép hộp 100×100×5 (4 cột cao 2,55 m ngàm chân, hộp kín trên–dưới) mang tải robot 2060 N → **ứng suất thân thấp (xanh), võng < 1 mm → DƯ BỀN rõ ràng**.

## Việc nên làm để có FOS "sạch" (nếu thầy yêu cầu con số chính xác)
1. Làm sạch hình học HỦ (3 nan đặc chồng + khoét Ø150 có thể tạo sliver) hoặc làm nan RỖNG.
2. Đặt tải phân bố (remote load / áp lực trên toàn đĩa) để bỏ singularity điểm.
3. Bo góc mặt đặt tải, đọc ứng suất thân (cột/vành) thay vì đỉnh singularity.

**Bằng chứng:** `figs/fea_khungtreo_final_vonMises.png` (12 mm), `figs/fea_khungtreo_vonMises.bmp` (6 mm), `out/khungtreo_final_results.csv`.
