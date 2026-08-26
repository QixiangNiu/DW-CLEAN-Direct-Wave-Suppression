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

function sim = simulate_channel(cfg, tx, echoSNRdB, noiseSeed)
%SIMULATE_CHANNEL Bistatic direct wave, strong multipath, echo, and noise.

if nargin >= 4, previous = rng; rng(noiseSeed, 'twister'); end
N = round(cfg.recordDuration*cfg.fs);
L = numel(tx);
iDirect = round(cfg.directStartSec*cfg.fs)+1;
iEcho = iDirect + round(cfg.echoDelay*cfg.fs);

if iEcho+L-1 > N
    error('Record duration is too short for the configured echo.');
end

% Frequency-dependent absorption from paper (12)-(13).
phase = unwrap(angle(tx));
fInst = [diff(phase); phase(end)-phase(end-1)]*cfg.fs/(2*pi);
fKHz = max(abs(fInst), 1)/1000;
betaAbs = 0.11*fKHz.^2./(1+fKHz.^2) + 44*fKHz.^2./(4100+fKHz.^2);
absorption = 10.^(-((cfg.bistaticDistance/1000).*betaAbs)/20);
absorption = absorption/mean(absorption);

directScale = sqrt(cfg.noisePower*10^(cfg.directSNRdB/10));
echoScale = sqrt(cfg.noisePower*10^(echoSNRdB/10));
directPulse = directScale * absorption .* tx;
echoPulse = echoScale * tx;

direct = zeros(N,1);
direct(iDirect:iDirect+L-1) = directPulse;
multipath = zeros(N,1);
for k = 1:numel(cfg.multipathDelaySec)
    idx = iDirect + round(cfg.multipathDelaySec(k)*cfg.fs);
    multipath(idx:idx+L-1) = multipath(idx:idx+L-1) + ...
        cfg.multipathGain(k)*directPulse;
end
echo = zeros(N,1);
echo(iEcho:iEcho+L-1) = echoPulse;
noise = sqrt(cfg.noisePower/2)*(randn(N,1)+1j*randn(N,1));

reference = zeros(N,1);
reference(iDirect:iDirect+L-1) = tx;

sim.received = direct + multipath + echo + noise;
sim.reference = reference;
sim.direct = direct;
sim.multipath = multipath;
sim.echo = echo;
sim.noise = noise;
sim.directStart = iDirect;
sim.echoStart = iEcho;
sim.echoSNRdB = echoSNRdB;
if nargin >= 4, rng(previous); end
end
