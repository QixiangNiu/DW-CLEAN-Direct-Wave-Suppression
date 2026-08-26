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

function [sirCurves, pdCurves] = monte_carlo_curves(cfg, tx)
%MONTE_CARLO_CURVES Reproduce the SIR and detection-probability trends.

names = {'No suppression','LMS','NLMS','RLS','CLEAN','DW-CLEAN'};

sirCurves.gapDB = cfg.snrGapSIR;
sirCurves.names = names;
sirCurves.values = zeros(numel(names), numel(sirCurves.gapDB));
for q = 1:numel(sirCurves.gapDB)
    gap = sirCurves.gapDB(q);
    if cfg.fullWaveformMonteCarlo
        accum = zeros(numel(names),1);
        for r = 1:cfg.monteCarloTrials
            sim = simulate_channel(cfg,tx,cfg.directSNRdB-gap,cfg.randomSeed+100000*q+r);
            methods = apply_all_methods(cfg,tx,sim);
            accum = accum+methods.sirDB(:);
        end
        sirCurves.values(:,q) = accum/cfg.monteCarloTrials;
    else
        sim = simulate_channel(cfg, tx, cfg.directSNRdB-gap, cfg.randomSeed+100+q);
        methods = apply_all_methods(cfg, tx, sim);
        sirCurves.values(:,q) = methods.sirDB(:);
    end
    fprintf('SIR curve %d/%d complete.\n', q, numel(sirCurves.gapDB));
end

pdCurves.gapDB = cfg.snrGapDetection;
pdCurves.names = names(2:end);
pdCurves.values = zeros(numel(names)-1, numel(pdCurves.gapDB));
for q = 1:numel(pdCurves.gapDB)
    gap = pdCurves.gapDB(q);
    if cfg.fullWaveformMonteCarlo
        counts = zeros(numel(names)-1,1);
        for r = 1:cfg.monteCarloTrials
            sim = simulate_channel(cfg,tx,cfg.directSNRdB-gap,cfg.randomSeed+300000*q+r);
            methods = apply_all_methods(cfg,tx,sim);
            for m = 2:numel(names)
                counts(m-1) = counts(m-1)+detection_event(methods.outputs{m},tx,sim,cfg);
            end
        end
        pdCurves.values(:,q) = counts/cfg.monteCarloTrials;
    else
        sim = simulate_channel(cfg, tx, cfg.directSNRdB-gap, cfg.randomSeed+300+q);
        methods = apply_all_methods(cfg, tx, sim);
        for m = 2:numel(names)
            pdCurves.values(m-1,q) = estimate_detection_pd( ...
                methods.outputs{m}, tx, sim, cfg, cfg.monteCarloTrials);
        end
    end
    fprintf('Detection curve %d/%d complete (%d scalar MC trials).\n', ...
        q, numel(pdCurves.gapDB), cfg.monteCarloTrials);
end
end
