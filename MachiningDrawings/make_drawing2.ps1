# make_drawing2.ps1 - v6 professional machining drawing.
# A3 landscape, first-angle projection, four views at ONE scale, fixed 2x2 grid,
# restrained dimensions, custom Vietnamese title table, mm.
param([string]$PartFile,[int]$Num=1,[int]$Den=2,[string]$MoTa='',[int]$DimViews=2)
. 'F:\DeltaRobot\FEA_Simulation\fea_common.ps1'
# typed helper for the title table
$IL_SW='D:\SOLIDWORKS\api\redist\SolidWorks.Interop.sldworks.dll'
$IL_CONST='D:\SOLIDWORKS\api\redist\SolidWorks.Interop.swconst.dll'
if(-not ('SwTbl' -as [type])){
Add-Type -ReferencedAssemblies @($IL_SW,$IL_CONST) -TypeDefinition @"
using SolidWorks.Interop.sldworks;
public static class SwTbl {
    public static object MakeTitleTable(object extObj, double x, double y, string[] left, string[] right) {
        IModelDocExtension ext = (IModelDocExtension)extObj;
        TableAnnotation t = ext.InsertGeneralTableAnnotation(false, x, y, 1, "", left.Length, 2);
        if (t == null) return null;
        for (int r = 0; r < left.Length; r++) {
            t.set_Text(r, 0, left[r]);
            t.set_Text(r, 1, right[r]);
        }
        t.SetColumnWidth(0, 0.048, 0);
        t.SetColumnWidth(1, 0.118, 0);
        for (int r = 0; r < left.Length; r++) t.SetRowHeight(r, 0.0065, 0);
        return t;
    }
    public static void SetAnnotationVisible(object annotationObj, bool visible) {
        IAnnotation a = (IAnnotation)annotationObj;
        a.Visible = visible ? 1 : 0;
    }
    public static void SetAnnotationColor(object annotationObj, int color) {
        IAnnotation a = (IAnnotation)annotationObj;
        a.Color = color;
    }
}
"@
}
$log="F:\DeltaRobot\MachiningDrawings\log2_"+[IO.Path]::GetFileNameWithoutExtension($PartFile)+".txt"
Remove-Item $log -ErrorAction SilentlyContinue
function L($m){ $m | Out-File -FilePath $log -Append -Encoding utf8; Write-Host $m }
$sw=Connect-SW

$partPath='F:\DeltaRobot\DeltaRobot_Final\'+$PartFile
$base=[IO.Path]::GetFileNameWithoutExtension($PartFile)
$drwPath='F:\DeltaRobot\MachiningDrawings\'+$base+'.SLDDRW'
$pdfPath='F:\DeltaRobot\MachiningDrawings\'+$base+'.pdf'
$tpl='D:\SOLIDWORKS\data\templates\iso.drwdot'
# v3 (2026-07-16): BO khung ten mac dinh SolidWorks — sheet trang, tu ve khung + bang ten rieng
$fmt=''

[SwRaw]::InvokeN($sw,'CloseAllDocuments',@($true)) | Out-Null
Remove-Item $drwPath,$pdfPath -ErrorAction SilentlyContinue

# part info
$rr=[SwRaw]::InvokeNRef2($sw,'OpenDoc6',@($partPath,1,1,''))
$part=$rr[0]; if(-not $part){$part=[SwRaw]::InvokeN($sw,'ActiveDoc',@())}
$pext=[SwRaw]::Invoke0($part,'Extension',$false)
$mat=''
try{ $mat=[SwRaw]::InvokeNRefVarLast($part,'GetMaterialPropertyName2',@(''))[1] }catch{}
$matShort="$mat"; if($matShort -match '\|'){ $matShort=$matShort.Split('|')[1] }
if(-not $matShort){ try{ $mat=[SwRaw]::InvokeNRefVarLast($part,'GetMaterialPropertyName2',@('Default'))[1]; $matShort="$mat"; if($matShort -match '\|'){$matShort=$matShort.Split('|')[1]} }catch{} }
if(-not $matShort){ $matShort='6061-T6 (SS)' }   # 2026-07-18: base switched steel->aluminium, all fabricated parts are 6061-T6 now
$mp=[SwRaw]::InvokeN($pext,'CreateMassProperty',@())
[double]$massKg=[SwRaw]::Invoke0($mp,'Mass',$false)
# part bbox (mm) for view layout
$bbW=100.0;$bbH=100.0;$bbD=100.0
try{
  $bodies=[SwRaw]::InvokeN($part,'GetBodies2',@(0,$true))
  $mnx=1e9;$mny=1e9;$mnz=1e9;$mxx=-1e9;$mxy=-1e9;$mxz=-1e9
  foreach($b in $bodies){
    $bx=[SwRaw]::InvokeN($b,'GetBodyBox',@())
    if(($bx[0]*1000) -lt $mnx){$mnx=$bx[0]*1000}; if(($bx[3]*1000) -gt $mxx){$mxx=$bx[3]*1000}
    if(($bx[1]*1000) -lt $mny){$mny=$bx[1]*1000}; if(($bx[4]*1000) -gt $mxy){$mxy=$bx[4]*1000}
    if(($bx[2]*1000) -lt $mnz){$mnz=$bx[2]*1000}; if(($bx[5]*1000) -gt $mxz){$mxz=$bx[5]*1000}
  }
  $bbW=$mxx-$mnx; $bbH=$mxy-$mny; $bbD=$mxz-$mnz
}catch{}
L ("part=$base mat=$matShort mass="+[math]::Round($massKg,3)+" bbox="+[math]::Round($bbW,0)+"x"+[math]::Round($bbH,0)+"x"+[math]::Round($bbD,0))

# v6: all four views use the same standard scale.  The map was verified against
# the actual view outlines; the large/long parts need the smaller scales to leave
# a dimension corridor around every cell.
$scaleMap=@{
  'DR-001_Base-Plate'        = @(1,10)
  'DR-002_Motor-Bracket-A'   = @(1,4)
  'DR-003_Motor-Bracket-B'   = @(1,4)
  'DR-004_Shoulder-Bracket'  = @(1,1)
  'DR-005-1_Upper-Arm-Hub'   = @(1,4)
  'DR-005-2_Upper-Arm-Link'  = @(1,5)
  'DR-006_Elbow-Clevis'      = @(1,4)
  'DR-007_Moving-Platform'   = @(1,4)
  'DR-001-1_De-Gan-Tay'      = @(1,10)
  'DR-001-2_Khung-Han'       = @(1,10)
  'DR-001-3_Mat-Treo'        = @(1,10)
}
if($scaleMap.ContainsKey($base)){
  $Num=[int]$scaleMap[$base][0]; $Den=[int]$scaleMap[$base][1]
} else {
  $Num=1; $Den=5
}
L ("professional scale v6 -> ${Num}:${Den} (same for all 4 views)")

# new drawing
$drw=[SwRaw]::InvokeN($sw,'NewDocument',@($tpl,8,0.42,0.297))
if(-not $drw){ L 'NewDocument FAILED'; exit 1 }
$ok=[SwRaw]::InvokeN($drw,'SetupSheet5',@('Sheet1',8,12,$Num,$Den,$true,$fmt,0.42,0.297,'Default',$true))
L ("SetupSheet5 ${Num}:${Den} firstAngle fmt=BLANK -> $ok")
[SwRaw]::InvokeN($drw,'SetUserPreferenceIntegerValue',@(263,5)) | Out-Null
[SwRaw]::InvokeN($drw,'SetUserPreferenceToggle',@(48,$false)) | Out-Null
# Keep the PDF paper/background stable; individual released annotations are
# forced to black below instead of changing the global printer colour mode.
[SwRaw]::InvokeN($drw,'SetUserPreferenceToggle',@(323,$true)) | Out-Null

# khung vien A3: ve NGAY BAY GIO khi sheet con TRONG (chua co view nao cuop sketch context)
try{
  $skm2=[SwRaw]::Invoke0($drw,'SketchManager',$false)
  [SwRaw]::PutProp($skm2,'AddToDB',$true)
  $bl=@()
  $bl+=[SwRaw]::InvokeN($skm2,'CreateLine',@(0.010,0.010,0.0,0.410,0.010,0.0))
  $bl+=[SwRaw]::InvokeN($skm2,'CreateLine',@(0.410,0.010,0.0,0.410,0.287,0.0))
  $bl+=[SwRaw]::InvokeN($skm2,'CreateLine',@(0.410,0.287,0.0,0.010,0.287,0.0))
  $bl+=[SwRaw]::InvokeN($skm2,'CreateLine',@(0.010,0.287,0.0,0.010,0.010,0.0))
  foreach($seg in $bl){ if($seg){ try{ [SwRaw]::PutProp($seg,'Color',0) }catch{} } }
  [SwRaw]::PutProp($skm2,'AddToDB',$false)
  [SwRaw]::InvokeN($drw,'ClearSelection2',@($true)) | Out-Null
  L 'border drawn (empty sheet)'
}catch{ L ('border fail: '+$_.Exception.Message) }

# views
$ok1=[SwRaw]::InvokeN($drw,'Create1stAngleViews2',@($partPath))
L ("Create1stAngleViews2=$ok1")
$vIso=[SwRaw]::InvokeN($drw,'CreateDrawViewFromModelView3',@($partPath,'*Isometric',0.365,0.25,0.0))
$dext0=[SwRaw]::Invoke0($drw,'Extension',$false)
# v6 fixed grid.  Each view owns one cell, so projection alignment and white
# space are consistent across all eight sheets.  The title table ends at y=70 mm.
[double]$sc=$Num/[double]$Den
[double]$cxF=0.115; [double]$cyF=0.238
[double]$cxT=0.115; [double]$cyT=0.137
[double]$cxS=0.315; [double]$cyS=0.238
[double]$cxIso=0.315; [double]$cyIso=0.137
[double]$isoSc=$sc
$sv0=[SwRaw]::InvokeN($drw,'GetFirstView',@())
$vv=[SwRaw]::InvokeN($sv0,'GetNextView',@())
$vi=0
while($vv){
  try{ [SwRaw]::PutProp($vv,'UseSheetScale',$false) }catch{}
  if($vi -lt 3){
    try{ [SwRaw]::PutProp($vv,'ScaleDecimal',$sc) }catch{}
    $pos=New-Object 'double[]' 2
    if($vi -eq 0){ $pos[0]=$cxF; $pos[1]=$cyF }
    elseif($vi -eq 1){ $pos[0]=$cxF; $pos[1]=$cyT }
    else { $pos[0]=$cxS; $pos[1]=$cyS }
    try{ [SwRaw]::PutProp($vv,'Position',$pos) }catch{ L ('pos put err v'+$vi) }
  } else {
    try{
      [SwRaw]::PutProp($vv,'ScaleDecimal',$isoSc)
      $pos=New-Object 'double[]' 2
      $pos[0]=$cxIso; $pos[1]=$cyIso
      [SwRaw]::PutProp($vv,'Position',$pos)
    }catch{}
  }
  $vv=[SwRaw]::InvokeN($vv,'GetNextView',@())
  $vi++
}
[SwRaw]::InvokeN($drw,'EditRebuild3',@()) | Out-Null
L ("layout v6 grid: F=("+[math]::Round($cxF,3)+","+[math]::Round($cyF,3)+") S=("+[math]::Round($cxS,3)+","+[math]::Round($cyS,3)+") T=("+[math]::Round($cxT,3)+","+[math]::Round($cyT,3)+") ISO=("+[math]::Round($cxIso,3)+","+[math]::Round($cyIso,3)+") commonScale="+[math]::Round($sc,4))

# (khung vien da ve truoc khi tao view)

# v6 dimensions: only the views that add machining information.  Complex circular
# parts use one dimensioned principal view plus the remaining clean projections.
$dimViewMap=@{
  'DR-001_Base-Plate'=0; 'DR-002_Motor-Bracket-A'=2; 'DR-003_Motor-Bracket-B'=1
  'DR-004_Shoulder-Bracket'=0; 'DR-005-1_Upper-Arm-Hub'=1
  'DR-005-2_Upper-Arm-Link'=1; 'DR-006_Elbow-Clevis'=1
  'DR-007_Moving-Platform'=0
  'DR-001-1_De-Gan-Tay'=1; 'DR-001-2_Khung-Han'=1; 'DR-001-3_Mat-Treo'=1
}
if($dimViewMap.ContainsKey($base)){ $DimViews=[int]$dimViewMap[$base] }
$sv0=[SwRaw]::InvokeN($drw,'GetFirstView',@())
$v=[SwRaw]::InvokeN($sv0,'GetNextView',@())
$vi=0
while($v){
  $vn=[SwRaw]::Invoke0($v,'GetName2',$false)
  if($vi -lt $DimViews){
    [SwRaw]::InvokeN($drw,'ClearSelection2',@($true)) | Out-Null
    $selOK=[SwRaw]::InvokeN($dext0,'SelectByID2',@($vn,'DRAWINGVIEW',0.0,0.0,0.0,$false,0,[DBNull]::Value,0))
    $st=-1
    # Ordinate scheme (2) is the least ambiguous option for these profiles.
    try{ $st=[SwRaw]::InvokeN($drw,'AutoDimension',@(0,2,-1,2,-1)) }catch{}
    $nd=0; try{ $nd=[SwRaw]::InvokeN($v,'GetDimensionCount4',@()) }catch{}
    L ("view $vn dims=$nd (autodim status=$st)")
  }
  $v=[SwRaw]::InvokeN($v,'GetNextView',@())
  $vi++
}

# Keep a controlled set: diameters/radii and the most informative large or round
# linear dimensions.  This removes the coordinate forest produced by AutoDimension.
$sv0=[SwRaw]::InvokeN($drw,'GetFirstView',@())
$v=[SwRaw]::InvokeN($sv0,'GetNextView',@())
$vi=0; $nDel=0; $nKeep=0
while($v){
  $dds=[SwRaw]::InvokeN($v,'GetDisplayDimensions',@())
  if($dds){
    $items=@()
    foreach($dd in $dds){
      try{
        $dim=[SwRaw]::InvokeN($dd,'GetDimension',@())
        [double]$val=([double][SwRaw]::Invoke0($dim,'SystemValue',$true))*1000.0
        $ann=[SwRaw]::InvokeN($dd,'GetAnnotation',@())
        $typ=-1
        try{$typ=[int][SwRaw]::Invoke0($dd,'Type2',$true)}catch{ try{$typ=[int][SwRaw]::InvokeN($dd,'GetType2',@())}catch{} }
        [double]$score=$val
        if(($typ -eq 5) -or ($typ -eq 6)){ $score=100000.0+$val }
        elseif($typ -eq 2){ $score=50000.0+$val }
        elseif([math]::Abs($val-[math]::Round($val)) -lt 0.021){ $score=20000.0+$val }
        $items+=New-Object PSObject -Property @{DD=$dd;Ann=$ann;Val=$val;Typ=$typ;Score=$score;Key=("$typ|"+[math]::Round($val,2))}
      }catch{}
    }
    $limit=10
    if($base -eq 'DR-001_Base-Plate'){ $limit=8 }
    if($base -eq 'DR-007_Moving-Platform'){ $limit=6 }
    if($base -like 'DR-001-*'){ $limit=8 }
    $keep=@{}
    foreach($it in ($items | Where-Object {$_.Val -ge 2.2} | Sort-Object Score -Descending)){
      if(($keep.Count -lt $limit) -and (-not $keep.ContainsKey($it.Key))){ $keep[$it.Key]=$true }
    }
    foreach($it in $items){
      $del=(($it.Val -lt 2.2) -or (-not $keep.ContainsKey($it.Key)))
      if($del){
        try{
          if($it.Ann){
            # AutoDimension ordinate chains are not reliably deletable one label at
            # a time.  Hiding the unwanted annotation is deterministic and keeps
            # the remaining manufacturing dimensions associative to the model.
            [SwTbl]::SetAnnotationVisible($it.Ann,$false)
            $nDel++
          }
        }catch{}
      } else { $nKeep++ }
    }
  }

  # Put annotations inside their own view cell.  A two-pass layout distributes
  # left/right text vertically and above/below text horizontally, avoiding the
  # stacked labels produced by SolidWorks' default ordinate placement.
  try{
    $outline=[SwRaw]::InvokeN($v,'GetOutline',@())
    if($vi -eq 0){$xmin=0.018;$xmax=0.212;$ymin=0.195;$ymax=0.282}
    elseif($vi -eq 1){$xmin=0.018;$xmax=0.212;$ymin=0.075;$ymax=0.192}
    elseif($vi -eq 2){$xmin=0.215;$xmax=0.407;$ymin=0.195;$ymax=0.282}
    else{$xmin=0.215;$xmax=0.407;$ymin=0.075;$ymax=0.192}
    $groups=@{left=@();right=@();above=@();below=@();inside=@()}
    $dds2=[SwRaw]::InvokeN($v,'GetDisplayDimensions',@())
    if($dds2){ foreach($dd2 in $dds2){
      $ann2=[SwRaw]::InvokeN($dd2,'GetAnnotation',@())
      if(-not $ann2){continue}
      try{[SwTbl]::SetAnnotationColor($ann2,0)}catch{}
      $p=[SwRaw]::InvokeN($ann2,'GetPosition',@()); if(-not $p){continue}
      [double]$px=$p[0]; [double]$py=$p[1]
      $side='inside'
      if($px -lt $outline[0]){$side='left'} elseif($px -gt $outline[2]){$side='right'} elseif($py -gt $outline[3]){$side='above'} elseif($py -lt $outline[1]){$side='below'}
      $groups[$side]+=(New-Object PSObject -Property @{Ann=$ann2;X=$px;Y=$py})
    }}
    foreach($side in @('left','right')){
      $arr=@($groups[$side] | Sort-Object Y); $cnt=$arr.Count
      for($k=0;$k -lt $cnt;$k++){
        [double]$yy=if($cnt -le 1){($ymin+$ymax)/2.0}else{$ymin+0.010+($k*(($ymax-$ymin-0.020)/($cnt-1)))}
        [double]$xx=if($side -eq 'left'){[math]::Max($xmin,[double]$outline[0]-0.012)}else{[math]::Min($xmax,[double]$outline[2]+0.012)}
        [SwRaw]::InvokeN($arr[$k].Ann,'SetPosition',@($xx,$yy,0.0)) | Out-Null
      }
    }
    foreach($side in @('above','below')){
      $arr=@($groups[$side] | Sort-Object X); $cnt=$arr.Count
      for($k=0;$k -lt $cnt;$k++){
        [double]$xx=if($cnt -le 1){($xmin+$xmax)/2.0}else{$xmin+0.012+($k*(($xmax-$xmin-0.024)/($cnt-1)))}
        [double]$yy=if($side -eq 'above'){[math]::Min($ymax,[double]$outline[3]+0.012)}else{[math]::Max($ymin,[double]$outline[1]-0.012)}
        [SwRaw]::InvokeN($arr[$k].Ann,'SetPosition',@($xx,$yy,0.0)) | Out-Null
      }
    }
    foreach($it2 in $groups.inside){
      [double]$xx=[math]::Min($xmax,[math]::Max($xmin,[double]$it2.X))
      [double]$yy=[math]::Min($ymax,[math]::Max($ymin,[double]$it2.Y))
      [SwRaw]::InvokeN($it2.Ann,'SetPosition',@($xx,$yy,0.0)) | Out-Null
    }
  }catch{ L ('dim arrange warning view '+$vi+': '+$_.Exception.Message.Split([char]10)[0]) }
  $v=[SwRaw]::InvokeN($v,'GetNextView',@())
  $vi++
}
[SwRaw]::InvokeN($drw,'ClearSelection2',@($true)) | Out-Null
L ("dim filter v6: kept $nKeep deleted $nDel; all annotations clamped to cells")

# Circular/multi-pattern parts are clearer with a concise machining-feature note
# than with dozens of Cartesian coordinates.  Curved freeform boundaries are
# controlled by the released 3D model.
$featureNotes=@{
  'DR-001_Base-Plate' = "KICH THUOC GIA CONG CHINH (mm):`nLO GIUA: D150 THONG.`n9x M16 (KHOAN D14 x25); 6x M20 (KHOAN D17.5 x25), R260.`nBIEN DANG CONG THEO MODEL 3D; DUNG SAI CHUNG ISO 2768-mK."
  'DR-004_Shoulder-Bracket' = "KICH THUOC GIA CONG CHINH (mm):`nMAT BICH D58; BAC DINH TAM D31.5.`n8x M2.5: LO THONG D2.6, BAC D5 x5, PCD D48.`nPHA BA VIA; DUNG SAI CHUNG ISO 2768-mK."
  'DR-007_Moving-Platform' = "KICH THUOC GIA CONG CHINH (mm):`nMOAY-O: D200 / D160 / D140 / D80.`n6x D12 DEU TREN PCD D110; 3 VI TRI THANH TRUYEN R120.50 CACH 120 deg.`nBIEN DANG 3 CANH THEO MODEL 3D; DUNG SAI CHUNG ISO 2768-mK."
}
if($featureNotes.ContainsKey($base)){
  try{
    $note=[SwRaw]::InvokeN($drw,'InsertNote',@([string]$featureNotes[$base]))
    if($note){
      $nann=[SwRaw]::InvokeN($note,'GetAnnotation',@())
      if($nann){
        [SwRaw]::InvokeN($nann,'SetPosition',@(0.022,0.270,0.0)) | Out-Null
        try{[SwTbl]::SetAnnotationColor($nann,0)}catch{}
      }
      L 'feature note inserted (complex pattern part)'
    }
  }catch{ L ('feature note warning: '+$_.Exception.Message.Split([char]10)[0]) }
}

# khung ten rieng - goc duoi phai, trong khung vien
$scaleTxt="${Num}:${Den}"
$dt=Get-Date -Format 'dd/MM/yyyy'
$leftC =@('BAN VE','CHI TIET','VAT LIEU','KHOI LUONG','TI LE','DON VI','NGUOI VE','NGAY VE','TRUONG')
$rightC=@($base,$MoTa,$matShort,([math]::Round($massKg,2).ToString()+' kg'),($scaleTxt+'  (A3)'),'mm - TCVN chieu goc thu nhat','NGUYEN VAN NAM - 23134038',$dt,'HCMUTE - DO AN TOT NGHIEP')
[double]$tblH=$leftC.Length*0.0065
[double]$tblX=0.410-0.166-0.003
[double]$tblY=0.012+$tblH
$tbl=[SwTbl]::MakeTitleTable($dext0,$tblX,$tblY,$leftC,$rightC)
if($tbl){
  try{
    $tann=[SwRaw]::InvokeN($tbl,'GetAnnotation',@())
    if($tann){ [SwRaw]::InvokeN($tann,'SetPosition',@($tblX,$tblY,0.0)) | Out-Null }
  }catch{}
}
L ("title table v3: "+([bool]$tbl)+" at ("+[math]::Round($tblX,3)+","+[math]::Round($tblY,3)+")")

[SwRaw]::InvokeN($drw,'ForceRebuild3',@($false)) | Out-Null
$sv=[SwRaw]::InvokeNRef2($drw,'SaveAs4',@($drwPath,0,2))
$sp=[SwRaw]::InvokeNRef2($drw,'SaveAs4',@($pdfPath,0,2))
L ("save drw err="+$sv[1]+" pdf err="+$sp[1]+" pdfSize="+((Get-Item $pdfPath -ErrorAction SilentlyContinue).Length))
[SwRaw]::InvokeN($drw,'ViewZoomtofit2',@()) | Out-Null
Start-Sleep 1
[SwRaw]::InvokeN($drw,'SaveBMP',@(('F:\DeltaRobot\MachiningDrawings\prev_'+$base+'.bmp'),1600,1131)) | Out-Null
[SwRaw]::InvokeN($sw,'CloseAllDocuments',@($true)) | Out-Null
L 'DONE2'
