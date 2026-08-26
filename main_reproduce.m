% =========================================================================
% *       *  *********  *       *
% **      *  *       *  *       *
% * *     *  *       *  *       *
% *  *    *  *       *  *       *
% *   *   *  *********  *       *
% *    *  *  *          *       *
% *     * *  *          *       *
% *      **  *          *       *
% *       *  *           *******
%
% Author: QIXIANG NIU
% Affiliation:
%   Northwestern Polytechnical University, School of Marine Science and Technology
%   Underwater Communication and Cooperative Detection Laboratory
%   Ocean Institute, Northwestern Polytechnical University
% Chinese affiliation:
%   西北工业大学航海学院“水下通信与协同探测”实验室
%   西北工业大学海洋研究院
% Date: 2023-10-15
% Copyright (c) 2023 QIXIANG NIU. All rights reserved.
% For academic research and reproducibility. Retain this notice.
% =========================================================================

clear; clc;
rootDir = fileparts(mfilename('fullpath'));
addpath(fullfile(rootDir, 'core_algorithms'));
cfg = config_dw_clean();
rng(cfg.randomSeed, 'twister');

fprintf('DW-CLEAN reproduction mode: %s\n', cfg.runMode);

[tx, waveform] = generate_isudc(cfg);

single = run_single_case(cfg, tx, -25);

[sirCurves, pdCurves] = monte_carlo_curves(cfg, tx);

music = music_comparison(single, cfg);

generalization = generalization_curves(cfg);

DW_CLEAN_results = struct( ...
    'configuration', cfg, ...
    'transmittedSignal', tx, ...
    'waveform', waveform, ...
    'singleCase', single, ...
    'sirCurves', sirCurves, ...
    'detectionProbability', pdCurves, ...
    'music', music, ...
    'generalization', generalization);

fprintf('Completed. Results are available in workspace variable DW_CLEAN_results.\n');
