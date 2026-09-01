# Machining drawings — Delta Robot

Fabrication drawings for the 8 machined parts (purchased parts are not drawn).
Each part has a `.SLDDRW` (editable) and a `.pdf` (for printing / submission).
The current set is **V7**, in `BanVe_ChinhSua_V7/`.

## Drawing standard

- A3 landscape, millimetres, first-angle projection (TCVN / ISO).
- Four views per sheet: three orthographic + one 3D isometric, all at one common
  scale on a fixed 2 × 2 grid.
- Drawing area kept clear of the title block; no leader / text / geometry crosses
  the border.
- Dimensions on the primary view only; the other views stay clean for reference.
- DR-001-x, DR-004 and DR-007 carry a note block for hole spec / PCD and general
  tolerances; freeform surfaces take the 3D model as the machining master.

| Drawing | Part | Common scale |
|---|---|---:|
| DR-001-1 / -2 / -3 | mounting plate / welded frame / hanging lid | 1:10 |
| DR-002 | Motor bracket A | 1:4 |
| DR-003 | Motor bracket B | 1:4 |
| DR-004 | Shoulder bracket | 1:1 |
| DR-005-1 | Upper-arm hub | 1:4 |
| DR-005-2 | Upper-arm link | 1:5 |
| DR-006 | Elbow clevis | 1:4 |
| DR-007 | Moving platform | 1:4 |

## Regeneration

Source scripts: `make_drawing2.ps1` (V6) and `BanVe_ChinhSua_V7/make_drawing_v7.ps1`
(V7), driven over COM. They read material / mass from the live part in
`DeltaRobot_Final/`, rebuild the border, four views and title block, then export
`.SLDDRW` + `.pdf`.

Check report: `BanVe_ChinhSua_V7/KIEMTRA_BANVE_V7.md`.
