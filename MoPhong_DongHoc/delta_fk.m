function [P, ok] = delta_fk(theta, p)
% DELTA_FK  Dong hoc thuan: goc dong co theta[3] (rad) -> tam ban may P=[x;y;z].
%   Moi khuyu Ei xac dinh; thu bam khop ban may ve tam -> tam ao Ci = Ei - r*[c;s;0].
%   Ban may P thoa |P - Ci| = L2 voi i=1,2,3  => giao 3 mat cau ban kinh L2.
C = zeros(3,3);
for i = 1:3
    c = cos(p.phi(i)); s = sin(p.phi(i));
    ct = cos(theta(i)); st = sin(theta(i));
    Ex = p.R*c + p.L1*ct*c;
    Ey = p.R*s + p.L1*ct*s;
    Ez = -p.L1*st;
    C(i,:) = [Ex - p.r*c, Ey - p.r*s, Ez];
end
[P, ok] = trilaterate(C(1,:), C(2,:), C(3,:), p.L2);
P = P(:);
end

function [P, ok] = trilaterate(c1, c2, c3, rad)
% Giao 3 mat cau cung ban kinh rad, tam c1,c2,c3. Lay nghiem z thap hon.
ok = true;
A = 2*[c2 - c1; c3 - c1];                       % 2x3
bb = [sum(c2.^2) - sum(c1.^2); sum(c3.^2) - sum(c1.^2)];
d = cross(A(1,:), A(2,:));                       % huong duong giao
if norm(d) < 1e-9, P = [NaN NaN NaN]; ok = false; return; end
P0 = (pinv(A)*bb).';                             % nghiem chuan tac (min-norm)
% P = P0 + t*d, the vao |P-c1|^2 = rad^2
aa = dot(d, d);
bq = 2*dot(d, P0 - c1);
cq = dot(P0 - c1, P0 - c1) - rad^2;
disc = bq^2 - 4*aa*cq;
if disc < 0
    if disc > -1e-6, disc = 0; else, P = [NaN NaN NaN]; ok = false; return; end
end
t1 = (-bq + sqrt(disc)) / (2*aa);
t2 = (-bq - sqrt(disc)) / (2*aa);
Pa = P0 + t1*d;  Pb = P0 + t2*d;
if Pa(3) <= Pb(3), P = Pa; else, P = Pb; end     % chon ban may thap hon (z am hon)
end
