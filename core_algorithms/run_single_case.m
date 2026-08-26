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

function result = run_single_case(cfg, tx, echoSNRdB)
%RUN_SINGLE_CASE One complete comparison, corresponding to paper Fig. 6.

sim = simulate_channel(cfg, tx, echoSNRdB, cfg.randomSeed+17);
methods = apply_all_methods(cfg, tx, sim);
nMethods = numel(methods.names);

corrCell = cell(1,nMethods);
tau = [];
for k = 1:nMethods
    [corrCell{k}, tau] = correlation_trace(methods.outputs{k}, tx, ...
        sim.directStart, cfg.fs);
end
referencePeak = max(abs(corrCell{1}));

directPeaks = zeros(nMethods,1);
echoPeaks = zeros(nMethods,1);
directIdx = sim.directStart;
echoIdx = sim.echoStart;
guard = max(2, round(0.002*cfg.fs));
for k = 1:nMethods
    c = abs(corrCell{k})/referencePeak;
    directPeaks(k) = max(c(max(1,directIdx-guard):min(numel(c),directIdx+guard)));
    echoPeaks(k) = max(c(max(1,echoIdx-guard):min(numel(c),echoIdx+guard)));
    corrCell{k} = c;
end

result.sim = sim;
result.names = methods.names;
result.outputs = methods.outputs;
result.infos = methods.infos;
result.sirDB = methods.sirDB;
result.correlation = corrCell;
result.tau = tau;
result.directPeaks = directPeaks;
result.echoPeaks = echoPeaks;
end
