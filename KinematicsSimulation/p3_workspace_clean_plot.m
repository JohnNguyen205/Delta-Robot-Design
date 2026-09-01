% p3_workspace_clean_plot.m -- ban sach (khong title/legend trong anh) cua
% figs/p3_workspace_xz.png, dung cho bao cao (giai thich dat o caption/van
% ban thay vi chu in tren hinh). Quet giong het p3_workspace.m.
clear; clc;
p = params();
if ~exist('figs','dir'), mkdir figs; end

xs = -650:15:650;  zs = -1350:15:-450;
RX = []; RZ = [];
for z = zs
  for x = xs
    [th,ok] = delta_ik([x;0;z], p);
    if ok && all(th>=p.th_min) && all(th<=p.th_max)
      RX(end+1)=x; RZ(end+1)=z; %#ok<SAGROW>
    end
  end
end

zc = p.ws_zc; Rw = p.ws_D/2; zlo = zc-p.ws_H/2; zhi = zc+p.ws_H/2;

f1 = figure('Visible','off','Position',[100 100 720 640]);
plot(RX,RZ,'.','Color',[.6 .8 1],'MarkerSize',4); hold on;
rectangle('Position',[-Rw zlo 2*Rw p.ws_H],'EdgeColor','r','LineWidth',2);
plot(0,zc,'r+','MarkerSize',10,'LineWidth',1.5);
axis equal; grid on; xlabel('x [mm]'); ylabel('z [mm]');
% KHONG title(), KHONG legend() -- giai thich dat trong caption bao cao
saveas(f1,'figs/p3_workspace_xz_clean.png');
fprintf('Da luu figs/p3_workspace_xz_clean.png (khong title/legend)\n');
fprintf('So diem voi-toi ve: %d\n', numel(RX));
