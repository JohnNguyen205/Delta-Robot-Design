# fea_run_v2.ps1 - like fea_run.ps1 but runs on a copy inside a target Folder and
# SAVES the part after solving so the FEA studies EMBED into the .SLDPRT (openable later).
param(
  [Parameter(Mandatory=$true)][string]$Part,
  [Parameter(Mandatory=$true)][int[]]$FixFaces,
  [Parameter(Mandatory=$true)][int[]]$LoadFaces,
  [Parameter(Mandatory=$true)][int]$RefFace,
  [Parameter(Mandatory=$true)][double[]]$Comp,
  [Parameter(Mandatory=$true)][double[]]$MeshSizes,
  [Parameter(Mandatory=$true)][double]$Yield,
  [Parameter(Mandatory=$true)][string]$Tag,
  [string]$Folder='F:\DeltaRobot\FEA_Simulation\MP_BEN_V2'
)
. 'F:\DeltaRobot\FEA_Simulation\fea_common.ps1'
$ErrorActionPreference = 'Stop'
$outDir = 'F:\DeltaRobot\FEA_Simulation\out'
$figDir = 'F:\DeltaRobot\FEA_Simulation\figs'

$sw = Connect-SW
$path = Join-Path $Folder $Part
$doc = Open-Part $sw $path
$base = [IO.Path]::GetFileNameWithoutExtension($Part)
Write-Host "=== FEA-V2 $base  tag=$Tag  folder=$Folder ==="
Write-Host ("Material: " + [SwRaw]::Invoke0($doc,'MaterialIdName',$true))

$cw    = Load-Sim $sw
[void][SwRaw]::InvokeNRefLast($sw,'ActivateDoc3',@([string]($base+'.SLDPRT'),$false,2))
$cwDoc = [SwRaw]::Invoke0($cw,'ActiveDoc',$true)
$sm    = [SwRaw]::Invoke0($cwDoc,'StudyManager',$true)

$study = $null
foreach ($sz in $MeshSizes) {
    $studyName = "conv_${Tag}_$([int]($sz*10))"
    try { [void][SwRaw]::InvokeN($sm,'DeleteStudy',@([string]$studyName)) } catch {}
    $r = [SwRaw]::InvokeNRefLast($sm,'CreateNewStudy2',@([string]$studyName,[int]0))
    $study = $r[0]
    if ($null -eq $study) { throw "CreateNewStudy2 null err=$($r[1])" }
    try { [void][SwRaw]::InvokeN($sm,'SetActiveStudy',@([int]([SwRaw]::Invoke0($sm,'StudyCount',$false)-1))) } catch {}

    $lrm = [SwRaw]::Invoke0($study,'LoadsAndRestraintsManager',$true)
    $fixArr = [SwGeom]::FacesArray($doc, $FixFaces)
    $rr = [SwFea]::AddFixed($lrm, $fixArr)
    if ($rr[1] -ne 0) { Write-Host "  WARN AddFixed err=$($rr[1])" }
    $ldArr  = [SwGeom]::FacesArray($doc, $LoadFaces)
    $refObj = [SwGeom]::FaceAt($doc, $RefFace)
    $fr = [SwFea]::AddForceDir($lrm, $ldArr, $refObj, [double]$Comp[0], [double]$Comp[1], [double]$Comp[2])
    if ($null -eq $fr[0]) { throw "AddForce null createErr=$($fr[1])" }

    $tol = [math]::Round($sz/20,4)
    [void][SwRaw]::InvokeN($study,'CreateMesh',@([int]0,[double]$sz,[double]$tol))
    $rc = [SwRaw]::InvokeN($study,'RunAnalysis',@())
    if ($rc -ne 0) { Write-Host "  RunAnalysis rc=$rc (size $sz) - skip"; continue }

    $results = [SwRaw]::Invoke0($study,'Results',$true)
    $sres = [SwRaw]::InvokeNRefLast($results,'GetMinMaxStress',@([int]9,[int]0,[int]1,[System.DBNull]::Value,[int]0))
    $vm = [double]$sres[0][3] / 1e6
    $fos = if ($vm -gt 0) { $Yield / $vm } else { 0 }
    Write-Host ("  size {0,5} mm : vonMises {1,8:F3} MPa  FOS {2,7:F1}" -f $sz,$vm,$fos)
}

# plot finest
try {
    [void][SwRaw]::InvokeN($cwDoc,'AddDefaultStaticStudyPlot',@([int]1,[int]9))
    $results = [SwRaw]::Invoke0($study,'Results',$true)
    [void][SwRaw]::InvokeN($results,'ActivatePlot',@([string]'Stress1'))
    [void][SwRaw]::InvokeN($doc,'ViewZoomtofit2',@())
} catch { Write-Host "  plot failed: $($_.Exception.Message)" }

# SAVE the part so the studies embed
[void][SwRaw]::InvokeN($doc,'ForceRebuild3',@($false))
$sv = [SwRaw]::InvokeNRef2($doc,'Save3',@(1))
Write-Host ("  SAVE embed studies err=" + $sv[1] + " warn=" + $sv[2])
# verify study count on disk copy
$n = [SwRaw]::Invoke0($sm,'StudyCount',$false)
Write-Host "=== done $Tag : StudyCount=$n, saved to $path ==="
