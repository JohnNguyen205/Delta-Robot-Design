# 01_probe.ps1 — validate toolchain: connect, open a part, load Simulation, dump faces.
param([string]$Part = 'DR-006_Elbow-Clevis.SLDPRT')
. 'F:\DeltaRobot\FEA_Simulation\fea_common.ps1'

$sw = Connect-SW
Write-Host ("SW rev: " + [SwRaw]::Invoke0($sw,'RevisionNumber',$false))

$path = Join-Path 'F:\DeltaRobot\DeltaRobot_Final' $Part
$doc = Open-Part $sw $path
$title = [SwRaw]::Invoke0($doc,'GetTitle',$false)
$mat   = [SwRaw]::Invoke0($doc,'MaterialIdName',$true)
Write-Host "Opened: $title"
Write-Host "Material: $mat"

# mass/volume
$ext = [SwRaw]::Invoke0($doc,'Extension',$true)
$mp  = [SwRaw]::InvokeN($ext,'CreateMassProperty',@())
if ($mp) {
    $mass = [SwRaw]::Invoke0($mp,'Mass',$true)
    $vol  = [SwRaw]::Invoke0($mp,'Volume',$true)
    Write-Host ("Mass={0:F3} kg  Volume={1:F1} cm3" -f $mass, ($vol*1e6))
}

# Simulation add-in
$cw = Load-Sim $sw
Write-Host ("CosmosWorks ver: " + [SwRaw]::Invoke0($cw,'VersionNumber',$false))

# face dump
$dump = [SwGeom]::DumpFaces($doc)
$outDir = 'F:\DeltaRobot\FEA_Simulation\out'
if (!(Test-Path $outDir)) { New-Item -ItemType Directory -Force $outDir | Out-Null }
$outFile = Join-Path $outDir ("faces_" + [IO.Path]::GetFileNameWithoutExtension($Part) + ".txt")
$dump | Out-File -Encoding utf8 $outFile
$nFaces = ($dump -split "`n" | Where-Object { $_ -match '^F\d' }).Count
Write-Host "Faces: $nFaces  (written to $outFile)"
Write-Host "--- planes & cylinders (first 60) ---"
($dump -split "`n" | Where-Object { $_ -match '(plane|cyl)' } | Select-Object -First 60) -join "`n"
