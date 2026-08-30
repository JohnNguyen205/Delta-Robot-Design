%% fea_load_params.m -- TONG HOP THONG SO TAI TRONG DAU VAO CHO MO PHONG BEN (FEA)
% =========================================================================
%  MUC DICH
%   File nay KHONG tinh lai vat ly tu dau. No CHI:
%    (1) Doc lai out/force_results.mat (ket qua force_analysis.m, quy dao
%        pick-and-place quintic, payload 2 kg, tai TRUNG TAM/baseline).
%    (2) Doc lai out/pose_results.mat (ket qua force_poses.m, quet toan bo
%        vung lam viec + 26 huong gia tot, lay WORST-CASE POSE, ty le x1.49
%        so voi baseline).
%    (3) Tu 2 nguon do, suy ra cong thuc + gia tri luc/momen dat len TUNG
%        CHI TIET chiu tai trong FEA (DR-006, DR-005-2, DR-007, rod,
%        DR-001-1/-2/-3), va DOI CHIEU voi so da hardcode trong
%        MoPhong_Ben/run_parts.ps1 va run_parts_pose.ps1.
%   Muc tieu: gom tat ca cong thuc dang RAI RAC (trong run_parts*.ps1,
%   KETQUA_BEN.md, THUYETMINH_MOPHONG_BEN_CHITIET.md) vao MOT noi TRUY DUOC
%   NGUON, khong bia so. Cho nao KHONG tim thay nguon/cong thuc thi ghi ro
%   "CHUA XAC MINH DUOC NGUON" thay vi doan.
%
%  KY HIEU (dinh nghia day du) --------------------------------------------
%   fMax     [N]   luc doc lon nhat 1 CAP thanh truyen (2 thanh/khop khuyu),
%                  bien baseline tren quy dao P&P -- doc tu force_results.mat
%   FeeMax   [N]   do lon luc dau cong tac (TCP) lon nhat -- force_results.mat
%   L1m      [m]   chieu dai bap tay (bicep), truc vai -> truc khuyu = p.L1
%   Mbicep   [N.m] momen uon bicep tai vai = fMax*L1m (dam cong-xon quy doi)
%   fw       [N]   fMax WORST-CASE toan vung lam viec (pose_results.mat)
%   Fw       [N]   FeeMax WORST-CASE toan vung lam viec (pose_results.mat)
%   tw       [N.m] momen khop WORST-CASE (thanh phan ban may, pose_results.mat)
%   r_pose   [-]   ty le worst-case/baseline = fw/fMax (~1.49, da co trong
%                  MoPhong_Luc/force_poses.m va MoPhong_Ben/run_parts_pose.ps1)
%   L_arm52  [m]   khoang cach 2 lo bore (vai<->khuyu) tren DR-005-2 dung lam
%                  CANH TAY DON quy doi momen uon -> luc ngang dat FEA
%                  (=270 mm, xem nguon o Section 2 duoi)
%   F_i      [N]   luc dat FEA cho 1 chi tiet i (gia tri cuoi cung)
%   m_duoi   [kg]  khoi luong phan robot TREO DUOI mat han Y=0 cua DR-001-2
%                  (doc lai tu KETQUA_BEN.md muc 8.2, KHONG tinh lai qua COM
%                  trong phien nay)
%   k_s      [-]   he so an toan/dong hoc dung cho cac chi tiet KET CAU TINH
%                  (DR-001-1/-2/-3) = 1.5, dong bo voi DR-001-3 da dung truoc
%   g        [m/s^2] gia toc trong truong = 9.81
%
%  NGUYEN TAC "EVIDENCE BEFORE DONE" (CLAUDE.md) --------------------------
%   - KHONG tinh lai dong luc hoc/tinh hoc tu dau (da co trong
%     force_analysis.m / force_poses.m) -- chi LOAD lai so da luu trong .mat.
%   - Voi DR-001-1/-2/-3 (ket cau TINH, khong qua force_analysis.m vi khong
%     nam trong chuoi dong luc hoc TCP->khop->bicep): so lieu lay THANG tu
%     KETQUA_BEN.md / THUYETMINH_MOPHONG_BEN_CHITIET.md, GHI RO trich dong
%     nao, KHONG bia cong thuc nghe hop ly.
%   - Neu KHONG tim duoc nguon/cong thuc cho 1 so nao, ghi ro
%     "CHUA XAC MINH DUOC NGUON" trong bang ket qua, KHONG tu suy dien.
% =========================================================================
clear; clc;
if ~exist('out','dir'), mkdir out; end
diary('out/fea_load_params_log.txt'); diary on;
fprintf('=== TONG HOP THONG SO TAI TRONG FEA -- DELTA ROBOT (payload 2 kg) ===\n\n');

%% ---------- 0. Doc lai ket qua da co (KHONG tinh lai vat ly) -------------
FR = load('out/force_results.mat');   % force_analysis.m (baseline P&P quintic)
PR = load('out/pose_results.mat');    % force_poses.m (worst-case toan vung LV)

fMax   = FR.fMax;        % [N] luc doc lon nhat 1 cap forearm, baseline
FeeMax = FR.FeeMax;      % [N] luc TCP lon nhat, baseline
L1m    = FR.L1m;         % [m] chieu dai bicep

fw = PR.fw;  Fw = PR.Fw;  tw = PR.tw;  L1m_pose = PR.L1m;   % worst-case pose
r_pose = fw/fMax;                                            % ty le worst/baseline

fprintf('--- Du lieu doc lai (KHONG tinh lai) ---\n');
fprintf(' out/force_results.mat: fMax = %.4f N , FeeMax = %.4f N , L1m = %.4f m\n', fMax, FeeMax, L1m);
fprintf(' out/pose_results.mat : fw   = %.4f N , Fw     = %.4f N , tw = %.4f N.m , L1m = %.4f m\n', fw, Fw, tw, L1m_pose);
fprintf(' Ty le worst-case/baseline r_pose = fw/fMax = %.4f (%.2fx)\n\n', r_pose, r_pose);

assert(abs(L1m-L1m_pose)<1e-9, 'L1m baseline va pose LECH NHAU -- kiem tra lai params.m 2 thu muc.');

%% ---------- Hang so tham chieu (chep lai tu tai lieu, KHONG tinh lai) ----
% DR-005-2: khoang cach 2 lo bore lam canh tay don quy doi momen->luc.
% Nguon (2 nguon doc lap, khop nhau):
%  (a) MoPhong_Ben/run_parts.ps1 dong 7: "Fix F3 R22.5 bore y=+135 ...
%      Load F9 R22.5 bore y=-135" -> khoang cach = 135-(-135) = 270 mm.
%  (b) MoPhong_Ben/THUYETMINH_MOPHONG_BEN_CHITIET.md muc 8 (dong ~271):
%      "Chieu dai lam viec (khoang cach 2 bore): L ~ 270 mm = 0.27 m"
%      (dung truc tiep trong cong thuc dam cong-xon delta=PL^3/(3EI)).
L_arm52 = 0.270;   % [m]

% DR-001-2 (khung han): khoi luong phan treo duoi mat han, HE SO AN TOAN.
% Nguon: MoPhong_Ben/KETQUA_BEN.md muc 8.2 (dong ~191-201) -- CHEP LAI,
% KHONG doc lai CAD qua COM trong phien nay (can mo SolidWorks moi lam duoc).
m_duoi_CAD  = 89.04;   % [kg] tong DR-001-1 + 3x(gearbox+DR-002..006+rod-end) + DR-007
m_duoi_hieuchinh = 17.24; % [kg] hieu chinh mat do gearbox TPMA (CAD 2.354 vs that 8.1 kg/cai x3)
m_duoi_that = m_duoi_CAD + m_duoi_hieuchinh;   % = 106.28 kg
k_s_tinh    = 1.5;      % he so an toan (dung lai tu DR-001-3, KETQUA_BEN.md muc 4.5)
g = 9.81;

% DR-001-1 va DR-001-3: gia tri hardcode trong run_parts.ps1, chi TRICH DAN
% lai tu KETQUA_BEN.md / THUYETMINH_MOPHONG_BEN_CHITIET.md (xem tung muc).
F_dr001_1_doc_total = 600;    % [N] "phan luc 3 cum canh tay" -- KETQUA_BEN.md dong 47
F_dr001_3_doc_total = 2097;   % [N] "~140 kg x 9.81 x 1.5"    -- KETQUA_BEN.md dong 34,48

%% ---------- Gia tri HARDCODE trong run_parts.ps1 / run_parts_pose.ps1 ----
% Chep nguyen van de doi chieu (KHONG sua). Nguon dong chinh xac:
%  MoPhong_Ben/run_parts.ps1       dong 17-21 (Comp=@(...))
%  MoPhong_Ben/run_parts_pose.ps1  dong 10-14 (Comp=@(...))
HC.dr006        = 61.35;   % run_parts.ps1 dong 17, Comp=(0,0,61.35)
HC.dr005b       = 185;     % run_parts.ps1 dong 18, Comp=(185,0,0)
HC.dr007        = 29.3;    % run_parts.ps1 dong 19, Comp=(0,0,29.3)
HC.dr001_1      = 100;     % run_parts.ps1 dong 20, Comp=(0,0,100)  [/lo, x6 lo]
HC.dr001_3      = 233;     % run_parts.ps1 dong 21, Comp=(0,0,233)  [/lo, x9 lo]
HC.dr006_pose   = 91.2;    % run_parts_pose.ps1 dong 10, Comp=(0,0,91.2)
HC.dr005b_pose  = 275;     % run_parts_pose.ps1 dong 12, Comp=(275,0,0)
HC.dr001_1_pose = 149;     % run_parts_pose.ps1 dong 14, Comp=(0,0,149) [/lo]

TOL = 0.5;   % [N] hoac [N.m] -- dung sai lam tron cho phep khi so sanh

rows = {};   % {Part, CoChe, CongThuc, GiaTri, DonVi, Hardcode, KhopKhong, GhiChuNguon}

%% ---------- 1. DR-006_Elbow-Clevis (baseline) -----------------------------
% Co che: 1 CAP thanh truyen (2 thanh 6516K305 + 2 khop cau 60645K471) bat
% vao 2 lo tren chac khuyu DR-006 (moi lo = luc doc 1 thanh). fea_run.ps1
% dat TONG luc 1 cap len CAC lo Load (F0,F34) theo -Y -- xem run_parts.ps1
% dong 17: Load=@(0,34), Comp=(0,0,61.35).
F_dr006 = fMax/2;   % [N] fMax = luc CA CAP; dat len 2 lo -> lay 1/2 lam do lon Comp truc Z
fprintf('--- 1. DR-006 Elbow-Clevis (baseline) ---\n');
fprintf(' Co che: 1 cap forearm (2 thanh) bat vao 2 lo rod tren chac khuyu.\n');
fprintf(' Cong thuc: F = fMax/2 = %.2f/2 = %.2f N\n', fMax, F_dr006);
fprintf(' Doi chieu run_parts.ps1 dong 17 (Comp=%.2f N): %s\n\n', HC.dr006, tf_match(F_dr006,HC.dr006,TOL));
rows(end+1,:) = {'DR-006 (baseline)','1 cap forearm -> 2 lo rod chac khuyu', ...
  'F = fMax/2', sprintf('%.2f',F_dr006), 'N', sprintf('%.2f',HC.dr006), ...
  tf_match(F_dr006,HC.dr006,TOL), 'force_results.mat fMax; run_parts.ps1 dong17'};

%% ---------- 1b. DR-006 (pose worst-case) ----------------------------------
F_dr006_pose = fw/2;
fprintf('--- 1b. DR-006 (pose worst-case, x%.2f) ---\n', r_pose);
fprintf(' Cong thuc: F = fw/2 = %.2f/2 = %.2f N\n', fw, F_dr006_pose);
fprintf(' Doi chieu run_parts_pose.ps1 dong 10 (Comp=%.2f N): %s\n\n', HC.dr006_pose, tf_match(F_dr006_pose,HC.dr006_pose,TOL));
rows(end+1,:) = {'DR-006 (pose worst-case)','1 cap forearm -> 2 lo rod, tu the bien R400 z-1050', ...
  'F = fw/2', sprintf('%.2f',F_dr006_pose), 'N', sprintf('%.2f',HC.dr006_pose), ...
  tf_match(F_dr006_pose,HC.dr006_pose,TOL), 'pose_results.mat fw; run_parts_pose.ps1 dong10'};

%% ---------- 2. DR-005-2_Upper-Arm-Link (baseline) -------------------------
% Co che: momen uon bicep Mbicep = fMax*L1m (tai true vai) duoc quy doi
% thanh 1 LUC NGANG dat o dau khuyu, ngam o dau vai, canh tay don = khoang
% cach 2 lo bore = L_arm52 = 270 mm (xem nguon hang so tren).
Mbicep = fMax*L1m;                 % [N.m] -- giong dong in "Momen uon bicep" trong force_log.txt
F_dr005b = Mbicep/L_arm52;         % [N]
fprintf('--- 2. DR-005-2 Upper-Arm-Link (baseline) ---\n');
fprintf(' Co che: momen uon bicep Mbicep=fMax*L1m quy ve luc ngang dat dau\n');
fprintf('         khuyu, ngam dau vai, canh tay don = khoang cach 2 bore = %.0f mm.\n', L_arm52*1000);
fprintf(' Cong thuc: Mbicep = fMax*L1m = %.2f*%.4f = %.2f N.m\n', fMax, L1m, Mbicep);
fprintf('            F = Mbicep/L_arm52 = %.2f/%.3f = %.2f N\n', Mbicep, L_arm52, F_dr005b);
fprintf(' Doi chieu run_parts.ps1 dong 18 (Comp=%.2f N): %s\n', HC.dr005b, tf_match(F_dr005b,HC.dr005b,TOL));
fprintf(' Ghi chu: L_arm52=270mm la SUY DIEN cua phien nay tu 2 nguon doc lap\n');
fprintf('          (toa do mat trong run_parts.ps1 va cong thuc dam trong\n');
fprintf('          THUYETMINH muc 8) -- KHONG co 1 dong cong thuc F=M/L tuong\n');
fprintf('          minh nao trong tai lieu goc, nhung khop voi 185N hardcode\n');
fprintf('          trong pham vi lam tron (%.2f vs %.0f).\n\n', F_dr005b, HC.dr005b);
rows(end+1,:) = {'DR-005-2 (baseline)','uon bicep quy doi luc ngang dau khuyu, ngam dau vai', ...
  'F = fMax*L1m / L_arm52', sprintf('%.2f',F_dr005b), 'N', sprintf('%.2f',HC.dr005b), ...
  tf_match(F_dr005b,HC.dr005b,TOL), 'SUY DIEN phien nay tu run_parts.ps1 dong7 + THUYETMINH muc8 (L=270mm); can nguoi kiem tra xac nhan cong thuc goc'};

%% ---------- 2b. DR-005-2 (pose worst-case) ---------------------------------
Mbicep_pose = fw*L1m_pose;              % = PR.Mbend(iw), giong ket qua force_poses.m
F_dr005b_pose = Mbicep_pose/L_arm52;
fprintf('--- 2b. DR-005-2 (pose worst-case) ---\n');
fprintf(' Cong thuc: Mbicep_pose = fw*L1m = %.2f*%.4f = %.2f N.m (~= tw doc tu pose_results.mat = %.2f N.m)\n', ...
        fw, L1m_pose, Mbicep_pose, tw);
fprintf('            F = Mbicep_pose/L_arm52 = %.2f/%.3f = %.2f N\n', Mbicep_pose, L_arm52, F_dr005b_pose);
fprintf(' Doi chieu run_parts_pose.ps1 dong 12 (Comp=%.2f N): %s\n\n', HC.dr005b_pose, tf_match(F_dr005b_pose,HC.dr005b_pose,TOL));
rows(end+1,:) = {'DR-005-2 (pose worst-case)','uon bicep worst-case (bien R400 z-1050) quy doi luc ngang', ...
  'F = fw*L1m / L_arm52', sprintf('%.2f',F_dr005b_pose), 'N', sprintf('%.2f',HC.dr005b_pose), ...
  tf_match(F_dr005b_pose,HC.dr005b_pose,TOL), 'pose_results.mat fw; run_parts_pose.ps1 dong12'};

%% ---------- 3. DR-007_Moving-Platform (baseline) ---------------------------
% Co che: 6 lo bat tool tren ban may chiu FeeMax chia deu 6 diem (payload +
% quan tinh dat tai tam, phan bo deu ra 6 lo theo gia thiet doi xung).
F_dr007 = FeeMax/6;
fprintf('--- 3. DR-007 Moving-Platform (baseline) ---\n');
fprintf(' Co che: FeeMax dat tai tam ban may, chia deu 6 lo bat tool.\n');
fprintf(' Cong thuc: F = FeeMax/6 = %.2f/6 = %.2f N\n', FeeMax, F_dr007);
fprintf(' Doi chieu run_parts.ps1 dong 19 (Comp=%.2f N): %s\n\n', HC.dr007, tf_match(F_dr007,HC.dr007,TOL));
rows(end+1,:) = {'DR-007 (baseline)','FeeMax tai tam -> chia deu 6 lo bat tool', ...
  'F = FeeMax/6', sprintf('%.2f',F_dr007), 'N', sprintf('%.2f',HC.dr007), ...
  tf_match(F_dr007,HC.dr007,TOL), 'force_results.mat FeeMax; run_parts.ps1 dong19'};
fprintf('Ghi chu: DR-007 KHONG co phien ban pose worst-case trong run_parts_pose.ps1\n');
fprintf('  (xem run_parts_pose.ps1 dong 2-3: "Platform Fee 176.1N ~ unchanged (pose-\n');
fprintf('  independent) so DR-007 skipped" -- Fw doc tu pose_results.mat = %.2f N, gan\n', Fw);
fprintf('  bang FeeMax baseline %.2f N, khop voi ly do bo qua nay).\n\n', FeeMax);

%% ---------- 4. 6516K305 Rod (connecting rod) -------------------------------
% Co che: 1 thanh doc trong 1 cap = fMax/2 (giong 1 lo tren DR-006, vi 2 lo
% do = 2 dau thanh cua CUNG 1 cap 2 thanh doc truc doi xung).
F_rod = fMax/2;
fprintf('--- 4. 6516K305 Rod (connecting rod, baseline) ---\n');
fprintf(' Co che: luc doc truc 1 thanh trong 1 cap (nen/keo) = fMax/2.\n');
fprintf(' Cong thuc: F = fMax/2 = %.2f/2 = %.2f N\n', fMax, F_rod);
fprintf(' Doi chieu run_parts.ps1: KHONG CO -- rod la chi tiet MUA (6516K305),\n');
fprintf('   khong nam trong danh sach 5 part cua run_parts.ps1/run_parts_pose.ps1.\n');
fprintf(' KIEM TRA EULER BUCKLING: force_analysis.m dong ~219 CHI IN RA dong chu\n');
fprintf('   "kiem oan Euler" nhu MOT GHI CHU/VIEC-CAN-LAM, KHONG co cong thuc/so\n');
fprintf('   lieu Euler (P_cr, do manh...) nao duoc TINH trong file do. => CHUA XAC\n');
fprintf('   MINH DUOC so lieu kiem Euler; KHONG bia cong thuc moi o day (tranh tinh\n');
fprintf('   lai vat ly ngoai pham vi "doc lai .mat" cua nhiem vu nay).\n\n');
rows(end+1,:) = {'6516K305 Rod (baseline)','1 thanh doc truc trong 1 cap forearm', ...
  'F = fMax/2', sprintf('%.2f',F_rod), 'N', 'N/A', 'N/A (khong co trong run_parts.ps1)', ...
  'force_results.mat fMax; Euler buckling CHUA XAC MINH DUOC NGUON (force_analysis.m dong219 chi la ghi chu, khong co cong thuc)'};

%% ---------- 5. DR-001-1_De-Gan-Tay (tam de) --------------------------------
% Chi tiet KET CAU TINH, KHONG qua force_analysis.m/force_poses.m (khong
% nam trong chuoi TCP->khop->bicep). So lieu TRICH DAN THANG tu tai lieu.
F_dr001_1_per = F_dr001_1_doc_total/6;   % 600 N / 6 lo = 100 N/lo
fprintf('--- 5. DR-001-1 De-Gan-Tay (tam de, ket cau tinh) ---\n');
fprintf(' Nguon: KETQUA_BEN.md dong 47 va THUYETMINH_MOPHONG_BEN_CHITIET.md dong 147:\n');
fprintf('   "600 N theo +Y (phan luc 3 cum canh tay)" dat len 6 lo bat bracket\n');
fprintf('   (2 lo/canh tay x 3 canh tay) -- run_parts.ps1 dong 20 dat Comp=(0,0,100)\n');
fprintf('   TUNG lo, tuc %.0f N/lo x 6 lo = %.0f N tong, KHOP voi 600 N cua tai lieu.\n', HC.dr001_1, HC.dr001_1*6);
fprintf(' *** CHUA XAC MINH DUOC NGUON CONG THUC CHINH XAC CUA 600 N ***\n');
fprintf('   Ca KETQUA_BEN.md va THUYETMINH_MOPHONG_BEN_CHITIET.md chi MO TA dinh\n');
fprintf('   tinh ("phan luc 3 cum canh tay") ma KHONG co dong cong thuc/phep tinh\n');
fprintf('   nao dan ra chinh xac con so 600 N (vi du: khong thay lien he truc tiep\n');
fprintf('   voi FeeMax=175.8N, fMax=122.7N, hay khoi luong canh tay/gearbox nao ra\n');
fprintf('   dung 600N). Khong tim thay file/log nao khac trong repo giai thich con\n');
fprintf('   so nay (da rg qua TIENDO.md, ThuyetMinh_LuaChonVatLieu.md, cac file\n');
fprintf('   faces_DR-001-1*.txt). KHONG bia them cong thuc o day.\n\n');
rows(end+1,:) = {'DR-001-1 (tam de)','phan luc 3 cum canh tay (bracket) -> 6 lo bat bracket', ...
  'F = 600 N (tai lieu) / 6 lo', sprintf('%.2f',F_dr001_1_per), 'N', sprintf('%.2f',HC.dr001_1), ...
  tf_match(F_dr001_1_per,HC.dr001_1,TOL), 'CHUA XAC MINH DUOC NGUON cong thuc 600N -- chi co mo ta dinh tinh trong KETQUA_BEN.md dong47 / THUYETMINH dong147'};

%% ---------- 5b. DR-001-1 (pose worst-case) ---------------------------------
F_dr001_1_pose_per = F_dr001_1_per*r_pose;
fprintf('--- 5b. DR-001-1 (pose worst-case) ---\n');
fprintf(' Cong thuc: nhan ty le pose r_pose=fw/fMax len gia tri baseline (khong\n');
fprintf('   phai tinh rieng, vi phan luc bracket ty le voi luc tay may fMax).\n');
fprintf(' F = %.2f N/lo (baseline) x r_pose %.4f = %.2f N/lo\n', F_dr001_1_per, r_pose, F_dr001_1_pose_per);
fprintf(' Doi chieu run_parts_pose.ps1 dong 14 (Comp=%.2f N): %s\n\n', HC.dr001_1_pose, tf_match(F_dr001_1_pose_per,HC.dr001_1_pose,TOL));
rows(end+1,:) = {'DR-001-1 (pose worst-case)','phan luc bracket, nhan ty le pose r_pose', ...
  'F = (600/6) * r_pose', sprintf('%.2f',F_dr001_1_pose_per), 'N', sprintf('%.2f',HC.dr001_1_pose), ...
  tf_match(F_dr001_1_pose_per,HC.dr001_1_pose,TOL), 'pose_results.mat fw/fMax; run_parts_pose.ps1 dong14; ke thua nguon 600N chua xac minh o muc 5'};

%% ---------- 6. DR-001-2_Khung-Han (khung han) ------------------------------
% Chep DUNG cong thuc tu KETQUA_BEN.md muc 8.2 (2026-07-22), KHONG tinh lai
% khoi luong qua COM trong phien nay (m_duoi_CAD = so da doc lai truoc do).
F_dr001_2 = m_duoi_that*g*k_s_tinh;
fprintf('--- 6. DR-001-2 Khung-Han (khung han, ket cau tinh) ---\n');
fprintf(' Nguon: KETQUA_BEN.md muc 8.2 (dong 190-202), tinh tay 2026-07-22, CHEP\n');
fprintf('   LAI nguyen cong thuc, khong tinh lai qua COM trong phien nay:\n');
fprintf('   m_duoi (CAD, moi thu treo DUOI mat han Y=0, tru DR-001-2/-3) = %.2f kg\n', m_duoi_CAD);
fprintf('   + hieu chinh mat do gearbox TPMA (CAD 2.354 vs that 8.1 kg/cai x3)  = +%.2f kg\n', m_duoi_hieuchinh);
fprintf('   = m_duoi,that = %.2f + %.2f = %.2f kg\n', m_duoi_CAD, m_duoi_hieuchinh, m_duoi_that);
fprintf('   F = m_duoi,that * g * k_s = %.2f * %.2f * %.1f = %.1f N\n', m_duoi_that, g, k_s_tinh, F_dr001_2);
fprintf(' Doi chieu run_parts.ps1 / run_parts_pose.ps1: KHONG CO -- DR-001-2 KHONG\n');
fprintf('   nam trong 2 script nay (chi 5 tag: dr006,dr005b,dr007,dr001_1,dr001_3).\n');
fprintf('   FEA rieng DR-001-2 chay TRUC TIEP qua fea_run.ps1 (khong qua run_parts*.ps1),\n');
fprintf('   xem KETQUA_BEN.md muc 8.2. Gia tri F=%.1fN KHOP CHINH XAC voi con so\n', F_dr001_2);
fprintf('   "1563,9 N" da ghi trong KETQUA_BEN.md (sai lech %.3f N do lam tron doc).\n\n', abs(F_dr001_2-1563.9));
rows(end+1,:) = {'DR-001-2 (khung han)','tai treo phan duoi mat han Y=0 (m_duoi*g*k_s)', ...
  'F = m_duoi_that*g*k_s', sprintf('%.1f',F_dr001_2), 'N', 'N/A', 'N/A (khong co trong run_parts.ps1, chay rieng qua fea_run.ps1)', ...
  'KETQUA_BEN.md muc8.2 dong190-202; khop voi 1563.9N da cong bo'};

%% ---------- 7. DR-001-3_Mat-Treo (mat treo) --------------------------------
F_dr001_3_per = F_dr001_3_doc_total/9;   % 2097 N / 9 lo M12 = 233 N/lo
% Cong thuc XAP XI da cong bo trong tai lieu (KETQUA_BEN.md dong34/48;
% THUYETMINH dong 255): "trong luong robot ~140 kg x 9.81 x he so 1.5"
m_robot_xapxi = 140;
F_check = m_robot_xapxi*g*k_s_tinh;
fprintf('--- 7. DR-001-3 Mat-Treo (mat treo, ket cau tinh) ---\n');
fprintf(' Nguon: KETQUA_BEN.md dong 34/48, THUYETMINH_MOPHONG_BEN_CHITIET.md dong 255:\n');
fprintf('   "~2097 N = trong luong robot ~140 kg x 9.81 x he so 1.5" dat len 9 lo M12\n');
fprintf('   (run_parts.ps1 dong 21: Comp=(0,0,233) TUNG lo x 9 lo = %.0f N tong).\n', HC.dr001_3*9);
fprintf(' Cong thuc XAP XI CONG BO: F_tong = m_robot*g*k_s = %.0f*%.2f*%.1f = %.1f N\n', ...
        m_robot_xapxi, g, k_s_tinh, F_check);
fprintf(' *** SAI LECH: cong thuc xap xi (%.1f N) KHONG khop chinh xac voi 2097 N\n', F_check);
fprintf('   da cong bo (lech %.1f N = %.1f%%). Khoi luong THAT can de ra dung 2097N\n', ...
        2097-F_check, 100*(2097-F_check)/2097);
fprintf('   la m = 2097/(9.81*1.5) = %.2f kg, KHONG khop voi "~140 kg" ghi trong tai\n', 2097/(g*k_s_tinh));
fprintf('   lieu (lech %.2f kg). => CHUA XAC MINH DUOC nguon chinh xac cua so 2097N/\n', 2097/(g*k_s_tinh)-m_robot_xapxi);
fprintf('   233N/lo -- tai lieu chi ghi cong thuc XAP XI (dau ~), khong co so lieu\n');
fprintf('   khoi luong chinh xac dung de ra dung con so nay. KHONG bia them.\n\n');
rows(end+1,:) = {'DR-001-3 (mat treo)','treo toan bo robot -> 9 lo M12 xuyen', ...
  'F = 2097 N (tai lieu, ~140kg*9.81*1.5) / 9 lo', sprintf('%.2f',F_dr001_3_per), 'N', sprintf('%.2f',HC.dr001_3), ...
  tf_match(F_dr001_3_per,HC.dr001_3,TOL), 'CHUA XAC MINH DUOC nguon chinh xac -- cong thuc xap xi ~140kg lech ~1.8% so voi 2097N cong bo, xem KETQUA_BEN.md dong34/48'};

%% ---------- 8. Bang tong hop + xuat file -----------------------------------
fprintf('=== BANG TONG HOP TAI TRONG FEA (doi chieu run_parts*.ps1) ===\n\n');
colw = [26 42 34 10 5 12 28 60];
hdr = {'Chi tiet','Co che truyen luc','Cong thuc','GiaTri','DVi','Hardcode','KhopKhong','GhiChuNguon'};
print_row(hdr,colw);
for i=1:size(rows,1), print_row(rows(i,:),colw); end
fprintf('\n');

T = cell2table(rows, 'VariableNames', ...
  {'ChiTiet','CoCheTruyenLuc','CongThuc','GiaTri_N_hoac_Nm','DonVi','Hardcode_runparts','KhopKhong','GhiChuNguon'});
csvfile = 'out/fea_load_params.csv';
writetable(T, csvfile);
fprintf('Da luu bang: %s (%d dong)\n', csvfile, size(rows,1));
fprintf('Da luu log:  out/fea_load_params_log.txt\n\n');

nmismatch = sum(strcmp(rows(:,7),'KHONG KHOP'));
nunverif  = sum(contains(rows(:,8),'CHUA XAC MINH'));
fprintf('--- TOM TAT KIEM TRA ---\n');
fprintf(' So dong SO SANH DUOC voi run_parts*.ps1 va KHONG khop (>%.1f dung sai): %d\n', TOL, nmismatch);
fprintf(' So dong co ghi chu "CHUA XAC MINH DUOC NGUON": %d (xem chi tiet Section 5 va 7 o tren)\n', nunverif);
fprintf('DONE\n');
diary off;

%% ---------- Ham phu ---------------------------------------------------
function s = tf_match(a,b,tol)
  if abs(a-b) <= tol, s = 'KHOP'; else, s = 'KHONG KHOP'; end
end

function print_row(c,colw)
  s = '';
  for i=1:numel(c)
    v = c{i};
    if ~ischar(v), v = num2str(v); end
    if numel(v) > colw(i), v = v(1:colw(i)); end
    s = [s pad(v,colw(i)+1)]; %#ok<AGROW>
  end
  fprintf('%s\n', s);
end
