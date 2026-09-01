# Structural simulation (FEA) — Delta Robot

SolidWorks Simulation static studies on the load-bearing parts, driven over COM
from PowerShell. Loads are the peak dynamic forces from `../ForceAnalysis`
(payload 2 kg). Each study includes a mesh-convergence sweep; a second pass
applies the worst-case multi-pose loads over the whole workspace.

## Contents

| File | Purpose |
|---|---|
| `fea_common.ps1` | shared helper (loads the compiled `SwSim` / `SwGeom` / `SwFea` classes) |
| `fea_run.ps1` | run one part: restraints, force, mesh sweep, solve, export fringe PNG |
| `run_parts.ps1` | batch wrapper over all parts (single-pose loads) |
| `run_parts_pose.ps1` | batch wrapper with the worst-case multi-pose loads (× 1.49) |
| `fea_run_v2.ps1`, `run_parts_v2.ps1` | studies embedded into `_FEA` part copies |
| `KETQUA_BEN.md` | single-pose results summary (Vietnamese) |
| `KETQUA_BEN_DAPOSE.md` | multi-pose (full-workspace) results (Vietnamese) |
| `THUYETMINH_MOPHONG_BEN_CHITIET.md` | detailed method + boundary conditions |
| `figs/`, `out/` | von Mises fringe PNGs / convergence CSVs / face-index dumps |

## How to run

```
powershell -ExecutionPolicy Bypass -File run_parts.ps1
powershell -ExecutionPolicy Bypass -File run_parts_pose.ps1
```

Do **not** call `fea_run.ps1` directly with array arguments via `powershell -File`
— commas get stripped; always go through `run_parts*.ps1`.

## Key results

| Part | von Mises (worst pose) | Factor of safety |
|---|---|---|
| DR-006 Elbow clevis | 38.8 MPa | 7.1 (governing) |
| DR-005-2 Upper-arm link | — | 43.5 |
| DR-007 Moving platform | — | 14.7 |
| DR-001-1 Base plate (Al 6061-T6) | — | ≈ 1268 |
| DR-001-3 Ceiling lid (Al 6061-T6) | — | ≈ 72 |

Whole-robot minimum factor of safety over the entire workspace: **7.1**.
Peak von Mises is mesh-sensitive at unfilleted load holes (numerical
singularities); stress / FOS is the primary output, displacement secondary.
