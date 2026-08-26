# DW-CLEAN Direct-Wave Suppression

**An Improved CLEAN Direct-Wave Suppression Algorithm for Integrated Underwater Detection and Communication**

---

## 📑 Paper

**An Improved CLEAN Direct-Wave Suppression Algorithm in Integrated System of Underwater Detection and Communication**

Qixiang Niu, Wentao Shi, Qunfei Zhang, and Chenglin Zhang  
*IEEE Sensors Journal*, vol. 24, no. 6, pp. 8503–8516, 15 March 2024.  
DOI: [10.1109/JSEN.2024.3360274](https://doi.org/10.1109/JSEN.2024.3360274)

---

## ✨ Highlights

- 🔹 Reproduces the paper's GSFM-GMSK integrated detection-and-communication waveform.
- 🔹 Implements equations (20)–(33) and the double-window movement, segmentation, reconstruction, thresholding, and splicing operations in Algorithm 1.
- 🔹 Compares DW-CLEAN with CLEAN, LMS, NLMS, and RLS direct-wave cancellation.
- 🔹 Evaluates matched-filter-domain SIR, detection probability, processed-array MUSIC spectra, iteration histories, and waveform-parameter generalization.
- 🔹 Provides a quick verification mode and a 5000-trial paper-scale Monte Carlo mode.
- 🔹 Performs numerical simulation only: no figures, images, or result files are generated.

---

## 🔎 Overview

In an integrated underwater detection and communication system, a strong direct wave and its multipath components may mask a much weaker target echo. This repository reconstructs the processing chain described in the paper: GSFM-GMSK waveform generation, discrete-ray bistatic-channel simulation, conventional CLEAN and DW-CLEAN suppression, matched-filter evaluation, detection-probability estimation, processed-array MUSIC comparison, iteration analysis, and parameter-generalization tests.

The implementation keeps the parameters disclosed in the paper and records the necessary reproduction assumptions in `config_dw_clean.m`. Since some implementation details and experimental data are not fully disclosed, independently generated numerical values may not exactly match the published results, but the code is designed to reproduce the method and its principal trends as closely as possible.

---

## 🗂️ Repository Structure

`core_algorithms` is the descriptive replacement for the conventional folder name `src`. In software repositories, `src` is short for **source** and normally stores source-code files; the name `core_algorithms` makes the folder's purpose explicit here.

```text
DW_CLEAN_DirectWave_Suppression/
├── README.md
├── config_dw_clean.m
├── main_reproduce.m
├── self_test.m
└── core_algorithms/
    ├── adaptive_cancel.m
    ├── apply_all_methods.m
    ├── clean_cancel.m
    ├── correlation_par_db.m
    ├── correlation_sir_db.m
    ├── correlation_trace.m
    ├── detection_event.m
    ├── estimate_detection_pd.m
    ├── generalization_curves.m
    ├── generate_isudc.m
    ├── iteration_curves.m
    ├── monte_carlo_curves.m
    ├── music_comparison.m
    ├── run_single_case.m
    └── simulate_channel.m
```

### File descriptions

| File | Purpose |
| --- | --- |
| `main_reproduce.m` | Main entry point. Runs the complete reproduction and returns all numerical outputs in `DW_CLEAN_results`. |
| `config_dw_clean.m` | Central configuration for paper parameters, explicitly stated reproduction assumptions, random seed, and run mode. |
| `self_test.m` | Runs waveform, SNR, suppression, finite-value, output-size, and no-figure assertions without writing result files. |
| `core_algorithms/generate_isudc.m` | Generates the GSFM-GMSK integrated waveform following the paper's signal model. |
| `core_algorithms/simulate_channel.m` | Implements a finite discrete-ray form of equations (11)–(16), including spreading, frequency-dependent absorption, direct-wave multipath, target echo, and noise. |
| `core_algorithms/run_single_case.m` | Runs one complete method comparison for a selected echo SNR. |
| `core_algorithms/apply_all_methods.m` | Applies the unprocessed baseline, CLEAN, DW-CLEAN, LMS, NLMS, and RLS methods to one received record. |
| `core_algorithms/clean_cancel.m` | Implements equations (20)–(33) and Algorithm 1, including Window1 movement records, Window2 segmentation, segment-wise estimation, continuous reconstruction, splicing, and threshold termination. |
| `core_algorithms/adaptive_cancel.m` | Implements the complex LMS, NLMS, and RLS reference-channel cancellers. |
| `core_algorithms/correlation_trace.m` | Computes the sliding complex matched-filter/correlation trace. |
| `core_algorithms/correlation_par_db.m` | Computes the peak-to-RMS ratio of a complex correlation trace. |
| `core_algorithms/correlation_sir_db.m` | Evaluates equation (37) in the matched-filter decision domain using the known simulated echo and the residual interference. |
| `core_algorithms/detection_event.m` | Makes one full-waveform matched-filter detection decision. |
| `core_algorithms/estimate_detection_pd.m` | Estimates detection probability with a scalar matched-filter Monte Carlo model. |
| `core_algorithms/monte_carlo_curves.m` | Computes SIR and detection-probability curves over the configured SNR gaps. |
| `core_algorithms/music_comparison.m` | Computes eight-element MUSIC spectra from the actual processed matched-filter snapshots rather than preset paper table values. |
| `core_algorithms/generalization_curves.m` | Evaluates DW-CLEAN under the paper's GSFM parameter combinations. |
| `core_algorithms/iteration_curves.m` | Returns numerical residual-error and SIR histories corresponding to the iteration studies in paper Figs. 5 and 8. |

---

## 🛠️ Getting Started

### Requirements

- MATLAB R2021b or later is recommended.
- No external dataset or third-party MATLAB toolbox is required by the current implementation.

### ▶️ Run Example

1. Open MATLAB and set the repository root as the current folder.
2. Open `config_dw_clean.m` and select a run mode:
   - `"quick"`: reduced Monte Carlo counts for code verification.
   - `"paper"`: 5000 Monte Carlo trials for paper-scale reproduction; this mode requires substantially more computation time.
3. Run:

```matlab
main_reproduce
```

The program does not create figures or output files. When execution finishes, all calculated data are available in the MATLAB workspace variable:

```matlab
DW_CLEAN_results
```

Before a long run, the numerical implementation can be checked with:

```matlab
self_test
```

For reproducibility, the default random seed is fixed in `config_dw_clean.m`.

---

## 📈 Results Summary

The returned structure contains the following numerical results:

| Field | Contents |
| --- | --- |
| `configuration` | All disclosed parameters, reproduction assumptions, and run settings. |
| `transmittedSignal` | Generated complex integrated waveform. |
| `waveform` | Intermediate waveform components and related metadata. |
| `singleCase` | One-channel realization and the outputs of all suppression methods. |
| `sirCurves` | Correlation-domain SIR results versus direct-wave/echo SNR gap. |
| `detectionProbability` | Estimated detection-probability results for the comparison methods. |
| `music` | MUSIC spatial-spectrum data before and after suppression. |
| `generalization` | DW-CLEAN results for the configured GSFM parameter combinations. |
| `iterationCurves` | Residual-MSE and SIR arrays versus iteration count; no plot is created. |

Expected qualitative behavior follows the paper: DW-CLEAN is intended to suppress the direct wave together with strong nearby multipath components while preserving the delayed weak echo more effectively than the comparison methods. Exact values depend on random channel/noise realizations and on assumptions needed for parameters that the paper does not disclose.

---

## 🔖 Citation

If this reproduction or the original method contributes to your research, please cite the paper:

```bibtex
@article{niu2024improved,
  author  = {Qixiang Niu and Wentao Shi and Qunfei Zhang and Chenglin Zhang},
  title   = {An Improved CLEAN Direct-Wave Suppression Algorithm in Integrated System of Underwater Detection and Communication},
  journal = {IEEE Sensors Journal},
  year    = {2024},
  volume  = {24},
  number  = {6},
  pages   = {8503--8516},
  doi     = {10.1109/JSEN.2024.3360274}
}
```

---

## ✉️ Contact

QIXIANG NIU  
School of Marine Science and Technology, Northwestern Polytechnical University  
Underwater Communication and Cooperative Detection Laboratory  
Ocean Institute, Northwestern Polytechnical University  
Email: [niuqx@mail.nwpu.edu.cn](mailto:niuqx@mail.nwpu.edu.cn)

---

## 💡 Notes

- This repository is an independent MATLAB reproduction intended for academic research and method verification.
- Parameters stated in the paper are separated from additional reproduction assumptions in `config_dw_clean.m`.
- Water depth, detailed ray geometry, reflection products, GMSK BT product and modulation index, detection false-alarm probability, and several implementation details are not disclosed by the paper; the corresponding assumptions are centralized in `config_dw_clean.m`.
- The default `quick` mode verifies the complete processing chain but is not intended to provide statistically converged paper-level curves.
- The `paper` mode increases Monte Carlo counts to 5000 and may take several hours depending on the computer.
- The published high-SNR-gap detection probabilities cannot be guaranteed from the disclosed parameters alone. The repository computes them from the stated signal/noise model and reports independently obtained values rather than embedding or forcing the paper's curves.
- No paper figures, copyrighted graphical assets, or experimental datasets are included.

---

## 🛡️ © Copyright

Copyright © 2023 QIXIANG NIU. All rights reserved.

Affiliations: 西北工业大学航海学院“水下通信与协同探测”实验室；西北工业大学海洋研究院。

The code is provided for academic research and reproducibility. Please retain the authorship and copyright notices in redistributed or modified copies.
