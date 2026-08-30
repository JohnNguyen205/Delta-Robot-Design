%% force_analysis.m -- PHAN TICH LUC & CHON DONG CO Delta Robot (payload 2 kg)
% =========================================================================
%  MUC DICH
%   (1) Xac dinh TAI TRONG THUC lam dau vao mo phong ben (FEA).
%   (2) Tinh MO MEN CAN CHO DONG CO = mo men TINH + mo men DONG, roi nhan
%       HE SO AN TOAN, so voi rating hop so-dong co TPM-010S (chon dong co).
%
%  KY HIEU (dinh nghia day du) --------------------------------------------
%   P        [mm]      vi tri dau cong tac (TCP) tren quy dao
%   a        [m/s^2]   gia toc TCP ( = d2P/dt2 )
%   g        [m/s^2]   gia toc trong truong = 9.81, vector gv=[0;0;-g]
%   theta_i  [rad]     goc khop (bicep) khop i, i=1..3
%   thdd_i   [rad/s^2] gia toc goc khop i ( = d2theta_i/dt2 )
%   l_i      [-]       vector don vi doc thanh truyen i (khuyu->ban may)
%   f_i      [N]       luc DOC moi CAP thanh truyen i (2 thanh/cap)
%   F_ee     [N]       tong luc quan tinh+trong luong tai TCP
%   m_ee     [kg]      khoi luong quy ve TCP = ban may+payload+1/2 forearm
%   m_arm    [kg]      khoi luong 1 bap tay (bicep) DR-005 (doc tu CAD)
%   J_arm    [kg.m^2]  mo men quan tinh bicep quanh truc vai (mo hinh thanh
%                      mang deu: J_arm = (1/3) m_arm L1^2)  -- gia thiet an toan
%   J_rot    [kg.m^2]  quan tinh rotor+hop so quy ve truc RA (J_motor * i^2)
%   Jv       [mm/rad]  Jacobian van toc:  Pdot = Jv * thetadot
%   tau_t_i  [N.m]     MO MEN TINH tai khop i (chi do trong luong, a=0)
%   tau_d_i  [N.m]     MO MEN DONG tai khop i (do quan tinh)
%   k_s      [-]       he so an toan chon dong co
%   T2B      [N.m]     mo men gia toc cuc dai cho phep cua TPM-010S (rating)
%
%  MO HINH LUC ------------------------------------------------------------
%   - Thanh truyen = THANH 2-LUC (ball joint 2 dau) -> chi chiu luc doc l_i.
%   - Can bang luc ban may:  sum_i ( f_i l_i ) = F_ee = m_ee ( a - gv )
%   - Mo men khop (thanh phan ban may): tau^ee = Jv' F_ee.
%   - Mo men khop day du = tau_TINH + tau_DONG (xem duoi).
%
%  Quy dao pick-and-place quintic, chu ky 1.2 s (giong mo phong dong hoc).
% =========================================================================
clear; clc;
p = params();
if ~exist('out','dir'), mkdir out; end
if ~exist('figs','dir'), mkdir figs; end
diary('out/force_log.txt'); diary on;
fprintf('=== PHAN TICH LUC & CHON DONG CO -- DELTA ROBOT (payload 2 kg) ===\n\n');

%% ---------- 1. Khoi luong & quan tinh (doc tu mo hinh SolidWorks) --------
m_plat = 4.214;    % ban may DR-007 [kg]
m_pay  = 2.0;      % payload muc tieu (<= 2 kg)
m_rod  = 0.348;    % 1 thanh truyen 6516K305 (carbon) [kg]
m_ball = 0.325;    % 1 khop cau 60645K471 (thep) [kg]
m_arm  = 6.912;    % 1 bap tay DR-005 (hub+link, nhom) [kg] -- doc CAD 2026-07-14
% khoi luong quy ve TCP = ban may + payload + 1/2 he thanh truyen (phia ban may)
m_ee = m_plat + m_pay + 0.5*(6*m_rod + 6*m_ball);
g = 9.81; gv = [0;0;-g];
L1m = p.L1/1000;                       % canh tay tren [m]
J_arm = (1/3)*m_arm*L1m^2;             % quan tinh bicep quanh truc vai (thanh deu)
r_cg  = L1m/2;                         % ban kinh khoi tam bicep tu truc vai [m]

%% ---------- 2. Du lieu dong co-hop so TPM-010S-061T (catalog) ------------
i_gb   = 61;          % ti so truyen
J_mot  = 0.19e-4;     % quan tinh khoi (catalog "Mass moment of inertia") [kg.m^2] (phia truc dong co)
J_rot  = J_mot*i_gb^2;% quy ve truc ra (RA) [kg.m^2]
T2B    = 80;          % Max. acceleration torque (mo men dinh cho phep) [N.m]
T_stall= 29;          % Stall torque (~mo men lien tuc cho phep) [N.m]
T_brake= 67;          % Brake holding torque [N.m]
n2max  = 98;          % Max. output speed [rpm]
k_s    = 1.5;         % HE SO AN TOAN chon dong co

fprintf('m_ee  = ban may(%.3f)+payload(%.1f)+1/2 forearm(%.3f) = %.3f kg\n', ...
        m_plat, m_pay, 0.5*(6*m_rod+6*m_ball), m_ee);
fprintf('m_arm = %.3f kg  -> J_arm = (1/3)m L1^2 = %.4f kg.m^2 (thanh deu, bao thu)\n', m_arm, J_arm);
fprintf('J_rot = J_mot*i^2 = %.2e*%d^2 = %.4f kg.m^2 (rotor+hop so quy ve truc RA)\n\n', J_mot, i_gb, J_rot);

%% ---------- 3. Quy dao pick-and-place (quintic, chu ky 1.2 s) ------------
W = [ 300 0 -1000; 300 0 -820; -300 0 -820; -300 0 -1000];  % waypoints (mm)
Tseg = [0.30 0.60 0.30]; dt = 0.001;
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

%% ---------- 4. Vong tinh luc + mo men (tach TINH / DONG) -----------------
F=zeros(n,3);                          % luc doc moi cap forearm [N]
FE=zeros(n,3);                         % luc TCP [N]
TH=zeros(n,3);                         % goc khop [rad]
Tse=zeros(n,3); Tde=zeros(n,3);        % mo men khop tu TCP: tinh / dong
reach=true(n,1);
for i=1:n
  [th,ok]=delta_ik(P(i,:).',p); if ~ok, reach(i)=false; end
  TH(i,:)=th.';
  L=zeros(3,3);
  for j=1:3
    c=cos(p.phi(j)); s=sin(p.phi(j)); ct=cos(th(j)); st=sin(th(j));
    Ej=[p.R*c+p.L1*ct*c; p.R*s+p.L1*ct*s; -p.L1*st];
    Pj=[P(i,1)+p.r*c; P(i,2)+p.r*s; P(i,3)];
    L(:,j)=(Pj-Ej)/norm(Pj-Ej);
  end
  a=Acc_m(i,:).';
  Fstat = m_ee*[0;0;g];                % luc GIU trong luong TCP (a=0)
  Fdyn  = m_ee*a;                       % luc QUAN TINH TCP
  FE(i,:)=(Fstat+Fdyn).';               % = m_ee(a-gv)
  if rcond(L)>1e-6, F(i,:)=(L\(Fstat+Fdyn)).'; else, F(i,:)=NaN; end
  [Jv,~]=delta_jacobian(P(i,:).',th,p);
  if all(isfinite(Jv(:)))
    Tse(i,:)=(Jv.'*Fstat).'/1000;       % mo men TINH tu TCP (N.m)
    Tde(i,:)=(Jv.'*Fdyn ).'/1000;       % mo men DONG tu TCP (N.m)
  end
end
% gia toc goc khop tu theta(t)
THd = gradient(TH.',dt).'; THdd = gradient(THd.',dt).';   % rad/s, rad/s^2

% --- Thanh phan bap tay (bicep) ---
Tsa = m_arm*g*r_cg*cos(TH);             % mo men TINH giu trong luong bicep [N.m]
Tda_arm = J_arm*THdd;                    % mo men DONG quan tinh RIENG bicep [N.m] (khong phu thuoc hop so)
Tda = (J_arm+J_rot)*THdd;               % mo men DONG quan tinh bicep+rotor (hop so hien tai) [N.m]

% --- Mo men TINH / DONG day du moi khop (cong bao thu tri tuyet doi) ------
Tstat = abs(Tse) + abs(Tsa);            % |tinh_TCP| + |tinh_bicep|  (moi khop)
Tdyn  = abs(Tde) + abs(Tda);            % |dong_TCP| + |dong_bicep+rotor|
Tenv  = Tstat + Tdyn;                    % duong bao tuc thoi (bao thu) moi khop [N.m]
Fee_mag=sqrt(sum(FE.^2,2));

%% ---------- 5. Ket qua dinh & KIEM CHON DONG CO --------------------------
fMax  = max(abs(F(:)));
FeeMax= max(Fee_mag);
Mtinh = max(Tstat(:));                  % mo men TINH dinh [N.m]
Mdong = max(Tdyn(:));                   % mo men DONG dinh [N.m]
Mtong = Mtinh + Mdong;                  % mo men tong (cong bao thu)
Myc   = k_s*Mtong;                      % MO MEN YEU CAU = k_s*(tinh+dong)
Mrms  = max(sqrt(mean(Tenv.^2,1)));     % rms mo men (duong bao) cua khop nang nhat
wmax_rpm = max(abs(THd(:)))*60/(2*pi);  % toc do goc khop dinh [rpm]
amax_deg = max(abs(THdd(:)))*180/pi;    % gia toc goc khop dinh [deg/s^2]

fprintf('--- TAI TRONG DINH (payload 2 kg) ---\n');
fprintf(' |F_ee|max              = %6.1f N\n', FeeMax);
fprintf(' |f_i|max (1 cap fore.) = %6.1f N  -> moi thanh %.1f N, moi ball-joint %.1f N\n', fMax, fMax/2, fMax/2);
fprintf(' Momen uon bicep (f*L1) = %6.1f N.m (tai vai, xem bieu do noi luc)\n\n', fMax*L1m);

fprintf('--- MO MEN KHOP: TACH TINH / DONG (dinh tren ca chu ky, 3 khop) ---\n');
fprintf(' M_tinh (giu trong luong)         = %6.2f N.m\n', Mtinh);
fprintf('        gom: TCP %.2f + bicep %.2f\n', max(abs(Tse(:))), max(abs(Tsa(:))));
fprintf(' M_dong (quan tinh)               = %6.2f N.m\n', Mdong);
fprintf('        gom: TCP %.2f + (bicep+rotor) %.2f\n', max(abs(Tde(:))), max(abs(Tda(:))));
fprintf(' M_tong = M_tinh + M_dong         = %6.2f N.m\n', Mtong);
fprintf(' He so an toan k_s                = %.2f\n', k_s);
fprintf(' M_yeucau = k_s*(M_tinh+M_dong)   = %6.2f N.m\n\n', Myc);

fprintf('--- KIEM CHON TPM-010S-061T (i=%d) ---\n', i_gb);
fprintf(' [dinh]      M_yeucau %.1f  <= T2B %.0f N.m  ? -> %s (du %.2fx)\n', ...
        Myc, T2B, tf(Myc<=T2B), T2B/Myc);
fprintf(' [lien tuc]  M_rms    %.1f  <= T_stall %.0f N.m ? -> %s (du %.2fx)\n', ...
        Mrms, T_stall, tf(Mrms<=T_stall), T_stall/Mrms);
fprintf(' [toc do]    w_khop   %.1f  <= n2max %.0f rpm  ? -> %s\n', ...
        wmax_rpm, n2max, tf(wmax_rpm<=n2max));
fprintf(' gia toc goc khop dinh = %.0f deg/s^2\n', amax_deg);
if Myc<=T2B && Mrms<=T_stall && wmax_rpm<=n2max
  fprintf(' => KET LUAN: TPM-010S-061T DU KHA NANG (dat ca 3 dieu kien).\n\n');
else
  fprintf(' => KET LUAN: TPM-010S-061T **KHONG DU** -> so sanh phuong an tang ti so truyen/mo men cao.\n\n');
end

%% ---------- 5b. SO SANH PHUONG AN HOP SO CUNG CO 010 --------------------
% Tang ti so truyen i lam TANG T2B nhung cung TANG quan tinh rotor quy doi
% (J_rot = J_mot*i^2) -> M_dong tang theo. Kiem lai tung phuong an.
% Du lieu THAT: i=61 (DYNAMIC) & i=55 (HIGH TORQUE) tu catalog.
% i=91,100 (DYNAMIC): T2B/stall UOC LUONG tuyen tinh theo i (can xac nhan datasheet cymex).
cname = {'TPM 010S-061T DYNAMIC (hien tai)','TPM 010S i=91 DYNAMIC (uoc luong)', ...
         'TPM 010S i=100 DYNAMIC (uoc luong)','TPMA 010S-055T HIGH TORQUE'};
ci    = [61      91      100     55     ];
cT2B  = [80      119     131     230    ];   % [N.m]  (i=61,55 that ; 91,100 uoc luong)
cstall= [29      43      48      110    ];   % [N.m]
cn2   = [98      66      60      88     ];   % [rpm]
cJmot = [0.19e-4 0.19e-4 0.19e-4 2.18e-4];   % [kg.m^2] phia truc dong co
creal = [1 0 0 1];
nc=numel(ci); cMyc=zeros(1,nc); cMrms=zeros(1,nc); cMdong=zeros(1,nc); cpass=false(1,nc);
fprintf('--- SO SANH PHUONG AN HOP SO (cung co 010) ---\n');
fprintf(' %-34s %4s %6s %6s %6s %6s %6s  %s\n','Phuong an','i','Mdong','Myc','T2B','Mrms','stall','KL');
for c=1:nc
  Jr = cJmot(c)*ci(c)^2;                       % quan tinh rotor quy ve truc RA
  Tdc = abs(Tde) + abs(Tda_arm + Jr*THdd);     % M_dong voi rotor cua phuong an c
  cMdong(c)=max(Tdc(:)); Mtg=Mtinh+cMdong(c); cMyc(c)=k_s*Mtg;
  cMrms(c)=max(sqrt(mean((Tstat+Tdc).^2,1)));
  cpass(c)= cMyc(c)<=cT2B(c) && cMrms(c)<=cstall(c) && wmax_rpm<=cn2(c);
  kl='DAT'; if ~cpass(c), kl='KHONG DAT'; end; if ~creal(c), kl=[kl ' (uoc luong)']; end
  fprintf(' %-34s %4d %6.1f %6.1f %6.0f %6.1f %6.0f  %s\n', ...
          cname{c}, ci(c), cMdong(c), cMyc(c), cT2B(c), cMrms(c), cstall(c), kl);
end
% chon phuong an DAT co du (T2B - Myc) it nhat nhung >0, uu tien du lieu that
score = cT2B - cMyc; score(~cpass)= -inf;
[~,cbest]=max(creal*1e6 + score.*cpass);   % uu tien creal, trong so pass
fprintf(' => DE XUAT: %s  (Myc %.1f <= T2B %.0f, du %.2fx; Mrms %.1f <= stall %.0f).\n\n', ...
        cname{cbest}, cMyc(cbest), cT2B(cbest), cT2B(cbest)/cMyc(cbest), cMrms(cbest), cstall(cbest));

% Hinh so sanh phuong an
f5=figure('Visible','off','Position',[100 100 980 520]);
xb=1:nc; bw=0.38;
b1=bar(xb-bw/2, cMyc,bw,'FaceColor',[0.64 0.08 0.18]); hold on;
b2=bar(xb+bw/2, cT2B,bw,'FaceColor',[0 0.45 0.74]);
for c=1:nc
  text(xb(c)-bw/2,cMyc(c)+3,sprintf('%.0f',cMyc(c)),'HorizontalAlignment','center','FontWeight','bold','FontSize',9);
  text(xb(c)+bw/2,cT2B(c)+3,sprintf('%.0f',cT2B(c)),'HorizontalAlignment','center','FontWeight','bold','FontSize',9,'Color',[0 0.3 0.6]);
  if cpass(c), mk='DAT'; cl=[0 0.5 0]; else, mk='KHONG'; cl=[0.7 0 0]; end
  text(xb(c),max(cMyc(c),cT2B(c))+16,mk,'HorizontalAlignment','center','FontWeight','bold','Color',cl,'FontSize',10);
end
set(gca,'XTick',xb,'XTickLabel',{'i=61 DYN','i=91 DYN*','i=100 DYN*','i=55 HITORQUE'});
ylabel('Mo men [N.m]'); grid on; ylim([0 260]);
legend([b1 b2],{'M_{yc}=k_s(M_{tinh}+M_{dong}) can co','T2B hop so (kha nang)'},'Location','northwest');
title('So sanh phuong an hop so cung co 010 (*=uoc luong, can datasheet)');
saveas(f5,'figs/gearbox_compare.png');

fprintf('--- BANG TAI FEA (cho tung chi tiet) ---\n');
fprintf('   DR-006 Elbow-Clevis : %.0f N (1 cap forearm o 2 lo rod)\n', ceil(fMax));
fprintf('   6516K305 Rod        : %.0f N doc truc (nen/keo, kiem oan Euler)\n', ceil(fMax/2));
fprintf('   DR-007 Platform     : %.0f N moi diem bat (6 diem)\n', ceil(fMax/2));
fprintf('   DR-005-2 Arm-Link   : momen uon ~%.0f N.m tai vai\n', ceil(fMax*L1m));

%% ---------- 6. HINH: luc & mo men theo thoi gian ------------------------
% (a) Luc doc 3 cap forearm
f1=figure('Visible','off','Position',[100 100 860 470]);
plot(t,F(:,1),'-','LineWidth',1.5); hold on; plot(t,F(:,2),'-','LineWidth',1.5); plot(t,F(:,3),'-','LineWidth',1.5);
grid on; xlabel('t [s]'); ylabel('Luc doc thanh truyen  f_i  [N]');
title('Luc doc moi cap thanh truyen theo thoi gian (payload 2 kg)');
legend('f_1 (cap 1)','f_2 (cap 2)','f_3 (cap 3)','Location','best'); saveas(f1,'figs/forearm_forces.png');

% (b) Do lon luc TCP
f3=figure('Visible','off','Position',[100 100 860 470]);
plot(t,Fee_mag,'b-','LineWidth',1.7); grid on; xlabel('t [s]'); ylabel('|F_{ee}| [N]');
title('Do lon luc dau cong tac |F_{ee}| theo thoi gian'); saveas(f3,'figs/force_ee.png');

% (c) MO MEN KHOP: tach TINH / DONG / TONG cho khop nang nhat
[~,jg] = max(max(Tstat+Tdyn,[],1));     % khop co mo men lon nhat
f2=figure('Visible','off','Position',[100 100 900 500]);
plot(t, Tstat(:,jg),'-','Color',[0 0.45 0.74],'LineWidth',1.6); hold on;
plot(t, Tdyn(:,jg), '-','Color',[0.85 0.33 0.10],'LineWidth',1.6);
plot(t, Tstat(:,jg)+Tdyn(:,jg),'-','Color',[0.2 0.2 0.2],'LineWidth',1.9);
yline(T2B,'--r','T2B = 80 N.m (dinh cho phep)','LineWidth',1.3,'LabelHorizontalAlignment','left');
yline(T_stall,'--',[num2str(T_stall) ' N.m (lien tuc)'],'Color',[0.5 0.5 0.5],'LineWidth',1.1,'LabelHorizontalAlignment','left');
grid on; xlabel('t [s]'); ylabel(['Mo men khop  \tau_' num2str(jg) '  [N.m]']);
title(sprintf('Mo men khop %d: TINH + DONG (khop nang nhat, payload 2 kg)', jg));
legend('M_{tinh} (trong luong)','M_{dong} (quan tinh)','M_{tinh}+M_{dong}', ...
       'Location','northoutside','Orientation','horizontal'); saveas(f2,'figs/joint_torques.png');

% (d) Bieu do cot so sanh chon dong co
f4=figure('Visible','off','Position',[100 100 720 470]);
vals=[Mtinh Mdong Mtong Myc]; b=bar(vals,0.6,'FaceColor','flat');
b.CData=[0 0.45 0.74; 0.85 0.33 0.10; 0.3 0.3 0.3; 0.64 0.08 0.18];
set(gca,'XTickLabel',{'M_{tinh}','M_{dong}','M_{tong}','M_{yc}=k_s M_{tong}'});
hold on; yline(T2B,'--r',sprintf('T2B = %d N.m',T2B),'LineWidth',1.5);
yline(T_stall,'--',sprintf('Stall = %d N.m',T_stall),'Color',[0.5 0.5 0.5],'LineWidth',1.2);
for i=1:4, text(i,vals(i)+1.5,sprintf('%.1f',vals(i)),'HorizontalAlignment','center','FontWeight','bold'); end
ylabel('Mo men [N.m]'); ylim([0 max(T2B,Myc)*1.15]); grid on;
title('Kiem chon dong co: M_{tinh}+M_{dong}, x he so an toan vs TPM-010S');
saveas(f4,'figs/torque_sizing.png');

%% ---------- 7. Luu ket qua ----------------------------------------------
save('out/force_results.mat','t','P','F','FE','TH','THdd','Tse','Tde','Tsa','Tda', ...
     'Tstat','Tdyn','Tenv','m_ee','m_arm','J_arm','J_rot','fMax','FeeMax', ...
     'Mtinh','Mdong','Mtong','Myc','Mrms','wmax_rpm','amax_deg', ...
     'T2B','T_stall','n2max','k_s','L1m','jg');
fprintf('\nDa luu: out/force_log.txt, out/force_results.mat,\n');
fprintf('        figs/{forearm_forces, force_ee, joint_torques, torque_sizing}.png\n');
diary off; fprintf('DONE\n');

function s=tf(b), if b, s='DAT'; else, s='**KHONG DAT**'; end, end
