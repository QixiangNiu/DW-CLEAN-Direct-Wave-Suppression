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
%CORRELATION_SIR_DB Equation (37) in the matched-filter decision domain.
% The known simulated echo is the signal of interest. Everything remaining
% in the processed output is direct-wave residue, multipath, and noise.
[cSignal,~] = correlation_trace(sim.echo,tx,sim.directStart,cfg.fs);
[cInterference,~] = correlation_trace(output-sim.echo,tx, ...
    sim.directStart,cfg.fs);
guard = max(2,round(0.002*cfg.fs));
directRange = sim.directStart:min(numel(cInterference), ...
    sim.directStart+round(cfg.maxDirectMultipathDelaySec*cfg.fs));
echoRange = max(1,sim.echoStart-guard):min(numel(cInterference),sim.echoStart+guard);
signalPower = max(abs(cSignal(echoRange)).^2);
directPower = max(abs(cInterference(directRange)).^2);
mask = true(size(cInterference));
mask(max(1,directRange(1)-guard):min(numel(mask),directRange(end)+guard)) = false;
mask(max(1,echoRange(1)-guard):min(numel(mask),echoRange(end)+guard)) = false;
noisePower = median(abs(cInterference(mask)).^2);
interferencePower = directPower+noisePower;
value = 10*log10((signalPower+eps)/(interferencePower+eps));
end
