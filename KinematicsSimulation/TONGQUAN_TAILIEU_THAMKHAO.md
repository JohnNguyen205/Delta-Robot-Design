---
title: "TỔNG QUAN VÀ TÓM LƯỢC CÁC TÀI LIỆU THAM KHẢO"
subtitle: "Đồ án tốt nghiệp – Thiết kế robot Delta"
author: "HCMUTE"
date: "18/07/2026"
lang: vi
---

# TỔNG QUAN VÀ TÓM LƯỢC CÁC TÀI LIỆU THAM KHẢO

**Chủ đề:** Robot Delta song song – động học, động lực học, thiết kế, mô phỏng và điều khiển

Báo cáo này tổng hợp và tóm lược nội dung của **18 tài liệu tham khảo** (bài báo khoa học, luận văn, catalog kỹ thuật) được thu thập trong thư mục `DoAnThamKhao`. Mỗi tài liệu được trình bày theo bố cục: *thông tin xuất bản – mục tiêu và nội dung nghiên cứu – phương pháp – kết quả đạt được*, với độ dài không quá 2 trang. Các tài liệu được nhóm theo chủ đề để thuận tiện cho việc xây dựng phần cơ sở lý thuyết và tổng quan của đồ án.

**Phân nhóm tài liệu:**

- **Nhóm A – Động học và thiết kế hình học** (7 tài liệu): các lời giải động học thuận/ngược, phân tích vùng làm việc, phương pháp thiết kế và tối ưu kích thước.
- **Nhóm B – Động lực học và điều khiển mô-men** (2 tài liệu).
- **Nhóm C – Quy hoạch và tối ưu quỹ đạo** (3 tài liệu).
- **Nhóm D – Sai số, độ chính xác và độ tin cậy** (2 tài liệu).
- **Nhóm E – Ứng dụng thực tế kết hợp thị giác máy** (2 tài liệu).
- **Nhóm F – Tài liệu tham khảo bổ trợ** (2 tài liệu).

\newpage

# NHÓM A – ĐỘNG HỌC VÀ THIẾT KẾ HÌNH HỌC

## A1. Williams II (2016) – *The Delta Parallel Robot: Kinematics Solutions*

**Thông tin:** R. L. Williams II, Ph.D., Mechanical Engineering, Ohio University, Internet Publication, 2016 *(tệp: Kinematic\_Vo.pdf)*.

**Mục tiêu và nội dung:** Đây là tài liệu nền tảng, được trích dẫn rộng rãi nhất về động học robot Delta. Tác giả trình bày mô tả đầy đủ cấu trúc robot Delta 3 bậc tự do (3-DOF) tịnh tiến XYZ với ba chân giống nhau dạng **RUU** (Revolute – Universal – Universal) nối tấm đế cố định với tấm động, cùng cơ cấu hình bình hành đảm bảo tấm động luôn song song với đế. Tài liệu xét cả hai biến thể: dẫn động khớp quay (revolute-input) và dẫn động khớp tịnh tiến (prismatic-input).

**Phương pháp:** Sử dụng phương pháp giải tích véctơ. Bài toán động học ngược (IPK) được giải bằng cách chiếu các ràng buộc hình học của từng chân, dẫn tới phương trình dạng $A\cos\theta + B\sin\theta + C = 0$ cho mỗi góc khớp; bài toán động học thuận (FPK) được đưa về **bài toán giao ba mặt cầu** (three-spheres intersection). Ngoài ra tài liệu suy diễn đầy đủ các phương trình vận tốc (ma trận Jacobian) cho cả hai loại robot.

**Kết quả:** Cung cấp lời giải giải tích tường minh cho IPK và FPK, kèm nhiều ví dụ số (snapshot và quỹ đạo), thuật toán giao ba mặt cầu (Phụ lục A, B) và phân tích các trường hợp đặc biệt (nghiệm ảo, điểm kỳ dị, đa nghiệm). Đây là bộ công thức được dùng làm chuẩn tham chiếu cho hầu hết các nghiên cứu Delta về sau, **là cơ sở lý thuyết trực tiếp cho phần động học của đồ án.**

## A2. Lê Xuân Hoàng, Lê Hoài Nam (2018) – *Bài toán động học, động lực học và phương pháp thiết kế hình học cho robot Delta kiểu ba khớp quay (RUU)*

**Thông tin:** Tạp chí Khoa học và Công nghệ ĐH Đà Nẵng, số 11(132).2018, Q.1, ISSN 1859-1531 *(tệp: 1528-…-20210415.pdf)*. Đây là tài liệu **tiếng Việt** duy nhất trong tập tham khảo.

**Mục tiêu và nội dung:** Trình bày một cách hệ thống các vấn đề cơ bản của robot Delta: mô hình hóa, động học, động lực học; đồng thời **phân loại chi tiết vùng làm việc** và xác định mặt cầu nội tiếp lớn nhất bên trong vùng làm việc, từ đó đề xuất phương pháp thiết kế hình học.

**Phương pháp:** Kế thừa mô hình hóa của Williams; giải động học ngược đa nghiệm bằng phương pháp số **Newton–Raphson** để chọn nghiệm phù hợp. Động lực học dùng phương trình **Lagrange dạng nhân tử** với 6 tọa độ suy rộng, quy khối lượng thanh hình bình hành về hai đầu khớp để đơn giản hóa. Vùng làm việc được biểu diễn qua giao của ba vùng hình xuyến (torus: ring/horn/spindle), quy về hình trụ nội tiếp trong mặt cầu.

**Kết quả:** Xác lập hệ bất phương trình phân biệt các vùng làm việc (Ia, Ib, IIa–IIf, IIIa, IIIb) và chỉ ra **bốn vùng phù hợp thực tế thiết kế** (Ib, IIe, IIf, IIIb có thể tích lớn nhất). Đề xuất **hai phương án thiết kế**: PA1 cho robot cỡ nhỏ, PA2 cho robot cỡ lớn. Ví dụ áp dụng (vùng làm việc cỡ khổ A4 210×297, cao 150 mm) cho kích thước tối ưu $r=227$, $L=197$, chọn vùng IIf/PA1. Kết luận: thiết kế hình học là tiền đề cho thiết kế chi tiết — **phương pháp luận sát với hướng làm của đồ án.**

## A3. Hong, Lim, Lee, Shin (2024) – *The Workspace Analysis of the Delta Robot Using a Cross-Section Diagram Based on Zero Platform*

**Thông tin:** *Machines* 2024, 12, 583, MDPI (Kumoh National Institute of Technology, Hàn Quốc) *(tệp: Joint.pdf)*.

**Mục tiêu và nội dung:** Đề xuất khái niệm mới **"robot Delta tấm-không" (zero-platform)** với ba tham số then chốt chi phối hình dạng và kích thước vùng làm việc, nhằm ước lượng nhanh vùng làm việc mà không cần tính toán số phức tạp.

**Phương pháp:** Đưa cấu hình hình xuyến (torus) trực tiếp vào các thanh của robot; vùng làm việc được xác định bằng **giao của ba biểu đồ mặt cắt (cross-section diagram)** chỉ dùng phép toán 2D trên torus, thay cho việc giải hệ phương trình ràng buộc hay phương pháp số.

**Kết quả:** So sánh vùng làm việc dựng bằng biểu đồ mặt cắt với phần mềm CAD 3D cho thấy phương pháp **ước lượng nhanh và trực quan hơn** về mặt hình học hình dạng, kích thước vùng làm việc. Đóng góp một công cụ hình học tiện dụng cho giai đoạn thiết kế sơ bộ.

## A4. Altuzarra, Urizar, Bilbao, Hernández (2024) – *Full Forward Kinematics of Lower-Mobility Planar Parallel Continuum Robots*

**Thông tin:** *Mathematics* 2024, 12, 3562, MDPI (University of the Basque Country, Tây Ban Nha) *(tệp: Full\_Forward\_Kinematics\_…\_Planar\_P.pdf)*.

**Mục tiêu và nội dung:** Mở rộng khái niệm Delta sang **robot liên tục song song (Parallel Continuum Manipulator – PCM)**, trong đó các thanh cứng được thay bằng thanh mềm đàn hồi. Nghiên cứu giải bài toán động học thuận đầy đủ và khảo sát vùng làm việc "gần-tịnh-tiến" của cơ cấu Keops–Delta phẳng dạng mềm.

**Phương pháp:** Mô hình hóa thanh mềm bằng **lý thuyết Cosserat (mô hình Kirchhoff đơn giản hóa)**, kết hợp cân bằng lực toàn hệ dẫn tới hệ phương trình vi phân phi tuyến. Đề xuất hai phương pháp giải FK: một phương pháp tìm **tất cả** nghiệm (chế độ lắp ráp), một phương pháp tìm nghiệm lân cận; kèm kiểm tra ổn định và tối ưu kích thước.

**Kết quả:** Chứng minh rằng **thay thanh cứng bằng thanh mềm không đơn thuần** — tùy phương án thiết kế và chế độ lắp ráp mà xuất hiện **góc nghiêng ký sinh (parasitic angle)** làm tấm động không còn tịnh tiến thuần túy. Đưa ra các cân nhắc thiết kế để đạt chuyển động gần-tịnh-tiến tối ưu. Tài liệu mang tính lý thuyết nâng cao, hữu ích để hiểu giới hạn của giả thiết "thanh cứng" trong mô hình Delta cổ điển.

## A5. Daneshjo, Ščerba, Ševčíková, Al-Rabeei, Mir (2025) – *Simulation Modeling of Kinematic Structures of Parallel Mechanisms*

**Thông tin:** *Engineering, Technology & Applied Science Research (ETASR)*, Vol. 15, No. 2, 2025, tr. 20714–20721 *(tệp: Simulation\_Modeling\_…\_Par.pdf)*.

**Mục tiêu và nội dung:** Nghiên cứu thiết kế mô hình robot Delta trong hệ **Pro/ENGINEER**, bao gồm thiết kế và tính bền các chi tiết, xác định vùng làm việc, với trọng tâm giải pháp thiết kế cơ khí cụ thể.

**Phương pháp:** Xác định sơ đồ động học Delta 3-DOF dạng **3R(SS)(SS)** (suy ra từ robot Hexa 6-DOF). Trình bày hai phương án khớp các-đăng (tương đương universal joint dùng bạc trượt + ổ bi cầu, và khớp cầu). Chọn cơ cấu chấp hành cuối là **giác hút chân không** (đĩa hút ZPT25CN-B01, tải tối đa 0,5 kg) với hệ số an toàn kẹp $k_P=4$; tính áp suất chân không cần thiết để chọn bộ tạo chân không (EZH 10BS, 46 kPa).

**Kết quả:** Hoàn thiện mô hình 3D robot Delta và lựa chọn linh kiện (tấm trên L-profile thép 11 343, tấm động thép 11 500 dày 5 mm, khớp cầu thép BS.970). Kết luận khẳng định ưu điểm của cơ cấu song song (độ cứng vững cao, động học tốt nhờ chuỗi kín) nhưng cũng lưu ý mức độ thương mại hóa còn hạn chế. **Tham chiếu tốt về quy trình thiết kế chi tiết + chọn giác hút cho end-effector.**

## A6. Pandolfi, Bilancia, Pellicciari (2025) – *An Integrated Engineering Approach for the Preliminary Design and Synthesis of Delta Robots*

**Thông tin:** *International Journal on Interactive Design and Manufacturing (IJIDeM)*, 2025, Springer (University of Modena and Reggio Emilia, Ý) *(tệp: s12008-025-02443-y.pdf)*.

**Mục tiêu và nội dung:** Đề xuất một **phương pháp và công cụ kỹ thuật tích hợp** để tổng hợp kích thước tối ưu robot Delta, xét đồng thời động học, động lực học, **độ mềm của thanh (link flexibility)** và **khe hở khớp cầu (ball joint clearance)** — những yếu tố mà các phương pháp trước thường bỏ qua ở giai đoạn thiết kế. Đầu vào là yêu cầu người dùng: kích thước bao (bounding box), số chu kỳ/phút (CPM), tải tĩnh tối đa, sai số cho phép của end-effector, và tối thiểu chi phí.

**Phương pháp:** (1) Pha tối ưu động lực học bằng **thuật toán di truyền (GA)** với mô hình giải tích trong MATLAB để tìm bộ kích thước tối ưu, dùng **mô-men RMS lớn nhất trong ba động cơ** làm hàm mục tiêu; ràng buộc tránh kỳ dị bằng giới hạn góc truyền động $45^\circ \le \gamma \le 135^\circ$ và thể tích tứ diện các véctơ thanh. (2) Kiểm chứng ảo bằng **mô phỏng đa vật thể mềm RecurDyn** (thanh mô hình phần tử dầm 1D, khe hở khớp cầu 0,1 mm). Vùng làm việc hình trụ: đường kính ≈75% cạnh nhỏ bounding box, cao ≈35% đường kính; luật thời gian Double-S.

**Kết quả:** GA cấu hình 500 thế hệ, quần thể 600, cho ra bộ kích thước tối ưu ($r_{min}=100$, $R_{min}=200$, $b_{min}=100$ mm). Quy trình lặp đảm bảo thiết kế cuối đáp ứng yêu cầu và tối thiểu kích cỡ động cơ. Đề xuất phương pháp đánh giá hiệu năng qua đồ thị **gia tốc end-effector theo tải trọng**. Công cụ đã được áp dụng thành công thiết kế một manipulator thực trong dự án công nghiệp (nguyên mẫu đang chế tạo). **Đây là tài liệu sát nhất với toàn bộ quy trình đồ án (thiết kế → tối ưu → mô phỏng bền → chọn động cơ).**

## A7. Ren, Zheng, Wang (2026) – *Influence of Structural Parameters on the Workspace of Delta Parallel Robots and Path Adaptability Optimization for Tea Fresh Leaf Sorting*

**Thông tin:** *Scientific Reports* (2026) 16:6651, Nature *(tệp: s41598-026-35969-6.pdf)*.

**Mục tiêu và nội dung:** Với yêu cầu "tốc độ cao – chính xác cao – ít hư hại" khi phân loại lá trà tươi, nghiên cứu mô phỏng vùng làm việc trên MATLAB để tìm bộ tham số kết cấu tối ưu thích ứng với quỹ đạo hình cổng (gate-shaped, "gắp–nâng–di chuyển–đặt").

**Phương pháp:** Xây dựng mô hình động học thuận/ngược; chọn bốn tham số kết cấu — chiều dài cánh tay chủ động $L$, cánh tay bị động $l$, bán kính đế $R$, bán kính tấm động $r$ — làm nhân tố khảo sát. Dùng **bảng trực giao L9** thiết kế thí nghiệm, tính thể tích vùng làm việc từng bộ, đánh giá phủ quỹ đạo cổng (200×400×200 mm) bằng trực quan hóa, và **phân tích cực sai (range analysis)** để xác định trọng số ảnh hưởng.

**Kết quả:** Thứ tự ảnh hưởng tới vùng làm việc: **$l > L > R > r$** (cánh tay bị động ảnh hưởng mạnh nhất). Bộ tham số tối ưu (Nhóm 8: $L=250$, $l=400$, $R=90$, $r=50$ mm) đạt cân bằng tốt nhất giữa vùng làm việc và tính năng chuyển động, **phủ hoàn toàn quỹ đạo cổng** yêu cầu. Cung cấp phương pháp định lượng quan hệ tham số–vùng làm việc, giải quyết vấn đề thích ứng quỹ đạo kém của robot phân loại truyền thống.

\newpage

# NHÓM B – ĐỘNG LỰC HỌC VÀ ĐIỀU KHIỂN MÔ-MEN

## B1. Cretescu, Neagoe, Saulescu (2023) – *Dynamic Analysis of a Delta Parallel Robot with Flexible Links and Joint Clearances*

**Thông tin:** *Applied Sciences* 2023, 13, 6693, MDPI (Transilvania University of Brasov, Romania) *(tệp: Analyze.pdf = Dynamic\_Analysis\_…\_Fl.pdf)*.

**Mục tiêu và nội dung:** Phân tích ảnh hưởng **đồng thời** của ba yếu tố tới hành vi động lực học robot Delta: **khe hở (clearance)** và **ma sát (friction)** trong khớp cầu, cùng **độ mềm (flexibility)** của thanh — khoảng trống mà theo tác giả chưa có nghiên cứu nào xét gộp cả ba.

**Phương pháp:** Mô hình hóa CAD trong **CATIA**, xuất thân thể 3D (định dạng IGES) sang **ADAMS** để mô phỏng chuyển động trên quỹ đạo không gian đại diện, đạt tới giá trị vận tốc/gia tốc tối đa cho phép (tải 5 kg, gia tốc cuối tới 120 m/s²). Khảo sát 7 kịch bản (S1–S7) tách và ghép các yếu tố.

**Kết quả:** Các hiệu ứng **tương tác lẫn nhau nhưng không cộng dồn tuyến tính (not cumulative)** — khi xét đồng thời khe hở và đàn hồi, độ lệch có thể tăng vượt tổng riêng lẻ. Kết luận quan trọng: **không nên mô phỏng tách riêng rồi cộng các yếu tố**; do bản chất phi tuyến, cần cách tiếp cận ghép hợp. Đề xuất kiểm chứng thực nghiệm trong tương lai. **Cảnh báo hữu ích cho phần mô phỏng bền/động lực học của đồ án về giới hạn giả thiết thanh cứng, khớp lý tưởng.**

## B2. Zhang, Liu, Yan, Han, Bi (2022) – *Dynamics Modeling of a Delta Robot with Telescopic Rod for Torque Feedforward Control*

**Thông tin:** *Robotics* 2022, 11, 36, MDPI (Tsinghua University + Robotphoenix) *(tệp: Speed\_joint.pdf = robotics-11-00036-v2.pdf)*.

**Mục tiêu và nội dung:** Xây dựng mô hình động lực học robot Delta **có thanh trục co duỗi ở giữa (telescopic rod)** — thành phần thường bị bỏ qua trong các mô hình chỉ có ba chân — để dùng cho **điều khiển tiền định mô-men (torque feedforward)**.

**Phương pháp:** Thiết lập hai hệ tọa độ suy rộng mô tả quan hệ giữa chuyển động của thanh co duỗi và vị trí tấm động; phân tích kỳ dị để lập động học thanh. Dùng phương pháp **Euler–Lagrange** lập mô hình động lực học của thanh co duỗi (xem như hệ con), rồi chuyển lực do thanh tác động lên tấm động thành mô-men cơ cấu chấp hành qua ma trận Jacobian. Có thực nghiệm nhận dạng tham số quán tính.

**Kết quả:** Thí nghiệm điều khiển tiền định mô-men cho thấy mô hình đề xuất **mô tả mô-men động cơ chính xác hơn** so với mô hình bỏ qua thanh co duỗi, giúp điều khiển robot chính xác hơn. Cung cấp khung lý thuyết cho thiết kế và điều khiển loại robot Delta có thanh trung tâm.

\newpage

# NHÓM C – QUY HOẠCH VÀ TỐI ƯU QUỸ ĐẠO

## C1. Wu, Wang, Jing, Zhao (2022) – *Optimal Time–Jerk Trajectory Planning for Delta Parallel Robot Based on Improved Butterfly Optimization Algorithm*

**Thông tin:** *Applied Sciences* 2022, 12, 8145, MDPI (North University of China) *(tệp: Optimize\_Trajectory.pdf)*.

**Mục tiêu và nội dung:** Nâng cao hiệu năng động lực học của robot Delta gắp-thả tốc độ cao qua quy hoạch quỹ đạo đa mục tiêu, cải thiện độ chính xác định vị động và độ ổn định, đồng thời tăng hiệu suất gắp.

**Phương pháp:** Quỹ đạo gắp-thả xây dựng bằng **đường cong NURBS** trong không gian Descartes (khả vi bậc cao ⇒ jerk liên tục). Lấy **thời gian và jerk** làm mục tiêu tối ưu, đề xuất **thuật toán bướm cải tiến (IBOA)** dựa trên BOA: đưa chuỗi hỗn loạn Circle thay quần thể khởi tạo ngẫu nhiên, dùng vi phân phân số để tăng tốc hội tụ; xử lý biến dạng đoạn song song của quỹ đạo.

**Kết quả:** So với các thuật toán khác, IBOA **giảm 16,2% thời gian tối ưu** và **giảm 87,6% jerk cực đại** (tốt hơn các thuật toán so sánh 14,1% và 27,2%). Mô phỏng chuyển động xác nhận quỹ đạo tối ưu **giảm rõ rệt gia tốc rung** của tấm cuối. Phương pháp áp dụng được cho các robot song song khác.

## C2. Zhu, He, Yu, Li (2023) – *Trajectory Smoothing Planning of Delta Parallel Robot Combining Cartesian and Joint Space*

**Thông tin:** *Mathematics* 2023, 11, 4509, MDPI (Guangzhou University) *(tệp: Tracking\_joint.pdf)*.

**Mục tiêu và nội dung:** Giải quyết **rung và sốc** do gián đoạn tiếp tuyến tại các góc nối của những đoạn thẳng nhỏ trong quỹ đạo — nguyên nhân làm giảm hiệu năng tốc độ cao/độ chính xác cao của robot Delta.

**Phương pháp:** Đề xuất phương pháp quy hoạch **kết hợp không gian Descartes và không gian khớp**. Lập mô hình động học/động lực học đầy đủ bằng phương pháp phân rã véctơ và phương pháp năng lượng vi phân, giải nghịch bằng ma trận giả nghịch đảo (viết chương trình MATLAB R2020a). Quỹ đạo end-effector quy hoạch trong không gian Descartes (chuẩn hóa lấy điểm dữ liệu + điểm điều khiển nghịch), ánh xạ sang không gian khớp rồi làm trơn lần hai bằng **đường B-spline bậc năm (quintic)**.

**Kết quả:** Jerk khớp liên tục trơn, end-effector chuyển động chính xác. **Sai số bám cực đại của khớp 1/2/3 giảm lần lượt 10,53%; 41,18%; 44,44%**; mô-men khớp cực đại giảm tối đa 11,65% — giảm hiệu quả rung và va đập.

## C3. Zhang, Ming (2019) – *Trajectory Planning and Optimization for a Par4 Parallel Robot Based on Energy Consumption*

**Thông tin:** *Applied Sciences* 2019, 9, 2770, MDPI (Xidian University) *(tệp: Trajectory Planning … Par4 … Energy Consumption.pdf)*.

**Mục tiêu và nội dung:** Quy hoạch và tối ưu quỹ đạo gắp-thả tốc độ cao cho robot song song **Par4** (4-DOF, họ hàng của Delta) theo tiêu chí **tối thiểu năng lượng cơ học tiêu thụ**.

**Phương pháp:** Quỹ đạo hình cổng với **chuyển tiếp bo tròn bằng đường cong Lamé** thay góc vuông (tránh gián đoạn gia tốc). Thiết kế phân đoạn cho dịch chuyển/vận tốc/gia tốc; dùng **luật đa thức bậc 5 và bậc 6 bất đối xứng** để giảm rung dư. Quy hoạch ở mức khớp (ánh xạ từ end-effector qua động học ngược). Tối ưu bằng thuật toán **Sói xám (Grey Wolf Optimizer – GWO)**.

**Kết quả:** Kiểm chứng thực nghiệm: **luật đa thức bậc 5 tiêu thụ năng lượng thấp hơn bậc 6.** Tham số $e$ tối ưu của đường Lamé = nửa khẩu độ gắp; tham số $f$ phụ thuộc chiều cao gắp và tọa độ điểm gắp-thả. Năng lượng cũng tăng khi điểm gắp-thả càng gần biên vùng làm việc. Phương pháp áp dụng được cho robot Delta.

\newpage

# NHÓM D – SAI SỐ, ĐỘ CHÍNH XÁC VÀ ĐỘ TIN CẬY

## D1. Yang, Ma, Ma, Sun, Li (2021) – *Sensitivity Analysis of Reliability of Low-Mobility Parallel Mechanisms Based on a Response Surface Method*

**Thông tin:** *Applied Sciences* 2021, 11, 9002, MDPI (Northeastern University, Shenyang) *(tệp: Sensitivity.pdf)*.

**Mục tiêu và nội dung:** Đánh giá **độ tin cậy động học (kinematic reliability)** và độ nhạy độ tin cậy của cơ cấu Delta cải tiến, có xét **tính ngẫu nhiên** của từng thành phần sai số đầu vào — điều các nghiên cứu trước thường bỏ qua, gây kết luận thiếu chính xác.

**Phương pháp:** Lập mô hình động học ngược bằng **biến đổi đồng nhất (homogeneous transform)**; dựa trên xấp xỉ Taylor bậc nhất, xây mô hình sai số gồm sai số tham số hình học, sai số khe hở khớp quay, sai số dẫn động. Dùng **phương pháp mặt đáp ứng (RSM)** (lấy mẫu Box–Behnken) lập hàm trạng thái giới hạn tường minh cho sai số vị trí end-effector, rồi tính độ tin cậy và độ nhạy.

**Kết quả:** Độ tin cậy động học tổ hợp **R = 0,9994**. Độ nhạy mạnh nhất với **kỳ vọng của $a_2$** (rồi $r_{32}$, $a_1$, $a_3$). Việc tăng **phương sai** của mọi biến ngẫu nhiên đều làm giảm độ tin cậy, trong đó **sai số chiều dài cánh tay chủ động** ảnh hưởng lớn nhất. Cung cấp cơ sở lý thuyết cho thiết kế dung sai và hiệu chỉnh độ chính xác.

## D2. Shang, Li, Liu, Cui (2019) – *Research on the Motion Error Analysis and Compensation Strategy of the Delta Robot*

**Thông tin:** *Mathematics* 2019, 7, 411, MDPI (China University of Mining and Technology, Beijing) *(tệp: Research on the Motion Error … .pdf)*.

**Mục tiêu và nội dung:** Phân tích sai số chuyển động và đề xuất **chiến lược bù sai số** để nâng cao độ chính xác chuyển động của robot Delta.

**Phương pháp:** Lập mô hình động học bằng **biến đổi ma trận D–H**; xây mô hình sai số xét đồng thời bốn nguồn: **sai số kích thước, sai số khe hở khớp quay, sai số dẫn động, sai số khe hở khớp cầu**. Phân tích ảnh hưởng từng loại; đề xuất chiến lược **bù bằng cách điều chỉnh góc dẫn động (driving angle)**, kiểm chứng qua ví dụ số.

**Kết quả:** So sánh trước/sau bù cho thấy robot **di chuyển bám sát vị trí mong muốn** — sai số được bù hiệu quả, chứng tỏ phương pháp điều chỉnh góc dẫn động cải thiện độ chính xác chuyển động. Phù hợp làm cơ sở cho phần đánh giá và bù sai số hình học.

\newpage

# NHÓM E – ỨNG DỤNG THỰC TẾ KẾT HỢP THỊ GIÁC MÁY

## E1. Vo Duy Cong, Le Hoai Phuong (2023) – *Design and Development of a Delta Robot System to Classify Objects Using Image Processing*

**Thông tin:** *IJECE*, Vol. 13, No. 3, 6/2023, tr. 2669–2676 (ĐH Bách khoa TP.HCM – HCMUT) *(tệp: Design.pdf)*.

**Mục tiêu và nội dung:** Thiết kế hệ thống phân loại tự động dùng robot Delta gắp vật + băng tải + camera + máy tính xử lý ảnh phân loại theo màu.

**Phương pháp:** Robot Delta 4-DOF (bậc 4 quay quanh trục đứng end-effector), kiến trúc chuỗi động R-(RR)-(RR), dẫn động **3 động cơ servo DC (Planetary GP36, tỉ số 1:14, encoder 500 xung/vòng)**, đế nhôm dày 10 mm, cánh chính bằng ống thép không gỉ, thanh nối carbon; tấm động gắn motor bước Nema 17 + tay kẹp mềm. Điều khiển bằng **Arduino Mega** (phát xung) + **Raspberry Pi 4** (xử lý ảnh). Thuật toán: chuyển ảnh BGR → không gian **HSV**, đặt ngưỡng nhận màu.

**Kết quả:** Độ chính xác phân loại **vật đỏ và vàng 100%, vật xanh 97,5%**; thời gian trung bình **1,8 s/vật**. Hệ thống hoạt động ổn định, có thể mở rộng phân loại theo hình dạng, kích thước, vật liệu. **Tham chiếu trực tiếp cho lựa chọn vật liệu (đế nhôm, cánh thép, thanh carbon) và cơ cấu tay kẹp của đồ án.**

## E2. Le Hoai Phuong, Vo Duy Cong, Thai Thanh Hiep (2023) – *Design a Low-cost Delta Robot Arm for Pick and Place Applications Based on Computer Vision*

**Thông tin:** *FME Transactions* (2023) 51, 99–108 (ĐH Bách khoa TP.HCM – HCMUT) *(tệp: Low\_Cost\_PickPlaceRobotArm.pdf)*.

**Mục tiêu và nội dung:** Phát triển cánh tay robot Delta **giá rẻ** gắp vật kích thước bất kỳ nhờ hệ thị giác, hướng tới doanh nghiệp vừa và nhỏ.

**Phương pháp:** Dùng **động cơ bước thay servo AC**, vật liệu và gia công sẵn có (**cắt laser, in 3D thay phay/tiện CNC**) để giảm chi phí. Điều khiển bằng **Arduino Uno**. Động học giải bằng phương pháp hình học (thuận + ngược). Hệ thị giác xác định tọa độ 3D và kích thước vật để mở tay kẹp đúng bề rộng và di chuyển tới tọa độ gắp.

**Kết quả:** Robot chế tạo **dưới 500 USD**, chạy êm; hệ thị giác ước lượng vị trí và kích thước vật với **sai số nhỏ (~0,44–0,88 mm)**. Ứng dụng gắp vật trên băng tải xác nhận thiết kế hoạt động đúng. Hướng phát triển: app điều khiển. **Tham chiếu về giải pháp chế tạo tiết kiệm và động học hình học.**

\newpage

# NHÓM F – TÀI LIỆU THAM KHẢO BỔ TRỢ

## F1. ABB – *IRB 360 FlexPicker Datasheet* (2017)

**Thông tin:** Catalog kỹ thuật, ABB Robotics, 2017 *(tệp: IRB 360 FlexPicker\_Datasheet\_US Letter.pdf)*.

**Nội dung và thông số:** Đây là **robot Delta thương mại chuẩn công nghiệp** dùng làm mốc so sánh thiết kế. Họ IRB 360: tải **1/3/6/8 kg**, tầm với **800/1130/1600 mm**, 3–4 trục, gắn treo ngược (inverted), khối lượng 120 kg (bản chuẩn) – 145 kg (inox). **Độ lặp lại vị trí 0,1 mm**; góc trục 4: 0,4°. Chu kỳ gắp-thả tiêu biểu (25/305/25 mm) khoảng **0,30–0,43 s**; theo băng tải tới 800–1400 mm/s; gia tốc/giảm tốc **3,5 g**. Bộ điều khiển IRC5 (TrueMove/QuickMove), phần mềm PickMaster tích hợp thị giác; tùy chọn inox IP69K cho ngành thực phẩm.

**Ý nghĩa:** Cung cấp **các chỉ tiêu tính năng mục tiêu tham chiếu** (tải, tầm với, tốc độ chu kỳ, độ lặp lại, kiểu treo trần) để đối chiếu và định hướng thông số thiết kế robot Delta trong đồ án — đặc biệt cơ cấu treo trần kiểu IRB 360 và mốc tải/tốc độ.

## F2. Reinhardt, Miskin (2025) – *Artificial Spacetimes for Reactive Control of Resource-Limited Robots*

**Thông tin:** *npj Robotics* (2025) 3:39, Nature (University of Pennsylvania) *(tệp: s44182-025-00058-9.pdf)*.

**Nội dung:** Bài báo **không thuộc chủ đề robot Delta** (đưa vào tập tham khảo có thể để mở rộng bối cảnh điều khiển robot). Đề xuất khung hình học **"không-thời gian nhân tạo"** để điều khiển phản ứng (reactive control) cho **vi robot (microrobot)** thiếu năng lực tính toán trên thân. Ý tưởng cốt lõi: quỹ đạo robot phản ứng trong trường điều khiển **tuân theo cùng động lực như tia sáng trong thuyết tương đối rộng** (nguyên lý Fermat suy rộng, trường điều khiển đóng vai tensor mét, quỹ đạo là đường trắc địa).

**Kết quả:** Dùng kỹ thuật từ quang học/tương đối để dựng và phân tích trường điều khiển tĩnh dẫn vi robot tránh biên và thực hiện tác vụ (tuần tra, hội tụ, phân tán); có công cụ hình thức phân tích hành vi và **kiểm chứng thực nghiệm bằng vi robot nền silicon**. *Liên quan gián tiếp, chỉ mang tính tham khảo phương pháp điều khiển.*

\newpage

# NHẬN XÉT TỔNG HỢP VÀ ĐỊNH HƯỚNG SỬ DỤNG CHO ĐỒ ÁN

Từ 18 tài liệu, có thể rút ra bức tranh tổng quan phục vụ trực tiếp cho đồ án thiết kế robot Delta:

1. **Cơ sở động học** dựa vững chắc trên Williams II [A1] và bài báo tiếng Việt của Lê Xuân Hoàng & Lê Hoài Nam [A2] — cả hai dùng phương pháp giải tích véctơ + giao ba mặt cầu (FK) và giải IPK dạng $A\cos\theta+B\sin\theta+C=0$, đây là bộ công thức nền cho phần tính toán động học.

2. **Thiết kế và tối ưu kích thước:** [A2], [A3], [A6], [A7] cung cấp các phương pháp phân loại/ước lượng vùng làm việc và tối ưu tham số ($l>L>R>r$ theo [A7]); đặc biệt [A6] (Pandolfi 2025) là quy trình tích hợp GA + RecurDyn gần nhất với chuỗi công việc *thiết kế → tối ưu → mô phỏng bền → chọn động cơ* của đồ án.

3. **Cảnh báo mô hình:** [B1] (Cretescu) và [A4] (continuum) nhắc rằng độ mềm thanh, khe hở và ma sát khớp **không cộng tuyến tính** và có thể gây sai lệch/nghiêng ký sinh — cần lưu ý khi diễn giải kết quả mô phỏng bền dựa trên giả thiết thanh cứng/khớp lý tưởng.

4. **Quy hoạch quỹ đạo:** [C1]–[C3] thống nhất dùng đa thức bậc cao/NURBS/B-spline và tối ưu (IBOA, GWO) để giảm jerk, rung và năng lượng — tham chiếu cho phần quỹ đạo gắp-thả (đồ án đang dùng quỹ đạo quintic, chu kỳ 1,2 s).

5. **Sai số và độ chính xác:** [D1], [D2] cho phương pháp mô hình hóa và bù sai số (RSM, D–H, điều chỉnh góc dẫn động) — cơ sở nếu đồ án mở rộng phần đánh giá độ chính xác.

6. **Chuẩn tính năng và ứng dụng:** [E1], [E2] (cùng nhóm HCMUT) và catalog ABB [F1] cho các mốc thực tế về vật liệu (đế nhôm/thép, cánh carbon), cơ cấu kẹp, chi phí và chỉ tiêu tải/tốc độ/độ lặp lại để đối chiếu mục tiêu thiết kế.

*(Các tệp trùng lặp trong thư mục: `Analyze.pdf` ≡ `Dynamic_Analysis_…_Fl.pdf` (×2); `Speed_joint.pdf` ≡ `robotics-11-00036-v2.pdf` — đã gộp, tính là một tài liệu mỗi cặp.)*
