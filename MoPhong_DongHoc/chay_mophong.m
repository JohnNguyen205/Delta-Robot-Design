% CHAY_MOPHONG  Mo phong 3D Delta robot — tu chay quy dao, chi can quan sat.
%   Chay: chay_mophong
clear; clc;
here = fileparts(mfilename('fullpath'));
if ~isempty(here), cd(here); end
p = params();
COL = deltaviz('palette');

% Quy dao pick & place (vong lap)
W = [ 300 0 -1000; 300 0 -820; -300 0 -820; -300 0 -1000; ...
     -300 0 -820; 300 0 -820; 300 0 -1000];
Pth = localBuildPath(W, 18);
n = size(Pth, 1);

f = figure('Name','DELTA ROBOT — Mo phong dong hoc (tu chay)', ...
    'NumberTitle','off', 'Color', COL.bg, ...
    'Position', [80 60 1100 780], 'Visible','on');
ax = axes('Parent', f); hold(ax,'on');
ax.Color = COL.scene;
deltaviz('static', ax, p, COL);
hDyn = gobjects(0);
hTrail = plot3(ax, NaN, NaN, NaN, '-', 'Color', [0.05 0.75 1], 'LineWidth', 1.8);
camlight(ax,'headlight');
light(ax,'Position',[-0.4 -0.6 0.9],'Style','infinite');
lighting(ax,'gouraud'); material(ax,'dull');
daspect(ax,[1 1 1]); grid(ax,'on'); ax.Box = 'on';
xlim(ax,[-640 640]); ylim(ax,[-640 640]); zlim(ax,[-1170 100]);
view(ax,40,20);
xlabel(ax,'x [mm]'); ylabel(ax,'y [mm]'); zlabel(ax,'z [mm]');
title(ax,'Dang chay quy dao pick & place... (dong cua so de dung)','FontWeight','bold');

% Tru vung lam viec
Rw = p.ws_D/2; zc = p.ws_zc; zl = zc-p.ws_H/2; zh = zc+p.ws_H/2;
[Xc,Yc,Zc] = cylinder(Rw,40); Zc = zl + Zc*(zh-zl);
surf(ax,Xc,Yc,Zc,'FaceColor',[0.90 0.20 0.20],'FaceAlpha',0.09, ...
    'EdgeColor',[0.80 0.30 0.30],'EdgeAlpha',0.25,'FaceLighting','none');

fprintf('=== MO PHONG DANG CHAY (cua so figure) ===\n');
fprintf('Dong cua so de dung. Vong lap vo han.\n');
drawnow;

trailN = 80;
trail = nan(trailN, 3);
k = 0;
while isvalid(f)
    k = k + 1;
    idx = mod(k-1, n) + 1;
    Pc = Pth(idx,:).';
    [th, ~] = delta_ik(Pc, p);
    delete(hDyn(isvalid(hDyn)));
    hDyn = deltaviz('dyn', ax, Pc, th, p, COL);
    trail = [trail(2:end,:); Pc.'];
    set(hTrail, 'XData', trail(:,1), 'YData', trail(:,2), 'ZData', trail(:,3));
    title(ax, sprintf('Pick&place  |  TCP=(%.0f, %.0f, %.0f) mm  |  theta=[%.1f  %.1f  %.1f] deg', ...
        Pc(1), Pc(2), Pc(3), rad2deg(th(1)), rad2deg(th(2)), rad2deg(th(3))), ...
        'FontWeight','bold');
    drawnow;
    pause(0.035);
end
fprintf('Da dung mo phong.\n');

function P = localBuildPath(W, npts)
P = [];
for k = 1:size(W,1)-1
    A = W(k,:); B = W(k+1,:);
    s = linspace(0,1,npts+1);
    s = 10*s.^3 - 15*s.^4 + 6*s.^5;
    Pk = A + s(:)*(B-A);
    if k > 1, Pk = Pk(2:end,:); end
    P = [P; Pk]; %#ok<AGROW>
end
end
