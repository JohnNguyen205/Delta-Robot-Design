# KIEM TRA BO BAN VE GIA CONG V7

Ngay kiem tra: 17/07/2026

Thu muc ban chinh sua: `F:\DeltaRobot\BanVe_GiaCong\BanVe_ChinhSua_V7`

## Noi dung da thuc hien

- Tao ban sao, khong ghi de file goc trong `F:\DeltaRobot\BanVe_GiaCong`.
- Bo khoi ghi chu `KICH THUOC GIA CONG CHINH` khoi vung hinh ve.
- Chuyen sang so do kich thuoc baseline va phan bo kich thuoc tren ba hinh chieu vuong goc.
- Giu hinh truc do 3D sach, khong dat kich thuoc.
- Loc kich thuoc nho, trung gia tri va trung instance; chi giu cac kich thuoc doc lap can thiet.
- Bo tri bon hinh tren luoi 2x2 A3 ngang, can deu khoang cach va tach khoi khung ten.

## Ket qua xuat va kiem tra truc quan

| Ban ve | SLDDRW | PDF | Kich thuoc tren 3 hinh chieu | Khong chong chu | Khong vuot khung |
|---|---:|---:|---:|---:|---:|
| DR-001-1_De-Gan-Tay | Dat | Dat | Dat | Dat | Dat |
| DR-001-2_Khung-Han | Dat | Dat | Dat | Dat | Dat |
| DR-001-3_Mat-Treo | Dat | Dat | Dat | Dat | Dat |
| DR-002_Motor-Bracket-A | Dat | Dat | Dat | Dat | Dat |
| DR-003_Motor-Bracket-B | Dat | Dat | Dat | Dat | Dat |
| DR-004_Shoulder-Bracket | Dat | Dat | Dat | Dat | Dat |
| DR-005-1_Upper-Arm-Hub | Dat | Dat | Dat | Dat | Dat |
| DR-005-2_Upper-Arm-Link | Dat | Dat | Dat | Dat | Dat |
| DR-006_Elbow-Clevis | Dat | Dat | Dat | Dat | Dat |
| DR-007_Moving-Platform | Dat | Dat | Dat | Dat | Dat |

Tong cong: 10 PDF, 10 SLDDRW, 10 log; tat ca log co `save drw err=0 pdf err=0` va `DONE2`.

## Luu y

Ban V7 chinh sua cach trinh bay ban ve, khong sua hinh hoc part nguon. Truoc khi phat hanh gia cong, nguoi phu trach cong nghe van nen xac nhan cac dung sai rieng, chuan dat va yeu cau be mat theo quy trinh cua xuong.

## Cap nhat 23/07/2026 - sua 2 loi khung ve/khung ten + tang co chu kich thuoc

Doi chieu voi `F:\DeltaRobot\Fomat\Rule_BanVe\khungve.png`, `khungten.png` va PDF TCVN 5705:1993
(muc luc dan chieu ISO R129:1959) phat hien 2 loi trong bo V7 cu, cong them 1 yeu cau bo sung ve co
chu kich thuoc, ca 3 da duoc sua trong CUNG mot lan chay lai script (`make_drawing_v7.ps1`), khong chay
lai rieng tung phan.

**Loi 1 - Khung vien sai margin.** Ban cu ve khung vien cach deu 10mm ca 4 canh. Theo `khungve.png`
(bang tra c/d cho khung A0-A4 nam ngang), canh TRAI (phia gay dong, ky hieu "d") phai = 25mm, 3 canh
con lai (tren/phai/duoi, ky hieu "c") = 10mm. Da sua: khung vien moi ve tai (25,10)-(410,10)-(410,287)-
(25,287) mm tren sheet A3 420x297mm. Vi khung trai dich vao 15mm, cot hinh chieu F/T (truoc o x=112mm)
duoc thu hep hanh lang kich thuoc va dich tam sang x=~119.5-121mm de khong lan khung; co kiem tra tu
dong qua `GetOutline` va tu dich them neu thieu (chua part nao can dich thuc te trong 10 part).

**Loi 2 - Khung ten sai hoan toan bo cuc.** Ban cu la bang 9 dong x 2 cot, kich thuoc ~166x58.5mm,
khong dung theo mau. Da thay bang dung `khungten.png`: bang **140mm x 32mm**, 5 cot (20/30/15/40/35mm)
x 4 hang (8/8/8/8mm), dat goc duoi-phai bang giay (trung khop canh phai/duoi cua khung vien moi).
O (1) Tua bai/ten goi vat the = merge (hang1+2, cot D+E); Nguoi ve/Kiem tra + ho ten/ngay o 2 hang dau
cot A/B/C; Truong/Lop merge cot A+B+C hang 3; Vat lieu merge cot D hang 3; Ti le/Ky hieu tach doi cot E
hang 3. Doi chieu voi anh mau: bo cuc luoi va vi tri 8 o noi dung khop voi `khungten.png`; rieng ranh
gioi chinh xac giua o "Vat lieu"/"Ti le"/"Ky hieu" trong anh mau khong co kich thuoc do rieng (chi co
140mm tong va 20/30/15mm cho 3 cot dau) nen phan chia 40mm/35mm cho 2 cot con lai la suy luan hop ly
duoc giu nguyen tu ban dau, khac biet duy nhat so voi mo ta ban dau cua nguoi dung.

**Yeu cau bo sung - co chu kich thuoc toi thieu 3.5mm + in dam.** TCVN 5705:1993 muc 2.3.1 cho phep
tu 2.5mm tro len nhung qua nho de doc ro khi in; da dat toi thieu **3.5mm** va **Bold=True** cho TOAN
BO annotation kich thuoc (khong chi mot phan) qua `IAnnotation.GetTextFormat(0)/SetTextFormat(0,false,tf)`
(mau chinh thuc SolidWorks dung de doi co chu hang loat) - khong tim thay API cap "document property"
truc tiep trong `swUserPreferenceIntegerValue_e` cho font kich thuoc (chi co cac thuoc tinh kieu mui
ten/duong dan), nen ap dung tung display-dimension annotation la cach dung API chinh thuc, ket qua
dong nhat 100% (khong lo dimension nao con font cu). Doc lai truoc/sau qua COM xac nhan chieu cao giu
nguyen 3.5mm (ban cu da san 3.5mm theo mac dinh chuan ve dang dung) va Bold: False->True tren tat ca
mau kiem tra.

**Chuan ghi kich thuoc**: kiem tra `GetUserPreferenceIntegerValue(13)` (swDetailingDimensionStandard)
truoc AutoDimension: ca 10 part deu DA San ISO (gia tri 2) tu truoc, khong can doi - phu hop voi TCVN
5705 (xay dung tren co so ISO R129:1959).

**Bang xac minh so lieu doc nguoc qua COM (10/10 part, chay 23/07/2026):**

| Ban ve | Khung vien mm (T/P/Tr/D) | Khung ten (rong x cao) | Chuan ghi KT | Co chu KT (mm/Bold) | 4 view khong vuot khung/khung ten | Save/PDF |
|---|---|---:|---:|---:|---:|---:|
| DR-001-1_De-Gan-Tay | 25/10/10/10 | 140.00 x 32.00 | ISO(2) | 3.5 / True (109 annotation) | ALL PASS | err=0/0, 62.4KB |
| DR-001-2_Khung-Han | 25/10/10/10 | 140.00 x 32.00 | ISO(2) | 3.5 / True (78 annotation) | ALL PASS | err=0/0, 42.1KB |
| DR-001-3_Mat-Treo | 25/10/10/10 | 140.00 x 32.00 | ISO(2) | 3.5 / True (109 annotation) | ALL PASS | err=0/0, 47.5KB |
| DR-002_Motor-Bracket-A | 25/10/10/10 | 140.00 x 32.00 | ISO(2) | 3.5 / True (35 annotation) | ALL PASS | err=0/0, 39.3KB |
| DR-003_Motor-Bracket-B | 25/10/10/10 | 140.00 x 32.00 | ISO(2) | 3.5 / True (49 annotation) | ALL PASS | err=0/0, 41.1KB |
| DR-004_Shoulder-Bracket | 25/10/10/10 | 140.00 x 32.00 | ISO(2) | 3.5 / True (31 annotation) | ALL PASS | err=0/0, 43.9KB |
| DR-005-1_Upper-Arm-Hub | 25/10/10/10 | 140.00 x 32.00 | ISO(2) | 3.5 / True (35 annotation) | ALL PASS | err=0/0, 48.8KB |
| DR-005-2_Upper-Arm-Link | 25/10/10/10 | 140.00 x 32.00 | ISO(2) | 3.5 / True (6 annotation) | ALL PASS | err=0/0, 36.0KB |
| DR-006_Elbow-Clevis | 25/10/10/10 | 140.00 x 32.00 | ISO(2) | 3.5 / True (68 annotation) | ALL PASS | err=0/0, 47.1KB |
| DR-007_Moving-Platform | 25/10/10/10 | 140.00 x 32.00 | ISO(2) | 3.5 / True (91 annotation) | ALL PASS | err=0/0, 49.1KB |

Cot "4 view khong vuot khung/khung ten" = doc `IView.GetOutline` cho ca 4 hinh (Front/Top/Side/Iso)
ngay sau khi dat vi tri view cuoi cung (diem doc tin cay duy nhat tren may nay - xem bay COM ben duoi),
so sanh voi toa do khung vien va bbox khung ten muc tieu; ca 40 view (10 part x 4) deu PASS.

**Bay COM phat hien them trong phien nay (bo sung vao ghi chu CLAUDE.md/memory)**: `IView.GetOutline`
tra ve dung hoac sai KHONG PHAI do tien trinh SolidWorks "stale" hay can mo lai file trong process rieng
nhu nghi ban dau - do la mot con duong sai lam ton nhieu thoi gian dieu tra. Nguyen nhan that su la
**bug trong chinh script PowerShell**: PowerShell coi ten bien KHONG PHAN BIET HOA/THUONG, nen
`$oxm` va `$oxM` la CUNG MOT bien - gan `$oxM=$ol[2]` da de len gia tri `$oxm=$ol[0]` truoc do, khien
ca 4 gia tri in ra deu trung voi xmax/ymax that. Sua bang cach dat ten bien phan biet hoan toan
(`$vLeft/$vBottom/$vRight/$vTop`). Bai hoc: KHONG dat 2 bien chi khac nhau o chu hoa/thuong trong cung
script (vi du toi da tung dung `$oxm`/`$oxM`, `$oym`/`$oyM`).

## Cap nhat 23/07/2026 (phan 2) - dong bo khung ten/khung vien theo mau tay nguoi dung (DR-001-3)

Sau lan chay script o phan 1, nguoi dung mo truc tiep `DR-001-3_Mat-Treo.SLDDRW` trong SolidWorks (KHONG
qua script) va tu tay chinh khung ten - coi day la ban CHUAN. Nhiem vu: doc chinh xac khung ten/khung
vien cua DR-001-3 roi ap dung y het sang 9 ban ve con lai, TUYET DOI KHONG dong vao dimension tren cac
view.

**Doc nguoc DR-001-3 (file `.claude`/kich hoat doc doc dung `SwRaw`/typed interop, mo `OpenDoc6` type=3):**
File dang KHONG mo trong bat ky tien trinh SolidWorks nao luc kiem tra (`ISldWorks.GetDocuments` rong,
ROT chi co 1 tien trinh `SolidWorks_PID_13364`, khong co lock file `~$...`), nen mo bang `OpenDoc6` voi
`Options=1` (READ-ONLY), doc xong dong lai KHONG luu - dung theo yeu cau. Khung vien (`Sketch1`, 4 doan
thang duoi Sheet1) = **(25,10)-(410,10)-(410,287)-(25,287) mm - GIONG HET mac dinh cua script** (khong
doi). Bang ten la mot **`GeneralTableFeature`** ten "General Table1" (tim qua duyet cay tinh nang de quy
`GetFirstSubFeature`/`GetNextSubFeature`, roi unwrap qua `IGeneralTableFeature.GetTableAnnotations()` -
`Feature.GetSpecificFeature2()` tren mot GeneralTableFeature KHONG tra ve thang TableAnnotation nhu tuong,
phai qua buoc unwrap nay). Bo cuc bang **CUNG HET** voi mac dinh cua script (140x32mm, 5 cot 20/30/15/40/35,
4 hang 8/8/8/8, cung vi tri neo goc duoi-phai x=270mm y=42mm, cung kieu merge, cung can giua ngang,
cung BorderLineWeight/GridLineWeight/AnchorType) - nguoi dung KHONG doi bo cuc/khung vien, chi doi
**dinh dang chu trong o va noi dung o "Tua bai"**:
- Chieu cao chu tung o (per-cell, khong phai muc mac dinh cua bang): script cu = 2.200mm (khong Bold,
  `useDocFmt=True` - ke thua dinh dang bang); DR-001-3 = **2.38125mm = 6.75pt chinh xac** (da xac minh
  qua tinh nguoc 6.75 x 0.352778mm/pt = 2.38125mm khop tuyet doi voi so doc duoc), ap dung rieng cho
  TUNG o (`useDocFmt=False`) - khong con ke thua muc mac dinh cua bang.
- Can chinh doc trong o (vertical justification): script cu = Middle (2) cho tat ca o; DR-001-3 =
  **Top (1)** cho tat ca o.
- O "Tua bai" (o gop (0,3)-(1,4)): script cu ghi text tho la ten file (vd `DR-002_Motor-Bracket-A`);
  DR-001-3 dung dinh dang rich-text gan lien: `<FONT size=14PTS style=B>DR-001-3: Mat-Treo` - tuc la
  **the HTML-like `<FONT size=14PTS style=B>` (14pt, in dam) + noi dung "MA: Mo-ta"** (thay dau `_` dau
  tien bang `: `, giu nguyen dau `-` trong phan mo ta).
- Khong doi: font family (Century Gothic - ke thua template, khong phai script dat), width factor 0.8,
  can chinh ngang (Center), TitleVisible=False, vi tri neo bang, khung vien, cac o noi dung khac (vat
  lieu/ti le/ma hieu/nguoi ve.../ngay...) van giu dung logic rieng cua tung part (khong copy cung noi
  dung cua DR-001-3 sang cac file khac).

**Cach dong bo (khong xoa-tao-lai bang/khung vien)**: vi khung vien VA bo cuc bang (kich thuoc cot/hang,
vi tri neo, kieu merge) o ca 9 file da GIONG HET DR-001-3 tu truoc (do ca 10 file cung duoc script sinh
trong CUNG mot lan chay o phan 1), viec "xoa khung cu, dung khung moi" tuong duong ve mat ket qua voi
**sua tai cho (in-place) 3 thuoc tinh khac biet da neu tren** - cach nay AN TOAN HON xoa/tao lai vi
khong dong den ma bang/khung vien dang lien ket voi cac view, giam rui ro lam lech dimension. Da kiem
tra: 2 file `DR-001-1_De-Gan-Tay` va `DR-001-2_Khung-Han` truoc do da bi chinh tay mot phan (khac voi
8 file con lai) - vi du DR-001-1 co san chieu cao chu 2.1167mm/wf=1.0/o Tua bai la "De Gan Tay" (khong
dau gach ngang, chu Bold=True truc tiep tren dinh dang o, KHONG co the `<FONT>`); DR-001-2 co san the
`<FONT size=14PTS>` (khong co `style=B`). Ca hai deu duoc ghi de ve dung 1 chuan DR-001-3 duy nhat trong
lan chay nay, dam bao dong nhat tuyet doi tren toan bo 9 file.

**Script su dung**: `sync_titleblock.ps1` (luu scratchpad phien lam viec) - moi file: mo (khong read-only,
type=3 options=0), `ActivateDoc3`, doc dem so dimension moi trong 4 view qua `GetDimensionCount4` (baseline
TRUOC), tim feature "General Table1" -> unwrap TableAnnotation, ap dung `SetCellTextFormat(r,c,false,tf)`
voi `tf.CharHeight=0.00238125` + `tf.WidthFactor=0.8` + `tf.Bold=false` va `set_CellTextVerticalJustification(r,c,1)`
cho toan bo 20 o (4x5), rieng o (0,3) ghi text moi theo mau MA/Mo-ta cua tung file, `ForceRebuild3`, dem
lai dimension (SAU), so sanh voi baseline - neu lech se DUNG NGAY khong luu (chua gap truong hop nao lech
trong 9 file); neu khop thi `SaveAs4` de ghi de SLDDRW + xuat PDF cung ten. Backup 9 file da co san tu
truoc (`*_backup_20260723_pretitleblocksync.SLDDRW`), khong tao them.

**Bang xac minh 10/10 part (doc nguoc qua COM, chay 23/07/2026 12:2x):**

| Ban ve | Khung ten khop mau (H=2.38125mm/Top/font tag) | Khung vien khop mau (25/10/10/10) | Dimension count (truoc=sau, tung view) | PDF export |
|---|---|---|---|---:|
| DR-001-1_De-Gan-Tay | Dat | Dat | 3=3, 2=2, 2=2, 0=0 | err=0, 76 638B |
| DR-001-2_Khung-Han | Dat | Dat | 3=3, 2=2, 2=2, 0=0 | err=0, 51 065B |
| DR-001-3_Mat-Treo (mau, khong sua) | - (mau goc) | - (mau goc) | khong doi (khong mo ghi) | err=0, 64 102B |
| DR-002_Motor-Bracket-A | Dat | Dat | 4=4, 3=3, 3=3, 0=0 | err=0, 48 143B |
| DR-003_Motor-Bracket-B | Dat | Dat | 4=4, 3=3, 3=3, 0=0 | err=0, 49 693B |
| DR-004_Shoulder-Bracket | Dat | Dat | 4=4, 3=3, 1=1, 0=0 | err=0, 52 764B |
| DR-005-1_Upper-Arm-Hub | Dat | Dat | 4=4, 3=3, 3=3, 0=0 | err=0, 57 887B |
| DR-005-2_Upper-Arm-Link | Dat | Dat | 2=2, 2=2, 0=0, 0=0 | err=0, 45 309B |
| DR-006_Elbow-Clevis | Dat | Dat | 2=2, 2=2, 3=3, 0=0 | err=0, 55 840B |
| DR-007_Moving-Platform | Dat | Dat | 2=2, 3=3, 1=1, 0=0 | err=0, 58 532B |

Tat ca 9 file sua deu: `dimMatch=True`, `borderMatch=True` (toa do 4 doan thang khung vien doc lai SAU
edit giong het TRUOC edit), `saveErr=0`, `pdfErr=0`. File `DR-001-3_Mat-Treo.SLDDRW` xac nhan KHONG bi
ghi de (size/timestamp giu nguyen 220 954B / 12:06:42 truoc va sau khi xuat lai PDF).

## Cap nhat 23/07/2026 (phan 3) - khoi phuc ky hieu ren + lam day lai bo kich thuoc bi loc qua tay

**Van de nguoi dung bao**: 10 ban ve V7 (phan 1+2) THIEU ky hieu ren (M5, M20, M16, M2.5, M48, INCH TAP)
tren cac lo ren that, trong khi mot file tham chieu con sot lai `DR-003_Motor-Bracket-B_RenM20.SLDDRW`
co hien thi dung kieu ky hieu nguoi dung muon. Sau do nguoi dung bo sung them file tham chieu day du
`BaoCao/Ban ve gia cong/GiaCongCoKhi.pdf` (10 trang, khung ten/khung vien kieu CU khong dung, nhung NOI
DUNG kich thuoc + ren la muc tieu) va yeu cau mo rong: khoi phuc luon ca bo kich thuoc day du bi bo loc
V7 (dong ~396-456 trong `make_drawing_v7.ps1`) an bot qua tay (limit 2-4 dim/view), khong chi rieng ren.

**Buoc 1 - xac dinh dung "ky hieu ren" la loai annotation gi (doc file tham chieu, KHONG mo ghi)**:
Mo `DR-003_Motor-Bracket-B_RenM20.SLDDRW` bang `OpenDoc6` Options=1 (read-only), duyet `IView.GetAnnotations()`
tung view (KHONG phai `IModelDocExtension.GetAnnotations()` - ham nay tra ve rong cho drawing, phai lay o
cap VIEW). Ket qua: chu "2X M20 X 2.5⌵20" **KHONG PHAI** la `IDisplayDimension`/hole-callout tu AutoDimension
(kiem tra toan bo dim trong file: `IDisplayDimension.IsHoleCallout()` deu tra ve **False**, khong co dim nao
gan voi duong kinh lo ren) - ma la **mot `IAnnotation` loai NOTE (annType=6) danh rieng, tay them**, noi
dung tho luu trong model: `'2X M20 X 2.5 <HOLE-DEPTH>20'`, trong do the `<HOLE-DEPTH>` la ky hieu thu vien
chuan cua SolidWorks (render thanh dau V/rot xuong bieu thi "chieu sau"). Vay nguyen nhan goc: **ky hieu ren
CHUA TUNG duoc AutoDimension sinh ra** (khong phai bi an) - phai tao moi bang NOTE dung mau nay, khong
phai bat lai `Visible`.

**Buoc 2 - xac minh THAT co lo ren nao qua COM tren tung part (khong tin danh sach tham chieu mu quang)**:
Doc `IFeature.GetDefinition()` ep kieu `ThreadFeatureData` (feature loai `SweepThread` - Insert>Features>
Thread that, KHAC voi cac feature dat ten `LoRen-*/LoBac-*` chi la Cut-Extrude thuong danh dau bang ten
Viet). Truong `Type`/`Size` cho dung ten ky hieu ren SolidWorks tu dung (vd `M20x2.5`, `0.6250-18`); truong
`Pitch`/`BlindDepth`/`Revolutions` **KHONG dang tin cay** qua API nay (doc ra dong loat 10.000mm bat ke
kich thuoc that - nghi la gia tri "template" cua thu vien profile, khong phai gia tri da ap dung) - rieng
`BlindDepth` cho 4 thread tren DR-002 lai doc dung (20/20/15/8mm, khac nhau ro giua cac feature) nen van
dung duoc cho truong hop nay; cho cac feature M48/INCH TAP khac deu doc ra 10mm dong loat (khong dung), nen
**gia tri chieu sau dung trong ghi chu cuoi cung lay tu file tham chieu PDF** (30mm cho M48, 40mm cho INCH
TAP - nhat quan qua nhieu part, hop ly hon so voi con so 10mm doc lech tu API).

**Ket qua xac minh 10/10 part (bang lo ren THAT, doc qua `FirstFeature`/`GetNextFeature` + `ThreadFeatureData`):**

| Part | Feature ren that (SweepThread) | Ky hieu chinh xac | Ghi chu ren them vao ban ve |
|---|---|---|---|
| DR-001-1_De-Gan-Tay | khong co | - | KHONG them (khong co ren that; theo dung file tham chieu) |
| DR-001-2_Khung-Han | khong co SweepThread (co LoRen-M12-Pad-x6/LoRen-M12-Goc-x3 nhung chi la Cut-Extrude danh dau ten, khong phai Thread that) | - | KHONG them (theo yeu cau tuong minh cua nguoi dung: giu dung file tham chieu, file do khong ghi ren cho cac lo M12/M16/M20 cua khoi DR-001) |
| DR-001-3_Mat-Treo | tuong tu DR-001-2 (LoBat-M16-x9/LoVit-M20-x6 la Cut-Extrude, khong phai Thread that) | - | KHONG them (tuong minh theo tham chieu) |
| DR-002_Motor-Bracket-A | Thread10/11=M20x2.5 (sau=20mm), Thread14/15=M16x2.0 (sau=15/8mm - 2 ban sao lech nhau, xem luu y) | M20x2.5, M16x2.0 | **"2X M20 X 2.5⌵20"** + **"2X M16 X 2.0⌵8"** (view Top) |
| DR-003_Motor-Bracket-B | Thread2/Thread3=M20x2.5 (sau=20mm, qua LPattern1/LPattern4) | M20x2.5 | **"2X M20 X 2.5⌵20"** (dat ca 2 view Front+Top, dung y het file tham chieu goc) |
| DR-004_Shoulder-Bracket | khong co SweepThread (chi Cut-Extrude Ø2.6 THRU + Ø5 CBORE - ren that nam ben DR-005-1) | - | KHONG them (dung nhu CLAUDE.md mo ta) |
| DR-005-1_Upper-Arm-Hub | Thread3=M48x3.0 (1 lan, khong pattern); LoRen-M25-Hub-x8 la Cut-Extrude (khong phai Thread that nhung ten feature xac nhan la lo ren tap Ø2.05x8) | M48x3.0, M2.5x0.45 | **"M48 X 3.0⌵30"** + **"8X M2.5 X 0.45⌵8"** |
| DR-005-2_Upper-Arm-Link | Thread1=M48x3.0, Thread2=**M48x5.0** (2 dau thanh giang, KHAC buoc ren nhau - xem luu y) | M48x3.0, M48x5.0 | **"M48 X 3.0⌵30"** + **"M48 X 5.0⌵30"** |
| DR-006_Elbow-Clevis | Thread1=M48x3.0 (1 lan); Thread2=0.6250-18 qua Mirror6 (2 lan) | M48x3.0, 5/8-18 UNF | **"M48 X 3.0⌵30"** + **"2X 5/8-18 UNF⌵40"** |
| DR-007_Moving-Platform | Thread1+Thread2=0.6250-18 qua Mirror1+CirPattern1 (6 lan tren 3 canh x 2 khop cau) | 5/8-18 UNF | **"6X 5/8-18 UNF⌵40"** |

**Luu y CAD phat hien duoc trong qua trinh xac minh (khong tu sua CAD, chi bao cao)**: (1) DR-002 co 2 ban
sao Thread14/Thread15 cung danh nghia M16x2.0 nhung `BlindDepth` doc duoc lech nhau (15mm vs 8mm) - da
dung gia tri 8mm (khop voi tham chieu) cho ghi chu, nhung day co the la loi nhap lieu CAD can nguoi
huong dan/nguoi dung kiem tra lai truc tiep tren feature Thread14. (2) DR-005-2 (Upper-Arm-Link) co
Thread1=M48x3.0 va Thread2=M48x5.0 - hai dau thanh giang mang **buoc ren khac nhau** (3.0 vs 5.0mm) trong
khi ve mat lap ghep (noi voi DR-005-1 hub va DR-006 elbow-clevis, ca hai deu dung M48x3.0) thi ca hai dau
nen giong nhau; nhieu kha nang Thread2 bi nhap sai buoc ren luc tao feature - **can nguoi dung/GVHD xac
nhan lai truc tiep tren CAD**, ban ve hien dang phan anh DUNG trang thai CAD hien tai (khong tu y sua).

**Buoc 3 - mo rong theo yeu cau: lam day lai bo kich thuoc day du (khong chi rieng ren)**: bo loc V7 goc
(ham tinh diem theo `Type2`, gioi han `$limit` = 2-4 dim/view) van con nguyen trong file (dim bi an qua
`SetAnnotationVisible(...,false)`, KHONG bi xoa). Da viet lai thuat toan: doc lai TOAN BO `GetDisplayDimensions`
(ca dang an), **giu nguyen tat ca dim dang hien (khong bao gio an bot - chi duoc phep THEM)**, roi nang
`limit` len 6/view va cho phep them cac dim bi an co diem so cao nhat (dedup theo `Type2+GiaTri`, khong
trung lap gia tri qua nhieu view) duoc hien lai, cho den khi dat 6 hoac het luoc. **Khong dung cach "bat
lai tat ca"** vi kiem tra rieng cho thay `DR-001-3` view Top co toi **96 dim tho** (AutoDimension ghi rieng
tung lo trong bo 9xM16+6xM20 theo so do "chain", moi lo mot gia tri khac nhau, khong the dedup) - bat het
se ra ban ve roi khong doc duoc; nang gioi han len 6/view (thay vi bat het) giu duoc dung cac gia tri PHAN
BIET quan trong (kiem chung: bang kich thuoc doc lai khop rat sat voi tham chieu PDF cho DR-001-1/-2/-3,
xem vi du duoi).

**Vi du doi chieu voi tham chieu PDF (khong bat buoc khop tuyet doi vi hinh hoc da doi qua nhieu lan sua
doi xung/tach khoi - chi can DUNG LOAI kich thuoc)**: DR-001-1 sau khi lam day: 755.92/315.82/317.48,
9XR24/3XR26/3XR28, 3XR381/3XR383, 723.39/777.94, Fillet 2mm - khop hau het cac gia tri tham chieu neu
(chi thieu 82mm day thay vi "50" - do hinh hoc that la 82mm, tham chieu co the da cu). DR-001-3: 252.19,
153.00, 52.98, 3XR383.03, Ø150 THRU, Ø17.5, R129.92, 38.25, 259.77, 77.22 - khop gan nhu toan bo danh sach
tham chieu.

**Script**: `fix_ren_and_dims.ps1` (luu scratchpad phien lam viec) - moi file: mo (khong read-only), doc
BEFORE (dump khung ten qua `GeneralTableFeature`->`GetTableAnnotations()`, dem dim total/visible tung view),
nang limit dim + them NOTE ren (co bao ve trung lap theo cap (view,text) de chay lai an toan, khong tao
note trung), rebuild, doc AFTER, so sanh khung ten TRUOC=SAU (bang chuoi dump tung o), luu `SaveAs4` de
SLDDRW + xuat PDF. Vi tri dat NOTE: tu dong chon view co nhieu dim duong kinh/ban kinh nhat (`Type2`=5
hoac 6 - dai dien view nhin thang mat lo tron), dat trong "hanh lang kich thuoc" co san cua tung view
(cung toa do co dinh dung trong `make_drawing_v7.ps1`), khong dam vao khung vien/khung ten.

**Bang xac minh cuoi cung 10/10 part (doc nguoc qua COM sau khi luu, script `final_verify.ps1`):**

| Ban ve | Khung vien (25/10/10/10mm) | Khung ten | Ren that + so luong | Ky hieu ren them | Dim total/visible (3 view chinh) |
|---|---:|---:|---|---|---|
| DR-001-1_De-Gan-Tay | Dat, khong doi | Dat, khong doi | Khong | (khong co) | 18/6, 71/6, 19/6 |
| DR-001-2_Khung-Han | Dat, khong doi | Dat, khong doi | Khong (theo tham chieu) | (khong co) | 4/4, 70/6, 4/2 |
| DR-001-3_Mat-Treo | Dat, khong doi | Dat, khong doi (mau tay nguoi dung giu nguyen) | Khong (theo tham chieu) | (khong co) | 8/6, 96/6, 6/5 |
| DR-002_Motor-Bracket-A | Dat, khong doi | Dat, khong doi | Co: 16xM5 (Cut, khong Thread), 2xM20x2.5, 2xM16x2.0 | 2X M20 X 2.5⌵20 + 2X M16 X 2.0⌵8 | 12/6, 14/6, 9/6 |
| DR-003_Motor-Bracket-B | Dat, khong doi | Dat, khong doi | Co: 2xM20x2.5 | 2X M20 X 2.5⌵20 (x2 view, khop tham chieu) | 27/6, 10/6, 12/6 |
| DR-004_Shoulder-Bracket | Dat, khong doi | Dat, khong doi | Khong (xac nhan qua COM: khong co SweepThread) | (khong co) | 5/4, 21/6, 5/1 |
| DR-005-1_Upper-Arm-Hub | Dat, khong doi | Dat, khong doi | Co: 1xM48x3.0, 8xM2.5 (Cut) | M48 X 3.0⌵30 + 8X M2.5 X 0.45⌵8 | 17/6, 10/6, 8/4 |
| DR-005-2_Upper-Arm-Link | Dat, khong doi | Dat, khong doi | Co: 1xM48x3.0, 1xM48x5.0 | M48 X 3.0⌵30 + M48 X 5.0⌵30 | 2/2, 2/2, 2/0 |
| DR-006_Elbow-Clevis | Dat, khong doi | Dat, khong doi | Co: 1xM48x3.0, 2x5/8-18 UNF | M48 X 3.0⌵30 + 2X 5/8-18 UNF⌵40 | 20/6, 28/6, 20/6 |
| DR-007_Moving-Platform | Dat, khong doi | Dat, khong doi | Co: 6x5/8-18 UNF | 6X 5/8-18 UNF⌵40 | 22/6, 42/6, 27/6 |

Tat ca 10 file: `save drw err=0`, `pdf err=0`; khung vien doc lai dung 4 doan `(25,10)-(410,10)-(410,287)-
(25,287)` mm cho ca 10 file; khung ten doc lai (dump toan bo 20 o) GIONG HET truoc/sau moi lan sua (chi
sua dim + them note, khong dung toi feature `GeneralTable1`). Backup truoc khi sua da co san tu truoc
(`Backup/*_backup_20260723_beforerensymbol.SLDDRW`, tao boi phien truoc).

**Han che con lai (bao cao trung thuc, khong che giau)**: mot vai vi tri ghi chu ren/kich thuoc dat gan
nhau bi chong nhe (vd DR-005-1 "8X M2.5..." cham vao so "82.71"; DR-006/DR-007 "M48.../INCH TAP..." cham
nhe vao mot dim khac) - van doc duoc ro rang tung so nhung chua toi uu hoan toan ve mat bo tri; can tinh
chinh vi tri tung note thu cong neu muon dep tuyet doi cho ban in cuoi cung. Depth cua ren M48/INCH TAP
(30mm/40mm) lay tu file tham chieu PDF (API `BlindDepth` khong dang tin cay cho cac feature nay) - neu
GVHD yeu cau do chinh xac tuyet doi thi nen do lai truc tiep tren feature CAD (Edit Feature > Thread) roi
sua text NOTE tuong ung (khong anh huong toi cach lam, chi thay so).

## Cap nhat 23/07/2026 (phan 4) - sua chong chu do buoc "lam day kich thuoc" o phan 3 gay ra

**Van de nguoi dung phat hien (doc truc tiep PDF, khong chi tin log)**: buoc "nang limit dim tu 2-4 len 6/
view" o phan 3 chi doi `Visible=true/false`, KHONG bao gio goi lai buoc sap xep vi tri (`SetPosition`) -
nen cac dim vua duoc hien lai van nam nguyen o vi tri AutoDimension dat tu dau (rat sat nhau khi so luong
dim/view tang tu 2-4 len 6), sinh ra chu de len nhau ro nhat o `DR-006` (4 cho: "96.25/94.49" dinh vao
nhau, "75.89/75.91/76.84" chong lam mot, "92.96 94.73 119.27 120.51 21.00 122.51" dinh chuoi, ghi chu ren
de len dim khac) va `DR-007` ("267.20/267.21" + "269.15/269.16" gan trung gia tri dinh chuoi, ren de len
"R20.48"); `DR-005-1`/`DR-002` nhe hon nhung van co cho cham.

**Nguyen nhan hai lop, sua theo dung 2 buoc nguoi dung yeu cau:**

**(1) Gop dimension gan trung gia tri** (< 1mm, cung `Type2`, cung 1 view): mot phan nguyen nhan la
AutoDimension tu sinh 2 dim GAN NHU giong het gia tri tu 2 canh doi xung (vd 267.20 vs 267.21, chenh
0.01mm - do sai so lam tron hinh hoc doi xung) ma buoc loc phan 3 (dedup theo khoa `Type2|Round(val,2)`)
khong bat duoc vi 267.20 va 267.21 lam tron o 2 chu so thap phan ra 2 khoa KHAC nhau. Sua: doi sang so
sanh **hieu tuyet doi < 1.0mm** giua cac gia tri da sap xep trong cung nhom `Type2` cua tung view (khong
con phu thuoc lam tron) - AN NGAY cac ban trung: `DR-007` an 267.205→giu 267.203, an 269.157→giu 269.155;
`DR-006` an 75.907 va 76.841→giu 75.888 (gop ca 3 gia tri gan nhau lien tiep thanh 1); `DR-003` an 2 cap
R17/R19 gan D-002; `DR-002`, `DR-004`, `DR-005-1` moi noi an 1 cap. Ap dung cho toan bo 10 file, khong
rieng DR-006/DR-007.

**(2) Sap xep lai vi tri sau khi loc** (nguyen nhan chinh gay chong chu): viet lai thuat toan "dim arrange"
cua ban goc (`make_drawing_v7.ps1` dong ~459-506, von chi chay MOT LAN luc tao ban ve dau tien voi it dim
hon) thanh script rieng `fix_overlap.ps1`, chay LAI tren toan bo dim+note DANG HIEN trong tung view:
- Phan loai tung nhan (dimension hoac ghi chu ren) vao 1 trong 5 vung quanh view (`left/right/above/below/
  inside`) theo vi tri so voi `GetOutline` cua view.
- **Phat hien va sua 1 loi mo hinh sai ban dau**: dim dat o `left`/`right` (hai ben view) trong SolidWorks
  duoc **xoay 90° de doc theo chieu doc** (chuan cua SW cho dim thang dung) - lan sua dau tien coi nham
  chieu "dai" cua khoi chu la chieu ngang (theo do rong chuoi ky tu) giong dim ngang, khien khoang cach
  giua cac shelf xep chong qua gan (chinh la nguyen nhan can 2 vong sua truoc khi phat hien, vd DR-005-1:
  "80.73"/"43.00" bi dinh o view Side). Sua: gan `HalfX`/`HalfY` moi nhan theo **dung huong doc chu that**
  (dim trai/phai: truc dai = Y dung do dai chuoi; dim tren/duoi + ghi chu ren: truc dai = X).
  - Xep tung vung theo kieu "shelf" (nhu xep sach): sap xep theo truc chinh, moi nhan chiem it nhat
    `do_dai_chu/2 + do_dai_chu_ke/2 + khe_ho(4.5mm)`; neu khong du cho tren 1 hang, tu dong mo hang moi
    (dich ra xa view them 1 buoc co dinh ~5.25mm) - dam bao KHONG BAO GIO 2 nhan chen nhau tren cung true
    chinh du so luong dim tang len bao nhieu.
  - **Ghi chu ren duoc danh rieng 1 "bang" o mep tren/duoi cua o luoi** (khong con canh tranh cho voi dim
    khac) - day chinh la nguyen nhan lam ghi chu ren "8X M2.5..." de len dim "82.71"/"R42.00" trong 2 lan
    sua dau (chung dung chung 1 hang xep va giao tranh nhau); tach rieng ra 1 dai danh rieng cho ren, con
    dim duoc xep trong phan con lai cua o luoi → het chong hoan toan.
  - Sau khi xep, chay them **1 buoc don doc-va-sua lap** (`Resolve-Overlaps`, toi da 20 vong): doc lai vi
    tri THAT + uoc luong kich thuoc chu that (so ky tu × 0.78×chieu cao chu 3.5mm, co tinh chu Bold rong
    hon chu thuong) cho tung nhan, kiem tra tung cap, neu con cham thi day nhan ra xa dung huong con thieu
    it nhat - lam viec doc lap voi buoc xep-shelf ben tren, bat duoc moi truong hop con sot du nguyen nhan
    la gi.

**Xac minh bang so lieu (khong chi nhin anh), script `fix_overlap.ps1` tu doc lai SAU khi luu, toan bo
10/10 file, chay lai them 1 lan cuoi voi khe ho rong hon (4.5mm, uoc luong chu rong hon cho font Bold) de
kiem tra chat hon:**

| Ban ve | Dedup gia tri trung (<1mm) | Buoc xep lai (left/right/above/below/inside, tung view) | Bbox check con cham? | Khung ten/khung vien | Save/PDF |
|---|---|---|---|---|---|
| DR-001-1_De-Gan-Tay | 0 | 0/4,3/3,2/1 | Khong | Khong doi | err=0/0 |
| DR-001-2_Khung-Han | 0 | 2/2,3/3,2/0 | Khong | Khong doi | err=0/0 |
| DR-001-3_Mat-Treo | 0 | 1/4,3/2,3/1 | Khong | Khong doi | err=0/0 |
| DR-002_Motor-Bracket-A | 1 (122.33≈121.42) | 2/2,3/3,3/3 | Khong | Khong doi | err=0/0 |
| DR-003_Motor-Bracket-B | 2 (R17,R19 doi) | 2/2,3/3,4/2 | Khong | Khong doi | err=0/0 |
| DR-004_Shoulder-Bracket | 1 (Ø2.6≈Ø2.59) | 3/1,1/4,1/0 | Khong | Khong doi | err=0/0 |
| DR-005-1_Upper-Arm-Hub | 1 (100.37≈100.23) | 4/0,4/1,4/0 | Khong (sau khi tach rieng bang ren) | Khong doi | err=0/0 |
| DR-005-2_Upper-Arm-Link | 0 | 2/0,0/2,0/0 | Khong | Khong doi | err=0/0 |
| DR-006_Elbow-Clevis | 3 (75.91,76.84 gop vao 75.89) | 3/0,0/4,2/4 | Khong | Khong doi | err=0/0 |
| DR-007_Moving-Platform | 2 (267.21,269.16 gop) | 1/2,1/5,0/3 | Khong | Khong doi | err=0/0 |

Tat ca 10 file: `TITLE TABLE UNCHANGED=True` (dump 20 o khung ten giong het truoc/sau), khung vien khong
dong den (script khong chua bat ky lenh nao sua sketch khung vien), `ANY OVERLAP REMAINING=False` qua
kiem tra bbox uoc luong, `save drw err=0`, `pdf err=0` ca 10 file. Kiem tra lai bang mat qua PDF xac nhan
DR-006 va DR-007 (2 file te nhat) gio doc ro tung so, khong con dam vao nhau.

**Han che con lai (bao cao trung thuc)**: uoc luong be rong chu dua tren so ky tu × he so trung binh
(khong doc truc tiep font-metrics that cua SolidWorks vi API khong lo ra), nen 1 vai cho VAN con nhan sat
nhau trong pham vi vai mm (duoi nguong bbox uoc luong nhung nhin ky van co the thay hoi cham leader-line
hoac 2 so cach nhau ~1-2mm) - cu the: `DR-006` view duoi-trai "92.96/94.73" va "119.27/120.51/122.51" (3
kich thuoc that su khac nhau 1-2mm, khong phai trung lap nen khong the gop, chi con cach tach thanh nhieu
hang hon hoac doi ty le ban ve); `DR-005-1`, `DR-002`, `DR-004` co leader-line di ngang qua gan chu (khong
lam mat so, chi hoi roi mat) o 1-2 vi tri. Day la muc do "co the chap nhan duoc cho do an gia cong" chu
chua phai "hoan hao tuyet doi tung pixel" - neu can dep hon nua thi phai chinh tay tung annotation hoac
giam so luong dimension quay lai (danh doi giua "day du thong tin" va "khong khi nao cham nhe").
