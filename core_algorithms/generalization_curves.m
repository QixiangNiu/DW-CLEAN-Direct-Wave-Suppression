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

function out = generalization_curves(cfg)
%GENERALIZATION_CURVES DW-CLEAN for alpha/rho combinations in paper Fig. 11.

params = [160 2.0; 160 2.3; 192 2.0; 192 2.3];
out.gapDB = cfg.snrGapGeneralization;
out.params = params;
out.values = zeros(size(params,1), numel(out.gapDB));
out.names = cell(size(params,1),1);

for p = 1:size(params,1)
    local = cfg;
    local.alpha = params(p,1);
    local.rho = params(p,2);
    [tx,~] = generate_isudc(local);
    out.names{p} = sprintf('\\alpha=%g, \\rho=%g', local.alpha, local.rho);
    for q = 1:numel(out.gapDB)
        gap = out.gapDB(q);
        if local.fullWaveformMonteCarlo
            count = 0;
            for r = 1:local.generalizationTrials
                sim = simulate_channel(local,tx,local.directSNRdB-gap, ...
                    local.randomSeed+700000*p+10000*q+r);
                [y,~] = clean_cancel(sim.received,tx,local,true);
                count = count+detection_event(y,tx,sim,local);
            end
            out.values(p,q) = count/local.generalizationTrials;
        else
            sim = simulate_channel(local, tx, local.directSNRdB-gap, ...
                local.randomSeed+700+p*100+q);
            [y,~] = clean_cancel(sim.received, tx, local, true);
            out.values(p,q) = estimate_detection_pd(y, tx, sim, local, ...
                local.generalizationTrials);
        end
    end
    fprintf('Generalization case %d/%d complete.\n', p, size(params,1));
end
end
