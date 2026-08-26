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

function out = iteration_curves(cfg, tx)
%ITERATION_CURVES Numerical data corresponding to paper Figs. 5 and 8.

sim = simulate_channel(cfg,tx,cfg.directSNRdB-40,cfg.randomSeed+81000);
out.iterations = cfg.iterationCounts;
out.names = {'LMS','NLMS','RLS','CLEAN','DW-CLEAN'};
out.sirDB = zeros(numel(out.names),numel(out.iterations));
out.residualMSE = zeros(size(out.sirDB));

for q = 1:numel(out.iterations)
    count = out.iterations(q);
    if count == 0
        outputs = repmat({sim.received},1,numel(out.names));
    else
        local = cfg;
        local.adaptiveMaxUpdates = count;
        local.cleanMaxIterations = count;
        local.dwMaxIterations = count;
        outputs = cell(1,numel(out.names));
        outputs{1} = adaptive_cancel(sim.received,sim.reference,local,'LMS');
        outputs{2} = adaptive_cancel(sim.received,sim.reference,local,'NLMS');
        outputs{3} = adaptive_cancel(sim.received,sim.reference,local,'RLS');
        outputs{4} = clean_cancel(sim.received,tx,local,false);
        outputs{5} = clean_cancel(sim.received,tx,local,true);
    end
    for method = 1:numel(out.names)
        out.sirDB(method,q) = correlation_sir_db(outputs{method},tx,sim,cfg);
        residualInterference = outputs{method}-sim.echo-sim.noise;
        out.residualMSE(method,q) = mean(abs(residualInterference).^2);
    end
end
end
