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

function cfg = config_dw_clean()
%CONFIG_DW_CLEAN Parameters for the IEEE Sensors Journal reproduction.

cfg.runMode = "quick";          % "quick" or "paper"
cfg.randomSeed = 20240315;

% Paper-disclosed waveform/channel parameters.
cfg.fs = 12000;
cfg.T = 0.25;
cfg.B = 2000;
cfg.fc = 2000;
cfg.alpha = 192;
cfg.rho = 2;
cfg.bits = [1 1 1 1 1 1 1 0 1 0 1 0 0 1 0 1 1 1];
cfg.soundSpeed = 1500;
cfg.bistaticDistance = 1000;
cfg.echoDelay = 0.5;
cfg.directSNRdB = 10;

% Paper-disclosed DW-CLEAN/adaptive parameters.
cfg.window2Segments = 10;
cfg.thresholdDB = 15;
cfg.window1StepSec = 0.05;
cfg.filterOrder = 30;
cfg.muLMS = 0.05;
cfg.muNLMS = 0.05;
cfg.nlmsDelta = 0.1;
cfg.rlsLambda = 1;

% Explicit reproduction assumptions (not disclosed by the paper).
cfg.gmskBT = 0.3;
cfg.gmskH = 0.5;
cfg.directStartSec = 0.20;
cfg.recordDuration = 1.25;
cfg.multipathDelaySec = [0.018 0.047];
cfg.multipathGain = [-0.55*exp(1j*0.4), 0.32*exp(-1j*0.7)];
cfg.maxDirectMultipathDelaySec = 0.15;
cfg.noisePower = 1;
cfg.cleanLoopGain = 1.0;
% The paper notes that conventional CLEAN makes only the single strongest
% judgement, whereas window1 lets DW-CLEAN revisit strong multipath.
cfg.cleanMaxIterations = 1;
cfg.dwMaxIterations = 8;
cfg.arrayElements = 8;
cfg.directAngleDeg = 0;
cfg.echoAngleDeg = 60;
cfg.musicSnapshots = 600;
cfg.detectionPfa = 1e-3;

if cfg.runMode == "paper"
    cfg.monteCarloTrials = 5000;
    cfg.generalizationTrials = 5000;
    cfg.fullWaveformMonteCarlo = true;
else
    cfg.monteCarloTrials = 80;
    cfg.generalizationTrials = 60;
    cfg.fullWaveformMonteCarlo = false;
end

cfg.snrGapSIR = 0:5:40;
cfg.snrGapDetection = 0:10:60;
cfg.snrGapGeneralization = 0:10:60;
end
