function force_poses()
%% force_poses.m -- Tai trong FEA tai NHIEU TU THE KHO tren toan vung lam viec.
% Voi moi tu the: quet huong gia toc dinh (26 huong) -> lay WORST-CASE
%   - fmax  : luc doc lon nhat 1 cap thanh truyen (tai DR-006 clevis)
%   - Fee   : do lon luc dau cong tac (tai DR-007 platform)
%   - tau   : mo men khop (thanh phan ban may)
%   - Mbend : mo men uon bicep = fmax*L1 (tai DR-005-2)
% Xuat bang + .mat + hinh. Dung lam tai FEA "tu the kho".
p = params();
if ~exist('out','dir'), mkdir out; end
if ~exist('figs','dir'), mkdir figs; end
diary('out/pose_log.txt'); diary on;
fprintf('=== TAI TRONG FEA DA TU THE (payload 2 kg) ===\n\n');

% ---- khoi luong quy ve TCP (giong force_analysis) ----
m_plat=4.214; m_pay=2.0; m_rod=0.348; m_ball=0.325; m_arm=6.912;
m_ee = m_plat + m_pay + 0.5*(6*m_rod+6*m_ball);
g=9.81; gv=[0;0;-g]; L1m=p.L1/1000;
a_pk = 11.58;   % gia toc TCP dinh [m/s^2] ~1.18g (tu mo phong dong hoc)
fprintf('m_ee=%.3f kg, a_pk=%.2f m/s^2, L1=%.1f mm\n\n', m_ee, a_pk, p.L1);

% ---- tap tu the kho: bien tru vung lam viec Ø800x250 @zc=-925 + tam + P&P ----
zc=p.ws_zc; H=p.ws_H; Rw=p.ws_D/2;      % -925, 250, 400
ztop=zc+H/2; zbot=zc-H/2;               % -800, -1050
naz=12; azs=(0:naz-1)*(2*pi/naz);
P=[0 0 zc]; nm={'Tam vung LV (R0,z-925)'};
for iz=[ztop zbot]
  for k=1:naz
    P(end+1,:)=[Rw*cos(azs(k)) Rw*sin(azs(k)) iz]; %#ok<AGROW>
    nm{end+1}=sprintf('Bien R400 az%03.0f z%d',rad2deg(azs(k)),round(iz)); %#ok<AGROW>
  end
end
W=[300 0 -1000;300 0 -820;-300 0 -820;-300 0 -1000];
for k=1:4, P(end+1,:)=W(k,:); nm{end+1}=sprintf('Waypoint P&P %d',k); end %#ok<AGROW>

% ---- 26 huong gia toc ----
[ax,ay,az]=ndgrid([-1 0 1],[-1 0 1],[-1 0 1]);
D=[ax(:) ay(:) az(:)]; D(all(D==0,2),:)=[]; D=D./vecnorm(D,2,2);

np=size(P,1);
fmax=zeros(np,1); Fee=zeros(np,1); tau=zeros(np,1); Mbend=zeros(np,1);
condv=nan(np,1); reach=false(np,1);
for i=1:np
  [th,ok]=delta_ik(P(i,:).',p); reach(i)=ok;
  if ~ok, continue; end
  L=zeros(3,3);
  for j=1:3
    c=cos(p.phi(j)); s=sin(p.phi(j)); ct=cos(th(j)); st=sin(th(j));
    Ej=[p.R*c+p.L1*ct*c; p.R*s+p.L1*ct*s; -p.L1*st];
    Pj=[P(i,1)+p.r*c; P(i,2)+p.r*s; P(i,3)];
    L(:,j)=(Pj-Ej)/norm(Pj-Ej);
  end
  [Jv,~]=delta_jacobian(P(i,:).',th,p);
  if all(isfinite(Jv(:))), condv(i)=cond(Jv); end
  wf=0; wF=0; wt=0;
  for d=1:size(D,1)
    a=a_pk*D(d,:).';
    Fv=m_ee*(a-gv);               % luc TCP = m_ee(a-g)
    if norm(Fv)>wF, wF=norm(Fv); end
    if rcond(L)>1e-6
      f=L\Fv; if max(abs(f))>wf, wf=max(abs(f)); end
    end
    if all(isfinite(Jv(:)))
      tv=Jv.'*Fv/1000; if max(abs(tv))>wt, wt=max(abs(tv)); end
    end
  end
  fmax(i)=wf; Fee(i)=wF; tau(i)=wt; Mbend(i)=wf*L1m;
end

% ---- bang ket qua ----
fprintf('%-28s %6s %6s %7s %6s %7s %5s\n','Tu the','x','y','z','fmax','Fee','cond');
for i=1:np
  if reach(i)
    fprintf('%-28s %6.0f %6.0f %7.0f %6.1f %6.1f %5.2f\n', nm{i}, P(i,1),P(i,2),P(i,3), fmax(i), Fee(i), condv(i));
  else
    fprintf('%-28s %6.0f %6.0f %7.0f   KHONG VOI TOI\n', nm{i}, P(i,1),P(i,2),P(i,3));
  end
end
[fw,iw]=max(fmax); [Fw,iF]=max(Fee); [tw,it]=max(tau);
fprintf('\n--- WORST-CASE toan vung lam viec ---\n');
fprintf(' fmax (cap forearm)  = %.1f N  tai [%s]\n', fw, nm{iw});
fprintf(' Fee  (luc TCP)      = %.1f N  tai [%s]\n', Fw, nm{iF});
fprintf(' tau  (mo men khop)  = %.1f N.m tai [%s]\n', tw, nm{it});
fprintf(' Mbend bicep (fmax*L1)= %.1f N.m\n', fw*L1m);
fprintf('\n So voi tai BASELINE (quy dao P&P): fmax=122.7 N, Fee=175.8 N.\n');
fprintf(' Ti so tang: fmax x%.2f, Fee x%.2f\n', fw/122.7, Fw/175.8);

% ---- hinh: scatter vung lam viec mau theo fmax ----
f=figure('Visible','off','Position',[100 100 900 640]);
sc=P(reach,:); cc=fmax(reach);
scatter3(sc(:,1),sc(:,2),sc(:,3),80,cc,'filled'); hold on;
scatter3(P(iw,1),P(iw,2),P(iw,3),200,'r','p','filled');
cb=colorbar; ylabel(cb,'fmax cap forearm [N]'); colormap(jet);
xlabel('x [mm]'); ylabel('y [mm]'); zlabel('z [mm]'); grid on; view(35,20);
title('Luc cap thanh truyen lon nhat tren cac tu the kho (sao do = worst)');
saveas(f,'figs/pose_fmax_workspace.png');

save('out/pose_results.mat','P','nm','fmax','Fee','tau','Mbend','condv','reach', ...
     'fw','iw','Fw','iF','tw','it','m_ee','a_pk','L1m');
fprintf('\nDa luu: out/pose_log.txt, out/pose_results.mat, figs/pose_fmax_workspace.png\n');
diary off; fprintf('DONE\n');
end
