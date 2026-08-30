# fea_common.ps1 - shared library for SolidWorks Simulation (FEA) automation via COM.
# Dot-source this. Provides: SwRaw (raw IDispatch), SwGeom (compiled interop face enum/pick),
# Connect-SW, Open-Part, Load-Sim. See CLAUDE.md + memory deltarobot-assem1-findings for recipe.

$ErrorActionPreference = 'Stop'
$SW_ROOT   = 'D:\SOLIDWORKS'
$IL_SW     = "$SW_ROOT\api\redist\SolidWorks.Interop.sldworks.dll"
$IL_CONST  = "$SW_ROOT\api\redist\SolidWorks.Interop.swconst.dll"
$IL_COS    = "$SW_ROOT\api\redist\SolidWorks.Interop.cosworks.dll"
$COSWORKS  = "$SW_ROOT\Simulation\cosworks.dll"
$PROJ      = 'F:\DeltaRobot\DeltaRobot_Final'

# --- raw IDispatch helper (methods/props that typed interop can't reach on this machine) ---
# SwRaw + SwSim compiled together (one assembly) so SwSim can reference SwRaw's public types.
$simSrc = (Get-Content 'F:\DeltaRobot\.claude\tools\swsim_lib.cs') | Where-Object { $_ -notmatch '^\s*using\s' }
$rawSrc = (Get-Content 'F:\DeltaRobot\.claude\tools\swraw_lib.cs' -Raw) + "`n" + ($simSrc -join "`n")
Add-Type -TypeDefinition $rawSrc

# --- compiled interop helper for geometry enumeration + face picking (typed interop works when COMPILED) ---
[void][Reflection.Assembly]::LoadFrom($IL_SW)
[void][Reflection.Assembly]::LoadFrom($IL_CONST)
[void][Reflection.Assembly]::LoadFrom($IL_COS)
# AssemblyResolve so the compiled type finds the interop at call time
[AppDomain]::CurrentDomain.add_AssemblyResolve([ResolveEventHandler]{
  param($s,$e)
  foreach ($p in @($IL_SW,$IL_CONST,$IL_COS)) {
    $n = [IO.Path]::GetFileNameWithoutExtension($p)
    if ($e.Name -like "$n,*") { return [Reflection.Assembly]::LoadFrom($p) }
  }
  return $null
})

Add-Type -ReferencedAssemblies @($IL_SW,$IL_CONST,$IL_COS) -TypeDefinition @"
using System;
using System.Text;
using System.Collections.Generic;
using SolidWorks.Interop.sldworks;
using SolidWorks.Interop.swconst;
using SolidWorks.Interop.cosworks;

public static class SwGeom {
    // Return one line per solid face: idx, type(plane/cyl/other), area(mm2), R(mm) for cyl,
    // axis dir for cyl, plane normal for plane, centroid(mm), box(mm).
    public static string DumpFaces(object modelDocObj) {
        IPartDoc pd = (IPartDoc)modelDocObj;
        object[] bodies = (object[])pd.GetBodies2((int)swBodyType_e.swSolidBody, false);
        StringBuilder sb = new StringBuilder();
        int gi = 0;
        for (int b = 0; b < bodies.Length; b++) {
            Body2 body = (Body2)bodies[b];
            object[] faces = (object[])body.GetFaces();
            for (int f = 0; f < faces.Length; f++) {
                Face2 face = (Face2)faces[f];
                Surface s = (Surface)face.GetSurface();
                double area = face.GetArea() * 1e6; // m2 -> mm2
                double[] box = (double[])face.GetBox(); // m, [xmin ymin zmin xmax ymax zmax]
                double cx = (box[0]+box[3])/2*1000, cy=(box[1]+box[4])/2*1000, cz=(box[2]+box[5])/2*1000;
                string kind="other", extra="";
                if (s.IsPlane()) {
                    kind="plane";
                    double[] pp = (double[])s.PlaneParams; // [nx ny nz, px py pz]
                    extra = string.Format("n=({0:F3},{1:F3},{2:F3})", pp[0],pp[1],pp[2]);
                } else if (s.IsCylinder()) {
                    kind="cyl";
                    double[] cp = (double[])s.CylinderParams; // [px py pz, ax ay az, radius]
                    extra = string.Format("R={0:F2} axis=({1:F3},{2:F3},{3:F3})", cp[6]*1000, cp[3],cp[4],cp[5]);
                }
                sb.AppendLine(string.Format(
                  "F{0} body{1} {2} A={3:F1}mm2 {4} C=({5:F1},{6:F1},{7:F1}) box=[{8:F1},{9:F1},{10:F1} .. {11:F1},{12:F1},{13:F1}]",
                  gi, b, kind, area, extra, cx,cy,cz,
                  box[0]*1000,box[1]*1000,box[2]*1000,box[3]*1000,box[4]*1000,box[5]*1000));
                gi++;
            }
        }
        return sb.ToString();
    }

    // Return the Face2 object at global face index gi (matching DumpFaces numbering).
    public static object FaceAt(object modelDocObj, int gi) {
        IPartDoc pd = (IPartDoc)modelDocObj;
        object[] bodies = (object[])pd.GetBodies2((int)swBodyType_e.swSolidBody, false);
        int idx=0;
        for (int b=0;b<bodies.Length;b++){
            Body2 body=(Body2)bodies[b];
            object[] faces=(object[])body.GetFaces();
            for (int f=0; f<faces.Length; f++){ if(idx==gi) return faces[f]; idx++; }
        }
        return null;
    }

    // Build an object[] of Face2 for the given global indices (for BC selection arrays).
    public static object FacesArray(object modelDocObj, int[] gis) {
        object[] outArr = new object[gis.Length];
        for (int i=0;i<gis.Length;i++) outArr[i] = FaceAt(modelDocObj, gis[i]);
        return outArr;
    }

    // Strongly-typed Face2[] - marshals to SAFEARRAY(VT_DISPATCH) which cosworks Add* wants.
    public static Face2[] FacesTyped(object modelDocObj, int[] gis) {
        Face2[] outArr = new Face2[gis.Length];
        for (int i=0;i<gis.Length;i++) outArr[i] = (Face2)FaceAt(modelDocObj, gis[i]);
        return outArr;
    }

    // Select faces via SelectionManager (IEntity.Select4) - some cosworks calls read the selection.
    public static int SelectFaces(object modelDocObj, int[] gis) {
        int ok=0;
        for (int i=0;i<gis.Length;i++){
            Entity e = (Entity)FaceAt(modelDocObj, gis[i]);
            if (e != null && e.Select4(i>0, null)) ok++;
        }
        return ok;
    }
}

// FEA boundary conditions via TYPED cosworks interop (compiled cast works where PS-level cast fails).
public static class SwFea {
    // Fixed-geometry restraint on the given faces. Returns [restraintObj, err].
    public static object AddFixed(object lrmObj, object[] faces) {
        ICWLoadsAndRestraintsManager lrm = (ICWLoadsAndRestraintsManager)lrmObj;
        int err;
        object r = lrm.AddRestraint((int)swsRestraintType_e.swsRestraintTypeFixed, faces, null, out err);
        return new object[]{ r, err };
    }
    // Directional force on faces; (d1,d2,d3) relative to refFace basis (d3 = normal). Newton.
    // Returns [forceObj, createErr, endEditErr].
    public static object AddForceDir(object lrmObj, object[] faces, object refFace, double d1, double d2, double d3) {
        ICWLoadsAndRestraintsManager lrm = (ICWLoadsAndRestraintsManager)lrmObj;
        int err;
        CWForce f = (CWForce)lrm.AddForce((int)swsForceType_e.swsForceTypeForceOrMoment, faces, refFace, out err);
        if (f == null) return new object[]{ null, err, -1 };
        f.ForceBeginEdit();
        f.SetForceComponentValues2(true, true, true, d1, d2, d3);
        int ee = f.ForceEndEdit();
        return new object[]{ f, err, ee };
    }
}
"@

function Connect-SW {
    try { $sw = [System.Runtime.InteropServices.Marshal]::GetActiveObject('SldWorks.Application') }
    catch { $sw = New-Object -ComObject SldWorks.Application }
    [SwRaw]::PutProp($sw,'Visible',$true)
    return $sw
}

function Open-Part($sw, $path) {
    $p = [string]$path
    $spec = [SwRaw]::InvokeN($sw,'GetOpenDocSpec',@([string]$p))
    [SwRaw]::PutProp($spec,'Silent',$true)
    $doc = [SwRaw]::InvokeN($sw,'OpenDoc7',@($spec))
    if ($null -eq $doc) { throw "OpenDoc7 returned null for $p" }
    return $doc
}

function Load-Sim($sw) {
    [void][SwRaw]::InvokeN($sw,'LoadAddIn',@($COSWORKS))
    $addin = [SwRaw]::InvokeN($sw,'GetAddInObject',@('SldWorks.Simulation'))
    if ($null -eq $addin) {
        [void][SwRaw]::InvokeN($sw,'LoadAddIn',@($COSWORKS))
        $addin = [SwRaw]::InvokeN($sw,'GetAddInObject',@('SldWorks.Simulation'))
    }
    $cw = [SwRaw]::Invoke0($addin,'CosmosWorks',$true)  # unwrap dispid 99 -> real ICosmosWorks
    if ($null -eq $cw) { throw "CosmosWorks unwrap returned null" }
    return $cw
}

Write-Host "fea_common loaded (SwRaw + SwGeom + Connect-SW/Open-Part/Load-Sim)"
