function varargout = deltaviz(mode, varargin)
% DELTAVIZ  Render 3D Delta robot kieu CAD kim loai (dung chung cho GUI & test).
%   COL = deltaviz('palette')             -> struct mau vat lieu
%   H   = deltaviz('static', ax, p, COL)  -> ve nen: san, den, de + hop dong co (1 lan)
%   H   = deltaviz('dyn',    ax, P, th, p, COL) -> ve canh tay + ban may (moi frame)
%
%   P  = [x;y;z] tam ban may (mm);  th = goc 3 dong co (rad).
%   Tra ve mang handle graphics de xoa/ve lai.

switch lower(mode)
    case 'palette', varargout{1} = palette();
    case 'static',  varargout{1} = drawStatic(varargin{:});
    case 'dyn',     varargout{1} = drawDyn(varargin{:});
    otherwise, error('deltaviz: mode khong hop le: %s', mode);
end
end

% ===================== BANG MAU VAT LIEU =====================
function COL = palette()
COL.bg      = [0.945 0.955 0.970];   % nen figure
COL.scene   = [0.905 0.925 0.960];   % nen truc 3D
COL.floor   = [0.86 0.89 0.94];      % san
COL.base    = [0.30 0.32 0.37];      % de chinh (thep son)
COL.base2   = [0.40 0.42 0.48];      % hub / gan
COL.motor   = [0.17 0.18 0.22];      % vo dong co
COL.arm     = [0.16 0.44 0.86;       % 3 canh tay (mau nhan dien)
               0.92 0.42 0.16;
               0.16 0.66 0.40];
COL.rod     = [0.80 0.82 0.87];      % thanh truyen (nhom bong)
COL.rodbar  = [0.55 0.57 0.63];      % thanh ngang parallelogram
COL.chrome  = [0.86 0.88 0.93];      % khop cau chrome
COL.joint   = [0.13 0.13 0.16];      % khop toi
COL.plat    = [0.96 0.62 0.10];      % ban may (cam)
COL.tcp     = [1.00 0.16 0.16];      % diem TCP
COL.foot    = [0.05 0.80 1.00];      % footprint
end

% ===================== VE NEN (1 LAN) =====================
function H = drawStatic(ax, p, COL)
H = gobjects(0);
zf = -1160;                                   % cao do san
% -- san mo phang trong suot --
g = 640;
[Xf,Yf] = meshgrid(linspace(-g,g,2), linspace(-g,g,2));
Zf = zf*ones(2,2);
H(end+1) = surf(ax, Xf, Yf, Zf, 'FaceColor',COL.floor, 'FaceAlpha',0.35, ...
    'EdgeColor',[0.6 0.65 0.72], 'EdgeAlpha',0.4, 'FaceLighting','none'); %#ok<AGROW>

% -- de chinh: dia day co gan + hub trung tam --
H(end+1) = dTube(ax,[0;0;32],[0;0;0], p.R+55, COL.base, 44);   %#ok<AGROW> dia de
H(end+1) = dTube(ax,[0;0;64],[0;0;30], 120, COL.base2, 30);    %#ok<AGROW> hub
H(end+1) = dTube(ax,[0;0;70],[0;0;64], 46, COL.motor, 22);     %#ok<AGROW> co truc giua

c = cos(p.phi); s = sin(p.phi);
for i = 1:3
    d  = [c(i);s(i);0];                       % huong kinh canh tay i
    % gan gia cuong tu hub ra vanh
    ri = 110*d + [0;0;42];
    ro = (p.R+48)*d + [0;0;42];
    H(end+1) = dBar(ax, ri, ro, 42, 26, COL.base2, [0;0;1]); %#ok<AGROW>
    % hop dong co tai chan canh tay
    Bi = [p.R*c(i); p.R*s(i); 14];
    H(end+1) = dTube(ax, Bi-d*10, Bi+d*72, 34, COL.motor, 22); %#ok<AGROW>
    H(end+1) = dTube(ax, Bi+d*72, Bi+d*80, 20, COL.base2, 18); %#ok<AGROW> nap truc
end
end

% ===================== VE CANH TAY (MOI FRAME) =====================
function H = drawDyn(ax, P, th, p, COL)
P = P(:); H = gobjects(0);
c = cos(p.phi); s = sin(p.phi);
for i = 1:3
    ct = cos(th(i)); st = sin(th(i));
    Bi = [p.R*c(i); p.R*s(i); 0];
    Ei = [p.R*c(i)+p.L1*ct*c(i); p.R*s(i)+p.L1*ct*s(i); -p.L1*st];
    Pi = [P(1)+p.r*c(i); P(2)+p.r*s(i); P(3)];
    tg = [-s(i); c(i); 0];                    % phuong tiep tuyen (mat phang parallelogram)
    off = tg*22;                              % nua be rong

    % -- bicep: thanh may det (flat bar), mat rong huong tiep tuyen --
    H(end+1) = dBar(ax, Bi, Ei, 50, 22, COL.arm(i,:), tg);   %#ok<AGROW>
    % -- khop vai + khuyu chrome --
    H(end+1) = dBall(ax, Bi, 22, COL.joint, false);          %#ok<AGROW>
    H(end+1) = dBall(ax, Ei, 20, COL.chrome, true);          %#ok<AGROW>

    % -- forearm parallelogram: 2 thanh + 2 ngang --
    A1 = Ei+off; A2 = Ei-off; B1 = Pi+off; B2 = Pi-off;
    H(end+1) = dTube(ax, A1, B1, 7.5, COL.rod, 10);          %#ok<AGROW>
    H(end+1) = dTube(ax, A2, B2, 7.5, COL.rod, 10);          %#ok<AGROW>
    H(end+1) = dTube(ax, A1, A2, 6, COL.rodbar, 8);          %#ok<AGROW> ngang tren
    H(end+1) = dTube(ax, B1, B2, 6, COL.rodbar, 8);          %#ok<AGROW> ngang duoi
    % -- 4 khop cau chrome --
    H(end+1) = dBall(ax, A1, 9, COL.chrome, true);           %#ok<AGROW>
    H(end+1) = dBall(ax, A2, 9, COL.chrome, true);           %#ok<AGROW>
    H(end+1) = dBall(ax, B1, 9, COL.chrome, true);           %#ok<AGROW>
    H(end+1) = dBall(ax, B2, 9, COL.chrome, true);           %#ok<AGROW>
end

% -- ban may: dia tron bevel + 3 vau khop --
H(end+1) = dTube(ax,[P(1);P(2);P(3)+9],[P(1);P(2);P(3)-9], p.r+16, COL.plat, 30); %#ok<AGROW>
H(end+1) = dTube(ax,[P(1);P(2);P(3)+11],[P(1);P(2);P(3)+9], p.r+4, COL.base2, 24); %#ok<AGROW>
for i = 1:3
    ctab = [P(1)+p.r*c(i); P(2)+p.r*s(i); P(3)];
    H(end+1) = dBall(ax, ctab, 10, COL.joint, false);        %#ok<AGROW>
end
% -- diem TCP --
H(end+1) = dBall(ax, P, 7, COL.tcp, false);                  %#ok<AGROW>
end

% ===================== PRIMITIVE HINH HOC =====================
function h = dTube(ax, p1, p2, r, col, n)
% ong tru dac ban kinh r noi p1->p2 (co nap 2 dau), be mat kim loai bong.
p1 = p1(:); p2 = p2(:); v = p2-p1; L = norm(v); if L<1e-9, L=1e-9; end
R = rotFrame(v/L, [0;0;1]);
[X,Y,Z] = cylinder(r, n); Z = Z*L;
Q = [X(:) Y(:) Z(:)]*R.';
X = reshape(Q(:,1),size(X))+p1(1);
Y = reshape(Q(:,2),size(Y))+p1(2);
Z = reshape(Q(:,3),size(Z))+p1(3);
mp = {'FaceColor',col, 'EdgeColor','none', 'FaceLighting','gouraud', ...
      'AmbientStrength',0.35, 'DiffuseStrength',0.80, 'SpecularStrength',0.55, ...
      'SpecularExponent',16, 'BackFaceLighting','reverselit'};
h = hggroup(ax);
surf('Parent',h, 'XData',X, 'YData',Y, 'ZData',Z, mp{:});                 % mat ben
patch('Parent',h, 'XData',X(1,:).', 'YData',Y(1,:).', 'ZData',Z(1,:).', mp{:}); % nap day
patch('Parent',h, 'XData',X(2,:).', 'YData',Y(2,:).', 'ZData',Z(2,:).', mp{:}); % nap tren
end

function h = dBall(ax, ctr, r, col, chrome)
% khop cau. chrome=true -> phan chieu manh gan trang.
if nargin < 5, chrome = false; end
[X,Y,Z] = sphere(12);
if chrome
    h = surf(ax, X*r+ctr(1), Y*r+ctr(2), Z*r+ctr(3), 'FaceColor',col, 'EdgeColor','none', ...
        'FaceLighting','gouraud', 'AmbientStrength',0.30, 'DiffuseStrength',0.55, ...
        'SpecularStrength',0.95, 'SpecularExponent',34, 'SpecularColorReflectance',1);
else
    h = surf(ax, X*r+ctr(1), Y*r+ctr(2), Z*r+ctr(3), 'FaceColor',col, 'EdgeColor','none', ...
        'FaceLighting','gouraud', 'AmbientStrength',0.40, 'DiffuseStrength',0.75, ...
        'SpecularStrength',0.45, 'SpecularExponent',18);
end
end

function h = dBar(ax, p1, p2, w, thk, col, ref)
% thanh chu nhat (box) noi p1->p2: rong w (theo ref), day thk.
if nargin < 7, ref = [0;0;1]; end
p1 = p1(:); p2 = p2(:); v = p2-p1; L = norm(v); if L<1e-9, L=1e-9; end
R = rotFrame(v/L, ref);                       % cot: [rong thk truc]
hw = w/2; ht = thk/2;
Vc = [-hw -ht 0;  hw -ht 0;  hw ht 0; -hw ht 0; ...
      -hw -ht L;  hw -ht L;  hw ht L; -hw ht L];
Vc = (R*Vc.').' + p1.';
F = [1 2 3 4; 5 6 7 8; 1 2 6 5; 2 3 7 6; 3 4 8 7; 4 1 5 8];
h = patch(ax, 'Vertices',Vc, 'Faces',F, 'FaceColor',col, 'EdgeColor','none', ...
    'FaceLighting','gouraud', 'AmbientStrength',0.38, 'DiffuseStrength',0.80, ...
    'SpecularStrength',0.55, 'SpecularExponent',18, 'BackFaceLighting','reverselit');
end

function R = rotFrame(vz, ref)
% he truc: cot 3 = vz (truc), cot 1 = thanh phan ref vuong goc vz, cot 2 = cross.
vz = vz(:)/norm(vz); ref = ref(:);
ex = ref - (ref.'*vz)*vz;
if norm(ex) < 1e-6
    tmp = [1;0;0]; if abs(vz(1)) > 0.9, tmp = [0;1;0]; end
    ex = tmp - (tmp.'*vz)*vz;
end
ex = ex/norm(ex); ey = cross(vz, ex);
R = [ex ey vz];
end
