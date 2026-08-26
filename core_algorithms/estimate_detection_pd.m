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

function pd = estimate_detection_pd(output, tx, sim, cfg, trials)
%ESTIMATE_DETECTION_PD Scalar matched-filter Monte Carlo detection model.
% Suppression is performed in the full waveform domain. The known simulated
% echo supplies the deterministic matched-filter mean; residual direct wave,
% multipath, and noise supply the interference distribution.

[cSignal,~] = correlation_trace(sim.echo,tx,sim.directStart,cfg.fs);
[cInterference,~] = correlation_trace(output-sim.echo,tx, ...
    sim.directStart,cfg.fs);
echoIdx = sim.echoStart;
guard = round(0.03*cfg.fs);
mask = true(size(cInterference));
for idx = [sim.directStart, sim.echoStart]
    mask(max(1,idx-guard):min(numel(cInterference),idx+guard)) = false;
end
floorSamples = cInterference(mask);
sigma = sqrt(mean(abs(floorSamples).^2)+eps);
mu = cSignal(echoIdx)+cInterference(echoIdx);
threshold = sigma*sqrt(-log(cfg.detectionPfa));
draws = mu + sigma/sqrt(2)*(randn(trials,1)+1j*randn(trials,1));
pd = mean(abs(draws) > threshold);
end
