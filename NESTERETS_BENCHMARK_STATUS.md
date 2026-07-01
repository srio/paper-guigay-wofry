# Status handoff — Nesterets & Wilkins (2008) benchmark

_Last updated: 2026-07-01. Author: Claude (Opus 4.8) session._

## Goal
Add a **new benchmark** to the paper (`ltx/main.tex`) reproducing figures of
**Nesterets & Wilkins (2008)**, *"Evaluation of the focusing performance of bent
Laue crystals using wave-optical theory"*, J. Appl. Cryst. **41**, 237–248,
doi:10.1107/S0021889808000617 — PDF at
`C:\Users\srio\OASYS2.0\paper-guigay-wofry\biblio\NesterestsWilkins2008.pdf`.

Reproduce with our WOFRY Laue code, matching the existing benchmark style
(GF2013 / GF2016 / GSdR2022 sections already in the paper).

## Paper parameters to reproduce
- Si(111), **E = 80 keV**, θ_B = 1.4161°, source distance **p = 20 m**,
  thickness **t = 1 mm**, extinction length Λ = 195.9 µm.
- **Fig 2** — wavefield *inside* the crystal (xz plane), α=0, R = ∞, 6, 4, 2, 1 m.
  (⚠ hard: needs field at intermediate depth z∈[0,t]; our GF2016 formalism gives
  the **exit-surface** field only. One ODP panel was flagged "??". Treat Fig 2 as
  optional / lower priority.)
- **Fig 3** — propagated transverse intensity vs z_d, α=0. Ranges:
  R=∞ → z_d∈[0,20 m]; R=6 → [0,9]; R=4 → [0,6]; R=2 → [0,3]; R=1 → [0,1.5].
- **Fig 5** — R=2 m, propagated z_d∈[0,3 m], for α = −0.5°, 0°, 0.5°, 1.0°.

The user already started a slide deck of target figures:
`C:\Users\srio\OASYS2.0\paper-guigay-resources\scripts_new\extra\PaperNesterets2008.odp`
(mostly screenshots; its matplotlib "q [m]" map is a Fig-3-style stacked xscan).

## Key finding on how to reproduce
- **Fig 3 / Fig 5 are 2D maps = `xscan(q)` transverse profiles stacked over a grid
  of q (= z_d).** This is the clean modern path, matching `GF2016_figs.py` /
  `GSdR2022.py` style using `WOLaueCrystal1D`.
- Borrmann fan half-width **a = t·sin(2θ_B)/2 ≈ 25 µm** — exactly the paper's
  Fig-2/3 "25 µm" scale bar. So **`a_factor ≈ 1.5–2`** gives the right x-window.
  The x-grid from `xscan` is fixed per crystal (independent of q), so stacking is clean.

## Relevant code / API (verified this session)
- Core class: `C:\Users\srio\OASYS2.0\OASYS2-ESRF-Extensions\orangecontrib\esrf\util\laue_crystal_focusing.py`
  - `xscan(q=<mm>, npoints_x, a_factor, a_center=0, filename="")` →
    `(xx[mm], yy_amplitude[complex], output_wavefront)`. Dispatches GF2016
    eq 23 (p=0,q=0), eq 24 (p=0,q≠0), eq 30 (p≠0,q=0), eq 31 (p≠0,q≠0).
  - `qscan(qmin,qmax,npoints)` (mm internally).
  - `chih2=None` override kwarg (added yesterday) to inject a paper's exact χ_h·χ_h̄.
  - **Internally distances are in mm.**
- Widget wrapper: `...\orangecontrib\esrf\wofry\widgets\extension\ow_laue_crystal.py`
  - `WOLaueCrystal1D(crystal_descriptor='Si', hkl=[1,1,1], R=<m>, poisson_ratio,
    photon_energy=<eV>, thickness=<m>, p=<m>, q=<m>, alfa_deg, integration_points,
    npoints_x, a_factor, use_fast_hyp1f1=0, apply_absorption=True, source_flag=1,
    chih2=None, verbose)`.
  - `.qscan(qmin,qmax,qpoints)` here takes **q in metres** (×1e3 internally).
  - ⚠ `.xscan(...)` on the **widget** is NOT a public proxy — the widget calls
    `self._LaueCrystalFocusing.xscan(self._q, ...)` inside `applyOpticalElement`.
    For a Fig-3 map, either (a) call `WOLaueCrystal1D(...)._LaueCrystalFocusing.xscan(q_mm, ...)`
    directly, or (b) instantiate `LaueCrystalFocusing` from the util module directly.

## Plan (next steps — NOT yet done)
1. Write `scripts_new\laue_wofry\Nesterets2008_figs.py` (mirror GF2016_figs.py):
   - `get_optical_element(R, alfa_deg, photon_energy=80000, p=20, thickness=1e-3)`.
   - `qmap(oe, qmin, qmax, qpoints, npoints_x, a_factor)` helper: loop q, call
     `xscan`, stack `|amp|^2` → 2D array; `plot_image` with x[µm] vs z_d[m].
   - `calculate_fig3(R, zmax)` for R ∈ {1e9, 6, 4, 2, 1}, save
     `Nesterets2008_fig3_R*.png`.
   - `calculate_fig5(alfa_deg)` for α ∈ {−0.5,0,0.5,1.0} at R=2, zmax=3, save
     `Nesterets2008_fig5_*.png`.
2. **Validate at LOW resolution first** (npoints_x≈40, qpoints≈40, one R) and time
   it before scaling — xscan loops over integration_points×npoints_x, and stacking
   over qpoints can be slow. Run as a **script file** (NOT `python -c`; widget
   imports are environment-sensitive and fail under -c). Use python `C:\oasys2\python.exe`.
3. Compare maps to paper Figs 3/5 (bowtie focusing; diffraction focus ≠ geometrical
   focus for R<∞; α tunes the focus for Fig 5).
4. Add the benchmark subsection + figures to `ltx/main.tex`, matching the existing
   GF/GSdR benchmark prose. Recompile (currently 38 pages) and latexdiff vs main-orig.

## Environment / conventions notes
- Python: use `C:\oasys2\python.exe` (the WindowsApps `python` is a stub; do NOT use).
- Sign convention settled yesterday: code uses **Im(χ_h·χ_h̄) > 0** (structure-factor
  product χ_h·χ_{−h}, matching GF2013/GF2016/paper2013.py). GSdR2022 uses the
  conjugate (Im<0) → q-mirror. `.tex` benchmarking section already rewritten for this.
- `laue_wofry\*.py` (GFBMP2013_figs.py, GF2016_figs.py, GSdR2022.py) are UNTRACKED in
  git — recovered from dangling blobs yesterday; consider `git add`. Do the same for
  the new Nesterets script.

## Temp artifacts left this session (safe to delete)
- `C:\Users\srio\OASYS2.0\paper-guigay-wofry\_june30_convo.txt` (extracted transcript)
- `...\scripts_new\extra\_odp_tmp\` (ODP extraction: PNGs + odp_text.txt)
