% p3_workspace.m -- Phase 3: quet vung lam viec, kiem tra tru Ø800x250 nam trong
clear; clc;
p = params();
if ~exist('figs','dir'), mkdir figs; end
if ~exist('out','dir'),  mkdir out;  end
diary('out/p3_log.txt'); diary on;
fprintf('=== PHASE 3: VUNG LAM VIEC ===\n');

xs = -650:15:650;  zs = -1350:15:-450;
% --- Mat cat dung y=0 (x-z) ---
RX = []; RZ = [];
for z = zs
  for x = xs
    [th,ok] = delta_ik([x;0;z], p);
    if ok && all(th>=p.th_min) && all(th<=p.th_max)
      RX(end+1)=x; RZ(end+1)=z; %#ok<SAGROW>
    end
  end
end

% --- Ban kinh voi-toi lon nhat tai z tam tru ---
zc = p.ws_zc; rmax_zc = 0;
for x = 0:5:650
  [th,ok]=delta_ik([x;0;zc],p);
  if ok && all(th>=p.th_min)&&all(th<=p.th_max), rmax_zc = x; else, break; end
end
% --- Khoang z voi-toi tren truc ---
zt_lo=NaN; zt_hi=NaN;
for z=-500:-2:-1350
  [th,ok]=delta_ik([0;0;z],p);
  good = ok && all(th>=p.th_min)&&all(th<=p.th_max);
  if good && isnan(zt_hi), zt_hi=z; end
  if good, zt_lo=z; end
end
fprintf('Ban kinh voi-toi tai z=%.0f: %.0f mm (can >= %.0f)\n', zc, rmax_zc, p.ws_D/2);
fprintf('Khoang z voi-toi tren truc: [%.0f, %.0f] mm\n', zt_lo, zt_hi);

% --- Kiem tra toan bo bien tru muc tieu (mat tru + 2 day) ---
Rw=p.ws_D/2; zlo=zc-p.ws_H/2; zhi=zc+p.ws_H/2; allin=true; nchk=0; nbad=0;
for z=[zlo zhi (zc)]
  for a=0:10:350
    P=[Rw*cosd(a);Rw*sind(a);z]; nchk=nchk+1;
    [th,ok]=delta_ik(P,p);
    if ~(ok&&all(th>=p.th_min)&&all(th<=p.th_max)), allin=false; nbad=nbad+1; end
  end
end
fprintf('Kiem tra bien tru muc tieu: %d diem, %d ngoai vung -> tru %s trong workspace\n', ...
    nchk, nbad, ternary(allin,'NAM GON','KHONG NAM GON'));

% --- Hinh 1: mat cat dung y=0 ---
f1=figure('Visible','on','Position',[100 100 720 640]);
plot(RX,RZ,'.','Color',[.6 .8 1],'MarkerSize',4); hold on;
rectangle('Position',[-Rw zlo 2*Rw p.ws_H],'EdgeColor','r','LineWidth',2);
plot(0,zc,'r+','MarkerSize',10,'LineWidth',1.5);
axis equal; grid on; xlabel('x [mm]'); ylabel('z [mm]');
title('Vung lam viec (mat cat y=0) + tru muc tieu Ø800x250');
legend('voi-toi','tru muc tieu','Location','best');
saveas(f1,'figs/p3_workspace_xz.png');

% --- Hinh 2: mat cat ngang z=zc ---
th_a=linspace(0,2*pi,200);
f2=figure('Visible','off','Position',[100 100 640 640]);
plot(rmax_zc*cos(th_a),rmax_zc*sin(th_a),'b-','LineWidth',1.5); hold on;
plot(Rw*cos(th_a),Rw*sin(th_a),'r--','LineWidth',2);
axis equal; grid on; xlabel('x [mm]'); ylabel('y [mm]');
title(sprintf('Mat cat ngang z=%.0f: bien voi-toi vs tru Ø800',zc));
legend('bien voi-toi','tru Ø800','Location','best');
saveas(f2,'figs/p3_slice_z.png');

fprintf('Da luu figs/p3_workspace_xz.png, figs/p3_slice_z.png\n');
diary off;
function s=ternary(c,a,b), if c, s=a; else, s=b; end, end
