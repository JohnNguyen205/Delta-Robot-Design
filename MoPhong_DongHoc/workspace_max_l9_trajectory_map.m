% WORKSPACE_MAX_L9_TRAJECTORY_MAP
% Mo phong maximum workspace cho thiet ke hien tai va 9 nhom L9(3^4),
% sau do kiem tra quy dao gap-dat quintic hien tai.
%
% Phuong phap:
%   1) Quet luoi FK trong gioi han theta = [-45, 70] deg de tao dam may
%      diem voi-toi cua tung bo thong so.
%   2) Dem voxel 10 mm de uoc luong the tich vung lam viec.
%   3) Quet cac lat z, dung convex hull cua lat diem de tim mat cat ngang
%      co dien tich lon nhat va duong kinh tuong duong.
%   4) Dung IK tren 601 diem quy dao gap-dat hien tai de kiem tra bao phu.
%
% Quy dao hien tai:
%   A (gap)       = [ 300, 0, -1000] mm
%   B (nang len)  = [ 300, 0,  -820] mm
%   C (di ngang)  = [-300, 0,  -820] mm
%   D (dat)       = [-300, 0, -1000] mm
%   Thoi gian     = [0.30, 0.60, 0.30] s
%
% Ket qua:
%   out/workspace_max_l9_trajectory.csv
%   out/workspace_max_l9_trajectory.mat
%   figs/workspace_max_l9_trajectory_map.png
%   figs/workspace_max_l9_max_slice_map.png
%
% Luu y: day la chuong trinh kiem chung theo phuong phap STT07, khong tu
% dong thay doi kich thuoc thiet ke trong params.m.

clear; clc;
if ~exist('figs','dir'), mkdir('figs'); end
if ~exist('out','dir'), mkdir('out'); end

diary('out/workspace_max_l9_trajectory_log.txt');
diary on;

p0 = params();

% L9(3^4): [L1, L2, R, r] theo 9 hang cua bai bao STT07.
L1_levels = [350, 407.5, 465];
L2_levels = [850, 1000, 1150];
R_levels  = [300, 347, 394];
r_levels = [90, 120.6, 150];
DM = [1 1 1 1; 1 2 2 2; 1 3 3 3; ...
      2 1 2 3; 2 2 3 1; 2 3 1 2; ...
      3 1 3 2; 3 2 1 3; 3 3 2 1];

% Row 0 la thiet ke hien tai; Row 1..9 la 9 cau hinh L9.
designs = [p0.L1, p0.L2, p0.R, p0.r; ...
           L1_levels(DM(:,1)).', L2_levels(DM(:,2)).', ...
           R_levels(DM(:,3)).', r_levels(DM(:,4)).'];
nrun = size(designs,1);
labels = [{'Hien tai'}, arrayfun(@(k) sprintf('L9-%d', k), 1:9, 'UniformOutput', false)];

% Luoi FK va thong so cat.
Ngrid = 45;
theta_grid = linspace(p0.th_min, p0.th_max, Ngrid);
voxel_edge = 10;
zstep = 15;

% Quy dao gap-dat hien tai.
W = [ 300, 0, -1000; ...
      300, 0,  -820; ...
     -300, 0,  -820; ...
     -300, 0, -1000];
Tseg = [0.30, 0.60, 0.30];
[t_path, P_path] = gen_quintic_path(W, Tseg, 0.002);
n_path = size(P_path,1);

fprintf('=== MAXIMUM WORKSPACE + TRAJECTORY MAP L9 ===\n');
fprintf('Gioi han goc: [%.0f, %.0f] deg; luoi FK: %d^3 = %d to hop\n', ...
    rad2deg(p0.th_min), rad2deg(p0.th_max), Ngrid, Ngrid^3);
fprintf('Quy dao: %d diem, thoi gian %.2f s\n\n', n_path, sum(Tseg));

% Bo nho ket qua.
Run = (0:nrun-1).';
L1 = designs(:,1); L2 = designs(:,2); R = designs(:,3); r = designs(:,4);
ValidFK = zeros(nrun,1);
WorkspaceVolume = zeros(nrun,1);
MaxArea = zeros(nrun,1);
MaxAreaZ = nan(nrun,1);
EquivalentDiameter = zeros(nrun,1);
GateCornersOK = zeros(nrun,1);
PathOK = zeros(nrun,1);
PathTotal = repmat(n_path,nrun,1);
PathPercent = zeros(nrun,1);
Pass = false(nrun,1);

% Luu dam may va thong tin mat cat de ve hinh sau.
clouds = cell(nrun,1);
slice_points = cell(nrun,1);
slice_hulls = cell(nrun,1);
path_ok_all = cell(nrun,1);
z_curves = cell(nrun,1);
area_curves = cell(nrun,1);

for run = 1:nrun
    p = p0;
    p.L1 = L1(run); p.L2 = L2(run); p.R = R(run); p.r = r(run);
    p.Rr = p.R - p.r;

    fprintf('--- %s (Run %d): L1=%.1f, L2=%.1f, R=%.1f, r=%.1f ---\n', ...
        labels{run}, Run(run), p.L1, p.L2, p.R, p.r);

    tic_run = tic;
    [Pcloud, Tcloud] = fk_grid_cloud(theta_grid, theta_grid, theta_grid, p);
    clouds{run} = Pcloud;
    ValidFK(run) = size(Pcloud,1);
    WorkspaceVolume(run) = voxel_volume(Pcloud, voxel_edge);
    [zbest, areabest, Dbest, zlist, arealist] = max_cross_section(Pcloud, zstep);
    MaxArea(run) = areabest;
    MaxAreaZ(run) = zbest;
    EquivalentDiameter(run) = Dbest;
    z_curves{run} = zlist;
    area_curves{run} = arealist;

    % Kiem tra 4 waypoint va toan bo quy dao bang IK.
    corner_ok = false(4,1);
    for i = 1:4
        [theta_corner, ok_corner] = delta_ik(W(i,:).', p);
        corner_ok(i) = ok_corner && all(theta_corner >= p.th_min) && ...
                       all(theta_corner <= p.th_max);
    end
    GateCornersOK(run) = sum(corner_ok);

    path_ok = false(n_path,1);
    for i = 1:n_path
        [theta_i, ok_i] = delta_ik(P_path(i,:).', p);
        path_ok(i) = ok_i && all(theta_i >= p.th_min) && all(theta_i <= p.th_max);
    end
    path_ok_all{run} = path_ok;
    PathOK(run) = sum(path_ok);
    PathPercent(run) = 100*PathOK(run)/PathTotal(run);
    Pass(run) = (GateCornersOK(run) == 4) && (PathOK(run) == PathTotal(run));

    % Luu cac diem mat cat lon nhat va hull de ve ban do.
    if ~isempty(Pcloud) && isfinite(zbest)
        sel = abs(Pcloud(:,3)-zbest) <= zstep/2;
        pts = Pcloud(sel,1:2);
        slice_points{run} = pts;
        if size(pts,1) >= 3
            kh = convhull(pts(:,1),pts(:,2));
            slice_hulls{run} = pts(kh,:);
        else
            slice_hulls{run} = zeros(0,2);
        end
    else
        slice_points{run} = zeros(0,2);
        slice_hulls{run} = zeros(0,2);
    end

    fprintf('  FK hop le: %d/%d; V=%.0f mm^3; Amax=%.1f mm^2 tai z=%.1f; Dtd=%.1f mm\n', ...
        ValidFK(run), Ngrid^3, WorkspaceVolume(run), MaxArea(run), MaxAreaZ(run), EquivalentDiameter(run));
    fprintf('  Quy dao: waypoint %d/4; toan bo %d/%d = %.2f%%; ket luan: %s; thoi gian %.2f s\n\n', ...
        GateCornersOK(run), PathOK(run), PathTotal(run), PathPercent(run), pass_text(Pass(run)), toc(tic_run));

    % Tcloud duoc tinh de tu kiem tra ket qua vector hoa o Run 0.
    if run == 1 && ~isempty(Pcloud)
        rng(11);
        ncheck = min(20, size(Pcloud,1));
        ids = randperm(size(Pcloud,1), ncheck);
        err_fk = 0;
        for jj = ids
            [pref, okref] = delta_fk(Tcloud(jj,:).', p);
            if okref
                err_fk = max(err_fk, norm(pref(:)-Pcloud(jj,:).'));
            end
        end
        fprintf('  Tu kiem tra Run 0: sai so FK vector hoa lon nhat = %.3e mm\n\n', err_fk);
    end
end

% Tao bang ket qua va ghi CSV/MAT.
Result = table(Run, labels.', L1, L2, R, r, ValidFK, WorkspaceVolume, ...
    MaxArea, MaxAreaZ, EquivalentDiameter, GateCornersOK, PathOK, PathTotal, ...
    PathPercent, Pass, ...
    'VariableNames', {'Run','Label','L1_mm','L2_mm','R_mm','r_mm', ...
    'ValidFKPoints','WorkspaceVolume_mm3','MaxCrossSectionArea_mm2', ...
    'MaxCrossSectionZ_mm','EquivalentDiameter_mm','GateCornersOK_0to4', ...
    'PathOK','PathTotal','PathPercent','Pass'});
writetable(Result, 'out/workspace_max_l9_trajectory.csv');
save('out/workspace_max_l9_trajectory.mat', 'Result', 'designs', 'DM', ...
    'W', 'Tseg', 't_path', 'P_path', 'clouds', 'slice_points', 'slice_hulls', ...
    'path_ok_all', 'z_curves', 'area_curves', 'p0');

% Hinh 1: ban do X-Z tai Y=0 va quy dao, moi o la mot cau hinh.
f1 = figure('Visible','off','Position',[50 50 1800 760], 'Color','w');
for run = 1:nrun
    subplot(2,5,run);
    Pcloud = clouds{run};
    if ~isempty(Pcloud)
        sel_y = abs(Pcloud(:,2)) <= 7.5;
        plot(Pcloud(sel_y,1), Pcloud(sel_y,3), '.', 'Color',[0.72 0.82 0.95], 'MarkerSize',2); hold on;
    else
        hold on;
    end
    plot(P_path(path_ok_all{run},1), P_path(path_ok_all{run},3), '.', ...
        'Color',[0.05 0.55 0.18], 'MarkerSize',7);
    plot(P_path(~path_ok_all{run},1), P_path(~path_ok_all{run},3), 'rx', ...
        'LineWidth',1.2, 'MarkerSize',5);
    plot(W(:,1), W(:,3), 'ko', 'MarkerFaceColor','m', 'MarkerSize',4);
    rectangle('Position',[-300 -1000 600 180], 'EdgeColor',[0.85 0.15 0.10], ...
        'LineStyle','--', 'LineWidth',0.8);
    grid on; axis equal; xlim([-700 700]); ylim([-1250 -300]);
    xlabel('X [mm]'); ylabel('Z [mm]');
    title(sprintf('%s: %s\nA_{max}=%.0f, z=%.0f, path=%.1f%%', ...
        labels{run}, pass_text(Pass(run)), MaxArea(run), MaxAreaZ(run), PathPercent(run)), ...
        'FontSize',8);
end
sgtitle(sprintf('Ban do vung lam viec va quy dao tai Y=0 | theta=[%.0f, %.0f] deg', ...
    rad2deg(p0.th_min), rad2deg(p0.th_max)), 'FontWeight','bold');
saveas(f1, 'figs/workspace_max_l9_trajectory_map.png');
close(f1);

% Hinh 2: mat cat ngang lon nhat cua tung cau hinh.
f2 = figure('Visible','off','Position',[50 50 1800 760], 'Color','w');
for run = 1:nrun
    subplot(2,5,run);
    pts = slice_points{run};
    hull = slice_hulls{run};
    if ~isempty(pts)
        plot(pts(:,1), pts(:,2), '.', 'Color',[0.72 0.82 0.95], 'MarkerSize',2); hold on;
    else
        hold on;
    end
    if ~isempty(hull)
        plot(hull(:,1), hull(:,2), 'b-', 'LineWidth',1.2);
    end
    ang = linspace(0,2*pi,240);
    plot((p0.ws_D/2)*cos(ang), (p0.ws_D/2)*sin(ang), 'r--', 'LineWidth',1.0);
    grid on; axis equal; xlim([-700 700]); ylim([-700 700]);
    xlabel('X [mm]'); ylabel('Y [mm]');
    title(sprintf('%s: V=%.3g m^3\nD_{td}=%.0f mm @ z=%.0f', ...
        labels{run}, WorkspaceVolume(run)*1e-9, EquivalentDiameter(run), MaxAreaZ(run)), ...
        'FontSize',8);
end
sgtitle('Mat cat ngang lon nhat | duong do: duong kinh muc tieu 800 mm', 'FontWeight','bold');
saveas(f2, 'figs/workspace_max_l9_max_slice_map.png');
close(f2);

% Tom tat de doc nhanh trong log.
fprintf('=== TOM TAT KIEM TRA QUY DAO ===\n');
for run = 1:nrun
    fprintf('%s: V=%.0f mm^3; Amax=%.1f mm^2; z=%.1f mm; Dtd=%.1f mm; ', ...
        labels{run}, WorkspaceVolume(run), MaxArea(run), MaxAreaZ(run), EquivalentDiameter(run));
    fprintf('waypoint=%d/4; path=%d/%d (%.2f%%); %s\n', ...
        GateCornersOK(run), PathOK(run), PathTotal(run), PathPercent(run), pass_text(Pass(run)));
end

fprintf('\nDa luu:\n');
fprintf('  out/workspace_max_l9_trajectory.csv\n');
fprintf('  out/workspace_max_l9_trajectory.mat\n');
fprintf('  figs/workspace_max_l9_trajectory_map.png\n');
fprintf('  figs/workspace_max_l9_max_slice_map.png\n');
fprintf('=== HET CHUONG TRINH ===\n');
diary off;

function txt = pass_text(pass_value)
if pass_value
    txt = 'DAT';
else
    txt = 'KHONG DAT';
end
end

function [Pcloud, T] = fk_grid_cloud(t1, t2, t3, p)
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
y1(valid_det) = (G22(valid_det).*bb1(valid_det)-G12(valid_det).*bb2(valid_det))./detG(valid_det);
y2(valid_det) = (G11(valid_det).*bb2(valid_det)-G12(valid_det).*bb1(valid_det))./detG(valid_det);
P0 = y1.*A1 + y2.*A2;
aa = sum(d.*d,2); diff0 = P0-C1;
bq = 2*sum(d.*diff0,2);
cq = sum(diff0.*diff0,2)-p.L2^2;
disc = bq.^2-4*aa.*cq;
okmask = valid_det & (aa > 1e-9) & (disc >= -1e-6);
sq = sqrt(max(disc,0));
tA = (-bq+sq)./(2*aa); tB = (-bq-sq)./(2*aa);
Pa = P0+tA.*d; Pb = P0+tB.*d;
lowerA = Pa(:,3) <= Pb(:,3);
Pfinal = Pb; Pfinal(lowerA,:) = Pa(lowerA,:);
okmask = okmask & all(isfinite(Pfinal),2);
Pcloud = Pfinal(okmask,:);
T = [th1(okmask), th2(okmask), th3(okmask)];
end

function Vol = voxel_volume(Pcloud, edge)
if isempty(Pcloud), Vol = 0; return; end
vox = floor(Pcloud/edge);
Vol = size(unique(vox,'rows'),1)*edge^3;
end

function [zbest, areabest, Dbest, zlist, arealist] = max_cross_section(Pcloud, zstep)
if isempty(Pcloud)
    zbest=NaN; areabest=0; Dbest=0; zlist=[]; arealist=[]; return;
end
band = zstep/2;
zlist = min(Pcloud(:,3)):zstep:max(Pcloud(:,3));
arealist = zeros(size(zlist));
for i = 1:numel(zlist)
    pts = Pcloud(abs(Pcloud(:,3)-zlist(i)) <= band,1:2);
    if size(pts,1) >= 3
        try
            k = convhull(pts(:,1),pts(:,2));
            arealist(i) = polyarea(pts(k,1),pts(k,2));
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
t = []; P = [];
for k = 1:size(W,1)-1
    A = W(k,:); B = W(k+1,:); Tk = Tseg(k);
    tk = 0:dt:Tk;
    tau = tk/Tk;
    s = 10*tau.^3 - 15*tau.^4 + 6*tau.^5;
    Pk = A + s(:)*(B-A);
    if k > 1
        tk = tk(2:end); Pk = Pk(2:end,:);
    end
    t = [t, sum(Tseg(1:k-1))+tk]; %#ok<AGROW>
    P = [P; Pk]; %#ok<AGROW>
end
end
