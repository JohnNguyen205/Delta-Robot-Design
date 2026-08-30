% p6_animate.m -- Phase 6: hoat hinh 3D robot chay theo quy dao (xuat GIF)
clear; clc;
p = params();
if ~exist('figs','dir'), mkdir figs; end
if ~exist('figs/frames','dir'), mkdir figs/frames; end
fprintf('=== PHASE 6: HOAT HINH 3D ===\n');

% Quy dao (dung lai waypoint nhu Phase 5, lay thua frame)
W = [ 300 0 -1000; 300 0 -820; -300 0 -820; -300 0 -1000];
nf = 48; P = [];
seglen = [round(nf*0.25) round(nf*0.5) round(nf*0.25)];
for k=1:3
  A=W(k,:); Bp=W(k+1,:); m=seglen(k); ss=linspace(0,1,m+1);
  ss=10*ss.^3-15*ss.^4+6*ss.^5;
  Pk=A+ss(:)*(Bp-A); if k>1, Pk=Pk(2:end,:); end
  P=[P;Pk]; %#ok<AGROW>
end
nfr=size(P,1);

phi=p.phi; c=cos(phi); s=sin(phi);
gif='figs/p6_animation.gif';
f=figure('Visible','off','Position',[80 80 720 620],'Color','w');
for f_i=1:nfr
  Pc=P(f_i,:).'; [th,~]=delta_ik(Pc,p);
  clf; hold on; grid on; axis equal;
  % de: tam giac khop de
  B=[p.R*c; p.R*s; zeros(1,3)];
  plot3(B(1,[1 2 3 1]),B(2,[1 2 3 1]),B(3,[1 2 3 1]),'k-','LineWidth',1);
  cols=[0.85 0.2 0.2; 0.2 0.6 0.2; 0.2 0.3 0.85];
  Pj=zeros(3,3);
  for i=1:3
    ct=cos(th(i)); st=sin(th(i));
    Bi=[p.R*c(i); p.R*s(i); 0];
    Ei=[p.R*c(i)+p.L1*ct*c(i); p.R*s(i)+p.L1*ct*s(i); -p.L1*st];
    Pi=[Pc(1)+p.r*c(i); Pc(2)+p.r*s(i); Pc(3)];
    Pj(:,i)=Pi;
    plot3([Bi(1) Ei(1)],[Bi(2) Ei(2)],[Bi(3) Ei(3)],'-','Color',cols(i,:),'LineWidth',3);   % bicep
    plot3([Ei(1) Pi(1)],[Ei(2) Pi(2)],[Ei(3) Pi(3)],'-','Color',cols(i,:),'LineWidth',1.5);  % forearm
    plot3(Ei(1),Ei(2),Ei(3),'ko','MarkerFaceColor',cols(i,:),'MarkerSize',5);
  end
  % ban may
  plot3(Pj(1,[1 2 3 1]),Pj(2,[1 2 3 1]),Pj(3,[1 2 3 1]),'m-','LineWidth',2);
  plot3(Pc(1),Pc(2),Pc(3),'m*','MarkerSize',9);
  plot3(P(1:f_i,1),P(1:f_i,2),P(1:f_i,3),'b:','LineWidth',1);   % vet quy dao
  xlim([-600 600]); ylim([-600 600]); zlim([-1100 60]);
  xlabel('x'); ylabel('y'); zlabel('z [mm]'); view(35,18);
  title(sprintf('Delta robot - pick&place  (frame %d/%d)',f_i,nfr));
  fn=sprintf('figs/frames/fr_%03d.png',f_i);
  exportgraphics(f,fn,'Resolution',90);
  [Im,map]=rgb2ind(imread(fn),128);
  if f_i==1, imwrite(Im,map,gif,'gif','LoopCount',inf,'DelayTime',0.06);
  else,      imwrite(Im,map,gif,'gif','WriteMode','append','DelayTime',0.06); end
end
fprintf('Da luu %s (%d frame)\n',gif,nfr);
