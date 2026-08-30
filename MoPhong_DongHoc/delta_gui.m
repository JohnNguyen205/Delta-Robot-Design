function delta_gui
% DELTA_GUI  Giao dien don gian: nhap tay X/Y/Z -> dong hoc nghich, ve robot dang stick.
%   Chay:  delta_gui   (trong thu muc MoPhong_DongHoc)
%   - Nhap gia tri X, Y, Z (mm) vao o so roi Enter -> robot cap nhat.
%   - Nut Home ve tam vung lam viec; nut goc nhin; hien/an tru lam viec.
p = params();

% ---- mau ----
C.bg    = [0.96 0.97 0.98];
C.scene = [1 1 1];
C.base  = [0.25 0.27 0.32];
C.arm   = [0.13 0.42 0.86; 0.92 0.42 0.12; 0.12 0.62 0.36];  % 3 canh tay
C.rod   = [0.45 0.48 0.55];
C.plat  = [0.95 0.60 0.08];
C.tcp   = [0.90 0.10 0.10];

% ---- gioi han o nhap ----
LIM = [-450 450; -450 450; -1150 -600];

% ---- trang thai ----
Pcur = [0;0;p.ws_zc];
hDyn = gobjects(0);
playing = false;

% ================= GIAO DIEN =================
fig = uifigure('Name','DELTA ROBOT - Mo phong dong hoc (HCMUTE)', ...
    'Position',[120 90 1080 700], 'Color',C.bg);
fig.CloseRequestFcn = @(s,e)onClose();

G = uigridlayout(fig,[1 2]);
G.ColumnWidth = {300,'1x'}; G.RowHeight = {'1x'};
G.Padding = [12 12 12 12]; G.ColumnSpacing = 12;

% -------- Cot trai: dieu khien --------
left = uigridlayout(G,[4 1]);
left.RowHeight = {150, 96, 150, '1x'};
left.Padding = [0 0 0 0]; left.RowSpacing = 10;

% Panel 1: nhap toa do
pIn = uipanel(left,'Title','  NHAP TOA DO TAM BAN MAY (mm)', ...
    'FontWeight','bold','FontSize',12,'BackgroundColor',[1 1 1]);
LI = uigridlayout(pIn,[3 2]);
LI.ColumnWidth = {40,'1x'}; LI.RowHeight = {'1x','1x','1x'};
LI.RowSpacing = 8; LI.Padding = [14 12 14 12];
ex = mkField(LI,1,'X', 0,        LIM(1,:));
ey = mkField(LI,2,'Y', 0,        LIM(2,:));
ez = mkField(LI,3,'Z', p.ws_zc,  LIM(3,:));
ex.ValueChangedFcn = @(s,e)onField(1,e.Value);
ey.ValueChangedFcn = @(s,e)onField(2,e.Value);
ez.ValueChangedFcn = @(s,e)onField(3,e.Value);

% Panel 2: nut lenh
pBtn = uipanel(left,'Title','  LENH','FontWeight','bold','FontSize',12, ...
    'BackgroundColor',[1 1 1]);
LB = uigridlayout(pBtn,[1 3]);
LB.Padding = [12 12 12 12]; LB.ColumnSpacing = 8;
uibutton(LB,'Text','Home','Tooltip','Ve tam vung lam viec (0,0,zc)', ...
    'ButtonPushedFcn',@(s,e)onHome());
demoBtn = uibutton(LB,'Text','Demo quy dao','BackgroundColor',[0.30 0.72 0.36], ...
    'FontColor',[1 1 1],'Tooltip','Chay/dung quy dao pick&place', ...
    'ButtonPushedFcn',@(s,e)onDemo());
cylChk  = uicheckbox(LB,'Text','Tru lam viec','Value',true, ...
    'ValueChangedFcn',@(s,e)drawScene());

% Panel 3: goc nhin
pView = uipanel(left,'Title','  GOC NHIN','FontWeight','bold','FontSize',12, ...
    'BackgroundColor',[1 1 1]);
LVw = uigridlayout(pView,[2 2]);
LVw.Padding = [12 12 12 12]; LVw.RowSpacing = 8; LVw.ColumnSpacing = 8;
uibutton(LVw,'Text','Iso',  'ButtonPushedFcn',@(s,e)setView(40,20));
uibutton(LVw,'Text','Top',  'ButtonPushedFcn',@(s,e)setView(0,90));
uibutton(LVw,'Text','Front','ButtonPushedFcn',@(s,e)setView(0,0));
uibutton(LVw,'Text','Side', 'ButtonPushedFcn',@(s,e)setView(90,0));

% Panel 4: trang thai
pSt = uipanel(left,'Title','  TRANG THAI','FontWeight','bold','FontSize',12, ...
    'BackgroundColor',[1 1 1]);
LS = uigridlayout(pSt,[4 1]);
LS.Padding = [12 12 12 12]; LS.RowSpacing = 6;
LS.RowHeight = {24,24,26,'1x'};
poslab = uilabel(LS,'Text','TCP = ( )','FontName','Consolas','FontSize',13);
thlab  = uilabel(LS,'Text','theta = [ ]','FontName','Consolas','FontSize',13);
reachlab = uilabel(LS,'Text','trong vung lam viec','FontSize',12,'FontWeight','bold', ...
    'FontColor',[0.15 0.5 0.2]);
statlab = uilabel(LS,'Text','San sang. Nhap X/Y/Z roi Enter.', ...
    'FontAngle','italic','FontColor',[0.4 0.4 0.4],'WordWrap','on');

% -------- Cot phai: truc 3D --------
ax = uiaxes(G); ax.Layout.Column = 2;
setupScene();
drawScene();

% ==================== NESTED ====================
    function onField(idx,val)
        if playing, return; end
        Pcur(idx) = min(max(val,LIM(idx,1)),LIM(idx,2));
        syncFields(); drawScene();
    end
    function onHome()
        playing=false; demoBtn.Text='Demo quy dao';
        Pcur=[0;0;p.ws_zc]; syncFields(); drawScene();
        statlab.Text='Da ve home.';
    end
    function onDemo()
        if playing
            playing=false; demoBtn.Text='Demo quy dao'; return;
        end
        playing=true; demoBtn.Text='Dung';
        statlab.Text='Dang chay quy dao pick & place...';
        W=[300 0 -1000;300 0 -820;-300 0 -820;-300 0 -1000; ...
           -300 0 -820;300 0 -820;300 0 -1000];
        Pth=buildPath(W,22);
        while playing && isvalid(fig)
            for k=1:size(Pth,1)
                if ~playing, break; end
                Pcur=Pth(k,:).'; syncFields(); drawScene(); pause(0.03);
            end
        end
        demoBtn.Text='Demo quy dao';
        if isvalid(fig), statlab.Text='Da dung quy dao.'; end
    end
    function setView(az,el), if isvalid(ax), view(ax,az,el); end, end
    function syncFields()
        ex.Value=round(Pcur(1)); ey.Value=round(Pcur(2)); ez.Value=round(Pcur(3));
    end

    function setupScene()
        cla(ax); hold(ax,'on'); ax.Color=C.scene;
        c=cos(p.phi); s=sin(p.phi);
        % vong khop de (tam dong co) + tam
        Bx=p.R*c; By=p.R*s;
        plot3(ax,[Bx Bx(1)],[By By(1)],[0 0 0 0],'-','Color',C.base,'LineWidth',2.5);
        plot3(ax,Bx,By,[0 0 0],'s','MarkerSize',11,'MarkerFaceColor',C.base, ...
            'MarkerEdgeColor','none');
        plot3(ax,0,0,0,'+','Color',C.base,'MarkerSize',10,'LineWidth',1.5);
        daspect(ax,[1 1 1]); grid(ax,'on'); ax.Box='on';
        xlim(ax,[-640 640]); ylim(ax,[-640 640]); zlim(ax,[-1170 100]);
        view(ax,40,20);
        xlabel(ax,'x [mm]'); ylabel(ax,'y [mm]'); zlabel(ax,'z [mm]');
        title(ax,'Mo hinh 3D Delta Robot (stick)','FontWeight','bold');
    end

    function drawScene()
        [th,ok]=delta_ik(Pcur,p);
        inlim = ok && all(th>=p.th_min) && all(th<=p.th_max);
        delete(hDyn(isvalid(hDyn))); hDyn=gobjects(0);
        c=cos(p.phi); s=sin(p.phi);
        Pf=zeros(3,3);
        for i=1:3
            ct=cos(th(i)); st=sin(th(i));
            Bi=[p.R*c(i); p.R*s(i); 0];
            Ei=[p.R*c(i)+p.L1*ct*c(i); p.R*s(i)+p.L1*ct*s(i); -p.L1*st];
            Pi=[Pcur(1)+p.r*c(i); Pcur(2)+p.r*s(i); Pcur(3)];
            Pf(:,i)=Pi;
            tg=[-s(i); c(i); 0]*22;   % nua be rong parallelogram
            % bicep
            hDyn(end+1)=plot3(ax,[Bi(1) Ei(1)],[Bi(2) Ei(2)],[Bi(3) Ei(3)], ...
                '-','Color',C.arm(i,:),'LineWidth',4); %#ok<AGROW>
            % forearm parallelogram: 2 thanh song song
            A1=Ei+tg; A2=Ei-tg; B1=Pi+tg; B2=Pi-tg;
            hDyn(end+1)=plot3(ax,[A1(1) B1(1)],[A1(2) B1(2)],[A1(3) B1(3)], ...
                '-','Color',C.rod,'LineWidth',1.8); %#ok<AGROW>
            hDyn(end+1)=plot3(ax,[A2(1) B2(1)],[A2(2) B2(2)],[A2(3) B2(3)], ...
                '-','Color',C.rod,'LineWidth',1.8); %#ok<AGROW>
            % khop
            hDyn(end+1)=plot3(ax,Ei(1),Ei(2),Ei(3),'o','MarkerSize',7, ...
                'MarkerFaceColor',C.arm(i,:),'MarkerEdgeColor','none'); %#ok<AGROW>
            hDyn(end+1)=plot3(ax,Pi(1),Pi(2),Pi(3),'o','MarkerSize',6, ...
                'MarkerFaceColor',C.plat,'MarkerEdgeColor','none'); %#ok<AGROW>
        end
        % ban may (tam giac) + TCP
        hDyn(end+1)=plot3(ax,[Pf(1,:) Pf(1,1)],[Pf(2,:) Pf(2,1)],[Pf(3,:) Pf(3,1)], ...
            '-','Color',C.plat,'LineWidth',2.5); %#ok<AGROW>
        hDyn(end+1)=plot3(ax,Pcur(1),Pcur(2),Pcur(3),'o','MarkerSize',9, ...
            'MarkerFaceColor',C.tcp,'MarkerEdgeColor','none'); %#ok<AGROW>
        if cylChk.Value, hDyn(end+1)=drawCyl(); end %#ok<AGROW>
        % doc so
        poslab.Text=sprintf('TCP = (%5.0f, %5.0f, %6.0f)',Pcur);
        thlab.Text =sprintf('theta = [%5.1f %5.1f %5.1f] do',rad2deg(th));
        if inlim
            reachlab.Text='trong vung lam viec'; reachlab.FontColor=[0.15 0.5 0.2];
        else
            reachlab.Text='NGOAI vung lam viec!'; reachlab.FontColor=[0.80 0.10 0.10];
        end
        drawnow limitrate;
    end

    function h=drawCyl()
        Rw=p.ws_D/2; zc=p.ws_zc; zl=zc-p.ws_H/2; zh=zc+p.ws_H/2;
        [Xc,Yc,Zc]=cylinder(Rw,36); Zc=zl+Zc*(zh-zl);
        h=surf(ax,Xc,Yc,Zc,'FaceColor',[0.90 0.25 0.25],'FaceAlpha',0.07, ...
            'EdgeColor',[0.85 0.35 0.35],'EdgeAlpha',0.25,'FaceLighting','none');
    end

    function onClose()
        playing=false; delete(fig);
    end
end

% ---------- ham phu ----------
function ef = mkField(L,row,name,val,lims)
lab=uilabel(L,'Text',name,'FontWeight','bold','FontSize',15, ...
    'HorizontalAlignment','center');
lab.Layout.Row=row; lab.Layout.Column=1;
ef=uieditfield(L,'numeric','Value',val,'Limits',lims, ...
    'HorizontalAlignment','center','FontSize',14);
ef.Layout.Row=row; ef.Layout.Column=2;
end

function P=buildPath(W,npts)
P=[];
for k=1:size(W,1)-1
    A=W(k,:); B=W(k+1,:); ss=linspace(0,1,npts+1); ss=10*ss.^3-15*ss.^4+6*ss.^5;
    seg=A+ss(:)*(B-A); if k>1, seg=seg(2:end,:); end
    P=[P; seg]; %#ok<AGROW>
end
end
