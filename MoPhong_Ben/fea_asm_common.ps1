# fea_asm_common.ps1 - shared library for WHOLE-ASSEMBLY SolidWorks Simulation via COM.
# Extends the per-part pipeline (fea_common.ps1) with:
#   SwRot     - connect to a SPECIFIC SolidWorks process via ROT moniker SolidWorks_PID_<pid>
#   SwAsm     - assembly-level component/face enumeration (typed interop, assembly coords)
#   SwFea2    - typed cosworks BCs: AddFixed, AddForceDir, AddGravity (+read-back), results helpers
# All temp on F: (C: chronically full). Dot-source this.

$ErrorActionPreference = 'Stop'
$env:TEMP='F:\SWTEMP'; $env:TMP='F:\SWTEMP'
$SW_ROOT   = 'D:\SOLIDWORKS'
$IL_SW     = $SW_ROOT + '\api\redist\SolidWorks.Interop.sldworks.dll'
$IL_CONST  = $SW_ROOT + '\api\redist\SolidWorks.Interop.swconst.dll'
$IL_COS    = $SW_ROOT + '\api\redist\SolidWorks.Interop.cosworks.dll'
$COSWORKS  = $SW_ROOT + '\Simulation\cosworks.dll'

# --- raw IDispatch helper + SwSim (safearray BC fallback) compiled together ---
$simSrc = (Get-Content 'F:\DeltaRobot\.claude\tools\swsim_lib.cs') | Where-Object { $_ -notmatch '^\s*using\s' }
$rotSrc = @'
public static class SwRot {
    [DllImport("ole32.dll")] static extern int GetRunningObjectTable(int reserved, out IRunningObjectTable prot);
    [DllImport("ole32.dll")] static extern int CreateBindCtx(int reserved, out IBindCtx ppbc);

    // List all ROT entries containing "SolidWorks"
    public static string List() {
        IRunningObjectTable rot; GetRunningObjectTable(0, out rot);
        IEnumMoniker em; rot.EnumRunning(out em);
        IBindCtx bc; CreateBindCtx(0, out bc);
        IMoniker[] mk = new IMoniker[1];
        string res = "";
        while (em.Next(1, mk, IntPtr.Zero) == 0) {
            string name; mk[0].GetDisplayName(bc, null, out name);
            if (name.IndexOf("SolidWorks", StringComparison.OrdinalIgnoreCase) >= 0) res += name + "\n";
        }
        return res;
    }
    // Get the ISldWorks for a given PID via moniker SolidWorks_PID_<pid>
    public static object GetByPid(int pid) {
        IRunningObjectTable rot; GetRunningObjectTable(0, out rot);
        IEnumMoniker em; rot.EnumRunning(out em);
        IBindCtx bc; CreateBindCtx(0, out bc);
        IMoniker[] mk = new IMoniker[1];
        string want = "SolidWorks_PID_" + pid;
        while (em.Next(1, mk, IntPtr.Zero) == 0) {
            string name; mk[0].GetDisplayName(bc, null, out name);
            if (name.IndexOf(want, StringComparison.OrdinalIgnoreCase) >= 0) {
                object obj; rot.GetObject(mk[0], out obj);
                return obj;
            }
        }
        return null;
    }
}
'@
$rawSrc = "using System.Runtime.InteropServices.ComTypes;`n" + (Get-Content 'F:\DeltaRobot\.claude\tools\swraw_lib.cs' -Raw) + "`n" + ($simSrc -join "`n") + "`n" + $rotSrc
Add-Type -TypeDefinition $rawSrc

[void][Reflection.Assembly]::LoadFrom($IL_SW)
[void][Reflection.Assembly]::LoadFrom($IL_CONST)
[void][Reflection.Assembly]::LoadFrom($IL_COS)
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

// Assembly-level geometry enumeration in ASSEMBLY coordinates.
// IComponent2.GetBodies3 returns body geometry in PART space -> transform by Component2.Transform2.
public static class SwAsm {

    static double[] Xform(double[] a, double x, double y, double z) {
        // SW MathTransform ArrayData: [0..8]=rotation (COLUMN-major per row-vector convention:
        // P' = P*R + t with R rows a[0..2],a[3..5],a[6..8]), [9..11]=translation, [12]=scale.
        double s = a[12];
        double nx = s*(x*a[0] + y*a[3] + z*a[6]) + a[9];
        double ny = s*(x*a[1] + y*a[4] + z*a[7]) + a[10];
        double nz = s*(x*a[2] + y*a[5] + z*a[8]) + a[11];
        return new double[]{nx,ny,nz};
    }
    static double[] XformDir(double[] a, double x, double y, double z) {
        double nx = x*a[0] + y*a[3] + z*a[6];
        double ny = x*a[1] + y*a[4] + z*a[7];
        double nz = x*a[2] + y*a[5] + z*a[8];
        return new double[]{nx,ny,nz};
    }

    public static string ListComponents(object asmModelObj) {
        ModelDoc2 md = (ModelDoc2)asmModelObj;
        AssemblyDoc asm = (AssemblyDoc)asmModelObj;
        object[] comps = (object[])asm.GetComponents(true); // top-level
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < comps.Length; i++) {
            Component2 c = (Component2)comps[i];
            string supp = (c.GetSuppression2() == (int)swComponentSuppressionState_e.swComponentSuppressed) ? " SUPPRESSED" : "";
            double[] box = null;
            try { box = (double[])c.GetBox(false,false); } catch {}
            string boxs = (box==null) ? "nobox" : string.Format("box=[{0:F1},{1:F1},{2:F1} .. {3:F1},{4:F1},{5:F1}]mm",
                box[0]*1000,box[1]*1000,box[2]*1000,box[3]*1000,box[4]*1000,box[5]*1000);
            sb.AppendLine(string.Format("C{0} '{1}' {2}{3}", i, c.Name2, boxs, supp));
        }
        return sb.ToString();
    }

    // Find top-level component whose Name2 contains substr (first match).
    public static object FindComp(object asmModelObj, string substr) {
        AssemblyDoc asm = (AssemblyDoc)asmModelObj;
        object[] comps = (object[])asm.GetComponents(true);
        for (int i = 0; i < comps.Length; i++) {
            Component2 c = (Component2)comps[i];
            if (c.Name2.IndexOf(substr, StringComparison.OrdinalIgnoreCase) >= 0) return c;
        }
        return null;
    }
    public static object[] FindComps(object asmModelObj, string substr) {
        AssemblyDoc asm = (AssemblyDoc)asmModelObj;
        object[] comps = (object[])asm.GetComponents(true);
        List<object> res = new List<object>();
        for (int i = 0; i < comps.Length; i++) {
            Component2 c = (Component2)comps[i];
            if (c.Name2.IndexOf(substr, StringComparison.OrdinalIgnoreCase) >= 0) res.Add(c);
        }
        return res.ToArray();
    }

    // Dump planar faces of one component (assembly coords), minAreaMM2 filter.
    public static string DumpPlanarFaces(object compObj, double minAreaMM2) {
        Component2 c = (Component2)compObj;
        double[] a = (double[])((MathTransform)c.Transform2).ArrayData;
        StringBuilder sb = new StringBuilder();
        object bodiesInfo;
        object[] bodies = (object[])c.GetBodies3((int)swBodyType_e.swSolidBody, out bodiesInfo);
        if (bodies == null) return "(no bodies)";
        int gi = 0;
        for (int b = 0; b < bodies.Length; b++) {
            Body2 body = (Body2)bodies[b];
            object[] faces = (object[])body.GetFaces();
            for (int f = 0; f < faces.Length; f++, gi++) {
                Face2 face = (Face2)faces[f];
                Surface s = (Surface)face.GetSurface();
                if (!s.IsPlane()) continue;
                double area = face.GetArea()*1e6;
                if (area < minAreaMM2) continue;
                double[] box = (double[])face.GetBox();
                double[] cen = Xform(a, (box[0]+box[3])/2, (box[1]+box[4])/2, (box[2]+box[5])/2);
                double[] nrm = (double[])face.Normal; // outward, part space
                double[] an = XformDir(a, nrm[0], nrm[1], nrm[2]);
                sb.AppendLine(string.Format(
                  "F{0} body{1} plane A={2:F0}mm2 Casm=({3:F1},{4:F1},{5:F1}) Nasm=({6:F3},{7:F3},{8:F3})",
                  gi, b, area, cen[0]*1000, cen[1]*1000, cen[2]*1000, an[0], an[1], an[2]));
            }
        }
        return sb.ToString();
    }

    // Pick faces of a component: planar, |assembly normal . dir| >= cosTol, assembly centroid dot dir within [lo,hi] mm.
    public static object[] PickPlanarFaces(object compObj, double dx, double dy, double dz,
                                          double cosTol, double loMM, double hiMM, double minAreaMM2) {
        Component2 c = (Component2)compObj;
        double[] a = (double[])((MathTransform)c.Transform2).ArrayData;
        object bodiesInfo;
        object[] bodies = (object[])c.GetBodies3((int)swBodyType_e.swSolidBody, out bodiesInfo);
        List<object> res = new List<object>();
        if (bodies == null) return res.ToArray();
        for (int b = 0; b < bodies.Length; b++) {
            Body2 body = (Body2)bodies[b];
            object[] faces = (object[])body.GetFaces();
            for (int f = 0; f < faces.Length; f++) {
                Face2 face = (Face2)faces[f];
                Surface s = (Surface)face.GetSurface();
                if (!s.IsPlane()) continue;
                if (face.GetArea()*1e6 < minAreaMM2) continue;
                double[] nrm = (double[])face.Normal;
                double[] an = XformDir(a, nrm[0], nrm[1], nrm[2]);
                double dot = an[0]*dx + an[1]*dy + an[2]*dz;
                if (dot < cosTol) continue;
                double[] box = (double[])face.GetBox();
                double[] cen = Xform(a, (box[0]+box[3])/2, (box[1]+box[4])/2, (box[2]+box[5])/2);
                double proj = (cen[0]*dx + cen[1]*dy + cen[2]*dz) * 1000.0;
                if (proj < loMM || proj > hiMM) continue;
                res.Add(face);
            }
        }
        return res.ToArray();
    }

    // All solid bodies of one component (for per-part result restriction).
    public static object[] CompBodies(object compObj) {
        Component2 c = (Component2)compObj;
        object bodiesInfo;
        object[] bodies = (object[])c.GetBodies3((int)swBodyType_e.swSolidBody, out bodiesInfo);
        return (bodies == null) ? new object[0] : bodies;
    }

    // Ref planes of the doc: name + assembly-space normal (RefPlane.Transform Z row).
    public static string ListRefPlanes(object modelObj) {
        ModelDoc2 m = (ModelDoc2)modelObj;
        Feature f = (Feature)m.FirstFeature();
        StringBuilder sb = new StringBuilder();
        while (f != null) {
            if (f.GetTypeName2() == "RefPlane") {
                RefPlane rp = (RefPlane)f.GetSpecificFeature2();
                double[] a = (double[])((MathTransform)rp.Transform).ArrayData;
                sb.AppendLine(string.Format("'{0}' normal=({1:F3},{2:F3},{3:F3}) origin=({4:F1},{5:F1},{6:F1})mm",
                    f.Name, a[6],a[7],a[8], a[9]*1000,a[10]*1000,a[11]*1000));
            }
            f = (Feature)f.GetNextFeature();
        }
        return sb.ToString();
    }
    // Which top-level components' boxes contain point (mm, assembly space)?
    public static string LocatePoint(object asmModelObj, double xMM, double yMM, double zMM, double tolMM) {
        AssemblyDoc asm = (AssemblyDoc)asmModelObj;
        object[] comps = (object[])asm.GetComponents(true);
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < comps.Length; i++) {
            Component2 c = (Component2)comps[i];
            double[] b = null;
            try { b = (double[])c.GetBox(false,false); } catch { continue; }
            if (b == null) continue;
            if (xMM >= b[0]*1000-tolMM && xMM <= b[3]*1000+tolMM &&
                yMM >= b[1]*1000-tolMM && yMM <= b[4]*1000+tolMM &&
                zMM >= b[2]*1000-tolMM && zMM <= b[5]*1000+tolMM)
                sb.AppendLine(c.Name2);
        }
        return sb.ToString();
    }

    public static object GetRefPlaneFeature(object modelObj, string name) {
        ModelDoc2 m = (ModelDoc2)modelObj;
        Feature f = (Feature)m.FirstFeature();
        while (f != null) {
            if (f.GetTypeName2() == "RefPlane" && f.Name == name) return f;
            f = (Feature)f.GetNextFeature();
        }
        return null;
    }
}

// Typed cosworks BC + results helpers for assembly studies.
public static class SwFea2 {
    public static object[] AddFixed(object lrmObj, object[] faces) {
        ICWLoadsAndRestraintsManager lrm = (ICWLoadsAndRestraintsManager)lrmObj;
        int err;
        object r = lrm.AddRestraint((int)swsRestraintType_e.swsRestraintTypeFixed, faces, null, out err);
        return new object[]{ r, err };
    }
    public static object[] AddForceDir(object lrmObj, object[] faces, object refFace, double d1, double d2, double d3) {
        ICWLoadsAndRestraintsManager lrm = (ICWLoadsAndRestraintsManager)lrmObj;
        int err;
        CWForce f = (CWForce)lrm.AddForce((int)swsForceType_e.swsForceTypeForceOrMoment, faces, refFace, out err);
        if (f == null) return new object[]{ null, err, -1 };
        f.ForceBeginEdit();
        f.SetForceComponentValues2(true, true, true, d1, d2, d3);
        int ee = f.ForceEndEdit();
        return new object[]{ f, err, ee };
    }
    // Gravity on a ref-plane feature; (d1,d2,d3) = (alongDir1, alongDir2, normal) m/s2.
    // Returns [gravObj, addErr, endEditErr, r1, r2, r3] with r* = read-back values.
    public static object[] AddGravity(object lrmObj, object refPlaneFeat, double d1, double d2, double d3) {
        ICWLoadsAndRestraintsManager lrm = (ICWLoadsAndRestraintsManager)lrmObj;
        int err;
        CWGravity gv = lrm.AddGravity(refPlaneFeat, out err);
        if (gv == null) return new object[]{ null, err, -1, 0.0, 0.0, 0.0 };
        gv.GravityBeginEdit();
        gv.SetGravitationalAcclerationValues(d1, d2, d3);
        int ee = gv.GravityEndEdit();
        double r1, r2, r3;
        gv.GetGravitationalAcclerationValues(out r1, out r2, out r3);
        return new object[]{ gv, err, ee, r1, r2, r3 };
    }
    // Global von Mises max: returns [arr, err]; arr[3] = max (Pa).
    public static object[] MinMaxStress(object resultsObj) {
        ICWResults r = (ICWResults)resultsObj;
        int err;
        object v = r.GetMinMaxStress(9, 0, 1, null, 0, out err);
        return new object[]{ v, err };
    }
    public static object[] MinMaxDisp(object resultsObj) {
        ICWResults r = (ICWResults)resultsObj;
        int err;
        object v = r.GetMinMaxDisplacement(3, 1, null, 0, out err);
        return new object[]{ v, err };
    }
    // FOS. allBodies=true -> whole model; else restrict to entities (bodies or faces).
    public static object[] MinMaxFOS(object resultsObj, bool allBodies, object entities) {
        ICWResults r = (ICWResults)resultsObj;
        int err;
        object v = r.GetMinMaxFactorOfSafety(allBodies, entities, 0, 0, out err);
        return new object[]{ v, err };
    }
    static string Fmt(object v) {
        if (v == null) return "(null)";
        if (v is Array) {
            System.Text.StringBuilder sb = new System.Text.StringBuilder("[");
            foreach (object o in (Array)v) { sb.Append(o); sb.Append("; "); }
            sb.Append("]");
            return sb.ToString();
        }
        return v.ToString();
    }
    // FOS restricted to each top-level component's bodies. One line per component.
    public static string FOSByComponent(object asmModelObj, object resultsObj) {
        AssemblyDoc asm = (AssemblyDoc)asmModelObj;
        ICWResults r = (ICWResults)resultsObj;
        object[] comps = (object[])asm.GetComponents(true);
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < comps.Length; i++) {
            Component2 c = (Component2)comps[i];
            object bodiesInfo;
            object[] bodies = null;
            try { bodies = (object[])c.GetBodies3((int)swBodyType_e.swSolidBody, out bodiesInfo); } catch {}
            if (bodies == null || bodies.Length == 0) { sb.AppendLine(c.Name2 + " : (no bodies)"); continue; }
            try {
                int err;
                object v = r.GetMinMaxFactorOfSafety(false, bodies, 0, 0, out err);
                sb.AppendLine(c.Name2 + " : err=" + err + " " + Fmt(v));
            } catch (Exception e) {
                sb.AppendLine(c.Name2 + " : EXC " + e.Message);
            }
        }
        return sb.ToString();
    }
    // Node location from study mesh. Returns [rc, x, y, z].
    public static double[] NodeLoc(object studyObj, int node) {
        ICWStudy s = (ICWStudy)studyObj;
        CWMesh m = s.Mesh;
        double x, y, z;
        int rc = m.GetNodeLocation(node, out x, out y, out z);
        return new double[]{ rc, x, y, z };
    }
    public static string FmtArr(object v) { return Fmt(v); }
    // Mesh settings + info
    public static string MeshInfo(object studyObj) {
        ICWStudy s = (ICWStudy)studyObj;
        CWMesh m = s.Mesh;
        return string.Format("mesher={0} quality={1} unit={2} elemSize={3:G5} tol={4:G5} max={5:G5} min={6:G5} growth={7:G4} circ={8} nodes={9} elems={10} failed={11} state={12}",
            m.MesherType, m.Quality, m.Unit, m.ElementSize, m.Tolerance, m.MaxElementSize, m.MinElementSize,
            m.GrowthRatio, m.MinElementsInCircle, m.NodeCount, m.ElementCount, m.IsMeshFailed2, m.MeshState);
    }
    public static void SetupMesh(object studyObj, int mesherType, int quality) {
        ICWStudy s = (ICWStudy)studyObj;
        CWMesh m = s.Mesh;
        m.MesherType = mesherType;
        m.Quality = quality;
    }
    public static string FailedComps(object studyObj) {
        ICWStudy s = (ICWStudy)studyObj;
        CWMesh m = s.Mesh;
        int n;
        object fc = m.GetFailedComponents(out n);
        string res = "nFailed=" + n;
        if (fc is object[]) foreach (object o in (object[])fc) res += " | " + o;
        else if (fc is string[]) foreach (string o in (string[])fc) res += " | " + o;
        return res;
    }
    public static string GlobalContact(object studyObj) {
        ICWStudy s = (ICWStudy)studyObj;
        CWContactManager cm = s.ContactManager;
        int t, o;
        cm.GetGlobalContact(out t, out o);
        return string.Format("globalContact type={0} option={1}", t, o);
    }
    // List simulation solid components + per-body material names
    public static string ListSolidComps(object studyObj) {
        ICWStudy s = (ICWStudy)studyObj;
        CWSolidManager sm = s.SolidManager;
        StringBuilder sb = new StringBuilder();
        int n = sm.ComponentCount;
        for (int i = 0; i < n; i++) {
            int err;
            CWSolidComponent sc = sm.GetComponentAt(i, out err);
            if (sc == null) continue;
            sb.Append(string.Format("SC{0} '{1}' bodies={2}", i, sc.ComponentName, sc.SolidBodyCount));
            for (int b = 0; b < sc.SolidBodyCount; b++) {
                int e2;
                CWSolidBody sb2 = sc.GetSolidBodyAt(b, out e2);
                if (sb2 == null) continue;
                string mat = "?";
                try { CWMaterial cm = sb2.GetSolidBodyMaterial(); if (cm != null) mat = cm.MaterialName; } catch {}
                sb.Append(string.Format(" [{0}:{1}]", sb2.SolidBodyName, mat));
            }
            sb.AppendLine();
        }
        return sb.ToString();
    }
    // Assign a custom isotropic material to all bodies of components whose name contains substr.
    // Units SI (N/m2, kg/m3). Returns "set=<n> rc=<...>" summary.
    public static string SetCompMaterial(object studyObj, string substr, string matName,
                                         double ex, double nuxy, double dens, double sigyld, double sigxt) {
        ICWStudy s = (ICWStudy)studyObj;
        CWSolidManager sm = s.SolidManager;
        StringBuilder sb = new StringBuilder();
        int cnt = 0;
        for (int i = 0; i < sm.ComponentCount; i++) {
            int err;
            CWSolidComponent sc = sm.GetComponentAt(i, out err);
            if (sc == null) continue;
            if (sc.ComponentName.IndexOf(substr, StringComparison.OrdinalIgnoreCase) < 0) continue;
            for (int b = 0; b < sc.SolidBodyCount; b++) {
                int e2;
                CWSolidBody sb2 = sc.GetSolidBodyAt(b, out e2);
                if (sb2 == null) continue;
                CWMaterial m = sb2.GetDefaultMaterial();
                if (m == null) { sb.Append(" [b" + b + ":nullmat]"); continue; }
                m.MaterialUnits = 0; // SI
                m.MaterialName = matName;
                m.SetPropertyByName("EX", ex, 0);
                m.SetPropertyByName("NUXY", nuxy, 0);
                m.SetPropertyByName("DENS", dens, 0);
                m.SetPropertyByName("SIGYLD", sigyld, 0);
                m.SetPropertyByName("SIGXT", sigxt, 0);
                int rc = sb2.SetSolidBodyMaterial(m);
                sb.Append(" [" + sc.ComponentName + "/b" + b + ":rc=" + rc + "]");
                cnt++;
            }
        }
        return "set=" + cnt + sb.ToString();
    }
    // Set draft/high quality on all bodies of components whose name contains substr. Returns count.
    public static int SetBodyQuality(object studyObj, string substr, int quality) {
        ICWStudy s = (ICWStudy)studyObj;
        CWSolidManager sm = s.SolidManager;
        int cnt = 0;
        for (int i = 0; i < sm.ComponentCount; i++) {
            int err;
            CWSolidComponent sc = sm.GetComponentAt(i, out err);
            if (sc == null) continue;
            if (sc.ComponentName.IndexOf(substr, StringComparison.OrdinalIgnoreCase) < 0) continue;
            for (int b = 0; b < sc.SolidBodyCount; b++) {
                int e2;
                CWSolidBody sb2 = sc.GetSolidBodyAt(b, out e2);
                if (sb2 != null && sb2.SetMeshQuality(quality)) cnt++;
            }
        }
        return cnt;
    }
}
"@

function Connect-SWPid([int]$SwPid) {
    $sw = [SwRot]::GetByPid($SwPid)
    if ($null -eq $sw) { throw "No ROT entry for SolidWorks_PID_$SwPid" }
    [SwRaw]::PutProp($sw,'Visible',$true)
    return $sw
}

function Open-Doc($sw, $path) {
    [string]$p = $path
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
    $cw = [SwRaw]::Invoke0($addin,'CosmosWorks',$true)
    if ($null -eq $cw) { throw "CosmosWorks unwrap returned null" }
    return $cw
}

Write-Host "fea_asm_common loaded (SwRot + SwAsm + SwFea2 + Connect-SWPid/Open-Doc/Load-Sim)"
