% p_STT07_workspace_quydao.m -- Vung lam viec + quy dao lam viec bang
% phuong phap quet luoi goc khop (FK) + mat do diem voi-toi + thi nghiem
% truc giao L9, doi chieu bo tham so thiet ke thuc te.
%
% Phuong phap (theo bai bao tham khao ve toi uu vung lam viec/quy dao Delta):
%  A. Quet luoi 3 goc chu dong (theta1,theta2,theta3) trong gioi han khop,
%     chay FK (thuan) cho tung to hop -> dam may diem voi-toi (Pcloud).
%  B. The tich vung lam viec = so voxel (canh 10mm) co diem voi-toi x the
%     tich 1 voxel ("mat do diem voi-toi").
%  C. Quet z de tim mat cat ngang co dien tich lon nhat (xap xi bang convex
%     hull cua hinh chieu XY trong 1 lat cat mong quanh z).
%  D. Chong quy dao "cong" (gate) pick-and-place len mat cat de kiem tra
%     bao phu.
%  E. Thi nghiem truc giao L9(3^4) tren 4 tham so ket cau (L1,L2,R,r),
%     phan tich pham vi (range analysis) de xep hang muc do anh huong.
%
% Ghi chu: FK duoc VECTOR HOA toan luoi (khong goi delta_fk.m trong vong
% lap 91125 lan) vi C_i (tam ao cua tung canh tay) chi phu thuoc theta_i
% rieng le, nen ta tinh truoc C1(theta1),C2(theta2),C3(theta3) roi ghep
% to hop bang ndgrid va giai giao 3 mat cau (trilateration) dang vector
% hoa (thay pinv 2x3 bang nghich dao Gram 2x2 dang dong bit, cong thuc
% Cramer) -- ket qua duoc doi chieu lai voi delta_fk.m (xem "Tu kiem tra").

clear; clc;
if ~exist('figs','dir'), mkdir figs; end
if ~exist('out','dir'),  mkdir out;  end
diary('out/pSTT07_log.txt'); diary on;
p0 = params();

fprintf('=== STT07: VUNG LAM VIEC (MAT DO DIEM) + QUY DAO CONG + L9 ===\n');
fprintf('Thiet ke thuc te: L1=%.1f L2=%.1f R=%.1f r=%.1f (Rr=%.1f) th=[%.0f,%.0f] deg\n\n', ...
    p0.L1,p0.L2,p0.R,p0.r,p0.Rr,rad2deg(p0.th_min),rad2deg(p0.th_max));

%% ================= BUOC A: DAM MAY DIEM VOI-TOI (thiet ke thuc te) =====
tA = tic;
N = 45;
tgrid = linspace(p0.th_min, p0.th_max, N);
[Pcloud, Tcloud] = fk_grid_cloud(tgrid, tgrid, tgrid, p0);
fprintf('--- BUOC A: quet luoi FK N=%d (%d to hop) ---\n', N, N^3);
fprintf('So diem voi-toi thuc (khong NaN, thoa giao 3 mat cau): %d / %d (%.1f%%)\n', ...
    size(Pcloud,1), N^3, 100*size(Pcloud,1)/N^3);
fprintf('Thoi gian tinh Buoc A: %.2f s\n', toc(tA));

% --- Tu kiem tra FK vector hoa vs delta_fk.m tren mau ngau nhien tu Pcloud ---
rng(1);
ntest = 25;
idxtest = randperm(size(Pcloud,1), min(ntest, size(Pcloud,1)));
maxerr = 0;
for ii = idxtest
    [Pref, okref] = delta_fk(Tcloud(ii,:).', p0);
    if okref
        maxerr = max(maxerr, norm(Pref(:) - Pcloud(ii,:).'));
    end
end
fprintf('Tu kiem tra: sai so max FK-vector-hoa vs delta_fk.m tren %d mau = %.3e mm\n\n', numel(idxtest), maxerr);

% --- Hinh 4 goc nhin ---
f1 = figure('Visible','off','Position',[80 80 900 800]);
subplot(2,2,1);
plot(Pcloud(:,2), Pcloud(:,3), '.', 'Color',[.2 .45 .85], 'MarkerSize',2);
axis equal; grid on; xlabel('Y [mm]'); ylabel('Z [mm]'); title('Mat truoc (Y-Z)');
subplot(2,2,2);
plot(Pcloud(:,1), Pcloud(:,2), '.', 'Color',[.2 .65 .35], 'MarkerSize',2);
axis equal; grid on; xlabel('X [mm]'); ylabel('Y [mm]'); title('Mat tren (X-Y)');
subplot(2,2,3);
plot(Pcloud(:,1), Pcloud(:,3), '.', 'Color',[.85 .35 .2], 'MarkerSize',2);
axis equal; grid on; xlabel('X [mm]'); ylabel('Z [mm]'); title('Mat ben (X-Z)');
subplot(2,2,4);
scatter3(Pcloud(:,1), Pcloud(:,2), Pcloud(:,3), 2, [.4 .3 .6], '.');
axis equal; grid on; xlabel('X'); ylabel('Y'); zlabel('Z [mm]'); title('Isometric'); view(35,22);
sgtitle('Buoc A: dam may diem voi-toi (quet luoi goc khop, N=45)');
saveas(f1, 'figs/pSTT07_workspace_cloud.png');
fprintf('Da luu figs/pSTT07_workspace_cloud.png\n\n');

%% ================= BUOC B: THE TICH THEO MAT DO DIEM (voxel 10mm) ======
Vol_design_mm3 = voxel_volume(Pcloud, 10);
fprintf('--- BUOC B: the tich vung lam viec (mat do diem, voxel 10mm) ---\n');
fprintf('The tich vung lam viec (thiet ke thuc te) = %.0f mm^3 = %.4f m^3 = %.2f lit\n\n', ...
    Vol_design_mm3, Vol_design_mm3*1e-9, Vol_design_mm3*1e-6);

%% ================= BUOC C: MAT CAT NGANG DIEN TICH LON NHAT =============
[zbest, areabest, Dbest, zlist, arealist] = max_cross_section(Pcloud, 15);
fprintf('--- BUOC C: quet mat cat ngang (buoc z=15mm, day lat +-7.5mm) ---\n');
fprintf('Mat cat lon nhat tai z = %.2f mm, dien tich = %.1f mm^2, duong kinh tuong duong = %.2f mm\n\n', ...
    zbest, areabest, Dbest);

sel = abs(Pcloud(:,3) - zbest) <= 7.5;
pts = Pcloud(sel,1:2);
kbest = convhull(pts(:,1), pts(:,2));
f3 = figure('Visible','off','Position',[80 80 700 700]);
plot(pts(kbest,1), pts(kbest,2), 'b-', 'LineWidth',1.6); hold on;
plot(pts(:,1), pts(:,2), '.', 'Color',[.6 .8 1], 'MarkerSize',3);
th_a = linspace(0,2*pi,200);
plot((p0.ws_D/2)*cos(th_a), (p0.ws_D/2)*sin(th_a), 'r--', 'LineWidth',2);
axis equal; grid on; xlabel('X [mm]'); ylabel('Y [mm]');
title(sprintf('Mat cat ngang dien tich lon nhat: z=%.0f mm, A=%.0f mm^2, D_{td}=%.0f mm', zbest, areabest, Dbest));
legend('bien voi-toi (convex hull)','diem voi-toi','tru muc tieu \Phi800','Location','best');
saveas(f3, 'figs/pSTT07_max_crosssection.png');
fprintf('Da luu figs/pSTT07_max_crosssection.png\n\n');

%% ================= BUOC D: BAO PHU QUY DAO CONG (gate) ==================
W = [ 300 0 -1000;   % A: gap (pick)
      300 0  -820;   % nang len
     -300 0  -820;   % di ngang
     -300 0 -1000];  % D: dat (place)
Tseg = [0.30 0.60 0.30];
[t_path, P_path] = gen_quintic_path(W, Tseg, 0.002);
n_path = size(P_path,1);

reach_path = false(n_path,1);
for i = 1:n_path
    [th,ok] = delta_ik(P_path(i,:).', p0);
    reach_path(i) = ok && all(th >= p0.th_min) && all(th <= p0.th_max);
end
n_reach_path = sum(reach_path);

corner_ok = false(4,1);
for i = 1:4
    [th,ok] = delta_ik(W(i,:).', p0);
    corner_ok(i) = ok && all(th >= p0.th_min) && all(th <= p0.th_max);
end
n_corner_reach = sum(corner_ok);

fprintf('--- BUOC D: bao phu quy dao cong (gate) tren thiet ke thuc te ---\n');
fprintf('4 dinh hinh chu nhat quy dao (X:[-300,300] Z:[-1000,-820] tai Y=0): %d/4 voi-toi\n', n_corner_reach);
fprintf('Toan bo quy dao quintic (%d diem, 0.30+0.60+0.30 s): %d/%d voi-toi (%.2f%%)\n\n', ...
    n_path, n_reach_path, n_path, 100*n_reach_path/n_path);

sely0 = abs(Pcloud(:,2)) <= 7.5;
f4 = figure('Visible','off','Position',[80 80 780 680]);
plot(Pcloud(sely0,1), Pcloud(sely0,3), '.', 'Color',[.6 .8 1], 'MarkerSize',3); hold on;
rectangle('Position',[-300 -1000 600 180], 'EdgeColor','r', 'LineWidth',2);
plot(P_path(:,1), P_path(:,3), 'k-', 'LineWidth',1.8);
plot(W(:,1), W(:,3), 'mo', 'MarkerFaceColor','m', 'MarkerSize',7);
axis equal; grid on; xlabel('X [mm]'); ylabel('Z [mm]');
title(sprintf('Buoc D: bao phu quy dao cong (Y=0) -- dinh:%d/4, duong:%d/%d (%.1f%%)', ...
    n_corner_reach, n_reach_path, n_path, 100*n_reach_path/n_path));
legend('vung voi-toi (lat Y=0)','hinh chu nhat quy dao','duong quy dao quintic','waypoint','Location','best');
saveas(f4, 'figs/pSTT07_gate_coverage.png');
fprintf('Da luu figs/pSTT07_gate_coverage.png\n\n');

%% ================= BUOC E: THI NGHIEM TRUC GIAO L9(3^4) ==================
fprintf('--- BUOC E: thi nghiem truc giao L9(3^4) tren 4 tham so ket cau ---\n');
L1_levels = [350, 407.5, 465];   % bicep (canh tay tren)
L2_levels = [850, 1000, 1150];   % forearm (thanh truyen)
R_levels  = [300, 347, 394];     % ban kinh vong khop de
r_levels  = [90, 120.6, 150];    % ban kinh vong khop ban may

DM = [1 1 1 1; 1 2 2 2; 1 3 3 3; ...
      2 1 2 3; 2 2 3 1; 2 3 1 2; ...
      3 1 3 2; 3 2 1 3; 3 3 2 1];

N25 = 25;
t25 = linspace(p0.th_min, p0.th_max, N25);

nrows = 10; % Row0 (thiet ke thuc te) + 9 hang L9
Run   = zeros(nrows,1);
L1c   = zeros(nrows,1); L2c = zeros(nrows,1); Rc = zeros(nrows,1); rc = zeros(nrows,1);
Volc  = zeros(nrows,1); Areac = zeros(nrows,1); Zc = zeros(nrows,1); Cornersc = zeros(nrows,1);

for row = 0:9
    if row == 0
        pmod = p0;   % thiet ke thuc te, chay lai o do phan giai N25 de so sanh dong khung voi L9
        L1v = p0.L1; L2v = p0.L2; Rv = p0.R; rv = p0.r;
    else
        L1v = L1_levels(DM(row,1));
        L2v = L2_levels(DM(row,2));
        Rv  = R_levels(DM(row,3));
        rv  = r_levels(DM(row,4));
        pmod = p0;
        pmod.L1 = L1v; pmod.L2 = L2v; pmod.R = Rv; pmod.r = rv; pmod.Rr = Rv - rv;
    end

    [Prow, ~] = fk_grid_cloud(t25, t25, t25, pmod);
    if isempty(Prow)
        Volrow = 0; Arow = 0; Zrow = NaN;
    else
        Volrow = voxel_volume(Prow, 12);
        [Zrow, Arow, ~, ~, ~] = max_cross_section(Prow, 20);
    end

    ncorner = 0;
    for i = 1:4
        [th,ok] = delta_ik(W(i,:).', pmod);
        if ok && all(th >= pmod.th_min) && all(th <= pmod.th_max), ncorner = ncorner + 1; end
    end

    k = row + 1;
    Run(k)=row; L1c(k)=L1v; L2c(k)=L2v; Rc(k)=Rv; rc(k)=rv;
    Volc(k)=Volrow; Areac(k)=Arow; Zc(k)=Zrow; Cornersc(k)=ncorner;

    fprintf('  Run %d: L1=%.1f L2=%.1f R=%.1f r=%.1f -> Vol=%.0f mm^3, Amax=%.0f mm^2 @z=%.0f, goc quy dao=%d/4\n', ...
        row, L1v, L2v, Rv, rv, Volrow, Arow, Zrow, ncorner);
end

% --- Ghi CSV ---
fidcsv = fopen('out/l9_results.csv','w');
fprintf(fidcsv, 'Run,L1,L2,R,r,Volume_mm3,MaxCrossSectionArea_mm2,MaxCrossSectionZ_mm,GateCornersReachable(0-4)\n');
for k = 1:nrows
    fprintf(fidcsv, '%d,%.2f,%.2f,%.2f,%.2f,%.1f,%.1f,%.2f,%d\n', ...
        Run(k), L1c(k), L2c(k), Rc(k), rc(k), Volc(k), Areac(k), Zc(k), Cornersc(k));
end
fclose(fidcsv);
fprintf('\nDa luu out/l9_results.csv (%d hang: Row0 + 9 hang L9)\n\n', nrows);

% --- Phan tich pham vi (range analysis) tren 9 hang L9 (khong tinh Row0) ---
factnames = {'L1 (canh tay tren)','L2 (thanh truyen)','R (ban kinh de)','r (ban kinh ban may)'};
levelvals = {L1_levels, L2_levels, R_levels, r_levels};
VolL9 = Volc(2:10);           % 9 hang L9 (Run=1..9), bo Row0
DM9   = DM;                   % da la 9x4

meanL = zeros(4,3);
rangeF = zeros(4,1);
for f = 1:4
    for lv = 1:3
        meanL(f,lv) = mean(VolL9(DM9(:,f)==lv));
    end
    rangeF(f) = max(meanL(f,:)) - min(meanL(f,:));
end
[~, ord] = sort(rangeF, 'descend');

fprintf('--- PHAN TICH PHAM VI (range analysis), 9 hang L9 (Row0 khong tinh) ---\n');
for f = 1:4
    fprintf('%s: gia tri muc [%.1f %.1f %.1f]; TB the tich [%.0f %.0f %.0f] mm^3; pham vi = %.0f mm^3\n', ...
        factnames{f}, levelvals{f}(1), levelvals{f}(2), levelvals{f}(3), ...
        meanL(f,1), meanL(f,2), meanL(f,3), rangeF(f));
end
fprintf('Xep hang muc do anh huong toi the tich vung lam viec (pham vi giam dan):\n  ');
for i = 1:4
    fprintf('%s (pham vi=%.0f)', factnames{ord(i)}, rangeF(ord(i)));
    if i < 4, fprintf('  >  '); end
end
fprintf('\n\n');

[volsort, idxsort] = sort(VolL9, 'descend');
fprintf('3 hang L9 co the tich lon nhat (de doi chieu, KHONG phai de doi tham so thiet ke):\n');
for i = 1:3
    rr = idxsort(i);
    fprintf('  Run %d: L1=%.1f L2=%.1f R=%.1f r=%.1f -> Vol=%.0f mm^3\n', ...
        rr, L1c(rr+1), L2c(rr+1), Rc(rr+1), rc(rr+1), volsort(i));
end
fprintf('\n');

save('out/pSTT07_results.mat','Pcloud','Tcloud','Vol_design_mm3','zbest','areabest','Dbest', ...
    'n_corner_reach','n_reach_path','n_path','Run','L1c','L2c','Rc','rc','Volc','Areac','Zc','Cornersc', ...
    'meanL','rangeF','ord','factnames','DM','L1_levels','L2_levels','R_levels','r_levels');

%% ================= TOM TAT CUOI CUNG ====================================
fprintf('=== TOM TAT KET QUA STT07 (thiet ke thuc te, params.m) ===\n');
fprintf('Buoc A: %d diem voi-toi thuc / %d to hop luoi (N=%d), sai so tu-kiem-tra FK max=%.3e mm\n', ...
    size(Pcloud,1), N^3, N, maxerr);
fprintf('Buoc B: the tich vung lam viec (voxel 10mm) = %.0f mm^3 (%.4f m^3)\n', Vol_design_mm3, Vol_design_mm3*1e-9);
fprintf('Buoc C: mat cat lon nhat tai z=%.2f mm, A=%.1f mm^2, D_td=%.2f mm\n', zbest, areabest, Dbest);
fprintf('Buoc D: 4 dinh hinh chu nhat quy dao = %d/4 voi-toi; toan bo duong quy dao = %d/%d (%.2f%%) voi-toi\n', ...
    n_corner_reach, n_reach_path, n_path, 100*n_reach_path/n_path);
if n_corner_reach == 4 && n_reach_path == n_path
    fprintf('==> THIET KE THUC TE (Row 0) BAO PHU DAY DU quy dao cong pick-and-place (4/4 dinh, 100%% duong di).\n');
else
    fprintf('==> THIET KE THUC TE (Row 0) CHUA bao phu day du quy dao (%d/4 dinh, %.2f%% duong di) -- can xem lai.\n', ...
        n_corner_reach, 100*n_reach_path/n_path);
end
fprintf('Buoc E: xep hang anh huong toi the tich (pham vi giam dan): %s > %s > %s > %s\n', ...
    factnames{ord(1)}, factnames{ord(2)}, factnames{ord(3)}, factnames{ord(4)});
fprintf('  (Day la khao sat do nhay/kiem chung quanh thiet ke da chot boi cac buoc dong hoc/luc/FEA truoc do,\n');
fprintf('   KHONG phai de xuat doi kich thuoc thuc te.)\n');
fprintf('=== HET STT07 ===\n');
diary off;

%% =========================== HAM CUC BO ==================================
function [Pcloud, T] = fk_grid_cloud(t1, t2, t3, p)
% Vector hoa dong hoc thuan tren luoi (t1 x t2 x t3): tra ve dam may diem
% voi-toi THUC (Mx3, da loc nghiem ao) va goc khop tuong ung (Mx3).
% C_i(theta_i) = tam ao canh tay i, chi phu thuoc theta_i (tach bien),
% nen tinh truoc theo tung truc roi ghep to hop bang ndgrid.
N1 = numel(t1); N2 = numel(t2); N3 = numel(t3);
[I,J,K] = ndgrid(1:N1,1:N2,1:N3);
I=I(:); J=J(:); K=K(:);
th1 = t1(I).'; th2 = t2(J).'; th3 = t3(K).';

c1=cos(p.phi(1)); s1=sin(p.phi(1));
c2=cos(p.phi(2)); s2=sin(p.phi(2));
c3=cos(p.phi(3)); s3=sin(p.phi(3));

C1 = [c1*(p.Rr + p.L1*cos(th1)), s1*(p.Rr + p.L1*cos(th1)), -p.L1*sin(th1)];
C2 = [c2*(p.Rr + p.L1*cos(th2)), s2*(p.Rr + p.L1*cos(th2)), -p.L1*sin(th2)];
C3 = [c3*(p.Rr + p.L1*cos(th3)), s3*(p.Rr + p.L1*cos(th3)), -p.L1*sin(th3)];

A1 = 2*(C2 - C1); A2 = 2*(C3 - C1);
bb1 = sum(C2.^2,2) - sum(C1.^2,2);
bb2 = sum(C3.^2,2) - sum(C1.^2,2);

d = cross(A1, A2, 2);

G11 = sum(A1.*A1,2); G12 = sum(A1.*A2,2); G22 = sum(A2.*A2,2);
detG = G11.*G22 - G12.^2;
valid_det = abs(detG) > 1e-9;

y1 = nan(size(detG)); y2 = nan(size(detG));
y1(valid_det) = (G22(valid_det).*bb1(valid_det) - G12(valid_det).*bb2(valid_det)) ./ detG(valid_det);
y2(valid_det) = (G11(valid_det).*bb2(valid_det) - G12(valid_det).*bb1(valid_det)) ./ detG(valid_det);

P0 = y1.*A1 + y2.*A2;

aa = sum(d.*d,2);
diff0 = P0 - C1;
bq = 2*sum(d.*diff0,2);
cq = sum(diff0.*diff0,2) - p.L2^2;
disc = bq.^2 - 4*aa.*cq;

okmask = valid_det & (aa > 1e-9) & (disc >= -1e-6);
discc = max(disc, 0);
sq = sqrt(discc);
tA = (-bq + sq) ./ (2*aa);
tB = (-bq - sq) ./ (2*aa);
Pa = P0 + tA.*d;
Pb = P0 + tB.*d;
lowerA = Pa(:,3) <= Pb(:,3);
Pfinal = Pb;
Pfinal(lowerA,:) = Pa(lowerA,:);

okmask = okmask & all(isfinite(Pfinal),2);
Pcloud = Pfinal(okmask,:);
T = [th1(okmask), th2(okmask), th3(okmask)];
end

function Vol = voxel_volume(Pcloud, edge)
% The tich theo mat do diem voi-toi: chia bounding box thanh voxel canh
% "edge" mm, dem so voxel co it nhat 1 diem voi-toi, nhan the tich 1 voxel.
if isempty(Pcloud), Vol = 0; return; end
vox = floor(Pcloud/edge);
vu = unique(vox,'rows');
Vol = size(vu,1) * edge^3;
end

function [zbest, areabest, Dbest, zlist, arealist] = max_cross_section(Pcloud, zstep)
% Quet z, tai moi z lay lat cat day (zstep/2) quanh z, chieu xuong XY,
% xap xi bien vung voi-toi bang convex hull cua lat cat (don gian hoa:
% khong phai occupancy that, chi la hull cua diem trong lat -- co the hoi
% cao hon dien tich thuc neu bien khong loi, nhung du de tim z toi uu va
% so sanh giua cac phuong an).
if isempty(Pcloud)
    zbest=NaN; areabest=0; Dbest=0; zlist=[]; arealist=[]; return;
end
band = zstep/2;
zmin = min(Pcloud(:,3)); zmax = max(Pcloud(:,3));
zlist = zmin:zstep:zmax;
arealist = zeros(size(zlist));
for i = 1:numel(zlist)
    z0 = zlist(i);
    sel = abs(Pcloud(:,3)-z0) <= band;
    pts = Pcloud(sel,1:2);
    if size(pts,1) >= 3
        try
            k = convhull(pts(:,1), pts(:,2));
            arealist(i) = polyarea(pts(k,1), pts(k,2));
        catch
            arealist(i) = 0;
        end
    end
end
[areabest, idx] = max(arealist);
zbest = zlist(idx);
Dbest = sqrt(4*areabest/pi);
end

function [t, P] = gen_quintic_path(W, Tseg, dt)
% Sinh quy dao quintic qua cac waypoint W (mx3) voi thoi gian tung doan
% Tseg -- giong het cach lam trong p5_trajectory.m (van toc/gia toc = 0
% tai moi waypoint).
t = []; P = [];
nseg = size(W,1) - 1;
for k = 1:nseg
    A = W(k,:); Bp = W(k+1,:); Tk = Tseg(k);
    tk = 0:dt:Tk;
    ss = 10*(tk/Tk).^3 - 15*(tk/Tk).^4 + 6*(tk/Tk).^5;
    Pk = A + ss(:)*(Bp-A);
    if k > 1, tk = tk(2:end); Pk = Pk(2:end,:); end
    t = [t, (sum(Tseg(1:k-1)) + tk)]; %#ok<AGROW>
    P = [P; Pk]; %#ok<AGROW>
end
end
