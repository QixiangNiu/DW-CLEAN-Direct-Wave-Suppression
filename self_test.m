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
addpath(fullfile(rootDir,'core_algorithms'));
cfg = config_dw_clean();
[tx,waveform] = generate_isudc(cfg);
assert(numel(tx) == round(cfg.T*cfg.fs));
assert(all(isfinite(tx)) && all(isfinite(waveform.instantaneousFrequency)));
assert(max(abs(abs(tx)-1)) < 1e-12);

sim = simulate_channel(cfg,tx,-25,cfg.randomSeed+17);
directSNR = 10*log10(mean(abs(sim.direct(sim.direct~=0)).^2)/ ...
    mean(abs(sim.noise).^2));
echoSNR = 10*log10(mean(abs(sim.echo(sim.echo~=0)).^2)/ ...
    mean(abs(sim.noise).^2));
assert(abs(directSNR-cfg.directSNRdB) < 0.2);
assert(abs(echoSNR+25) < 0.2);

methods = apply_all_methods(cfg,tx,sim);
for method = 1:numel(methods.outputs)
    assert(numel(methods.outputs{method}) == numel(sim.received));
    assert(all(isfinite(methods.outputs{method})));
    assert(isfinite(methods.sirDB(method)));
end
assert(methods.infos{6}.iterations > 0);
assert(isempty(findall(groot,'Type','figure')));
fprintf('All DW-CLEAN numerical self-tests passed. No figures were created.\n');
