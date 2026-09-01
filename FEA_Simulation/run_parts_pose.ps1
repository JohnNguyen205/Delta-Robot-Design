# run_parts_pose.ps1 - FEA at WORST-CASE difficult-pose loads (from ForceAnalysis/force_poses.m).
# Worst pose = workspace bottom edge R400 z-1050: cap forearm force 182.4 N (x1.49 baseline 122.7),
# joint/bicep bending 74.3 N.m. Platform Fee 176.1 N ~ unchanged (pose-independent) so DR-007 skipped.
# Uses fea_run.ps1 (no save) -> conv_<tag>_pose.csv + fea_<tag>_pose_vonMises.bmp. Loads SCALED x1.487.
param([string[]]$Only)
$env:TEMP='F:\SWTEMP'; $env:TMP='F:\SWTEMP'
$run = 'F:\DeltaRobot\FEA_Simulation\fea_run.ps1'
$parts = @(
  # dr006 clevis: baseline (0,0,61.35)=122.7N -> pose 182.4N -> per-face 91.2
  @{ Tag='dr006_pose';   Part='DR-006_Elbow-Clevis.SLDPRT';     Fix=@(1,12);   Load=@(0,34);   Ref=17; Comp=@(0,0,91.2);  Mesh=@(8,5,3);  Yield=275 },
  # dr005b arm bending: baseline (185,0,0)=50N.m -> pose 74.3N.m -> 275 N lateral
  @{ Tag='dr005b_pose';  Part='DR-005-2_Upper-Arm-Link.SLDPRT'; Fix=@(3,2);    Load=@(9);      Ref=0;  Comp=@(275,0,0);  Mesh=@(12,8,5); Yield=275 },
  # dr001_1 plate: baseline (0,0,100)=600N bracket reaction -> x1.49 -> per-face 149
  @{ Tag='dr001_1_pose'; Part='DR-001-1_De-Gan-Tay.SLDPRT';     Fix=@(1);       Load=@(84,85,98,101,102,105); Ref=0; Comp=@(0,0,149); Mesh=@(20,14,10); Yield=275 }
)
foreach ($p in $parts) {
  if ($Only -and ($Only -notcontains $p.Tag)) { continue }
  Write-Host ("`n########## " + $p.Tag + " (POSE worst-case) ##########")
  & $run -Part $p.Part -FixFaces $p.Fix -LoadFaces $p.Load -RefFace $p.Ref -Comp $p.Comp -MeshSizes $p.Mesh -Yield $p.Yield -Tag $p.Tag
}
Write-Host "`nALL DONE POSE"
