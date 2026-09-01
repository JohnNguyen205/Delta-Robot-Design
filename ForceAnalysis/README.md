# Force analysis & actuator selection — Delta Robot (payload 2 kg)

Force study that (1) produces the **real loads** used as FEA input and
(2) **checks the gearmotor choice** by the static + dynamic × safety-factor
moment method (advisor's format): forearm links solved as two-force members,
joint torques through the Jacobian, motor sizing including bicep weight/inertia
(6.9 kg from CAD) and reflected rotor inertia `J_mot·i²`, safety factor 1.5.

## Contents

| File | Purpose |
|---|---|
| `params.m`, `delta_ik.m`, `delta_jacobian.m` | kinematic constants + IK/Jacobian (copy kept in sync with `../KinematicsSimulation`) |
| `force_analysis.m` | forearm forces + static/dynamic joint moments + motor–gearbox check |
| `force_poses.m` | multi-pose load sweep (centre + 24 workspace-edge points + waypoints × peak-accel dirs), worst case retained |
| `force_diagrams.m` | free-body diagram + N/Q/M internal-force diagrams |
| `moment_angle_sweep.m` | joint moment vs tilt angle, CSV/MAT + peak plot |
| `fea_load_params.m` | exports the peak loads consumed by `../FEA_Simulation` |
| `ThuyetMinh_ChonDongCo.md` | detailed motor-selection write-up (Vietnamese) |
| `figs/`, `out/` | result figures / logs / `.mat` |

## How to run

```
matlab -batch "cd('<repo>/ForceAnalysis'); force_analysis"
matlab -batch "cd('<repo>/ForceAnalysis'); force_poses"
matlab -batch "cd('<repo>/ForceAnalysis'); force_diagrams"
```

## Key results

| Quantity | Nominal (centre) | Worst case (edge, R400 / z−1050) |
|---|---|---|
| End-effector force F_ee | 175.8 N | 176.1 N |
| Forearm-pair force | 122.7 N (61.3 N/rod) | 182.4 N (× 1.49) |
| Bicep bending moment | ≈ 50 N·m | 74.3 N·m (× 1.49) |
| Jacobian condition number | — | 2.75 (no singularity) |

Motor check (TPMA010S-055T, i = 55): required M_yc = (35.8 + 55.0) × 1.5 =
136.3 N·m ≤ T2B 230 (1.69×); M_rms 53.4 ≤ 110 (2.06×); 30.1 rpm ≤ 88 rpm —
all pass. The initially considered TPM-010S-061T (T2B 80 N·m) fails.
