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
  <img src="MoPhong_DongHoc/figs/kin_arm_schematic.png" width="49%" alt="Delta robot kinematic schematic">
  <img src="MoPhong_DongHoc/figs/pSTT07_workspace_cloud.png" width="49%" alt="Reachable workspace point cloud">
</p>

<p align="center"><b>Figure 1.</b> Kinematic schematic of one arm (left) and the reachable workspace point cloud enclosing the target Ø800 × 250 mm cylinder (right).</p>

## 2. Kinematics verification (MATLAB R2025a)

The inverse and forward kinematics were implemented independently and cross-checked:

- Round-trip error ‖P − FK(IK(P))‖ ≤ **6.2 × 10⁻¹³ mm** over 3000 sample points.
- Reachable radius 650 mm at z = −925 mm (requirement: 400 mm).
- Jacobian: **no singular points** inside the workspace; condition number κ(J) max 2.75, average 2.13; minimum forearm–bicep transmission angle 49.8°.

<p align="center">
  <img src="MoPhong_DongHoc/figs/p2_roundtrip_hist.png" width="49%" alt="FK/IK round-trip error histogram">
  <img src="MoPhong_DongHoc/figs/p4_cond_map.png" width="49%" alt="Jacobian condition-number map">
</p>

<p align="center"><b>Figure 2.</b> FK/IK closed-loop error distribution (left) and Jacobian condition-number map on the y = 0 section (right).</p>

## 3. Motion & trajectory

A 6-block Simulink model (trajectory generator → IK → FK → Jacobian → joint velocity → logging) reproduces the pick-and-place cycle (solver ode3, Δt = 2 ms, 601 samples).

<p align="center">
  <img src="MoPhong_DongHoc/figs/simulink_model.png" width="49%" alt="Simulink kinematics model">
  <img src="MoPhong_DongHoc/figs/p5_joint_profiles.png" width="49%" alt="Joint position, velocity and acceleration profiles">
</p>

<p align="center"><b>Figure 3.</b> Simulink model (left) and joint position / velocity / acceleration profiles over one 1.2 s cycle, peak joint speed 30.1 rpm (right).</p>

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
  <img src="MoPhong_Luc/figs/so_do_phan_bo_luc.png" width="49%" alt="Free-body and force distribution diagram">
  <img src="MoPhong_Luc/figs/bieu_do_noi_luc.png" width="49%" alt="Internal force diagrams N, Q, M">
</p>

<p align="center"><b>Figure 4.</b> Free-body and force-distribution diagram (left) and internal-force diagrams N / Q / M for the bicep and forearm (right).</p>

<p align="center">
  <img src="MoPhong_Luc/figs/pose_fmax_workspace.png" width="49%" alt="Peak forearm force over the workspace">
  <img src="MoPhong_Luc/figs/joint_torques.png" width="49%" alt="Joint torque over the trajectory">
</p>

<p align="center"><b>Figure 5.</b> Peak forearm force mapped over the workspace (left) and joint torque along the trajectory (right).</p>

## 5. Actuator selection

The required joint torque is split into static and dynamic terms and multiplied by a 1.5 safety factor (per the advisor's method), including the bicep weight and inertia (6.9 kg, from CAD) and the reflected rotor inertia *J*₍mot₎·*i*²:

| Criterion | Result | Margin |
|---|---|---|
| Required torque M_yc = (M_static 35.8 + M_dynamic 55.0) × 1.5 | 136.3 N·m ≤ T2B 230 N·m | **1.69 ×** |
| RMS torque M_rms | 53.4 N·m ≤ 110 N·m | **2.06 ×** |
| Joint speed | 30.1 rpm ≤ 88 rpm | pass |

The initially considered TPM-010S-061T (T2B 80 N·m) is rejected — M_yc 112.5 N·m > 80 N·m. The high-torque **TPMA010S-055T** passes all three criteria.

<p align="center">
  <img src="MoPhong_Luc/figs/torque_sizing.png" width="49%" alt="Torque sizing chart">
  <img src="MoPhong_Luc/figs/gearbox_compare.png" width="49%" alt="Gearbox option comparison">
</p>

<p align="center"><b>Figure 6.</b> Torque-sizing chart (left) and comparison of the four size-010 gearbox options (right).</p>

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
  <img src="MoPhong_Ben/figs/fea_dr006_resym_vonMises.png" width="49%" alt="FEA von Mises stress, elbow clevis">
  <img src="MoPhong_Ben/figs/fea_dr007_vonMises.png" width="49%" alt="FEA von Mises stress, moving platform">
</p>

<p align="center">
  <img src="MoPhong_Ben/figs/fea_dr005b_vonMises.png" width="49%" alt="FEA von Mises stress, upper-arm link">
  <img src="MoPhong_Ben/figs/fea_dr001_1_vonMises.png" width="49%" alt="FEA von Mises stress, base plate">
</p>

<p align="center"><b>Figure 7.</b> von Mises stress plots — elbow clevis, moving platform, upper-arm link and base plate. The whole-robot minimum factor of safety over the entire workspace is <b>7.1</b>.</p>

---

## 8. Thesis chapters

| Chapter | Title | What it covers |
|---|---|---|
| **1** | Overview | Motivation; state of the art of Delta robots; general and specific objectives; research object and scope; research method; report outline. |
| **2** | Theoretical basis | Delta structure and working principle; geometric model and coordinate frames; kinematic foundations — degrees of freedom, geometric parameters, per-limb closed-loop equations, forward kinematics, inverse kinematics, model-consistency check; basis for the vacuum-gripper design — joint layout and suction-cup arrangement, suction force and vacuum pressure. |
| **3** | Workspace computation & simulation | Objectives, scope and input data; the L9 survey parameter set and the test trajectory; point-density workspace simulation — joint-space sweep, volume and largest-cross-section estimate; verification of the target Ø800 × 250 mm cylinder, of the pick-and-place trajectory, and of the joint velocity / acceleration bounds. |
| **4** | Load analysis, material & drivetrain selection | Material selection; part masses from CAD; load data and force-distribution model; internal-force analysis of the links — free-body model, axial forces, motor–gearbox selection; FEA strength check of the main load-bearing parts; overall strength summary versus requirements. |
| **5** | Electrical & control system design | Machine-vision system — colour/shape recognition algorithm and test results on sample images; camera–robot–conveyor coordinate transforms; control-board architecture. |
| **6** | Conclusion & future work | Results, limitations of the work, and development directions. |

---

<sub>The thesis document, third-party vendor CAD and reference papers are not included in this repository (see `.gitignore`). Academic work — all rights reserved; please cite if reused. © JohnNguyen205, HCMUTE.</sub>
