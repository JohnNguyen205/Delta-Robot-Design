function [Jf, condJ, mu_bicep, detA, detB] = delta_jacobian(P, theta, p)
% DELTA_JACOBIAN  Jacobian van toc cua Delta robot tai (P, theta).
%   Rang buoc moi khau: (Ei-Pi).(Ei_dot - P_dot) = 0
%     -> A * xdot = B * thetadot
%   A: hang i = forearm Li = (Ei - Pi).'   (3x3)
%   B: cheo, B_ii = L1 * Li . vhat_i  (vhat_i = huong van toc khuyu)
%   Jf: xdot = Jf * thetadot  (Jf = A\B, Jacobian thuan)
%   condJ = cond(Jf); detA=0 -> ky di song song (Type II); detB=0 -> ky di bien (Type I)
%   mu_bicep = min goc giua forearm va bicep [deg] (goc truyen)
A = zeros(3,3); bd = zeros(3,1); mus = zeros(3,1);
for i = 1:3
    c=cos(p.phi(i)); s=sin(p.phi(i)); ct=cos(theta(i)); st=sin(theta(i));
    Bi = [p.R*c; p.R*s; 0];
    Ei = [p.R*c + p.L1*ct*c; p.R*s + p.L1*ct*s; -p.L1*st];
    Pi = [P(1)+p.r*c; P(2)+p.r*s; P(3)];
    Li = Ei - Pi;                 % forearm
    A(i,:) = Li.';
    vhat = [-st*c; -st*s; -ct];   % huong van toc khuyu (don vi)
    bd(i) = p.L1 * (Li.'*vhat);
    bicep = Ei - Bi;              % vector bicep
    cosb = (Li.'*bicep)/(norm(Li)*norm(bicep));
    mus(i) = rad2deg(acos(max(-1,min(1,abs(cosb)))));
end
B = diag(bd);
detA = det(A); detB = prod(bd);
if abs(detA) < 1e-9
    Jf = nan(3); condJ = inf;
else
    Jf = A\B;
    condJ = cond(Jf);
end
mu_bicep = min(mus);
end
