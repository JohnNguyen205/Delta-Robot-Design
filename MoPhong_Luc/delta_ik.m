function [theta, ok] = delta_ik(P, p)
% DELTA_IK  Dong hoc nghich: tam ban may P=[x;y;z] -> goc dong co theta[3] (rad).
%   [theta, ok] = delta_ik(P, p)
%   ok = true neu ca 3 khau co nghiem thuc & trong gioi han goc.
%
% Mo hinh mot canh tay (phuong vi phi):
%   Khop de   Bi = R*[c;s;0],  c=cos(phi), s=sin(phi)
%   Khop ban may Pi = P + r*[c;s;0]
%   Khuyu  Ei = Bi + L1*[cos(th)*c; cos(th)*s; -sin(th)]
%   Rang buoc |Ei - Pi| = L2  ->  E*sin(th) + F*cos(th) + G = 0
%     u  = (x*c + y*s) - (R-r)     (thanh phan huong kinh cua Pi-Bi)
%     w  = -x*s + y*c              (thanh phan tiep tuyen, forearm lech mat phang)
%     E  = 2*L1*z ; F = -2*L1*u ; G = L1^2 + u^2 + w^2 + z^2 - L2^2
theta = nan(3,1);
ok = true;
for i = 1:3
    c = cos(p.phi(i)); s = sin(p.phi(i));
    u  = (P(1)*c + P(2)*s) - p.Rr;
    w  = -P(1)*s + P(2)*c;
    z  = P(3);
    E = 2*p.L1*z;
    F = -2*p.L1*u;
    G = p.L1^2 + u^2 + w^2 + z^2 - p.L2^2;

    rho = hypot(E, F);
    if rho < 1e-12 || abs(G) > rho + 1e-6
        ok = false; theta(i) = NaN; continue;   % khong toi duoc
    end
    % E*sin+F*cos = -G  <=>  sin(th+psi) = -G/rho,  psi = atan2(F,E)
    psi = atan2(F, E);
    as  = max(-1, min(1, -G/rho));
    b   = asin(as);
    cand = [b - psi, pi - b - psi];
    cand = atan2(sin(cand), cos(cand));          % wrap ve (-pi,pi]

    % chon nghiem trong gioi han; neu ca hai -> lay goc nho hon (elbow hop ly)
    inlim = cand(cand >= p.th_min & cand <= p.th_max);
    if isempty(inlim)
        ok = false; theta(i) = cand(1);          % ngoai gioi han
    else
        theta(i) = min(inlim);
    end
end
end
