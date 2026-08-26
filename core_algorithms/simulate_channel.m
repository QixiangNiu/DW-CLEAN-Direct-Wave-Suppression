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
%SIMULATE_CHANNEL Discrete-ray implementation of paper equations (11)-(16).

if nargin >= 4, previous = rng; rng(noiseSeed, 'twister'); end
N = round(cfg.recordDuration*cfg.fs);
L = numel(tx);
iDirect = round(cfg.directStartSec*cfg.fs)+1;
iEcho = iDirect + round(cfg.echoDelay*cfg.fs);

if iEcho+L-1 > N
    error('Record duration is too short for the configured echo.');
end

% Frequency-dependent absorption in (12)-(13). The instantaneous physical
% frequency is used in kHz. Absolute propagation loss is absorbed into the
% requested received SNR; its frequency-dependent shape is retained.
phase = unwrap(angle(tx));
fInst = [diff(phase); phase(end)-phase(end-1)]*cfg.fs/(2*pi);
fKHz = max(abs(fInst), 1)/1000;
betaAbs = 0.11*fKHz.^2./(1+fKHz.^2) + 44*fKHz.^2./(4100+fKHz.^2);
directAbsorption = 10.^(-((cfg.bistaticDistance/1000).*betaAbs)/20);
directShape = directAbsorption.*tx;
directScale = sqrt(cfg.noisePower*10^(cfg.directSNRdB/10) / ...
    mean(abs(directShape).^2));
echoScale = sqrt(cfg.noisePower*10^(echoSNRdB/10) / mean(abs(tx).^2));
directPulse = directScale*directShape;
echoPulse = echoScale*tx;

direct = zeros(N,1);
direct(iDirect:iDirect+L-1) = directPulse;
multipath = zeros(N,1);
for k = 1:numel(cfg.multipathDelaySec)
    idx = iDirect + round(cfg.multipathDelaySec(k)*cfg.fs);
    pathDistance = cfg.bistaticDistance + ...
        cfg.soundSpeed*cfg.multipathDelaySec(k);
    pathAbsorption = 10.^(-((pathDistance/1000).*betaAbs)/20);
    spreadingRatio = cfg.bistaticDistance/pathDistance;
    pathPulse = directScale*spreadingRatio*cfg.multipathReflection(k).* ...
        pathAbsorption.*tx;
    multipath(idx:idx+L-1) = multipath(idx:idx+L-1) + ...
        pathPulse;
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
sim.instantaneousFrequencyHz = fInst;
sim.absorptionDBPerKm = betaAbs;
if nargin >= 4, rng(previous); end
end
