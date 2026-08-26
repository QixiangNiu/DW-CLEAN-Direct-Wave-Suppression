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

function detected = detection_event(output, tx, sim, cfg)
%DETECTION_EVENT One full-waveform matched-filter detection decision.
[c,~] = correlation_trace(output, tx, sim.directStart, cfg.fs);
echoIdx = sim.echoStart;
guard = round(0.03*cfg.fs);
mask = true(size(c));
for idx = [sim.directStart, sim.echoStart]
    mask(max(1,idx-guard):min(numel(c),idx+guard)) = false;
end
sigma = sqrt(mean(abs(c(mask)).^2)+eps);
threshold = sigma*sqrt(-log(cfg.detectionPfa));
detected = abs(c(echoIdx)) > threshold;
end
