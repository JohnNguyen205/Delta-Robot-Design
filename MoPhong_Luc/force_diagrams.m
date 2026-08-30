%% force_diagrams.m -- SO DO PHAN BO LUC & BIEU DO NOI LUC (Delta Robot)
% =========================================================================
%  Xuat 2 hinh phuc vu THUYET MINH TINH TOAN (yeu cau trinh bay cua thay):
%   (1) so_do_phan_bo_luc.png  : FBD ban may + FBD mot canh tay (co ky hieu)
%   (2) bieu_do_noi_luc.png    : bieu do noi luc N,Q,M cua bicep + luc doc rod
%  Du lieu dinh lay tu out/force_results.mat (force_analysis.m da chay).
% =========================================================================
clear; clc; p = params();
S = load('out/force_results.mat');
f_cap = S.fMax;                 % luc doc 1 cap forearm [N] (dinh)
f_rod = f_cap/2;                % moi thanh [N]
L1m   = S.L1m;                  % [m]
m_ee  = S.m_ee; g = 9.81;
W_ee  = m_ee*g;                 % trong luong quy ve TCP [N]
Fin   = max(sqrt(sum(S.FE.^2,2)));  % |F_ee| dinh [N]
mu    = 50;                     % goc truyen dai dien forearm-bicep [do] (~49.8 kiem chung)
Mmax_bend = f_cap*L1m;          % mo men uon lon nhat tai vai (bao thu, luc ngang) [N.m]

%% ====================== HINH 1: SO DO PHAN BO LUC =======================
fig = figure('Visible','off','Position',[80 80 1180 560]);

% ---- (a) FBD ban may (can bang luc tai TCP) ----
subplot(1,2,1); hold on; axis equal off; title('(a) So do phan bo luc tai ban may (TCP)','FontWeight','bold');
th3 = [90 210 330]*pi/180;                 % 3 huong khop (120 do)
Rp = 1;                                     % ban kinh ve ban may
xp = Rp*cos(th3); yp = Rp*sin(th3);
fill([xp xp(1)],[yp yp(1)],[0.85 0.9 1],'EdgeColor',[0.2 0.3 0.6],'LineWidth',1.5); % ban may
plot(0,0,'k+','MarkerSize',10,'LineWidth',1.2);
% 3 luc doc thanh truyen f_i*l_i (huong tu khop vao TCP, ve huong ra ngoai-len)
for j=1:3
  dx=cos(th3(j)); dy=sin(th3(j));
  quiver(xp(j),yp(j), 0.9*dx,0.9*dy, 0,'Color',[0 0.45 0.74],'LineWidth',2.2,'MaxHeadSize',0.5);
  text(xp(j)+1.05*dx, yp(j)+1.05*dy, sprintf('f_%d l_%d',j,j),'Color',[0 0.3 0.6],'FontWeight','bold','FontSize',11,'HorizontalAlignment','center');
end
% trong luong + quan tinh tai TCP
quiver(0,0, 0,-1.15, 0,'Color',[0.6 0 0],'LineWidth',2.4,'MaxHeadSize',0.5);
text(0.06,-1.25,sprintf('W = m_{ee} g = %.0f N',W_ee),'Color',[0.6 0 0],'FontWeight','bold','FontSize',11);
quiver(0,0, 1.15,0.5, 0,'Color',[0.85 0.33 0.10],'LineWidth',2.2,'MaxHeadSize',0.5);
text(1.2,0.6,sprintf('F_{qt} = m_{ee} a'),'Color',[0.7 0.25 0],'FontWeight','bold','FontSize',11);
text(-1.9,-1.75,{'\bfPhuong trinh can bang luc:','\Sigma f_i l_i = m_{ee}(a - g) = F_{ee}',sprintf('|F_{ee}|_{max} = %.1f N   (f_{cap,max}=%.1f N)',Fin,f_cap)}, ...
     'FontSize',10,'BackgroundColor',[1 1 0.9],'EdgeColor',[0.7 0.7 0.4]);
xlim([-2 2.2]); ylim([-2 1.8]);

% ---- (b) FBD mot canh tay (bicep) ----
subplot(1,2,2); hold on; axis equal off; title('(b) So do phan bo luc mot canh tay (bicep)','FontWeight','bold');
O=[0 0]; ang=-25*pi/180; E=O+[cos(ang) sin(ang)]*2.4;   % vai O -> khuyu E
plot([O(1) E(1)],[O(2) E(2)],'-','Color',[0.25 0.25 0.25],'LineWidth',6);        % bicep
plot(O(1),O(2),'o','MarkerFaceColor',[0.9 0.7 0.2],'MarkerEdgeColor','k','MarkerSize',13); % khop vai
plot(E(1),E(2),'o','MarkerFaceColor',[0.7 0.85 1],'MarkerEdgeColor','k','MarkerSize',11);   % khuyu
text(O(1)-0.15,O(2)+0.28,'O (vai, RA hop so)','FontSize',10,'HorizontalAlignment','center');
text(E(1)+0.1,E(2)+0.25,'E (khuyu)','FontSize',10);
% mo men dong co tai O (cung ten tuong trung)
tt=linspace(pi*0.2,pi*1.15,40); plot(0.55*cos(tt),0.55*sin(tt),'-','Color',[0.64 0.08 0.18],'LineWidth',2);
quiver(0.55*cos(tt(end)),0.55*sin(tt(end)), -0.12,0.02,0,'Color',[0.64 0.08 0.18],'LineWidth',2,'MaxHeadSize',2);
text(-0.15,0.75,'\tau (mo men dong co)','Color',[0.64 0.08 0.18],'FontWeight','bold','FontSize',11);
% trong luong bicep tai giua
Mid=(O+E)/2; quiver(Mid(1),Mid(2),0,-0.85,0,'Color',[0.6 0 0],'LineWidth',2,'MaxHeadSize',0.6);
text(Mid(1)-1.05,Mid(2)-0.55,sprintf('W_{arm}=%.0f N',S.m_arm*g),'Color',[0.6 0 0],'FontWeight','bold','FontSize',10);
% luc forearm tai khuyu (doc forearm) + phan tich thanh phan
fdir=[cos(ang-(180-mu)*pi/180) sin(ang-(180-mu)*pi/180)];
quiver(E(1),E(2), 1.1*fdir(1),1.1*fdir(2),0,'Color',[0 0.45 0.74],'LineWidth',2.4,'MaxHeadSize',0.5);
text(E(1)+1.1*fdir(1)-0.55,E(2)+1.1*fdir(2)-0.28,sprintf('F_e = f_{cap} = %.0f N',f_cap),'Color',[0 0.3 0.6],'FontWeight','bold','FontSize',10);
% thanh phan doc/ngang bicep tai khuyu
text(E(1)+0.15,E(2)+0.15,{sprintf('N_e=F_e cos\\mu=%.0f N (doc)',f_cap*cosd(mu)),sprintf('V_e=F_e sin\\mu=%.0f N (ngang)',f_cap*sind(mu)),sprintf('\\mu\\approx%d^o (goc truyen)',mu)}, ...
     'FontSize',9,'BackgroundColor',[0.95 0.97 1],'EdgeColor',[0.6 0.7 0.9]);
xlim([-1.3 3.6]); ylim([-2.1 1.2]);
saveas(fig,'figs/so_do_phan_bo_luc.png');

%% ====================== HINH 2: BIEU DO NOI LUC =========================
% Bicep = dam cong-xon: goc x=0 (vai/ngam) -> dau x=L1 (khuyu, dat luc).
% Tai dau: luc doc N_e va luc ngang V_e (phan tich tu F_e theo goc truyen mu).
% Cong them trong luong ban than phan bo w = m_arm g / L1 (thanh phan ngang uoc luong).
L = p.L1;                       % mm
x = linspace(0,L,200);          % toa do doc bicep [mm], 0 = vai
Ne = f_cap*cosd(mu);            % luc doc dau [N]
Ve = f_cap*sind(mu);            % luc ngang dau [N]
w  = S.m_arm*g/(L/1000);        % [N/m] -> doi sang N/mm:
w_mm = w/1000;                  % N/mm phan bo (uoc luong thanh phan ngang ~ w)
% Noi luc (tu ngam): cong-xon tai dau tu x=L
N = Ne*ones(size(x));                              % luc doc (xap xi hang so)
Q = Ve + w_mm*(L - x);                             % luc cat: dau nho, ngam lon
M = Ve*(L - x) + w_mm*(L - x).^2/2;                % mo men uon: 0 o dau, max o ngam
M_Nm = M/1000;                                     % N.m

fig2 = figure('Visible','off','Position',[80 80 900 820]);
% --- N ---
subplot(3,1,1); hold on; grid on;
fill([x fliplr(x)],[N zeros(size(N))],[0.80 0.88 0.98],'EdgeColor','none');
plot(x,N,'-','Color',[0 0.30 0.60],'LineWidth',2);
ylabel('N(x) [N]'); title(sprintf('Bieu do LUC DOC bicep  (N \\approx %.0f N, nen doc truc)',Ne));
xlim([0 L]); set(gca,'XTickLabel',[]);
text(L*0.02,Ne*0.6,'vai (ngam)','FontSize',9); text(L*0.86,Ne*0.6,'khuyu','FontSize',9);
% --- Q ---
subplot(3,1,2); hold on; grid on;
fill([x fliplr(x)],[Q zeros(size(Q))],[0.98 0.86 0.78],'EdgeColor','none');
plot(x,Q,'-','Color',[0.75 0.30 0.05],'LineWidth',2);
ylabel('Q(x) [N]'); title(sprintf('Bieu do LUC CAT bicep  (Q_{max} \\approx %.0f N tai vai)',max(Q)));
xlim([0 L]); set(gca,'XTickLabel',[]);
% --- M ---
subplot(3,1,3); hold on; grid on;
fill([x fliplr(x)],[M_Nm zeros(size(M_Nm))],[0.80 0.80 0.80],'EdgeColor','none');
plot(x,M_Nm,'-','Color',[0.15 0.15 0.15],'LineWidth',2.2);
plot(0,max(M_Nm),'r.','MarkerSize',22);
text(L*0.03,max(M_Nm)*0.92,sprintf('M_{max} = %.1f N.m',max(M_Nm)),'Color',[0.6 0 0],'FontWeight','bold','FontSize',11);
ylabel('M(x) [N.m]'); xlabel('x doc bicep [mm]  (0 = vai/ngam, L1 = khuyu)');
title('Bieu do MO MEN UON bicep  (dat vao FEA DR-005-2)');
xlim([0 L]);
saveas(fig2,'figs/bieu_do_noi_luc.png');

%% --- Hinh phu: luc doc thanh truyen (2-luc member) ---
fig3=figure('Visible','off','Position',[80 80 720 300]); hold on; grid on;
xr=linspace(0,1000,50); plot(xr,-f_rod*ones(size(xr)),'-','Color',[0.1 0.5 0.2],'LineWidth',2.5);
fill([xr fliplr(xr)],[-f_rod*ones(size(xr)) zeros(size(xr))],[0.85 0.95 0.85],'EdgeColor','none');
xlabel('doc thanh truyen [mm] (khuyu -> ban may)'); ylabel('N_{rod} [N]');
title(sprintf('Luc doc thanh truyen 6516K305 (2-luc member): N = %.0f N (nen), kiem oan Euler', f_rod));
text(400,-f_rod*0.55,sprintf('N = %.1f N/thanh  (khong doi doc chieu dai)',f_rod),'FontWeight','bold');
ylim([-f_rod*1.3 f_rod*0.3]); xlim([0 1000]);
saveas(fig3,'figs/noiluc_thanhtruyen.png');

fprintf('Da xuat: figs/so_do_phan_bo_luc.png, figs/bieu_do_noi_luc.png, figs/noiluc_thanhtruyen.png\n');
fprintf('Mmax_bend = %.1f N.m ; N_rod = %.1f N ; Ne=%.0f Ve=%.0f N\n', max(M_Nm), f_rod, Ne, Ve);
fprintf('DONE\n');
