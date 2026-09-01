% p4_singularity.m -- Phase 4: Jacobian, so dieu kien, goc truyen tren vung lam viec
clear; clc;
p = params();
if ~exist('figs','dir'), mkdir figs; end
if ~exist('out','dir'),  mkdir out;  end
diary('out/p4_log.txt'); diary on;
fprintf('=== PHASE 4: JACOBIAN / KY DI / GOC TRUYEN ===\n');

Rw=p.ws_D/2; zc=p.ws_zc; zlo=zc-p.ws_H/2; zhi=zc+p.ws_H/2;

% --- Quet toan tru muc tieu ---
condmax=0; mumin=180; Pcondmax=[0 0 0]; Pmumin=[0 0 0]; ndeg=0; ntot=0;
condvals=[];
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
      if cJ>condmax, condmax=cJ; Pcondmax=P.'; end
      if mu<mumin, mumin=mu; Pmumin=P.'; end
    end
  end
end
fprintf('So diem quet: %d ; diem gan ky di song song (detA~0): %d\n', ntot, ndeg);
fprintf('So dieu kien Jacobian: max=%.3f (tai [%.0f %.0f %.0f]) ; trung binh=%.3f\n', ...
    condmax, Pcondmax, mean(condvals(isfinite(condvals))));
fprintf('Goc truyen (forearm-bicep) nho nhat = %.1f deg (tai [%.0f %.0f %.0f])\n', ...
    mumin, Pmumin);
fprintf('Doi chieu thiet ke: cond ~3.69 , goc truyen xau nhat ~34.6 deg\n');

% --- Ban do so dieu kien tren mat cat z=zc ---
gx=-Rw:20:Rw; gz=zlo:10:zhi;
[XX,ZZ]=meshgrid(gx,gz); CC=nan(size(XX));
for ii=1:numel(XX)
  P=[XX(ii);0;ZZ(ii)];
  [th,ok]=delta_ik(P,p); if ~ok, continue; end
  if any(th<p.th_min)||any(th>p.th_max), continue; end
  [~,cJ]=delta_jacobian(P,th,p); CC(ii)=cJ;
end
f=figure('Visible','on','Position',[100 100 760 560]);
pcolor(XX,ZZ,CC); shading interp; colorbar; hold on;
rectangle('Position',[-Rw zlo 2*Rw p.ws_H],'EdgeColor','r','LineWidth',1.5);
xlabel('x [mm]'); ylabel('z [mm]');
title('So dieu kien Jacobian tren mat cat y=0 (trong tru muc tieu)');
saveas(f,'figs/p4_cond_map.png');
fprintf('Da luu figs/p4_cond_map.png\n');
diary off;
