% p5_trajectory.m -- Phase 5: quy dao pick-and-place (cong/gate) + theta,omega,alpha
clear; clc;
p = params();
if ~exist('figs','dir'), mkdir figs; end
if ~exist('out','dir'),  mkdir out;  end
diary('out/p5_log.txt'); diary on;
fprintf('=== PHASE 5: QUY DAO PICK-AND-PLACE ===\n');

% --- Waypoint & thoi gian tung doan (giay) ---
W = [ 300 0 -1000;   % A: gap (pick)
      300 0  -820;   % nang len
     -300 0  -820;   % di ngang
     -300 0 -1000];  % D: dat (place)
Tseg = [0.30 0.60 0.30];      % thoi gian moi doan
dt = 0.002;
fprintf('Waypoints (mm): pick(300,0,-1000)->nang->ngang->place(-300,0,-1000)\n');
fprintf('Thoi gian: %.2f + %.2f + %.2f = %.2f s ; dt=%.3f\n', Tseg, sum(Tseg), dt);

% --- Sinh quy dao voi luat thoi gian quintic (van toc, gia toc = 0 tai waypoint) ---
t=[]; P=[];
for k=1:3
  A=W(k,:); Bp=W(k+1,:); Tk=Tseg(k);
  tk=0:dt:Tk;
  ss=10*(tk/Tk).^3 - 15*(tk/Tk).^4 + 6*(tk/Tk).^5;   % quintic 0->1
  Pk=A + ss(:)*(Bp-A);
  if k>1, tk=tk(2:end); Pk=Pk(2:end,:); end          % tranh trung diem noi
  t=[t, (sum(Tseg(1:k-1))+tk)]; P=[P; Pk]; %#ok<AGROW>
end
n=numel(t);

% --- IK tren toan quy dao ---
TH=zeros(n,3); reach=true(n,1);
for i=1:n
  [th,ok]=delta_ik(P(i,:).',p);
  if ~ok||any(th<p.th_min)||any(th>p.th_max), reach(i)=false; end
  TH(i,:)=th.';
end
fprintf('Diem voi-toi tren quy dao: %d/%d (%.1f%%)\n',sum(reach),n,100*mean(reach));

% --- Van toc/gia toc goc (vi phan sai phan trung tam) ---
OM = gradient(TH.',dt).';        % rad/s (n x 3)
AL = gradient(OM.',dt).';        % rad/s^2
OMd=rad2deg(OM); ALd=rad2deg(AL); THd=rad2deg(TH);

% --- Van toc/gia toc TCP ---
V = gradient(P.',dt).';  Vs=sqrt(sum(V.^2,2));   % mm/s
Acc = gradient(V.',dt).'; As=sqrt(sum(Acc.^2,2));% mm/s^2

fprintf('\n--- DINH (peak) ---\n');
for j=1:3
 fprintf('Khop %d: |theta|<=%.1f deg, |omega|max=%.1f deg/s (%.2f rpm), |alpha|max=%.0f deg/s^2\n',...
   j, max(abs(THd(:,j))), max(abs(OMd(:,j))), max(abs(OMd(:,j)))/6, max(abs(ALd(:,j))));
end
fprintf('TCP: van toc max=%.0f mm/s, gia toc max=%.0f mm/s^2 (%.2f g)\n', ...
    max(Vs), max(As), max(As)/9810);

% --- Hinh ---
f1=figure('Visible','on','Position',[100 100 700 560]);
plot3(P(:,1),P(:,2),P(:,3),'b-','LineWidth',1.8); hold on; grid on;
plot3(W(:,1),W(:,2),W(:,3),'ro','MarkerFaceColor','r');
text(W(1,1),W(1,2),W(1,3),'  pick'); text(W(4,1),W(4,2),W(4,3),'  place');
xlabel('x'); ylabel('y'); zlabel('z [mm]'); axis equal; view(0,0);
title('Quy dao pick-and-place (cong)'); saveas(f1,'figs/p5_path.png');

f2=figure('Visible','on','Position',[100 100 900 700]);
subplot(3,1,1); plot(t,THd,'LineWidth',1.3); grid on; ylabel('\theta [deg]');
legend('\theta_1','\theta_2','\theta_3','Location','eastoutside'); title('Goc khop');
subplot(3,1,2); plot(t,OMd,'LineWidth',1.3); grid on; ylabel('\omega [deg/s]');
subplot(3,1,3); plot(t,ALd,'LineWidth',1.3); grid on; ylabel('\alpha [deg/s^2]'); xlabel('t [s]');
saveas(f2,'figs/p5_joint_profiles.png');
fprintf('Da luu figs/p5_path.png, figs/p5_joint_profiles.png\n');

save('out/p5_traj.mat','t','P','TH','OM','AL','W','Tseg');
diary off;
