# make_drawing_v7.ps1 - balanced machining drawing copies.
# A3 landscape, first-angle projection, three dimensioned orthographic views,
# one clean isometric view, fixed 2x2 grid, custom Vietnamese title table, mm.
param(
  [string]$PartFile,
  [int]$Num=1,
  [int]$Den=2,
  [string]$MoTa='',
  [int]$DimViews=3,
  [string]$OutputDir='F:\DeltaRobot\BanVe_GiaCong\BanVe_ChinhSua_V7'
)
. 'F:\DeltaRobot\MoPhong_Ben\fea_common.ps1'
# typed helper for the title table
$IL_SW='D:\SOLIDWORKS\api\redist\SolidWorks.Interop.sldworks.dll'
$IL_CONST='D:\SOLIDWORKS\api\redist\SolidWorks.Interop.swconst.dll'
if(-not ('SwTbl' -as [type])){
Add-Type -ReferencedAssemblies @($IL_SW,$IL_CONST) -TypeDefinition @"
using System.Text;
using SolidWorks.Interop.sldworks;
using SolidWorks.Interop.swconst;
public static class SwTbl {
    // V8 (2026-07-23): khung ten dung bo cuc TCVN/khungten.png - 5 cot x 4 hang, 140x32mm.
    // Cot: A=20 B=30 C=15 D=40 E=35 (0-20/20-50/50-65/65-105/105-140).
    // Hang: R0-R3 = 8mm moi hang (0-8/8-16/16-24/24-32).
    // O (1) Tua bai = merge (0,3)-(1,4). O Truong/Lop = merge (2,0)-(3,2). O (2) Vat lieu = merge (2,3)-(3,3).
    public static object MakeTitleTableV8(object extObj, double x, double y,
        string tuaBai, string vatLieu, string tiLe, string kyHieu,
        string tenVe, string ngayVe, string tenKiemTra, string ngayKiemTra,
        string truongLop1, string truongLop2) {
        IModelDocExtension ext = (IModelDocExtension)extObj;
        TableAnnotation t = ext.InsertGeneralTableAnnotation(false, x, y, 1, "", 4, 5);
        if (t == null) return null;
        double[] colW = { 0.020, 0.030, 0.015, 0.040, 0.035 };
        double[] rowH = { 0.008, 0.008, 0.008, 0.008 };
        for (int c = 0; c < 5; c++) { t.SetColumnWidth(c, colW[c], 0); t.SetLockColumnWidth(c, true); }
        for (int r = 0; r < 4; r++) { t.SetRowHeight(r, rowH[r], 0); t.SetLockRowHeight(r, true); }
        try { t.TitleVisible = false; } catch { }
        t.set_Text(0, 0, "Nguoi ve");
        t.set_Text(1, 0, "Kiem tra");
        t.set_Text(0, 1, tenVe);
        t.set_Text(0, 2, ngayVe);
        t.set_Text(1, 1, tenKiemTra);
        t.set_Text(1, 2, ngayKiemTra == null ? "" : ngayKiemTra);
        t.set_Text(0, 3, tuaBai);
        t.set_Text(2, 0, truongLop1 + "\n" + truongLop2);
        t.set_Text(2, 3, vatLieu);
        t.set_Text(2, 4, tiLe);
        t.set_Text(3, 4, kyHieu);
        t.MergeCells(0, 3, 1, 4);
        t.MergeCells(2, 0, 3, 2);
        t.MergeCells(2, 3, 3, 3);
        // custom compact font so long text (name/ID) fits inside the narrow B column (30mm).
        try {
            TextFormat tf = t.GetTextFormat();
            tf.CharHeight = 0.0022;
            tf.WidthFactor = 0.8;
            t.SetTextFormat(false, tf);
        } catch { }
        for (int r = 0; r < 4; r++) {
            for (int c = 0; c < 5; c++) {
                try { t.set_CellTextHorizontalJustification(r, c, (int)swTextJustification_e.swTextJustificationCenter); } catch { }
                try { t.set_CellTextVerticalJustification(r, c, (int)swVerticalJustification_e.swVerticalJustificationMiddle); } catch { }
            }
        }
        return t;
    }
    // Evidence dump: column widths, row heights, merge map and text of every cell (mm).
    public static string DumpTable(object tblObj) {
        TableAnnotation t = (TableAnnotation)tblObj;
        int rc = t.RowCount; int cc = t.ColumnCount;
        double w = 0, h = 0;
        StringBuilder sb = new StringBuilder();
        for (int c = 0; c < cc; c++) w += t.GetColumnWidth(c);
        for (int r = 0; r < rc; r++) h += t.GetRowHeight(r);
        sb.AppendFormat("rows={0} cols={1} totalW={2:F2}mm totalH={3:F2}mm\n", rc, cc, w * 1000.0, h * 1000.0);
        for (int c = 0; c < cc; c++) sb.AppendFormat("colW[{0}]={1:F2}mm ", c, t.GetColumnWidth(c) * 1000.0);
        sb.Append("\n");
        for (int r = 0; r < rc; r++) sb.AppendFormat("rowH[{0}]={1:F2}mm ", r, t.GetRowHeight(r) * 1000.0);
        sb.Append("\n");
        for (int r = 0; r < rc; r++) {
            for (int c = 0; c < cc; c++) {
                int wr = r, wc = c;
                bool merged = false;
                try { merged = t.IsCellMerged(r, c, ref wr, ref wc); } catch { }
                string txt = "";
                try { txt = t.get_Text(r, c); } catch { }
                if (txt == null) txt = "";
                txt = txt.Replace("\n", "|");
                sb.AppendFormat("[{0},{1}] merged={2} text='{3}'\n", r, c, merged, txt);
            }
        }
        return sb.ToString();
    }
    // V8b (2026-07-23): kich thuoc chu ghi kich thuoc toi thieu 3.5mm + Bold, ap dung tung annotation
    // (dung dung mau chinh thuc cua SolidWorks cho "resize all dimension text": IAnnotation.GetTextFormat/
    // SetTextFormat line index 0). Tra ve [ok, beforeHeightMm, afterHeightMm, beforeBold, afterBold].
    public static object[] SetDimTextFormat(object annotationObj, double charHeightM, bool bold) {
        IAnnotation a = (IAnnotation)annotationObj;
        object beforeObj = null; TextFormat tf = null;
        double beforeH = -1; bool beforeB = false;
        try { beforeObj = a.GetTextFormat(0); tf = (TextFormat)beforeObj; beforeH = tf.CharHeight; beforeB = tf.Bold; } catch { }
        if (tf == null) return new object[] { false, beforeH, -1.0, beforeB, false };
        tf.CharHeight = charHeightM;
        tf.Bold = bold;
        bool ok = false;
        try { ok = a.SetTextFormat(0, false, tf); } catch { }
        double afterH = -1; bool afterB = false;
        try { object afterObj = a.GetTextFormat(0); TextFormat tf2 = (TextFormat)afterObj; afterH = tf2.CharHeight; afterB = tf2.Bold; } catch { }
        return new object[] { ok, beforeH, afterH, beforeB, afterB };
    }
    public static void SetAnnotationVisible(object annotationObj, bool visible) {
        IAnnotation a = (IAnnotation)annotationObj;
        // swAnnotationVisible = 1; swAnnotationHidden = 3.
        // Value 0 means "unknown" and can still be exported as visible.
        a.Visible = visible ? 1 : 3;
    }
    public static void SetAnnotationColor(object annotationObj, int color) {
        IAnnotation a = (IAnnotation)annotationObj;
        a.Color = color;
    }
}
"@
}
New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null
$log=Join-Path $OutputDir ("log_V7_"+[IO.Path]::GetFileNameWithoutExtension($PartFile)+".txt")
Remove-Item $log -ErrorAction SilentlyContinue
function L($m){ $m | Out-File -FilePath $log -Append -Encoding utf8; Write-Host $m }
$sw=Connect-SW

$partPath='F:\DeltaRobot\DeltaRobot_Final\'+$PartFile
$base=[IO.Path]::GetFileNameWithoutExtension($PartFile)
$drwPath=Join-Path $OutputDir ($base+'.SLDDRW')
$pdfPath=Join-Path $OutputDir ($base+'.pdf')
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
if(-not $matShort){ if($base -like 'DR-001*'){ $matShort='ASTM A36 Steel' } else { $matShort='6061-T6 (SS)' } }
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
# V8 (2026-07-23): TCVN 5705:1993 duoc xay dung tren co so ISO R129:1959 -> ep chuan ghi kich thuoc ve ISO
# (swDetailingDimensionStandard = 13; swDetailingStandardISO = 2) TRUOC AutoDimension.
$stdBefore=-1
try{ $stdBefore=[SwRaw]::InvokeN($drw,'GetUserPreferenceIntegerValue',@(13)) }catch{}
[SwRaw]::InvokeN($drw,'SetUserPreferenceIntegerValue',@(13,2)) | Out-Null
$stdAfter=-1
try{ $stdAfter=[SwRaw]::InvokeN($drw,'GetUserPreferenceIntegerValue',@(13)) }catch{}
L ("drafting standard (13=swDetailingDimensionStandard, 2=ISO): before=$stdBefore after=$stdAfter")
# Keep the PDF paper/background stable; individual released annotations are
# forced to black below instead of changing the global printer colour mode.
[SwRaw]::InvokeN($drw,'SetUserPreferenceToggle',@(323,$true)) | Out-Null

# khung vien A3 (TCVN 5705 / khungve.png): canh TRAI (gay dong, "d") = 25mm, 3 canh con lai ("c") = 10mm.
# ve NGAY BAY GIO khi sheet con TRONG (chua co view nao cuop sketch context)
[double]$bdL=0.025; [double]$bdR=0.410; [double]$bdB=0.010; [double]$bdT=0.287
try{
  $skm2=[SwRaw]::Invoke0($drw,'SketchManager',$false)
  [SwRaw]::PutProp($skm2,'AddToDB',$true)
  $bl=@()
  $bl+=[SwRaw]::InvokeN($skm2,'CreateLine',@($bdL,$bdB,0.0,$bdR,$bdB,0.0))
  $bl+=[SwRaw]::InvokeN($skm2,'CreateLine',@($bdR,$bdB,0.0,$bdR,$bdT,0.0))
  $bl+=[SwRaw]::InvokeN($skm2,'CreateLine',@($bdR,$bdT,0.0,$bdL,$bdT,0.0))
  $bl+=[SwRaw]::InvokeN($skm2,'CreateLine',@($bdL,$bdT,0.0,$bdL,$bdB,0.0))
  foreach($seg in $bl){ if($seg){ try{ [SwRaw]::PutProp($seg,'Color',0) }catch{} } }
  [SwRaw]::PutProp($skm2,'AddToDB',$false)
  [SwRaw]::InvokeN($drw,'ClearSelection2',@($true)) | Out-Null
  # doc lai toa do 4 dinh ngay sau khi ve = bang chung margin (mm tinh tu mep giay 0/0.42/0.297)
  $bp=@()
  foreach($seg in $bl){
    try{
      $sp=[SwRaw]::InvokeN($seg,'GetStartPoint2',@())
      $ep=[SwRaw]::InvokeN($seg,'GetEndPoint2',@())
      $spx=[double][SwRaw]::Invoke0($sp,'X',$true); $spy=[double][SwRaw]::Invoke0($sp,'Y',$true)
      $epx=[double][SwRaw]::Invoke0($ep,'X',$true); $epy=[double][SwRaw]::Invoke0($ep,'Y',$true)
      $bp+=("(" + [math]::Round($spx*1000,2) + "," + [math]::Round($spy*1000,2) + ")->(" + [math]::Round($epx*1000,2) + "," + [math]::Round($epy*1000,2) + ")")
    }catch{}
  }
  L ("border drawn (empty sheet). margins mm: left=" + [math]::Round($bdL*1000,1) + " right=" + [math]::Round((0.420-$bdR)*1000,1) + " top=" + [math]::Round((0.297-$bdT)*1000,1) + " bottom=" + [math]::Round($bdB*1000,1))
  L ("border segments (mm): " + ($bp -join ' | '))
}catch{ L ('border fail: '+$_.Exception.Message) }

# views
$ok1=[SwRaw]::InvokeN($drw,'Create1stAngleViews2',@($partPath))
L ("Create1stAngleViews2=$ok1")
$vIso=[SwRaw]::InvokeN($drw,'CreateDrawViewFromModelView3',@($partPath,'*Isometric',0.365,0.25,0.0))
$dext0=[SwRaw]::Invoke0($drw,'Extension',$false)
# V7 fixed grid. Each view owns one equal cell; the top row is lowered to leave
# a clear dimension corridor below the border. The title table ends at y=70 mm.
[double]$sc=$Num/[double]$Den
# V8 (2026-07-23): khung vien trai doi 10->25mm nen cot F/T (truoc cxF/cxT=112mm, hanh lang kich
# thuoc rong den x=20mm) duoc keo vao: hanh lang moi bat dau x=35mm, giu nguyen canh phai (x=204mm)
# -> tam o F/T dich tu 112 len 119.5mm. Cot S/Iso (312mm) khong doi (canh phai/tren/duoi khong doi).
[double]$cxF=0.1195; [double]$cyF=0.222
[double]$cxT=0.1195; [double]$cyT=0.122
[double]$cxS=0.312; [double]$cyS=0.222
[double]$cxIso=0.312; [double]$cyIso=0.122
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
L ("layout v7 equal grid: F=("+[math]::Round($cxF,3)+","+[math]::Round($cyF,3)+") S=("+[math]::Round($cxS,3)+","+[math]::Round($cyS,3)+") T=("+[math]::Round($cxT,3)+","+[math]::Round($cyT,3)+") ISO=("+[math]::Round($cxIso,3)+","+[math]::Round($cyIso,3)+") commonScale="+[math]::Round($sc,4))

# (khung vien da ve truoc khi tao view)

# V8 (2026-07-23): doc GetOutline tung view MOT LAN DUY NHAT moi view (quan trong - da phat hien qua
# thu nghiem: goi GetOutline LAN THU HAI tro len tren CUNG mot view trong cung phien lam viec tra ve
# gia tri "suy bien" min=max, du la lan goi dau tien tren view do hoan toan chinh xac; goi 1 lan duy
# nhat luon dung). Vi vay ca border-clear-correction LAN kiem tra chong-khung-ten deu dung chung
# MOT lan doc outline nay, khong doc lai lan thu hai.
function Get-ViewsList($drwObj){
  $arr=@(); $s0=[SwRaw]::InvokeN($drwObj,'GetFirstView',@()); $vv0=[SwRaw]::InvokeN($s0,'GetNextView',@())
  while($vv0){ $arr+=$vv0; $vv0=[SwRaw]::InvokeN($vv0,'GetNextView',@()) }
  return $arr
}
[double]$safeL=$bdL+0.003
$viewsChk=Get-ViewsList $drw
$vnames=@('F(view0)','T(view1)','S(view2)','ISO(view3)')
$outlines=@{}
for($k=0;$k -lt $viewsChk.Count;$k++){
  $ol=[SwRaw]::InvokeN($viewsChk[$k],'GetOutline',@())
  if($ol){ $outlines[$k]=$ol }
}
$maxDeficit=0.0
for($k=0;$k -lt 2;$k++){
  if($outlines.ContainsKey($k)){
    [double]$olxmin=$outlines[$k][0]
    $def=$safeL-$olxmin
    if($def -gt $maxDeficit){ $maxDeficit=$def }
    L ("pre-check view idx=$k outline xmin="+[math]::Round($olxmin*1000,2)+"mm (need >= "+[math]::Round($safeL*1000,2)+"mm)")
  }
}
if($maxDeficit -gt 0.0001){
  L ("border-clear correction: shifting F/T column right by "+[math]::Round($maxDeficit*1000,2)+"mm")
  $cxF=$cxF+$maxDeficit; $cxT=$cxT+$maxDeficit
  $sv0b=[SwRaw]::InvokeN($drw,'GetFirstView',@()); $vvb=[SwRaw]::InvokeN($sv0b,'GetNextView',@()); $vib=0
  while($vvb){
    if($vib -lt 2){
      $posb=New-Object 'double[]' 2
      if($vib -eq 0){$posb[0]=$cxF;$posb[1]=$cyF} else {$posb[0]=$cxT;$posb[1]=$cyT}
      try{ [SwRaw]::PutProp($vvb,'Position',$posb) }catch{}
    }
    $vvb=[SwRaw]::InvokeN($vvb,'GetNextView',@()); $vib++
  }
  [SwRaw]::InvokeN($drw,'EditRebuild3',@()) | Out-Null
  L ("post-correction F=("+[math]::Round($cxF,4)+","+[math]::Round($cyF,4)+") T=("+[math]::Round($cxT,4)+","+[math]::Round($cyT,4)+")")
  # shift is a pure rightward translation - update the F/T outlines analytically (deterministic,
  # avoids a second GetOutline call on the same views which would return degenerate data).
  foreach($k in @(0,1)){
    if($outlines.ContainsKey($k)){
      $o=$outlines[$k]
      $outlines[$k]=@(($o[0]+$maxDeficit),$o[1],($o[2]+$maxDeficit),$o[3])
    }
  }
}else{
  L 'border-clear check: F/T views already clear of left border, no correction needed'
}

# V8 (2026-07-23) FINAL OVERLAP CHECK - uses the SAME single outline reads captured above (right
# after final view positions were set, before dimensions/table are added): this is the reliable point
# for IView.GetOutline on this machine (repeat calls on the same view, or calls made after
# ForceRebuild3/SaveAs4/reopening the saved file, were found 2026-07-23 to intermittently return a
# degenerate zero-area box). Adding dimensions/a title table afterward does not move or resize a
# view's own outline (only its annotations), so this reflects the final, saved geometry correctly.
[double]$tblW=0.140; [double]$tblHfull=0.032
[double]$tblX=$bdR-$tblW
[double]$tblY=$bdB+$tblHfull
[double]$tXmin=$tblX; [double]$tXmax=$tblX+$tblW; [double]$tYmax=$tblY; [double]$tYmin=$tblY-$tblHfull
L ("FINAL OVERLAP CHECK titleTable target bbox(mm): x=["+[math]::Round($tXmin*1000,2)+","+[math]::Round($tXmax*1000,2)+"] y=["+[math]::Round($tYmin*1000,2)+","+[math]::Round($tYmax*1000,2)+"]")
$overlapAllPass=$true
for($k=0;$k -lt $viewsChk.Count;$k++){
  $nmk=if($k -lt $vnames.Length){$vnames[$k]}else{"view$k"}
  if(-not $outlines.ContainsKey($k)){ L ("FINAL OVERLAP CHECK "+$nmk+": GetOutline null"); $overlapAllPass=$false; continue }
  $ol=$outlines[$k]
  # NOTE: PowerShell variable names are case-INSENSITIVE - $oxm and $oxM would be the SAME variable
  # (this exact bug produced bogus "degenerate" min==max readings earlier in this session; use fully
  # distinct names: vLeft/vBottom/vRight/vTop).
  [double]$vLeft=$ol[0]; [double]$vBottom=$ol[1]; [double]$vRight=$ol[2]; [double]$vTop=$ol[3]
  $passBorder = ($vLeft -ge $bdL) -and ($vRight -le $bdR) -and ($vBottom -ge $bdB) -and ($vTop -le $bdT)
  $overlapsTable = -not (($vRight -le $tXmin) -or ($vLeft -ge $tXmax) -or ($vTop -le $tYmin) -or ($vBottom -ge $tYmax))
  $status = if($passBorder -and (-not $overlapsTable)){'PASS'}else{'FAIL'}
  if($status -ne 'PASS'){ $overlapAllPass=$false }
  L ("FINAL OVERLAP CHECK "+$nmk+" outline(mm)=["+[math]::Round($vLeft*1000,2)+","+[math]::Round($vBottom*1000,2)+" .. "+[math]::Round($vRight*1000,2)+","+[math]::Round($vTop*1000,2)+"] insideBorder="+$passBorder+" overlapsTitleTable="+$overlapsTable+" -> "+$status)
}
L ("FINAL OVERLAP CHECK overall: " + ($(if($overlapAllPass){'ALL PASS'}else{'SOME FAIL'})))

# V7 dimensions: dimension all three orthographic projections. The later filter
# keeps a small, non-repeating set per view; the isometric view remains clean.
$DimViews=3
$sv0=[SwRaw]::InvokeN($drw,'GetFirstView',@())
$v=[SwRaw]::InvokeN($sv0,'GetNextView',@())
$vi=0
while($v){
  $vn=[SwRaw]::Invoke0($v,'GetName2',$false)
  if($vi -lt $DimViews){
    [SwRaw]::InvokeN($drw,'ClearSelection2',@($true)) | Out-Null
    $selOK=[SwRaw]::InvokeN($dext0,'SelectByID2',@($vn,'DRAWINGVIEW',0.0,0.0,0.0,$false,0,[DBNull]::Value,0))
    $st=-1
    # Baseline scheme (1) leaves no orphaned ordinate datums after filtering.
    try{ $st=[SwRaw]::InvokeN($drw,'AutoDimension',@(0,1,1,1,-1)) }catch{}
    $nd=0; try{ $nd=[SwRaw]::InvokeN($v,'GetDimensionCount4',@()) }catch{}
    L ("view $vn dims=$nd (autodim status=$st)")
  }
  $v=[SwRaw]::InvokeN($v,'GetNextView',@())
  $vi++
}

# Keep a controlled set: diameters/radii and the most informative linear
# dimensions. Repeated values are shown only once across the three projections.
# V8b (2026-07-23): chieu cao chu kich thuoc toi thieu 3.5mm (ISO/TCVN 2.3.1 cho phep >=2.5mm nhung
# 2.5 qua nho de doc ro khi in) + Bold, ap dung tren TUNG display-dimension annotation (dung mau
# chinh thuc cua SolidWorks cho "resize all dimension text": IAnnotation.GetTextFormat/SetTextFormat
# line 0) - danh sach uu tien "cap document" (Document Properties > Detailing font) khong co API
# integer/double truc tiep trong swUserPreferenceIntegerValue_e; day la cach duoc SW chinh thuc dung.
[double]$dimCharH=0.0035
$fontFixCount=0; $fontSampleLog=@()
$sv0=[SwRaw]::InvokeN($drw,'GetFirstView',@())
$v=[SwRaw]::InvokeN($sv0,'GetNextView',@())
$vi=0; $nDel=0; $nKeep=0; $globalKeys=@{}
while($v){
  $dds=[SwRaw]::InvokeN($v,'GetDisplayDimensions',@())
  if($dds){
    $items=@()
    $sampleTaken=$false
    foreach($dd in $dds){
      try{
        $dim=[SwRaw]::InvokeN($dd,'GetDimension',@())
        [double]$val=([double][SwRaw]::Invoke0($dim,'SystemValue',$true))*1000.0
        $ann=[SwRaw]::InvokeN($dd,'GetAnnotation',@())
        if($ann){
          try{
            $ff=[SwTbl]::SetDimTextFormat($ann,$dimCharH,$true)
            if([bool]$ff[0]){ $fontFixCount++ }
            if(-not $sampleTaken){
              $fontSampleLog+=("view$vi sample dim: before H="+[math]::Round([double]$ff[1]*1000,2)+"mm bold="+$ff[3]+" -> after H="+[math]::Round([double]$ff[2]*1000,2)+"mm bold="+$ff[4]+" ok="+$ff[0])
              $sampleTaken=$true
            }
          }catch{}
        }
        $typ=-1
        try{$typ=[int][SwRaw]::Invoke0($dd,'Type2',$true)}catch{ try{$typ=[int][SwRaw]::InvokeN($dd,'GetType2',@())}catch{} }
        [double]$score=$val
        if(($typ -eq 5) -or ($typ -eq 6)){ $score=100000.0+$val }
        elseif($typ -eq 2){ $score=50000.0+$val }
        elseif([math]::Abs($val-[math]::Round($val)) -lt 0.021){ $score=20000.0+$val }
        $items+=New-Object PSObject -Property @{DD=$dd;Ann=$ann;Val=$val;Typ=$typ;Score=$score;Key=("$typ|"+[math]::Round($val,2));Keep=$false}
      }catch{}
    }
    $limit=if($vi -eq 0){4}else{3}
    if($base -like 'DR-001-*'){ $limit=if($vi -eq 1){2}else{3} }
    if($base -eq 'DR-006_Elbow-Clevis'){
      $limit=if($vi -eq 0){2}elseif($vi -eq 1){2}else{3}
    }
    if($base -eq 'DR-007_Moving-Platform'){
      $limit=if($vi -eq 0){2}elseif($vi -eq 1){3}else{1}
    }
    $keep=@{}
    foreach($it in ($items | Where-Object {$_.Val -ge 2.2} | Sort-Object Score -Descending)){
      if(($keep.Count -lt $limit) -and (-not $keep.ContainsKey($it.Key)) -and (-not $globalKeys.ContainsKey($it.Key))){
        $keep[$it.Key]=$true
        $globalKeys[$it.Key]=$true
        $it.Keep=$true
      }
    }
    foreach($it in $items){
      # Keep only the selected display-dimension instance. Patterned geometry can
      # expose several annotations with the same type/value key.
      $del=(($it.Val -lt 2.2) -or (-not [bool]$it.Keep))
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
    # xmin/xmax cua cot F/T bam theo $cxF (co the da duoc dich phai boi khoi border-clear correction o tren)
    [double]$fxmin=[math]::Max(0.035,$cxF-0.0845); [double]$fxmax=[math]::Min(0.215,$cxF+0.0845)
    if($vi -eq 0){$xmin=$fxmin;$xmax=$fxmax;$ymin=0.172;$ymax=0.274}
    elseif($vi -eq 1){$xmin=$fxmin;$xmax=$fxmax;$ymin=0.076;$ymax=0.168}
    elseif($vi -eq 2){$xmin=0.220;$xmax=0.404;$ymin=0.172;$ymax=0.274}
    else{$xmin=0.220;$xmax=0.404;$ymin=0.076;$ymax=0.168}
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
L ("dim filter v7: kept $nKeep hidden $nDel; dimensions distributed across three orthographic views")
L ("dim font V8b: charHeight target="+($dimCharH*1000)+"mm bold=true, applied to $fontFixCount display-dimension annotations")
foreach($sl in $fontSampleLog){ L ("  "+$sl) }

# V7 intentionally omits the former "KICH THUOC GIA CONG CHINH" text block.
# Manufacturing dimensions are carried by the three orthographic projections.

# khung ten V8 (2026-07-23): dung bo cuc khungten.png, 140x32mm, goc duoi-phai trong khung vien moi.
$scaleTxt="${Num}:${Den}"
$dt=Get-Date -Format 'dd/MM/yyyy'
$tuaBai=$base
$vatLieu=$matShort
$tiLe=($scaleTxt+' (A3)')
$kyHieu=$base
if($base -match '^(DR-\d+(-\d+)?)'){ $kyHieu=$Matches[1] }
$tenVe='NGUYEN VAN NAM - 23134038'
$ngayVe=$dt
$tenKiemTra='TS. VU QUANG HUY'
$ngayKiemTra=''
$truongLop1='TRUONG DAI HOC CONG NGHE KY THUAT TP.HCM'
$truongLop2='Nganh Robot and AI - Lop 23134A'
# table TopLeft-anchored at (tblX,tblY); width=140mm height=32mm -> bottom-right corner lands exactly
# on the border's bottom-right inner corner (bdR,bdB). tblW/tblX/tblY were already computed above
# (FINAL OVERLAP CHECK block) - reused here unchanged.
$tbl=[SwTbl]::MakeTitleTableV8($dext0,$tblX,$tblY,$tuaBai,$vatLieu,$tiLe,$kyHieu,$tenVe,$ngayVe,$tenKiemTra,$ngayKiemTra,$truongLop1,$truongLop2)
if($tbl){
  try{
    $tann=[SwRaw]::InvokeN($tbl,'GetAnnotation',@())
    if($tann){ [SwRaw]::InvokeN($tann,'SetPosition',@($tblX,$tblY,0.0)) | Out-Null }
  }catch{}
}
L ("title table v8: "+([bool]$tbl)+" anchored at ("+[math]::Round($tblX*1000,2)+","+[math]::Round($tblY*1000,2)+")mm, target 140x32mm, bottom-right should land at ("+[math]::Round($bdR*1000,2)+","+[math]::Round($bdB*1000,2)+")mm")
if($tbl){
  try{
    $dump=[SwTbl]::DumpTable($tbl)
    L "title table V8 dump:"
    L $dump
  }catch{ L ('title table dump fail: '+$_.Exception.Message) }
}

[SwRaw]::InvokeN($drw,'ForceRebuild3',@($false)) | Out-Null
$sv=[SwRaw]::InvokeNRef2($drw,'SaveAs4',@([string]$drwPath,[int]0,[int]2))
$sp=[SwRaw]::InvokeNRef2($drw,'SaveAs4',@([string]$pdfPath,[int]0,[int]2))
L ("save drw err="+$sv[1]+" pdf err="+$sp[1]+" pdfSize="+((Get-Item $pdfPath -ErrorAction SilentlyContinue).Length))
# V8 (2026-07-23): ViewZoomtofit2 was found to fit only the VIEWS' extent, cropping the title table
# (which reaches x=410mm, further right than any view) out of the .bmp preview. Zoom explicitly to
# the full physical sheet (0..0.42 x 0..0.297 m) with generous margin, box aspect matched to the
# 1600x1131 capture (1.4147) so ViewZoomTo2's own aspect-correction doesn't crop off the right edge.
[double]$zH=0.360; [double]$zW=$zH*(1600.0/1131.0)
[double]$zYmin=-0.03; [double]$zXmin=-((($zW-0.42)/2.0))
try{ [SwRaw]::InvokeN($drw,'ViewZoomTo2',@($zXmin,$zYmin,0.0,($zXmin+$zW),($zYmin+$zH),0.0)) | Out-Null }
catch{ [SwRaw]::InvokeN($drw,'ViewZoomtofit2',@()) | Out-Null }
Start-Sleep 1
$bmpPath=[string](Join-Path $OutputDir ('prev_V7_'+$base+'.bmp'))
[SwRaw]::InvokeN($drw,'SaveBMP',@($bmpPath,[int]1600,[int]1131)) | Out-Null
[SwRaw]::InvokeN($sw,'CloseAllDocuments',@($true)) | Out-Null
L ("TBL_TARGET x=" + $tblX + " y=" + $tblY + " w=" + $tblW + " h=" + $tblHfull)
L ("BORDER_TARGET L=" + $bdL + " R=" + $bdR + " T=" + $bdT + " B=" + $bdB)
L 'DONE2'
