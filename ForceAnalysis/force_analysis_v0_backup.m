% force_analysis.m -- MO PHONG / PHAN TICH LUC Delta Robot (payload 2 kg)
% ------------------------------------------------------------------------
%  Muc dich: xac dinh TAI TRONG THUC lam dau vao cho mo phong ben (FEA)
%            va kiem tra chon dong co - hop so.
%
%  Mo hinh luc:
%   - Thanh truyen (forearm) la THANH 2-LUC (ball joint 2 dau) -> chi chiu
%     luc DOC truc, huong theo vector don vi l_i cua forearm.
%   - Can bang luc tai ban may:  sum_i ( f_i * l_i ) = m_ee * ( a - g )
%       f_i  : luc doc moi CAP forearm (2 thanh/cap) [N]
%       l_i  : vector don vi forearm i (khuyu -> ban may)
%       m_ee : khoi luong quy ve dau cong tac [kg]
%       a    : gia toc ban may [m/s^2];  g = [0;0;-9.81]
%   - Momen khop dong co:  tau = Jf.' * F_ee   (Jf: Jacobian van toc mm/rad)
%
%  Quy dao: pick-and-place quintic (giong mo phong dong hoc, chu ky 1.2 s).
%  Ket qua: dinh (peak) f_i, F_ee, tau_i  ->  out/ , figs/.
% ------------------------------------------------------------------------
clear; clc;
p = params();
if ~exist('out','dir'), mkdir out; end
if ~exist('figs','dir'), mkdir figs; end
diary('out/force_log.txt'); diary on;
fprintf('=== MO PHONG LUC DELTA ROBOT (payload 2 kg) ===\n\n');

% --- Khoi luong (kg) doc tu mo hinh SolidWorks (mass properties) ---
m_plat = 4.214;   % ban may DR-007
m_pay  = 2.0;     % payload muc tieu (thiet ke <= 2 kg)
m_rod  = 0.348;   % 1 thanh truyen 6516K305 (carbon)
m_ball = 0.325;   % 1 khop cau 60645K471 (thep)
% khoi luong quy ve dau cong tac = ban may + payload + 1/2 he thanh truyen (phia ban may)
m_ee = m_plat + m_pay + 0.5*(6*m_rod + 6*m_ball);
g = 9.81; gv = [0;0;-g];
fprintf('m_ee = ban may(%.3f) + payload(%.1f) + 1/2 forearm(%.3f) = %.3f kg\n', ...
        m_plat, m_pay, 0.5*(6*m_rod+6*m_ball), m_ee);

% --- Quy dao pick-and-place (quintic, chu ky 1.2 s) ---
W = [ 300 0 -1000; 300 0 -820; -300 0 -820; -300 0 -1000];  % waypoints (mm)
Tseg = [0.30 0.60 0.30]; dt = 0.002;
t=[]; P=[];
for k=1:3
  A=W(k,:); Bp=W(k+1,:); Tk=Tseg(k); tk=0:dt:Tk;
  ss=10*(tk/Tk).^3 - 15*(tk/Tk).^4 + 6*(tk/Tk).^5;
  Pk=A + ss(:)*(Bp-A);
  if k>1, tk=tk(2:end); Pk=Pk(2:end,:); end
  t=[t,(sum(Tseg(1:k-1))+tk)]; P=[P;Pk];
end
n=numel(t);
V=gradient(P.',dt).'; Acc=gradient(V.',dt).'; Acc_m=Acc/1000;   % m/s^2

% --- Vong tinh luc tren quy dao ---
F=zeros(n,3); TAU=zeros(n,3); FE=zeros(n,3); reach=true(n,1);
for i=1:n
  [th,ok]=delta_ik(P(i,:).',p); if ~ok, reach(i)=false; end
  L=zeros(3,3);
  for j=1:3
    c=cos(p.phi(j)); s=sin(p.phi(j)); ct=cos(th(j)); st=sin(th(j));
    Ej=[p.R*c+p.L1*ct*c; p.R*s+p.L1*ct*s; -p.L1*st];
    Pj=[P(i,1)+p.r*c; P(i,2)+p.r*s; P(i,3)];
    L(:,j)=(Pj-Ej)/norm(Pj-Ej);
  end
  a=Acc_m(i,:).'; F_ee=m_ee*(a-gv); FE(i,:)=F_ee.';
  if rcond(L)>1e-6, F(i,:)=(L\F_ee).'; else, F(i,:)=NaN; end
  [Jf,~]=delta_jacobian(P(i,:).',th,p);
  if all(isfinite(Jf(:))), TAU(i,:)=(Jf.'*F_ee).'/1000; end
end
Fee_mag=sqrt(sum(FE.^2,2));

% --- Ket qua dinh ---
fMax=max(abs(F(:))); tauMax=max(abs(TAU(:))); FeeMax=max(Fee_mag);
fprintf('\n--- TAI TRONG DINH (peak) tren quy dao ---\n');
fprintf(' Luc dau cong tac  |F_ee|max        = %6.1f N\n', FeeMax);
fprintf(' Luc doc forearm   |f_i|max (1 cap)  = %6.1f N  -> moi thanh %.1f N, moi ball-joint %.1f N\n', fMax, fMax/2, fMax/2);
fprintf(' Momen khop        |tau_i|max        = %6.2f N.m  (kiem chon dong co/hop so TPM-010S)\n', tauMax);
fprintf(' Momen uon bicep uoc (f*L1)          = %6.1f N.m\n', fMax*p.L1/1000);
fprintf('\n Bang tai FEA (dung cho tung chi tiet):\n');
fprintf('   DR-006 Elbow-Clevis : %.0f N (1 cap forearm o 2 lo rod)\n', ceil(fMax));
fprintf('   6516K305 Rod        : %.0f N doc truc (nen/keo, kiem oan Euler)\n', ceil(fMax/2));
fprintf('   DR-007 Platform     : %.0f N moi diem bat (6 diem)\n', ceil(fMax/2));
fprintf('   DR-005-2 Arm-Link   : momen uon ~%.0f N.m tai vai\n', ceil(fMax*p.L1/1000));

% --- Hinh ---
f1=figure('Visible','off','Position',[100 100 820 460]);
plot(t,F(:,1),'-','LineWidth',1.4); hold on; plot(t,F(:,2),'-','LineWidth',1.4); plot(t,F(:,3),'-','LineWidth',1.4);
grid on; xlabel('t [s]'); ylabel('Luc doc forearm f_i [N]'); title('Luc doc moi cap forearm theo thoi gian (payload 2 kg)');
legend('cap 1','cap 2','cap 3','Location','best'); saveas(f1,'figs/forearm_forces.png');

f2=figure('Visible','off','Position',[100 100 820 460]);
plot(t,TAU(:,1),'-','LineWidth',1.4); hold on; plot(t,TAU(:,2),'-','LineWidth',1.4); plot(t,TAU(:,3),'-','LineWidth',1.4);
grid on; xlabel('t [s]'); ylabel('Momen khop \tau_i [N.m]'); title('Momen khop dong co theo thoi gian');
legend('\tau_1','\tau_2','\tau_3','Location','best'); saveas(f2,'figs/joint_torques.png');

f3=figure('Visible','off','Position',[100 100 820 460]);
plot(t,Fee_mag,'b-','LineWidth',1.6); grid on; xlabel('t [s]'); ylabel('|F_{ee}| [N]');
title('Do lon luc dau cong tac theo thoi gian'); saveas(f3,'figs/force_ee.png');

save('out/force_results.mat','t','P','F','TAU','FE','m_ee','fMax','tauMax','FeeMax');
fprintf('\nDa luu: out/force_log.txt, out/force_results.mat, figs/{forearm_forces,joint_torques,force_ee}.png\n');
diary off;
fprintf('DONE\n');
