% p4b_cond3d.m -- Phase 4b: 3D scatter cua so dieu kien Jacobian tren toan vung lam viec
% Thay the cho ban do 2D mat cat (figs/p4_cond_map.png) bang scatter3 tren toan bo
% 34.372 diem quet 3D thuc te (cung vong lap voi p4_singularity.m).
clear; clc;
p = params();
if ~exist('figs','dir'), mkdir figs; end
if ~exist('out','dir'),  mkdir out;  end
diary('out/p4b_log.txt'); diary on;
fprintf('=== PHASE 4b: 3D SCATTER SO DIEU KIEN JACOBIAN ===\n');

Rw=p.ws_D/2; zc=p.ws_zc; zlo=zc-p.ws_H/2; zhi=zc+p.ws_H/2;

% --- Quet toan tru muc tieu (VERBATIM giong p4_singularity.m) ---
condmax=0; mumin=180; Pcondmax=[0 0 0]; Pmumin=[0 0 0]; ndeg=0; ntot=0;
condvals=[];
% Mang luu toan bo diem hop le de ve scatter3
Xp=zeros(1,40000); Yp=zeros(1,40000); Zp=zeros(1,40000); Cp=zeros(1,40000);
npt=0;
for z=zlo:10:zhi
  for rr=0:20:Rw
    na = max(1, round(2*pi*rr/20));
    for a=linspace(0,2*pi,na+1)
      if rr>0 && a>=2*pi, continue; end
      P=[rr*cos(a);rr*sin(a);z]; ntot=ntot+1;
      [th,ok]=delta_ik(P,p); if ~ok, continue; end
      [~,cJ,mu,dA,~]=delta_jacobian(P,th,p);
      if ~isfinite(cJ)||abs(dA)<1e-6, ndeg=ndeg+1; end
      condvals(end+1)=cJ; %#ok<SAGROW>
      npt=npt+1;
      Xp(npt)=P(1); Yp(npt)=P(2); Zp(npt)=P(3); Cp(npt)=cJ;
      if cJ>condmax, condmax=cJ; Pcondmax=P.'; end
      if mu<mumin, mumin=mu; Pmumin=P.'; end
    end
  end
end
Xp=Xp(1:npt); Yp=Yp(1:npt); Zp=Zp(1:npt); Cp=Cp(1:npt);

fprintf('So diem quet: %d ; diem gan ky di song song (detA~0): %d\n', ntot, ndeg);
condmean = mean(condvals(isfinite(condvals)));
fprintf('So dieu kien Jacobian: max=%.3f (tai [%.0f %.0f %.0f]) ; trung binh=%.3f\n', ...
    condmax, Pcondmax, condmean);
fprintf('Goc truyen (forearm-bicep) nho nhat = %.1f deg (tai [%.0f %.0f %.0f])\n', ...
    mumin, Pmumin);
fprintf('Doi chieu thiet ke: cond ~3.69 , goc truyen xau nhat ~34.6 deg\n');

% --- Kiem tra doi chieu voi so lieu da trich dan trong bao cao ---
ref_ntot = 34372; ref_condmax = 2.749; ref_Pcondmax = [-341 209 -1050];
ref_mumin = 49.8; ref_Pmumin = [188 114 -800];
fprintf('\n--- DOI CHIEU VOI SO LIEU DA TRICH DAN ---\n');
fprintf('ntot: quet=%d , trich dan=%d , khop=%d\n', ntot, ref_ntot, ntot==ref_ntot);
fprintf('condmax: quet=%.4f , trich dan=%.3f , lech=%.4f\n', condmax, ref_condmax, abs(condmax-ref_condmax));
fprintf('Pcondmax: quet=[%.0f %.0f %.0f] , trich dan=[%.0f %.0f %.0f]\n', Pcondmax, ref_Pcondmax);
fprintf('mumin: quet=%.3f , trich dan=%.1f , lech=%.3f\n', mumin, ref_mumin, abs(mumin-ref_mumin));
fprintf('Pmumin: quet=[%.0f %.0f %.0f] , trich dan=[%.0f %.0f %.0f]\n', Pmumin, ref_Pmumin);

% --- Danh dau diem dac biet ---
idx_condmax = find(Cp==condmax, 1, 'first');
% Tim diem gan Pmumin nhat trong tap da luu (mumin khong luu truc tiep trong Cp)
dmm = (Xp-Pmumin(1)).^2 + (Yp-Pmumin(2)).^2 + (Zp-Pmumin(3)).^2;
[~, idx_mumin] = min(dmm);

% Subsample de ve cho do net (giu toan bo du lieu cho thong ke, chi subsample luc ve)
step = 2; % ve moi diem thu 2 -> ~17k diem hien thi, tranh vung dac opaque
sel = 1:step:npt;

markersz = 10;

% ================= Hinh 1: Goc nhin isometric (hinh chinh) =================
f1 = figure('Visible','on','Position',[100 100 900 750]);
scatter3(Xp(sel),Yp(sel),Zp(sel),markersz,Cp(sel),'filled','MarkerFaceAlpha',0.5);
hold on;
colormap(jet); cb=colorbar; cb.Label.String='cond(J)';
plot3(Pcondmax(1),Pcondmax(2),Pcondmax(3),'kp','MarkerSize',16,'MarkerFaceColor','k');
text(Pcondmax(1),Pcondmax(2),Pcondmax(3)+40, sprintf('  cond_{max}=%.3f',condmax), ...
    'FontWeight','bold','FontSize',9);
plot3(Pmumin(1),Pmumin(2),Pmumin(3),'ks','MarkerSize',14,'MarkerFaceColor',[1 1 1]);
text(Pmumin(1),Pmumin(2),Pmumin(3)+40, sprintf('  \\mu_{min}=%.1f^{\\circ}',mumin), ...
    'FontWeight','bold','FontSize',9);
xlabel('x [mm]'); ylabel('y [mm]'); zlabel('z [mm]');
title(sprintf('So dieu kien Jacobian kappa(J) tren toan vung lam viec O800x250mm (%d diem)', ntot));
axis equal; grid on; box on; view(35,20);
saveas(f1,'figs/p4b_cond3d_scatter.png');
fprintf('\nDa luu figs/p4b_cond3d_scatter.png\n');

% ================= Hinh 2: Goc nhin top-down =================
f2 = figure('Visible','on','Position',[100 100 900 750]);
scatter3(Xp(sel),Yp(sel),Zp(sel),markersz,Cp(sel),'filled','MarkerFaceAlpha',0.5);
hold on;
colormap(jet); cb=colorbar; cb.Label.String='cond(J)';
plot3(Pcondmax(1),Pcondmax(2),Pcondmax(3),'kp','MarkerSize',16,'MarkerFaceColor','k');
plot3(Pmumin(1),Pmumin(2),Pmumin(3),'ks','MarkerSize',14,'MarkerFaceColor',[1 1 1]);
xlabel('x [mm]'); ylabel('y [mm]'); zlabel('z [mm]');
title(sprintf('So dieu kien Jacobian kappa(J) - nhin tu tren xuong (%d diem)', ntot));
axis equal; grid on; box on; view(0,90);
saveas(f2,'figs/p4b_cond3d_top.png');
fprintf('Da luu figs/p4b_cond3d_top.png\n');

% ================= Hinh 3 (bonus): Goc nhin truoc (front, y-z ẩn x) =================
f3 = figure('Visible','on','Position',[100 100 900 750]);
scatter3(Xp(sel),Yp(sel),Zp(sel),markersz,Cp(sel),'filled','MarkerFaceAlpha',0.5);
hold on;
colormap(jet); cb=colorbar; cb.Label.String='cond(J)';
plot3(Pcondmax(1),Pcondmax(2),Pcondmax(3),'kp','MarkerSize',16,'MarkerFaceColor','k');
plot3(Pmumin(1),Pmumin(2),Pmumin(3),'ks','MarkerSize',14,'MarkerFaceColor',[1 1 1]);
xlabel('x [mm]'); ylabel('y [mm]'); zlabel('z [mm]');
title(sprintf('So dieu kien Jacobian kappa(J) - nhin truc dien (%d diem)', ntot));
axis equal; grid on; box on; view(0,0);
saveas(f3,'figs/p4b_cond3d_front.png');
fprintf('Da luu figs/p4b_cond3d_front.png\n');

fprintf('\n=== TOM TAT ===\n');
fprintf('ntot=%d\n', ntot);
fprintf('condmax=%.4f tai [%.1f %.1f %.1f]\n', condmax, Pcondmax);
fprintf('condmean=%.4f\n', condmean);
fprintf('mumin=%.3f deg tai [%.1f %.1f %.1f]\n', mumin, Pmumin);

diary off;
