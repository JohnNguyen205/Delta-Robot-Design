# fea_asm_run.ps1 - WHOLE-ASSEMBLY static FEA on DR-000_Delta-Robot_V0.SLDASM.
# One invocation = one mesh size (fresh process per run - stale-COM-handle trap).
# Model: global bonded contact, fixed = ceiling face of DR-001-3 (Z=-177.8, N=+Z),
# loads = gravity+dynamic accel 11.58 m/s2 along -Z (whole structure) + 220 N down on
# DR-007 bottom face (payload 2 kg + tool 0.5 kg, worst-case dynamic).
# NEVER SAVES the assembly (evidence = CSV + BMP + console log).
param(
  [double]$MaxMM = 25,
  [double]$MinMM = 8,
  [string]$Tag   = 'toanrobot_25',
  [int]$SwPid    = 2272,
  [int]$Mesher   = 2,     # 0=standard, 1=curvature, 2=blended curvature-based
  [int]$Quality  = 1,     # 0=draft, 1=high
  [switch]$ExportPlot,
  [switch]$SkipSolve      # mesh-only probe
)
$ErrorActionPreference = 'Stop'
. 'F:\DeltaRobot\FEA_Simulation\fea_asm_common.ps1'
$outDir = 'F:\DeltaRobot\FEA_Simulation\out'
$figDir = 'F:\DeltaRobot\FEA_Simulation\figs'

$sw = Connect-SWPid $SwPid
$asmPath = 'F:\DeltaRobot\DeltaRobot_Final\DR-000_Delta-Robot_V0.SLDASM'
$doc = Open-Doc $sw $asmPath
Write-Host ('doc: ' + [SwRaw]::InvokeN($doc,'GetPathName',@()))
$ext = [SwRaw]::Invoke0($doc,'Extension',$true)
Write-Host ('WhatsWrongCount: ' + [SwRaw]::InvokeN($ext,'GetWhatsWrongCount',@()))

$cw    = Load-Sim $sw
$cwDoc = [SwRaw]::Invoke0($cw,'ActiveDoc',$true)
if ($null -eq $cwDoc) { throw 'cosmos ActiveDoc null' }
$sm    = [SwRaw]::Invoke0($cwDoc,'StudyManager',$true)

$studyName = "wb_$Tag"
try { [void][SwRaw]::InvokeN($sm,'DeleteStudy',@([string]$studyName)) } catch {}
$r = [SwRaw]::InvokeNRefLast($sm,'CreateNewStudy2',@([string]$studyName,[int]0))
$study = $r[0]
if ($null -eq $study) { throw "CreateNewStudy2 null err=$($r[1])" }
try { [void][SwRaw]::InvokeN($sm,'SetActiveStudy',@([int]([SwRaw]::Invoke0($sm,'StudyCount',$false)-1))) } catch {}
Write-Host "study $studyName created"
Write-Host ('  ' + [SwFea2]::GlobalContact($study))

# --- materials read-back (evidence) - first run only writes the full list ---
$matLog = $outDir + '\asm_materials.txt'
if (-not (Test-Path $matLog)) {
  [SwFea2]::ListSolidComps($study) | Out-File -Encoding utf8 $matLog
  Write-Host "  materials -> $matLog"
}

$lrm = [SwRaw]::Invoke0($study,'LoadsAndRestraintsManager',$true)

# --- FIXTURE: ceiling face of DR-001-3 (planar, N=+Z, Z in [-180,-175] mm, big) ---
$lid = [SwAsm]::FindComp($doc,'DR-001-3')
if ($null -eq $lid) { throw 'DR-001-3 not found' }
$fixFaces = [SwAsm]::PickPlanarFaces($lid, 0.0,0.0,1.0, 0.99, -180.0, -175.0, 10000.0)
Write-Host ("fixture faces: " + $fixFaces.Length)
if ($fixFaces.Length -lt 1) { throw 'no fixture face found' }
$rr = [SwFea2]::AddFixed($lrm, $fixFaces)
Write-Host ("  AddFixed err=" + $rr[1])
if ($null -eq $rr[0]) { throw 'AddFixed returned null' }

# --- FORCE: 220 N down (-Z) on DR-007 bottom face (N=-Z, proj(-Z) ~ +1707.6) ---
$plat = [SwAsm]::FindComp($doc,'DR-007')
if ($null -eq $plat) { throw 'DR-007 not found' }
$ldFaces = [SwAsm]::PickPlanarFaces($plat, 0.0,0.0,-1.0, 0.99, 1700.0, 1712.0, 20000.0)
Write-Host ("load faces: " + $ldFaces.Length)
if ($ldFaces.Length -lt 1) { throw 'no load face found' }
# d3 = along outward normal of ref face (= -Z, down) -> +220 N = downward
$fr = [SwFea2]::AddForceDir($lrm, $ldFaces, $ldFaces[0], 0.0, 0.0, 220.0)
Write-Host ("  AddForce err=" + $fr[1] + " endEdit=" + $fr[2])
if ($null -eq $fr[0]) { throw 'AddForce returned null' }

# --- GRAVITY: 11.58 m/s2 along -Z via Front Plane (normal (0,0,1)) ---
$fp = [SwAsm]::GetRefPlaneFeature($doc,'Front Plane')
if ($null -eq $fp) { throw 'Front Plane not found' }
$gr = [SwFea2]::AddGravity($lrm, $fp, 0.0, 0.0, -11.58)
Write-Host ("  AddGravity err=" + $gr[1] + " endEdit=" + $gr[2] + " readback=(" + $gr[3] + "," + $gr[4] + "," + $gr[5] + ")")
if ($null -eq $gr[0]) { throw 'AddGravity returned null' }

# --- GEARBOX MATERIAL: TPMA STEP bodies have none in CAD -> assign custom in-study.
# Steel stiffness, EFFECTIVE density 3441 kg/m3 (real 8.1 kg / CAD volume 2.354 L) so
# self-weight is correct despite the imported-STEP default-density issue (CLAUDE.md).
$gbm = [SwFea2]::SetCompMaterial($study, 'TPMA010S', 'TPMA-Housing-EffDens', 2.1e11, 0.28, 3441.0, 2.5e8, 4.0e8)
Write-Host ("gearbox material: " + $gbm)

# --- MESH ---
[SwFea2]::SetupMesh($study, $Mesher, $Quality)
$t0 = Get-Date
$rcm = [SwRaw]::InvokeN($study,'CreateMesh',@([int]0,[double]$MaxMM,[double]$MinMM))
$tMesh = ((Get-Date) - $t0).TotalSeconds
Write-Host ("CreateMesh rc=" + $rcm + " (" + [math]::Round($tMesh) + " s)")
Write-Host ('  ' + [SwFea2]::MeshInfo($study))
if ($rcm -ne 0) {
  Write-Host ('  FAILED comps: ' + [SwFea2]::FailedComps($study))
  throw "mesh failed rc=$rcm"
}
$mesh = [SwRaw]::Invoke0($study,'Mesh',$true)
$nNode = [SwRaw]::Invoke0($mesh,'NodeCount',$true)
$nElem = [SwRaw]::Invoke0($mesh,'ElementCount',$true)
Write-Host ("  nodes=$nNode elems=$nElem")
if ($SkipSolve) { Write-Host 'SkipSolve set - stopping after mesh'; exit 0 }

# --- SOLVE ---
$t0 = Get-Date
$rc = [SwRaw]::InvokeN($study,'RunAnalysis',@())
$tSolve = ((Get-Date) - $t0).TotalSeconds
Write-Host ("RunAnalysis rc=$rc (" + [math]::Round($tSolve) + " s)")
if ($rc -ne 0) { throw "RunAnalysis failed rc=$rc" }

# --- RESULTS ---
$results = [SwRaw]::Invoke0($study,'Results',$true)
$sres = [SwFea2]::MinMaxStress($results)
Write-Host ("stress err=" + $sres[1] + " raw=" + [SwFea2]::FmtArr($sres[0]))
$sArr = $sres[0]
$vm = [double]$sArr[3] / 1e6
$maxNode = [int]$sArr[2]
$dres = [SwFea2]::MinMaxDisp($results)
$dArr = $dres[0]
$disp = [double]$dArr[3] * 1000
Write-Host ("disp err=" + $dres[1] + " raw=" + [SwFea2]::FmtArr($dres[0]))
# UZ component (2) to confirm sag direction
try {
  $uz = [SwRaw]::InvokeNRefLast($results,'GetMinMaxDisplacement',@([int]2,[int]1,[System.DBNull]::Value,[int]0))
  Write-Host ("UZ raw=" + [SwFea2]::FmtArr($uz[0]))
} catch { Write-Host ("UZ read failed: " + $_.Exception.Message) }

# locate max-stress node
$locStr = ''
try {
  $nl = [SwFea2]::NodeLoc($study, $maxNode)
  $nx = [double]$nl[1]*1000; $ny = [double]$nl[2]*1000; $nz = [double]$nl[3]*1000
  Write-Host ("max vonMises node $maxNode at (" + [math]::Round($nx,1) + ',' + [math]::Round($ny,1) + ',' + [math]::Round($nz,1) + ') mm')
  $locStr = [SwAsm]::LocatePoint($doc, $nx, $ny, $nz, 2.0)
  Write-Host ("  inside components:`n" + $locStr)
} catch { Write-Host ("node locate failed: " + $_.Exception.Message) }

# global FOS
$fosG = -1.0
try {
  $fres = [SwFea2]::MinMaxFOS($results, $true, $null)
  Write-Host ("FOS global err=" + $fres[1] + " raw=" + [SwFea2]::FmtArr($fres[0]))
  $fA = $fres[0]
  if ($fA -is [Array] -and $fA.Length -ge 2) { $fosG = [double]($fA | Measure-Object -Minimum | Select-Object -ExpandProperty Minimum) }
} catch { Write-Host ("FOS global failed: " + $_.Exception.Message) }

# FOS per component (weakest part)
try {
  $perComp = [SwAsm]::FOSByComponent($doc, $results)
  $perComp | Out-File -Encoding utf8 ($outDir + '\fos_bycomp_' + $Tag + '.txt')
  Write-Host ("FOS by component -> out\fos_bycomp_$Tag.txt")
  Write-Host $perComp
} catch { Write-Host ("FOS by comp failed: " + $_.Exception.Message) }

# CSV row
$row = [pscustomobject]@{
  tag=$Tag; mesher=$Mesher; quality=$Quality; max_mm=$MaxMM; min_mm=$MinMM;
  nodes=$nNode; elems=$nElem; vonMises_MPa=[math]::Round($vm,3); URES_mm=[math]::Round($disp,4);
  FOS_min=[math]::Round($fosG,2); mesh_s=[math]::Round($tMesh); solve_s=[math]::Round($tSolve);
  maxstress_comp=($locStr -replace "`r?`n",' / ').Trim()
}
$row | Export-Csv -Append -NoTypeInformation -Path ($outDir + '\conv_toanrobot.csv')
Write-Host ("CSV row appended: vonMises=" + [math]::Round($vm,2) + " MPa, URES=" + [math]::Round($disp,3) + " mm, FOSmin=" + [math]::Round($fosG,2))

# --- PLOT ---
if ($ExportPlot) {
  try {
    [void][SwRaw]::InvokeN($cwDoc,'AddDefaultStaticStudyPlot',@([int]1,[int]9))
    $results = [SwRaw]::Invoke0($study,'Results',$true)
    [void][SwRaw]::InvokeN($results,'ActivatePlot',@([string]'Stress1'))
    [void][SwRaw]::InvokeN($doc,'ShowNamedView2',@([string]'*Isometric',[int]7))
    [void][SwRaw]::InvokeN($doc,'ViewZoomtofit2',@())
    $bmp = $figDir + '\fea_toanrobot_vonMises.bmp'
    [void][SwRaw]::InvokeN($doc,'SaveBMP',@([string]$bmp,[int]1600,[int]1200))
    if (Test-Path $bmp) { Write-Host "plot -> $bmp" } else { Write-Host 'plot BMP NOT created' }
  } catch { Write-Host ("plot/export failed: " + $_.Exception.Message) }
}
Write-Host "=== done $Tag (NO SAVE) ==="
