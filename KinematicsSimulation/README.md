# Kinematics simulation — Delta Robot (MATLAB R2025a)

Self-contained inverse/forward kinematics, workspace, singularity and trajectory
study for the 3-DOF Delta robot. All kinematic constants come from `params.m`
(single source) and must stay in sync with the CAD design values.

## Contents

| File | Purpose |
|---|---|
| `params.m` | kinematic constants: `L1=407.5`, `L2=1000.0`, `R=347.0`, `r=120.6` mm, `phi=(-90,30,150)°` |
| `delta_ik.m` / `delta_fk.m` | inverse (P → θ, closed form) / forward (θ → P, trilateration) kinematics |
| `delta_jacobian.m` | velocity Jacobian `J = A⁻¹B`, condition number, transmission angle, Type I/II singularity flags |
| `p3_workspace.m` | joint-sweep workspace point cloud + volume / largest cross-section |
| `p4_singularity.m`, `p4b_cond3d.m` | κ(J) map over the working region |
| `p5_trajectory.m` | quintic pick-and-place trajectory, joint bound check |
| `p6_animate.m`, `delta_gui.m`, `deltaviz.m` | animation and interactive viewer |
| `verify_target_workspace.m` | check the Ø800 × 250 mm target cylinder is fully reachable |
| `THUYETMINH_DONGHOC_CHITIET.md`, `TINHTOAN_DONGHOC_CHITIET.md` | detailed derivation and worked calculation (Vietnamese) |
| `KETQUA_DONGHOC.md` | phase-by-phase results log |
| `figs/`, `out/` | generated figures / logs / `.mat` |

## How to run

```
matlab -batch "cd('<repo>/KinematicsSimulation'); test_p1_ik_fk"
matlab -batch "cd('<repo>/KinematicsSimulation'); p3_workspace"
matlab -batch "cd('<repo>/KinematicsSimulation'); p5_trajectory"
```

`delta_gui.m` renders only on the live MATLAB desktop, not in `-batch`.

## Key results

- FK(IK(P)) round-trip error ≤ 6.2 × 10⁻¹³ mm over 3000 points.
- Reachable radius 650 mm at z = −925 mm (requirement 400 mm).
- Jacobian: no singular points in the workspace; κ(J) max 2.75, avg 2.13;
  minimum forearm–bicep transmission angle 49.8°.
