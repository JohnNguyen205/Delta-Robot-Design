function p = params()
% PARAMS  Thong so dong hoc Delta Robot HCMUTE (nguon thong so duy nhat).
%   Don vi: mm, rad. Goc theta_i = goc bicep chuc xuong duoi mat phang ngang.
p.R    = 347.0;                    % ban kinh vong khop de [mm] = (R-r)+r = 226.4+120.6
p.r    = 120.6;                    % ban kinh vong khop ban may [mm]
p.Rr   = p.R - p.r;                % 226.4 mm (tham so rut gon)
p.L1   = 407.5;                    % canh tay tren (bicep) [mm]
p.L2   = 1000.0;                   % thanh truyen (forearm, ball-to-ball) [mm]
p.phi  = deg2rad([-90, 30, 150]);  % phuong vi 3 canh tay [rad]

% Vung lam viec muc tieu (tru dong truc)
p.ws_D  = 800;                     % duong kinh [mm]
p.ws_H  = 250;                     % chieu cao [mm]
p.ws_zc = -925;                    % z tam tru (duoi mat vai) [mm]

% Gioi han goc dong co (gia dinh ban dau - can xac nhan tu co cau/hop so)
p.th_min = deg2rad(-45);
p.th_max = deg2rad(70);

% Gioi han goc truyen (transmission angle) toi thieu chap nhan duoc
p.mu_min = deg2rad(30);
end
