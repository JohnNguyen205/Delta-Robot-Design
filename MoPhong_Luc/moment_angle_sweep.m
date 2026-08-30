%% MOMENT_ANGLE_SWEEP  Quet mo-men theo goc tay chu dong
% Mo hinh doi xung dung cung bo thong so voi force_analysis.m.
% Muc tieu:
%   1) Viet lai cong thuc can bang luc dang dung trong bao cao.
%   2) Quet theta trong gioi han khop, tinh luc thanh va mo-men tung khop.
%   3) Tim goc co mo-men lon nhat de doi chieu voi mo phong dong luc hoc.
%
% Don vi: mm, rad, N, N.m. Jv co don vi mm/rad nen khi nhan luc phai
% chia 1000 de doi sang N.m.

clear; clc; close all;
p = params();

if ~exist('out','dir'), mkdir out; end
if ~exist('figs','dir'), mkdir figs; end

diary('out/moment_angle_sweep_log.txt'); diary on;
fprintf('=== QUET MO-MEN THEO GOC TAY CHU DONG ===\n');
fprintf('Mo hinh doi xung, tai TCP di chuyen theo truc z.\n\n');

% Khoi luong va gia toc dung chung voi force_analysis.m
m_plat = 4.214; m_pay = 2.0; m_rod = 0.348; m_ball = 0.325;
m_arm = 6.912;
m_ee = m_plat + m_pay + 0.5*(6*m_rod + 6*m_ball);
g = 9.81;
a_z = 11.58;                 % gia toc nang dinh [m/s^2]
F_z = m_ee*(g + a_z);        % luc tong theo phuong z [N]
L1m = p.L1/1000;
r_cg = L1m/2;
k_s = 1.5;

% Mien truyen luc dung cho tinh thiet ke: loai vung gan singularity
% (mu -> 90 deg lam cos(mu) -> 0). Dung du phong 30...75 deg.
mu_min_allowed = 30;
mu_max_allowed = 75;

% Quet goc theo gioi han khai bao trong params.m.
npt = 1451;
theta_deg = linspace(rad2deg(p.th_min), rad2deg(p.th_max), npt).';
theta = deg2rad(theta_deg);

z = nan(npt,1); mu_deg = nan(npt,1); N_i = nan(npt,1);
M_load = nan(npt,1); M_arm = nan(npt,1); M_simple = nan(npt,1);
M_jac = nan(npt,1); reach = false(npt,1);
tau_jac = nan(npt,3);
ik_err_deg = nan(npt,1);

for k = 1:npt
    th = repmat(theta(k),3,1);
    % Pose doi xung P=[0 0 z]. Tu |E_i-P_i|=L2:
    % z = -L1 sin(theta) - sqrt(L2^2-(R-r+L1 cos(theta))^2).
    q = p.L2^2 - (p.Rr + p.L1*cos(theta(k)))^2;
    if q <= 0
        continue;
    end
    z(k) = -p.L1*sin(theta(k)) - sqrt(q);
    P = [0; 0; z(k)];

    [th_ik,ok] = delta_ik(P,p);
    if ~ok || any(~isfinite(th_ik))
        continue;
    end
    reach(k) = true;
    ik_err_deg(k) = max(abs(rad2deg(th_ik-th)));

    [Jv,~,mu,~,~] = delta_jacobian(P,th,p);
    mu_deg(k) = mu;
    % Cong thuc can bang luc don gian dung trong bao cao:
    % F_z=m_ee(g+a_z), F_zi=F_z/3, N_i=F_zi/cos(mu).
    N_i(k) = (F_z/3)/cosd(mu_deg(k));
    M_load(k) = N_i(k)*L1m;
    M_arm(k) = m_arm*g*r_cg*abs(cos(theta(k)));
    M_simple(k) = M_load(k) + M_arm(k);

    % Kiem tra bang Jacobian van toc cua cung pose doi xung.
    tau_jac(k,:) = (Jv.'*[0;0;F_z]).'/1000;
    M_jac(k) = max(abs(tau_jac(k,:))) + M_arm(k);
end

valid = reach & isfinite(M_simple) & isfinite(M_jac) & ...
    mu_deg >= mu_min_allowed & mu_deg <= mu_max_allowed;
if ~any(valid)
    error('Khong co diem quet nao nam trong mien lam viec.');
end

[Msm,im] = max(M_simple(valid));
iv = find(valid); im = iv(im);
[Mjm,ij] = max(M_jac(valid));
ivj = find(valid); ij = ivj(ij);

fprintf('m_ee = %.3f kg; a_z = %.2f m/s^2; F_z = m_ee(g+a_z) = %.2f N\n', m_ee,a_z,F_z);
fprintf('Gioi han quet: %.2f ... %.2f deg; so diem hop le: %d/%d\n', ...
    theta_deg(1),theta_deg(end),sum(valid),npt);
fprintf('Mien loc truyen luc: %.1f <= mu <= %.1f deg (loai vung gan singularity)\n', ...
    mu_min_allowed,mu_max_allowed);
fprintf('Sai so IK lon nhat tai diem hop le: %.3e deg\n\n',max(ik_err_deg(valid)));
fprintf('--- KET QUA THEO CONG THUC CAN BANG LUC ---\n');
fprintf('M_simplified,max = %.2f N.m tai theta = %.2f deg\n', Msm,theta_deg(im));
fprintf('  mu = %.2f deg; N_i = %.2f N; M_load = %.2f N.m; M_arm = %.2f N.m\n', ...
    mu_deg(im),N_i(im),M_load(im),M_arm(im));
fprintf('  M_chon = k_s*M_simplified,max = %.2f N.m (k_s=%.2f)\n',k_s*Msm,k_s);
fprintf('\n--- DOI CHIEU JACOBIAN TAI CUNG POSE ---\n');
fprintf('M_jacobian,max = %.2f N.m tai theta = %.2f deg\n', Mjm,theta_deg(ij));
fprintf('  mu = %.2f deg; M_arm = %.2f N.m; tau_jac = [%.2f %.2f %.2f] N.m\n', ...
    mu_deg(ij),M_arm(ij),tau_jac(ij,1),tau_jac(ij,2),tau_jac(ij,3));

% Bang so lieu de co the kiem tra doc lap.
T = table(theta_deg,z,mu_deg,N_i,M_load,M_arm,M_simple,M_jac,valid, ...
    'VariableNames',{'theta_deg','z_mm','mu_deg','N_i_N','M_load_Nm', ...
    'M_arm_Nm','M_simple_Nm','M_jac_Nm','valid'});
writetable(T,'out/moment_angle_sweep.csv');
save('out/moment_angle_sweep.mat','theta_deg','z','mu_deg','N_i','M_load', ...
    'M_arm','M_simple','M_jac','tau_jac','valid','m_ee','a_z','F_z','k_s', ...
    'Msm','im','Mjm','ij','mu_min_allowed','mu_max_allowed','p');

% Hinh tong hop de dua vao bao cao.
f = figure('Visible','off','Position',[100 100 980 610]);
M_simple_plot=M_simple; M_simple_plot(~valid)=NaN;
plot(theta_deg,M_simple_plot,'-','Color',[0.64 0.08 0.18],'LineWidth',2.4);
grid on; box on;
xlabel('Goc tay chu dong \theta [deg]'); ylabel('Mo-men tai truc dong co [N.m]');
title('Mo-men theo goc tay chu dong (payload 2 kg)');
print(f,'figs/moment_angle_sweep.png','-dpng','-r150');
close(f);

% Hinh transmission angle va luc doc de kiem tra nguyen nhan cuc dai.
f2 = figure('Visible','off','Position',[100 100 980 560]);
mu_plot=mu_deg; mu_plot(~valid)=NaN; Ni_plot=N_i; Ni_plot(~valid)=NaN;
yyaxis left; plot(theta_deg,mu_plot,'LineWidth',1.8); ylabel('\mu [deg]');
yyaxis right; plot(theta_deg,Ni_plot,'LineWidth',1.8); ylabel('N_i [N]');
grid on; box on; xlabel('Goc tay chu dong \theta [deg]');
title('Goc truyen va luc doc theo goc tay chu dong');
print(f2,'figs/transmission_force_angle.png','-dpng','-r150');
close(f2);

fprintf('\nDa luu: out/moment_angle_sweep_log.txt, out/moment_angle_sweep.csv,\n');
fprintf('        out/moment_angle_sweep.mat, figs/moment_angle_sweep.png,\n');
fprintf('        figs/transmission_force_angle.png\n');
diary off;
fprintf('DONE\n');
