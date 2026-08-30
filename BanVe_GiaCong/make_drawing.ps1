# make_drawing.ps1 - generate a machining drawing (TCVN/ISO first-angle, A3) for ONE part.
# Usage: powershell -File make_drawing.ps1 <PartFileName.SLDPRT> <scaleDenominator> <VietDescription>
param([string]$PartFile,[int]$Den=2,[string]$MoTa='')
. 'F:\DeltaRobot\MoPhong_Ben\fea_common.ps1'
$log="F:\DeltaRobot\BanVe_GiaCong\log_"+[IO.Path]::GetFileNameWithoutExtension($PartFile)+".txt"
Remove-Item $log -ErrorAction SilentlyContinue
function L($m){ $m | Out-File -FilePath $log -Append -Encoding utf8; Write-Host $m }
$sw=[System.Runtime.InteropServices.Marshal]::GetActiveObject('SldWorks.Application')

$partPath='F:\DeltaRobot\DeltaRobot_Final\'+$PartFile
$base=[IO.Path]::GetFileNameWithoutExtension($PartFile)
$drwPath='F:\DeltaRobot\BanVe_GiaCong\'+$base+'.SLDDRW'
$pdfPath='F:\DeltaRobot\BanVe_GiaCong\'+$base+'.pdf'
$tpl='D:\SOLIDWORKS\data\templates\iso.drwdot'
$fmt='C:\ProgramData\SolidWorks\SOLIDWORKS 2023\lang\english\sheetformat\a3 - iso.slddrt'

[SwRaw]::InvokeN($sw,'CloseAllDocuments',@($true)) | Out-Null

# open part, read props (material, mass), set custom props for title block
$rr=[SwRaw]::InvokeNRef2($sw,'OpenDoc6',@($partPath,1,1,''))
$part=$rr[0]; if(-not $part){$part=[SwRaw]::InvokeN($sw,'ActiveDoc',@())}
$pext=[SwRaw]::Invoke0($part,'Extension',$false)
$mat=''
try{ $mat=[SwRaw]::InvokeNRefVarLast($part,'GetMaterialPropertyName2',@(''))[1] }catch{}
if(-not $mat){ try{ $mat=[SwRaw]::InvokeN($part,'MaterialIdName',@()) }catch{} }
$mp=[SwRaw]::InvokeN($pext,'CreateMassProperty',@())
[double]$massKg=[SwRaw]::Invoke0($mp,'Mass',$false)
L ("part=$base material=$mat mass="+[math]::Round($massKg,3)+" kg")
$cp=[SwRaw]::InvokeN($pext,'CustomPropertyManager',@(''))
$KN=@('Description','Material','Weight','DrawnBy','DrawnDate','Title','CompanyName')
$wt=[math]::Round($massKg,2).ToString()+' kg'
$dt=Get-Date -Format 'dd/MM/yyyy'
$KV=@($MoTa,"$mat",$wt,'SV: 23134038',$dt,$MoTa,'HCMUTE - DO AN TOT NGHIEP')
for($ki=0;$ki -lt 7;$ki++){
  [string]$kn=$KN[$ki]; [string]$kvv=$KV[$ki]
  try{ [SwRaw]::InvokeN($cp,'Add3',@($kn,30,$kvv,1)) | Out-Null }catch{ L ("prop $kn err") }
}

# new drawing
$drw=[SwRaw]::InvokeN($sw,'NewDocument',@($tpl,8,0.42,0.297))   # 8 = A3
if(-not $drw){ L 'NewDocument FAILED'; exit 1 }
# A3, first-angle, scale 1:Den, iso format
$ok=[SwRaw]::InvokeN($drw,'SetupSheet5',@('Sheet1',8,12,1,$Den,$true,$fmt,0.42,0.297,'Default',$true))
L ("SetupSheet5(1:$Den, firstAngle)=$ok")
# force mm units (template defaults to IPS) + no reference parentheses
[SwRaw]::InvokeN($drw,'SetUserPreferenceIntegerValue',@(263,5)) | Out-Null    # swUnitSystem=MMGS
[SwRaw]::InvokeN($drw,'SetUserPreferenceToggle',@(48,$false)) | Out-Null      # no parentheses
L 'units=MMGS, parentheses off'

# standard 3 views (first angle) + isometric
$ok1=[SwRaw]::InvokeN($drw,'Create1stAngleViews2',@($partPath))
L ("Create1stAngleViews2=$ok1")
$vIso=[SwRaw]::InvokeN($drw,'CreateDrawViewFromModelView3',@($partPath,'*Isometric',0.34,0.235,0.0))
L ("iso view="+([bool]$vIso))
# force all views to sheet scale (Create1stAngleViews2 may keep model scale)
$sv0=[SwRaw]::InvokeN($drw,'GetFirstView',@())
$vv=[SwRaw]::InvokeN($sv0,'GetNextView',@())
while($vv){
  try{ [SwRaw]::PutProp($vv,'UseSheetScale',$true) }catch{}
  $vv=[SwRaw]::InvokeN($vv,'GetNextView',@())
}
[SwRaw]::InvokeN($drw,'EditRebuild3',@()) | Out-Null

# per-view: import model dims, hole callouts, then autodimension fallback
$dext0=[SwRaw]::Invoke0($drw,'Extension',$false)
$sheetV=[SwRaw]::InvokeN($drw,'GetFirstView',@())
$v=[SwRaw]::InvokeN($sheetV,'GetNextView',@())
$vi=0
while($v){
  $vn=[SwRaw]::Invoke0($v,'GetName2',$false)
  $got=0
  try{ $a1=[SwRaw]::InvokeN($v,'InsertModelAnnotations3',@(0,3,$true,$false,$false)); if($a1){$got=$got+@($a1).Count} }catch{}
  try{ $a2=[SwRaw]::InvokeN($v,'InsertModelAnnotations3',@(0,16,$true,$false,$false)); if($a2){$got=$got+@($a2).Count} }catch{}
  $nd=0
  try{ $nd=[SwRaw]::InvokeN($v,'GetDimensionCount4',@()) }catch{}
  if(($nd -lt 3) -and ($vi -lt 3)){
    [SwRaw]::InvokeN($drw,'ClearSelection2',@($true)) | Out-Null
    $selOK=[SwRaw]::InvokeN($dext0,'SelectByID2',@($vn,'DRAWINGVIEW',0.0,0.0,0.0,$false,0,[DBNull]::Value,0))
    $st=-1
    try{ $st=[SwRaw]::InvokeN($drw,'AutoDimension',@(0,2,-1,2,-1)) }catch{ L ('  AutoDimension EX '+$_.Exception.Message.Split([char]10)[0]) }
    try{ $nd=[SwRaw]::InvokeN($v,'GetDimensionCount4',@()) }catch{}
    # auto-arrange the freshly added dims of this view
    try{
      $dds=[SwRaw]::InvokeN($v,'GetDisplayDimensions',@())
      if($dds){
        [SwRaw]::InvokeN($drw,'ClearSelection2',@($true)) | Out-Null
        $first=$true
        foreach($dd in $dds){
          $ann=[SwRaw]::InvokeN($dd,'GetAnnotation',@())
          if($ann){ [SwRaw]::InvokeN($ann,'Select3',@((-not $first),[DBNull]::Value)) | Out-Null; $first=$false }
        }
        [SwRaw]::InvokeN($dext0,'AlignDimensions',@(0,0.008)) | Out-Null
      }
    }catch{ L ('  arrange err: '+$_.Exception.Message.Split([char]10)[0]) }
    L ("  autodim sel=$selOK status=$st")
  }
  L ("view $vn : inserted=$got dimCount=$nd")
  $v=[SwRaw]::InvokeN($v,'GetNextView',@())
  $vi++
}

$dext=[SwRaw]::Invoke0($drw,'Extension',$false)
$dcp=[SwRaw]::InvokeN($dext,'CustomPropertyManager',@(''))
for($ki=0;$ki -lt 7;$ki++){
  [string]$kn=$KN[$ki]; [string]$kvv=$KV[$ki]
  try{ [SwRaw]::InvokeN($dcp,'Add3',@($kn,30,$kvv,1)) | Out-Null }catch{}
}
# material/mass note (guaranteed info block, bottom-left)
$txt='CHI TIET: '+$MoTa+[char]10+'VAT LIEU: '+"$mat".Split('|')[1]+[char]10+'KHOI LUONG: '+[math]::Round($massKg,2)+' kg'+[char]10+'TI LE 1:'+$Den+'  -  DVT: mm  -  TCVN (chieu goc thu nhat)'
try{
  $note=[SwRaw]::InvokeN($drw,'InsertNote',@($txt))
  if($note){
    $ann=[SwRaw]::InvokeN($note,'GetAnnotation',@())
    if($ann){ [SwRaw]::InvokeN($ann,'SetPosition',@(0.155,0.030,0.0)) | Out-Null }
  }
  L 'note inserted'
}catch{ L ('note err: '+$_.Exception.Message.Split([char]10)[0]) }
[SwRaw]::InvokeN($drw,'ForceRebuild3',@($false)) | Out-Null
# count views
$sheetV=[SwRaw]::InvokeN($drw,'GetFirstView',@())
$nv=0; $v=[SwRaw]::InvokeN($sheetV,'GetNextView',@())
while($v){ $nv++; $v=[SwRaw]::InvokeN($v,'GetNextView',@()) }
L ("views on sheet: $nv (expect 4)")

# save + pdf
$sv=[SwRaw]::InvokeNRef2($drw,'SaveAs4',@($drwPath,0,2))
L ("save SLDDRW err="+$sv[1]+" warn="+$sv[2])
$sp=[SwRaw]::InvokeNRef2($drw,'SaveAs4',@($pdfPath,0,2))
L ("save PDF err="+$sp[1])
if(Test-Path $pdfPath){ L ("PDF size="+((Get-Item $pdfPath).Length)) } else { L 'PDF MISSING' }
# preview bmp
[SwRaw]::InvokeN($drw,'ViewZoomtofit2',@()) | Out-Null
Start-Sleep 1
[SwRaw]::InvokeN($drw,'SaveBMP',@(('F:\DeltaRobot\BanVe_GiaCong\prev_'+$base+'.bmp'),1600,1131)) | Out-Null
[SwRaw]::InvokeN($sw,'CloseAllDocuments',@($true)) | Out-Null
L 'DONEDRW'
