%% force_diagram_clean.m
% Redraw of "Hinh 4.1" (force-distribution diagram) in a clean vector
% style: proper arrows (quiver, fixed-fraction heads), no default MATLAB
% text-only annotations, boxed equation callouts, consistent color coding.
%
% Panel (a): force balance at the moving platform (TCP)
% Panel (b): force on one active arm (bicep)
%
% All numeric values (81 N, 175.8 N, 122.7 N, 68 N, 123 N, 79 N, 94 N,
% 50 deg) are taken as-given from the thesis force analysis and are NOT
% recomputed here.
%
% Output: F:\DeltaRobot\ForceAnalysis\figs\force_diagram_clean.png

close all; clc;

outDir = 'F:\DeltaRobot\ForceAnalysis\figs';
if ~exist(outDir,'dir'); mkdir(outDir); end

%% ---- color scheme -------------------------------------------------
col.black   = [0.05 0.05 0.05];       % structural lines
col.blue    = [0.05 0.05 0.05];       % f_i*l_i vectors, N_e/V_e
col.orange  = [0.05 0.05 0.05];       % inertial / motor-related (F_qt, tau)
col.darkred = [0.05 0.05 0.05];       % weight vectors (W, W_arm)
col.purple  = [0.05 0.05 0.05];       % resultant force (F_e)
col.fillTri = [0.90 0.90 0.90];       % platform triangle fill (light gray, non-black so edges stay visible)
col.gray    = [0.35 0.35 0.35];       % reference / construction lines (kept slightly lighter to distinguish dashed ref line)

lwStruct = 2.2;   % structural line width
lwVec    = 1.8;   % force vector line width
lwArc    = 1.4;   % arc line width
fsLabel  = 11;     % math label font size
fsTxt    = 10;     % Vietnamese label font size
fsBox    = 10.5;   % equation box font size
fsTitle  = 12.5;   % panel title font size

fig = figure('Color','w','Position',[100 100 1400 460],'Units','pixels');

%% =====================================================================
%  PANEL (a) -- force balance at the moving platform (TCP)
%% =====================================================================
ax1 = axes('Parent',fig,'Position',[0.045 0.06 0.42 0.84]);
hold(ax1,'on'); axis(ax1,'equal'); axis(ax1,'off');
xlim(ax1,[-2.3 2.3]); ylim(ax1,[-2.1 2.1]);

R = 1.0;                       % platform "circumradius" for the sketch
vAng = [90 210 330];           % vertex angles: up, down-left, down-right
V = R*[cosd(vAng); sind(vAng)]';   % 3x2 vertex coords

% --- platform triangle (light fill, black edge) ---
patch(ax1,'XData',V(:,1),'YData',V(:,2), ...
    'FaceColor',col.fillTri,'EdgeColor',col.black,'LineWidth',lwStruct);
plot(ax1, 0, 0, 'o', 'MarkerSize',4,'MarkerFaceColor',col.black,'MarkerEdgeColor',col.black);

% --- f_i*l_i vectors: outward from each vertex along its own direction ---
armLen = 0.75;
fLabels = {'$f_1\ell_1$','$f_2\ell_2$','$f_3\ell_3$'};
fLabelsTex = {'f_{1}l_{1}','f_{2}l_{2}','f_{3}l_{3}'};
labOffsets = [0 0.18; -0.16 -0.10; 0.16 -0.10];   % nudge label away from arrow tip
labHA = {'center','right','left'};
for k = 1:3
    dir_k = V(k,:)/R;                       % unit outward direction
    p0 = V(k,:);
    p1 = V(k,:) + armLen*dir_k;
    drawArrow(ax1, p0, p1, col.blue, lwVec, 0.35);
    lp = p1 + labOffsets(k,:);
    text(ax1, lp(1), lp(2), fLabelsTex{k}, 'Interpreter','tex', ...
        'FontSize',fsLabel,'Color',col.blue,'HorizontalAlignment',labHA{k}, ...
        'VerticalAlignment','middle','FontWeight','bold');
end

% --- F_qt (inertial force), up-and-right, orange ---
qtAng = 45;
qtLen = 1.05;
p1 = [qtLen*cosd(qtAng), qtLen*sind(qtAng)];
drawArrow(ax1, [0 0], p1, col.orange, lwVec, 0.30);
text(ax1, p1(1)+0.10, p1(2)+0.16, 'F_{qt}', 'Interpreter','tex', ...
    'FontSize',fsLabel,'Color',col.orange,'HorizontalAlignment','left', ...
    'VerticalAlignment','middle','FontWeight','bold');

% --- W, straight down, dark red ---
wLen = 1.05;
p1 = [0, -wLen];
drawArrow(ax1, [0 0], p1, col.darkred, lwVec, 0.30);
text(ax1, p1(1)+0.10, p1(2)-0.05, 'W', 'Interpreter','tex', ...
    'FontSize',fsLabel,'Color',col.darkred,'HorizontalAlignment','left', ...
    'VerticalAlignment','top','FontWeight','bold');

text(ax1, 0, 2.05, '(a) Sơ đồ phân bố lực tại bàn máy (TCP)', ...
    'Interpreter','none','FontSize',fsTitle,'FontWeight','bold', ...
    'HorizontalAlignment','center','VerticalAlignment','bottom');

%% =====================================================================
%  PANEL (b) -- force on one active arm (bicep)
%% =====================================================================
ax2 = axes('Parent',fig,'Position',[0.555 0.06 0.42 0.84]);
hold(ax2,'on'); axis(ax2,'equal'); axis(ax2,'off');
xlim(ax2,[-1.3 4.3]); ylim(ax2,[-3.0 1.6]);

O = [0 0];
armAngDeg = -20;
Larm = 3.0;
E = O + Larm*[cosd(armAngDeg) sind(armAngDeg)];

% --- arm as a thick structural line segment ---
plot(ax2, [O(1) E(1)], [O(2) E(2)], '-', 'Color', col.black, 'LineWidth', 4.2);
plot(ax2, O(1), O(2), 'o', 'MarkerSize',5,'MarkerFaceColor',col.black,'MarkerEdgeColor',col.black);
plot(ax2, E(1), E(2), 'o', 'MarkerSize',5,'MarkerFaceColor',col.black,'MarkerEdgeColor',col.black);

% --- dashed reference line: arm axis extended beyond E (for the mu arc) ---
Lext = 1.0;
Eext = E + Lext*[cosd(armAngDeg) sind(armAngDeg)];
plot(ax2, [E(1) Eext(1)], [E(2) Eext(2)], '--', 'Color', col.gray, 'LineWidth', 1.1);

% --- O label ---
text(ax2, O(1)-0.15, O(2)+0.32, 'O (vai, RA hộp số)', 'Interpreter','none', ...
    'FontSize',fsTxt,'Color',col.black,'HorizontalAlignment','left', ...
    'VerticalAlignment','bottom','FontWeight','bold');

% --- torque arc near O, small curved arrow, orange ---
tCenter = O + [-0.55 -0.35];
tRadius = 0.42;
drawArc(ax2, tCenter, tRadius, 40, 300, col.orange, 1.9, true);
text(ax2, tCenter(1)-0.05, tCenter(2)-0.62, '\tau (mô-men động cơ)', ...
    'Interpreter','tex','FontSize',fsTxt,'Color',col.orange, ...
    'HorizontalAlignment','center','VerticalAlignment','top','FontWeight','bold');

% --- W_arm, straight down from arm midpoint, dark red ---
M = (O + E)/2;
wArmLen = 68*0.012;
p1 = M + [0 -wArmLen];
drawArrow(ax2, M, p1, col.darkred, lwVec, 0.30);
text(ax2, p1(1)+0.12, p1(2)-0.02, 'W_{arm}', 'Interpreter','tex', ...
    'FontSize',fsLabel,'Color',col.darkred,'HorizontalAlignment','left', ...
    'VerticalAlignment','top','FontWeight','bold');

% --- F_e, resultant end force, purple, angle mu from arm axis ---
muDeg = 50;
feAngDeg = armAngDeg - muDeg;     % rotate clockwise (further downward) from arm axis
feLen = 123*0.012;
p1 = E + feLen*[cosd(feAngDeg) sind(feAngDeg)];
drawArrow(ax2, E, p1, col.purple, 2.1, 0.28);
text(ax2, p1(1)+0.12, p1(2)-0.05, 'F_e', 'Interpreter','tex', ...
    'FontSize',fsLabel,'Color',col.purple,'HorizontalAlignment','left', ...
    'VerticalAlignment','top','FontWeight','bold');

% --- angle arc for mu between arm-extended line and F_e, at E ---
muArcR = 0.55;
drawArc(ax2, E, muArcR, feAngDeg, armAngDeg, col.black, 1.3, false);
muMid = feAngDeg + (armAngDeg-feAngDeg)/2;
mp = E + (muArcR+0.28)*[cosd(muMid) sind(muMid)];
text(ax2, mp(1), mp(2), '\mu', 'Interpreter','tex','FontSize',fsLabel+1, ...
    'Color',col.black,'HorizontalAlignment','center','VerticalAlignment','middle', ...
    'FontWeight','bold');

text(ax2, 1.55, 1.35, '(b) Sơ đồ phân bố lực một cánh tay (bicep)', ...
    'Interpreter','none','FontSize',fsTitle,'FontWeight','bold', ...
    'HorizontalAlignment','center','VerticalAlignment','bottom');

%% ---- export ---------------------------------------------------------
outFile = fullfile(outDir,'force_diagram_clean.png');
set(fig,'PaperPositionMode','auto');
try
    exportgraphics(fig, outFile, 'Resolution', 200);
catch
    print(fig, outFile, '-dpng', '-r200');
end

fprintf('Saved: %s\n', outFile);
d = dir(outFile);
fprintf('Size: %d bytes\n', d.bytes);

%% =====================================================================
%  Local helper functions
%% =====================================================================
function h = drawArrow(ax, p0, p1, color, lw, headfrac)
    % Draw a clean vector arrow from p0 to p1 using quiver (no autoscale).
    dx = p1(1) - p0(1);
    dy = p1(2) - p0(2);
    h = quiver(ax, p0(1), p0(2), dx, dy, 0, ...
        'Color', color, 'LineWidth', lw, ...
        'MaxHeadSize', headfrac, 'AutoScale', 'off', ...
        'MarkerSize', 0.001);
end

function drawArc(ax, center, r, theta1_deg, theta2_deg, color, lw, arrowAtEnd)
    % Draw a circular arc from theta1 to theta2 (degrees), optionally with
    % a small arrowhead tangent to the arc at its end.
    th = linspace(theta1_deg, theta2_deg, 60);
    xarc = center(1) + r*cosd(th);
    yarc = center(2) + r*sind(th);
    plot(ax, xarc, yarc, '-', 'Color', color, 'LineWidth', lw);
    if arrowAtEnd
        dth = sign(theta2_deg - theta1_deg) * 3;
        tx0 = center(1) + r*cosd(theta2_deg - dth);
        ty0 = center(2) + r*sind(theta2_deg - dth);
        tx1 = xarc(end);
        ty1 = yarc(end);
        quiver(ax, tx0, ty0, tx1-tx0, ty1-ty0, 0, ...
            'Color', color, 'LineWidth', lw, ...
            'MaxHeadSize', 6, 'AutoScale', 'off');
    end
end
