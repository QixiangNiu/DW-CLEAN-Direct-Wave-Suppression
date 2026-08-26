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

function value = correlation_sir_db(output, tx, sim, cfg)
%CORRELATION_SIR_DB Echo peak versus residual direct/multipath and floor.
[c,~] = correlation_trace(output, tx, sim.directStart, cfg.fs);
guard = max(2,round(0.002*cfg.fs));
directRange = sim.directStart:min(numel(c), ...
    sim.directStart+round(cfg.maxDirectMultipathDelaySec*cfg.fs));
echoRange = max(1,sim.echoStart-guard):min(numel(c),sim.echoStart+guard);
echoPeak = max(abs(c(echoRange)));
directPeak = max(abs(c(directRange)));
mask = true(size(c));
mask(max(1,directRange(1)-guard):min(numel(c),directRange(end)+guard)) = false;
mask(max(1,echoRange(1)-guard):min(numel(c),echoRange(end)+guard)) = false;
floorPower = median(abs(c(mask)).^2);
value = 10*log10((echoPeak^2+eps)/(directPeak^2+floorPower+eps));
end
