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

function [s, out] = generate_isudc(cfg)
%GENERATE_ISUDC Generate the GSFM-GMSK integrated waveform in (3)-(10).

N = round(cfg.T * cfg.fs);
t = (0:N-1).' / cfg.fs;

u = 2*pi*cfg.alpha*(t.^cfg.rho)/cfg.rho;
sincUn = ones(size(u));
nz = abs(u) > 1e-12;
sincUn(nz) = sin(u(nz))./u(nz);
beta = cfg.B/(2*cfg.alpha);
fGSFM = beta*cfg.alpha .* (cos(u) - ((cfg.rho-1)/cfg.rho).*sincUn);
phiGSFM = 2*pi*cumtrapz(t, fGSFM);

symbols = 2*cfg.bits(:)-1;
Tb = cfg.T/numel(symbols);
nrz = zeros(N,1);
for k = 1:numel(symbols)
    i1 = floor((k-1)*N/numel(symbols))+1;
    i2 = floor(k*N/numel(symbols));
    nrz(i1:i2) = symbols(k);
end

% Gaussian premodulation filter. BT and h are explicit assumptions.
sigmaT = sqrt(log(2))/(2*pi*cfg.gmskBT);
halfLen = max(2, ceil(4*sigmaT*Tb*cfg.fs));
tg = (-halfLen:halfLen).' / cfg.fs;
g = exp(-0.5*(tg/(sigmaT*Tb)).^2);
g = g/sum(g);
shaped = conv(nrz, g, 'same');
fGMSK = cfg.gmskH/(2*Tb) * shaped;
phiGMSK = 2*pi*cumtrapz(t, fGMSK);

phase = 2*pi*cfg.fc*t + phiGSFM + phiGMSK;
s = exp(1j*phase);
s = s/sqrt(mean(abs(s).^2));

out.t = t;
out.fGSFM = cfg.fc + fGSFM;
out.fGMSK = fGMSK;
out.instantaneousFrequency = cfg.fc + fGSFM + fGMSK;
out.phaseGSFM = phiGSFM;
out.phaseGMSK = phiGMSK;
out.signal = s;
end
