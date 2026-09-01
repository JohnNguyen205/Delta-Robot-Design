# fea_run.ps1 - static FEA mesh-convergence study for one part.
# Opens part, builds static study, fixture + directional force, loops mesh sizes,
# reads max von Mises + max URES disp, computes FOS = yield/vonMises, exports a
# von Mises plot BMP at the finest mesh, writes a convergence table. All read-back
# (evidence rule). See CLAUDE.md + memory deltarobot-assem1-findings for the recipe.
param(
  [Parameter(Mandatory=$true)][string]$Part,
  [Parameter(Mandatory=$true)][int[]]$FixFaces,
  [Parameter(Mandatory=$true)][int[]]$LoadFaces,
  [Parameter(Mandatory=$true)][int]$RefFace,
  [Parameter(Mandatory=$true)][double[]]$Comp,   # per-face (d1,d2,d3) rel. to ref face, Newton
  [Parameter(Mandatory=$true)][double[]]$MeshSizes,  # mm, coarse->fine
  [Parameter(Mandatory=$true)][double]$Yield,    # MPa
  [Parameter(Mandatory=$true)][string]$Tag,
  [switch]$Gravity,
  [double]$GravY = 11.58                          # +Y accel (m/s2) = 1.18g for base
)
. 'F:\DeltaRobot\FEA_Simulation\fea_common.ps1'
$ErrorActionPreference = 'Stop'
$outDir = 'F:\DeltaRobot\FEA_Simulation\out'
$figDir = 'F:\DeltaRobot\FEA_Simulation\figs'
foreach ($d in @($outDir,$figDir)) { if (!(Test-Path $d)) { New-Item -ItemType Directory -Force $d | Out-Null } }

$sw = Connect-SW
$path = Join-Path 'F:\DeltaRobot\DeltaRobot_Final' $Part
$doc = Open-Part $sw $path
$base = [IO.Path]::GetFileNameWithoutExtension($Part)
Write-Host "=== FEA $base  tag=$Tag ==="
Write-Host ("Material: " + [SwRaw]::Invoke0($doc,'MaterialIdName',$true))

$cw    = Load-Sim $sw
$cwDoc = [SwRaw]::Invoke0($cw,'ActiveDoc',$true)
$sm    = [SwRaw]::Invoke0($cwDoc,'StudyManager',$true)

$study = $null
foreach ($sz in $MeshSizes) {
    $studyName = "conv_${Tag}_$([int]($sz*10))"
    try { [void][SwRaw]::InvokeN($sm,'DeleteStudy',@([string]$studyName)) } catch {}
    $r = [SwRaw]::InvokeNRefLast($sm,'CreateNewStudy2',@([string]$studyName,[int]0))
    $study = $r[0]
    if ($null -eq $study) { throw "CreateNewStudy2 null err=$($r[1])" }
    # activate this study so cwDoc results/plots target it
    try { [void][SwRaw]::InvokeN($sm,'SetActiveStudy',@([int]([SwRaw]::Invoke0($sm,'StudyCount',$false)-1))) } catch {}

    $lrm = [SwRaw]::Invoke0($study,'LoadsAndRestraintsManager',$true)

    # --- fixture (typed cosworks interop) ---
    $fixArr = [SwGeom]::FacesArray($doc, $FixFaces)
    $rr = [SwFea]::AddFixed($lrm, $fixArr)
    if ($rr[1] -ne 0) { Write-Host "  WARN AddFixed err=$($rr[1])" }

    # --- directional force (needs ref face) ---
    $ldArr  = [SwGeom]::FacesArray($doc, $LoadFaces)
    $refObj = [SwGeom]::FaceAt($doc, $RefFace)
    $fr = [SwFea]::AddForceDir($lrm, $ldArr, $refObj, [double]$Comp[0], [double]$Comp[1], [double]$Comp[2])
    if ($null -eq $fr[0]) { throw "AddForce null createErr=$($fr[1])" }
    if ($fr[2] -ne 0) { Write-Host "  WARN ForceEndEdit err=$($fr[2])" }

    # --- mesh + solve ---
    $tol = [math]::Round($sz/20,4)
    [void][SwRaw]::InvokeN($study,'CreateMesh',@([int]0,[double]$sz,[double]$tol))
    $rc = [SwRaw]::InvokeN($study,'RunAnalysis',@())
    if ($rc -ne 0) { Write-Host "  RunAnalysis rc=$rc (size $sz) - skip"; continue }

    # --- read results ---
    $results = [SwRaw]::Invoke0($study,'Results',$true)
    $sres = [SwRaw]::InvokeNRefLast($results,'GetMinMaxStress',@([int]9,[int]0,[int]1,[System.DBNull]::Value,[int]0))
    $sArr = $sres[0]
    $vm = [double]$sArr[3] / 1e6   # Pa -> MPa
    $dres = [SwRaw]::InvokeNRefLast($results,'GetMinMaxDisplacement',@([int]3,[int]1,[System.DBNull]::Value,[int]0))
    $dArr = $dres[0]
    $disp = [double]$dArr[3] * 1000  # m -> mm
    # node/element count
    $nNode = 0; $nElem = 0
    try { $mesh = [SwRaw]::Invoke0($study,'Mesh',$true); $nNode = [SwRaw]::InvokeN($mesh,'GetNodeCount',@()); $nElem = [SwRaw]::InvokeN($mesh,'GetElementCount',@()) } catch {}
    $fos = if ($vm -gt 0) { $Yield / $vm } else { 0 }
    $row = [pscustomobject]@{ elem_mm=$sz; nodes=$nNode; elems=$nElem; vonMises_MPa=[math]::Round($vm,3); disp_mm=[math]::Round($disp,4); FOS=[math]::Round($fos,1) }
    Write-Host ("  size {0,5} mm : nodes {1,7} vonMises {2,8:F3} MPa  disp {3,7:F4} mm  FOS {4,7:F1}" -f $sz,$nNode,$vm,$disp,$fos)
    $row | Export-Csv -Append -NoTypeInformation -Path (Join-Path $outDir "conv_$Tag.csv")
}

# --- plot the finest mesh von Mises + export BMP ---
try {
    [void][SwRaw]::InvokeN($cwDoc,'AddDefaultStaticStudyPlot',@([int]1,[int]9))
    $results = [SwRaw]::Invoke0($study,'Results',$true)
    [void][SwRaw]::InvokeN($results,'ActivatePlot',@([string]'Stress1'))
    [void][SwRaw]::InvokeN($doc,'ViewZoomtofit2',@())
    $bmp = Join-Path $figDir "fea_${Tag}_vonMises.bmp"
    [void][SwRaw]::InvokeN($doc,'SaveBMP',@([string]$bmp,[int]1400,[int]1000))
    if (Test-Path $bmp) { Write-Host "  plot -> $bmp" }
} catch { Write-Host "  plot/export failed: $($_.Exception.Message)" }

Write-Host "=== done $Tag (table: $outDir\conv_$Tag.csv) ==="
