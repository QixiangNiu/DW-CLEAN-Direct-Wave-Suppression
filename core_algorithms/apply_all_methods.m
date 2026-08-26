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

function result = apply_all_methods(cfg, tx, sim)
%APPLY_ALL_METHODS Run every comparison method on one received record.

names = {'No suppression','LMS','NLMS','RLS','CLEAN','DW-CLEAN'};
outputs = cell(size(names));
infos = cell(size(names));
outputs{1} = sim.received;
infos{1} = struct('method','No suppression');

[outputs{2}, infos{2}] = adaptive_cancel(sim.received, sim.reference, cfg, 'LMS');
[outputs{3}, infos{3}] = adaptive_cancel(sim.received, sim.reference, cfg, 'NLMS');
[outputs{4}, infos{4}] = adaptive_cancel(sim.received, sim.reference, cfg, 'RLS');
[outputs{5}, infos{5}] = clean_cancel(sim.received, tx, cfg, false);
[outputs{6}, infos{6}] = clean_cancel(sim.received, tx, cfg, true);

result.names = names;
result.outputs = outputs;
result.infos = infos;
result.sirDB = cellfun(@(z) correlation_sir_db(z, tx, sim, cfg), outputs);
end
