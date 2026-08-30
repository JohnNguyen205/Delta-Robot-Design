# run_parts.ps1 — run the convergence FEA for the load-bearing parts, sequentially, one SW session.
# Arrays are real PowerShell literals here (passing arrays as CLI args to `powershell -File` from an
# outside shell strips the commas). Invoke: powershell -ExecutionPolicy Bypass -File run_parts.ps1 [tag1 tag2 ...]
# 2026-07-18: face indices re-probed after DR-001 3-file split + symmetry cleanup + aluminum base.
#   Face signatures (see out/faces_*.txt of 2026-07-18):
#   dr006  : Fix F1 R24 journal + F12 back plane z=-12.5; Load F0/F34 R7.94 rod holes; Ref F17 plane n=(0,-1,0)
#   dr005b : Fix F3 R22.5 bore y=+135 + F2 end plane y=+150; Load F9 R22.5 bore y=-135; Ref F0 plane y=-150
#   dr007  : Fix 6x R7.94 ball holes F8/48/58/67/73/80; Load 6x R6 tool holes F32-37; Ref F30 bottom plane
#   dr001_1: Fix F1 weld plane Y=0; Load 6x R8.75 bracket holes (2/arm) F84/85/98/101/102/105; Ref F0 plane Y=50
#   dr001_3: Fix 9x R7 M16 F35-43 + 6x R8.75 M20 F45-50 (ceiling taps); Load 9x R6.75 M12 thru F51-56/69-71; Ref F31
param([string[]]$Only)   # optional: run only these tags (e.g. dr006 dr005b)
$env:TEMP='F:\SWTEMP'; $env:TMP='F:\SWTEMP'
if (-not (Test-Path 'F:\SWTEMP')) { New-Item -ItemType Directory -Force 'F:\SWTEMP' | Out-Null }
$run = 'F:\DeltaRobot\MoPhong_Ben\fea_run.ps1'

$parts = @(
  @{ Tag='dr006';   Part='DR-006_Elbow-Clevis.SLDPRT';     Fix=@(1,12);                Load=@(0,34);               Ref=17; Comp=@(0,0,61.35); Mesh=@(8,5,3);    Yield=275 },
  @{ Tag='dr005b';  Part='DR-005-2_Upper-Arm-Link.SLDPRT'; Fix=@(3,2);                 Load=@(9);                  Ref=0;  Comp=@(185,0,0);   Mesh=@(12,8,5);   Yield=275 },
  @{ Tag='dr007';   Part='DR-007_Moving-Platform.SLDPRT';  Fix=@(8,48,58,67,73,80);    Load=@(32,33,34,35,36,37);  Ref=30; Comp=@(0,0,29.3);  Mesh=@(12,8,5);   Yield=275 },
  @{ Tag='dr001_1'; Part='DR-001-1_De-Gan-Tay.SLDPRT';     Fix=@(1);                   Load=@(84,85,98,101,102,105); Ref=0; Comp=@(0,0,100);  Mesh=@(20,14,10); Yield=275 },
  @{ Tag='dr001_3'; Part='DR-001-3_Mat-Treo.SLDPRT';       Fix=@(35,36,37,38,39,40,41,42,43,45,46,47,48,49,50); Load=@(51,52,53,54,55,56,69,70,71); Ref=31; Comp=@(0,0,233); Mesh=@(12,8,5); Yield=275 }
)

foreach ($p in $parts) {
  if ($Only -and ($Only -notcontains $p.Tag)) { continue }
  Write-Host ("`n########## " + $p.Tag + " ##########")
  & $run -Part $p.Part -FixFaces $p.Fix -LoadFaces $p.Load -RefFace $p.Ref -Comp $p.Comp -MeshSizes $p.Mesh -Yield $p.Yield -Tag $p.Tag
}
Write-Host "`nALL DONE"
