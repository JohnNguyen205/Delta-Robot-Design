# Delta Robot Design — 3-DOF Parallel Robot Mechanical Design

> **Graduation thesis (đồ án tốt nghiệp)** — Ho Chi Minh City University of Technology and Education (HCMUTE).
> Complete mechanical design of a ceiling-mounted 3-DOF Delta parallel robot for high-speed pick-and-place, benchmarked against the ABB IRB 360 FlexPicker.

This repository contains the SolidWorks CAD model, the MATLAB analysis and simulation code, the finite-element (FEA) results, and the machining drawings. Every conclusion is backed by data read back from the model or the solver — no assumed figures.

---

## Overview

| | |
|---|---|
| Architecture | 3-DOF Delta (parallel), rotational actuators, ceiling-mounted |
| Payload | **2 kg** |
| Workspace | cylinder **Ø800 × 250 mm**, centred ≈ 925 mm below the shoulder plane |
| Pick-and-place cycle | 1.2 s (quintic trajectory) |
| Peak TCP speed / acceleration | ≈ 1875 mm/s / ≈ 1.18 g |
| Actuator | Wittenstein TPMA010S-055T gearmotor, ratio *i* = 55 |
| Structural material | Aluminium 6061-T6 (all machined parts) |
| Total mass | 122.4 kg (CAD model), ≈ 140 kg estimated real |
| Minimum factor of safety (whole robot, full workspace) | **7.1** |

---

## 1. Kinematic architecture

| Symbol | Meaning | Value |
|---|---|---|
| L₁ | upper-arm (bicep) length: shoulder axis → elbow ball line | 407.5 mm |
| L₂ | forearm length, ball-centre to ball-centre | 1000.0 mm |
| R − r | base radius − moving-platform radius | 226.4 mm |
| r | moving-platform radius | 120.6 mm |

<p align="center">
  <img src="MoPhong_DongHoc/figs/kin_arm_schematic.png" width="46%" alt="Delta robot kinematic schematic">
  <img src="MoPhong_DongHoc/figs/pSTT07_workspace_cloud.png" width="46%" alt="Reachable workspace point cloud">
</p>

**Figure 1.** Kinematic schematic of one arm (left) and the reachable workspace point cloud enclosing the target Ø800 × 250 mm cylinder (right).

## 2. Kinematics verification (MATLAB R2025a)

The inverse and forward kinematics were implemented independently and cross-checked:

- Round-trip error ‖P − FK(IK(P))‖ ≤ **6.2 × 10⁻¹³ mm** over 3000 sample points.
- Reachable radius 650 mm at z = −925 mm (requirement: 400 mm).
- Jacobian: **no singular points** inside the workspace; condition number κ(J) max 2.75, average 2.13; minimum forearm–bicep transmission angle 49.8°.

<p align="center">
  <img src="MoPhong_DongHoc/figs/p2_roundtrip_hist.png" width="46%" alt="FK/IK round-trip error histogram">
  <img src="MoPhong_DongHoc/figs/p4_cond_map.png" width="46%" alt="Jacobian condition-number map">
</p>

**Figure 2.** FK/IK closed-loop error distribution (left) and Jacobian condition-number map on the y = 0 section (right).

## 3. Motion & trajectory

A 6-block Simulink model (trajectory generator → IK → FK → Jacobian → joint velocity → logging) reproduces the pick-and-place cycle (solver ode3, Δt = 2 ms, 601 samples).

<p align="center">
  <img src="MoPhong_DongHoc/figs/simulink_model.png" width="46%" alt="Simulink kinematics model">
  <img src="MoPhong_DongHoc/figs/p5_joint_profiles.png" width="46%" alt="Joint position/velocity/acceleration profiles">
</p>

**Figure 3.** Simulink model (left) and joint position / velocity / acceleration profiles over one 1.2 s cycle (right); peak joint speed 30.1 rpm.

## 4. Force & dynamic analysis

Forearm links are solved as two-force members; joint torques are obtained through the Jacobian. Loads are swept over the whole workspace (centre + 24 edge points + 4 waypoints × 26 peak-acceleration directions) and the worst case is retained.

| Quantity | Nominal (centre pose) | Worst case (workspace edge, R400 / z−1050) |
|---|---|---|
| End-effector force F_ee | 175.8 N | 176.1 N |
| Forearm-pair force | 122.7 N (61.3 N per rod) | **182.4 N** (× 1.49) |
| Bicep bending moment | ≈ 50 N·m | **74.3 N·m** (× 1.49) |
| Platform joint torque τ | 48.4 N·m | — |
| Jacobian condition number | — | 2.75 (no singularity) |

<p align="center">
  <img src="MoPhong_Luc/figs/so_do_phan_bo_luc.png" width="46%" alt="Free-body / force distribution diagram">
  <img src="MoPhong_Luc/figs/bieu_do_noi_luc.png" width="46%" alt="Internal force diagrams N, Q, M">
</p>

**Figure 4.** Free-body and force-distribution diagram (left) and internal-force diagrams N / Q / M for the bicep and forearm (right).

<p align="center">
  <img src="MoPhong_Luc/figs/pose_fmax_workspace.png" width="46%" alt="Peak forearm force over the workspace">
  <img src="MoPhong_Luc/figs/joint_torques.png" width="46%" alt="Joint torque over the trajectory">
</p>

**Figure 5.** Peak forearm force mapped over the workspace (left) and joint torque along the trajectory (right).

## 5. Actuator selection

The required joint torque is split into static and dynamic terms and multiplied by a 1.5 safety factor (per the advisor's method), including the bicep weight and inertia (6.9 kg, from CAD) and the reflected rotor inertia *J*₍mot₎·*i*²:

| Criterion | Result | Margin |
|---|---|---|
| Required torque M_yc = (M_static 35.8 + M_dynamic 55.0) × 1.5 | 136.3 N·m ≤ T2B 230 N·m | **1.69 ×** |
| RMS torque M_rms | 53.4 N·m ≤ 110 N·m | **2.06 ×** |
| Joint speed | 30.1 rpm ≤ 88 rpm | pass |

The initially considered TPM-010S-061T (T2B 80 N·m) is rejected — M_yc 112.5 N·m > 80 N·m. The high-torque **TPMA010S-055T** passes all three criteria.

<p align="center">
  <img src="MoPhong_Luc/figs/torque_sizing.png" width="46%" alt="Torque sizing chart">
  <img src="MoPhong_Luc/figs/gearbox_compare.png" width="46%" alt="Gearbox option comparison">
</p>

**Figure 6.** Torque-sizing chart (left) and comparison of the four size-010 gearbox options (right).

## 6. Structure & materials

- **All machined parts: aluminium 6061-T6.** The base was first designed in ASTM A36 steel but was too heavy, so all three base blocks were reassigned to 6061-T6 (−128.8 kg).
- Forearm connecting rods: carbon fibre. Ball-joint rod ends (`60645K471`): alloy steel.
- The base plate (`DR-001`) is split into three separate fabrication blocks — mounting plate, welded frame, and hanging lid — bolted/welded together.
- Part numbering: `DR-000` main assembly, `DR-001…DR-007` machined parts; purchased parts keep their vendor names.

## 7. Structural validation (FEA)

SolidWorks Simulation, static studies on the load-bearing parts with the peak dynamic loads from §4, including a mesh-convergence sweep and a full-workspace multi-pose sweep.

| Part | von Mises (worst pose) | Factor of safety |
|---|---|---|
| DR-006 Elbow clevis | 38.8 MPa | **7.1** (governing) |
| DR-005-2 Upper-arm link | — | 43.5 |
| DR-007 Moving platform | — | 14.7 |
| DR-001-1 Base plate (aluminium) | — | ≈ 1268 |
| DR-001-3 Ceiling lid (aluminium) | — | ≈ 72 |

<p align="center">
  <img src="MoPhong_Ben/figs/fea_dr006_resym_vonMises.png" width="46%" alt="FEA von Mises — elbow clevis">
  <img src="MoPhong_Ben/figs/fea_dr007_vonMises.png" width="46%" alt="FEA von Mises — moving platform">
</p>

<p align="center">
  <img src="MoPhong_Ben/figs/fea_dr005b_vonMises.png" width="46%" alt="FEA von Mises — upper-arm link">
  <img src="MoPhong_Ben/figs/fea_dr001_1_vonMises.png" width="46%" alt="FEA von Mises — base plate">
</p>

**Figure 7.** von Mises stress plots: elbow clevis, moving platform, upper-arm link and base plate. The whole-robot minimum factor of safety over the entire workspace is **7.1**.

---

## 8. Design pipeline (8 stages)

The whole thesis — including the report structure and the drawing set — follows this linear pipeline; each stage consumes the output of the previous one and concludes as **pass / conditional pass / not evaluated**.

| # | Stage | Content | Artefacts |
|---|---|---|---|
| **I** | Theory basis, task, targets | Delta-robot review, problem statement, target parameters | report Ch. 1 |
| **II** | Geometry & kinematic parameters | choose L₁, L₂, R−r, r for the Ø800 × 250 workspace; check transmission angle / condition number | `MoPhong_DongHoc/params.m` |
| **III** | Forward / inverse kinematics & Jacobian | implement and verify IK/FK (round-trip ≈ 10⁻¹³ mm), singularity analysis | `delta_ik.m`, `delta_fk.m`, `delta_jacobian.m`, `p4_singularity.m` |
| **IV** | Motion simulation & trajectory | workspace, quintic trajectory, 6-block Simulink model, animation | `p3_workspace.m`, `p5_trajectory.m`, `p6_animate.m`, `delta_kinematics.slx` |
| **V** | Force & dynamic analysis | free-body diagram, internal-force diagrams N/Q/M, multi-pose load sweep | `MoPhong_Luc/force_analysis.m`, `force_diagrams.m`, `force_poses.m` |
| **VI** | Actuator selection | M_yc / M_rms / speed criteria; reject TPM-010S-061T, select TPMA010S-055T | `MoPhong_Luc/ThuyetMinh_ChonDongCo.md` |
| **VII** | Material selection & FEA | choose 6061-T6; FEA of the load-bearing parts + mesh convergence + multi-pose sweep | `MoPhong_Ben/KETQUA_BEN.md`, `KETQUA_BEN_DAPOSE.md` |
| **VIII** | CAD assembly, machining drawings & BOM | finalise `DR-000`, export A3 first-angle drawings (TCVN) for the 8 machined parts, build the BOM | `DeltaRobot_Final/`, `BanVe_GiaCong/` |

---

## 9. Repository layout

```
DeltaRobot_Final/      Active CAD model (SolidWorks 2023)
                       DR-000_Delta-Robot_V0.SLDASM — main assembly
                       DR-001…DR-007 — machined parts (DR-001 split into 3 files)
                       Frame.SLDPRT — steel support frame
                       + TPMA gearbox, connecting rods, ball joints

MoPhong_DongHoc/       Kinematics simulation (MATLAB R2025a + Robotics System Toolbox)
                       params.m • delta_ik/fk/jacobian.m • p3…p6 • delta_gui.m
                       delta_kinematics.slx (Simulink) • figs/ • KETQUA_DONGHOC.md

MoPhong_Luc/           Force analysis & actuator selection (MATLAB)
                       force_analysis.m • force_poses.m • force_diagrams.m
                       ThuyetMinh_ChonDongCo.md

MoPhong_Ben/           Structural FEA (SolidWorks Simulation via COM)
                       fea_run*.ps1 • figs/ • KETQUA_BEN.md • KETQUA_BEN_DAPOSE.md
                       THUYETMINH_MOPHONG_BEN_CHITIET.md
                       (solver .CWR/.LOG files are not tracked — regenerable)

BanVe_GiaCong/         Machining drawings for the 8 machined parts
                       BanVe_ChinhSua_V7/ — .SLDDRW + .pdf (A3, first-angle, TCVN)
                       make_drawing*.ps1 — drawing regeneration scripts

TIENDO.md             Daily progress log (Vietnamese)
CLAUDE.md             Workflow & automation notes
```

> The thesis document itself (`BaoCao/` — DOCX / PDF / PPTX) is **not** published here; its key content is summarised in this README.

## 10. Toolchain

| Task | Tool |
|---|---|
| CAD & assembly | SolidWorks 2023 SP3 (automated via COM / PowerShell) |
| FEA | SolidWorks Simulation (COM) — mesh convergence, multi-pose sweep |
| Kinematics / forces / trajectory | MATLAB R2025a (+ Robotics System Toolbox), Simulink |
| Document generation | pandoc (Markdown → OMML/DOCX), PyMuPDF (PDF assembly & editing) |

## 11. Not included

For copyright and size reasons, the following are excluded (see `.gitignore`):

- The thesis document (`BaoCao/` — report DOCX/PDF, presentation PPTX).
- Reference research papers and the ABB IRB 360 catalogue (`DeltaRobot_Document/`).
- Wittenstein vendor CAD & catalogues (`Catalog_Wittenstein/`), McMaster-Carr purchased-part CAD (`LinhKien/`).
- FEA solver result files `.CWR` / `.LOG` (≈ 13 GB, regenerable from the scripts in `MoPhong_Ben/`).
- Simulink build cache (`slprj/`), `.bmp` previews, and `*_backup_*` copies.

## 12. License & usage

This is academic work (a graduation thesis). The analysis code and models are the author's own; all rights reserved. Reuse is permitted for study and non-commercial research — please cite when reusing. Third-party trade names and CAD belong to their respective owners.

**Author:** JohnNguyen205 — HCMUTE.
