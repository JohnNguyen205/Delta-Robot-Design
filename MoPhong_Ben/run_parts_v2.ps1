# run_parts_v2.ps1 - build+solve+SAVE the FEA studies into the copies in MP_BEN_V2.
param([string[]]$Only)
$env:TEMP='F:\SWTEMP'; $env:TMP='F:\SWTEMP'
$run = 'F:\DeltaRobot\MoPhong_Ben\fea_run_v2.ps1'
$folder = 'F:\DeltaRobot\MoPhong_Ben\MP_BEN_V2'

$parts = @(
  @{ Tag='dr006';   Part='DR-006_Elbow-Clevis_FEA.SLDPRT';     Fix=@(1,12);                Load=@(0,34);               Ref=17; Comp=@(0,0,61.35); Mesh=@(8,5,3);    Yield=275 },
  @{ Tag='dr005b';  Part='DR-005-2_Upper-Arm-Link_FEA.SLDPRT'; Fix=@(3,2);                 Load=@(9);                  Ref=0;  Comp=@(185,0,0);   Mesh=@(12,8,5);   Yield=275 },
  @{ Tag='dr007';   Part='DR-007_Moving-Platform_FEA.SLDPRT';  Fix=@(8,48,58,67,73,80);    Load=@(32,33,34,35,36,37);  Ref=30; Comp=@(0,0,29.3);  Mesh=@(12,8,5);   Yield=275 },
  @{ Tag='dr001_1'; Part='DR-001-1_De-Gan-Tay_FEA.SLDPRT';     Fix=@(1);                   Load=@(84,85,98,101,102,105); Ref=0; Comp=@(0,0,100);  Mesh=@(20,14,10); Yield=275 },
  @{ Tag='dr001_3'; Part='DR-001-3_Mat-Treo_FEA.SLDPRT';       Fix=@(35,36,37,38,39,40,41,42,43,45,46,47,48,49,50); Load=@(51,52,53,54,55,56,69,70,71); Ref=31; Comp=@(0,0,233); Mesh=@(12,8,5); Yield=275 }
)

foreach ($p in $parts) {
  if ($Only -and ($Only -notcontains $p.Tag)) { continue }
  Write-Host ("`n########## " + $p.Tag + " (V2 embed) ##########")
  & $run -Part $p.Part -FixFaces $p.Fix -LoadFaces $p.Load -RefFace $p.Ref -Comp $p.Comp -MeshSizes $p.Mesh -Yield $p.Yield -Tag $p.Tag -Folder $folder
}
Write-Host "`nALL DONE V2"
