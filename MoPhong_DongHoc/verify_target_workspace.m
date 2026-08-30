clear; clc;
p = params();
if ~exist('out','dir'), mkdir out; end
diary('out/target_workspace_log.txt'); diary on;
fprintf('=== KIEM TRA TRU VUNG LAM VIEC MUC TIEU ===\n');

Rw = p.ws_D/2; zlo = p.ws_zc-p.ws_H/2; zhi = p.ws_zc+p.ws_H/2;
zv = zlo:10:zhi; rv = 0:10:Rw; av = 0:5:355;
nt=0; nik=0; nacc=0; nbad=0; nanglefail=0; minmu=inf; maxcond=0; maxerr=0;
maxJointReq=-inf; PmaxJointReq=[NaN NaN NaN]; maxViolation=-inf; PmaxViolation=[NaN NaN NaN];
Pbad=zeros(0,3); Pminmu=[NaN NaN NaN]; Pmaxcond=[NaN NaN NaN];
for z=zv
  for rr=rv
    aa=0; if rr>0, aa=av; end
    for a=aa
      P=[rr*cosd(a); rr*sind(a); z]; nt=nt+1;
      [th,ok]=delta_ik(P,p);
      if ok
        thmax=rad2deg(max(th));
        if thmax>maxJointReq, maxJointReq=thmax; PmaxJointReq=P.'; end
        violation=thmax-rad2deg(p.th_max);
        if violation>maxViolation, maxViolation=violation; PmaxViolation=P.'; end
      end
      if ~(ok && all(th>=p.th_min) && all(th<=p.th_max))
        Pbad(end+1,:)=P.'; %#ok<AGROW>
        if ok, nanglefail=nanglefail+1; end
        continue;
      end
      nik=nik+1;
      [~,cJ,mu,dA,~]=delta_jacobian(P,th,p);
      [Pfk,okfk]=delta_fk(th,p);
      if okfk, maxerr=max(maxerr,norm(Pfk-P)); end
      if mu<minmu, minmu=mu; Pminmu=P.'; end
      if cJ>maxcond, maxcond=cJ; Pmaxcond=P.'; end
      if isfinite(cJ) && abs(dA)>1e-6 && mu>=rad2deg(p.mu_min)
        nacc=nacc+1;
      else
        nbad=nbad+1; Pbad(end+1,:)=P.'; %#ok<AGROW>
      end
    end
  end
end

fprintf('Luoi: z buoc 10 mm, rho buoc 10 mm, goc phuong vi buoc 5 deg\n');
fprintf('Tong so diem: %d\n',nt);
fprintf('Co nghiem IK + trong gioi han goc: %d/%d (%.4f%%)\n',nik,nt,100*nik/nt);
fprintf('Dat them Jacobian va mu>=30 deg: %d/%d (%.4f%%)\n',nacc,nt,100*nacc/nt);
fprintf('Diem khong dat tieu chi: %d\n',size(Pbad,1));
fprintf('Diem vuot gioi han goc: %d\n',nanglefail);
fprintf('Goc khop lon nhat can trong luoi = %.4f deg tai [%.0f %.0f %.0f] mm\n',maxJointReq,PmaxJointReq);
fprintf('Vuot gioi han 70 deg lon nhat = %.4f deg tai [%.0f %.0f %.0f] mm\n',maxViolation,PmaxViolation);
fprintf('mu_min = %.4f deg tai [%.0f %.0f %.0f] mm\n',minmu,Pminmu);
fprintf('cond(J)_max = %.4f tai [%.0f %.0f %.0f] mm\n',maxcond,Pmaxcond);
fprintf('Sai so FK(IK(P)) lon nhat = %.3e mm\n',maxerr);
if nacc==nt
  fprintf('KET LUAN: TRU MUC TIEU DUOC BAO PHU 100%% BOI MIEN LAM VIEC CHAP NHAN.\n');
else
  fprintf('KET LUAN: TRU MUC TIEU CHUA DUOC BAO PHU; CAN XEM LAI THAM SO.\n');
end
save('out/target_workspace_results.mat','nt','nik','nacc','nbad','nanglefail','maxJointReq','PmaxJointReq', ...
     'maxViolation','PmaxViolation','minmu','maxcond','maxerr','Pminmu','Pmaxcond','Pbad','Rw','zlo','zhi');
diary off; fprintf('DONE\n');
