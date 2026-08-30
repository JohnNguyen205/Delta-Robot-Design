function delta_gui_simple()
% DELTA_GUI_SIMPLE  Giao dien mo phong dong hoc Delta Robot - DON GIAN, MUOT, co KHOA VUNG AN TOAN.
%   Hai che do:
%     - DONG HOC THUAN (FK): keo 3 thanh truot goc khop theta1..3 -> tinh vi tri ban may P.
%     - DONG HOC NGHICH (IK): keo 3 thanh truot vi tri X,Y,Z -> tinh 3 goc khop theta.
%   KHOA VUNG AN TOAN (chong ky di): danh gia moi tu the theo (a) gioi han goc khop,
%     (b) goc truyen muy = goc forearm-bicep, (c) so dieu kien Jacobian, (d) nam trong tru
%     lam viec Ø800x250. Khi bat khoa, neu tu the roi vao KY DI / NGOAI VUNG thi tu dong
%     LUI VE tu the an toan gan nhat (robot khong bao gio ket o cau hinh ky di).
%     Mau: XANH = an toan, CAM = gan ky di (canh bao), DO = ky di / ngoai vung.
%   Chay: >> delta_gui_simple ;  dung chung params.m, delta_fk.m, delta_ik.m, delta_jacobian.m.

p    = params();
mode = 'FK';
th   = deg2rad([19.15 19.15 19.15]).';
[P, okState] = delta_fk(th, p);
guardOn = true; busy = false; stopReq = false; tick = 0;
lastSafe = struct('th', th, 'P', P);
curLvl = 0; curCond = NaN; curMu = NaN;

% Nguong danh gia ky di
MU_WARN=40; MU_UNSAFE=25;          % goc truyen [do]  (mu_min thiet ke = 30)
COND_WARN=4; COND_UNSAFE=8;        % so dieu kien Jacobian
% Mau
C_SAFE=[0.10 0.35 0.75]; C_WARN=[0.95 0.55 0.10]; C_BAD=[0.85 0.10 0.10];
TCP_SAFE=[0.10 0.65 0.20]; TCP_WARN=[0.95 0.55 0.10]; TCP_BAD=[0.85 0.10 0.10];

LIM_TH = [rad2deg(p.th_min) rad2deg(p.th_max)];
LIM_XY = [-500 500]; LIM_Z = [-1250 -550];

% ================= GIAO DIEN =================
f = figure('Name','Delta Robot - Mo phong dong hoc (don gian)','NumberTitle','off',...
    'Color',[0.96 0.97 0.99],'Position',[70 60 1140 730]);
ax = axes('Parent',f,'Units','normalized','Position',[0.34 0.06 0.63 0.9]);
H = createScene(ax, p);

uicontrol(f,'Style','text','Units','normalized','Position',[0.02 0.935 0.28 0.04],...
    'String','CHE DO DIEU KHIEN','FontWeight','bold','FontSize',11,...
    'BackgroundColor',[0.96 0.97 0.99],'HorizontalAlignment','left');
btnFK = uicontrol(f,'Style','togglebutton','Units','normalized','Position',[0.02 0.878 0.14 0.05],...
    'String','KHOP (thuan)','FontSize',10,'FontWeight','bold','Value',1,'Callback',@(~,~)setMode('FK'));
btnIK = uicontrol(f,'Style','togglebutton','Units','normalized','Position',[0.16 0.878 0.14 0.05],...
    'String','VI TRI (nghich)','FontSize',10,'FontWeight','bold','Value',0,'Callback',@(~,~)setMode('IK'));

lbl = gobjects(1,3); sld = gobjects(1,3); edt = gobjects(1,3);
y0 = 0.80; dy = 0.108;
for i = 1:3
    yy = y0 - (i-1)*dy;
    lbl(i) = uicontrol(f,'Style','text','Units','normalized','Position',[0.02 yy+0.045 0.28 0.035],...
        'String','','FontSize',11,'FontWeight','bold','BackgroundColor',[0.96 0.97 0.99],'HorizontalAlignment','left');
    sld(i) = uicontrol(f,'Style','slider','Units','normalized','Position',[0.02 yy+0.012 0.22 0.03],'Callback',@(~,~)onSlider(i,true));
    edt(i) = uicontrol(f,'Style','edit','Units','normalized','Position',[0.245 yy+0.012 0.055 0.03],'FontSize',10,'Callback',@(~,~)onEdit(i));
    addlistener(sld(i),'ContinuousValueChange',@(~,~)onSlider(i,false));
end

chkGuard = uicontrol(f,'Style','checkbox','Units','normalized','Position',[0.02 0.50 0.30 0.035],...
    'String','Khoa vung an toan (chong ky di)','FontSize',10,'FontWeight','bold','Value',1,...
    'BackgroundColor',[0.96 0.97 0.99],'Callback',@(~,~)toggleGuard());
btnPP = uicontrol(f,'Style','pushbutton','Units','normalized','Position',[0.02 0.435 0.14 0.05],...
    'String','Chay quy dao P&P','FontSize',10,'FontWeight','bold','Callback',@(~,~)runTraj());
uicontrol(f,'Style','pushbutton','Units','normalized','Position',[0.16 0.435 0.14 0.05],...
    'String','DUNG','FontSize',10,'FontWeight','bold','ForegroundColor',[0.7 0 0],'Callback',@(~,~)stopTraj());
uicontrol(f,'Style','pushbutton','Units','normalized','Position',[0.02 0.37 0.14 0.05],...
    'String','Ve HOME','FontSize',10,'Callback',@(~,~)goHome());
uicontrol(f,'Style','pushbutton','Units','normalized','Position',[0.16 0.37 0.14 0.05],...
    'String','Goc nhin Iso','FontSize',10,'Callback',@(~,~)view(ax,135,20));
txt = uicontrol(f,'Style','text','Units','normalized','Position',[0.02 0.02 0.28 0.32],...
    'String','','FontSize',9.5,'BackgroundColor',[1 1 1],'HorizontalAlignment','left');

setMode('FK');

% ============ HAM CON ============
    function setMode(m)
        if busy, return; end
        mode = m; set(btnFK,'Value',strcmp(m,'FK')); set(btnIK,'Value',strcmp(m,'IK'));
        if strcmp(mode,'FK')
            names = {'theta_1 (do)','theta_2 (do)','theta_3 (do)'};
            for k = 1:3, set(sld(k),'Min',LIM_TH(1),'Max',LIM_TH(2),'Value',clamp(rad2deg(th(k)),LIM_TH)); set(lbl(k),'String',names{k}); end
        else
            names = {'X (mm)','Y (mm)','Z (mm)'}; lims = {LIM_XY, LIM_XY, LIM_Z};
            for k = 1:3, set(sld(k),'Min',lims{k}(1),'Max',lims{k}(2),'Value',clamp(P(k),lims{k})); set(lbl(k),'String',names{k}); end
        end
        syncEdits(); recompute(); applyGuard(); redraw(); updateStatus();
    end

    function onSlider(i, force)
        if busy, return; end
        v = get(sld(i),'Value'); applyInput(i, v);
        set(edt(i),'String',sprintf('%.1f', v));
        recompute(); applyGuard(); redraw();
        tick = tick + 1; if force || mod(tick,4)==0, updateStatus(); end
    end
    function onEdit(i)
        if busy, return; end
        v = str2double(get(edt(i),'String'));
        if isnan(v), syncEdits(); return; end
        if strcmp(mode,'FK'), lim = LIM_TH; elseif i<3, lim = LIM_XY; else, lim = LIM_Z; end
        v = clamp(v, lim); set(sld(i),'Value',v); applyInput(i, v);
        recompute(); applyGuard(); redraw(); updateStatus();
    end
    function applyInput(i, v)
        if strcmp(mode,'FK'), th(i) = deg2rad(v); else, P(i) = v; end
    end
    function syncEdits()
        for k = 1:3
            if strcmp(mode,'FK'), val = rad2deg(th(k)); else, val = P(k); end
            set(edt(k),'String',sprintf('%.1f',val));
        end
    end
    function restoreControls()
        if strcmp(mode,'FK')
            for k=1:3, set(sld(k),'Value',clamp(rad2deg(th(k)),LIM_TH)); set(edt(k),'String',sprintf('%.1f',rad2deg(th(k)))); end
        else
            lims={LIM_XY,LIM_XY,LIM_Z};
            for k=1:3, set(sld(k),'Value',clamp(P(k),lims{k})); set(edt(k),'String',sprintf('%.1f',P(k))); end
        end
    end
    function toggleGuard()
        guardOn = logical(get(chkGuard,'Value'));
        applyGuard(); redraw(); updateStatus();
    end
    function goHome()
        if busy, return; end
        th = deg2rad([19.15 19.15 19.15]).'; [P, okState] = delta_fk(th, p);
        lastSafe.th = th; lastSafe.P = P; setMode(mode);
    end
    function recompute()
        if strcmp(mode,'FK'), [P, okState] = delta_fk(th, p);
        else,                 [th, okState] = delta_ik(P, p); end
    end
    function applyGuard()
        [lvl,cJ,mu] = evalSafety(th, P, okState);
        if guardOn && lvl>=2                    % KY DI / NGOAI VUNG -> lui ve an toan
            th = lastSafe.th; P = lastSafe.P; okState = true;
            restoreControls();
            [lvl,cJ,mu] = evalSafety(th, P, okState);
        elseif lvl<=1
            lastSafe.th = th; lastSafe.P = P;   % ghi nho tu the an toan/canh bao gan nhat
        end
        curLvl=lvl; curCond=cJ; curMu=mu;
    end
    function [lvl,condJ,mu] = evalSafety(thL, PL, okL)
        lvl=2; condJ=NaN; mu=NaN;
        if ~okL || any(~isfinite(PL)) || any(~isfinite(thL)), return; end
        if any(thL < p.th_min-1e-9) || any(thL > p.th_max+1e-9), return; end
        [~,condJ,mu] = delta_jacobian(PL, thL, p);
        if ~isfinite(condJ) || condJ>COND_UNSAFE || mu<MU_UNSAFE, lvl=2; return; end
        rxy = hypot(PL(1),PL(2));
        inCyl = rxy <= p.ws_D/2+1e-6 && abs(PL(3)-p.ws_zc) <= p.ws_H/2+1e-6;
        if condJ>COND_WARN || mu<MU_WARN || ~inCyl, lvl=1; else, lvl=0; end
    end
    function redraw()
        updateScene(H, th, P, p, curLvl, guardOn, C_SAFE,C_WARN,C_BAD, TCP_SAFE,TCP_WARN,TCP_BAD);
        drawnow limitrate;
    end
    function updateStatus()
        switch curLvl
            case 0, st='AN TOAN';                 col=[0 0.5 0];
            case 1, st='GAN KY DI (canh bao)';    col=[0.80 0.45 0];
            otherwise, st='KY DI / NGOAI VUNG';   col=[0.8 0 0];
        end
        if isfinite(curCond), cs=sprintf('%.2f',curCond); else, cs='inf (ky di)'; end
        if isfinite(curMu), ms=sprintf('%.1f',curMu); else, ms='-'; end
        out = find(th(:).' < p.th_min-1e-9 | th(:).' > p.th_max+1e-9);
        if isempty(out), ol='khong'; else, ol=num2str(out); end
        s = sprintf(['TRANG THAI: %s\n' ...
            'So dieu kien Jacobian: %s\n' ...
            'Goc truyen muy_min: %s do (gioi han %d)\n' ...
            'Khop vuot gioi han: %s\n\n' ...
            'Goc khop (do):\n  th1=%.1f  th2=%.1f  th3=%.1f\n\n' ...
            'Vi tri ban may (mm):\n  X=%.1f  Y=%.1f  Z=%.1f'], ...
            st, cs, ms, MU_WARN, ol, rad2deg(th(1)),rad2deg(th(2)),rad2deg(th(3)), P(1),P(2),P(3));
        set(txt,'String',s,'ForegroundColor',col);
    end
    function stopTraj(), stopReq = true; end
    function runTraj()
        if busy, return; end
        busy = true; stopReq = false; set(btnPP,'String','Dang chay...','Enable','off');
        pick=[-250;0;-1040]; lift=[-250;0;-810]; over=[250;0;-810]; place=[250;0;-1040];
        wp = [pick lift over place over lift];
        pathP = buildPath(wp, 26); n = size(pathP,2);
        TH = zeros(3,n); OKp = false(1,n);
        for k = 1:n, [TH(:,k), OKp(k)] = delta_ik(pathP(:,k), p); end
        set(H.txt,'Visible','off'); c = 0;
        while ~stopReq && ishandle(f)
            for k = 1:n
                if stopReq || ~ishandle(f), break; end
                th = TH(:,k); P = pathP(:,k); okState = OKp(k);
                [curLvl,curCond,curMu] = evalSafety(th,P,okState);
                updateScene(H, th, P, p, curLvl, guardOn, C_SAFE,C_WARN,C_BAD, TCP_SAFE,TCP_WARN,TCP_BAD);
                c = c + 1; if mod(c,6)==0, updateStatus(); end
                drawnow limitrate;
            end
        end
        set(H.txt,'Visible','on');
        busy = false; lastSafe.th=th; lastSafe.P=P;
        if ishandle(btnPP), set(btnPP,'String','Chay quy dao P&P','Enable','on'); end
        if ishandle(f), setMode(mode); end
    end
end

% ============ TAO DO HOA MOT LAN ============
function H = createScene(ax, p)
hold(ax,'on');
[gx,gy] = meshgrid(linspace(-p.R-60,p.R+60,2));
surf(ax, gx, gy, zeros(2), 'FaceColor',[0.90 0.92 0.95],'EdgeColor','none');
% BIEN VUNG AN TOAN (tru Ø800x250) - khung day mau XANH LA
ang = linspace(0,2*pi,49); rc = p.ws_D/2; z1 = p.ws_zc-p.ws_H/2; z2 = p.ws_zc+p.ws_H/2;
gz = [0.10 0.60 0.20];
H.zone = gobjects(1,6);
H.zone(1) = plot3(ax, rc*cos(ang), rc*sin(ang), z1*ones(size(ang)), '-','Color',gz,'LineWidth',1.5);
H.zone(2) = plot3(ax, rc*cos(ang), rc*sin(ang), z2*ones(size(ang)), '-','Color',gz,'LineWidth',1.5);
av = linspace(0,2*pi,5); av(end)=[];
for k=1:4
    H.zone(2+k) = plot3(ax, rc*cos(av(k))*[1 1], rc*sin(av(k))*[1 1], [z1 z2], '-','Color',gz,'LineWidth',1);
end
% vong khop de + tam
B = zeros(3,3); for i=1:3, B(i,:) = [p.R*cos(p.phi(i)), p.R*sin(p.phi(i)), 0]; end
plot3(ax,[B(:,1);B(1,1)],[B(:,2);B(1,2)],[B(:,3);B(1,3)],':','Color',[0.5 0.5 0.5],'LineWidth',1);
plot3(ax,0,0,0,'ks','MarkerSize',6,'MarkerFaceColor',[0.4 0.4 0.4]);
plot3(ax,B(:,1),B(:,2),B(:,3),'o','MarkerSize',7,'MarkerFaceColor',[0.10 0.35 0.75],'MarkerEdgeColor','k');
% khau dong (cap nhat moi khung)
for i=1:3
    H.bicep(i)   = plot3(ax,[0 0],[0 0],[0 0],'-','Color',[0.10 0.35 0.75],'LineWidth',4);
    H.forearm(i) = plot3(ax,[0 0],[0 0],[0 0],'-','Color',[0.90 0.45 0.10],'LineWidth',2.5);
end
H.elbow = plot3(ax,nan,nan,nan,'o','MarkerSize',6,'MarkerFaceColor',[0.30 0.55 0.90],'MarkerEdgeColor','k','LineStyle','none');
H.plat  = patch(ax,'XData',nan(3,1),'YData',nan(3,1),'ZData',nan(3,1),'FaceColor',[0.70 0.76 0.84],'EdgeColor',[0.3 0.3 0.3],'LineWidth',1.5);
H.tcp   = plot3(ax,nan,nan,nan,'p','MarkerSize',16,'MarkerFaceColor',[0.85 0.1 0.1],'MarkerEdgeColor','k','LineStyle','none');
H.txt   = text(ax,0,0,0,'','FontSize',9,'Color',[0.85 0.1 0.1]);
hold(ax,'off'); grid(ax,'on'); box(ax,'on'); daspect(ax,[1 1 1]);
xlim(ax,[-850 850]); ylim(ax,[-850 850]); zlim(ax,[-1450 200]);
set(ax,'XLimMode','manual','YLimMode','manual','ZLimMode','manual','SortMethod','childorder');
xlabel(ax,'X (mm)'); ylabel(ax,'Y (mm)'); zlabel(ax,'Z (mm)');
view(ax,135,20); title(ax,'Delta Robot - dong hoc');
end

% ============ CHI CAP NHAT DU LIEU ============
function updateScene(H, th, P, p, lvl, drawZone, cS,cW,cB, tS,tW,tB)
if drawZone, zv='on'; else, zv='off'; end
set(H.zone, 'Visible', zv);
switch lvl, case 0, bcol=cS; case 1, bcol=cW; otherwise, bcol=cB; end
switch lvl, case 0, tcol=tS; case 1, tcol=tW; otherwise, tcol=tB; end
B = zeros(3,3); E = zeros(3,3); Pi = zeros(3,3);
for i=1:3
    c=cos(p.phi(i)); s=sin(p.phi(i));
    B(i,:)  = [p.R*c, p.R*s, 0];
    E(i,:)  = B(i,:) + p.L1*[cos(th(i))*c, cos(th(i))*s, -sin(th(i))];
    Pi(i,:) = P(:).' + p.r*[c, s, 0];
end
for i=1:3
    if th(i) < p.th_min-1e-9 || th(i) > p.th_max+1e-9, col=cB; else, col=bcol; end
    set(H.bicep(i),'XData',[B(i,1) E(i,1)],'YData',[B(i,2) E(i,2)],'ZData',[B(i,3) E(i,3)],'Color',col);
end
set(H.elbow,'XData',E(:,1),'YData',E(:,2),'ZData',E(:,3));
if all(isfinite(P))
    for i=1:3
        set(H.forearm(i),'XData',[E(i,1) Pi(i,1)],'YData',[E(i,2) Pi(i,2)],'ZData',[E(i,3) Pi(i,3)],'Visible','on');
    end
    set(H.plat,'XData',Pi(:,1),'YData',Pi(:,2),'ZData',Pi(:,3),'Visible','on');
    set(H.tcp,'XData',P(1),'YData',P(2),'ZData',P(3),'MarkerFaceColor',tcol,'Visible','on');
    set(H.txt,'Position',[P(1) P(2) P(3)-45],'String',sprintf('  P(%.0f, %.0f, %.0f)',P(1),P(2),P(3)),'Color',tcol);
else
    set([H.forearm(:); H.plat; H.tcp],'Visible','off');
    set(H.txt,'Position',[0 0 -500],'String','  Khong toi duoc','Color',[0.8 0 0]);
end
end

% ============ TIEN ICH ============
function path = buildPath(wp, n)
m = size(wp,2); segs = cell(1,m);
for j = 1:m
    a = wp(:,j); b = wp(:, mod(j,m)+1);
    u = linspace(0,1,n); s = 3*u.^2 - 2*u.^3;
    segs{j} = a + (b-a).*s;
end
path = [segs{:}];
end

function v = clamp(v, lim)
v = min(max(v, lim(1)), lim(2));
end
