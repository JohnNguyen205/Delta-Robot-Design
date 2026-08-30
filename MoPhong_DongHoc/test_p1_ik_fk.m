% test_p1_ik_fk.m  -- Phase 1+2: kiem chung IK & FK bang vong lap FK(IK(P))=P
% Chay: matlab -batch "cd('F:/DeltaRobot/MoPhong_DongHoc'); test_p1_ik_fk"
clear; clc;
p = params();
if ~exist('figs','dir'), mkdir figs; end
if ~exist('out','dir'),  mkdir out;  end
diary('out/p1_p2_log.txt'); diary on;

fprintf('=== THONG SO ===\n');
fprintf('R=%.1f r=%.1f (R-r=%.1f) L1=%.1f L2=%.1f mm; phi=[%.0f %.0f %.0f] deg\n', ...
    p.R, p.r, p.Rr, p.L1, p.L2, rad2deg(p.phi));

% --- Diem home: tam ban may ngay duoi tam, z tai tam tru vung lam viec ---
Ph = [0; 0; p.ws_zc];
[th, ok] = delta_ik(Ph, p);
fprintf('\n=== HOME P=(%.1f, %.1f, %.1f) ===\n', Ph);
fprintf('IK ok=%d  theta = [%.3f %.3f %.3f] deg\n', ok, rad2deg(th));
[Pfk, ~] = delta_fk(th, p);
fprintf('FK(theta) = (%.4f, %.4f, %.4f)  |sai so|=%.3e mm\n', Pfk, norm(Pfk-Ph));

% --- Vai diem mau trong tru ---
fprintf('\n=== DIEM MAU ===\n');
samples = [ 200 0 p.ws_zc; 0 200 p.ws_zc-100; -150 -150 p.ws_zc+100; 300 100 -850];
for k=1:size(samples,1)
    Pk = samples(k,:).';
    [tk, okk] = delta_ik(Pk, p);
    if okk
        Pb = delta_fk(tk, p);
        fprintf('P=(%6.1f,%6.1f,%7.1f) ok=%d th=[%6.1f %6.1f %6.1f]deg  err=%.2e\n', ...
            Pk, okk, rad2deg(tk), norm(Pb-Pk));
    else
        fprintf('P=(%6.1f,%6.1f,%7.1f) ok=0 (ngoai vung)\n', Pk);
    end
end

% --- Round-trip tren N diem ngau nhien trong tru muc tieu ---
rng(1);
N = 3000;
Rw = p.ws_D/2;  zlo = p.ws_zc - p.ws_H/2;  zhi = p.ws_zc + p.ws_H/2;
errs = []; nreach = 0; ntot = 0;
for k=1:N
    rr = Rw*sqrt(rand); an = 2*pi*rand;
    Pk = [rr*cos(an); rr*sin(an); zlo + (zhi-zlo)*rand];
    ntot = ntot + 1;
    [tk, okk] = delta_ik(Pk, p);
    if ~okk, continue; end
    % kiem tra gioi han goc that su
    if any(tk < p.th_min-1e-9) || any(tk > p.th_max+1e-9), continue; end
    Pb = delta_fk(tk, p);
    errs(end+1) = norm(Pb - Pk); %#ok<SAGROW>
    nreach = nreach + 1;
end
fprintf('\n=== ROUND-TRIP (tru Ø%.0fx%.0f, tam z=%.0f) ===\n', p.ws_D, p.ws_H, p.ws_zc);
fprintf('So diem: %d, voi-toi: %d (%.1f%%)\n', ntot, nreach, 100*nreach/ntot);
fprintf('Sai so FK(IK(P)) vs P:  max=%.3e  mean=%.3e  median=%.3e mm\n', ...
    max(errs), mean(errs), median(errs));

pass = max(errs) <= 1e-6;
fprintf('\n>>> KET LUAN Phase 1+2: %s (nguong 1e-6 mm)\n', ternary(pass,'DAT','KHONG DAT'));

% --- Bieu do histogram sai so ---
f = figure('Visible','on','Position',[100 100 700 450]);
histogram(log10(max(errs,1e-16)), 40);
xlabel('log_{10}( sai so round-trip [mm] )'); ylabel('so diem');
title(sprintf('Kiem chung IK/FK: %d diem, max=%.1e mm', nreach, max(errs)));
grid on;
saveas(f, 'figs/p2_roundtrip_hist.png');
fprintf('Da luu figs/p2_roundtrip_hist.png\n');
diary off;

function s = ternary(c,a,b), if c, s=a; else, s=b; end, end
